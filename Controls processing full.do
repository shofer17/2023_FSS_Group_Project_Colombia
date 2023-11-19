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

save "$data/ENSO.dta", replace


* other controls
*  2. Labor variables
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
save "$data/Laboral_data_processed.dta", replace

************ 3. CPI data

import excel "$folder\Inflation.xlsx", sheet("Inflation(year-city)") firstrow clear
destring *, replace
encode state, gen(DPTOS)
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
summarize DPTO
scalar size = r(N)/8
display size
forvalues k= 1/48 {
	
insobs 2, after(8*`k' + 2*`k' -2)
	
}

* fill up variables
replace DPTO = DPTO[_n-1] +1 if DPTO == .
replace DPTO = 27 if DPTO == 87
replace DPTO = 95 if DPTO == 88
replace inflationwrttolastmonth = inflationwrttolastmonth[_n-1] if DPTOS ==.
replace monthnumber = monthnumber[_n-1] if DPTOS ==.
replace year = year[_n-1] if DPTOS ==.

* define period
gen period = ym(year, monthnumber)

* keep important variabless
keep period inflationwrttolastmonth DPTO
rename inflationwrttolastmonth monthly_inflation
* probably this time series need seasonal adjustment
format %tm period

save "$data/inflation_intermediate.dta", replace

**** 4. Coca plantation estimate
import excel "$folder\Coca_Month.xlsx", sheet("AllTogether") firstrow clear
destring *, replace
encode Departamento, gen(DPTOS)
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
gen period = ym(Year, MonthNumber)

* keep important variabless
keep period EstimateProductionHa DPTO Year MonthNumber

* probably this time series need seasonal adjustment
format %tm period

save "$data/EstimateProductionHa.dta", replace

******** 5. Light intensity data
import excel "$folder\data_clean\nl_states_adjusted.xlsx", sheet("Sheet1") firstrow clear

rename date_r period


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
keep period avg_monthly_light_* DPTO 

gen month = month(period)
gen year = year(period)
gen perio = ym(year, month)
drop period
rename perio period
keep period avg_monthly_light_* DPTO 
sort DPTO period
save "$data/light_data.dta", replace


******** 6. ISE data (already seasonal adjusted by the national statistic office)
import excel "$folder\anex-ISE-12actividades-sep2023.xlsx", sheet("Hoja1") firstrow clear

gen period = ym(year, month)
format %tm period
drop year month
save "$data/ISE.dta", replace


********* 7. Exchange rate
import excel "$folder\TRM.xlsx", firstrow clear

gen period = ym(Year, Month)
format %tm period

rename Promediomensual Exchange_rate

keep period Exchange_rate

save "$data/Exchange_rate.dta", replace


********* 8. US seizure data
use "$data_clean\seized_by_drug.dta", clear

destring *, replace

gen period = ym(year, month_num)
format %tm period

encode drug, gen(drug_type)
keep kg period drug_type

bys period: egen total_kg = sum(kg)
gen ratio_fent = kg/total_kg if drug_type ==  2
gen ratio_cocaine = kg/total_kg if drug_type == 1
gen fent_kg = kg if drug_type ==  2
gen cocaine_kg = kg if drug_type ==  1

collapse (max) ratio* fent_kg cocaine_kg, by(period)

save "$data/seizure.dta", replace

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

* 1. Avg Rural Household (nominal)
use "$data/Real_income_to_seasonal_adjust.dta", clear
keep INGLABO period DPTO
rename INGLABO Avg_rural_income_nominal

* 2. Monthly inflation
merge m:m period DPTO using "$data/inflation_intermediate.dta"
drop _merge

* 3. Laboral market variables
merge m:m period DPTO using "$data/Laboral_data_processed"

sort DPTO period

drop Año month Class DPTOS _merge
*drop Class DPTOS _merge

* 4. Coca plantation estimate

merge m:m period DPTO using "$data/EstimateProductionHa.dta"
drop _merge

* 5. Light intensity

merge m:m period DPTO using "$data/light_data.dta"
drop _merge

* 6. (natinoal) ENSO
merge m:1 period using "$data/ENSO.dta"
drop _merge

* 7. (national) ISE
merge m:1 period using "$data/ISE.dta"
drop _merge

* 8. (national) Exchange Rate
merge m:1 period using "$data/Exchange_rate.dta"
drop _merge

* 9. (US) Seizures
merge m:1 period using "$data/seizure.dta"
drop _merge

* create year and month
xtset DPTO period
format %tm period
rename MonthNumber Month
replace Year = Year[_n-1] if Year ==.
replace Month = Month[_n-1] if Month ==.
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
label var monthly_inflation "State monthly inflation"
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

save "$data/Database_full.dta", replace
* Export variables to R for seasonal adjustment