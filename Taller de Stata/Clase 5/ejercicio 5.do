
** EJERCICIO 5

*PUNTO 1: FIJAR DIRECTORIO

cd "C:\Users\Carlos A. Ayala\Desktop\universidad\Cuarto Semestre\Taller de Stata\Clase 5\"



*PUNTO 2: IMPORTAR BASE DE DATOS

import delimited using "comtrade-col-2019", clear delimiter(",") stringcols(_all)

*PUNTO 3: concervar variables de abajo

keep year period tradeflow tradevalueus

*PUNTO 4: conserveobs y guardebase de datos 

keep if tradeflow!="Re-imports"

compress 

save "clean_comtrade_2019", replace

*PUNTO 5: IMPORTAR BD 2020, HACER LO MISMO MENOS GUARDAR

import delimited using "comtrade-col-2020jul", clear delimiter(",") stringcols(_all)
*se cambió el jul


keep year period tradeflow tradevalueus

keep if tradeflow!="Re-imports"

compress

save "clean_comtrade_2020jul", replace     
*este fue un cambio


*PUNTO 6: 

append using "clean_comtrade_2019"


*PUNTO 7:

gen mes = substr(period,-2,2)

destring mes year, replace

gen mes_year=ym(year,mes)

format %tm mes_year

save "clean_comtrade_2019_2020", replace

erase "clean_comtrade_2020jul.dta"
*se cambió el jul

erase "clean_comtrade_2019.dta"

*PUNTO 8:

import excel "1.1.1.TCM_Serie histórica IQY.xlsx", clear cellrange(A8:B10522) firstrow

rename (Fechaddmmaaaa Tasadecambiorepresentativade) (fecha tdmr)

*PUNTO 9:

gen mes_year=mofd(fecha)

format %tm mes_year

*PUNTO 10:

collapse (mean) tdmr , by(mes_year)

*PUNTO 11:

merge 1:m mes_year using "clean_comtrade_2019_2020"

tab _merge

keep if _merge ==3

drop _merge

*PUNTO 12:

destring tradevalueus, replace

gen double tradevaluecop = (tradevalueus*tdmr)/1000000000000

*PUNTO 13:

gen trim=qofd(dofd(mes_year))

format %tq trim

collapse (sum) tradevaluecop, by(trim tradeflow)


*PUNTO 14: (use wide para especificar que se va a introducir nuevas columnas)

reshape wide tradevaluecop, i(trim) j(tradeflow) string

*PUNTO 15: 

gen tasa_export =(tradevaluecopExports[_n]-tradevaluecopExports[_n-1])/(tradevaluecopExports[_n-1])

gen tasa_import =(tradevaluecopImports[_n]-tradevaluecopImports[_n-1])/(tradevaluecopImports[_n-1])























