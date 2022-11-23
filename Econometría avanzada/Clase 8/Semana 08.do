* Econometría Avanzada
* Clase Complementaria
* 2022-2
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

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 8"


	 
*********************************************************************************
** CLASE 8 - Endogeneidad y RDB						     	         		   **
*********************************************************************************

use "Rational Ignorance Hypothesis", clear
describe
	* Outcome de interés (Y):  Proporción de respuestas correctas en el quiz de 
	*	política.
	* Variable indep. de interés (D): Votar en las elecciones presidenciales.
	* Variable de elegibilidad (T): Tener estatus de voto obligatorio.
	* Running variable (X):  Distancia en días del cumpleaños 18 al día de las 
	*	elecciones.
	
	/* Hipótesis de la ignorancia racional del votante Downs (1957):
		¿Cuál es el efecto de la votación efectiva sobre el conocimiento 
		político? 																*/

egen std_politicalquiz = std(politicalquiz)
global covs i.escola votedbefore2010 white female collegemother_y

* 1. Endogeneidad - Estimaciones ingenuas
*-------------------------------------------------------------------------------*

*) MCO
reg std_politicalquiz vote ${covs}
	/* ¿MCO identifica un efecto causal del voto sobre los resultados del 
		quiz de política?
		
		No. Es plausible que existan diferencias sistemáticas en las no 
		observables entre quienes votan respecto a quienes no votan que a su 
		vez afectan el conocimiento sobre los candidatos. Por ejemplo, 
		diferencias en la motivación para participar en la democracia. 
		
		 - + Motivación -> + Pr. de votar.
		 - + Motivación -> + Se informan sobre los candidatos. 
		 
		 Por tanto, se espera que el estimador de MCO sobreestime el efecto 
		 del voto sobre el conocimiento. 									*/
									
									
* 2. RDB
*===============================================================================*

*) IV
* ssc install ivreg2
* ssc install ranktest
ivreg2 std_politicalquiz (vote=compulsoryvote) ${covs}, first
	/* ¿IV idenficia un efecto causal del voto sobre los resultados del
		quiz de política?
		
		No. La obligatoriedad del voto es plausiblemente endógena porque
		hay diferencias sitemáticas en las conductas de votación de la 
		población muy jóven respecto a la población muy vieja.				*/

* 2.1. RDB
*-------------------------------------------------------------------------------*		
*) Verificación de supuestos de RDB
	
	* 1. Discontinuidad en la probabilidad de tratamiento	
	reghdfe vote compulsoryvote##c.diasalt_1 if sample6m==1, a(escola) 			///
		vce(robust)
	
		* Tarea: revisar el código del display
	di "El salto en la probabilidad de tratamiento es de " 						///
		string(_b[1.compulsoryvote]*100,"%6.3f") " puntos porcentuales "		///
		"y el p-valor de la prueba de significancia individual es de " 			///
		string(ttail(e(df_r),abs(_b[1.compulsoryvote]/_se[1.compulsoryvote]))*2, ///
		"%6.3f")
		
	* 2. Continuidad local de las covariables
	estimates clear
	local n=0
	foreach var of varlist white female collegemother_y livewithparents work 	///
	votedbefore2010 { 
		local ++n
		qui reghdfe `var' compulsoryvote##c.diasalt_1 if sample6m==1, 			///
					a(escola) vce(robust)
		estimates store m`n'
		estadd local SchoolFE = "Yes" , replace 
		
	}
		* Tarea: revisar el código del esttab
		esttab m*, append  														///
			nocons se starlevel(* .10 ** .05 *** .01)							///
			mtitles("White" "Female" "Mother College" "Live parents" 			///
			"Work" "Voted 2010") varlabels(1.compulsoryvote "Compulsory vote")  ///
			stats(SchoolFE  N, fmt(0 %9.0gc) labels("School FE" "N")) 			///
			keep(1.compulsoryvote)
		
		/* Nota: Al final, lo mejor es implementar rdrobust sobre las 
		   covaraiables. Tarea: Revisar el siguiente código e interpretar 
		   sus resultados. */
		estimates clear
		local n=0
		foreach var of varlist white female collegemother_y livewithparents ///
			work votedbefore2010 { 
			local ++n
			rdrobust `var' diasalt_1, all  
			estimates store m`n'		
		}
		
		esttab m*, append  														///
			nocons se starlevel(* .10 ** .05 *** .01)							///
			mtitles("White" "Female" "Mother College" "Live parents" 			///
			"Work" "Voted 2010") 

	* 3. No manipulación de la variable de focalización
	*ssc install rddensity	
	rddensity diasalt_1 , c(0) plot

*) Estimación de RDB

	* Estimación paramétrica
	ivreg2 std_politicalquiz (vote=compulsoryvote) diasalt_1 					///
		1.compulsoryvote#c.diasalt_1 ${covs}, first
	
	ivreg2 std_politicalquiz (vote=compulsoryvote) diasalt_1 					///
		c.diasalt_1#c.diasalt_1	1.compulsoryvote#c.diasalt_1 					///
		1.compulsoryvote#c.diasalt_1#c.diasalt_1 ${covs}, first	
		
	ivreg2 std_politicalquiz (vote=compulsoryvote) diasalt_1 					///
			1.compulsoryvote#c.diasalt_1 ${covs} if sample6m==1, first
	
	* Estimación no paramétrica
	rdrobust std_politicalquiz diasalt_1, c(0) fuzzy(vote) all
	/* El efecto no es estadísticamente distinto de cero. Esto es evidencia
	   sugestiva a favor de la hipótesis de ignorancia racional: los individuos
	   no se están informando para votar. Esto, según la hipótesis, indica que
	   los individuos consideran que su voto no es relevante, de manera que 
	   deciden no informarse respecto a su decisión dada la irrelevancia
	   percibida de esta. 														*/

*-------------------------------------------------------------------------------*
* Fin del Do-file
