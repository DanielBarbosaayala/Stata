
**Ejercicio 9

* PUNTO 0

global dir "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 9\"


* PUNTO 1

use "${dir}Uchoques_2013_et", replace


* PUNTO 2

*foreach var of varlist id_hogar~hizo15{

*foreach var of varlist i* j* t* a* e* i* o* u*{

gen nombre = ""

gen descripcion = ""

set trace on

local i=1

foreach var of varlist _all{

replace nombre = "`var'" if _n == `i'

local label: var label `var'

replace descripcion = "`label'" if _n == `i'

local ++i   
	
}   

drop id_hogar~hizo15

drop if descripcion == ""

export excel "doc excel.xlsx", firstrow(variables) sheet("sheet 1", replace)



