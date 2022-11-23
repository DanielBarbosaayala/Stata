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

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 6"
	 

gl data "${path}/Econ. Av. - COMP/Bases de datos/IV\Angrist & Krueger (1991)"




*********************************************************************************
** CLASE 6 - Endogeneidad y Variables Instrumentales 						   **
*********************************************************************************

use "Salario_IV", clear
describe
	* Outcome de interés (Y): Logaritmo del salario semanal
	* Variable indep. de interés (X): Años de educación.
		/* ¿Cuál es el efecto de la educación sobre el salario?					*/

* 1. Endogeneidad
*-------------------------------------------------------------------------------*

reg lwklywge educ
	/* Un año adicional de educación está relacionado con un aumento en el 
		salario de (0.070*100)%=7%.												   
	   
	   ¿Qué problema tiene esta regresión?
	   
	   Este modelo tiene variable omitida: 
	   La educación es presumiblemente endógena a factores no observados, como
	   la motivación de los individuos y sus habilidades innatas (que también
	   afectan el salario). Luego, en esta estimación de MCO se rompe el 
	   supuesto de independencia condicional y brinda estimadores sesgados e
	   inconsistentes.
	   
	   Solución: Variables Instrumentales										*/

* 2. Variables Instrumentales
*-------------------------------------------------------------------------------*
	
*) Verificación de supuestos	

	* Relevancia						  
	tab qob, gen(trim)
	reg educ trim1, r

	reg educ trim1 i.pob, r
	predict educ_hat // Obtenemos los valores de X predichos.
	test trim1 // test significancia conjunta. SOLO DE VARS INTRUMENTALE, NO CONTROLES
	
		/* El F es mayor a 10, luego se cumple la regla del pulgar. 
		Sin embargo, hay trabajos que muestran que F>10 puede ser insuficiente.
		En particular, se argumenta que si  F es inferior a 104.5, 
		pueden haber serios problemas por cuenta de instrumentos débiles.  
		(ver Lee et al. (2020): https://arxiv.org/pdf/2010.05058.pdf).			*/ 
															
	* Exogeneidad	
		/* En este contexto no se puede probar empíricamente. Para ello 
		   se necesitarían varios (2 o +) instrumentos (prueba de sobreidentifi-
		   cación de Sargent). Esta prueba de sobreidentificación parte del 
		   supuesto de que uno de los instrumentos es exógeno. Por tanto, hay 
		   que tener cuidado con los resultados de la misma.					*/   


*) Segunda etapa

	reg lwklywge educ_hat i.pob
	scalar b0 = _b[_cons] 
	scalar b1 = _b[educ_hat]
	* Guardamos los parámetros estimados. Los vamos a usar luego.

    drop educ_hat
   
   

*) Botstrap: implementación de forma manual

	* Remuestreo aleatorio con remplazo de la base de datos original
	help bsample

	preserve
		bsample 50
		reg lwklywge educ
	restore
	
	* Bootstrap con 100 iteraciones
	matrix define boots = J(100,2,.)
	forvalues i = 1/100 {
		
		* Preservamos la base de datos original 
		preserve
		
			* Remuestreo
			bsample _N
			
			* Estimación de interés
			qui reg educ trim1 i.pob
			qui predict educ_hat
			qui reg lwklywge educ_hat i.pob
			mat boots[`i',1] = _b[_cons] // beta 0 en la iteración i
			mat boots[`i',2] = _b[educ_hat] // beta 1 en la iteración i
		
		restore
	}
		* ¿Qué pasaría si fijáramos una semilla en este proceso


* Visualizar los resultados	
preserve
	clear
	svmat boots
	
	* Histograma de b0
	tw (hist boots1) (kdensity boots1), graphregion(color(white)) 				///
		plotregion(lcolor(black))												///
		ytitle("Densidad") xtitle("{&beta}{sub:0}{sup:MCO}") 					///
		legend(order(1 "Histograma" 2 "Densidad kernel"))					///
		name(b0, replace)														
	
	* Histograma de b1
	tw (hist boots2) (kdensity boots2), graphregion(color(white)) 				///
		plotregion(lcolor(black))												///
		ytitle("Densidad") xtitle("{&beta}{sub:1}{sup:MCO}") 					///
		legend(order(1 "Histograma" 2 "Densidad kernel"))					///
		name(b1, replace)

	* findit grc1leg
	grc1leg b0 b1, graphregion(color(white))

	* Errores estándar
	sum boots1
	local ee = round(r(sd),0.001)
	local t = round(b0/r(sd),0.01)
	local p_val = round(2*ttail(49,b0/r(sd)),0.001)
	
	global nota1 "El error estándar de la constante es `ee'."
	global nota2 "Su t calculado es `t' y el p-valor asociado es `p_val'."
	global nota3 "No es estadísticamente distinto de cero."
	dis "$nota1 $nota2 $nota3"
	
	sum boots2
	local ee = round(r(sd),0.001)
	local t = round(b1/r(sd),0.01)
	local p_val = round(2*ttail(49,b1/r(sd)),0.001)
	
	global nota1 "El error estándar de beta 1 es `ee'."
	global nota2 "Su t calculado es `t' y el p-valor asociado es `p_val'."
	global nota3 "Es estadísitcamente significativo al 1%"
	dis "$nota1 $nota2 $nota3"
	
restore	
	
	
* Bootstrap: creación de un programa
	
		* Definición de un comando
		cap program drop my_iv
		program define my_iv, eclass
		/* La opción "eclass" está indicando que guarde lo de la última 
			estimación en la lista de ereturn.									*/
		
			* 1ra etapa
			reg educ trim1 i.pob, r
			cap drop educ_hat
			predict educ_hat

			* 2da etapa
			reg lwklywge educ_hat i.pob, r
		end
	
		* Bootstrap
		set seed 1234
		bootstrap _b, reps(50): my_iv
		


*) Estimación directa
ivreg2 lwklywge (educ=trim1) i.pob, r first
	/* ivreg2 computa correctamente los errores estándar. Ya podemos hacer infe-
	   rencia estadística de manera segura.
	   
	   A un nivel de significancia del 1% se puede afirmar que, en promedio, un
	   año adicional de educación incrementa el salario semanal en 13.55%
	   para aquellos individuos cuya educación habría incrementado de no haber
	   nacido en el primer trimestre											*/
																			   
reg lwklywge trim1 i.pob, r first