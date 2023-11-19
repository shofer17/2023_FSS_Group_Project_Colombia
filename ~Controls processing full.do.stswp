/*
Controls

Monthly National Economic Indicator
Capital CPI
Exchange Rate


*/

* 1. Oceanice ENSO index
import delimited "C:\Users\juanf\Downloads\ENSO_oceanic_index.txt", delimiter(space, collapse) clear

drop v1

encode seas, gen(date)
summ date

gen month = date
replace month = 1 if date == 3 // DJF is january, not march
replace month = 2 if date == 6 // JFM is february, not june
replace month = 3 if date == 4 // FMA is march, not april
replace month = 4 if date == 8 // MAM is april, not august
replace month = 5 if date == 1 // AMJ is may, not january
replace month = 6 if date == 9 // MJJ is june, not september
replace month = 8 if date == 5 // JAS is August, not may
replace month = 9 if date == 2 // ASO is september, not february
replace month = 10 if date == 12 // SON is october, not december
replace month = 12 if date == 10 // SON is december, not october

gen period = ym(yr, month)

drop if yr < 2010

keep period yr month total anom
format %tm period

rename anom ENSO
keep ENSO period
*xtset DPTO period

save "$data/ENSO_full.dta", replace


* other controls
*  2. Labor variables

import excel "$folder\TDD 2010-2023.xlsx", firstrow clear
destring *, replace
encode Mes, gen(date)
replace date = date[_n-1] if date ==.
gen month = date
replace month = 1 if date == 4 // DJF is january, not march
replace month = 2 if date == 6 // JFM is february, not june
replace month = 3 if date == 9 // FMA is march, not april
replace month = 4 if date == 1 // april
replace month = 5 if date == 10 // AMJ is may, not january
replace month = 6 if date == 8 // MJJ is june, not september
*replace month = 7 if date == 6
replace month = 8 if date == 2 // JAS is August, not may
replace month = 9 if date == 13 // ASO is september, not february
replace month = 10 if date == 12 // SON is october, not december
replace month = 11 if date == 11
replace month = 12 if date == 3 
replace month = 1 if date == 5

encode Clase, gen(Class)

gen per = ym(Año, month)
encode Departamentos, gen(DPTOS)

gen test = DPTOS +0
gen DPTO = .
replace DPTO = 5 if DPTOS == 1
replace DPTO = 13 if DPTOS == 4
replace DPTO = 18 if DPTOS == 7
replace DPTO = 19 if DPTOS == 8
replace DPTO = 23 if DPTOS == 12
replace DPTO = 27 if DPTOS == 9
replace DPTO = 52 if DPTOS == 17
replace DPTO = 54 if DPTOS == 18

drop if DPTO != 5 & DPTO != 13 & DPTO != 18 & DPTO != 19 & DPTO != 23 & DPTO != 27 & DPTO != 52 & DPTO != 54 & DPTO != 4 & DPTOS != . 

drop Mes Clase Departamentos test date
keep if Class == 1
rename per period
rename inglabo Avg_rural_income_nominal
format %tm period
sort period DPTO

* Bolívar outlier?
summ Avg_rural_income_nominal if DPTO == 13
replace Avg_rural_income_nominal = . if DPTO == 13 & Avg_rural_income_nominal >= 3148132
summ Avg_rural_income_nominal if DPTO == 13
scalar mean_bol = r(mean)
replace Avg_rural_income_nominal = mean_bol if INGLABO == .

save "$data/Laboral_income_data_full.dta", replace

