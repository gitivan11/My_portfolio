********************************************************************************
** Microeconometrics (cd. 20295)
** Prof: Thomas Le Barbanchon | TA: Erick Baumgartner
** Problem Set 1: Experiments and Randomization Inference
** Group Members: Chiara Nespoli, Ivan Varga, Jacopo Castelnuovo
********************************************************************************

clear all
cls

* 0. Setup and Conditional Path Logic

display "`c(username)'"

if "`c(username)'" == "MAFFINA_P" {
    global path "/Users/MAFFINA_P/Desktop/Uni/ESS/II Sem./Microeconometrics/PS1/files/"
    global outputpath "/Users/MAFFINA_P/Desktop/Uni/ESS/II Sem./Microeconometrics/PS1/files/"
}
else if "`c(username)'" == "Member2_Username" {
    global path "C:/Users/Member2/Documents/Microeconometrics/PS1/"
    global outputpath "C:/Users/Member2/Documents/Microeconometrics/PS1/Output/"
}
else if "`c(username)'" == "TA_Username" {
    global path "C:/Users/TA/Desktop/Grading/PS1/"
    global outputpath "C:/Users/TA/Desktop/Grading/PS1/Output/"
}

* Set the working directory to the main path
cd "$path"

cls

**# Q1.a

* load the dataset *
use jtrain2, clear

// ssc install ietoolkit

*generate the balance table 

* Initialize an empty matrix with 6 columns
matrix balcheck1 = (.,.,.,.,.,.)

