////////////////// Final regression ///////////////
use "$data/Database_full.dta", clear


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
label var log_EstimateProductionHa "Log Estimated Coca Production based on Quinoa"
label var ENSO "ENSO index"
label var log_only_cocaine_related "Log Number of deaths (US) caused only by cocaine"
label var log_only_fentanyl_related "Log Number of deaths (US) caused only by fentanyl"



eststo clear

sort DPTO period
xtset DPTO period



** Table
* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 4: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 5	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	
	*** 1st table: Full sample
  * Output table
esttab using "$tabfolder/Table_Regression_comparison.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccc} \\ \hline ") /// 
posthead(" & \multicolumn{4}{c}{Income} \\ \cline{2-5} & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small} \\ \hline   &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")


  * Output table
esttab using "$tabfolder/Table_Regression_comparison_compact.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3)  labels("Observations" "R-squared" "State F.E." "Month F.E.")) keep(log_only_fentanyl_related ) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccc} \\ \hline ") /// 
posthead(" & \multicolumn{4}{c}{Income} \\ \cline{2-5} & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small} \\ \hline   &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")

***** Panel B
preserve
keep if period >= 657

eststo clear

sort DPTO period
xtset DPTO period


* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 4: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 5	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estimates store coefs
	estimates store est_`var'
* panel B
esttab using "$tabfolder/Table_Regression_comparison", append ///
stats (N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline   &  &  &  &  \\ \textbf{Panel B: Sub sample from October 2014} \\ & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{5}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1}" "\end{tabular}")	


esttab using "$tabfolder/Table_Regression_comparison_compact", append ///
stats (N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) keep(log_only_fentanyl_related ) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline   &  &  &  &  \\ \textbf{Panel B: Sub sample from October 2014} \\ & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{5}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1}" "\end{tabular}")

restore


************ COEF PLOT

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
label var log_Exchange_rate "L Exch. rate"
label var log_EstimateProductionHa "L Est. Coca Prod. "
label var ENSO "ENSO"
label var log_only_cocaine_related "L deaths coca."
label var log_only_fentanyl_related "L deaths fent."
label var ISE "Econ. Perf. Ind."

gen scale_ISE = ISE/10
gen scale_CPI = CPI/10
label var scale_ISE "Scaled Econ. Perf. Ind."
label var scale_CPI "Scaled CPI"
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
		  label plotlabels(Full Post, w(4)) ///
		  yline(0, lpattern(dash) lwidth(*0.5)) ///
		  ytitle("") ///
		  xtitle("Income: Average Light Intensity for Small Villages", size(small) height(6)) ///
		  xlabel(, labsize(vsmall) nogextend labc(black)) ///
		  msymbol(D)  ///
		  mfc(none) ///
		  mfcolor(white) ///
		  msize(small)  ///
		  levels(95) ///
		  xscale(lc(black))  ///
		  ciopts(lcol(black) recast(rcap) lwidth(*0.8)) ///
		   yscale(range(-0.05 0.05) lc(black))  ///
		   ylabel(-0.3(0.1)0.3) ///
		  graphregion(fcolor(white)) bgcolor(white)  ///
		  name(coef, replace) ///
		  keep (*:  log_only_fentanyl_related log_only_cocaine_related scale_CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO scale_ISE COVID) 
restore
graph export "$figfolder/Figure_coef_plot.pdf", replace		  
		  

		  
		  
		  //////////////////// Simple regression /////////////////
		  
		  * Label variables
label var log_fentanyl_related_deaths "Log number of deaths (US) caused, among others, by fentanyl"
label var log_cocain_related "Log number of deaths (US) caused, among others, by fentanyl"
label var log_Exchange_rate "Log Exchange rate (COP/USD)"
label var avg_monthly_light_small_lagg "(Lag) Average Monthly Night Light Intensity for Small Villages"
label var log_fentanyl_related_deaths "Log number of deaths (US) caused, among others, by fentanyl"
label var log_cocain_related "Log number of deaths (US) caused, among others, by fentanyl"
label var log_Exchange_rate "Log Exchange rate (COP/USD)"
label var log_EstimateProductionHa "Log Estimated Coca Production based on Quinoa"
label var ENSO "ENSO index"
label var log_only_cocaine_related "Log Number of deaths (US) caused only by cocaine"
label var log_only_fentanyl_related "Log Number of deaths (US) caused only by fentanyl"
eststo clear

sort DPTO period
xtset DPTO period



** Table
* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related, abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 4: small
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	
	/*
#d ; 
local coeflabels coeflabels( 
  d_trained_share "Change in Share of Emails with Trained Workers" 
  d_trained_levels "Change in Levels of Emails with Trained Workers" 
  IVshare_workersend "Share of Pre- Emails Received from Trained" 
  levels_IV_W_B2 "Log of Pre- Emails Received from Trained"
  ); 

#d cr 	
	*/
	*** 1st table: Full sample
  * Output table
esttab using "$tabfolder/Table_Regression_comparison_simple.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccc} \\ \hline ") /// 
posthead(" & \multicolumn{4}{c}{Income} \\ \cline{2-5} & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small} \\ \hline   &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")


***** Panel B
preserve
keep if period >= 657

eststo clear

sort DPTO period
xtset DPTO period


* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 4: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 5	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
	estimates store coefs
	estimates store est_`var'
