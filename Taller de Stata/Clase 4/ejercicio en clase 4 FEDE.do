*Ejercicio clase 4
*Federico Meneses-201228081


clear all 


*Punto 2
cd "C:\Users\LENOVO\Desktop\IV Semestre\Stata\clase 4\Ejercicio clase 4"  
import delimited using "space_missions", delimiter(",") clear  

*Punto 3
**Paso 1: aplicar la función dependiendo de la fecuencia de la información
gen fecha = clock(datum,"#MDYhm#")
**Paso 2: cambiar el formato de la variable que se da en el paso anterior 
format fecha %tc

*Punto 4 
gen dia = date(datum,"#MDY###")
format dia %td 

*Punto 5
** AÑO 
***gen year = yofd(dofc(fecha))
gen year = yofd(dia)

**Trimestre 
gen trimestre = qofd(dia) 
format trimestre %tq 
**Mes 
gen mes = mofd(dia)
format mes %tm 

*Punto 6
gsort -dia  
gen dist_tempo = (dia-dia[_N])/365

*Punto 7 
gen country = regexs(0) if regexm(location,"[A-Za-z]*$") // recordar especificar si tiene letras mayúsculas o minúsculas 

*Punto 8 
tab country 
** Canaria, Facility, Ocean, Site, Sea 
replace country = "por definir" if inlist(country, "Canaria", "Facility", "Ocean", "Site", "Sea")  

*Punto 9 
gen uno = 1
bys country : egen nro_lanza = total(uno)
tab nro_lanza 
br country if nro_lanza ==1395

*Punto 10

gen Union_Sovietica=cond(dia>td(09nov1989),1,0)


*Punto 11 
tab Union_Sovietica
gen LASU = (1862) if Union_Sovietica == 1 

*Punto 12 
bys country : egen DUS = total(Union_Sovietica) 
tab DUS 
gsort -DUS 






