* Econometría Avanzada
* Clase Complementaria
* 2022-2
clear all
cap log close
set more off
cls


global dir "Econ. Av. - COMP/2022-1/2. Clase complementaria/Semana 03"


if "`c(username)'"=="storr"{
	cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:/Users/torre/OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Dac12"{
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:\Users\Dac12\OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="valentinadaza" {
	cd "/Users/camilo/OneDrive - Universidad de los Andes/Academia/Clases/${dir}" 
	gl path "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}"
} 

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 3\"
	 
else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 3\"

gl data "${path}\Econ. Av. - COMP\Bases de datos"
	 
*********************************************************************************
** CLASE 3- MCO 															   **
*********************************************************************************

* 1. Interpretación de Parámetros
* -------------------------------------------------------------------------------
* Randomizing religion: the impact of protestant evangelism on economic outcomes
* Gharad Bryan, James J. Choi, y Dean Karlan 
* 2021. The Quarterly Journal of Economics

use "RandomizingReligion.dta", clear 
	/*Estudiante, cargue la base de datos */


describe
	* Outcome de interés (Y): Religiosidad y salario
	* Variable indep. de interés (X): Valores cirstianos
		/* ¿Cuál es el efecto de la asignación al programa de valores cristianos
			sobre la religiosidad y el salario? 								*/

*) Regresiones: 

	* Sin regresoras
	reg household_income
	sum household_income
	
	* Regresión Univariada - Con Variable Dummy
	reg household_income 1.values, cluster(basecomm)
	
	*1.values hace el rpemdeio y teniene el cuenta el valor1
	* En promedio las personas con  1 recibieron 650 usd más
	
	** Cuando cluster: corre la regresión EE calcularlos con cluster entre individuos de la misma comunidad
	
	ttest household_income, by(values)
	
	* Regresión Univariada - Con Variable Continua
	reg household_income educ_resp
		
	* Regresión multivariada 
	global controles respondent_gender days_june married divorced adults 		///
		children educ_resp married_m educ_resp_m
	reg household_income values ${controles}, cluster(basecomm)

*) Resultados almacenados
ereturn list
// e(b) vector de betas, y e(V) matriz varcov estimadas

di _b[values]
di _se[values]^2
mat list e(V)
mat list r(table)

*) Valores predichos
predict yhat
predict ehat, resid

*) Resultados principales
	
	* Religiosidad
	qui reg z_religion_intr_i values ${controles}, cluster(basecomm)
	outreg2 using "Reg_Model.doc", replace word cti("Religiosidad") 			///
		keep(values) nocons nor2 dec(3)

/// Comando qui hace que la regresón se corra en segundo plano para ahorrar memoria		
		
		* Al obtener los resultados de una regresión,
		*no solo nos importa la significancia estadística de los
		*coeficientes estimados, sino su significancia económica.
		*Para este propósito, tenemos varias alternativas.


		
		
		
		* Podemos ver el efecto estimado como porcentaje de la media:

			sum z_religion_intr_i
			
			di _b[values]/r(mean)*100

			// interpretación en términos de medias. Me sirve para mirar cuanto porcentaje de la media tiene de efecto el beta estimado
			
		* Como desviaciones estándar:

			di _b[values]/r(sd)
	// Lo mismo pero en desviaciones estandar 
	
	* Salario
	foreach var of varlist household_income pay_agr_labor pay_formal_employ 	///
	pay_self_employ {
		
		qui reg `var' values ${controles}, cluster(basecomm)
		outreg2 using "Reg_Model.doc", append word cti("`var'") keep(values) 	///
			nocons nor2 dec(3)

	}

	* Visualizar resultados
	seeout using "Reg_Model.txt"

	
	
* Extra: Formas Funcionales												   
* -------------------------------------------------------------------------------
*) Creación de variables logaritmicas

/* Es usual en al literatura realizar transformaciones logarístmicas de 
   ciertas variables por 1) el tipo de efecto que se busca estimar y 
   2) suaviza las diferencias en localización y escala que suelen generar 
   problemas de heteroscedasticidad 											*/
foreach var of varlist household_income educ_resp {
	gen ln_`var'=ln(`var'+1)
}
	
*) Modelos logaritmicos

/* Los efectos interpretados son ceteris paribus, son efectos promedio y 
   son estadísticamente significativo a un 5%.	    							*/
	
	* a. Log-Lin (salario educación)
	reg ln_household_income educ_resp
	/* Semi-elasticidad, se debe multiplicar por 100 el beta: 
	   Un año adicional está asociado a un incremento de 3.8% en el salario.	*/

	* b. Lin-Log (salario educación) 
	reg household_income ln_educ_resp
	/* Se debe dividir por 100 el beta: 
	   Un incremento en 1% en los años de educación está asociado a un 
	   incremento de 7 PhP en el salario.									*/

	* c. Log-Log (salario educación)
	reg ln_household_income ln_educ_resp
	/* Eslasticidades: 
	   Un incremento en 1% en los años de educación está asociado a un 
	   incremento de 0.24% en el salario.		  								*/

	* d. Log-Lin (salario valores)  
	reg ln_household_income values, cluster(basecomm)
	/* Se debe iinterpretar (exp(beta)-1)*100 %: 
	   Multiplicar por 100 el beta no es una aproximacion tan mala, pero no es
	   correcto 																*/
	di (exp(_b[values])-1)*100
	/* En promedio, el haber trabajado en sus valores cristianos incrementa en 
	   23.4 % el salario.				 										*/

