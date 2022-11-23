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

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 10"

gl data "${path}/Econ. Av. - COMP/Bases de datos"


*********************************************************************************
** CLASE 10 - DIFERENCIAS EN DIFERENCIAS									   **
*********************************************************************************

* 1. Diferencias en Diferencias en datos panel
* ------------------------------------------------------------------------------
use "Data_expo_SV_siria.dta", clear
describe 

	* Outcome de interés (Num_countries): Numero de paises a los que exporta
		* la compañia 
	* Variable de grupo (ChoqueSiria): = 1 si  mas del 50% de las exportaciones 
		 * de la compañia son a Siria y por ende estan espuestos al choque 
		 * politico.
	* Variable de tiempo (Post): =1 si estan en presencia de la crisis politica
		* en siria, 0 dlc
																			   
	/* ¿Cuál es el efecto choques políticos internacionales (Crisis politica en 
	Siria) sobre las firmas exportadoras (Numero de paises a los que exportan 
	las empresas)?*/
		
*) Estadísticas descriptivas

	* Variable post
	tab qdate post, m

	* Variable tratamiento
	tab qdate choquesiria

	* Evolución de los grupos en el tiempo: 

	/* Tarea: Revisar el código de la siguiente gráfica. 
				El comando grstyle le permite fijar el estilo de todas sus 
				gráficas en un do-file.											*/
	
	*ssc install grstyle		
	grstyle init
	grstyle set plain, horizontal nogrid noextend box		  
			  
	preserve 
		collapse Num_countries, by(qdate choquesiria)
		
		reshape wide Num_countries, i(qdate) j(choquesiria) 
				
		tw (connected Num_countries0 qdate, msize(vsmall) msymbol(D) lcolor(black)		///
			mcolor(black) recast(connected) lpattern("-") xaxis(1 2)) 					/// 
		   (connected Num_countries1 qdate, msize(vsmall) msymbol(O) lcolor(gray) 		///
			 mcolor(gray) recast(connected)  xaxis(1 2)), 								///
				 name(`xvar'_2, replace)												///		 
				 ytitle("`lab_var'", size(*.75))										///
				 xtitle("trimestre")													///
				 xtitle("", axis(2))													///
				 xline(204, lp(shortdash))												///
				 xlabel(184(4)223, axis(1))												///
				 xscale(range(184 223)) 												///
				 xlabel(204 "Crisis politica Siria", axis(2) labsize(*.7)) 				///		 
				 ylabel(, format(%9.1fc) labsize(*.75)) 								///
				 legend(region(color(white)) size(small)								///
				 order(1 "No expuesto choque siria"  2 "Expuesto al choque de Siria"))  ///
				 xscale(lstyle(none)) 	 yscale(lstyle(none))							///
				 ytitle("Numero de paises a los que exportan")
	restore 

*) Modelo estático

	*Declarar el Panel
	xtset ID_firma qdate, q

	* DD 2x2
	reg Num_countries choquesiria##post, cluster(ID_firma)
		
		local beta = round(_b[1.choquesiria#1.post],0.001)
		local nota1 "El número promedio de países a los que exportaban las firmas"
		local nota2 "fuertemente conectadas a Siria (i.e., tratadas) incrementó"
		local nota3 "en `beta' unidades producto del choque a Siria."
		local nota4 "Este efecto es estadísticamente significativo al 1%."
		di "`nota1' `nota2' `nota3' `nota4'."

	* Nota: Es importante hacer cluster a nivel de la unidad de análisis si
	* se cree que hay efectos heterogéneos.
	
	* Ver: Abadie, Athey, Imbens, Wooldridge (2017) : 
	* "WHEN SHOULD YOU ADJUST STANDARD ERRORS FOR CLUSTERING?"
	* https://www.nber.org/system/files/working_papers/w24003/w24003.pdf
	
	
	* DD TWFE- Efecto fijo de firma y tiempo		
	reghdfe Num_countries 1.choquesiria#1.post, a(qdate ID_firma) 				///
		cluster(ID_firma)
	
	* DD TWFE- Efecto fijo de firma y tiempo/industria
	egen industria_tiempo = group(qdate main_sector_2)
	reghdfe Num_countries 1.choquesiria#1.post, a(industria_tiempo ID_firma) 	///
		cluster(ID_firma)
	
*) Modelo dinámico

	* Crear dummies para cada año
	tab qdate, gen(time_) 	
		
	* Dummies con labels del año
	local j = 1	
	forval i = 1(1)40 {

		local y = floor((`i'-1)/4)
		local k = 2006 + `y'
		local q = mod(`i',4)
	
		cap drop TX_time_`j'
		gen TX_time_`j' = time_`j'*choquesiria
	
	
		if `q' == 0 {
	
			local lbl = "`k'"+"q"+"4"
			label var TX_time_`j' "`lbl'"	

		}
	
		else {
	
			local lbl= "`k'"+"q"+"`q'"
			label var TX_time_`j' "`lbl'"	
	
		}
	
		drop time_`j'
		local ++j
		
	}	

	
	* Periodo base 2011q2
	replace TX_time_22 = 0 

	* Estimación dinámica	
	reghdfe Num_countries TX*, a(industria_tiempo ID_firma) cl(ID_firma)
	estimates store coefs2

	* Gráfica
	coefplot coefs2, omitted										     		///
		 vertical 												 				///
		 drop(_cons)											  				///
		 label 													  				///
		 yline(0, lpattern(dash) lwidth(*0.5))   				  				///
		 ytitle("Coeficiente")									  				///
		 xtitle("Año-Trimestre", size(medsmall))			 				  	///
		 xlabel(, labsize(small) nogextend labc(black) angle(vertical)) 		///
		 ylabel(,nogrid nogextend labc(black) format(%9.2f)) 	  				///
		 msymbol(O) 											  				///
		 graphregion(color(white)) bgcolor(white) scheme(s2mono) 				///		
		 msize(vsmall) 											  				///
		 levels(95) 											  				///
		 xline(23, lpattern(dash))								  				///
		  ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 			 			///
		 plotregion(lcolor(white) fcolor(white))  				  				///
		 graphregion(lcolor(white) fcolor(white))  				  				///
		 yscale(lc(black)) 										  				///
		 xscale(lc(black)) 										  				///
		 name(Regresion_Dinamica, replace)	
	
* 2. Diferencias en Diferencias con cortes transversales repetidos
* -------------------------------------------------------------------------------
use "${data}/DiD/Petróleo (DiD Cross Section)/petroleo.dta", clear
describe

	* Outcome de interés (Y): Puntaje z de la estatura según la edad
	*   Tratamiento (D): Aumento de ingreso municipal por regalías (encontrar 
	*					petroleo)

/* Supuestos de identificación: 
	1. Tendencias paralelas.
	2. Todos los individuos de un corte transversal pueden ser usados como 
	   'sustitutos' de los individuos de otro corte transversal.
	   
	   - Este último se cumple si los cortes transversales usados son 
		 muestras aleatorias (representativas) de la misma población.
																				*/

*) Estimación en formato Long (¡OJO! no es Panel): En niveles

	* Caso base 2x2
	reg ha_nchs D##t, r
	
	* Caso base con controles
	global X educa_jefe orden_n hombre ocupado_jefe personas ingresos_hogar_jefe
	reg ha_nchs D##t $X					 

*-------------------------------------------------------------------------------*
* Fin del Do-file
	