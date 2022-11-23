*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			   Taller de Stata 2020-II             **
** 			   						               **
** 			   Cristhian Acosta-Pardo              **
** 				Miguel Garzón-Ramírez              **
** 			   						               **
** 				Ejercicio de clase 1               **
*****************************************************


**EJERCICIO EN CLASE 1**
clear all
log using "pob.log", replace
cd "G:\Mi unidad\4_DOCENCIA\Taller de Stata\2020-II\6 - Ejercicios\EC1 - Importación de datos"

*1.
import excel "Bases\ProyeccionMunicipios2005_2020.xls", sheet("Mpios") cellrange(A9:T1131) firstrow clear
save poblacion.dta, replace
log close

*2.
log using "ideca.log", replace
import delimited using "uso_12.txt", clear delimiter(";") decimalseparator(",") stringcol(1 2 3)
drop objectid
codebook
describe
inspect

save uso_12.dta, replace
log close

