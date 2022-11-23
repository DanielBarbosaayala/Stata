* Econometría Avanzada
* Clase Complementaria
* 2022-2
clear all
cap log close
set more off
cls 

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 05"

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
	 

gl data "${path}/Econ. Av. - COMP/Bases de datos/RDN"


*********************************************************************************
** CLASE 5 - RDN 						     								   **
*********************************************************************************

* 1. Regresión Discontinua Nítida (RDN)
* -------------------------------------------------------------------------------
/* 																			   */
use "${data}/Elecciones_Turquía", clear
describe
	* Outcome de interés (Y): Proporción de mujeres entre 15-20 años con 
	* 	educación media en el año 2000.
	* Variable indep. de interés (T): Elección de alcalde proveniente de un 
	* 	partido islámico en las elecciones de 1994.
	* Running variable (X): Margen de votos con la que ganó (o perdió) el
	*	candidato islámico en las elecciones de 1994.
		/* ¿Qué impacto tiene la llegada al poder de un alcalde islámico sobre 
			el acceso a educación de las mujeres? 								*/
			
*) Discontinuidad en la probabilidad de tratamiento
twoway (scatter T X if X<0, mfcolor(gray%80*0.7) mlcolor(gray%80)) 			///
	(scatter T X if X>=0, mfcolor(gray%80*0.7) mlcolor(gray%80)) 			///
	(lfit T X if X<0, lcolor(black)) 										///
	(lfit T X if X>=0, lcolor(black)), 										///
	xline(0, lcolor(black)) graphregion(fcolor(white)) legend(off)			///
	xtitle("Margen de votos") ytitle("Probabilidad de ser tratado")
	/* Esto nos indica que estamos en el mundo de regresión discontinua nítida 
 	   y que la asignación al tratamiento corresponde exactamente a la 
	   condición de tratamiento efectiva.									   */

* 1.1. Estimación ingenua: RLS = Diferencia de medias
*-------------------------------------------------------------------------------*
reg Y T 
	/* Este resultado preliminar sugiere que en los municipios donde el alcalde
		no es islamico, hay mayor proporción de mujeres entre 15-20 años
		que tienen educación media.
		
		¿Es este efecto razonablemente causal? ¿Por qué?	
		
		Estamos comparando municipios muy distintos entre ellos. En particular, 
		que un municipio elija un alcalde islámico no es aleatorio. Por ejemplo, 
		los candidatos islámicos tienden a tener más afinidades con creencias
		conservadoras respecto al papel de la mujer. Por tanto, es más probable 
		la elección de un alcalde islámico es plausible que también sean 
		aquellos en los que la participación de la mujer en la política y la 
		educación esté más restringida.											*/

*) Balance muestral
global controles ageshr19 ageshr60 buyuk hischshr1520m i89 lpop1994 merkezi 	///
	merkezp partycount sexr shhs subbuyuk vshr_islam1994

reg T ${controles}
test ${controles}

/* Las características observables explican el tratamiento. Es decir, los 
   municipios son muy distintos en características observables y, por tanto,
   es razonable que también lo sean en caractarísticas no observables.	
   
   Solución: Comparar a municipios que eligieron un alcalde islámico con los que 
			 eligieron uno no islámico que sean razonablemente similares. Para 
			 esto podemos comparar municpios en los que el alcalde ganó por una 
			 baja diferencia en los votos. Es decir, vamos a comparar aquellos 
			 municipios en que el candidato islámico ganó por pocos votos con 
			 aquellos municipios en los que el candidato islámico perdió por 
			 unos pocos votos			 						               */
																	   
* 1.2. Implementación de RDN
*-------------------------------------------------------------------------------*																	   
*) Descripción de RDN
ssc install rdrobust, replace
*ssc install rddensity, replace

*) Verificación de supuestos			

	* 1. Continuidad local
	* Aproximación gráfica
	rdplot lpop1994 X, p(2) binselect("es")										///
	graph_options(xtitle("Margen de Victoria del Alcalde Islamico") 			///
		name(vshr_islam1994, replace) graphregion(fcolor(white)) legend(off))	
		
	* Aproximación de diferencias de medias (en distintas vecindades)
	ttest lpop1994 if inrange(X,-0.5,0.5), by(T) 	
	ttest lpop1994 if inrange(X,-0.25,0.25), by(T) 	
	ttest lpop1994 if inrange(X,-0.1,0.1), by(T) 
	
	* 2. No manipulación
	kdensity X, xline(0,lcol(red) lp("--")) lcol(black)	
	
	rddensity X
	rddensity X, plot  graph_opt(title("Test de manipulación") 					///
		xtitle("Margen de Victoria del Alcalde Islamico")   					///
		ytitle("Densidad de la variable de focalización")  						///
		scheme(s1mono) legend(off) graphregion(fcolor(white))) 
	
	