* panel B
esttab using "$tabfolder/Table_Regression_comparison_simple", append ///
stats (N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline   &  &  &  &  \\ \textbf{Panel B: Sub sample from October 2014} \\ & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{5}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1}" "\end{tabular}")	



/////////////////////////////////////////////////
/////////////// Two tables in one ///////////////
/////////////////////////////////////////////////

use "$data/Database_full.dta", clear


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
label var log_EstimateProductionHa "Log Estimated Coca Production based on Quinoa"
label var ENSO "ENSO index"
label var log_only_cocaine_related "Log Number of deaths (US) caused only by cocaine"
label var log_only_fentanyl_related "Log Number of deaths (US) caused only by fentanyl"



eststo clear

sort DPTO period
xtset DPTO period



** Table
* Simple
* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related  , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO)
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 4: small	
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

	* Complete
* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID, abs(DPTO Month) nocons vce(cluster DPTO) 
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

	*** 1st table: Full sample
  * Output table
esttab using "$tabfolder/Table_Regression_comparison_full.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccccccc} \\ \hline ") /// 
posthead(" & \multicolumn{8}{c}{Income} \\ \cline{2-5} \cline{6-9}   & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small} & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small} \\ \hline  & & & & &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")


  * Output table
esttab using "$tabfolder/Table_Regression_comparison_full_compact.tex", replace f  ///
stats(N r2 SFE MFE, fmt(0 3)  labels("Observations" "R-squared" "State F.E." "Month F.E.")) keep(log_only_fentanyl_related ) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) nocons nomtitle ///
label booktab  ///
prehead("\begin{tabular}{lcccccccc} \\ \hline ") /// 
posthead(" & \multicolumn{8}{c}{Income} \\ \cline{2-5} \cline{6-9} & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small}  & Survey  &  \multicolumn{1}{c}{Big} & \multicolumn{1}{c}{Medium}& \multicolumn{1}{c}{Small} \\ \hline  & & & & &  &  &  &  \\ \textbf{Panel A: Full sample} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("")
restore
***** Panel B
preserve
keep if period >= 657

eststo clear

sort DPTO period
xtset DPTO period

	* Col 1
eststo: reghdfe log_real_income log_only_fentanyl_related log_only_cocaine_related  , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 2: big
eststo: reghdfe avg_monthly_light_big log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"

* Col 3: med
eststo: reghdfe avg_monthly_light_medium log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"
		
* Col 4: small
eststo: reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related , abs(DPTO Month) nocons vce(cluster DPTO) 
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
esttab using "$tabfolder/Table_Regression_comparison_full", append ///
stats (N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline  & & & & &  &  &  &  \\ \textbf{Panel B: Sub sample from October 2014} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{9}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1}" "\end{tabular}")	



esttab using "$tabfolder/Table_Regression_comparison_full_compact", append ///
stats (N r2 SFE MFE, fmt(0 3) labels("Observations" "R-squared" "State F.E." "Month F.E.")) b(%9.3f) keep(log_only_fentanyl_related ) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) se nocons nomtitle nonumber ///
label booktab ///
prehead("") ///
posthead(" \hline  & & & & &  &  &  &  \\ \textbf{Panel B: Sub sample from October 2014} \\ & & & & & & & & \\") ///
prefoot("\arrayrulecolor{black!10}\midrule") ///
postfoot("\arrayrulecolor{black}\bottomrule" "\multicolumn{9}{c}{*** p$<$0.01, ** p$<$0.05, * p$<$0.1}" "\end{tabular}")

restore
		  
gen treatment = (period >= 657)	  
gen treat_effect_fent = treatment*log_only_fentanyl_related
gen treat_effect_coca = treatment*log_only_cocaine_related
		  
reghdfe avg_monthly_light_small treat_effect_fent treat_effect_coca, abs(DPTO Month) nocons vce(cluster DPTO) 	

reghdfe avg_monthly_light_small treat_effect_fent treat_effect_coca CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 		

  	  
		  
reghdfe avg_monthly_light_small log_only_fentanyl_related log_only_cocaine_related CPI Participation_rate log_Exchange_rate  log_EstimateProductionHa ENSO ISE COVID , abs(DPTO Month) nocons vce(cluster DPTO) 
	estadd local SFE "$\checkmark$"
	estadd local MFE "$\checkmark$"		  