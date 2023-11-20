/////////////////////////// Some regressions ////////////////////////////

use "$data/Database.dta", clear

*define new variables
gen log_income = log(Avg_rural_income_nominal)

foreach var in Employed Non_employed Unemployed Inactives EAP PET EstimateProductionHa avg_monthly_light_intensity ISE primary_activities agriculture Exchange_rate fent_kg cocaine_kg {
	
	gen log_`var' = log(`var')
}




local controls monthly_inflation Employed Non_employed Unemployed Inactives EAP PET Unemployment_rate Participation_rate Occupied_rate EstimateProductionHa avg_monthly_light_intensity ENSO ISE primary_activities agriculture Exchange_rate ratio_fent ratio_cocaine fent_kg cocaine_kg log_Employed log_Non_employed log_Unemployed log_Inactives log_EAP log_PET log_EstimateProductionHa log_avg_monthly_light_intensity log_ISE log_primary_activities log_agriculture log_Exchange_rate log_fent_kg log_cocaine_kg

xtset DPTO period

* LASSO

rlasso log_income `controls' i.period, fe robust partial(i.period) cluster(DPTO) prestd 

rlasso Participation_rate `controls' i.period, fe robust partial(i.period) cluster(DPTO) prestd 

rlasso log_income log_fent_kg `controls' i.period, fe robust partial(i.period) cluster(DPTO) prestd c(0.1)

local selected = e(selected)

reghdfe log_income 


/////////////////////////// Some regressions ////////////////////////////

use "$data/Database_full.dta", clear


foreach var in Employed Unemployed Inactives Avg_rural_income_nominal EAP PET period CPI Non_employed Year Month EstimateProductionHa avg_monthly_light_intensity avg_monthly_light_small avg_monthly_light_medium avg_monthly_light_big ISE primary_activities agriculture Exchange_rate ratio_fent ratio_cocaine fent_kg cocaine_kg only_fentanyl_related cocain_related_deaths only_cocaine_related fentanyl_related_deaths {
	
	gen log_`var' = log(`var')
}

gen real_income = Avg_rural_income_nominal/CPI
gen log_real_income = log(real_income)



gen death_only_fent_lag_1 = log_only_fentanyl_related[_n-1]
gen death_only_fent_lag_2 = log_only_fentanyl_related[_n-2]
gen death_only_fent_lag_3 = log_only_fentanyl_related[_n-3]
gen death_only_fent_lag_4 = log_only_fentanyl_related[_n-4]
gen death_only_fent_lag_5 = log_only_fentanyl_related[_n-5]
gen death_only_fent_lag_6 = log_only_fentanyl_related[_n-6]
gen death_only_fent_lag_7 = log_only_fentanyl_related[_n-7]
gen death_only_fent_lag_8 = log_only_fentanyl_related[_n-8]
gen death_only_fent_lag_9 = log_only_fentanyl_related[_n-9]
gen death_only_fent_lag_10 = log_only_fentanyl_related[_n-10]
gen death_only_fent_lag_11 = log_only_fentanyl_related[_n-11]
gen death_only_fent_lag_12 = log_only_fentanyl_related[_n-12]



global controls Employed Unemployed Inactives Avg_rural_income_nominal EAP PET Unemployment_rate Participation_rate Occupied_rate period CPI Non_employed Year Month EstimateProductionHa avg_monthly_light_intensity avg_monthly_light_small avg_monthly_light_medium avg_monthly_light_big ENSO ISE primary_activities agriculture Exchange_rate ratio_fent ratio_cocaine fent_kg cocaine_kg only_fentanyl_related cocain_related_deaths only_cocaine_related fentanyl_related_deaths log_Unemployed log_Inactives log_Avg_rural_income_nominal log_EAP log_PET log_period log_CPI log_Non_employed log_Year log_Month log_EstimateProductionHa log_avg_monthly_light_intensity log_avg_monthly_light_small log_avg_monthly_light_medium log_avg_monthly_light_big log_ISE log_primary_activities log_agriculture log_Exchange_rate log_ratio_fent log_ratio_cocaine log_fent_kg log_cocaine_kg log_only_fentanyl_related log_cocain_related_deaths log_only_cocaine_related log_fentanyl_related_deaths death_only_fent_lag_1 death_only_fent_lag_2 death_only_fent_lag_3 death_only_fent_lag_4 death_only_fent_lag_5 death_only_fent_lag_6 death_only_fent_lag_7 death_only_fent_lag_8 death_only_fent_lag_9 death_only_fent_lag_10 death_only_fent_lag_11 death_only_fent_lag_12

xtset DPTO period

* LASSO
* Log avg rural income
rlasso log_Avg_rural_income_nominal $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd 
* log light instensive data (total)
rlasso log_avg_monthly_light_intensity $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd 
* log light instensive data (small)
rlasso log_avg_monthly_light_small $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd 
global selected = r(selected) 

reghdfe log_avg_monthly_light_small CPI log_only_fentanyl_related, abs( DPTO) 

reghdfe log_avg_monthly_light_medium CPI log_only_fentanyl_related, abs( DPTO) 

reghdfe log_avg_monthly_light_big CPI log_only_fentanyl_related, abs( DPTO) 

