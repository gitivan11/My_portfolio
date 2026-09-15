
"""
Australia GDP forecasting project with Diebold-Mariano tests.

Main specification
------------------
Preferred ADL(1):
    gdp_growth_t ~ gdp_growth_{t-1} + export_growth_{t-1}
                   + interest_rate_{t-1} + inflation_{t-1}

Robustness specifications (added)
----------------------------------
ADL(1) – Terms-of-trade alternative (replaces export_growth with tot_growth):
    gdp_growth_t ~ gdp_growth_{t-1} + tot_growth_{t-1}
                   + interest_rate_{t-1} + inflation_{t-1}

ADL(1) – Delta-rate alternative (replaces interest_rate level with first diff):
    delta_interest_rate_t = interest_rate_t - interest_rate_{t-1}
    gdp_growth_t ~ gdp_growth_{t-1} + export_growth_{t-1}
                   + delta_interest_rate_{t-1} + inflation_{t-1}

What the script does
--------------------
1. Downloads Australian quarterly macro data from FRED
   (including a terms-of-trade proxy series).
2. Builds a cleaned common-support quarterly dataset.
3. Computes YoY transformations with pct_change(fill_method=None);
   also constructs tot_growth (YoY) and delta_interest_rate (first diff).
4. Produces descriptives, plots, and ADF tests.
5. Estimates:
   - Model A: contemporaneous interest and inflation
   - Preferred ADL(1)
   - Preferred ADL(1) with HAC standard errors
   - ADL(2) candidate
   - ADL(2) with HAC standard errors
   - Crisis-dummy ADL(1)
   - Crisis-dummy ADL(2)
   - Robustness ADL(1) – ToT alternative
   - Robustness ADL(1) – ToT with HAC standard errors
   - Robustness ADL(1) – delta-rate alternative
   - Robustness ADL(1) – delta-rate with HAC standard errors
6. Runs diagnostics and Wald test on the preferred ADL(1).
7. Builds recursive 1-step-ahead forecasts for:
   - ADL(1)          (preferred)
   - ADL(2)
   - AR(2)
   - VAR(2)
   - Equal-weight combination of ADL(1), AR(2), VAR(2)
   - ADL(1) – ToT robustness
   - ADL(1) – delta-rate robustness
8. Computes forecast metrics and Diebold-Mariano tests
   (including DM tests of robustness models vs the preferred ADL(1)).
9. Writes csv/png/txt outputs, including DM-test results and
   alternative-regressor summary tables.

Install:
    pip install pandas numpy matplotlib statsmodels scipy fredapi pandas-datareader

Run:
    export FRED_API_KEY="YOUR_KEY"
    python australia_gdp_project_dm.py
"""

from __future__ import annotations

import os
import shutil
import warnings
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from scipy import stats
from statsmodels.stats.diagnostic import acorr_breusch_godfrey, het_white
from statsmodels.stats.stattools import jarque_bera
from statsmodels.tsa.api import VAR
from statsmodels.tsa.stattools import adfuller

warnings.filterwarnings("ignore")

START_DATE = "1996-01-01"
END_DATE = "2026-01-01"
FORECAST_HORIZON = 40
HAC_LAGS = 4
DM_HORIZON = 1
PROJECT_FOLDER_NAME = "australia_econometrics_project_dm"
FRED_API_KEY = os.getenv("FRED_API_KEY")


@dataclass
class SeriesConfig:
    candidates: List[str]
    agg: str
    display_name: str


SERIES_CONFIG: Dict[str, SeriesConfig] = {
    "gdp_level": SeriesConfig(
        candidates=[
            "AUSGDPRQDSMEI",   # OECD quarterly real GDP
            "NGDPRSAXDCAUQ",   # IMF quarterly real GDP fallback
            "NAEXKP01AUQ189S", # requested earlier
        ],
        agg="last",
        display_name="Real GDP",
    ),
    "cpi_index": SeriesConfig(
        candidates=[
            "AUSCPIALLQINMEI", # quarterly CPI
            "AUSCPIALLMINMEI", # monthly fallback
        ],
        agg="mean",
        display_name="Consumer Price Index",
    ),
    "interest_rate": SeriesConfig(
        candidates=[
            "IR3TIB01AUQ156N", # quarterly 3m interbank rate
            "IR3TIB01AUM156N", # monthly fallback
        ],
        agg="mean",
        display_name="3-month interest rate",
    ),
    "export_level": SeriesConfig(
        candidates=[
            "NXRSAXDCAUQ",     # quarterly real exports of goods and services
            "NXRNSAXDCAUQ",    # nominal/alternative fallback
        ],
        agg="last",
        display_name="Real exports",
    ),
    # Terms of trade: export price index / import price index
    # FRED: AUSXGSRSNMEIS (monthly) – no dedicated quarterly series on FRED,
    # so we use a monthly proxy and convert to quarterly.
    "tot_index": SeriesConfig(
        candidates=[
            "AUSXGSRSNMEIS",   # Australia goods & services terms-of-trade monthly index (OECD)
            "XTEXVA01AUQ659S", # quarterly export value index as a rough proxy
        ],
        agg="mean",
        display_name="Terms of trade",
    ),
}


def get_output_dir() -> Path:
    custom_dir = os.getenv("PROJECT_OUTPUT_DIR")
    candidates: List[Path] = []
    if custom_dir:
        candidates.append(Path(custom_dir).expanduser())
    candidates.append(Path.home() / "Downloads" / PROJECT_FOLDER_NAME)
    candidates.append(Path.cwd() / PROJECT_FOLDER_NAME)

    for candidate in candidates:
        try:
            candidate.mkdir(parents=True, exist_ok=True)
            return candidate
        except OSError:
            continue

    raise OSError("Could not create output directory.")


def copy_script_to_output(output_dir: Path) -> None:
    try:
        script_path = Path(__file__).resolve()
        destination = output_dir / script_path.name
        if script_path != destination:
            shutil.copy2(script_path, destination)
    except Exception:
        pass


def save_dataframe(df: pd.DataFrame, output_dir: Path, filename: str) -> None:
    df.to_csv(output_dir / filename)


def save_text(text: str, output_dir: Path, filename: str) -> None:
    (output_dir / filename).write_text(text, encoding="utf-8")


def fetch_with_fredapi(series_id: str, start: str, end: str, api_key: str | None) -> pd.Series:
    from fredapi import Fred

    fred = Fred(api_key=api_key) if api_key else Fred()
    series = fred.get_series(series_id, observation_start=start, observation_end=end)
    if series is None or len(series) == 0:
        raise ValueError(f"{series_id} returned no data via fredapi.")
    series = pd.to_numeric(series, errors="coerce").dropna()
    series.index = pd.to_datetime(series.index)
    series.name = series_id
    return series.sort_index()


