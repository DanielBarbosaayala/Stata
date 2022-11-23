*****************************************
* 		Monitoría Econometría 1 		*
*****************************************

* Link para descargar STATA 16: https://www.software-shop.com/universidades/uniandes

/// Buenas prácticas: Lo primero que hacemos es definir una carpeta que sirva como directorio. Hay que mostrarle explícitamente a los estudiantes cómo hacer esto.

clear all // limpiar todo
set more off, perm // para mostrar completo el resultado
set matsize 11000 // decirle a stata el tamaño de la matriz
cls // limpiar la ventana de resultados

* Se establece el directorio de trabajo. Allí se irá todo lo que exportemos.

cd "/Users/anamariapatron/Desktop/monitoria_stata"

*-----------------------------------*
* 	I. Manipulación de bases		*
*-----------------------------------*

*** a. Exploración de bases ***

use "Datos Originales/Base1.dta", clear
br
// para cerrar la base anterior y abrir la que quiero(base1.dta)
use "Datos Originales/Base2.dta", clear
br

use "Datos Originales/Base3.dta", clear
br

*** b. Generar un identificador ***

* Generar un identificador único para cada municipio 
// Concatenar el código del municipio y el código del departamento

use "Datos Originales/Base1.dta", clear												
egen id=concat(coddpto codmpio)
//concat:generar variables usando funciones. Es una de las funciones de egen
//egen id: estamos generando una variable que se llama id que junta el codmpio y coddpto
save "Datos Procesados/Base_ID.dta", replace
// replace: para que si hay otra base con el mismo nombre, la reemplace
//save: guarda la base de datos que creamos ( es base1.dta+ variable id que creamos)


*** c. Pegar las bases: Merge ***

use "Datos Originales/Base2.dta", clear
br
//base que queremos pegar
use "Datos Procesados/Base_ID.dta", clear
//base master

merge 1:m id using "Datos Originales/Base2.dta"
save "Datos Procesados/Base_Merge.dta", replace

//merge correspondencia variable using nombrebase
// si _merge==3 entonces todo se pegó bien si es 2 o 1 hubo algo sin pegarse

*** d. Pegar las bases: Append ***

use "Datos Originales/Base3.dta", clear
br
use "Datos Procesados/Base_Merge.dta", clear
tab ano
append using "Datos Originales/Base3.dta"
tab ano
//tab: saca todos los valores que toma la variable... su rango y sus frecuencias
save "Datos Procesados/Base_Calculos.dta", replace 

*-------------------------------------------*
* 	II. Generar y exportar de resultados	*
*-------------------------------------------*

*** a. Estadísticas descriptivas ***

sum pobl_tot

sum pobl_tot, d
ssc install outreg2
outreg2 using "Resultados/Tabla_1.doc", replace sum(detail) keep(pobl_tot) eqkeep(N mean sd min max p25 p50 p75)
//keep variable que quiero mantener y eqkeep lo que quiero sacar de esa variable

asdoc tabstat pobl_tot, stat(N mean sd p25 p50 p75) replace

*** b. Crear variables categóricas ***

gen tipo_pob=. 
sum pobl_tot, d 
return list
scalar p25=r(p25)
scalar p50=r(p50) 
scalar p75=r(p75)
replace tipo_pob=1 if pobl_tot<=p25
//opcion 2 es poner replace tipo_pob=1 if pobl_tot<= 6848.5 pero es ineficiente
replace tipo_pob=2 if pobl_tot>p25 & pobl_tot<=p50
replace tipo_pob=3 if pobl_tot>p50 & pobl_tot<=p75
replace tipo_pob=4 if pobl_tot>p75

save "Datos Procesados/Base_Final.dta", replace 

*** c. Gráficas ***

	*i. Scatter
	
	scatter pobl_tot discapital, title("Relación entre población total y distancia a la capital")
	//ver correlación entre 2 variables
	
	twoway (scatter pobl_tot discapital) (lfit pobl_tot discapital),  title("Relación entre población total y distancia a la capital")
	//grafico con linea de tendencia (lfit)
	
	*ii. Gráfico de barras

	graph bar (mean) pobl_rur, over(tipo_pob) ///
	title("Promedio población rural por percentil")

	*iii. Histogramas

	gen ln_pobl_tot=ln(pobl_tot)
	//sqrt raiz cuadrada
	histogram ln_pobl_tot
	histogram ln_pobl_tot, norm
	graph export "Resultados/Histograma_Pobl_Tot.png", replace 
	//toca correr las dos lineas juntas hist + graph export

*** d. Condicionales ***

preserve
keep if tipo_pob!=4
sum pobl_tot 
outreg2 using "Resultados/Tabla_2.doc", title(población p25 p50 p75 ) ///
sum(detail) eqkeep(N mean sd min max) replace
restore
//se debe correr todo junto, desde el preserve hasta el restore

*** e. Regresiones ***

reg  pobl_tot pobl_rur
// pobl_tot es dependiente y pobl_rur es independiente
ereturn list
//porque hablamos en términos matriciales
outreg2 using "Resultados/Tabla_3.doc", replace

** correlaciones 
pwcorr pobl_tot pobl_rur, sig star(0.05)
// sig star es para poner el nivel de significancia

* Anexar otra regresión a la misma tabla

reg  pobl_tot pobl_urb
outreg2 using "Resultados/Tabla_3.doc", append
//se debe usar outreg2 inmediatamente después de la regresión sino lanza error

 