/*
***********
twoway (connected Avg_rural_income_nominal period if DPTO == 52, mcolor(black) lcolor(black%60) msize(small) msymbol(Dh) lpattern(shortdash) mlc(black) ///
mfc(none) xtitle("Time", height(6) axis(2)))   ////
(connected Avg_rural_income_nominal period if  DPTO == 54, mcolor(blue) ///
lcolor(blue%60) msize(small) msymbol(Oh) lpattern(shortdash) mlc(blue) mfc(none)  ///
xaxis(1 2) xline(757 13, lcolor(black) lpattern(dash) lwidth(medthin)) xlabel(757 "Fentanyl?", labsize(med))) ///
(connected Avg_rural_income_nominal period if DPTO == 19, ///
mcolor(red) lcolor(red%60) msize(small) msymbol(Sh) lpattern(shortdash) mlc(red) mfc(none)) ///
(connected Avg_rural_income_nominal period if DPTO == 5, ///
mcolor(green) lcolor(green%60) msize(small) msymbol(Dh) lpattern(shortdash) mlc(green) mfc(none)) ///
(connected Avg_rural_income_nominal period if DPTO == 13, ///
mcolor(lavender) lcolor(lavender%60) msize(small) msymbol(Dh) lpattern(dash) mlc(lavender) mfc(none)) ///
(connected Avg_rural_income_nominal period if DPTO == 23, ///
mcolor(olive_teal) lcolor(olive_teal%90) msize(small) msymbol(Dh) lpattern(shortdash) mlc(olive_teal) mfc(none)) ///
(connected Avg_rural_income_nominal period if DPTO == 18, ///
mcolor(orange) lcolor(orange%60) msize(small) msymbol(Sh) lpattern(shortdash) mlc(orange) mfc(none)) ///
(connected Avg_rural_income_nominal period if DPTO == 23, ///
mcolor(purple) lcolor(purple%60) msize(small) msymbol(Dh) lpattern(dash) mlc(purple) mfc(none)) ///
, ///
legend(order(1 "Nariño" 2 "Norte de Santander" 3 "Cauca" 4 "Antioquia" 5 "Bolívar" 6 "Córdoba" 7 "Caquetá" 8 "Chocó")size(small) rows(2) pos(6) region(c(none))) graphregion(color(white)) bgcolor(white) ///
xlabel(,valuelabel labsize(medsmall) angle(horizontal)) ytitle("Average Rural Household Income (COP)", size(small) height(6)) xtitle("") ///
plotregion(margin(none))


*2010-2020
import excel "$folder\TD departamental pre.xlsx", firstrow clear
destring *, replace
encode Mes, gen(date)
replace date = date[_n-1] if date ==.
gen month = date
replace month = 1 if date == 4 // DJF is january, not march
replace month = 2 if date == 5 // JFM is february, not june
replace month = 3 if date == 8 // FMA is march, not april
replace month = 4 if date == 1 // april
replace month = 5 if date == 9 // AMJ is may, not january
replace month = 6 if date == 7 // MJJ is june, not september
replace month = 7 if date == 6
replace month = 8 if date == 2 // JAS is August, not may
replace month = 9 if date == 12 // ASO is september, not february
replace month = 10 if date == 11 // SON is october, not december
replace month = 11 if date == 10
replace month = 12 if date == 3 // SON is december, not october

* drop total
drop if month == 13
encode Clase, gen(Class)
drop if Class == 3

gen per = ym(Año, month)
encode Departamentos, gen(DPTOS)
/*replace DPTOS =. if DPTOS < 54
replace DPTOS = DPTOS[_n-1] if DPTOS ==.*/
gen test = DPTOS +0
gen DPTO = .
replace DPTO = 5 if DPTOS == 1
replace DPTO = 13 if DPTOS == 4
replace DPTO = 18 if DPTOS == 7
replace DPTO = 19 if DPTOS == 8
replace DPTO = 23 if DPTOS == 12
replace DPTO = 27 if DPTOS == 10
replace DPTO = 52 if DPTOS == 17
replace DPTO = 54 if DPTOS == 18


drop if DPTO != 5 & DPTO != 13 & DPTO != 18 & DPTO != 19 & DPTO != 23 & DPTO != 27 & DPTO != 52 & DPTO != 4 & DPTOS != . 

drop Mes Clase Departamentos test date
keep if Class == 1
rename per period
rename Promediodeinglabo Avg_rural_income_nominal
format %tm period
sort period DPTO

preserve 
keep DPTO period Avg_rural_income_nominal 
save "$data/income_data_pre.dta", replace
restore

save "$data/Laboral_data_processed_pre.dta", replace

***

import excel "$folder\TD departamental.xlsx", firstrow clear
destring *, replace
encode Mes, gen(date)
replace date = date[_n-1] if date ==.
gen month = date
replace month = 1 if date == 4 // DJF is january, not march
replace month = 2 if date == 5 // JFM is february, not june
replace month = 3 if date == 8 // FMA is march, not april
replace month = 4 if date == 1 // april
replace month = 5 if date == 9 // AMJ is may, not january
replace month = 6 if date == 7 // MJJ is june, not september
replace month = 7 if date == 6
replace month = 8 if date == 2 // JAS is August, not may
replace month = 9 if date == 12 // ASO is september, not february
replace month = 10 if date == 11 // SON is october, not december
replace month = 11 if date == 10
replace month = 12 if date == 3 // SON is december, not october