def fetch_with_datareader(series_id: str, start: str, end: str) -> pd.Series:
    from pandas_datareader import data as web

    df = web.DataReader(series_id, "fred", start, end)
    if df is None or df.empty:
        raise ValueError(f"{series_id} returned no data via pandas_datareader.")
    series = pd.to_numeric(df.iloc[:, 0], errors="coerce").dropna()
    series.index = pd.to_datetime(series.index)
    series.name = series_id
    return series.sort_index()


def fetch_series_with_fallback(config: SeriesConfig, start: str, end: str, api_key: str | None) -> Tuple[pd.Series, str, str]:
    errors: List[str] = []

    for series_id in config.candidates:
        for backend in ("fredapi", "pandas_datareader"):
            try:
                if backend == "fredapi":
                    series = fetch_with_fredapi(series_id, start, end, api_key)
                else:
                    series = fetch_with_datareader(series_id, start, end)
                if not series.empty:
                    return series, series_id, backend
            except Exception as exc:
                errors.append(f"{series_id} via {backend}: {exc}")

    raise RuntimeError(
        f"Failed to download {config.display_name}. Tried:\n" + "\n".join(errors)
    )


def to_quarterly(series: pd.Series, agg: str = "mean") -> pd.Series:
    s = pd.to_numeric(series, errors="coerce").dropna().copy()
    s.index = pd.to_datetime(s.index)
    s = s.sort_index()

    if len(s) < 2:
        out = s.copy()
        out.index = out.index.to_period("Q").to_timestamp(how="end")
        return out

    diffs = s.index.to_series().diff().dropna().dt.days
    median_gap = float(diffs.median()) if not diffs.empty else 90.0

    grouped = s.groupby(s.index.to_period("Q"))

    if median_gap <= 45:
        if agg == "mean":
            q = grouped.mean()
        elif agg == "last":
            q = grouped.last()
        else:
            raise ValueError("agg must be 'mean' or 'last'.")
        counts = grouped.count()
        q = q[counts >= 3]
    else:
        q = grouped.last()

    q.index = q.index.to_timestamp(how="end")
    q.name = series.name
    return q.sort_index()


def prepare_dataset(start: str, end: str, api_key: str | None) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    quarterly_series: Dict[str, pd.Series] = {}
    metadata_rows: List[Dict[str, str]] = []

    print("=" * 80)
    print("DOWNLOADING DATA")
    print("=" * 80)

    for var_name, config in SERIES_CONFIG.items():
        raw_series, series_id, backend = fetch_series_with_fallback(config, start, end, api_key)
        q_series = to_quarterly(raw_series, agg=config.agg).rename(var_name)
        quarterly_series[var_name] = q_series

        metadata_rows.append(
            {
                "Variable": var_name,
                "Display Name": config.display_name,
                "Series ID Used": series_id,
                "Backend": backend,
                "Start": str(q_series.index.min().date()),
                "End": str(q_series.index.max().date()),
                "Observations": str(len(q_series)),
            }
        )

        print(
            f"{config.display_name:<25} | using {series_id:<18} | {backend:<18} | "
            f"{str(q_series.index.min().date())} to {str(q_series.index.max().date())} | n={len(q_series)}"
        )

    metadata_df = pd.DataFrame(metadata_rows).set_index("Variable")

    levels = pd.concat(quarterly_series.values(), axis=1)
    levels = levels.loc[(levels.index >= pd.Timestamp(start)) & (levels.index <= pd.Timestamp(end))].copy()

    # Exact common support on levels
    levels = levels.dropna().copy()

    transformed = pd.DataFrame(index=levels.index)
    transformed["gdp_growth"] = levels["gdp_level"].pct_change(4, fill_method=None) * 100
    transformed["inflation"] = levels["cpi_index"].pct_change(4, fill_method=None) * 100
    transformed["export_growth"] = levels["export_level"].pct_change(4, fill_method=None) * 100
    transformed["interest_rate"] = levels["interest_rate"]

    # --- Terms-of-trade YoY growth (robustness regressor 1) ---
    transformed["tot_growth"] = levels["tot_index"].pct_change(4, fill_method=None) * 100

    # --- First-difference of interest rate (robustness regressor 2) ---
    # delta_interest_rate_t = interest_rate_t - interest_rate_{t-1}
    transformed["delta_interest_rate"] = levels["interest_rate"].diff(1)

    # Lags
    transformed["gdp_growth_l1"] = transformed["gdp_growth"].shift(1)
    transformed["gdp_growth_l2"] = transformed["gdp_growth"].shift(2)
    transformed["export_growth_l1"] = transformed["export_growth"].shift(1)
    transformed["interest_rate_l1"] = transformed["interest_rate"].shift(1)
    transformed["inflation_l1"] = transformed["inflation"].shift(1)
    # Robustness lags
    transformed["tot_growth_l1"] = transformed["tot_growth"].shift(1)
    transformed["delta_interest_rate_l1"] = transformed["delta_interest_rate"].shift(1)

    # Pandemic pulse dummies
    transformed["covid_pulse_2020q2"] = (transformed.index == pd.Timestamp("2020-06-30 23:59:59.999999999")).astype(int)
    transformed["covid_pulse_2020q3"] = (transformed.index == pd.Timestamp("2020-09-30 23:59:59.999999999")).astype(int)

    # Some quarterly conversions end at exact quarter-end 23:59:59.999999999; make fallback explicit
    if transformed["covid_pulse_2020q2"].sum() == 0:
        transformed["covid_pulse_2020q2"] = transformed.index.to_period("Q").astype(str).eq("2020Q2").astype(int)
    if transformed["covid_pulse_2020q3"].sum() == 0:
        transformed["covid_pulse_2020q3"] = transformed.index.to_period("Q").astype(str).eq("2020Q3").astype(int)

    transformed = transformed.dropna().copy()
    model_df = transformed.copy()

    if len(model_df) <= FORECAST_HORIZON + 8:
        raise ValueError(
            "Final cleaned dataset is too short for a 40-quarter recursive forecast exercise."
        )

    return transformed, model_df, metadata_df


