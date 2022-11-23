/* CONTINUACIÓN DIF-DIF */

cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\6 semestre\Econometría 2\Complementarias de stata\Clase 10"

use "datapanel.dta", clear
reg ln_wage i.race grade exp i.year##i.c_city  if year==73|year==75

preserve 
collapse (mean) ln_wage , by(c_city year )
twoway 	(tsline ln_wage if c_city ==1) ///
		(tsline ln_wage if c_city ==0) if year<=75, ///
			legend(order(1 "centro" 2 "fuera"))
restore 
reg ln_wage i.race grade exp i.year##i.c_city  if year==73|year==75

matlist e(b)' //permite ver como guarda stata los valores de la regresión para luego llamarlos en los test.

test 75.year#1.c_city
test 1.c_city
test 75.year
test (75.year#1.c_city) (1.c_city) (75.year)

logit c_city i.race grade exp //para revisar que las condiciones específicas observables no tengan efectos relevantes sobre la probabilidad de ser o no ser tratado.


use "Clase 9 Paneldata.dta", clear

//metodo de dommies
reg ln_wage exp expersq tenure south  black other i.idcode 
est store mco 

//pooled olx
xtset idcode year
xtreg ln_wage exp expersq tenure south  black other, fe
est store fe 

//diferencias
reg d.ln_wage d.exp d.expersq d.tenure d.south  d.black d.other , nocons //d.var saca la diferecncia entre las variables en el tiempo
est store dif

//comparación del modelo
est table fe mco dif 
drop tag max T rr _est_fe _est_mco muestra _est_dif

