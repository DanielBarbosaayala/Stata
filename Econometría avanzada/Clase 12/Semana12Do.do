* Econometría Avanzada
* Clase Complementaria
* 2022-1
clear all
cap log close
set more off
cls 

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 08"

if "`c(username)'"=="storr"{
	cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:/Users/torre/OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Dac12"{
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:\Users\Dac12\OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="valentinadaza"{
	cd "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}"
	gl path "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes"
} 

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 12"


gl data "Clase 12"


*********************************************************************************
** MAXIMA VEROSIMILITUD														   **
*********************************************************************************
* -------------------------------------------------------------------------------	
	
*) Programación manual de la Log-Verosimilitud
	
	* Generación de variable aleatoria 
	clear all
	set obs 2000

	set seed 20212
	
	scalar lambda = 5

	gen Y = rpoisson(lambda)

	* Definición del programa
	cap program drop mypoisson
	program define mypoisson
		args lnf lambda
		quietly replace `lnf' = $ML_y1 *ln(`lambda')- `lambda' - lnfactorial($ML_y1)
	end
	
	* Definición del Modelo
	ml model lf mypoisson (Y=)
		* lf: linear form
		* mypoisson: program name
		* Cada () indica la ecuación a calcular en cada argumento:
			* Se pide reemplazar `lambda' por una constante
				
		
	* Revición de la programación - Ml Check
	ml check
	
	* Definición de valores iniciales - Ml search
	ml search
	
	* Maximización del modelo
	ml max
	
	* Camino de convergencia
	ml graph

*) Pruebas de hipótesis
test _cons = 5






*********************************************************************************
** MODELOS DE ELECCIÓN BINARIA		  					    		   		   **
*********************************************************************************
use "FAMI", clear
describe 

* Outcome de interés (Y): Atrición
* Variable indep. de interés (X): Asignación al tratamiento FAMI.
																			   
	/* ¿Cuál es el efecto de la asignación al tratamiento sobre la atrición?	*/

* 1. Definición de variable dependiente y controles
* -------------------------------------------------------------------------------

*) Variable de atrición
bys attrition: mdesc cognition

*) Controles
gl controles 			i.d_zlen_bl r_zlen_bl i.d_zwei_bl r_zwei_bl 			///
						i.department i.male i.prev_cc i.population wealth 		///
						i.teenagem TVIP_m
						
* 2. Modelo de Probabilidad Lineal
* -------------------------------------------------------------------------------

*) Estimación
reg attrition i.treatment ${controles}, r
outreg2 using "Regresion.doc", replace nor2 nonotes nocons label dec(3) 		///
	decmark(.) ctitle("MPL") addtext("Resultados","EMa", "EE", "W-H")			///
	keep(1.treatment)															///
	addnote("Errores estandar en parentesis. * p<0.01, ** p<0.05, * p<0.1")	

*) Valores predichos
predict attrition_hat_MPL, xb

*) Potenciales problemas:

	* Heteroscedasticidad
	reg attrition i.treatment
	reg attrition i.treatment, r

	* Valores predichos fuera del espacio de probabilidades. (<0 | >1)
	sum attrition_hat_MPL
	
* 3. Logit Binario 
* -------------------------------------------------------------------------------

*) Estimación
logit attrition i.treatment ${controles}
outreg2 using "Regresion.doc", append nor2 nonotes nocons label dec(3) 			///
	keep(1.treatment)															///
	decmark(.) ctitle("Logit") addtext("Resultados","Parámetros", "EE", "-")

	*Importante: Inlcuir i. en las variables categoricas

*) Efectos marginales

	* Efectos marginales en el promedio
	margins, dydx(*) atmeans

	* Efectos marginales promedio
	margins, dydx(*) post
	outreg2 using "Regresion.doc", append nor2 nonotes label dec(3) 			///
		keep(1.treatment)														///
		decmark(.) ctitle("Logit") addtext("Resultados","EMa", "EE", "-")

	* Efectos marginales en valores específicos de las regresoras
	qui logit attrition i.treatment ${controles}
	margins, dydx(*) at(male=1)
			
*) Valores predichos
		
	* Probabilidades predichas
	predict attrition_hat_logit
	sum attrition_hat_logit
			
	* Ajuste con regresoras
	predict xb, xb
	sum xb
		/* El resultado es distinto al de la probabilidad predicha.
		Obtenemos los parametros estimados mas no la probabilidad contenida 
		en la CDF */
				
* 4. Probit Binario
* -------------------------------------------------------------------------------

*) Estimación
probit attrition i.treatment ${controles}
outreg2 using "Regresion.doc", append nor2 nonotes nocons label dec(3) 			///
	keep(1.treatment)															///
	decmark(.) ctitle("Probit") addtext("Resultados","Parámetros", "EE","-")

*) Efectos marginales promedio
margins, dydx(*) post
outreg2 using "Regresion.doc", append nor2 nonotes label dec(3) 				///
	keep(1.treatment)															///
	decmark(.) ctitle("Probit") addtext("Resultados","EMa", "EE", "-")

seeout using "Regresion.txt", label

	/* ¿Cómo interpretar la magnitud de estos efectos? 							*/
	/* ¿Qué pasa si no se le pone ``i'' a las dummies? 							*/
		
*) Probabilidades predichas
qui probit attrition i.treatment ${controles}
predict attrition_hat_probit
sum attrition_hat_probit

/* ¿Cuál es mejor? ¿MPL, Probit o Logit?

	(1) Si se cumplen los supuestos de MCO, MPL estima los efectos 
		marginales promedio de forma consistente y a diferencia de MV no 
		necesita supuestos sobre la distribución.
		
	(2) Si lo que se busca es predecir probablidades MPL no es una buena 
		alternativa ya que las probabilidades no estan acotadas entre 0 y 1
		
	(3) Logit se facilita analiticamente dada la CDF, sin embargo dado el 
		teorema de límite central es mas factible suponer una distirbución 
		normal de los errores											        */
		
*-------------------------------------------------------------------------------*
* Fin del Do-file
