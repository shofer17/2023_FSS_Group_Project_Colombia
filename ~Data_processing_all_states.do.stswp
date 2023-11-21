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
* Other states
replace DPTO = 11 if DPTOS == 2 // Atlántico
replace DPTO = 15 if DPTOS == 5 // Boyacá
replace DPTO = 17 if DPTOS == 6 // Caldas
replace DPTO = 20 if DPTOS == 11 // Cesar
replace DPTO = 41 if DPTOS == 13 // Huila
replace DPTO = 44 if DPTOS == 14 // La guajira
replace DPTO = 47 if DPTOS == 15 // Magdalena
replace DPTO = 50 if DPTOS == 16 // Meta
replace DPTO = 63 if DPTOS == 19 // Quindío
replace DPTO = 66 if DPTOS == 20 // Risaralda
replace DPTO = 68 if DPTOS == 21 // Santander
replace DPTO = 70 if DPTOS == 22 // Sucre
replace DPTO = 73 if DPTOS == 23 // Tolima
replace DPTO = 76 if DPTOS == 24 // Valle del cauca
replace DPTO = 11 if DPTOS == 3 // Bogotá

drop if DPTO != 5 & DPTO != 13 & DPTO != 18 & DPTO != 19 & DPTO != 23 & DPTO != 27 & DPTO != 52 & DPTO != 54 & DPTO != 11 & DPTO != 15 & DPTO != 17 & DPTO != 20 & DPTO != 41 & DPTO != 44 & DPTO != 47 & DPTO != 50 & DPTO != 63 & DPTO != 66 & DPTO != 68 & DPTO != 70 & DPTO != 73 & DPTO != 76 & DPTO != 11 & DPTOS != . 


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
replace Avg_rural_income_nominal = mean_bol if Avg_rural_income_nominal == .

save "$data/Laboral_income_data_full_all_states.dta", replace


//////////////////////////////////////////

* 1. Laboral and income data
use "$data/Laboral_income_data_full_all_states.dta", clear

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

* test
egen test = group(period DPTO)
drop if test ==.
duplicates list test
*br if test == 94
drop if (test == 94 & Ocupados < 80000)
drop if (test == 375 & Ocupados < 80000)
drop if (test == 656 & Ocupados < 80000)
drop if (test == 937 & Ocupados < 80000)
drop if (test == 1218 & Ocupados < 80000)
drop if (test == 1499 & Ocupados < 80000)
drop if (test == 1780 & Ocupados < 80000)
drop if (test == 2061 & Ocupados < 80000)
drop if (test == 2342 & Ocupados < 80000)
drop if (test == 2623 & Ocupados < 80000)
drop if (test == 2904 & Ocupados < 80000)
sort Year Month
format %tm period
xtset DPTO period

drop test


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
label var fentanyl_related_deaths "Number of deaths (US) caused, among others, by fentanyl"



save "$data/Database_full_all_states.dta", replace