cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 12\"


*1. IMPORTAR BASE DE DATOS

spshape2dta "world", replace

*2. ARREGLAR BASE

use world, replace

rename ADM0_A3 code

tempfile world
save `world'

*3. IMPORTAR BASE CASOS COVID

use "datacovid", replace

sum new_cases_per_million
local max = round(`r(max)',0.1)

macro dir


*4. EMPAREJAR BASECASOS CON BASE ATRIBUTO

foreach mes in "Febrero" "Mayo" "Agosto" "Noviembre"{
    
	preserve
	
	keep if month == "`mes'"
	
	merge 1:1 code using `world', keep(2 3) nogen 
	
	
	
	#d
	
	grmap new_cases_per_million using "world_shp", id(_ID)
	fcolor(Greens)
	ndf(gray)
	clmethod(custom)
	clb(0 1.9 5.1 21.1 `max')
	legend(position(9) ring(0))
	legstyle(2)
	title("`mes'")
	name("`mes'", replace);
	
	#d cr;
	
	restore
	
}

graph combine `names', title("Casos de COVID-19 por millón de personas") xsize(10) ysize(20)




