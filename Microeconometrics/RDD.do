clear all
cls

display "`c(username)'"

if "`c(username)'" == "MAFFINA_P" {
    global path "/Users/MAFFINA_P/Desktop/Uni/ESS/II Sem./Microeconometrics/PS3/stata_files"
    global outputpath "/Users/MAFFINA_P/Desktop/Uni/ESS/II Sem./Microeconometrics/PS3/stata_files"
}

else if "c(username)'" == "chiaranespoli" { 
	global path "/Users/chiaranespoli/Desktop" 
	global outputpath "/Users/chiaranespoli/Desktop/outputs_ex1" 
}

else if "`c(username)'" == "Ivan" {
    global path "C:/Users/Ivan/Desktop/Study/Microeconometrics/Assignment/files3"
    global outputpath "C:/Users/Ivan/Desktop/Study/Microeconometrics/Assignment/files3/outputs_ex3"
}
else if "`c(username)'" == "TA_Username" {
    global path "C:/Users/TA/Desktop/Grading/PS1/"
    global outputpath "C:/Users/TA/Desktop/Grading/PS1/Output/"
}

cd "$path"

cls

capture mkdir "outputs_ex1"
* Set the working directory to the main path
cd "$path"

cls

* Create output folder
capture mkdir "outputs_ex1"

* Define main variables
local X X
local Y Y
local T T
local cutoff 0

**# Q1
**## a)

use pset_3


rdplot `T' `X', c(`cutoff') p(1) ///
    graph_options( ///
        title("First Stage: Treatment at the Cutoff") ///
        ytitle("Treatment Variable") ///
        xtitle("Running variable") ///
        legend(off) ///
        name(graph_1a, replace) ///
    )

graph export "outputs_ex1/pset_3_exercise_1_question_1_a.png", replace

* The graph shows a clear discontinuity in the treatment variable at the cutoff X = 0.
* For municipalities where the Islamic vote margin is below zero, the Islamic party loses
* the election and the treatment variable T equals 0. For municipalities where the Islamic
* vote margin is above zero, the Islamic party wins the election and T equals 1.


**##b)

capture mkdir "outputs_ex1"

local X X
local cutoff 0

local covariates hischshr1520m i89 vshr_islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk

tempfile table1

postfile handle ///
    str80 Label ///
    double MSE_Optimal_Bandwidth ///
    double RD_Estimator ///
    double P_Value ///
    double Effective_Number_of_Observations ///
    using "`table1'", replace