local i = 1
* Loop over the 7 covariates (includes nodegree)
foreach var of varlist age educ black hisp nodegree re74 re75 {
    
    * Stats for group 0 (Control)
    sum `var' if train == 0, d
    local m0 = r(mean)
    local s0 = r(sd)
    
    * Stats for group 1 (Treated)
    sum `var' if train == 1, d
    local m1 = r(mean)
    local s1 = r(sd)
    
    * Difference and t-test p-value
    ttest `var', by(train)
    
    * Populate the matrix row by row
    matrix balcheck1[`i',1] = `m0'
    matrix balcheck1[`i',2] = `s0'
    matrix balcheck1[`i',3] = `m1'
    matrix balcheck1[`i',4] = `s1'
    matrix balcheck1[`i',5] = `m1' - `m0'
    matrix balcheck1[`i',6] = r(p)
    
    local i = `i' + 1
    * Expand the matrix downward for the next variable (7 variables total)
    if `i' <= 7 matrix balcheck1 = (balcheck1 \ .,.,.,.,.,.)
}

* Name the rows and columns
matrix rownames balcheck1 = age educ black hisp nodegree re74 re75
matrix colnames balcheck1 = Mean_Ctrl SD_Ctrl Mean_Treat SD_Treat Diff p_value

* Create the Excel file and paste starting in cell A1
putexcel set "TABLE_1.xlsx", replace
putexcel A1 = matrix(balcheck1), names bold 

**# Q1.b 

*perform the regression of re78 on train, using robust std.errors

reg re78 train, vce(robust)

scalar b_train = _b[train] // saving the beta coefficient of the regression
scalar se_train = _se[train] // saving also the standard error of the beta

* the results indcate that the average difference (in thousands of dollars)
* between those who participated in the program and the control is 1,794.34$
* in 1978 real earnings. 
* The estimated CI at 5% level is [0.4759489,3.112737]

**#Q1.c

// ssc install outreg2

* define global macros for the covariate groups, this will be helpful in case
* we need to change the regression models without changing the input of the code


global x_1 "train"
global x_2 "age educ black hisp"
global x_3 "re74 re75"

reg re78 $x_1, vce(robust) // regressing re78 on each "package" of covariates
estimates store reg1

reg re78 $x_1 $x_2, vce(robust)
estimates store reg2

reg re78 $x_1 $x_2 $x_3, vce(robust)
estimates store reg3

count if e(sample) & train == 1 // using e(sample) we count the exact number with train==1
								// in the previous regression
local n_treat = r(N)			// save the number in a local macro named n_treat
count if e(sample) & train == 0  // we perform the same step as above but for train==0
local n_ctrl = r(N)

*exporting the results in a single table
outreg2 [reg1 reg2 reg3] using "TABLE_2.xls", excel replace ///
    addtext("N Treated", `n_treat', "N Control", `n_ctrl')

* as it clear from the excel table the coefficient remains statistically significant
* and the variation in the absolute value is small (1.794 -> 1.686-> 1.680) starting
* from model 1 with no controls and then adding demographic covariates and finally previous earnings
* Statistical significance changes from 1% in Model 1 to 5% in Model 2 and Model 3.
* this is coherent with a good randomization and the change represents introduction of additional
* control for minor sample imbalances

**# Q1.d

*run again the regression

reg re78 train age educ black hisp re74 re75
predict influence_train, dfbeta(train) // 

* ranks from the bottom
sort influence_train
gen rank_low = _n

* ranks from the top
gsort -influence_train
gen rank_high = _n

* drop 3 lowest + 3 highest
reg re78 train age educ black hisp re74 re75 if rank_low>3 & rank_high>3, vce(robust)

* drop 5 lowest + 5 highest
reg re78 train age educ black hisp re74 re75 if rank_low>5 & rank_high>5, vce(robust) 

* drop 10 lowest + 10 highest
reg re78 train age educ black hisp re74 re75 if rank_low>10 & rank_high>10, vce(robust)

* since dfbeta identifies observations whose removal substantially changes a regression coefficient
* The coefficient falls from the baseline of 1.680 down to 1.358 (trimming 3), 1.224 (trimming 5), and finally 1.022 (trimming 10).
* we can conclude given the great change in the coefficient that the previous result was driven
* by a group of extreme outliers.

*-------------------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------------------


**#Q2.a

use jtrain3, clear
* Initialize a new empty matrix
matrix balcheck2 = (.,.,.,.,.,.)

local i = 1
* Loop over the 6 covariates (nodegree is excluded)
foreach var of varlist age educ black hisp re74 re75 {
    
    sum `var' if train == 0, d
    local m0 = r(mean)
    local s0 = r(sd)
    
    sum `var' if train == 1, d
    local m1 = r(mean)
    local s1 = r(sd)
    
    ttest `var', by(train)
    
    matrix balcheck2[`i',1] = `m0'
    matrix balcheck2[`i',2] = `s0'
    matrix balcheck2[`i',3] = `m1'
    matrix balcheck2[`i',4] = `s1'
    matrix balcheck2[`i',5] = `m1' - `m0'
    matrix balcheck2[`i',6] = r(p)
    
    local i = `i' + 1
    * Expand the matrix downward for the next variable (6 variables total)
    if `i' <= 6 matrix balcheck2 = (balcheck2 \ .,.,.,.,.,.)
}

matrix rownames balcheck2 = age educ black hisp re74 re75
matrix colnames balcheck2 = Mean_Ctrl SD_Ctrl Mean_Treat SD_Treat Diff p_value

* Modify the existing Excel file and paste starting in cell H1
putexcel set "TABLE_1.xlsx", modify
putexcel H1 = matrix(balcheck2), names bold
	
**#Q2.b

gen treated=. // generate empty variable

set seed 45654 // generic seed for reproduction

gen random=uniform()
sort random

egen random_order=rank(random)

qui sum random
gen N =r(N)
replace treated=0 if random_order<=(N/2)
replace treated=1 if random_order>(N/2) & random_order<=N

**# Q2.c

// ssc install randtreat

set seed 27972 // new seed

randtreat, generate(treated_2) // generate the new "fake" treatment variable

pwcorr treated treated_2, sig

*since p-value is 0.0303 the correlation is not statistically significant at 5%


**# Q2.d 


* (Assumes you have already run your Q2.b code here to generate the fake 'treated' variable)

* Initialize a third empty matrix
matrix balcheck3 = (.,.,.,.,.,.)

local i = 1
* Loop over the 6 covariates grouping by the fake 'treated' variable
foreach var of varlist age educ black hisp re74 re75 {
    
    sum `var' if treated == 0, d
    local m0 = r(mean)
    local s0 = r(sd)
    
    sum `var' if treated == 1, d
    local m1 = r(mean)
    local s1 = r(sd)
    
    ttest `var', by(treated)
    
    matrix balcheck3[`i',1] = `m0'
    matrix balcheck3[`i',2] = `s0'
    matrix balcheck3[`i',3] = `m1'
    matrix balcheck3[`i',4] = `s1'
    matrix balcheck3[`i',5] = `m1' - `m0'
    matrix balcheck3[`i',6] = r(p)
    
    local i = `i' + 1
    if `i' <= 6 matrix balcheck3 = (balcheck3 \ .,.,.,.,.,.)
}

matrix rownames balcheck3 = age educ black hisp re74 re75
matrix colnames balcheck3 = Mean_Ctrl SD_Ctrl Mean_Treat SD_Treat Diff p_value

* Modify the existing Excel file and paste starting in cell P1
putexcel set "TABLE_1.xlsx", modify
putexcel P1 = matrix(balcheck3), names bold

* looking at the p-value column we can see that every pairwise t-test is above
* 5%. This matches perfectly the randomness in treatment assignment


**#Q2.e 

global x_1_fake "treated"
global x_2 "age educ black hisp"
global x_3 "re74 re75"


* Model 1 (Fake Treatment only)
regress re78 $x_1_fake, vce(robust)
estimates store reg1_fake

* Model 2 (Adding demographics)
regress re78 $x_1_fake $x_2, vce(robust)
estimates store reg2_fake

* Model 3 (Adding prior earnings)
regress re78 $x_1_fake $x_2 $x_3, vce(robust)
estimates store reg3_fake

* Count the treated and controls used in the final model's sample
count if e(sample) & treated == 1
local n_treat = r(N)

count if e(sample) & treated == 0
local n_ctrl = r(N)

* We use "append" instead of "replace" so it adds to TABLE_2
outreg2 [reg1_fake reg2_fake reg3_fake] using "TABLE_2.xls", excel append ///
    addtext("N Treated", `n_treat', "N Control", `n_ctrl')


**#Q2.f


* Define globals for the covariate groups (using the real 'train' variable)
global x_1_real "train"
global x_2 "age educ black hisp"
global x_3 "re74 re75"


* Model 1 (Actual Treatment only)
regress re78 $x_1_real, vce(robust)
estimates store reg1_real

* Model 2 (Adding demographics)
regress re78 $x_1_real $x_2, vce(robust)
estimates store reg2_real

* Model 3 (Adding prior earnings)
regress re78 $x_1_real $x_2 $x_3, vce(robust)
estimates store reg3_real

* Count the treated and controls used in the final model's sample
count if e(sample) & train == 1
local n_treat = r(N)

count if e(sample) & train == 0
local n_ctrl = r(N)

outreg2 [reg1_real reg2_real reg3_real] using "TABLE_2.xls", excel append ///
    addtext("N Treated", `n_treat', "N Control", `n_ctrl')

	

*-------------------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------------------	
	
	
**#Q3.a 

* Load the experimental dataset

use jtrain2, clear
rlasso re78 age educ black hisp re74 re75, rob 
local sel_vars = e(selected) 

* Clean the macro: remove "_cons" and any stray dots using native list logic 
local to_remove "_cons ." 
local clean_vars : list sel_vars - to_remove 

regress re78 train `clean_vars', vce(robust)

* The naive approach does not work, since rlasso id dropping all the covariates
* except the intercept. This makes impossible to perform the second step of the task.
* Inference on this method is flawed because the algorithm is designed for prediction
* and not for causal inference. Thus, it drops the important confounders which are
* correlated with the treatment variable, which implies in our case OVB.

**#Q3.b 

**##i)

* Given that we have to perform both an automatic double selection using pdslasso
* and a manual double selection using rlasso, we perform the following steps

*automatic double selection
pdslasso re78 train (age* educ* black hisp re74 re75), rob // the variables in () are the candidate controls and on the other hand, while 'rob' uses HC-robust penalty loadings

*manual double selection
* LASSO of Y (outcome) on X 
rlasso re78 age educ black hisp re74 re75, rob 
local S_Y = e(selected) 

* LASSO of D (treatment) on X 
rlasso train age educ black hisp re74 re75, rob 
local S_D = e(selected) 

* Clean the macros: remove "_cons" and any stray dots using native list logic 
local to_remove "_cons ." 
local clean_Y : list S_Y - to_remove 
local clean_D : list S_D - to_remove 

* OLS on the union of selected controls 
regress re78 train `clean_Y' `clean_D', vce(robust)

/*The pdslasso output reveals that the automated double-selection algorithm selected zero high-dimensional controls, concluding that none of the baseline covariates possessed sufficient predictive power for the outcome or the treatment variable under the rigorous, heteroskedasticity-robust penalty
Because of this, the manual verification steps using rlasso also selected zero covariates, causing the local macros S_Y and S_D to capture only the unpenalized constant _cons
When these local macros were expanded in the final regress command, Stata attempted to manually include _cons—a reserved system variable—as an independent regressor, which immediately triggered the invalid name r(198) syntax error
Both outputs are perfectly coherent because they demonstrate the exact same econometric result: the union of the selected controls from both equations is empty, meaning the final post-double-selection procedure correctly defaults to a simple OLS regression of the outcome on just the treatment variable*/


**##ii)

*we create dummies for every age and educ level
dummies age
dummies educ

* Create some interaction terms between controls
gen re74_re75 = re74 * re75
gen black_educ = black * educ
gen hisp_educ = hisp * educ

* The wildcard (*) tells Stata to include all the newly created dummy variables.
* We also include the new interaction terms we generated.
pdslasso re78 train (age* educ* black hisp re74 re75 re74_re75 black_educ hisp_educ), rob

* Step 1: LASSO of outcome (re78) on the expanded controls
* Step 1: LASSO of outcome (re78) on the expanded controls 
rlasso re78 age* educ* black hisp re74 re75 re74_re75 black_educ hisp_educ, rob 
global S_Y_exp = e(selected) 

* Step 2: LASSO of treatment (train) on the expanded controls 
rlasso train age* educ* black hisp re74 re75 re74_re75 black_educ hisp_educ, rob 
global S_D_exp = e(selected) 

* Clean the macros: remove "_cons" and any stray dots using native list logic 
local to_remove "_cons ." 
local temp_Y "$S_Y_exp" 
local temp_D "$S_D_exp" 
global clean_Y_exp : list temp_Y - to_remove 
global clean_D_exp : list temp_D - to_remove 

* Step 3: OLS on the union of the expanded selected controls 
regress re78 train $clean_Y_exp $clean_D_exp, vce(robust)

* Step 3: OLS on the union of the expanded selected controls
regress re78 train $clean_Y_exp $clean_D_exp, vce(robust)

/*Expanding the feature set with dummies and interactions allows the LASSO algorithm to detect highly specific, nonlinear effects—such as the precise impact of being 18 or 30 years old—that a standard linear specification would completely miss
Because age18 and age30 were selected specifically in the treatment equation (the S_D step), they represent the confounders most strongly correlated with treatment assignment, highlighting the exact characteristics that suffer from the worst baseline imbalances between the treated and control groups
By taking the union of the selected variables and forcing these specific age dummies into the final OLS regression, the post-double-selection procedure actively controls for these imbalances to remove bias
This effectively immunizes the final regression against the severe omitted-variable bias that plagued the naive prediction-focused approach in Q3(a), ultimately isolating a valid causal estimate for the treatment effect.*/


*-------------------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------------------


**#Q4.a 

**##i) 

*estimate e_hat via logistic regression

use jtrain3, clear

* Define covariates
global X age educ black hisp re74

* Estimate propensity score via logistic regression
logit train $X

* Predicted propensity score: e_hat_logit(X)
predict double ehat_logit, pr

* Summary statistics separately for treated and controls
summ ehat_logit if train == 1, detail
summ ehat_logit if train == 0, detail 

* Overlap plot

tempvar bin mid dens_t dens_c dens_c_neg n_t n_c

* Choose bin width
local w = 0.05

* Create common bins
gen `bin' = floor(ehat_logit/`w')
gen `mid' = (`bin' + 0.5)*`w'

* Count treated and controls in each bin
bysort `mid': egen `n_t' = total(train==1)
bysort `mid': egen `n_c' = total(train==0)

* Total number in each group
count if train==1
local Nt = r(N)

count if train==0
local Nc = r(N)

* Convert counts to densities
gen `dens_t' = `n_t' / (`Nt'*`w')
gen `dens_c' = `n_c' / (`Nc'*`w')

* Mirror controls below zero
gen `dens_c_neg' = -`dens_c'

* Keep one observation per bin
bysort `mid': keep if _n==1

* Plot mirrored histogram
twoway ///
    (bar `dens_t' `mid', base(0) barwidth(`w')) ///
    (bar `dens_c_neg' `mid', base(0) barwidth(`w')) ///
    , ///
    yline(0) ///
    legend(order(1 "Treated" 2 "Control")) ///
    xtitle("Estimated propensity score") ///
    ytitle("Density") ///
    title("Overlap plot: logit propensity scores")

restore

**##ii) 


* load data
use jtrain3, clear

global X age educ black hisp re74

h2o init

cap _h2oframe remove jtrain3_h2o
_h2oframe put, into(jtrain3_h2o) current


_h2oframe factor train, replace

* fit random forest binary classifier

h2oml rfbinclass train $X, h2owhatsrseed(12345) ntrees(200)

* result 
predict ehat_rf, pr

* Summary statistics separately for treated and controls
summ ehat_rf if train == 1, detail
summ ehat_rf if train == 0, detail

* Overlap plot

tempvar bin mid dens_t dens_c dens_c_neg

* Choose bin width
local w = 0.05

* Create common bins
gen `bin' = floor(ehat_rf/`w')
gen `mid' = (`bin' + 0.5)*`w'

* Count observations in each bin by treatment status
bysort `mid': egen n_t = total(train==1)
bysort `mid': egen n_c = total(train==0)

* Total counts in each group
count if train==1
local Nt = r(N)

count if train==0
local Nc = r(N)

* Convert to densities
gen `dens_t' = n_t / (`Nt'*`w')
gen `dens_c' = n_c / (`Nc'*`w')

* Mirror controls below zero
gen `dens_c_neg' = -`dens_c'

* Keep one row per bin for plotting
bysort `mid': keep if _n==1

* Plot mirrored bars
twoway ///
    (bar `dens_t' `mid', base(0) barwidth(`w') ) ///
    (bar `dens_c_neg' `mid', base(0) barwidth(`w') ) ///
    , ///
    yline(0) ///
    legend(order(1 "Treated" 2 "Control")) ///
    xtitle("Estimated propensity score") ///
    ytitle("Density") ///
    title("Overlap plot of logit propensity scores")
	
**##iii) 

gen byte keep_logit = ehat_logit <= 0.8
gen byte keep_rf    = ehat_rf <= 0.8


* (i) Logit cutoff = max propensity score among controls

summ ehat_logit if train==0, meanonly
scalar cutoff_logit = r(max)
display "Logit cutoff (max control PS) = " cutoff_logit

* Indicator for treated units trimmed under logit rule
gen byte trim_logit = (train==1 & ehat_logit > cutoff_logit)

* Number and fraction of treated trimmed
count if train==1
scalar N_treated = r(N)

count if trim_logit==1
scalar N_trim_logit = r(N)

display "Number of treated trimmed (logit) = " N_trim_logit
display "Fraction of treated trimmed (logit) = " N_trim_logit / N_treated

* Compare covariate means: trimmed treated vs kept treated
gen byte treated_kept_logit = (train==1 & trim_logit==0)
gen byte treated_trimmed_logit = (train==1 & trim_logit==1)

tabstat age educ black hisp re74 if train==1, ///
    by(trim_logit) stat(n mean sd)

* (i) RF cutoff = max propensity score among controls

summ ehat_rf if train==0, meanonly
scalar cutoff_rf = r(max)
display "RF cutoff (max control PS) = " cutoff_rf

* Indicator for treated units trimmed under RF rule
gen byte trim_rf = (train==1 & ehat_rf > cutoff_rf)

* (ii) Number and fraction of treated trimmed
count if trim_rf==1
scalar N_trim_rf = r(N)

display "Number of treated trimmed (RF) = " N_trim_rf
display "Fraction of treated trimmed (RF) = " N_trim_rf / N_treated

* (iii) Compare covariate means: trimmed treated vs kept treated
gen byte treated_kept_rf = (train==1 & trim_rf==0)
gen byte treated_trimmed_rf = (train==1 & trim_rf==1)

tabstat age educ black hisp re74 if train==1, ///
    by(trim_rf) stat(n mean sd)


**## iv) 

* Trimming rule:
* keep all controls
* keep treated only if their PS is at or below the cutoff

gen byte keep_logit = (train==0) | (train==1 & ehat_logit <= cutoff_logit)
gen byte keep_rf    = (train==0) | (train==1 & ehat_rf    <= cutoff_rf)

* Column 1: re78 full sample
reg re78 train $X
estimates store col1

* Column 2: re78 logit-trimmed sample
reg re78 train $X if keep_logit==1
estimates store col2

* Column 3: re78 RF-trimmed sample
reg re78 train $X if keep_rf==1
estimates store col3

* Column 4: re75 full sample
reg re75 train $X
estimates store col4

* Column 5: re75 logit-trimmed sample
reg re75 train $X if keep_logit==1
estimates store col5

* Column 6: re75 RF-trimmed sample
reg re75 train $X if keep_rf==1
estimates store col6

* Display a table
estimates table col1 col2 col3 col4 col5 col6, ///
    b(%9.3f) se(%9.3f) stats(N r2, fmt(%9.0g %9.3f))

**##	v) compare estimators


* (i) Flexibility: Random Forests (RF) are completely nonparametric and capture nonlinearities and interactions automatically, while logistic regression assumes a linear functional form in log-odds and requires interactions to be specified manually.
* (ii) Tail behavior/calibration: Logit has smooth tail behavior due to the logistic CDF and is generally well-calibrated. RF can be irregular or spiky, producing extreme scores in regions of poor overlap. As seen in the output, the median propensity score for controls under RF is exactly 0. 
* (iii) Interpretability and reproducibility: Logit provides clear, interpretable coefficients and is deterministic. RF acts as a "black box" where specific relationships are hard to disentangle, and results are seed-dependent.
* (iv) Effect on trimming: Because RF pushes propensity scores to extremes in areas of poor overlap, the trimming rule (e_hat <= 0.8) discards a vastly different set of observations [1, 9]. As seen in the Stata output, Logit trimmed 37 units (20%) while RF trimmed 117 units (63.24%). The trimmed units under Logit tend to be much younger (mean age 18.5 vs 27.6), whereas RF trims a broader mix of ages but strictly targets those with low prior earnings (mean re74 of 0.107 vs 5.51).*/

**#Q4.b

/*
* Dehejia and Wahba (1999) concluded that non-experimental methods using propensity scores could replicate experimental benchmarks. However, Imbens and Xu (2025) point out that recovering the true causal estimand requires the unconfoundedness assumption to hold. 
* Unconfoundedness is fundamentally untestable directly, but its plausibility must be assessed through placebo tests (e.g., using 1975 earnings as an outcome). When applied to the nonexperimental samples used by Dehejia and Wahba, placebo tests consistently yield large, negative, and statistically significant estimates. This is perfectly confirmed by our TABLE 3 output, which shows a significant negative effect on re75 across all specifications (ranging from -2.00 to -3.39), indicating a severe violation of unconfoundedness. 
* Therefore, the nonexperimental results cannot be strictly interpreted as causal. The fact that modern estimators matched the experimental benchmark on the specific LDW-CPS sample was coincidental. Furthermore, by aggressively trimming the sample to enforce overlap, we fundamentally change the estimand. We are no longer estimating the causal effect for the original target population, but rather a local ATT for a specific "overlap" sub-population from which individuals with the highest propensity scores have been systematically discarded. 
*/


*-------------------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------------------


**#Q5.a

*UNBIASEDNESS OF NEYMAN'S INFERENCE

* Following Athey and Imbens (2017), the finite-sample ATE is:
* tau = (1/N) * sum_{i=1}^N [ Y_i(1) - Y_i(0) ]

* Neyman's estimator is the difference in observed means:
* tau_hat = Ybar_t_obs - Ybar_c_obs

* This estimator can also be written as:
* tau_hat = tau + (1/N) * sum_{i=1}^N D_i * [ (N/N_t)*Y_i(1) + (N/N_c)*Y_i(0) ]
* Since E[D_i] = 0 under random assignment, tau_hat is unbiased even with heterogeneous effects.

* Neyman inference depends on the variance of tau_hat:
* V(tau_hat) = S_c^2 / N_c + S_t^2 / N_t - S_tc^2 / N

* The term S_tc^2 cannot be estimated because we never observe both Y_i(1) and Y_i(0).
* Therefore, the usual estimator is: V_hat_Neyman = s_c^2 / N_c + s_t^2 / N_t
* This omits S_tc^2 / N and is upward biased.

* Neyman inference is unbiased in two cases:
* 1) Constant treatment effects -> S_tc^2 = 0
* 2) Infinite population view: V_hat_Neyman is unbiased for Var(tau_hat) as estimator of the population ATE rather than the finite-sample ATE. 

**#Q5.b

* Fisher's inference focuses on testing sharp null hypotheses,
* in particular the null of no treatment effect for any unit:

* H0: Y_i(0) = Y_i(1)   for all i = 1,...,N.

* Under this hypothesis, all missing potential outcomes can be
* inferred from the observed data, so the full set of potential outcomes is known.

* Considering the test statistic as the difference in means by treatment status:

* T = Ybar_t_obs - Ybar_c_obs

* The Fisher p-value is obtained as the probability, over the randomization distribution, 
* of observing a value of the statistic at least as extreme as the realized one:

* p = Pr( |T(W, Y_obs)| >= |T(W_obs, Y_obs)| )

* An important component of Fisher inference is the choice of the test statistic. 
* A natural choice is the difference in mean outcomes between treated and control units.
* However, alternative statistics can be used, such as the difference in mean ranks, 
* where outcomes are transformed into ranks before computing the statistic.
* Such transformations can improve the power of the test in the presence of outliers or heavy-tailed outcome distributions.


* load the dataset *
use jtrain2, clear
reg re78 train

capture which ritest
if _rc ssc install ritest

ritest train _b[train], reps(10000) seed(12345) nodots: reg re78 train


* Using ritest in Stata, I obtain a Fisher randomization inference p-value of approximately 0.0029, 
* which different to the value of 0.0044 reported by Athey and Imbens (2017).

* In Section 4.1, Athey and Imbens compute the Fisher p-value by repeatedly reassigning treatment, keeping the number of treated
* and control units fixed, and recalculating the test statistic.

* The difference arises because, i practice randomization inference is implemented through Monte Carlo 
* resampling rather than by enumerating all possible treatment assignments.

* As discussed by HeB (2017), when the number of possible permutations is very large, the randomization 
* distribution is approximated using a large number of random draws.
* As a consequence, the estimated p-value depends on the number of replications, the random seed used, and minor implementation details.

* Therefore, small discrepancies between the estimated p-value and the one reported  by Athey and Imbens are expected. 

**#Q5.c

* Athey and Imbens' illustration of Fisherian inference using the LaLonde (1986) data can  be criticized 
* primarily because the assumed assignment mechanism does not accurately reflect the original randomization plan.

* In their illustration, Athey and Imbens treat the data as arising from a completely randomized experiment, 
* where treatment is randomly reassigned across all individuals while keeping the total number of treated and control units fixed.

* This procedure implicitly assumes a simple random assignment over a single homogeneous sample, 
* as in the framework of completely randomized experiments discussed in their Section 4.

* However, the original LaLonde experiment had a more complex design. 
* The National Supported Work (NSW) program was implemented across multiple sites and 
* target groups (see note 4 in LaLonde, 1986), and treatment probabilities were not necessarily identical across all subpopulations.

* In particular, LaLonde notes that in at least one site the assignment probability 
* differed from 0.5 (see note 10 in LaLonde, 1986), implying that the experiment was not a purely completely randomized design.

* Moreover, the dataset commonly used in empirical applications (including the one used by Athey and Imbens) 
* is a restricted subsample of the original experiment.

* As highlighted in the problem set, the available data include only a subset of the original treated and control units.

* In addition, LaLonde documents the presence of sample attrition, even if part of it was randomly 
* induced and therefore does not threaten internal validity (see page 606 in LaLonde, 1986).
* Nonetheless, these features imply that the observed sample does not perfectly coincide with the initially randomized population.


**#Q5d
**## i)

* HC1 and HC3 are both heteroskedasticity-consistent estimators but differ in how they correct for finite-sample bias.
*
* In Stata, vce(robust) (HC1) estimates the variance of observation j as:

* sigma_j^2 = (N / (N - K)) * u_j^2
* where u_j is the residual and the factor N/(N-K) improves small-sample properties (Stata Manual on linear regression).

* In contrast, HC3 (vce(hc3)) uses:

* sigma_j^2 = u_j^2 / (1 - h_jj)^2

* This adjustment accounts for leverage (h_jj) and tends to perform better under heteroskedasticity.
* As a result, vce(hc3) typically produces more conservative confidence intervals (Stata Manual on linear regression).

* Applying HC3 instead of HC1 has important implications for inference.
* As emphasized in the Data Colada post, re-estimating the analyses with HC3 leads to more robust standard errors.

* The bar chart shows that HC1 standard errors systematically over-reject, with false-positive rates often above the
* nominal 5% level. In contrast, HC3 produces rejection rates closer to 5%, indicating more accurately calibrated inference.


**##ii)
*the first part will be mantained the same
* load the dataset *
use jtrain2, clear

// ssc install ietoolkit

*generate the balance table 

* Initialize an empty matrix with 6 columns
matrix balcheck1 = (.,.,.,.,.,.)

local i = 1
* Loop over the 7 covariates (includes nodegree)
foreach var of varlist age educ black hisp nodegree re74 re75 {
    
    * Stats for group 0 (Control)
    sum `var' if train == 0, d
    local m0 = r(mean)
    local s0 = r(sd)
    
    * Stats for group 1 (Treated)
    sum `var' if train == 1, d
    local m1 = r(mean)
    local s1 = r(sd)
    
    * Difference and t-test p-value
    ttest `var', by(train)
    
    * Populate the matrix row by row
    matrix balcheck1[`i',1] = `m0'
    matrix balcheck1[`i',2] = `s0'
    matrix balcheck1[`i',3] = `m1'
    matrix balcheck1[`i',4] = `s1'
    matrix balcheck1[`i',5] = `m1' - `m0'
    matrix balcheck1[`i',6] = r(p)
    
    local i = `i' + 1
    * Expand the matrix downward for the next variable (7 variables total)
    if `i' <= 7 matrix balcheck1 = (balcheck1 \ .,.,.,.,.,.)
}

* Name the rows and columns
matrix rownames balcheck1 = age educ black hisp nodegree re74 re75
matrix colnames balcheck1 = Mean_Ctrl SD_Ctrl Mean_Treat SD_Treat Diff p_value

* Create the Excel file and paste starting in cell A1
putexcel set "TABLE_1_hc3.xlsx", replace
putexcel A1 = matrix(balcheck1), names bold 


*perform the regression of re78 on train, using HC3 std.errors

reg re78 train, vce(hc3)

scalar b_train = _b[train] // saving the beta coefficient of the regression
scalar se_train = _se[train] // saving also the standard error of the beta

* the results indcate that the average difference (in thousands of dollars)
* between those who participated in the program and the control is 1,794.43$
* in 1978 real earnings. 
* The estimated CI at 5% level is [0.47,3.12]
* Switching from HC1 (robust) to HC3 slightly increases the standard error (from 0.671 to 0.673), 
* reflecting a more conservative correction for finite-sample bias and leverage. 
* However, the difference is negligible, and the statistical significance of the estimate is unchanged (p = 0.008 in both cases).


// ssc install outreg2

* define global macros for the covariate groups, this will be helpful in case
* we need to change the regression models without changing the input of the code

global x_1 "train"
global x_2 "age educ black hisp"
global x_3 "re74 re75"

reg re78 $x_1, vce(hc3) // regressing re78 on each "package" of covariates
estimates store reg1

reg re78 $x_1 $x_2, vce(hc3)
estimates store reg2

reg re78 $x_1 $x_2 $x_3, vce(hc3)
estimates store reg3

count if e(sample) & train == 1 // using e(sample) we count the exact number with train==1
								// in the previous regression
local n_treat = r(N)			// save the number in a local macro named n_treat
count if e(sample) & train == 0  // we perform the same step as above but for train==0
local n_ctrl = r(N)

*exporting the results in a single table
outreg2 [reg1 reg2 reg3] using "TABLE_2_hc3.xls", excel replace ///
    addtext("N Treated", `n_treat', "N Control", `n_ctrl')

* as it clear from the excel table the coefficient remains statistically significant
* and the variation in the absolute value is small (1.794 -> 1.686-> 1.680) starting
* from model 1 with no controls and then adding demographic covariates and finally previous earnings
* Statistical significance changes from 1% in Model 1 to 5% in Model 2 and Model 3.
* this is coherent with a good randomization and the change represents introduction of additional
* control for minor sample imbalances
* Comparing HC1 and HC3 standard errors, the latter are slightly larger (0.673 vs 0.671), reflecting a more conservative correction for leverage and finite-sample bias. 
* However, the differences do not affect statistical significance. 
* This suggests that inference is robust to the choice of variance estimator and that HC1 is not severely downward biased in this application.

*run again the regression

reg re78 train age educ black hisp re74 re75
predict influence_train, dfbeta(train) // 

* ranks from the bottom
sort influence_train
gen rank_low = _n

* ranks from the top
gsort -influence_train
gen rank_high = _n

* drop 3 lowest + 3 highest
reg re78 train age educ black hisp re74 re75 if rank_low>3 & rank_high>3, vce(hc3)

* drop 5 lowest + 5 highest
reg re78 train age educ black hisp re74 re75 if rank_low>5 & rank_high>5, vce(hc3) 

* drop 10 lowest + 10 highest
reg re78 train age educ black hisp re74 re75 if rank_low>10 & rank_high>10, vce(hc3)

* since dfbeta identifies observations whose removal substantially changes a regression coefficient
* The coefficient falls from the baseline of 1.680 down to 1.358 (trimming 3), 1.224 (trimming 5), and finally 1.022 (trimming 10).
* we can conclude given the great change in the coefficient that the previous result was driven
* by a group of extreme outliers.
* Results are very similar when using HC1 or HC3 standard errors, indicating that the influence of these 
* observations affects primarily the point estimates rather than the variance estimation.

**##iii)

*the first part will be mantained the same
* load the dataset *
use jtrain2, clear

// ssc install ietoolkit

*generate the balance table 

* Initialize an empty matrix with 6 columns
matrix balcheck1 = (.,.,.,.,.,.)

local i = 1
* Loop over the 7 covariates (includes nodegree)
foreach var of varlist age educ black hisp nodegree re74 re75 {
    
    * Stats for group 0 (Control)
    sum `var' if train == 0, d
    local m0 = r(mean)
    local s0 = r(sd)
    
    * Stats for group 1 (Treated)
    sum `var' if train == 1, d
    local m1 = r(mean)
    local s1 = r(sd)
    
    * Difference and t-test p-value
    ttest `var', by(train)
    
    * Populate the matrix row by row
    matrix balcheck1[`i',1] = `m0'
    matrix balcheck1[`i',2] = `s0'
    matrix balcheck1[`i',3] = `m1'
    matrix balcheck1[`i',4] = `s1'
    matrix balcheck1[`i',5] = `m1' - `m0'
    matrix balcheck1[`i',6] = r(p)
    
    local i = `i' + 1
    * Expand the matrix downward for the next variable (7 variables total)
    if `i' <= 7 matrix balcheck1 = (balcheck1 \ .,.,.,.,.,.)
}

* Name the rows and columns
matrix rownames balcheck1 = age educ black hisp nodegree re74 re75
matrix colnames balcheck1 = Mean_Ctrl SD_Ctrl Mean_Treat SD_Treat Diff p_value

* Create the Excel file and paste starting in cell A1
putexcel set "TABLE_1_boot.xlsx", replace
putexcel A1 = matrix(balcheck1), names bold 


bootstrap _b[train], reps(1000) seed(12345): reg re78 train

* The results indicate that the average difference (in thousands of dollars)
* between those who participated in the program and the control group is 1.794, 
* corresponding to about $1,794 higher earnings in 1978 for treated individuals.

* The bootstrap standard error is 0.673, leading to a 95% confidence interval of [0.47, 3.11]

* Compared to HC1 and HC3, the bootstrap standard error is almost identical,
* and the statistical significance of the estimate remains unchanged (p = 0.008).
* This suggests that inference is robust across different methods for computing
* standard errors and that heteroskedasticity or leverage issues are not driving the results in this application.


// ssc install outreg2

* define global macros for the covariate groups, this will be helpful in case
* we need to change the regression models without changing the input of the code

global x_1 "train"
global x_2 "age educ black hisp"
global x_3 "re74 re75"

bootstrap _b[train], reps(1000) seed(12345): reg re78 $x_1
estimates store reg1_boot

bootstrap _b[train], reps(1000) seed(12345): reg re78 $x_1 $x_2
estimates store reg2_boot

bootstrap _b[train], reps(1000) seed(12345): reg re78 $x_1 $x_2 $x_3
estimates store reg3_boot

count if e(sample) & train == 1 // using e(sample) we count the exact number with train==1
								// in the previous regression
local n_treat = r(N)			// save the number in a local macro named n_treat
count if e(sample) & train == 0  // we perform the same step as above but for train==0
local n_ctrl = r(N)

*exporting the results in a single table

outreg2 [reg1_boot reg2_boot reg3_boot] using "TABLE_2_boot.xls", excel replace ///
    addtext("N Treated", `n_treat', "N Control", `n_ctrl')
	
* As shown in the bootstrap results, the coefficient on train remains positive
* and statistically significant across all specifications.
* Its magnitude decreases only slightly when adding covariates (1.794 -> 1.686 -> 1.680), 
* consistent with the introduction of controls accounting for minor sample imbalances.
* The bootstrap standard errors are very similar to those obtained with HC3,
* and statistical significance remains unchanged across models.
* This indicates that inference is robust to the choice of variance estimator


*run again the regression

reg re78 train age educ black hisp re74 re75
predict influence_train, dfbeta(train) // 

* ranks from the bottom
sort influence_train
gen rank_low = _n

* ranks from the top
gsort -influence_train
gen rank_high = _n

* drop 3 lowest + 3 highest
bootstrap _b[train], reps(1000) seed(12345): reg re78 train age educ black hisp re74 re75 if rank_low > 3 & rank_high > 3
* drop 5 lowest + 5 highest
bootstrap _b[train], reps(1000) seed(12345): reg re78 train age educ black hisp re74 re75 if rank_low > 5 & rank_high > 5
* drop 10 lowest + 10 highest
bootstrap _b[train], reps(1000) seed(12345): reg re78 train age educ black hisp re74 re75 if rank_low > 10 & rank_high > 10

* since dfbeta identifies observations whose removal substantially changes a regression coefficient,
* the coefficient falls from the baseline of 1.680 down to 1.358 (trimming 3), 1.224 (trimming 5), and finally 1.022 (trimming 10).

* we can conclude, given the large change in the coefficient, that the initial result was partly driven 
* by a group of extreme influential observations (outliers).

* results are very similar when using HC1, HC3, and bootstrap standard errors, indicating that the influence
* of these observations affects primarily the point estimates rather than the variance estimation.

**##iv)

* Overall, our conclusions about the effect of the training program do not change in a qualitative sense. 
* Using HC3 and bootstrap standard errors, the coefficient on train remains positive and statistically significant both in the baseline
* regression and in the specifications. Therefore, the main conclusion is unchanged: the program appears to have increased 1978 earnings on average.

* However, the dfbeta analysis shows that the estimated magnitude of the effect is sensitive to a small 
* number of influential observations. After trimming these units, the coefficient on train falls substantially. 
* This suggests that the sign of the effect is fairly robust, but its exact size should be interpreted with caution.

* A reason why the HC3 results do not change much in this exercise is that HC3 only affects the standard errors, not the coefficient itself. 
* As discussed in the Data Colada post, HC3 matters most when HC1 standard errors are downward biased because
* of small-sample problems or high leverage. In this application, HC1, HC3, and bootstrap standard errors are all very similar, 
* which suggests that variance estimation is not the main issue. Instead, the main issue is that a few influential observations affect the point estimate.


*
