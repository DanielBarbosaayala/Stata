* Econometría Avanzada
* Clase Complementaria
* 2022-1
clear all
cap log close
set more off
cls

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 14"

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

else cd "ESTUDIANTE: COPIE AQUÍ LA RUTA DE SU DIRECTORIO"

gl data_cs "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 14"

*********************************************************************************
** CLASE 14 - CONTROL SINTÉTICO					  		    		  		   **
*********************************************************************************

*-------------------------------------------------------------------------------
* 1. Control Sintético
* ------------------------------------------------------------------------------
ssc install synth, replace
findit synth_runner

use "${data_cs}/texas.dta", replace
describe
xtdes

	* Tratamiento : Expansión de los establecimientos carcelarios.
	* Outcome de interés (Y): Tasa de encarcelamiento de los hombres 
	* afroamericanos.
	* Año del tratamiento: 1993.

*) Estimación
synth bmprison bmprison(1990) bmprison(1991) bmprison(1992) 					///
		bmprison(1988) alcohol(1990) aidscapita(1990) aidscapita(1991)			///
		income ur poverty black(1990) black(1991) black(1992) 					///
		perc1519(1990), trunit(48) trperiod(1993) unitnames(state) 				///
		mspeperiod(1985(1)1992)
			
		* Constantes (no negativas) de cada variable independiente
		mat list e(V_matrix)
		
		* Vector de pesos 
		mat list e(W_weights)
		
*) Presentación gráfica del efecto del tratamiento
	
	* Base temporal
	tempfile synth
	
	* Estimación en una base
	qui synth bmprison bmprison(1990) bmprison(1991) bmprison(1992) 			///
		bmprison(1988)	alcohol(1990) aidscapita(1990) aidscapita(1991)			///
		income ur poverty black(1990) black(1991) black(1992) 					///
		perc1519(1990), trunit(48) trperiod(1993) unitnames(state) 				///
		mspeperiod(1985(1)1992) keep(`synth')
	
	* Ajuste de la base
	use `synth' , replace
	drop _Co_Number _W_Weight
	rename (_time _Y_treated _Y_synthetic) (year treat counterfact)
	
	* Gráfica
	twoway (line treat year,lp(solid)lw(vthin)lcolor(black))					///
			(line counterfact year,lp(solid)lw(vthin)lcolor(navy)),				///
			xline(1993, lpattern(shortdash) lcolor(black)) 						///
			xtitle("Año",si(medsmall)) xlabel(#10) 								///
			ytitle("Tasa de encarcelamiento", size(medsmall)) legend(off)		///
			graphregion(fcolor(white))
	
	
	*Efecto
	gen effect=treat-counterfact
	
	twoway (line effect year,lp(solid)lw(vthin)lcolor(black)),				///
		xline(1993, lpattern(shortdash) lcolor(black)) 						///
		xtitle("Año",si(medsmall)) xlabel(#10) 								///
		ytitle("Efecto en la tasa de encarcelamiento", size(medsmall)) legend(off)		///
		graphregion(fcolor(white))


	
	
*) Placebo espacial 
use "${data_cs}/texas.dta", replace
		
synth_runner bmprison bmprison(1990) bmprison(1992) bmprison(1991) 				///
	bmprison(1988) alcohol(1990) aidscapita(1990) aidscapita(1991) 				///
	income ur poverty black(1990) black(1991) black(1992) 						///
	perc1519(1990), trunit(48) trperiod(1993) unitnames(state) 					///
	mspeperiod(1985(1)1992) gen_vars
	
	* P-valor estandarizado de H0: No hay efecto del tratamiento
	di e(pval_joint_post_std)
	
	* P-valores estandarizados para año t de H0: No hay efecto del tratamiento 
	* en t
	mat l e(pvals_std)
	
	* RMSPE para la unidad tratada
	sum pre_rmspe post_rmspe if statefip == 48
	
	* Ajuste de la base
	keep effect year statefip
	reshape wide effect, i(year) j(statefip)
	rename effect48 texas 
		
	* Gráfica
	twoway (line effect1 -effect20 year, lc(gray*0.75 ...) lw(vthin ...))		///
			(line effect21 -effect35 year, lc(gray*0.75 ...) lw(vthin ...))		///
			(line effect36 -effect56 year, lc(gray*0.75 ...) lw(vthin ...))		///
			(line texas year, lc(black)),										///
			legend(off) graphregion(fcolor(white)) 								///
			xline(1993, lpattern(shortdash) lcolor(black))						///
			yline(0, lpattern(shortdash) lcolor(black)) 						///
			xtitle("Año",si(medsmall))
			
