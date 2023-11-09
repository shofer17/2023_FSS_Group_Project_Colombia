/*
GEIH
Survey data

*/


/*
--------------------- General characteristics -------------------------
dataset name: Características generales, seguridad social en salud y educación.DTA
PER: year
Mes: month
DIRECTORIO: ID
DPTO: State (we are interested in Caquetá, Cauca and Norte de Santander)
CLASE: 1 if Urban 2 if Rural (we are interested in rural)
V3999 P2057: ¿Usted se considera campesino(a)? Do you consider yourself as a peasan?
V4001 P2061: ¿Usted considera que alguna vez fue campesino(a)? Do you consider that you have once been a peasant?
V4050 P3039: ¿Usted se reconoce como? Do you consider yourself: 1 Man 2 Woman 3 Trans Man 4 Trans woman 5 Other
V4058 Campesina ??


-------------------------- Employment data ------------------------------
dataset name: Ocupados.DTA
PER: year
Mes: month
DIRECTORIO: ID
V4097 P6500 Antes de descuentos ¿cuánto ganó ... El mes pasado en este empleo? 
			Before discounts how much did you earn in this employment last month?
V4155 P3051 Antes de descuentos, ¿Cuánto recibió ... el mes pasado por concepto de honorarios profesionales?
			Before discounts how much did you earn under the concept of professional fees?
V4163 P3052 Antes de descuentos, ¿Cuánto recibió ... el mes pasado por concepto de ingresos o comisiones?
			Before discounts how much did you earn under the concept of income or commissions?
V4171 P3053 ¿ A cuántos meses corresponde lo que recibió?
			how many months does what you received correspond?
V4190 P3058S1 Salarios u honorarios
				Wages and fees
V4268 P6750 ¿cuál fue la ganancia neta o los honorarios netos de ... Esa actividad, negocio, profesión o finca, el mes pasado?
			What was the net profit or the net fees of... that activity, business, profession or property, the past month?
V4269 P3073 ¿A cuántos meses corresponde lo que recibió?
			how many months does what you received correspond?
V4353 OCI Población ocupada Ocupied population
V4354 INGLABO Ingresos laborales laboral income
V4355 RAMA2D_R4 ¿A qué actividad se dedica principalmente la empresa o negocio en la que…… realiza su trabajo?
				What activity are you dedicated to? mainly the company or
business in which...... carries out his work?
V4356 RAMA4D_R4 Rama de Actividad según la CIIU revisión 4 adaptada para Colombia


------------------- Laboral force ------------------
dataset name: Fuerza de trabajo.DTA
PER: year
Mes: month
DIRECTORIO: ID

--------------------- Non occupied -----------------

-------------------- Other types of work -----------

----------------------- Migration ------------------

--------------- Household and house data -----------

----------------- Other income and taxes -----------



Based on this, I consider that the best income proxy is Occupied >> 

V4097 P6500 Antes de descuentos ¿cuánto ganó ... El mes pasado en este empleo? 
			Before discounts how much did you earn in this employment last month?

V4163 P3052 Antes de descuentos, ¿Cuánto recibió ... el mes pasado por concepto de ingresos o comisiones?
			Before discounts how much did you earn under the concept of income or commissions?
V4171 P3053 ¿ A cuántos meses corresponde lo que recibió?
			how many months does what you received correspond?
** V4190 P3058S1 Salarios u honorarios **
				Wages and fees
V4268 P6750 ¿cuál fue la ganancia neta o los honorarios netos de ... Esa actividad, negocio, profesión o finca, el mes pasado?

V4097 P6500: Formal income from a job (probably legal)
V4163 P3052: Income and comissions
V4171 P3053: months >> P3052/P3053 = monthly income and comissions

*/

use "C:\Users\juanf\Downloads\Agosto\Agosto\DAT\DAT\Características generales, seguridad social en salud y educación.DTA", clear

destring *, replace

use "C:\Users\juanf\Downloads\Agosto\Agosto\DAT\DAT\Ocupados.DTA", clear

destring *, replace



keep if DPTO == 18 | DPTO == 19 | DPTO == 54
keep if CLASE == 2

keep PER MES DIRECTORIO DPTO CLASE P6500 P3052 P3053 P3058S1 P6750 P6500 P3052 P3053 OCI INGLABO RAMA2D_R4 RAMA4D_R4 OFICIO_C8

foreach k of varlist P* {
	replace `k' = 0 if `k' ==.
}

* Is INGLABO the sum of all incomes?
drop suma
gen suma = P6500+(P3052)+P3058S1+P6750
summ suma
summ INGLABO
tab suma INGLABO

* INGLABO compiles all the incomes, first I will work with this
/* 2 approaches, drop if INGLABO == . (non occupied people I would say)
or replacing it with 0 equals and the mean will go down.
First I'll try the first approach first

*/

use "C:\Users\juanf\Downloads\Agosto\Agosto\DAT\DAT\Ocupados.DTA", clear

destring *, replace

keep if DPTO == 18 | DPTO == 19 | DPTO == 54
keep if CLASE == 2
* Just keep INGLABO
keep PER MES DIRECTORIO DPTO CLASE INGLABO RAMA2D_R4 RAMA4D_R4 OFICIO_C8
* Maybe we can try to filter by CIIU
collapse (mean) INGLABO, by(DPTO PER MES)

*It seems to work, let's loop!

global data "C:\Users\juanf\Documents\FSS\Data_processing"


/*
Nariño = 52
Putumayo = NA
Norte de Santander = 54
Cauca = 19
Antioquia = 05
Bolívar = 13
Córdoba = 23
Caquetá = 18
Chocó = 27
Guaviare = NA
*/