encode Clase, gen(Class)

gen per = ym(Año, month)
encode Departamentos, gen(DPTOS)
replace DPTOS =. if DPTOS < 54
replace DPTOS = DPTOS[_n-1] if DPTOS ==.
gen test = DPTOS +0
gen DPTO = .


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
replace DPTO = 5 if DPTOS == 54
replace DPTO = 13 if DPTOS == 56
replace DPTO = 18 if DPTOS == 59
replace DPTO = 19 if DPTOS == 60
replace DPTO = 23 if DPTOS == 64
replace DPTO = 27 if DPTOS == 61
replace DPTO = 52 if DPTOS == 69
replace DPTO = 54 if DPTOS == 70




drop if DPTO != 5 & DPTO != 13 & DPTO != 18 & DPTO != 19 & DPTO != 23 & DPTO != 27 & DPTO != 52 & DPTO != 4 & DPTOS != . 

drop Mes Clase Departamentos test date
keep if Class == 1
rename per period
format %tm period
sort period DPTO

* Put the income variable so it can match in the full dataset
merge 1:1 period DPTO using "$data/Real_income_to_seasonal_adjust.dta"

save "$data/Laboral_data_processed.dta", replace
* merging the two laboral datasets

use "$data/Laboral_data_processed_pre", replace
append
*/
************ 3. CPI data
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
import excel "$folder\Inflation.xlsx", sheet("Inflation(year-city)") firstrow clear
destring *, replace
encode State, gen(DPTOS)
gen test = DPTOS +0
gen DPTO =.
replace DPTO = 5 if DPTOS == 1
replace DPTO = 13 if DPTOS == 2
replace DPTO = 18 if DPTOS == 3
replace DPTO = 19 if DPTOS == 4
replace DPTO = 23 if DPTOS == 5
replace DPTO = 52 if DPTOS == 6
replace DPTO = 54 if DPTOS == 7
replace DPTO = 86 if DPTOS == 8
* Chocó and Guaviare are missing, judging the data, we should take the same values that we used for Putumayo as they are both in the "Other regions" section

* Compute the average for each period
bys date: egen average_cpi = mean(Inflationbase2018100)

summarize DPTO
scalar size = r(N)/6
display size

