***************************************************************************
* Cross-border Effects: Tracing U.S. Fentanyl's Effect on Rural Colombian Income

* This version: November 24, 2023

* Authors: Biasiucci, Giovanni - Geraldo-Correa, Gabriel - Herrera-Sarmiento, Juan Felipe - Hofer, Silvan Michael & Olivetta Mariasole

***************************************************************************
* This file runs the analysis section (regressions, plots, output, etc.)
***************************************************************************

* Load data
use "$data/Database_full.dta", clear

* Variable creation
foreach var in Employed Unemployed Inactives Avg_rural_income_nominal EAP PET period CPI Non_employed Year Month EstimateProductionHa avg_monthly_light_intensity avg_monthly_light_small avg_monthly_light_medium avg_monthly_light_big ISE primary_activities agriculture Exchange_rate ratio_fent ratio_cocaine fent_kg cocaine_kg only_fentanyl_related cocain_related_deaths only_cocaine_related fentanyl_related_deaths {
	
	gen log_`var' = log(`var')
}

gen real_income = Avg_rural_income_nominal/CPI
gen log_real_income = log(real_income)
gen avg_monthly_light_small_lagg = avg_monthly_light_small[_n-1]
gen COVID = (Year == 2020 & Month >= 4 & Month <=6)


* Label variables
label var log_fentanyl_related_deaths "Log number of deaths (US) caused, among others, by fentanyl"
label var log_cocain_related "Log number of deaths (US) caused, among others, by fentanyl"
label var log_Exchange_rate "Log Exchange rate (COP/USD)"
label var avg_monthly_light_small_lagg "(Lag) Average Monthly Night Light Intensity for Small Villages"
label var log_fentanyl_related_deaths "Log number of deaths (US) caused, among others, by fentanyl"
label var log_cocain_related "Log number of deaths (US) caused, among others, by fentanyl"
label var log_Exchange_rate "Log Exchange rate (COP/USD)"
label var log_EstimateProductionHa "Log Estimated Coca Production"
label var ENSO "ENSO index"
label var log_only_cocaine_related "Log of deaths by cocaine"
label var log_only_fentanyl_related "Log of deaths by fentanyl"
eststo clear

//////////////////////////////////////////////////////////////////////////
/////////////// Full regression (simple and with controls) ///////////////
//////////////////////////////////////////////////////////////////////////

eststo clear

sort DPTO period
xtset DPTO period



** Table
* Simple
* Col 1: survey
eststo: reghdfe log_real_income log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"
* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related   , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"
		
* Col 4: small	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"

	* Complete
* Col 5: survey
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID, abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"

* Col 6: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"

* Col 7: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"
		
* Col 8: small	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"

	*** 1st table: Full sample
  * Output table
esttab using "$tabfolder/Table_Regression_comparison_full.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccccccc} \\ \hline ") /// 
posthead(" & \multicolumn{8}{c}{Income} \\ \cline{2-5} \cline{6-9}   & Survey  &  \multicolumn{3}{c}{Light Intensity} & Survey & \multicolumn{3}{c}{Light Intensity} \\ \cline{3-5} \cline{7-9} & GEIH & Big & Medium & Small & GEIH & Big & Medium & Small \\ \hline  & & & & &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")


  * Output table
esttab using "$tabfolder/Table_Regression_comparison_full_compact.tex", replace f  ///
stats(N r2 CON SFE MFE, fmt(0 3)  labels("Observations" "R-squared" "Controls" "State F.E." "Month F.E.")) keep(log_only_fentanyl_related log_only_cocaine_related log_EstimateProductionHa) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccccccc} \\ \hline ") /// 
posthead(" & \multicolumn{8}{c}{Income} \\ \cline{2-5} \cline{6-9}   & Survey  &  \multicolumn{3}{c}{Light Intensity} & Survey & \multicolumn{3}{c}{Light Intensity} \\ \cline{3-5} \cline{7-9} & GEIH & Big & Medium & Small & GEIH & Big & Medium & Small \\ \hline  & & & & &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")

***** Panel B
preserve
keep if period >= 657

eststo clear

sort DPTO period
xtset DPTO period

	* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related   , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"
		
* Col 4: small
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\times$"
	
* Complete

* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"
		
* Col 4: small
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estadd local CON "$\checkmark$"


* panel B
esttab using "$tabfolder/Table_Regression_comparison_full", append ///
stats (N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline  & & & & &  &  &  &  \\ \textbf{Panel B: Sub sample from October 2014} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{9}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1. Standard errors clustered by state}" "\end{tabular}")	



esttab using "$tabfolder/Table_Regression_comparison_full_compact", append ///
stats (N r2 CON SFE MFE, fmt(0 3) labels("Observations" "R-squared" "Controls" "State F.E." "Month F.E.")) b(%9.3f) keep(log_only_fentanyl_related log_only_cocaine_related log_EstimateProductionHa) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline  & & & & &  &  &  &  \\ \textbf{Panel B: Sub sample} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\end{tabular}")
restore



