* Econometría Avanzada
* Clase Complementaria
* 2022-2
clear all
cap log close
set more off
cls

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 02"

	else if "`c(username)'"=="torre" cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}"
	else if "`c(username)'"=="Dac12" cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}"
	else if "`c(username)'"=="valentinadaza" cd "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}"

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 2\"

*********************************************************************************
** CLASE 2-	RESULTADOS POTENCIALES 											   **
*********************************************************************************

	* Outcome de interés (Y): Estado de salud.
	* Tratamiento (D): Ser hospitalizado.
		/* ¿Cuál es el efecto de ser hospitalizado sobre el estado de salud?	*/

* 1. Estructura del modelo
* -------------------------------------------------------------------------------

*) Preparar el ambiente de trabajo
set obs 100000 //Genera observaciones vacias
set seed 20212 // fijar semilla. Para que resultados sean replicacbles
help random_number_functions

*) x y u's
gen x = rchi2(3)
gen u1 = rnormal(0,1)
gen u0 = rnormal(0,1)

*) Outcomes potenciales

	* Parámetros
	local alpha = 0.3
	local delta = 0.07
	local beta = 0.25

	* Para D = 0
	gen Y0 = `alpha' + x*`beta' + u0
	
	* Para D = 1
	gen Y1 = `alpha' + `delta' + x*`beta' + u1
	
*) Asignación al tratamiento
gen D = Y1 > Y0
tab D
	
*) Outcome observado
gen Y = Y1*D + Y0*(1-D)

tab Y

	* Distribución
	tw (hist Y, blcolor(gray%80) bfcolor(gray*0.5%80)) 							///
		(kdensity Y, lcolor(black)),											///
		graphregion(fcolor(white)) plotregion(lcolor(black))					///
		ylabel(,nogrid)															///
		legend(order(1 "Histograma" 2 "Densidad kernel"))
		
	graph export "graph.tiff", as(tif) width(3900) replace

* 2. Parámetros de interés
* -------------------------------------------------------------------------------

*) Definición de la matriz
mat MAT_resultados = J(8,1,.)
mat rownames MAT_resultados = "T_{i}" "ATE" "ATT" "ATU" "MCO" "MCO|X" 			///
	"MCO (D aleatorio)" "MCO (D aleatorio)|X"

*) Efecto del tratamiento para i = 1
gen Ti = Y1 - Y0
sum Ti if _n == 1
mat MAT_resultados[1,1] = r(mean)

*) ATE
sum Ti 
mat MAT_resultados[2,1] = r(mean)

*) ATT
sum Ti if D == 1
mat MAT_resultados[3,1] = r(mean)

*) ATU
sum Ti if D == 0
mat MAT_resultados[4,1] = r(mean)

mat l MAT_resultados

* 3. Análisis de regresión
* -------------------------------------------------------------------------------

*) Regresión lineal simple
ttest Y, by(D)
reg Y D

mat MAT_resultados[5,1] = _b[D]

*) Regresión lineal múltiple
reg Y D x
mat MAT_resultados[6,1] = _b[D]

sum Y if D == 0
mat l MAT_resultados

*) Sesgo de selección
sum Y0 if D == 1
sum Y0 if D == 0

	* ¿Qué pasa si el tratamiento es aleatorio?
	gen D_r = rbinomial(1,0.5)
	sum Y0 if D_r == 1
	sum Y0 if D_r == 0
	
	replace Y = Y1*D_r + Y0*(1-D_r)
	
	reg Y D_r 
	mat MAT_resultados[7,1] = _b[D_r]
	
	reg Y D_r x
	mat MAT_resultados[8,1] = _b[D_r]
		/* El estimador del ATE está un poco lejos del ATE poblacional.
		   Si aumentamos la muestra, segúramente el estimador será más 
		   cercano al valor real. A esto se le conoce como consistencia.*/

mat l MAT_resultados

*********************************************************************************
** ¿Cómo exportar una tabla con el contenido de la matriz?. Para esto 	   	   **
** podemos explorar los comandos putexcel y frmttable.						   ** 
*********************************************************************************
search frmttable

