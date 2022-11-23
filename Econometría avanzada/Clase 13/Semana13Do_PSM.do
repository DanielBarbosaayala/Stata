* Econometría Avanzada
* Clase Complementaria
* 2022-1
clear all
cap log close
set more off
cls

global dir "Econ. Av. - COMP/2022-1/2. Clase complementaria/Semana 13"

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

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 13"


*********************************************************************************
** CLASE 14 - Propensity Score Matching					  		    		   **
*********************************************************************************

* 1. PSM
* -------------------------------------------------------------------------------
use "Elecciones_locales_2002_SV.dta", clear
des	
	* Outcome de interés (Y): Participación electoral, "vote02"
	* Variables de tratamiento (X): Haber contestado una llamada para incentivar
	* 	el voto, "contact".
	* Instrumento (Z): Haber sido asignada aleatoriamente al grupo que recibe 	
	* 	llamada, "treat_real".
	
*) Análisis de cumplimiento 
tab treat_real contact, row
	
*) Controles
global X age female state vote00 competiv newreg

*) PSM: 1. Probabilidad de participar

	* Estimación
	probit contact ${X}

	* Predicción del PS
	predict pscore

*) PSM: 2. Restringir al soporte común

	* Mínimo y máximo para definir el soporte común
	bys contact: sum pscore
	
	* Definición del soporte común
	qui sum pscore if contact == 0
	gen soporte_comun = pscore <= r(max)
	tab soporte_comun
	/* máx. de contact = 1 > máx. de contact = 0 
		Entonces, se debe restringir la muestra. Hay 1 persona (tratada)
		fuera del soporte común.												*/

	* Densidad del Propensity Score por grupo de tratamiento
	cap ssc install psmatch2
	psgraph, treated(contact) pscore(pscore) bin(500) name(PS, replace)
	gr display PS

*) PSM: 3. Algoritmo de emparejamiento
		
	* A. k-Vecinos más cercanos (k=1)
		
		* Orden aleatorio de la base
		set seed 202110
		drawnorm orden
		sort orden
		/* En caso de que haya dos vecinos a la misma distancia se toma el
			que aparece de primero en la base de datos							*/
				
		* Emparejamiento sin reemplazo
		psmatch2 contact ${X}, outcome(vote02) n(1) common noreplacement
		
		des _weight _treated 
		tab _weight // Peso de cada observación 
		tab _treated // Estatus de tratamiento de toda la muestra
		tab  _weight _treated, missing
		
		/* (1) Todos los tratados tienen vecino más cercano:
				No hay ningún tratado en el soporte común sin vecino más 
				cercano.
		   (2) Un no-tratado puede servir de control para un solo tratado.
		   (3) Hay 128,703 no tratados que no son usados como controles.		*/

		* Emparejamiento con reemplazo
		psmatch2 contact ${X}, outcome(vote02) n(1) common
		
		return list
		estimates store PSM
		
		tab  _weight _treated, missing
		/* (1) Todos los tratados dentro del soporte común tienen vecino más 
				cercano, y este puede repetirse entre unidades tratadas.
		   (2) Un no-tratado puede servir de control para más de un tratado.
				Hay un no-tratado que se usa como control de 84 tratados.
		   (3) Hay 148,650 no tratados que no son usados como controles.		*/
			   
	* Radio 0.01 - Tarea: Revisar este código
	/*
	preserve
	keep if _n<16000
	
	psmatch2 contact $X, outcome(vote02) radius caliper(0.01) common
	tab  _weight _treated, missing
	
	restore																		*/
		/* (1) No necesariamente todos los tratados en el soporte común tienen
				control. 
		   (2) Un no-tratado puede servir de control para más de un tratado.
		   (3) Hay 1 no-tratado no usado como control.
	       (4) Hay 0 tratados sin control.										*/

		/* Hay un trade-off entre la presición y la varianza.  ¿Cual?			*/
			   
*) PSM: 4. Evaluar la calidad del emparejamiento
estimates restore PSM
pstest ${X}, both
	/* Lo ideal sería que en M nunca fuera estadísticamente distinto de cero	*/	
			
*) PSM: 5. y 6. Estimar el efecto y Corregir los errores estándar por Bootstrap
bootstrap r(att), dots cluster(county) reps(5):					 				///
	psmatch2 contact ${X}, outcome(vote02) n(1) common
		
*) Comparaciones
	
	* IV
	ivreg2 vote02 (contact = treat_real) ${X}, first cluster(county)
	
	* MCO en el soporte común
	reg vote02 contact ${X} if soporte_comun == 1, cluster(county)

*-------------------------------------------------------------------------------*
* Fin del Do-file