*********************************************************************************
** EJERCICIO: Presente en una tabla el coeficiente indicado para un modelo:	   **
**	a. Log-Lin (salario educación)          					               **
**	b. Log-Lin (salario educación)        			             		       **
**	c. Log-Log (salario educación)                  			 		       **
**	d. Lin-Log (salario valores)	                       					   **
*********************************************************************************

* a. Log-Lin (wage educ)
reg ln_household_income educ_resp
outreg2 using "Reg_Log.doc", replace cti("Log-Lin") word nocons nor2 dec(3)

* b. Lin-Log (wage educ) 
reg household_income ln_educ_resp
outreg2 using "Reg_Log.doc", append cti("Lin-Log") word nocons nor2 dec(3)

* c. Log-Log (wage educ)
reg ln_household_income ln_educ_resp
outreg2 using "Reg_Log.doc", append cti("Log-Log") word nocons nor2 dec(3)

* d. Log-Lin (wage female)  
reg ln_household_income values, cluster(basecomm)
local beta = (exp(_b[values])-1)*100
outreg2 using "Reg_Log.doc", append cti("Log-Dummy") word nocons nor2 dec(3) 	///
	addstat("(e(b)-1)*100",`beta')	
	
	
********************************************************************************
* INFERENCIA ESTADÍSTICA E INCUMPLIMIENTO DE SUPUESTOS EN MCO        		  **	
******************************************************************************** 
* Sabemos que, bajo las hipótesis de Gauss-Markov, el estimador de MCO es inses-
* gado, consistente y eficiente. En particular, la eficiencia requiere de los 
* supuestos de homocedasticidad y de no-autocorrelación. Sin embargo, cuando 
* esto no se cumple, se puede invalidar la inferencia estadística. 

clear all
cap log close
set more off
cls



* 1. Heteroscedasticidad
*-------------------------------------------------------------------------------*
* Se da cuando la varianza de los errores no es constante entre unidades.

*) Simulación de los datos
set obs 50
set seed 13

	* Variables auxiliares
	gen i = runiform(0,1)
	gen j = runiform(0,20)

	* Asignación al tratamiento (aleatoria)
	gen D = (i>0.6)

	* Parámetros poblacionales
	scalar alpha = 1 
	scalar beta = 3 
	
	* Error con heteroscedasticidad
	gen e = rnormal(0,.057*j^2)	

	* Variable dependiente
	gen Y = alpha + beta*D + e

*) Regresiones

	* Suponiendo homoscedasticidad y no autocorrelación
	reg Y D
	
		* Identificación del problema
		hettest
		imtest, white
		
		* Ejercicio: La heteroscedasticidad se puede diagnósticar a partir 
		* de gráficos de los residuales contra variables independientes.
		* Construyan una(s) gráfica(s) que les permita hacer tal diagnóstico.
	
	* Errores estándar robustos a heteroscedasticidad
	reg Y D, r
	
	*Para muestras pequeñas (N<=250) es mejor usar el estimador de Davidson-MacKinnon
	*Ver: http://datacolada.org/99
	*Y ver: https://t.co/gQM0t16Nqc
	
	reg Y D, vce(hc3)
	
	*Nota: Esto es el default de R (punto para R...)
	
	
* Note que al especificar mal la forma de la VarCov, llegamos a la conclusion 	
* incorrecta: No rechazamos la hipotesis nula (H0: beta=0) cuando deberíamos 	
* (Error tipo II). Este problema se soluciona al utilizar errores robustos a 	
* heterocedasticidad.
	
* Pese a que el estimador sigue siendo consistente (se cumple exogeneidad 
* estricta), al no especificar bien la VarCov, se sobreestiman los errores 
* estándar. 

* Nota: Podría pasar lo contrario, y se subestiman los errores. En 
* tal caso, podríamos cometer error tipo I (rechazamos H0 cuando no debemos).

* 2. Autocorrelación
*-------------------------------------------------------------------------------*

* Interés general: https://blogs.worldbank.org/impactevaluations/when-should-you-cluster-standard-errors-new-wisdom-econometrics-oracle

*) Simulación de los datos
* Los datos son exactamente los mismos salvo por el término del error.
	
	* Error independiente
	gen e2 =rnormal(0,0.1)	
	
	* Variable dependiente
	gen Y2 = alpha + e2
		* Noten que en este caso el coeficiente que acompaña D es cero.
	
	* Expandir la base 1000 veces
	gen id = _n
	expand 1000, gen(dupindicator)
	
	* Gernerar identificador de cluster	
	rename id cluster
		
		* Ejercicio: Exploren el siguiente comando y expliquen por qué permite
		* identificar los clústeres en este caso.
		egen pareja = group(Y2) // pareja == cluster

*) Regresiones
	
	* Ignorando la autocorrelación que existe entre las copias
	reg Y2 D
		* Noten que la autocorrelación es igual a uno.
		
	* Errores estándar robustos a correlación a nivel de clústeres
	reg Y2 D, cluster(cluster)
	
* La autocorrelación nos lleva a que subestimemos los errores estándar. Ello, 
* nos lleva a identificar un efecto donde no lo hay. Es decir, incrementa
* la probabilidad de cometer error tipo I.	
*-------------------------------------------------------------------------------*
* Fin del Do-file
	
	
	
	
	
	
	
	
	
	
	
	
	