//////////////////////// Useful regressions? ///////////////////////////
reghdfe log_avg_monthly_light_intensity log_only_fentanyl_related EAP, abs(DPTO) // Positive correlation of fentanyl over income - Opposite of the intended

reghdfe log_avg_monthly_light_intensity log_fentanyl_related EAP, abs( DPTO) // Positive correlation of fentanyl over income - Opposite of the intended

reghdfe log_avg_monthly_light_intensity log_only_cocaine_related EAP, abs(DPTO) // Positive correlation of cocaine over income - Works for the purpose
 
reghdfe log_avg_monthly_light_intensity log_cocain_related EAP, abs(DPTO) // Positive correlation of cocaine over income - Works for the purpose

//////////////////////////////////

gen lag_avg_monthly_light_small = avg_monthly_light_small[_n-1]

rlasso log_avg_monthly_light_small $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd

/*Nariño = 52
Putumayo = 86
Norte de Santander = 54
Cauca = 19
Antioquia = 05
Bolívar = 13
Córdoba = 23
Caquetá = 18
Chocó = 27
Guaviare = 95*/
preserve 
keep if DPTO == 54 | DPTO == 56 | DPTO == 86  | DPTO == 19
reghdfe avg_monthly_light_small only_fentanyl_related only_cocaine_related CPI avg_monthly_light_medium lag_avg_monthly_light_small, abs(DPTO Month) nocons vce(cluster DPTO)

restore


preserve 
keep if DPTO == 52 | DPTO == 54 | DPTO == 86  | DPTO == 19
reghdfe avg_monthly_light_small only_fentanyl_related only_cocaine_related CPI avg_monthly_light_medium lag_avg_monthly_light_small, abs(DPTO Month) nocons vce(cluster DPTO)

reghdfe log_avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related  CPI log_avg_monthly_light_big, abs(DPTO Month) nocons vce(cluster DPTO)


restore

**************** Small regressions IMPORTANT
global controls Employed Unemployed Inactives Avg_rural_income_nominal EAP PET Unemployment_rate Participation_rate Occupied_rate period CPI Non_employed Year Month EstimateProductionHa avg_monthly_light_medium avg_monthly_light_big ENSO ISE primary_activities agriculture Exchange_rate ratio_fent ratio_cocaine fent_kg cocaine_kg only_fentanyl_related cocain_related_deaths only_cocaine_related fentanyl_related_deaths log_Unemployed log_Inactives log_Avg_rural_income_nominal log_EAP log_PET log_period log_CPI log_Non_employed log_Year log_Month log_EstimateProductionHa log_Exchange_rate log_fent_kg log_cocaine_kg log_only_fentanyl_related log_cocain_related_deaths log_only_cocaine_related log_fentanyl_related_deaths

rlasso avg_monthly_light_small log_only_fentanyl_related $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd
local selected = e(selected)

* lasso
reghdfe avg_monthly_light_small log_only_fentanyl_related log_fent_kg `selected', abs(DPTO Month) nocons vce(cluster DPTO) 

* controls by hand
* Mortality sub sampling
preserve
keep if Year <= 2017 & Year >=2014
reghdfe avg_monthly_light_small  log_fentanyl_related_deaths log_cocain_related CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 
restore

preserve
keep if Year  >= 2019
* Traditional method with survey
reghdfe log_real_income  log_fentanyl_related_deaths log_cocain_related CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 
* Innovative setup
reghdfe avg_monthly_light_small  log_fentanyl_related_deaths log_cocain_related CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 
restore
* only seizures
reghdfe avg_monthly_light_small log_fent_kg log_cocaine_kg CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 

reghdfe avg_monthly_light_small log_fent_kg log_cocaine_kg fent_event cocaine_event CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 

reghdfe log_real_income log_fent_kg log_cocaine_kg fent_event cocaine_event CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 

**** Laggs
reghdfe avg_monthly_light_small log_only_cocaine_related log_cocaine_kg CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 

******************** Medium regressions
rlasso avg_monthly_light_medium log_only_fentanyl_related $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd
local selected = e(selected)
* lasso
reghdfe avg_monthly_light_medium log_only_fentanyl_related `selected', abs(DPTO Month) nocons vce(cluster DPTO) 

* controls by hand
reghdfe avg_monthly_light_medium log_only_fentanyl_related log_fent_kg log_only_cocaine_related log_cocaine_kg CPI Unemployment_rate log_Exchange_rate ISE, abs(DPTO Month) nocons vce(cluster DPTO) 
**********************


* 1. No fixed effects
reghdfe log_real_income only_fentanyl_related CPI, noabs vce(cluster DPTO)

eststo: reghdfe avg_monthly_light_small only_fentanyl_related CPI, noabs vce(cluster DPTO)
	estadd local SFE $\times$
	estadd local TFE $\times$


estadd 

* Output table
esttab using "$tabfolder/Table_Regression_seized.tex", replace f  ///
stats(N r2 SFE TFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Time F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccc} \\ \hline ") /// 
posthead("& \multicolumn{4}{c}{$\Delta$ Real Income} \\ \hline  &  &  &  &  &  \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{5}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1}" "\end{tabular}")




* log light instensive data (medium)
rlasso log_avg_monthly_light_medium $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd 
* log light instensive data (big)
rlasso log_avg_monthly_light_big $controls i.period, fe robust partial(i.period) cluster(DPTO) prestd 

   