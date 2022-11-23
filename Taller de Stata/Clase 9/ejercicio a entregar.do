
**Ejercicio 9

global dir "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 10\"

use "${dir} fechas_facturacion", replace

edit if regexm (finper	, "ENE")


foreach var of varlist inicioper* finper*{
    
	
replace `var' = regexr(`var', "ENE", "JAN")

replace `var' = regexr(`var', "ABR", "APR")

replace `var' = regexr(`var', "AGO", "AUG")

replace `var' = regexr(`var', "DIC", "DEC")

	
}

**Solucion 2

use "${dir}fechas_facturacion", replace


tokenize ENE ABR AGO DEC
macro dir


foreach var of varlist inicioper* finper*{
    
	local i = 1
	
	foreach mes in "JAN"  "APR"  "AUG"  "DEC"{
	    
		replace `var' = regexr(`var', "``i''", "`mes'")
		
		local ++i
	}
	
	gen `var'_mod = date(`var', "MDY")
	format `var'_mod %td
	
	drop `var'
	
}


`







 






