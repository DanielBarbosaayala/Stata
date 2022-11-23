* Econometría Avanzada
* Clase Complementaria
* 2022-2
clear all
cap log close
set more off
cls 

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 11" // revisar carpeta

if "`c(username)'"=="storr"{
	cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:/Users/torre/OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Dac12"{
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:\Users\Dac12\OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="valentinacastillagutierrez"{
	cd "/Users/valentinacastillagutierrez/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}"
	gl path "/Users/valentinacastillagutierrez/Library/CloudStorage/OneDrive-UniversidaddelosAndes"
} 
else gl data "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 11\"



*********************************************************************************
** CLASE 11 - EVENT STUDY 								 		    		   **
*********************************************************************************
use "${data}\mpdata.dta", clear
describe 
	* Outcome de interés (Y): Log del número de jóvenes empleados
	* Variable de grupo (D): =1 si el condado incrementó el salario mínimo, 0 dlc
																			   
	/* ¿Cuál es el efecto de incerementar el salario mínimo en la tasa de empleo?	*/
	

* 1. Estimadores clásicos
*===============================================================================*

** Nota: Para aplicar los estimadores es importante que el formato del panel
*  sea  tipo "long" no tipo "wide".

* 1.1. Modelo estático - TWFE
*-------------------------------------------------------------------------------*
*) Declarar el panel
order countyreal year
xtset countyreal year, y

*) Variable de tratamiento
gen Dit = (year >= firsttreat & firsttreat!=0)

*) Ejemplo de codificación
br if countyreal==12019	

*) Estimación MCO

reghdfe lemp Dit, absorb(countyreal year) cluster(countyreal) nocon

*** El efecto que sugiere el modelo es negativo:
** Aumentar el salario representa una disminución del empleo de 3.6%.

** ¿Es creíble esta estimación? ¡No, pues es muy probable que existan efectos
* de tratamiento dinámicos! 


* 1.2. Modelo dinámico - TWFE
*-------------------------------------------------------------------------------*
*) Creamos una variable que nos indique el tiempo relativo

gen rel_time=year-firsttreat

*El tiempo relativo no está definido para nunca tratados
replace rel_time=. if firsttreat==0 

*) Generamos dummies para cada categoría posible de tiempos relativos

tab rel_time, gen(evt)


*) Cambiamos los labels y los nombres para no confundirnos

*Leads

forvalues x = 1/4 {
    
    local j= 5-`x'
	ren evt`x' evt_l`j'
	cap label var evt_l`j' "-`j'" 
}


*Lags

forvalues x = 0/3 {
    
    local j= 5+`x'
	ren evt`j' evt_f`x'
	cap label var evt_f`x' "`x'"  
}


*) Periodo base - Omitir por multicolinealidad

replace evt_l1=0
	
*) Estimación

reghdfe lemp evt_l3 evt_l2 evt_l1 evt_f*, nocon absorb(countyreal year) cluster(countyreal) 

estimates store coefs_i
	
*) Gráfica
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Log número de empleos jóvenes")                                     ///
	xtitle("Tiempo relativo al tratamiento", size(medsmall))			 		///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(4, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(Salario_i, replace)
	/*	Note que no hay IC para la dummy del tiempo -1 (no tiene error
		estándar), esto se debe a que es nuestro periodo de referencia. 
		Es decir, los coeficientes se interpretan con respecto a dicho periodo. */	
		
*) Pruebas de hipótesis
estimates restore coefs_i
test evt_l1 evt_l2 evt_l3  /* No hay efectos anticipatorios 			*/
test evt_f0 evt_f1 evt_f2 evt_f3 /* Hay efectos dinámicos				*/


* 2. Nuevos estimadores 
*===============================================================================*

* 2.1. Callaway & Sant'Anna (2021)
*-------------------------------------------------------------------------------*
ssc install ereplace

*) Estimación
net install csdid, from ("https://raw.githubusercontent.com/friosavila/csdid_drdid/main/code/") replace

csdid lemp, ivar(countyreal) time(year) gvar(firsttreat)  		
	
* Con controles

csdid lemp lpop, ivar(countyreal) time(year) gvar(firsttreat) 
	
*) Gráfica
/* Para ver el efecto en cada cohorte, vemos los ATT(g,t)'s */

qui csdid lemp, ivar(countyreal) time(year) gvar(firsttreat)  		

csdid_plot, group(2004)
csdid_plot, group(2006)
csdid_plot, group(2007)

	
*) Agregación de resultados

* Todas los tipos de agregaciones
estat all

* ATT promedio para cada cohorte
estat group
csdid_plot

* ATT cada periodo (i.e., cada ola para la cual se puede calcular)
estat calendar
csdid_plot

* ATT dinámico (i.e., como el estudio de evento)
estat event
csdid_plot

/* Alternativamente, se puede solicitar la agregación directamente a partir de
   la estimación. Por ejemplo:
   csdid lemp, ivar(countyreal) time(year) gvar(firsttreat)  agg(group)
   csdid lemp, ivar(countyreal) time(year) gvar(firsttreat)  agg(calendar)
   csdid lemp, ivar(countyreal) time(year) gvar(firsttreat)  agg(event)		   */