forvalues k = 2020/2023 {
	
	forvalues i = 1/12 {
		
		use "$data\Ocupados_`k'_`i'.dta", clear
	
	destring *, replace

keep if DPTO == 52 | DPTO == 54 | DPTO == 19 | DPTO == 5 | DPTO == 13 | DPTO == 23 | DPTO == 18 | DPTO == 27
keep if CLASE == 2 // Rural households

collapse (mean) INGLABO, by(DPTO PER MES)


save "$data\Proc_`k'_`i'.dta", replace
	
	
	}
	

	
}

* First we need to fix some data (the month identifier is not working for some 2022 months)
forvalues i = 2020/2022{
	

forvalues k = 1/12 {
	use "$data/Proc_`i'_`k'", clear
	replace MES = `k'
	save "$data/Proc_`i'_`k'", replace
}

}

* merge the data
clear all

forvalues k = 2020/2023 {
	forvalues i = 1/12 {
	*use "$data\Proc_2022_1.dta", clear
	append using "$data\Proc_`k'_`i'.dta"
	}
}
* special case 2020
replace PER = 2020 if PER ==.
drop PERIODO
/*
replace DPTO = 1 if DPTO == 18 // Caquetá
replace DPTO = 2 if DPTO == 19 // Cauca
replace DPTO = 3 if DPTO == 54 // Norte de Santander*/

/*
Nariño = 52
Putumayo = NA
Norte de Santander = 54
Cauca = 19
Antioquia = 05
Bolívar = 13
Córdoba = 23
Caquetá = 18
Chocó = 27
Guaviare = NA
*/

* Bolívar outlier?
summ INGLABO if DPTO == 13
replace INGLABO = . if DPTO == 13 & INGLABO >= 3148132
summ INGLABO if DPTO == 13
scalar mean_bol = r(mean)
replace INGLABO = mean_bol if INGLABO == .

gen period = ym(PER, MES)

* We need to seasonally adjust the time series

format %tm period

xtset DPTO period
tsfill

*Choco missing value for  2020-8 in rural households
summ INGLABO if DPTO == 27 & PER == 2020 & (MES == 7 | MES == 9)
scalar choco_miss = r(mean)

replace INGLABO = choco_miss if period == 727

*------- Merging the inflation data
* For now I'll use the national CPI, the alternative is to compute 7/8 capital cities CPI
preserve
import excel "$data\IPC.xlsx", sheet("Sheet1") cellrange(B13:F70) firstrow clear
destring *, replace
gen period = ym(Year, Month)
format %tm period
summ Index if Year == 2021 & Month == 1
scalar CPI_start = r(mean)
gen CPI_n = Index/CPI_start
keep CPI_n period
save "$data/CPI_merge.dta", replace
restore

merge m:1 period using "$data/CPI_merge.dta"
keep if _merge == 3

gen real_income = INGLABO/CPI_n

/*
twoway (connect  real_income period, by(DPTO))
summ period*/
twoway (connected real_income period if DPTO == 52, mcolor(black) lcolor(black%60) msize(small) msymbol(Dh) lpattern(shortdash) mlc(black) ///
mfc(none) xtitle("Time", height(6) axis(2)))   ////
(connected real_income period if  DPTO == 54, mcolor(blue) ///
lcolor(blue%60) msize(small) msymbol(Oh) lpattern(shortdash) mlc(blue) mfc(none)  ///
xaxis(1 2) xline(757 13, lcolor(black) lpattern(dash) lwidth(medthin)) xlabel(757 "Fentanyl?", labsize(med))) ///
(connected real_income period if DPTO == 19, ///
mcolor(red) lcolor(red%60) msize(small) msymbol(Sh) lpattern(shortdash) mlc(red) mfc(none)) ///
(connected real_income period if DPTO == 5, ///
mcolor(green) lcolor(green%60) msize(small) msymbol(Dh) lpattern(shortdash) mlc(green) mfc(none)) ///
(connected real_income period if DPTO == 13, ///
mcolor(lavender) lcolor(lavender%60) msize(small) msymbol(Dh) lpattern(dash) mlc(lavender) mfc(none)) ///
(connected real_income period if DPTO == 23, ///
mcolor(olive_teal) lcolor(olive_teal%90) msize(small) msymbol(Dh) lpattern(shortdash) mlc(olive_teal) mfc(none)) ///
(connected real_income period if DPTO == 18, ///
mcolor(orange) lcolor(orange%60) msize(small) msymbol(Sh) lpattern(shortdash) mlc(orange) mfc(none)) ///
(connected real_income period if DPTO == 23, ///
mcolor(purple) lcolor(purple%60) msize(small) msymbol(Dh) lpattern(dash) mlc(purple) mfc(none)) ///
, ///
legend(order(1 "Nariño" 2 "Norte de Santander" 3 "Cauca" 4 "Antioquia" 5 "Bolívar" 6 "Córdoba" 7 "Caquetá" 8 "Chocó")size(small) rows(2) pos(6) region(c(none))) graphregion(color(white)) bgcolor(white) ///
xlabel(,valuelabel labsize(medsmall) angle(horizontal)) ytitle("Average Rural Household Income (COP)", size(small) height(6)) xtitle("") ///
plotregion(margin(none))


* Export data to seasonal adjust it in R
save "$data/Real_income_to_seasonal_adjust.dta", replace


* Call R processed data
use "$data/real_income_SA.dta", clear
destring *, replace
gen period = ym(Year, Month)
format %tm period

rename value real_income