foreach var of local covariates {

    display "Now running rdrobust for variable: `var'"

    capture noisily rdrobust `var' `X', ///
        c(`cutoff') ///
        p(1) ///
        kernel(triangular) ///
        bwselect(mserd)

    if _rc != 0 {
        display as error "rdrobust failed for variable: `var'"
        continue
    }

    local lab : variable label `var'
    if "`lab'" == "" local lab "`var'"

    local effN = e(N_h_l) + e(N_h_r)

    post handle ///
        ("`lab'") ///
        (e(h_l)) ///
        (e(tau_cl)) ///
        (e(pv_cl)) ///
        (`effN')
}

postclose handle

preserve

use "`table1'", clear

format MSE_Optimal_Bandwidth RD_Estimator P_Value %9.4f
format Effective_Number_of_Observations %9.0f

list, clean noobs

export excel using "outputs_ex1/Table_1.xlsx", firstrow(variables) replace

restore

* Exercise 1(b) interpretation:
* Table 1 reports RD estimates for baseline variables at the cutoff X = 0.
* The purpose of this exercise is to check covariate balance around the cutoff.
* In an RD design, units just below and just above the cutoff should be comparable,
* except for treatment assignment. Therefore, predetermined variables should not
* display significant discontinuities at the cutoff.
*
* In this table, all p-values are above 0.05:
* - Share Men aged 15-20 with High School Education: p = 0.265
* - Islamic Mayor in 1989: p = 0.424
* - Islamic vote share 1994: p = 0.683
* - Number of parties receiving votes 1994: p = 0.726
* - Log Population in 1994: p = 0.964
* - District center: p = 0.449
* - Province center: p = 0.431
* - Sub-metro center: p = 0.682
* - Metro center: p = 0.754
*
* Since none of the baseline variables shows a statistically significant jump
* at the cutoff, we fail to reject continuity of these covariates.
* This supports the validity of the RD design because it suggests that municipalities
* barely won or barely lost by the Islamic party were similar in observable baseline
* characteristics.
*
* However, this does not prove the RD identification assumption. It only provides
* supporting evidence, since we cannot directly test continuity of unobserved
* potential outcomes.

**## c)

* Running variable
local X X
local cutoff 0

* 9 baseline covariates
local covariates hischshr1520m i89 vshr_islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk

* Remove old graphs from memory if they exist
capture graph drop covplot1
capture graph drop covplot2
capture graph drop covplot3
capture graph drop covplot4
capture graph drop covplot5
capture graph drop covplot6
capture graph drop covplot7
capture graph drop covplot8
capture graph drop covplot9
capture graph drop Graph_1

local graphlist
local i = 1

foreach var of local covariates {

    local lab : variable label `var'
    if "`lab'" == "" local lab "`var'"

    rdplot `var' `X', c(`cutoff') p(1) ///
        graph_options( ///
            title("`lab'", size(vsmall)) ///
            ytitle("") ///
            xtitle("Running variable", size(vsmall)) ///
            legend(off) ///
            name(covplot`i', replace) ///
        )

    local graphlist `graphlist' covplot`i'

    local ++i
}

graph combine `graphlist', cols(3) iscale(0.5) ///
    title("Graph 1. RD Plots for Baseline Variables") ///
    name(Graph_1, replace)

graph export "outputs_ex1/Graph_1.png", replace
graph save "outputs_ex1/Graph_1.gph", replace

**## d)

* Drop previous graphs if they exist
capture graph drop hist_X
capture graph drop dens_X
capture graph drop Graph_2

* Histogram of X below and above the cutoff

twoway ///
    (hist X if X < 0, color(red%50) bin(30)) ///
    (hist X if X >= 0, color(blue%50) bin(30)), ///
    xline(0, lcolor(black) lpattern(dash)) ///
    legend(label(1 "Below cutoff") label(2 "Above cutoff")) ///
    title("Running Variable Distribution") ///
    xtitle("Running variable") ///
    ytitle("Density") ///
    name(hist_X, replace)

* Estimated density plot using rddensity

rddensity X, c(0) plot ///
    graph_opt( ///
        title("Estimated Density of Running Variable") ///
        xtitle("Running variable") ///
        ytitle("Density") ///
        xline(0, lcolor(black) lpattern(dash)) ///
		legend(off) ///
        name(dens_X, replace) ///
    )

* Step 3: Combine histogram and density plot side-by-side

graph combine hist_X dens_X, cols(2) iscale(0.75) ///
    title("Graph 2. Running Variable Density Checks") ///
    name(Graph_2, replace)

graph export "outputs_ex1/Graph_2.png", replace
graph save "outputs_ex1/Graph_2.gph", replace

**## e)

* Formal Cattaneo-Jansson-Ma density test at cutoff X = 0
rddensity X, c(0)

* Store the test statistic and p-value
local T_stat = e(T_q)
local p_val  = e(pv_q)

display "Density test at cutoff X = 0"
display "T-statistic = " `T_stat'
display "p-value     = " `p_val'

preserve

clear
set obs 1

gen cutoff = 0
gen T_statistic = `T_stat'
gen p_value = `p_val'

format T_statistic p_value %9.4f

list, clean noobs

pwd
capture mkdir "outputs_ex1"

export excel using "outputs_ex1/Density_Test_Cutoff_0.xlsx", ///
    firstrow(variables) replace

restore

* The rddensity test examines whether the density of the running variable X
* is continuous at the cutoff X = 0.
*
* The null hypothesis is that there is no discontinuity in the density of X
* at the cutoff.
*
* The test gives a T-statistic of -1.3937 and a p-value of 0.1634.
* Since the p-value is larger than 0.05, we fail to reject the null hypothesis
* of density continuity at the cutoff.
*
* Therefore, we do not find statistically significant evidence of manipulation
* or sorting around the cutoff.
*
* This is favorable for the validity of the RD design, because it supports the
* assumption that municipalities just below and just above the Islamic vote-margin
* threshold are comparable.

**## f)


capture mkdir "outputs_ex1"

local X X
local Y Y

capture postclose handle

tempfile placebo_results

postfile handle ///
    double Cutoff ///
    str20 Sample_Used ///
    double RD_Estimator ///
    double Conventional_P_Value ///
    double Robust_P_Value ///
    double Bandwidth ///
    double Effective_N ///
    using "`placebo_results'", replace


* Negative placebo cutoffs: use only observations below the true cutoff

foreach c in -10 -5 {

    quietly rdrobust `Y' `X' if `X' < 0, ///
        c(`c') ///
        p(1) ///
        kernel(triangular) ///
        bwselect(mserd)

    local effN = e(N_h_l) + e(N_h_r)

    post handle ///
        (`c') ///
        ("X < 0") ///
        (e(tau_cl)) ///
        (e(pv_cl)) ///
        (e(pv_rb)) ///
        (e(h_l)) ///
        (`effN')

    display "Placebo cutoff = `c', sample X < 0"
    display "RD estimate    = " e(tau_cl)
    display "Conv. p-value  = " e(pv_cl)
    display "Robust p-value = " e(pv_rb)
    display "Bandwidth      = " e(h_l)
    display "Effective N    = " `effN'
}


* Positive placebo cutoffs: use only observations above the true cutoff


foreach c in 5 10 {

    quietly rdrobust `Y' `X' if `X' >= 0, ///
        c(`c') ///
        p(1) ///
        kernel(triangular) ///
        bwselect(mserd)

    local effN = e(N_h_l) + e(N_h_r)

    post handle ///
        (`c') ///
        ("X >= 0") ///
        (e(tau_cl)) ///
        (e(pv_cl)) ///
        (e(pv_rb)) ///
        (e(h_l)) ///
        (`effN')

    display "Placebo cutoff = `c', sample X >= 0"
    display "RD estimate    = " e(tau_cl)
    display "Conv. p-value  = " e(pv_cl)
    display "Robust p-value = " e(pv_rb)
    display "Bandwidth      = " e(h_l)
    display "Effective N    = " `effN'
}

postclose handle

preserve

use "`placebo_results'", clear

format RD_Estimator Conventional_P_Value Robust_P_Value Bandwidth %9.4f
format Effective_N %9.0f

list, clean noobs

export excel using "outputs_ex1/Table_placebo_cutoffs.xlsx", ///
    firstrow(variables) replace

restore


* We test for placebo discontinuities at alternative cutoffs: -10, -5, 5, and 10.
* The goal is to check whether discontinuities appear away from the true treatment
* cutoff X = 0.
*
* For the negative placebo cutoffs, we use only observations with X < 0.
* For the positive placebo cutoffs, we use only observations with X >= 0.
* This avoids contaminating the placebo tests with the real treatment threshold at X = 0.
*
* The conventional p-values are:
* cutoff -10: p = 0.1573
* cutoff -5:  p = 0.2997
* cutoff 5:   p = 0.4474
* cutoff 10:  p = 0.3012
*
* All p-values are above 0.05, so we fail to reject the null hypothesis
* of no discontinuity at each placebo cutoff.
*
* Therefore, we do not find evidence of alternative discontinuities away from
* the true cutoff. This supports the validity of the RD design, because the
* discontinuity appears to be specific to the actual electoral threshold X = 0.


**## g)

rdplot `Y' `X', c(`cutoff') p(1) nbins(20 20) binselect(es) ///
    graph_options( ///
        title("RD Plot of Y against X") ///
        ytitle("Outcome") ///
        xtitle("Running Variable") ///
        name(graph_1g, replace) ///
    )

graph export "outputs_ex1/graph_1g.png", replace
graph save "outputs_ex1/graph1_g.gph", replace

**## h)
* Linear, Uniform kernel, MSE-optimal bandwidth
rdrobust `Y' `X', c(`cutoff') p(1) ///
    kernel(uniform) bwselect(mserd)

*as indicated at the beginning of the problem set i will display conventional betas and standard errors
display "Uniform kernel - Conventional beta = " e(tau_cl)
display "Uniform kernel - Conventional SE   = " e(se_tau_cl)
display "Uniform kernel - Conventional pval = " e(pv_cl)

* Linear, triangular kernel, MSE-optimal bandwidth	
rdrobust `Y' `X', c(`cutoff') p(1) ///
    kernel(triangular) bwselect(mserd)

*as indicated at the beginning of the problem set i will display conventional betas and standard errors
display "Triangular kernel - Conventional beta = " e(tau_cl)
display "Triangular kernel - Conventional SE   = " e(se_tau_cl)
display "Triangular kernel - Conventional pval = " e(pv_cl)


* Using rdrobust with a linear polynomial and MSE-optimal bandwidth, the estimated RD effect is 
* positive for both kernel choices

* With the uniform kernel the estimated effect is about 3.20 percentage points
* With the triangular kernel, the estimated effect is about 3.02 percentage points

* Therefore, electing a mayor from an Islamic party appears to increase the share of women aged 15-20 with high school education.


**REMINDER: from now on as indicated by the Problem set we will use triangular kernel

**## i) 

capture drop X1 X2 X3 X4 TX1 TX2 TX3 TX4

forvalues j = 1/4 {
    gen X`j' = X^`j'
    gen TX`j' = T*X^`j'
}

reg Y T X1 X2 X3 X4 TX1 TX2 TX3 TX4

*the coefficient of T is the RD estimate: 3.6829

**## j) 

rdrobust `Y' `X', c(`cutoff') p(1) ///
    kernel(triangular) bwselect(mserd)

local opt_i = e(h_l) 

capture drop TX
gen TX = T*X

reg Y T X TX if abs(X) <= `opt_i'

*the coefficient of T is the RD estimate: 3.0595
* This estimate is very close to the triangular kernel rdrobus estimate mate at point h. 
* Nevertheless the two are not exactly the same because in point j we are running an 
* unweighted OLS regression withing the optimal bandwidth while the rdrobust with a 
* triangular kernel gives more weight to observations clores to the cutoff and less
* weight to obersvations away from the cutoff. 

**## k) 

rdrobust `Y' `X', c(`cutoff') p(1) ///
    kernel(triangular) bwselect(mserd)

capture scalar drop opt_i
scalar opt_i = e(h_l)

cap matrix drop R
matrix R = J(5, 3, .)

local i = 1

foreach m in 0.5 0.75 1 1.25 1.5 {

    rdrobust `Y' `X', c(`cutoff') p(1) ///
        kernel(triangular) h(`=scalar(opt_i)*`m'')

    matrix R[`i', 1] = e(tau_cl)
    matrix R[`i', 2] = e(ci_l_rb)
    matrix R[`i', 3] = e(ci_r_rb)

    local i = `i' + 1
}

matrix colnames R = coef ci_lo ci_hi
matrix rownames R = "0.5*opt_i" "0.75*opt_i" "1*opt_i" "1.25*opt_i" "1.5*opt_i"

matrix list R

capture graph drop Graph_3

preserve
clear

svmat R, names(col)
gen mult = _n*0.25 + 0.25

twoway (rcap ci_lo ci_hi mult) (scatter coef mult, mc(navy)), ///
    yline(0, lp(dash)) ///
    legend(off) ///
    xtitle("BW Multiplier") ///
    ytitle("RD Estimate") ///
    title("Graph 3. Bandwidth Sensitivity") ///
    name(Graph_3, replace)
	
graph export "outputs_ex1/Graph_3.png", replace
graph save "outputs_ex1/Graph_3.gph", replace

restore

* The bandwidth sensitivity plot shows that the RD point estimate remains positive for all bandwidth choices. 
* The estimate is smaller at 0.5*opt_i, but it becomes quite stable from 0.75*opt_i onward, remaining close to
* 3 percentage points.

* This suggests that the estimated effect is reasonably robust to bandwidth choice in terms of sign and magnitude. 
* This is consistent with the main result in Meyersso where Islamic mayoral rule is found to increase
* female high school education by around 3 percentage points.


	**# Q2
	**## a) 

	use fraud_pcenter_final, clear

	cap which rdplot
	if _rc ssc install rdrobust, replace

	* Create running variable

	gen dist_km = _dist/1000

	* Create signed distance:

	gen running = dist_km
	replace running = -dist_km if cov == 0

	label var running "Signed distance to coverage boundary, km"
	label var cov "Cell phone coverage"

	* Check that running variable is signed correctly
	summarize _dist dist_km running cov
	summarize running if cov == 0
	summarize running if cov == 1


	* Plot treatment variable as a function of running variable


	rdplot cov running, c(0) p(1) ///
		graph_options( ///
			title("Treatment variable, running variable") ///
			ytitle("Cell phone coverage") ///
			xtitle("Signed distance to coverage boundary, km") ///
			legend(off) ///
			name(graph_ex2a_rdplot, replace) ///
		)

	graph export "graph_ex2a_treatment_rdplot.png", replace


	* Compute RD estimate

	rdrobust cov running, ///
		c(0) ///
		p(1) ///
		kernel(triangular) ///
		bwselect(mserd)

	* Store relevant results: estimated coefficients, p-values

	scalar rd_estimate = e(tau_cl)
	scalar rd_pvalue   = e(pv_cl)
	scalar bandwidth   = e(h_l)

	display "RD estimate for treatment discontinuity = " rd_estimate
	display "Conventional p-value = " rd_pvalue
	display "MSE-optimal bandwidth = " bandwidth


	** Interpretation: this is a sharp RDD design. Cov changes discontinuosly at the boundary, by construction of the data set (long x lat rectangles). However, the authors address the fuzziness of the boundary due to oscillations by interpreting the treatment coefficient as an intent-to-treat effect. The authors thus additionally "fuzzify" the design by repeatedly computing \tau estimates for RDD with different boundary values and then testing for the difference in ATE.
	** the key identifying assumption is continuity of potential outcomes at the coverage boundary. Polling centers just outside coverage must therefore be valid counterfactuals for polling centers just inside coverage. this requires no sorting/manipulation around the boundary and no discontinuous changes in predetermined covariates at the boundary. In addition, segment fixed effects help compare polling centers near the same part of the boundary.

	**## b)

	* A proxy for longitude is harmless if the coverage boundary is horizontal/east-west, so treatment assignment and distance to the boundary depend only on latitude. Since latitude is measured correctly, the one-dimensional running variable can still be constructed without measurement error. If instead the boundary varies in both latitude and longitude, or is vertical/north-south, longitude measurement error mismeasures distance to the boundary and may misclassify treatment status.

	**## c) 
use fraud_pcenter_final, clear

* Recode regions 
recode region2 (3=1) (4=2)

drop if conflict == 1

* Create measures, including polynomials
capture drop _dist2 _dist3 _dist4 lat2 lat3 lat4 lon2 lon3 lon4 temp

replace _dist = _dist/1000
gen _dist2 = _dist^2
gen _dist3 = _dist^3
gen _dist4 = _dist^4

foreach i in 2 3 4 {
    capture drop lat`i'
    capture drop lon`i'
    gen lat`i' = lat^`i'
    gen lon`i' = lon^`i'
}

* Optimal bandwidth
gen temp = _dist
replace temp = -_dist if cov == 0

* Loop over the two measures of fraud used in the paper
foreach var in comb comb_ind {
    rdbwselect vote_`var' temp if ind_seg50 == 1, vce(cluster segment50)
    scalar hopt_`var' = e(h_mserd)

    forvalues r = 1/2 {
        rdbwselect vote_`var' temp if ind_seg50 == 1 & region2 == `r', ///
            vce(cluster segment50)
        scalar hopt_`var'_`r' = e(h_mserd)
    }
}

* Control means
foreach var in comb comb_ind {
    sum vote_`var' if cov == 0 & ind_seg50 == 1 & _dist <= hopt_`var'
    scalar mean_`var' = r(mean)

    forvalues r = 1/2 {
        sum vote_`var' if cov == 0 & ind_seg50 == 1 & ///
            _dist <= hopt_`var'_`r' & region2 == `r'
        scalar mean_`var'_`r' = r(mean)
    }
}

foreach var in comb comb_ind {
    sum vote_`var' if cov == 0 & ind_seg50 == 1
    scalar mean_`var'_all = r(mean)

    forvalues r = 1/2 {
        sum vote_`var' if cov == 0 & ind_seg50 == 1 & region2 == `r'
        scalar mean_`var'_`r'_all = r(mean)
    }
}

xtset, clear
xtset segment50 pccode


********************************************************************************
* B. Local Linear Regression using distance as forcing variable
********************************************************************************

foreach var in comb_ind comb {    

    * All regions
    xtreg vote_`var' cov##c.(_dist) if ind_seg50 == 1 & _dist <= hopt_`var', ///
        fe vce(cluster segment50)

    est store col1_a_`var'
    estadd scalar Obs = e(N)
    estadd scalar Mean = mean_`var'
    estadd scalar Bw = hopt_`var'
    estadd scalar Gr = e(N_clust)

    * Southeast
    xtreg vote_`var' cov##c.(_dist) if ind_seg50 == 1 & ///
        _dist <= hopt_`var'_1 & region2 == 1, ///
        fe vce(cluster segment50)

    est store col1_b_`var'
    estadd scalar Obs = e(N)
    estadd scalar Mean = mean_`var'_1
    estadd scalar Bw = hopt_`var'_1
    estadd scalar Gr = e(N_clust)

    * Northwest
    xtreg vote_`var' cov##c.(_dist) if ind_seg50 == 1 & ///
        _dist <= hopt_`var'_2 & region2 == 2, ///
        fe vce(cluster segment50)

    est store col1_c_`var'
    estadd scalar Obs = e(N)
    estadd scalar Mean = mean_`var'_2
    estadd scalar Bw = hopt_`var'_2
    estadd scalar Gr = e(N_clust)
}


********************************************************************************
* C. Polynomial RD using distance with all observations
********************************************************************************

foreach var in comb_ind comb {    

    * All regions
    xtreg vote_`var' cov##c.(_dist _dist2 _dist3) if ind_seg50 == 1, ///
        fe vce(cluster segment50)

    est store col2_a_`var'
    estadd scalar Obs = e(N)
    estadd scalar Mean = mean_`var'_all
    estadd scalar Gr = e(N_clust)

    * Southeast
    xtreg vote_`var' cov##c.(_dist _dist2 _dist3) if ind_seg50 == 1 & ///
        region2 == 1, ///
        fe vce(cluster segment50)

    est store col2_b_`var'
    estadd scalar Obs = e(N)
    estadd scalar Mean = mean_`var'_1_all
    estadd scalar Gr = e(N_clust)

    * Northwest
    xtreg vote_`var' cov##c.(_dist _dist2 _dist3) if ind_seg50 == 1 & ///
        region2 == 2, ///
        fe vce(cluster segment50)

    est store col2_c_`var'
    estadd scalar Obs = e(N)
    estadd scalar Mean = mean_`var'_2_all
    estadd scalar Gr = e(N_clust)
}


********************************************************************************
********************************************************************************
********************************************************************************
*       E. Export point estimates
********************************************************************************

capture mkdir "outputs_ex2"

putexcel set "outputs_ex2/Exercise2c_columns_1_3_5_point_estimates.xlsx", ///
    replace sheet("point_estimates")

* Table title
putexcel A1 = "Exercise 2(c): Point estimates from Gonzalez Table 2, columns 1, 3, and 5"

* Column headers
putexcel A3 = "Outcome" ///
         B3 = "Column 1: All regions" ///
         C3 = "Column 3: Southeast" ///
         D3 = "Column 5: Northwest"

********************************************************************************
* Panel A: At least one station with Category C fraud
* This corresponds to vote_comb_ind
********************************************************************************

estimates restore col1_a_comb_ind
local b1 = _b[1.cov]

estimates restore col1_b_comb_ind
local b3 = _b[1.cov]

estimates restore col1_c_comb_ind
local b5 = _b[1.cov]

putexcel A5 = "Panel A. At least one station with Category C fraud"
putexcel A6 = "Inside coverage" ///
         B6 = (`b1') ///
         C6 = (`b3') ///
         D6 = (`b5')

********************************************************************************
* Panel B: Share of votes under Category C fraud
* This corresponds to vote_comb
********************************************************************************

estimates restore col1_a_comb
local b1 = _b[1.cov]

estimates restore col1_b_comb
local b3 = _b[1.cov]

estimates restore col1_c_comb
local b5 = _b[1.cov]

putexcel A8 = "Panel B. Share of votes under Category C fraud"
putexcel A9 = "Inside coverage" ///
         B9 = (`b1') ///
         C9 = (`b3') ///
         D9 = (`b5')

********************************************************************************
* Format Excel cells
********************************************************************************

putexcel B6:D6, nformat(number_d3)
putexcel B9:D9, nformat(number_d3)

display "Point-estimate table exported to outputs_ex2/Exercise2c_columns_1_3_5_point_estimates.xlsx"


* Interpretation


* Exercise 2(c) interpretation:
* Columns 1, 3, and 5 report local linear RD estimates of the effect of cell phone coverage on the fraud outcomes vote_comb and vote_comb_id.

* Column 1 uses all regions. Column 3 restricts the sample to the Southeast region. Column 5 restricts the sample to the Northwest region.

* The coefficient on 1.cov is the RD point estimate. It measures the discontinuous change in the fraud outcome when moving from just outside to just inside the cell phone coverage boundary. For both measures of fraud, the coefficients are negative, implying that coverage may improve transparency (decrease fraud).