*) Estimaciones

	* 1. Paramétricas ----------------------------------------------------------
				  
	* Polinomio grado cero alrededor del corte 
	reg Y T if inrange(X,-0.240,0.240)
	reg Y T ${controles} if inrange(X,-0.240,0.240)

	* Polinomio grado uno igual a ambos lados alrededor del corte
	reg Y T X if inrange(X,-0.240,0.240)
	
	* Polinomio grado uno diferente a ambos lados alrededor del corte
	gen T_X=X*T
	reg Y T X T_X if inrange(X,-0.240,0.240)
	/* La elección de un alcalde islámico genera un aumento del 3.2pp en la 
	proporción de mujeres entre 15-20 años en los municipios en los que ganó
	un candidato islámico con respecto a los municipios en los que perdió el 
	candidato islámico, dentro de un ancho de banda 0.24. Dado que el promedio
	de la variable dependiente es 0.163, el efecto estimado corresponde a un
	incremento del 20% (0.032/0.163) en la participación educativa de las
	mujeres con respecto a la media.											*/
	
	* Polinomio de grado dos igual a ambos lados alrededor del corte
	gen X2=X^2
	reg Y T X X2 if inrange(X,-0.240,0.240)
	
	* Polinomio de grado dos diferente a ambos lados alrededor del corte
	gen T_X2=X2*T 
	reg Y T X X2 T_X T_X2 if inrange(X,-0.3,0.3)
	
	
	* 2. No paramétricas -------------------------------------------------------
	
	* Estimación no paramétrica: default es kernel triangular, polinomio de
	* grado 1, coeficientes sin corrección de sesgo.
	
	rdrobust Y X
	
	* Polinomio de grado 2, con kernel triangular, coeficientes insesgados y
	* con errores robustos (los errores robustos incorporan tanto la varianza
	* asociada a la estimación de la discontinuidad como a la estimación del 
	* sesgo, por lo que son los errores correctos para inferencia)
	
	rdrobust Y X, p(2) all
	
	*Polinomio de grado 2, con kernel uniforme en la banda (-0.3,0.3)
	
	rdrobust Y X, p(2) all kernel(uniform) h(0.3)
	
	* Note que la estimación sin corrección del sesgo con el kernel unforme
	* coincide con el MCO-> los polinomios locales son una generalización de MCO
	* con distintos pesos.
		

/* ¡El resultado es positivo! En Turquía, un estado laico con instituciones edu-
    cativas públicas y privadas del mismo caracter se prohíben las expresiones
	religiosas, tales como el llevar la cabeza cubierta con un hiyab. Esto, en 
	realidad, es una barrera a la entrada para, en este caso, mujeres islámicas.
	Así, con la llegada de un alcalde puede que esas prohibiciones puedan entrar
	en discusión o puede que se construyan instituciones educativas islámicas en 
	las que las expresiones religiosas, como el uso del hiyab, no estén prohibi-
	das. De esta manera, barreras a la entrada para mujeres islámicas al sistema
	educativo son disminuidas.												   */
	
*********************************************************************************
** Ejercicio 1: Haga su propio rdplot usando el comando scatter. Es decir,     **
** 	debe graficar la discontinuidad estimada de la variable de resultado.	   **
** 	Presente una gráfica que ilustre su relación de interés (T->Y). 		   **
** 	Pista: revise la opción genvars del comando rdplot						   **
********************************************************************************* 
cap drop rdplot_*
rdplot Y X, c(0) p(4) genvars													///
	graph_options(graphregion(color(white)) legend(off)						 	///
	 xti("Margen de votos islámicos") yti("Educación de la mujer")))  
	
scatter rdplot_mean_y rdplot_mean_x, mcolor(gray) ||							///
	qfit rdplot_hat_y rdplot_mean_x if rdplot_mean_x>=0, lcolor(black)	||		///
	qfit rdplot_hat_y rdplot_mean_x if rdplot_mean_x<=0, lcolor(black)  		///
	xline(0, lcolor(red) lp("-")) graphregion(color(white)) legend(off)			///
	xti("Margen de votos islámicos") yti("Educación de la mujer")
	
*********************************************************************************
** Ejercicio 2: La aproximación de diferencias de medias para verificar
** el cumplimiento de continuidad local en covariables no es la mejor. Esto
** dado que la diferencia de medias supone una relazión constante entre las 
** covariables y la variable de focalización. Así, lo mejor es estimar
** el efecto del tratamiento en el corte para las demás covariables sobre las 
** cuales no debería haber efecto. Corroboren que hay continuidad local
** estimando el efecto de del tratamiento sobre las covariables de forma no
** paramétrica.
*********************************************************************************
foreach x in $controles {	
	rdrobust `x' X	
}

	
*-------------------------------------------------------------------------------*
* Fin del Do-file
