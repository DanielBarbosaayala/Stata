* Econometría Avanzada
* Clase Complementaria
* 2022-2
clear all
cap log close
set more off
cls 

if "`c(username)'"=="storr"{
	cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:/Users/torre/OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Dac12"{
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:\Users\Dac12\OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="valentinadaza"{
	cd"/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}" 
	gl path "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes"
} 

else //cd "ESTUDIANTE: COPIE AQUÍ LA RUTA DE SU DIRECTORIO"
	 

gl data "${path}/Econ. Av. - COMP/Bases de datos"

*********************************************************************************
** CLASE 7 - IV LATE					     								   **
*********************************************************************************

* 1. IV
*===============================================================================*
use "${data}/RCT/AeioTU/AeioTU.dta", clear
describe
	* Outcome de interés (Y): Habilidades cognitivas
	* Variable indep. de interés (X): Asistencia efectiva a centro de cuidado
	* Variable instrumental (Z): Asignación aleaatoria a centro de cuidado
		/* ¿Cuál es el efecto de la asistencia efectiva a un centro de 
			cuidado sobre el desarrollo cognitivo? 								*/
	
global covs cognitivo_BL sexo raza riqueza_BL ninos_casa_BL centrocuidadp_BL	///
			edad_BL edad2_BL assessor_FE*

* 1.1. MCO
*-------------------------------------------------------------------------------*
*) Chequeo de covariables
ssc install mdesc

mdesc ${covs}
misstable sum 

gen to_use = cognitivo_ajust<. & cognitivo_BL<. 	
tab to_use							

mdesc ${covs} if to_use == 1

*) Modelo de diferencias
reg cognitivo_ajust asistencia ${covs} 								
reg cognitivo_ajust asistencia ${covs} if to_use == 1									
	* No es necesaria el condicional if to_use == 1. Sin embargo, al incluirla
	* son ustedes los que están eliminando las observaciones con missings y no
	* Stata.
	
	* ¿Es el efecto estimado razonablemente causal? Dado que las madres que 
	* deciden llevar a sus hijos al centro de cuidado pueden ser sistemática-
	* mente distintas a las madres que no lo hacen (e.g. diferencias en motiva-
	* ción), el tratamiento efectivo seguramente es endógeno. Así, dada la 
	* presencia de sesgo de selección/OVB, el estimador por MCO es plausiblemente
	* sesgado e inconsistente.
	
* 1.2. IV
*-------------------------------------------------------------------------------*
*) Estadísticas descriptivas	

	* 1. Compliance
	
		* Tabla
		tab asistencia D if to_use == 1, col
		
		* Tarea: Revisar el código de la siguiente gráfica
		count if to_use == 1
		local N = r(N)
		
		tempvar asistencia	
		gen `asistencia' = asistencia*100		
		
		tempvar no_asistencia
		gen `no_asistencia' = (1 - asistencia)*100
		
		gr hbar `asistencia' `no_asistencia' if to_use == 1, 					///
			blabel(bar, format(%3.1f))											///
			over(D, relabel(1 "Asignado a Control" 2 "Asignado a Tratamiento")) ///
			stack graphregion(fcolor(white)) legend(r(1) 						///
			label(1 "% Asiste") label(2 "% No Asiste"))							///
			bar(1, color(black)) bar(2, color(gray))							///
			note("N=`N'") 


*) Chequeo de supuestos

	* Relevancia: 
	reg asistencia D ${covs} if to_use == 1, r
	test D
	
	* Exogeneidad, Restricción de exclusión y monotonicidad: ...
				
*) Estimación
* ssc install ivreg2
ivreg2 cognitivo_ajust (asistencia = D) ${covs} if to_use == 1, first 			///
	savefirst r
	
di "Estadístico F de la primera etapa: "e(rkf)
est store segunda_etapa		
	
	* Post-estimación
	est restore _ivreg2_asistencia
	eret list
	
	est restore segunda_etapa
	eret list
