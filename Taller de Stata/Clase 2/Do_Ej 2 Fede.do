
***ejercicio en clase 
clear all 
*Punto 1
cd "C:\Users\LENOVO\Desktop\IV Semestre\Stata\clase 2"

*punto 2 
type 1567349900409.csv
import delimited "1567349900409.csv", clear delimiter (";") // siempre usarlo para los excel

*punto 3
drop if _n<=3 // borrar una variable u observación

display _N 

*punto 4
gen estación = v2[2]
gen cod_estación = v2[1]

*punto 5 
rename (v*) (fecha hora co pm10 pm2_5) 

*punto 6
drop if _n<=4 

*punto 7

replace hora ="00:00" if hora ="24:00"

*punto 8

replace fecha = hora + "/" + fecha 

*punto 9 
tab hora if co == "" 

*punto 10
drop hora 

*punto 11 
destring co pm10 pm2_5, replace 
destring co, replace dpcomma 

*punto 12 
format co %2.1f

*punto 13 
order cod_estación estación fecha

*punto 14
sum pm10, detail  
 

*punto 15
gen pm10_w = pm10
replace pm10_w = r(p1) if pm10 < r(p1)
replace pm10_w = r(p1) if pm10 > r(p95) & pm10 < r(p100) 

*punto 16 
tabstat pm10 pm10_w, stat(N min mean max sd ) 
// la mínima entre pm10 y pm10_w es es diferente, respectivamente 0 y 2 para cada uno. así mismo la deaviación estándar y la media de pm10 es mayor que la de pm10_w esto probablemente por el ajuste que se hizo 