frmttable using "matriz.doc", statmat(MAT_resultados)							///
	ctitles("Efecto", "Coeficiente") replace
	
*********************************************************************************
** Ejercicio: Presente en una gráfica cómo a medida que aumenta el tamaño de   **
** muestra, el estimador del ATE cuando el tratamiento es aleatorio se acerca  **
** cada vez más al valor poblacional de este. 							       **
**                                                                             **
** Para esto:                                                                  **
** 1. Creen una matriz vacía con 1000 filas y dos columnas. En la primera 	   **
**    columna van a guardar el tamaño de muestra de cada iteración y en la     **
**    segunda el ATE estimado.                                                 **
** 2. Dentro de un loop simulen 1000 veces la muestra de Y1, Y0, Y y D_r tal   **
**    como fue presentado anteriormente en el Do-file. En cada iteración, el   **
**    tamaño de muestra debe incrementar en 100. Es decir, en la primera 	   **
**    iteración N = 100, en la segunda N = 200, en la tercera N = 300 y así    **
**    sucesivamente hasta completar las mil iteraciones. Asegúrense de 		   **
**    guardar el tamaño de muestra de cada iteración en la matriz. Es decir,   **
**    si están en la iteración 2, el número 200 debe ser guardaro en la        **
**    posición 2,1 de la matriz.
** 3. Dentro de cada iteración hagan una regresión de Y contra D_r y x. 	   **
**    guarden el coeficiente estimado en la fila correspondiente de la segunda **
**    columna de la matriz. Es decir, si están en la iteración 10, el 		   **
**    coeficiente estimado debe ser guardado en la posición 10,2 de la matriz. **
** 4. Limpien su espacio de trabajo con el comando clear.                      **
** 5. Conviertan la matriz en la base de datos del espacio de trabajo. Para    **
**    esto, revisen los comandos svmat y mkmat.                                **
** 6. Hagan un gráfico de linea (help tw line) del parámetro estimado (eje y)  **
**    contra el tamaño de muestra de la estimación (eje x). Agreguen una línea **
**    horizontal ubicada en el eje y en la posición 0.071 (el ATE poblacional).**
**                                                                             **
** Para revisar el comportamiento de un estimador inconsistente, pueden        **
** repetir este ejercicio cuando D es asignado según Y1>Y0.					   **
*********************************************************************************

set seed 2
mat ATE = J(1000,3,.)

local N = 0
forvalues i = 1/1000 {
	local N = `N' + 100

	*) Simulación de los datos
	clear
	set obs `N'
	mat ATE[`i',1] = `N'

	
		* x y u's
		gen x = rchi2(3)
		gen u1 = rnormal(0,1)
		gen u0 = rnormal(0,1)

		* Parámetros
		local alpha = 0.3
		local delta = 0.07
		local beta = 0.25

		* Para D = 0
		gen Y0 = `alpha' + x*`beta' + u0

		* Para D = 1
		gen Y1 = `alpha' + `delta' + x*`beta' + u1

		* D aleatorio
		gen D_r = rbinomial(1,0.5)
		
		* D endógeno
		gen D = Y1 > Y0
		
		* Outcome observado 
		gen Y_r = Y1*D_r + Y0*(1-D_r)
		gen Y = Y1*D + Y0*(1-D)
	
	*) Estimación
	qui reg Y_r D_r x
	mat ATE[`i',2] = _b[D_r]
	
	qui reg Y D x
	mat ATE[`i',3] = _b[D]
	
}

clear 
svmat ATE
tw (line ATE2 ATE1, lcolor(navy%70))											///
	(line ATE3 ATE1, lcolor(maroon%70)),										///
	graphregion(color(white)) 													///
	plotregion(lcolor(black))													///
	yline(.07185166, lcolor(black) lpattern(-))									///
	xtitle("Tamaño de muestra")													///
	ytitle("Efecto estimado")													///
	legend(order(1 "Tratamiento aleatorio" 2 "Tratamiento endógeno"))

graph export "ejercicio2.tiff", as(tif) width(3900) replace