forvalues k= 1/107 {
insobs 3, after(7*`k' + 3*`k' -3)
}

/*
forvalues k= 76/145 {	
insobs 2, after(8*`k' + 2*`k' -3)
}*/

forvalues k= 108/145 {
insobs 2, after(8*`k' + 2*`k' -2)
}

* fill up variables
replace DPTO = DPTO[_n-1] +1 if DPTO == .

* pre 2018
replace DPTO = 27 if DPTO == 21 | DPTO == 87
replace DPTO = 95 if DPTO == 22 | DPTO == 88
replace DPTO = 86 if DPTO == 20

replace Inflationbase2018100 = average_cpi[_n-3] if DPTO == 27 | DPTO == 95 | DPTO == 86 & year[_n-3] <= 2018

replace Inflationbase2018100 = average_cpi[_n-3] if DPTO == 27 | DPTO == 95 & year[_n-3] >= 2019
/*
replace DPTO = 27 if DPTO == 14 | DPTO == 6 | DPTO == 55  | DPTO == 24 | DPTO == 53 | (DPTO == 20 & DPTO[_n-1] == 19) | (DPTO == 19 & test== .) | DPTO == 87

replace DPTO = 95 if DPTO == 15 | DPTO == 7 | DPTO == 56 | DPTO == 20 | DPTO == 25 | DPTO == 54 | DPTO == 21 | DPTO == 56 | DPTO == 25 | DPTO == 54 | (DPTO == 20 & DPTO[_n+1] == 23) | DPTO == 88 */
*replace Inflationbase2018100 = Inflationbase2018100[_n-1] if DPTOS ==.
replace MonthNumber = MonthNumber[_n-1] if DPTOS ==.
replace year = year[_n-1] if DPTOS ==.

* define period
gen period = ym(year, MonthNumber)

* keep important variabless
keep period Inflationbase2018100 DPTO
rename Inflationbase2018100 CPI
* probably this time series need seasonal adjustment
format %tm period

*xtset DPTO period 


* Use national values for pre 2018


*tsfill

save "$data/inflation_intermediate_full.dta", replace

**** 4. Coca plantation estimate
import excel "$folder\Coca-Monthly2010-2022.xlsx",  firstrow clear
destring *, replace
encode Dpto, gen(DPTOS)
gen test = DPTOS +0
gen DPTO =.
replace DPTO = 5 if DPTOS == 1
replace DPTO = 13 if DPTOS == 2
replace DPTO = 18 if DPTOS == 3
replace DPTO = 19 if DPTOS == 4
replace DPTO = 23 if DPTOS == 5
replace DPTO = 52 if DPTOS == 6
replace DPTO = 54 if DPTOS == 7
replace DPTO = 86 if DPTOS == 8 

* define period
gen period = ym(Year, Month)

rename Value EstimateProductionHa
* keep important variabless
keep period EstimateProductionHa DPTO Year Month

* probably this time series need seasonal adjustment
format %tm period

save "$data/EstimateProductionHa_full.dta", replace

******** 5. Light intensity data
import excel "$folder\data_clean\nl_states_new.xlsx", sheet("Sheet1") firstrow clear
destring *, replace
*rename date_r period


*format %tm period // period not working in the same format

encode states, gen(DPTOS)
gen test = DPTOS +0
gen DPTO =.
replace DPTO = 5 if DPTOS == 1
replace DPTO = 13 if DPTOS == 2
replace DPTO = 18 if DPTOS == 3
replace DPTO = 19 if DPTOS == 4
replace DPTO = 23 if DPTOS == 5
replace DPTO = 52 if DPTOS == 6
replace DPTO = 54 if DPTOS == 7
replace DPTO = 86 if DPTOS == 8 

rename value_mean avg_monthly_light_intensity
rename value_band_low avg_monthly_light_small
rename value_band_mid avg_monthly_light_medium
rename value_band_higher avg_monthly_light_big
keep year month avg_monthly_light_* DPTO 

*gen month = month(period)
*gen year = year(period)
gen period = ym(year, month)
*drop period
*rename perio period
keep period avg_monthly_light_* DPTO 
sort DPTO period
format %tm period
save "$data/light_data_full.dta", replace


******** 6. ISE data (already seasonal adjusted by the national statistic office)
import excel "$folder\anex-ISE-12actividades-sep2023_full.xlsx", sheet("Hoja1") firstrow clear
gen period = ym(year, month)
format %tm period
drop year month
save "$data/ISE_full.dta", replace


********* 7. Exchange rate
import excel "$folder\TRM.xlsx", firstrow clear

gen period = ym(Year, Month)
format %tm period

rename Promediomensual Exchange_rate

keep period Exchange_rate

save "$data/Exchange_rate_full.dta", replace


********* 8. US seizure data
use "$data_clean\seized_by_drug.dta", clear

destring *, replace

gen period = ym(year, month_num)
format %tm period
sort period
encode drug, gen(drug_type)
keep kg period drug_type

bys period: egen total_kg = sum(kg)
gen ratio_fent = kg/total_kg if drug_type ==  2
gen ratio_cocaine = kg/total_kg if drug_type == 1
gen fent_kg = kg if drug_type ==  2
gen cocaine_kg = kg if drug_type ==  1

collapse (max) ratio* fent_kg cocaine_kg, by(period)

save "$data/seizure.dta", replace

*** 9. US Mortality 
import excel "$data_clean\mortality_cocaine_fentanyl.xlsx", sheet("Sheet1") firstrow clear

gen period = ym(year, monthdth)
format %tm period
sort period
   
twoway (connected  only_fentanyl_related period) (connected  cocain_related_deaths period) (connected  only_cocaine_related period)  (connected  fentanyl_related_deaths period) 
drop year
drop monthdth
save "$data/US_deaths_full.dta", replace
**** Compile database withouth Seasonal Adjustment

*** State monthly data
* Avg Rural Household Income
* Monthly inflation
* Laboral market variables
* Coca plantation estimate
* Light Intensity

*** National monthly data
* ENSO
* Economic Performance Index
* Exchange Rate

*** US data (works as national monthly data in the sense there is no state-variation)
/*
* 1. Avg Rural Household (nominal)
use "$data/income_data_pre.dta", clear
xtset DPTO period
tsfill
append using  "$data/nominal_income_post.dta"
*use "$data/Real_income_to_seasonal_adjust.dta", clear

collapse (mean) Avg_rural_income_nominal INGLABO, by(period DPTO)

gen nominal_income = (Avg_rural_income_nominal + INGLABO)/2 


keep INGLABO period DPTO

* plot to see differences
twoway (connected  Avg_rural_income_nominal period if period >720 & period <= 740, by(DPTO)) (connected  INGLABO period if period >720 & period <= 740, by(DPTO) legend(order(1 "Pre" 2 "Post" )size(small) rows(2) pos(6) region(c(none))))

rename INGLABO Avg_rural_income_nominal

append using 
* Avg Rural pre 2010-2020
*/
** 1. number of seizures
use "$data_clean\seized_by_drug_eventnum.dta", clear

destring *, replace

gen period = ym(year, month)
sort period
format %tm period

encode drug, gen(drug_type)
keep events period drug_type

bys period: egen total_events = sum(events)
gen ratio_fent_event = event/total_events if drug_type ==  2
gen ratio_cocaine_event = event/total_events if drug_type == 1
gen fent_event = events if drug_type ==  2
gen cocaine_event = events if drug_type ==  1

collapse (max) ratio* fent_event cocaine_event, by(period)

save "$data/seizure_events.dta", replace




* 1. Laboral and income data
use "$data/Laboral_income_data_full.dta", clear

* 2. Monthly inflation
merge m:m period DPTO using "$data/inflation_intermediate_full.dta"
drop _merge

*use "$data/inflation_intermediate_full.dta", clear

* 3. Laboral market variables
merge m:m period DPTO using "$data/Laboral_data_processed"

sort DPTO period

drop Año month Class DPTOS _merge
*drop Class DPTOS _merge

* 4. Coca plantation estimate

merge m:m period DPTO using "$data/EstimateProductionHa_full.dta"
drop _merge

* 5. Light intensity

merge m:m period DPTO using "$data/light_data_full.dta"
drop _merge

* 6. (natinoal) ENSO
merge m:1 period using "$data/ENSO_full.dta"
drop _merge

* 7. (national) ISE
merge m:1 period using "$data/ISE_full.dta"
drop _merge

* 8. (national) Exchange Rate
merge m:1 period using "$data/Exchange_rate_full.dta"
drop _merge

* 9. (US) Seizures
merge m:1 period using "$data/seizure.dta"
drop _merge


* 10. (US) deaths
merge m:1 period using "$data/US_deaths_full.dta"
drop _merge 

* 11. (US) number of seizures
merge m:1 period using "$data/seizure_events.dta"
drop _merge

* create year and month
xtset DPTO period
format %tm period

sort Year Month

replace Year = Year[_n-1] if Year ==.
replace Year = 2023 if period >= 756
sort period
replace Month = Month[_n-1] if Month ==.
replace Month = . if Year == 2023
* Change names
rename Ocupados Employed
rename Noocupados Non_employed
rename Desocupados Unemployed
rename Inactivos Inactives
rename PEA EAP
rename TD Unemployment_rate
rename TGP Participation_rate
rename TO Occupied_rate


* label variables
label var DPTO "State (number)"
label var period "Period (month x year)"
label var Avg_rural_income_nominal "Average Rural Household Income (nominal non SA)"
label var CPI "State CPI"
label var Employed "Employed Population"
label var Non_employed "Population not seeking for job"
label var Unemployed "Unemployede population"
label var EAP "Economic Active Population"
label var PET "Population in labor age"
label var Unemployment_rate "Unemployment rate"
label var Participation_rate "Participation rate"
label var EstimateProductionHa "Estimated Coca Production based on Quinoa"
label var avg_monthly_light_intensity "Average Monthly Night Light Intensity"
label var avg_monthly_light_small "Average Monthly Night Light Intensity for Small Villages"
label var avg_monthly_light_medium "Average Monthly Night Light Intensity for Medium-size Villages"
label var avg_monthly_light_big "Average Monthly Night Light Intensity for Big-size Villages (cities)"
label var ISE "Economic Performance Index"
label var ratio_fent "Ratio of Fentanyl seizures over the sum of cocaine and fentanyl seizures"
label var ratio_cocaine "Ratio of Cocaine seizures over the sum of cocaine and fentanyl seizures"
label var fent_kg "Amount of Fentanyle seized in kilograms"
label var cocaine_kg "Amount of Cocaine seized in kilograms"
label var only_fentanyl_related "Number of deaths (US) caused only by fentanyl"
label var cocain_related_deaths "Number of deaths (US) caused, among others, by fentanyl"
label var only_cocaine_related "Number of deaths (US) caused only by cocaine"
label var fentanyl_related_deaths"Number of deaths (US) caused, among others, by fentanyl"



save "$data/Database_full.dta", replace
* Export variables to R for seasonal adjustment