def descriptive_analysis(df: pd.DataFrame, output_dir: Path) -> Tuple[pd.DataFrame, pd.DataFrame]:
    print("\n" + "=" * 80)
    print("TASK 1: DESCRIPTIVE ANALYSIS")
    print("=" * 80)

    vars_to_show = ["gdp_growth", "inflation", "interest_rate", "export_growth"]
    desc = df[vars_to_show].describe().T
    print("\nDescriptive statistics:\n")
    print(desc.to_string(float_format=lambda x: f"{x:0.4f}"))

    fig, axes = plt.subplots(2, 2, figsize=(14, 9), sharex=True)
    titles = [
        ("gdp_growth", "YoY Real GDP Growth (%)"),
        ("inflation", "YoY Inflation (%)"),
        ("interest_rate", "Short-Term Interest Rate (%)"),
        ("export_growth", "YoY Real Export Growth (%)"),
    ]

    for ax, (var, title) in zip(axes.flatten(), titles):
        ax.plot(df.index, df[var])
        ax.set_title(title)
        ax.axhline(0, linewidth=0.8, linestyle="--")
        ax.grid(True, alpha=0.3)

    fig.suptitle("Australia: Transformed Quarterly Series", fontsize=14)
    fig.tight_layout(rect=[0, 0.03, 1, 0.97])
    fig.savefig(output_dir / "descriptive_series.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    adf_rows = []
    print("\nADF test p-values:\n")
    for var in vars_to_show:
        adf_res = adfuller(df[var].dropna(), autolag="AIC")
        adf_rows.append(
            {
                "Variable": var,
                "ADF Statistic": adf_res[0],
                "p-value": adf_res[1],
                "Used Lags": adf_res[2],
                "Nobs": adf_res[3],
            }
        )
    adf_table = pd.DataFrame(adf_rows).set_index("Variable")
    print(adf_table.to_string(float_format=lambda x: f"{x:0.4f}"))

    save_dataframe(desc, output_dir, "descriptive_statistics.csv")
    save_dataframe(adf_table, output_dir, "adf_results.csv")
    return desc, adf_table


def fit_hac(model, maxlags: int = HAC_LAGS):
    return model.get_robustcov_results(cov_type="HAC", maxlags=maxlags)


def model_results_to_df(model) -> pd.DataFrame:
    return pd.DataFrame(
        {
            "coefficient": model.params,
            "std_error": model.bse,
            "t_stat": model.tvalues,
            "p_value": model.pvalues,
        }
    )


def estimate_models(df: pd.DataFrame, output_dir: Path):
    print("\n" + "=" * 80)
    print("TASK 2: MODEL SPECIFICATION")
    print("=" * 80)

    formula_a = "gdp_growth ~ gdp_growth_l1 + export_growth_l1 + interest_rate + inflation"
    formula_adl1 = "gdp_growth ~ gdp_growth_l1 + export_growth_l1 + interest_rate_l1 + inflation_l1"
    formula_adl2 = "gdp_growth ~ gdp_growth_l1 + gdp_growth_l2 + export_growth_l1 + interest_rate_l1 + inflation_l1"
    formula_adl1_crisis = formula_adl1 + " + covid_pulse_2020q2 + covid_pulse_2020q3"
    formula_adl2_crisis = formula_adl2 + " + covid_pulse_2020q2 + covid_pulse_2020q3"
    # Robustness 1: replace export_growth with tot_growth
    formula_adl_tot = "gdp_growth ~ gdp_growth_l1 + tot_growth_l1 + interest_rate_l1 + inflation_l1"
    # Robustness 2: replace interest_rate level with delta_interest_rate
    formula_adl_delta_rate = "gdp_growth ~ gdp_growth_l1 + export_growth_l1 + delta_interest_rate_l1 + inflation_l1"

    model_a = smf.ols(formula=formula_a, data=df).fit()
    adl1 = smf.ols(formula=formula_adl1, data=df).fit()
    adl1_hac = fit_hac(adl1)
    adl1_crisis = smf.ols(formula=formula_adl1_crisis, data=df).fit()

    adl2 = smf.ols(formula=formula_adl2, data=df).fit()
    adl2_hac = fit_hac(adl2)
    adl2_crisis = smf.ols(formula=formula_adl2_crisis, data=df).fit()

    # --- Robustness 1: Terms-of-trade ---
    adl_tot = smf.ols(formula=formula_adl_tot, data=df).fit()
    adl_tot_hac = fit_hac(adl_tot)

    # --- Robustness 2: Delta interest rate ---
    adl_delta_rate = smf.ols(formula=formula_adl_delta_rate, data=df).fit()
    adl_delta_rate_hac = fit_hac(adl_delta_rate)

    comparison = pd.DataFrame(
        {
            "Model": [
                "Model A (contemporaneous rate and inflation)",
                "Preferred ADL(1)",
                "ADL(2) candidate",
            ],
            "AIC": [model_a.aic, adl1.aic, adl2.aic],
            "BIC": [model_a.bic, adl1.bic, adl2.bic],
            "Adj. R-squared": [model_a.rsquared_adj, adl1.rsquared_adj, adl2.rsquared_adj],
        }
    )

    # Separate table for alternative-regressor robustness models
    alt_reg_comparison = pd.DataFrame(
        {
            "Model": [
                "Preferred ADL(1) – exports",
                "Robustness ADL(1) – ToT",
                "Robustness ADL(1) – delta rate",
            ],
            "AIC": [adl1.aic, adl_tot.aic, adl_delta_rate.aic],
            "BIC": [adl1.bic, adl_tot.bic, adl_delta_rate.bic],
            "Adj. R-squared": [adl1.rsquared_adj, adl_tot.rsquared_adj, adl_delta_rate.rsquared_adj],
        }
    )

    print("\nModel comparison:\n")
    print(comparison.to_string(index=False, float_format=lambda x: f"{x:0.4f}"))

    print("\nAlternative-regressor robustness model comparison:\n")
    print(alt_reg_comparison.to_string(index=False, float_format=lambda x: f"{x:0.4f}"))

    print("\nMODEL A SUMMARY\n")
    print(model_a.summary())
    print("\nPREFERRED ADL(1) SUMMARY\n")
    print(adl1.summary())
    print("\nPREFERRED ADL(1) WITH HAC(NEWEY-WEST) STANDARD ERRORS\n")
    print(adl1_hac.summary())
    print("\nROBUSTNESS ADL(1) WITH PANDEMIC PULSE DUMMIES\n")
    print(adl1_crisis.summary())
    print("\nADL(2) CANDIDATE (SECOND GDP LAG ADDED TO EXPORT ADL) SUMMARY\n")
    print(adl2.summary())
    print("\nADL(2) WITH HAC(NEWEY-WEST) STANDARD ERRORS\n")
    print(adl2_hac.summary())
    print("\nROBUSTNESS ADL(2) WITH PANDEMIC PULSE DUMMIES\n")
    print(adl2_crisis.summary())
    print("\nROBUSTNESS ADL(1) – TERMS-OF-TRADE ALTERNATIVE SUMMARY\n")
    print(adl_tot.summary())
    print("\nROBUSTNESS ADL(1) – TERMS-OF-TRADE WITH HAC(NEWEY-WEST) STANDARD ERRORS\n")
    print(adl_tot_hac.summary())
    print("\nROBUSTNESS ADL(1) – DELTA INTEREST RATE ALTERNATIVE SUMMARY\n")
    print(adl_delta_rate.summary())
    print("\nROBUSTNESS ADL(1) – DELTA INTEREST RATE WITH HAC(NEWEY-WEST) STANDARD ERRORS\n")
    print(adl_delta_rate_hac.summary())

    save_dataframe(comparison.set_index("Model"), output_dir, "model_comparison.csv")
    save_dataframe(alt_reg_comparison.set_index("Model"), output_dir, "alternative_regressor_model_comparison.csv")
    save_dataframe(model_results_to_df(adl1), output_dir, "preferred_adl_coefficients_ols.csv")
    save_dataframe(model_results_to_df(adl1_hac), output_dir, "preferred_adl_coefficients_hac.csv")
    save_dataframe(model_results_to_df(adl1_crisis), output_dir, "adl_crisis_dummy_coefficients.csv")
    save_dataframe(model_results_to_df(adl2), output_dir, "adl2_coefficients_ols.csv")
    save_dataframe(model_results_to_df(adl2_hac), output_dir, "adl2_coefficients_hac.csv")
    save_dataframe(model_results_to_df(adl2_crisis), output_dir, "adl2_crisis_dummy_coefficients.csv")
    # Robustness coefficient tables
    save_dataframe(model_results_to_df(adl_tot), output_dir, "adl_tot_coefficients_ols.csv")
    save_dataframe(model_results_to_df(adl_tot_hac), output_dir, "adl_tot_coefficients_hac.csv")
    save_dataframe(model_results_to_df(adl_delta_rate), output_dir, "adl_delta_rate_coefficients_ols.csv")
    save_dataframe(model_results_to_df(adl_delta_rate_hac), output_dir, "adl_delta_rate_coefficients_hac.csv")

    summary_text = (
        "MODEL A SUMMARY\n\n"
        + model_a.summary().as_text()
        + "\n\nPREFERRED ADL(1) (LAGGED EXPORT GROWTH, LAGGED INTEREST, LAGGED INFLATION) SUMMARY\n\n"
        + adl1.summary().as_text()
        + "\n\nPREFERRED ADL(1) WITH HAC(NEWEY-WEST) STANDARD ERRORS\n\n"
        + adl1_hac.summary().as_text()
        + "\n\nROBUSTNESS ADL(1) WITH PANDEMIC PULSE DUMMIES\n\n"
        + adl1_crisis.summary().as_text()
        + "\n\nADL(2) CANDIDATE (SECOND GDP LAG ADDED TO EXPORT ADL) SUMMARY\n\n"
        + adl2.summary().as_text()
        + "\n\nADL(2) WITH HAC(NEWEY-WEST) STANDARD ERRORS\n\n"
        + adl2_hac.summary().as_text()
        + "\n\nROBUSTNESS ADL(2) WITH PANDEMIC PULSE DUMMIES\n\n"
        + adl2_crisis.summary().as_text()
        + "\n\nROBUSTNESS ADL(1) – TERMS-OF-TRADE ALTERNATIVE\n\n"
        + adl_tot.summary().as_text()
        + "\n\nROBUSTNESS ADL(1) – TERMS-OF-TRADE WITH HAC(NEWEY-WEST) STANDARD ERRORS\n\n"
        + adl_tot_hac.summary().as_text()
        + "\n\nROBUSTNESS ADL(1) – DELTA INTEREST RATE ALTERNATIVE\n\n"
        + adl_delta_rate.summary().as_text()
        + "\n\nROBUSTNESS ADL(1) – DELTA INTEREST RATE WITH HAC(NEWEY-WEST) STANDARD ERRORS\n\n"
        + adl_delta_rate_hac.summary().as_text()
    )
    save_text(summary_text, output_dir, "adl_model_summaries.txt")

    return {
        "formula_a": formula_a,
        "formula_adl1": formula_adl1,
        "formula_adl2": formula_adl2,
        "formula_adl1_crisis": formula_adl1_crisis,
        "formula_adl2_crisis": formula_adl2_crisis,
        "formula_adl_tot": formula_adl_tot,
        "formula_adl_delta_rate": formula_adl_delta_rate,
        "model_a": model_a,
        "adl1": adl1,
        "adl1_hac": adl1_hac,
        "adl1_crisis": adl1_crisis,
        "adl2": adl2,
        "adl2_hac": adl2_hac,
        "adl2_crisis": adl2_crisis,
        "adl_tot": adl_tot,
        "adl_tot_hac": adl_tot_hac,
        "adl_delta_rate": adl_delta_rate,
        "adl_delta_rate_hac": adl_delta_rate_hac,
        "comparison": comparison,
        "alt_reg_comparison": alt_reg_comparison,
    }


def run_diagnostics(model, output_dir: Path, filename: str = "diagnostic_tests.csv") -> pd.DataFrame:
    print("\n" + "=" * 80)
    print(f"DIAGNOSTIC TESTS FOR {filename}")
    print("=" * 80)

    bg_lm_stat, bg_lm_pvalue, bg_f_stat, bg_f_pvalue = acorr_breusch_godfrey(model, nlags=4)
    white_lm_stat, white_lm_pvalue, white_f_stat, white_f_pvalue = het_white(model.resid, model.model.exog)
    jb_stat, jb_pvalue, _, _ = jarque_bera(model.resid)

    diagnostics = pd.DataFrame(
        {
            "Test": [
                "Breusch-Godfrey LM (4 lags)",
                "Breusch-Godfrey F (4 lags)",
                "White LM",
                "White F",
                "Jarque-Bera",
            ],
            "Statistic": [bg_lm_stat, bg_f_stat, white_lm_stat, white_f_stat, jb_stat],
            "p-value": [bg_lm_pvalue, bg_f_pvalue, white_lm_pvalue, white_f_pvalue, jb_pvalue],
        }
    )

    print("\nKey diagnostic p-values:\n")
    key_rows = diagnostics.loc[
        diagnostics["Test"].isin(["Breusch-Godfrey LM (4 lags)", "White LM", "Jarque-Bera"])
    ]
    print(key_rows[["Test", "p-value"]].to_string(index=False, float_format=lambda x: f"{x:0.4f}"))

    save_dataframe(diagnostics.set_index("Test"), output_dir, filename)
    return diagnostics


def wald_interest_rate_test(model, output_dir: Path) -> pd.DataFrame:
    print("\n" + "=" * 80)
    print("TASK 4: WALD TEST ON INTEREST RATE")
    print("=" * 80)

    interest_terms = [name for name in model.params.index if str(name).startswith("interest_rate")]
    if not interest_terms:
        raise ValueError("No interest-rate terms found.")

    restriction = " + ".join(interest_terms) + " = 0"
    wald_res = model.wald_test(restriction)

    pvalue = float(np.asarray(wald_res.pvalue))
    statistic = float(np.asarray(wald_res.statistic))

    if pvalue < 0.05:
        conclusion = "Reject the null: interest-rate terms are jointly relevant."
    else:
        conclusion = "Fail to reject the null: interest-rate terms are not jointly relevant."

    print(f"Restriction: {restriction}")
    print(f"Wald statistic: {statistic:0.4f}")
    print(f"p-value: {pvalue:0.4f}")
    print(conclusion)

    out = pd.DataFrame(
        {
            "restriction": [restriction],
            "wald_statistic": [statistic],
            "p_value": [pvalue],
            "conclusion": [conclusion],
        }
    )
    save_dataframe(out, output_dir, "wald_test_interest_rate.csv")
    return out


def recursive_forecast_formula(df: pd.DataFrame, formula: str, forecast_horizon: int, name: str) -> pd.Series:
    start_idx = len(df) - forecast_horizon
    preds: List[float] = []
    pred_dates = df.index[start_idx:]

    for i in range(start_idx, len(df)):
        train = df.iloc[:i].copy()
        test = df.iloc[[i]].copy()
        model = smf.ols(formula=formula, data=train).fit()
        preds.append(float(model.predict(test).iloc[0]))

    return pd.Series(preds, index=pred_dates, name=name)


def recursive_forecast_ar2(df: pd.DataFrame, forecast_horizon: int) -> pd.Series:
    formula = "gdp_growth ~ gdp_growth_l1 + gdp_growth_l2"
    return recursive_forecast_formula(df, formula, forecast_horizon, "AR(2) Forecast")


def recursive_forecast_var2(df: pd.DataFrame, forecast_horizon: int) -> pd.Series:
    var_df = df[["gdp_growth", "inflation", "interest_rate"]].copy()
    start_idx = len(var_df) - forecast_horizon
    preds: List[float] = []
    pred_dates = var_df.index[start_idx:]

    for i in range(start_idx, len(var_df)):
        train = var_df.iloc[:i].copy()
        model = VAR(train)
        fitted = model.fit(2)
        forecast_array = fitted.forecast(train.values[-fitted.k_ar:], steps=1)
        preds.append(float(forecast_array[0, 0]))

    return pd.Series(preds, index=pred_dates, name="VAR(2) Forecast")


def forecast_error_metrics(actual: pd.Series, predicted: pd.Series) -> Dict[str, float]:
    aligned = pd.concat([actual, predicted], axis=1).dropna()
    errors = aligned.iloc[:, 0] - aligned.iloc[:, 1]
    mae = float(np.mean(np.abs(errors)))
    msfe = float(np.mean(errors**2))
    rmse = float(np.sqrt(msfe))
    return {
        "MAE": mae,
        "MAFE": mae,
        "MSFE": msfe,
        "RMSE": rmse,
        "RMSFE": rmse,
    }


def _autocovariance(x: np.ndarray, lag: int) -> float:
    x = np.asarray(x, dtype=float)
    x_mean = x.mean()
    n = len(x)
    return np.sum((x[lag:] - x_mean) * (x[:n - lag] - x_mean)) / n


def diebold_mariano_test(
    actual: pd.Series,
    pred1: pd.Series,
    pred2: pd.Series,
    loss: str = "SE",
    h: int = 1,
    model1_name: str = "Model 1",
    model2_name: str = "Model 2",
) -> Dict[str, object]:
    aligned = pd.concat([actual, pred1, pred2], axis=1).dropna()
    aligned.columns = ["actual", "pred1", "pred2"]

    e1 = aligned["actual"] - aligned["pred1"]
    e2 = aligned["actual"] - aligned["pred2"]

    loss = loss.upper()
    if loss == "SE":
        d = (e1**2) - (e2**2)
    elif loss == "AE":
        d = np.abs(e1) - np.abs(e2)
    else:
        raise ValueError("loss must be 'SE' or 'AE'.")

    d = np.asarray(d, dtype=float)
    T = len(d)
    if T <= h:
        raise ValueError("Not enough observations for the requested forecast horizon in DM test.")

    gamma0 = _autocovariance(d, 0)
    var_d = gamma0
    if h > 1:
        for lag in range(1, h):
            weight = 1.0 - lag / h
            var_d += 2.0 * weight * _autocovariance(d, lag)

    if var_d <= 0:
        dm_stat = np.nan
        p_value = np.nan
        winner = "Undetermined"
    else:
        dm_stat = d.mean() / np.sqrt(var_d / T)
        # Harvey-Leybourne-Newbold small-sample correction
        hln_factor = np.sqrt((T + 1 - 2 * h + (h * (h - 1)) / T) / T)
        dm_stat = dm_stat * hln_factor
        p_value = 2.0 * (1.0 - stats.t.cdf(np.abs(dm_stat), df=T - 1))

        if np.isnan(p_value):
            winner = "Undetermined"
        elif p_value < 0.05 and d.mean() < 0:
            winner = model1_name
        elif p_value < 0.05 and d.mean() > 0:
            winner = model2_name
        else:
            winner = "No significant difference"

    return {
        "Model 1": model1_name,
        "Model 2": model2_name,
        "Loss": loss,
        "Observations": T,
        "Mean loss differential (L1-L2)": float(d.mean()),
        "DM statistic": float(dm_stat) if not np.isnan(dm_stat) else np.nan,
        "p-value": float(p_value) if not np.isnan(p_value) else np.nan,
        "Winner at 5%": winner,
    }


def forecasting_exercise(df: pd.DataFrame, formulas: Dict[str, str], forecast_horizon: int, output_dir: Path) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    print("\n" + "=" * 80)
    print("TASKS 5 & 6: FORECASTING EXERCISE + DIEBOLD-MARIANO TESTS")
    print("=" * 80)

    actual = df["gdp_growth"].iloc[-forecast_horizon:].copy()
    actual.name = "Actual GDP Growth"

    adl1_fc = recursive_forecast_formula(df, formulas["formula_adl1"], forecast_horizon, "ADL(1) Forecast")
    adl2_fc = recursive_forecast_formula(df, formulas["formula_adl2"], forecast_horizon, "ADL(2) Forecast")
    ar2_fc = recursive_forecast_ar2(df, forecast_horizon)
    var2_fc = recursive_forecast_var2(df, forecast_horizon)

    comb_fc = pd.concat([adl1_fc, ar2_fc, var2_fc], axis=1).mean(axis=1)
    comb_fc.name = "Combined Forecast"

    # --- Robustness recursive forecasts ---
    adl_tot_fc = recursive_forecast_formula(
        df, formulas["formula_adl_tot"], forecast_horizon, "ADL(1)-ToT Forecast"
    )
    adl_delta_rate_fc = recursive_forecast_formula(
        df, formulas["formula_adl_delta_rate"], forecast_horizon, "ADL(1)-DeltaRate Forecast"
    )

    forecast_df = pd.concat(
        [actual, adl1_fc, adl2_fc, ar2_fc, var2_fc, comb_fc, adl_tot_fc, adl_delta_rate_fc],
        axis=1,
    )

    model_forecasts = {
        "ADL(1)": adl1_fc,
        "ADL(2)": adl2_fc,
        "AR(2)": ar2_fc,
        "VAR(2)": var2_fc,
        "Combined (equal-weight average)": comb_fc,
    }

    evaluation_rows = []
    for model_name, preds in model_forecasts.items():
        metrics = forecast_error_metrics(actual, preds)
        metrics["Model"] = model_name
        evaluation_rows.append(metrics)

    evaluation_table = pd.DataFrame(evaluation_rows).set_index("Model").sort_values("RMSE")

    print("\nForecast evaluation table:\n")
    print(evaluation_table.to_string(float_format=lambda x: f"{x:0.4f}"))

    # --- Alternative-regressor evaluation table ---
    alt_reg_forecasts = {
        "Preferred ADL(1) – exports": adl1_fc,
        "Robustness ADL(1) – ToT": adl_tot_fc,
        "Robustness ADL(1) – delta rate": adl_delta_rate_fc,
    }

    alt_eval_rows = []
    for model_name, preds in alt_reg_forecasts.items():
        metrics = forecast_error_metrics(actual, preds)
        metrics["Model"] = model_name
        alt_eval_rows.append(metrics)

    alt_eval_table = pd.DataFrame(alt_eval_rows).set_index("Model").sort_values("RMSE")

    print("\nAlternative-regressor forecast evaluation table:\n")
    print(alt_eval_table.to_string(float_format=lambda x: f"{x:0.4f}"))

    # Diebold-Mariano tests (squared-error loss)
    dm_rows = [
        diebold_mariano_test(actual, adl1_fc, ar2_fc, loss="SE", h=DM_HORIZON, model1_name="ADL(1)", model2_name="AR(2)"),
        diebold_mariano_test(actual, adl1_fc, var2_fc, loss="SE", h=DM_HORIZON, model1_name="ADL(1)", model2_name="VAR(2)"),
        diebold_mariano_test(actual, adl1_fc, comb_fc, loss="SE", h=DM_HORIZON, model1_name="ADL(1)", model2_name="Combined"),
        diebold_mariano_test(actual, adl1_fc, adl2_fc, loss="SE", h=DM_HORIZON, model1_name="ADL(1)", model2_name="ADL(2)"),
    ]
    dm_table = pd.DataFrame(dm_rows)

    # --- DM tests: robustness models vs preferred ADL(1) ---
    alt_dm_rows = [
        diebold_mariano_test(
            actual, adl1_fc, adl_tot_fc,
            loss="SE", h=DM_HORIZON,
            model1_name="ADL(1) preferred",
            model2_name="ADL(1)-ToT",
        ),
        diebold_mariano_test(
            actual, adl1_fc, adl_delta_rate_fc,
            loss="SE", h=DM_HORIZON,
            model1_name="ADL(1) preferred",
            model2_name="ADL(1)-DeltaRate",
        ),
    ]
    alt_dm_table = pd.DataFrame(alt_dm_rows)

    print("\nDiebold-Mariano tests (squared-error loss):\n")
    print(dm_table.to_string(index=False, float_format=lambda x: f"{x:0.4f}" if isinstance(x, float) else str(x)))

    print("\nDiebold-Mariano tests – robustness models vs preferred ADL(1):\n")
    print(alt_dm_table.to_string(index=False, float_format=lambda x: f"{x:0.4f}" if isinstance(x, float) else str(x)))

    save_dataframe(forecast_df, output_dir, "forecast_results.csv")
    save_dataframe(evaluation_table, output_dir, "forecast_evaluation_table.csv")
    save_dataframe(evaluation_table[["RMSE"]], output_dir, "forecast_rmse_table.csv")
    save_dataframe(dm_table, output_dir, "diebold_mariano_results.csv")
    # Robustness-specific outputs
    save_dataframe(alt_eval_table, output_dir, "alternative_regressor_forecast_evaluation.csv")
    save_dataframe(alt_dm_table, output_dir, "alternative_regressor_dm_results.csv")

    # Explicit ADL lag comparison file
    adl_lag_comparison = pd.DataFrame(
        {
            "Model": ["ADL(1)", "ADL(2)"],
            "AIC": [np.nan, np.nan],
            "BIC": [np.nan, np.nan],
            "RMSE": [
                evaluation_table.loc["ADL(1)", "RMSE"],
                evaluation_table.loc["ADL(2)", "RMSE"],
            ],
            "MAE": [
                evaluation_table.loc["ADL(1)", "MAE"],
                evaluation_table.loc["ADL(2)", "MAE"],
            ],
            "Decision": [
                "Preferred baseline" if evaluation_table.loc["ADL(1)", "RMSE"] <= evaluation_table.loc["ADL(2)", "RMSE"] else "Worse than ADL(2)",
                "Improves RMSE" if evaluation_table.loc["ADL(2)", "RMSE"] < evaluation_table.loc["ADL(1)", "RMSE"] else "Rejected: no RMSE gain",
            ],
        }
    )
    save_dataframe(adl_lag_comparison.set_index("Model"), output_dir, "adl_lag_comparison.csv")

    fig = plt.figure(figsize=(14, 7))
    plt.plot(forecast_df.index, forecast_df["Actual GDP Growth"], label="Actual GDP Growth")
    plt.plot(forecast_df.index, forecast_df["ADL(1) Forecast"], label="ADL(1) Forecast")
    plt.plot(forecast_df.index, forecast_df["ADL(2) Forecast"], label="ADL(2) Forecast")
    plt.plot(forecast_df.index, forecast_df["AR(2) Forecast"], label="AR(2) Forecast")
    plt.plot(forecast_df.index, forecast_df["VAR(2) Forecast"], label="VAR(2) Forecast")
    plt.plot(forecast_df.index, forecast_df["Combined Forecast"], label="Combined Forecast")
    plt.plot(forecast_df.index, forecast_df["ADL(1)-ToT Forecast"], label="ADL(1)-ToT Forecast", linestyle="--")
    plt.plot(forecast_df.index, forecast_df["ADL(1)-DeltaRate Forecast"], label="ADL(1)-DeltaRate Forecast", linestyle="--")
    plt.title("Recursive 1-Step Ahead Forecasts: Australia GDP Growth")
    plt.axhline(0, linewidth=0.8, linestyle="--")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    fig.savefig(output_dir / "forecast_comparison.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    eval_plot_df = evaluation_table.reset_index()

    ax1 = eval_plot_df.set_index("Model")[["MAE", "MSFE", "RMSE"]].plot(
        kind="bar",
        figsize=(10, 6),
    )
    ax1.set_title("Forecast Evaluation Metrics: MAE, MSFE, RMSE")
    ax1.set_xlabel("Model")
    ax1.set_ylabel("Value")
    ax1.tick_params(axis="x", rotation=0)
    ax1.legend(title="Metric")
    plt.tight_layout()
    ax1.get_figure().savefig(output_dir / "forecast_metrics_barplot_1.png", dpi=300, bbox_inches="tight")
    plt.close(ax1.get_figure())

    # Bar plot for alternative-regressor models
    ax2 = alt_eval_table.reset_index().set_index("Model")[["MAE", "MSFE", "RMSE"]].plot(
        kind="bar",
        figsize=(10, 6),
    )
    ax2.set_title("Forecast Evaluation Metrics: Alternative-Regressor Robustness")
    ax2.set_xlabel("Model")
    ax2.set_ylabel("Value")
    ax2.tick_params(axis="x", rotation=15)
    ax2.legend(title="Metric")
    plt.tight_layout()
    ax2.get_figure().savefig(output_dir / "forecast_metrics_barplot_alt_reg.png", dpi=300, bbox_inches="tight")
    plt.close(ax2.get_figure())

    return forecast_df, evaluation_table, dm_table


def latex_escape(text: str) -> str:
    repl = {
        "\\": r"\textbackslash{}",
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "{": r"\{",
        "}": r"\}",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
    }
    out = str(text)
    for k, v in repl.items():
        out = out.replace(k, v)
    return out


def make_macro(name: str, value: object) -> str:
    return f"\\newcommand{{\\{name}}}{{{latex_escape(value)}}}"


def write_latex_macros(
    transformed_df: pd.DataFrame,
    model_df: pd.DataFrame,
    models: Dict[str, object],
    evaluation_table: pd.DataFrame,
    dm_table: pd.DataFrame,
    diagnostics: pd.DataFrame,
    robustness_diagnostics: pd.DataFrame,
    wald_df: pd.DataFrame,
    output_dir: Path,
) -> None:
    # Helper to access
    adl1 = models["adl1"]
    adl1_hac = models["adl1_hac"]
    adl1_crisis = models["adl1_crisis"]
    adl2 = models["adl2"]

    ranking = " < ".join(evaluation_table.index.tolist())

    dm_map = {}
    for _, row in dm_table.iterrows():
        key = f"{row['Model 1']}_vs_{row['Model 2']}".replace("(", "").replace(")", "").replace(" ", "").replace("-", "")
        dm_map[key] = row

    lines = []

    # Sample macros
    lines.append(make_macro("TransformedSampleStart", transformed_df.index.min().to_period("Q")))
    lines.append(make_macro("TransformedSampleEnd", transformed_df.index.max().to_period("Q")))
    lines.append(make_macro("ModelSampleStart", model_df.index.min().to_period("Q")))
    lines.append(make_macro("ModelSampleEnd", model_df.index.max().to_period("Q")))
    lines.append(make_macro("ModelObs", len(model_df)))
    lines.append(make_macro("ForecastStart", model_df.index[-FORECAST_HORIZON].to_period("Q")))
    lines.append(make_macro("ForecastEnd", model_df.index[-1].to_period("Q")))
    lines.append(make_macro("ForecastObs", FORECAST_HORIZON))

    # Descriptives / ADF
    desc = transformed_df[["gdp_growth", "inflation", "interest_rate", "export_growth"]].describe().T
    adf = {}
    for var in ["gdp_growth", "inflation", "interest_rate", "export_growth"]:
        adf[var] = adfuller(transformed_df[var].dropna(), autolag="AIC")[1]

    macro_pairs = {
        "GDPMean": f"{desc.loc['gdp_growth', 'mean']:.2f}",
        "GDPStd": f"{desc.loc['gdp_growth', 'std']:.2f}",
        "GDPMin": f"{desc.loc['gdp_growth', 'min']:.2f}",
        "GDPMax": f"{desc.loc['gdp_growth', 'max']:.2f}",
        "GDPADF": f"{adf['gdp_growth']:.3f}",
        "InflationMean": f"{desc.loc['inflation', 'mean']:.2f}",
        "InflationStd": f"{desc.loc['inflation', 'std']:.2f}",
        "InflationMin": f"{desc.loc['inflation', 'min']:.2f}",
        "InflationMax": f"{desc.loc['inflation', 'max']:.2f}",
        "InflationADF": f"{adf['inflation']:.3f}",
        "RateMean": f"{desc.loc['interest_rate', 'mean']:.2f}",
        "RateStd": f"{desc.loc['interest_rate', 'std']:.2f}",
        "RateMin": f"{desc.loc['interest_rate', 'min']:.2f}",
        "RateMax": f"{desc.loc['interest_rate', 'max']:.2f}",
        "RateADF": f"{adf['interest_rate']:.3f}",
        "ExportMean": f"{desc.loc['export_growth', 'mean']:.2f}",
        "ExportStd": f"{desc.loc['export_growth', 'std']:.2f}",
        "ExportMin": f"{desc.loc['export_growth', 'min']:.2f}",
        "ExportMax": f"{desc.loc['export_growth', 'max']:.2f}",
        "ExportADF": f"{adf['export_growth']:.3f}",
        "ADLContAIC": f"{models['model_a'].aic:.2f}",
        "ADLContBIC": f"{models['model_a'].bic:.2f}",
        "ADLContAdjR": f"{models['model_a'].rsquared_adj:.3f}",
        "ADLPreferredAIC": f"{adl1.aic:.2f}",
        "ADLPreferredBIC": f"{adl1.bic:.2f}",
        "ADLPreferredAdjR": f"{adl1.rsquared_adj:.3f}",
        "Intercept": f"{adl1_hac.params[0]:.4f}",
        "InterceptSE": f"{adl1_hac.bse[0]:.4f}",
        "InterceptP": f"{adl1_hac.pvalues[0]:.3f}",
        "LagGDP": f"{adl1_hac.params[1]:.4f}",
        "LagGDPSE": f"{adl1_hac.bse[1]:.4f}",
        "LagGDPP": f"{adl1_hac.pvalues[1]:.3f}",
        "ExportCoef": f"{adl1_hac.params[2]:.4f}",
        "ExportCoefSE": f"{adl1_hac.bse[2]:.4f}",
        "ExportCoefP": f"{adl1_hac.pvalues[2]:.3f}",
        "LagRateCoef": f"{adl1_hac.params[3]:.4f}",
        "LagRateCoefSE": f"{adl1_hac.bse[3]:.4f}",
        "LagRateCoefP": f"{adl1_hac.pvalues[3]:.3f}",
        "LagInflCoef": f"{adl1_hac.params[4]:.4f}",
        "LagInflCoefSE": f"{adl1_hac.bse[4]:.4f}",
        "LagInflCoefP": f"{adl1_hac.pvalues[4]:.3f}",
        "ADL2AIC": f"{adl2.aic:.2f}",
        "ADL2BIC": f"{adl2.bic:.2f}",
        "ADL2AdjR": f"{adl2.rsquared_adj:.3f}",
        "GDP2Coef": f"{adl2.params['gdp_growth_l2']:.4f}",
        "GDP2P": f"{adl2.pvalues['gdp_growth_l2']:.3f}",
        "BGPval": f"{diagnostics.loc['Breusch-Godfrey LM (4 lags)', 'p-value']:.4f}",
        "WhitePval": f"{diagnostics.loc['White LM', 'p-value']:.4f}",
        "JBPval": f"{diagnostics.loc['Jarque-Bera', 'p-value']:.4f}",
        "ADLCrisisAIC": f"{adl1_crisis.aic:.2f}",
        "ADLCrisisAdjR": f"{adl1_crisis.rsquared_adj:.3f}",
        "RobustBGPval": f"{robustness_diagnostics.loc['Breusch-Godfrey LM (4 lags)', 'p-value']:.4f}",
        "WaldStat": f"{wald_df.loc[0, 'wald_statistic']:.3f}",
        "WaldPval": f"{wald_df.loc[0, 'p_value']:.3f}",
        "WaldInference": str(wald_df.loc[0, 'conclusion']),
        "ADLMAE": f"{evaluation_table.loc['ADL(1)', 'MAE']:.3f}",
        "ADLMSFE": f"{evaluation_table.loc['ADL(1)', 'MSFE']:.3f}",
        "ADLRMSE": f"{evaluation_table.loc['ADL(1)', 'RMSE']:.3f}",
        "ADL2MAE": f"{evaluation_table.loc['ADL(2)', 'MAE']:.3f}",
        "ADL2MSFE": f"{evaluation_table.loc['ADL(2)', 'MSFE']:.3f}",
        "ADL2RMSE": f"{evaluation_table.loc['ADL(2)', 'RMSE']:.3f}",
        "ARMAE": f"{evaluation_table.loc['AR(2)', 'MAE']:.3f}",
        "ARMSFE": f"{evaluation_table.loc['AR(2)', 'MSFE']:.3f}",
        "ARRMSE": f"{evaluation_table.loc['AR(2)', 'RMSE']:.3f}",
        "VARMAE": f"{evaluation_table.loc['VAR(2)', 'MAE']:.3f}",
        "VARMSFE": f"{evaluation_table.loc['VAR(2)', 'MSFE']:.3f}",
        "VARRMSE": f"{evaluation_table.loc['VAR(2)', 'RMSE']:.3f}",
        "CombMAE": f"{evaluation_table.loc['Combined (equal-weight average)', 'MAE']:.3f}",
        "CombMSFE": f"{evaluation_table.loc['Combined (equal-weight average)', 'MSFE']:.3f}",
        "CombRMSE": f"{evaluation_table.loc['Combined (equal-weight average)', 'RMSE']:.3f}",
        "ForecastRanking": ranking,
    }

    # DM macros
    for pretty_name, key_stub in [
        ("DMADLvsAR", "ADL1_vs_AR2"),
        ("DMADLvsVAR", "ADL1_vs_VAR2"),
        ("DMADLvsComb", "ADL1_vs_Combined"),
        ("DMADLvsADLtwo", "ADL1_vs_ADL2"),
    ]:
        if key_stub in dm_map:
            row = dm_map[key_stub]
            macro_pairs[f"{pretty_name}Stat"] = f"{row['DM statistic']:.3f}"
            macro_pairs[f"{pretty_name}P"] = f"{row['p-value']:.3f}"
            macro_pairs[f"{pretty_name}Winner"] = str(row["Winner at 5%"])

    for key, value in macro_pairs.items():
        lines.append(make_macro(key, value))

    save_text("\n".join(lines) + "\n", output_dir, "latex_results_macros.tex")


def write_readme(output_dir: Path) -> None:
    readme = f"""Australia econometrics project with Diebold-Mariano tests
=========================================================

Main script:
- australia_gdp_project_dm.py

Main outputs:
- series_metadata.csv
- descriptive_statistics.csv
- adf_results.csv
- descriptive_series.png
- model_comparison.csv
- preferred_adl_coefficients_ols.csv
- preferred_adl_coefficients_hac.csv
- adl_crisis_dummy_coefficients.csv
- adl2_coefficients_ols.csv
- adl2_coefficients_hac.csv
- adl2_crisis_dummy_coefficients.csv
- adl_tot_coefficients_ols.csv
- adl_tot_coefficients_hac.csv
- adl_delta_rate_coefficients_ols.csv
- adl_delta_rate_coefficients_hac.csv
- alternative_regressor_model_comparison.csv
- alternative_regressor_forecast_evaluation.csv
- alternative_regressor_dm_results.csv
- adl_model_summaries.txt
- diagnostic_tests.csv
- robustness_diagnostic_tests.csv
- wald_test_interest_rate.csv
- forecast_results.csv
- forecast_evaluation_table.csv
- forecast_rmse_table.csv
- forecast_comparison.png
- forecast_metrics_barplot_1.png
- forecast_metrics_barplot_alt_reg.png
- adl_lag_comparison.csv
- diebold_mariano_results.csv
- latex_results_macros.tex

Run:
1. pip install pandas numpy matplotlib statsmodels scipy fredapi pandas-datareader
2. export FRED_API_KEY="YOUR_KEY"
3. python australia_gdp_project_dm.py

Output folder:
- {output_dir}
"""
    save_text(readme, output_dir, "README.txt")


def main() -> None:
    output_dir = get_output_dir()
    copy_script_to_output(output_dir)
    write_readme(output_dir)

    print("\n" + "=" * 80)
    print("OUTPUT FOLDER")
    print("=" * 80)
    print(output_dir)

    transformed_df, model_df, metadata_df = prepare_dataset(START_DATE, END_DATE, FRED_API_KEY)

    print("\n" + "=" * 80)
    print("SERIES USED")
    print("=" * 80)
    print(metadata_df.to_string())
    save_dataframe(metadata_df, output_dir, "series_metadata.csv")

    descriptive_analysis(transformed_df, output_dir)
    models = estimate_models(model_df, output_dir)
    diagnostics = run_diagnostics(models["adl1"], output_dir, filename="diagnostic_tests.csv")
    robustness_diagnostics = run_diagnostics(models["adl1_crisis"], output_dir, filename="robustness_diagnostic_tests.csv")
    wald_df = wald_interest_rate_test(models["adl1"], output_dir)
    forecast_df, evaluation_table, dm_table = forecasting_exercise(model_df, models, FORECAST_HORIZON, output_dir)

    write_latex_macros(
        transformed_df=transformed_df,
        model_df=model_df,
        models=models,
        evaluation_table=evaluation_table,
        dm_table=dm_table,
        diagnostics=diagnostics.set_index("Test"),
        robustness_diagnostics=robustness_diagnostics.set_index("Test"),
        wald_df=wald_df,
        output_dir=output_dir,
    )

    print("\nDone. Key files saved in:")
    print(output_dir)


if __name__ == "__main__":
    main()