////////////////////// Long table //////////////////

eststo clear

sort DPTO period
xtset DPTO period



** Table
* Simple
* Col 1: survey
eststo: reghdfe log_real_income log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related   , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 4: small	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

	* Complete
* Col 5: survey
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID, abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 6: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 7: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 8: small	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"


***** Panel B
preserve
keep if period >= 657


sort DPTO period
xtset DPTO period

	* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related   , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 4: small
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	
* Complete

* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) // partially works
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 4: small
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"


* panel B

	*** 1st table: Full sample
  * Output table
esttab using "$tabfolder/Table_Regression_comparison_full_long.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccccccccccccccc} \\ \hline ") /// 
posthead(" & \multicolumn{16}{c}{Income} \\ \cline{2-5} \cline{6-9} \cline{10-13} \cline{14-17}  & Survey  &  \multicolumn{3}{c}{Light Intensity} & Survey & \multicolumn{3}{c}{Light Intensity} & Survey  &  \multicolumn{3}{c}{Light Intensity} & Survey & \multicolumn{3}{c}{Light Intensity} \\ \cline{3-5} \cline{7-9} \cline{11-13} \cline{15-17} & GEIH & Big & Medium & Small & GEIH & Big & Medium & Small & GEIH & Big & Medium & Small & GEIH & Big & Medium & Small \\ \hline & & & & & & & & & & & & & &  &  &  &  \\ \textbf{Panel A: Full Sample}& & & & & & & &  \multicolumn{5}{c}{\textbf{Panel B: Sub Sample}}  \\ & & & & & & & & & & & &  & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{17}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1. Standard errors clustered by state}" "\end{tabular}")	

restore


/////////////////////////// COEF PLOT ////////////////////////////////

use "$data/Database_full.dta", clear


foreach var in Employed Unemployed Inactives Avg_rural_income_nominal EAP PET period CPI Non_employed Year Month EstimateProductionHa avg_monthly_light_intensity avg_monthly_light_small avg_monthly_light_medium avg_monthly_light_big ISE primary_activities agriculture Exchange_rate ratio_fent ratio_cocaine fent_kg cocaine_kg only_fentanyl_related cocain_related_deaths only_cocaine_related fentanyl_related_deaths {
	
	gen log_`var' = log(`var')
}

gen real_income = Avg_rural_income_nominal/CPI
gen log_real_income = log(real_income)
gen avg_monthly_light_small_lagg = avg_monthly_light_small[_n-1]
gen COVID = (Year == 2020 & Month >= 4 & Month <=6)


label var Participation_rate "Part. Rate"
label var log_Exchange_rate "L Exchange rate"
label var avg_monthly_light_small_lagg "(Lag) Average Monthly Night Light Intensity for Small Villages"
label var log_fentanyl_related_deaths "L # of deaths (US) caused, among others, by fentanyl"
label var log_cocain_related "L number of deaths (US) caused, among others, by fentanyl"
label var log_Exchange_rate "Exch. rate"
label var log_EstimateProductionHa "Coca Prod. "
label var ENSO "ENSO"
label var log_only_cocaine_related "Deaths (C)"
label var log_only_fentanyl_related "Deaths (F)"
label var ISE "Econ. Perf. Ind."

gen scale_ISE = ISE/10
gen scale_CPI = CPI/10
label var scale_ISE "Econ. Perf. Ind.*"
label var scale_CPI "CPI*"
reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related scale_CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO scale_ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estimates store coefs_pre
	estimates store est_`var'_pre
preserve
keep if period >=657	
	
reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related scale_CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO scale_ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estimates store coefs_post
	estimates store est_`var'_post
	
	reghdfe avg_monthly_light_small log_only_fentanyl_related
	
	reghdfe avg_monthly_light_small log_only_fentanyl_related
	
coefplot coefs_pre coefs_post, omitted	///
		  vertical ///
		  label plotlabels(Full Sub, w(4)) ///
		  yline(0, lpattern(dash) lwidth(*0.5)) ///
		  ytitle("") ///
		  xtitle("Income: Average Light Intensity for Small Villages", size(small) height(6)) ///
		  xlabel(, labsize(small) nogextend labc(black)) ///
		  msymbol(D)  ///
		  mfc(none) ///
		  mfcolor(white) ///
		  msize(small)  ///
		  levels(95) ///
		  xscale(lc(black))  ///
		  ciopts(lcol(black) recast(rcap) lwidth(*0.8)) ///
		   yscale(range(-0.05 0.05) lc(black))  ///
		   ylabel(-0.3(0.1)0.3, labsize(vbig)) ///
		  graphregion(fcolor(white)) bgcolor(white)  ///
		  name(coef, replace) ///
		  keep (*:  log_only_fentanyl_related log_only_cocaine_related scale_CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO scale_ISE COVID) 
restore
graph export "$figfolder/Figure_coef_plot.pdf", replace		  
