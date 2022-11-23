**Clase 4

** Carlos A. Ayala

*PUNTO 1: 

cd "C:\Users\Carlos A. Ayala\Desktop\universidad\Cuarto Semestre\Taller de Stata\Clase 4\"


*PUNTO 2:

import delimited using "space_missions", delimiter (",") clear


*PUNTO 3:

gen fecha = clock(datum,"#MDYhm#")

format fecha %tc

br datum if fecha ==.

*PUNTO 4:

gen dia = date(datum,"#MDY###")

format dia %td


*PUNTO 5:

gen year = yofd(dia)

gen trimestre = qofd(dia)
format trimestre %tq

gen mes = mofd(dia)
format mes %tm

*PUNTO 6:

gsort -dia

gen dist_tiempo = (dia-dia[_N])/365.25


*PUNTO 7:
gen country = regexs(0) if regexm(location,"[A-Za-z]*$")


*PUNTO 8: 

replace country = "por definir" if inlist(country, "Facility", "Ocean", "Canaria", "Site", "Sea")


*PUNTO 9:

gen uno=1

bys country: egen nro_lanza= total(uno)

tab country

bys country year: egen nro_lanza_year = total(uno)

bys country year: egen mean_lanza = mean(nro_lanza_year)

*PUNTO 1O:

gen post_us=cond(dia>td(26dec1991),1,0)

*PUNTO 11: 

tab post_us

gen lanza_dep_disolv=(1718) if post_us==1

*PUNTO 12:

bys country: egen lanz_post_us=total(uno) if dia>td(26dec1991)

gsort -lanz_post_us

tab lanz_post_us country






