* 2.2. Sun & Abraham (2020)	
*-------------------------------------------------------------------------------*

*) Estimación
ssc install eventstudyinteract
ssc install avar
set matsize 800

gen never=(firsttreat==0)

eventstudyinteract lemp evt_l* evt_f*, 	                 ///
	absorb(countyreal) cohort(firsttreat) ///
	control_cohort(never) vce(cluster i.countyreal)

*) Gráfica
* Tarea: Revisar el siguiente código
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) vertical graphregion(color(white))				///
	plotregion(lcolor(black)) yline(0, lcolor(maroon) lpattern(-))				///
	ytitle("Log número de empleos jóvenes")										///
	xtitle("Tiempo relativo al tratamiento", size(medsmall))			 		///
	xline(5,lpattern(dash))														///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			

* 2.3. Todos los estimadores - Anexo	
*-------------------------------------------------------------------------------*

* Este código es tomado de Fernando Rios-Avila:
* https://github.com/friosavila/Compare-DiD-Estimators
* Necesitan instalar lo siguiente:
/*
- did_imputation: ssc install did_imputation
- event_plot: ssc install event_plot
- bacondecomp: ssc install bacondecomp
- did_multiplegt: ssc install did_multiplegt
*/	

ssc install did_imputation
ssc install event_plot
ssc install bacondecomp
ssc install did_multiplegt

gen gvar2 = cond(firsttreat==0, ., firsttreat) // Algunos estimadores requieren 
*que los nuevos tratados estén en missing y no en 0

 
rename evt_l1 ref  // reference year

* Globals importantes

global post 3 /* Número de periodos post sin contar el 0*/
global pre 3 /* Número de periodos pre*/
global ep event_plot
global g0 "default_look"
global g1 xla(-$pre (1) $post) /*global g1 xla(-5(1)5)*/
global g2 xt("Periodos relativos al evento")
global g3 yt("Efecto causal")
global g  $g1 $g2 $g3
global t "together"

// Estimación con did_imputation de Borusyak et al. (2021)

did_imputation lemp countyreal year firsttreat, horizons(0/$post) autosample pretrend($pre) minn(0) 

estimates store bjs // storing the estimates for later
$ep bjs, $t $g0 graph_opt($g ti("BJS 21") name(gBJS, replace))

// Estimación con did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020)

did_multiplegt lemp countyreal year Dit, robust_dynamic dynamic($post) placebo($pre) breps(20) cluster(countyreal) 
event_plot e(estimates)#e(variances), stub_lag(Effect_#) stub_lead(Placebo_#) $t $g0 graph_opt($g ti("CD 20") name(gCD, replace))
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

// Estimación con csdid of Callaway and Sant'Anna (2020)
csdid lemp, ivar(countyreal) time(year) gvar(firsttreat)  		
estat event, estore(cs) // this produces and stores the estimates at the same time
$ep cs, stub_lag(Tp#) stub_lead(Tm#) $t $g0 graph_opt($g ti("CS 20") name(gCS, replace))

// Estimación con eventstudyinteract of Sun and Abraham (2020)


eventstudyinteract lemp evt_l* evt_f*, 	                 ///
	absorb(countyreal) cohort(firsttreat) ///
	control_cohort(never) vce(cluster i.countyreal)
$ep e(b_iw)#e(V_iw), stub_lag(evt_f#) stub_lead(evt_l#) $t $g0 graph_opt($g ti("SA 20")  name(gSA, replace)) 
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

// Estimación por TWFE

reghdfe lemp evt_l3 evt_l2 ref evt_f*, nocon absorb(countyreal year) cluster(countyreal) 
estimates store ols // saving the estimates for later
$ep ols,  stub_lag(evt_f#) stub_lead(evt_l#) $t $g0 graph_opt($g ti("OLS") name(gOLS, replace))  


/* Descomposición de Goodman-Bacon */
bacondecomp lemp Dit, ddetail gropt(legend(off) name(gGB, replace))

/* gY gBJS gCD gCS gSA gOLS gGB gG gCDLZ */
graph combine gOLS gGB gBJS gCD gCS gSA, ycommon name(combined, replace)


// Combine all plots using the stored estimates
event_plot /// 
bjs  dcdh_b#dcdh_v cs sa_b#sa_v  ols, ///
	stub_lag( tau# Effect_# Tp# evt_f#  evt_f#) ///
	stub_lead( pre# Placebo_#  Tm# evt_l# evt_l# ) ///
	plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.1)0.325) trimlead(5) noautolegend ///
	graph_opt(  ///
	title("Todos los estimadores de estudios de evento", size(med)) ///
	xtitle("Periodos relativos al evento", size(small)) ///
	ytitle("Efecto causal promedio estimado", size(small)) xlabel(-$pre(1)$post)  ///
	legend(order(1 "BJS" 3 "dCdH" ///
				5 "CS" 7 "SA" 9 "TWFE") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) 	///
	lag_opt1(msymbol(+) color(black)) lag_ci_opt1(color(black)) ///
	lag_opt2(msymbol(O) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) ///
	lag_opt5(msymbol(Sh) color(dkorange)) lag_ci_opt5(color(dkorange))

	
	
*-------------------------------------------------------------------------------*
* Fin del Do-file























