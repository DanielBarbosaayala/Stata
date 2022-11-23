*Federico Meneses Serrato-201228081
clear all
cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Taller 3\" 
use "geih_2014_2016_vf", replace 
gen elvl = 1 if esc == 0

replace elvl = 2 if esc>=1 & esc<=5

replace elvl = 3 if esc>=6 & esc<=11

replace elvl = 4 if esc>=12 & esc<=16

replace elvl = 5 if esc>=17 & esc<=26


label define lb_ano_es 1 "Sin escolaridad" 2 "Primaria" 3 "Secundaria" 4 "Universidad" 5 "Posgrado"

label val elvl lb_ano_es

gen PEA = 1 if dsi==1 | oci==1

*egen long PEA = count(pea)


*gen pob = 1

label drop dsi dsi
label drop oci oci
replace dsi = fe if dsi == 1
replace oci = fe if oci == 1 

*** aqui empieza mi parte improvisada
//
// label drop p6020 p6020
//
// drop if p6020 == 1
//
// gen PEA = 1
//
// replace PEA = oci if oci !=.
//
// replace PEA = dsi if dsi !=.
//
// drop if PEA == 1
//
// collapse (sum) dsi oci [aweight=fe] ,by (p6020 elvl ) 
//
//

***aqui termina mi parte improvisada
replace PEA = dsi if dsi != .
replace PEA = oci if oci != .

drop if PEA == . 
drop if elvl == .
drop if p6020 == 1
egen PEA_RM = sum(PEA) 
collapse (sum) dsi oci [aweight=fe] ,by (p6020 elvl) 
*(mean) inglabo [aweight=fe], by (p6020 elvl) 
scalar PEA_R = 3.54e+07
scalar PEA_RM = 1.66e+07
drop if elvl == .
gen TD = dsi/PEA_RM 
*drop TD
replace TD = TD*100
graph bar (mean) TD , over (p6020) over (elvl) /// 
title(Tasa de desempleo) /// 
subtitle(2014-2016. GEIH) ///
ytitle (Porcentaje (%)) ///
ylabel(0(5)15) ///
note(Fuente: Gran Encuesta Integrada de Hogares) ///
name(hello_world)



*PEA = dsi + oci 
*TD: dsi / (PEA) 
***Ingreso laborarl prmedio















