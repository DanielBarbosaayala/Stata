*** CLASE 11: Caso de Estudio: CAMBIO ESTRUCTURAL

* 
*Preparamos stata para trabajar
clear all

cd "C:\Users\carli\Dropbox\Carlos Arturo Ramírez Pinto\Files\Universidad\Maestria\Complementarias\Econometria 1\Clases\Semana 11"

if "`c(username)'" == "veronica"  {
	cd "/Users/veronica/Dropbox/Econometria 1 - 2021-10/Clases complementarias/Clase 11"
}

/* Hoy en la clase vamos a intentar acercanos a la respuesta de dos preguntas **

¿Que rol juega el ingreso del responsable economico del estudiante sobre su puntaje prueba Saber 11?

¿Existe un cambio estructural en el modelo cuando diferenciamos los efectos marginales por sexo? 




Para esto ahora vamos a cargar en nuestro stata una base de datos que contiene información acerca de los puntajes de los estudiantes elegibles al programa Ser Pilo Paga el segundo semestre de 2014, y sus caracteristicas sociodemograficas. 
*/


use base_spp_compl_final, clear

** Inspeccionemos las variables

*describe

d


sum

* ¿Cual es el ingreso promedio de los responsables del hogar? 
* ¿ Qué proporción de la muestra esta compuesta por mujeres?
* ¿ Existe una brecha salarial entre hombres y mujeres en la muestra que observamos?
graph hbox ingreso_responsable, over(sexo_responsable)

* Se puede ver que existe una diferencia entre el ingreso del responsable cuando este es hombre o mujer. Para ver si la diferencia es estadisticamente significativa

ttest ingreso_responsable, by(sexo_responsable)

/* 

	En un principios vamos a considerar unicamente como se relacionan nuestras variables continuas indendientes con el puntaje de la prueba saber 11. Para esto vamos a realizar los siguientes graficos:
	
	
*/

gen edad2=edad^2
gen ingreso_responsable2=ingreso_responsable^2

local variables = "edad ingreso_responsable"
foreach var_ in `variables'{

tw (scatter puntaje_saber11 `var_')|| (lfit puntaje_saber11 `var_'), name(p_`var_', replace) ytitle("Puntaje Saber 11") scheme(s1color) 
*Prueben para ver como se ve con el esquema de colores de la revista The Economist
*scheme(economist)

tw (scatter puntaje_saber11 `var_')|| (qfit puntaje_saber11 `var_'), name(p_`var_'_2, replace) ytitle("Puntaje Saber 11") scheme(s1color) 

*scheme(economist) 

*Stata viene con ciertos prediseños configurados para las graficas. s2color es el clasico de stata. 

}


/*


Teniendo en cuenta las graficas generadas anteriormente, consideran que se deben agregrar las variables de edad e ingreso del responsable al cuadrado. ¿Sí? ¿No?¿Por qué?


*/
************************************************************

/* Teniendo lo que acabamos de explorar en cuenta vamos a plantear el siguiente modelo de regresión lineal para tratar de responder a nuestra primera pregunta: 

			Puntaje_i=b0+b1*edad+b2edad^2+b3*IngresoResp


*/

reg puntaje_saber11 edad c.edad#c.edad ingreso_responsable
cap drop edad2
gen edad2=edad^2

reg puntaje_saber11 edad edad2 ingreso_responsable

*¿Existe alguna diferencia entre la especificación de alguna de estas dos regresiones?

*¿Que podemos concluir a partir de ellas? 
*¿Que rol juega el ingreso? 
*¿Es acorde con lo que esperabamos?

**** CAMBIO ESTRUCTURAL

/*

	Ahora vamos a considerar la posibilidad de que nuestro tenga cambio estructural de acuerdos a los valores de la variable de sexo del responsable economico. Esto que implica:
	
	- Cambio estructural en el intercepto: Un cambio estructural en el intercepto significa que el valor que podriamos esperar de la prueba saber 11 es distintas para aquellos estudiantes cuyos responsables economicos es de sexo masculino vs aquellos estudiantes para quienes el responsable economico es de sexo femenino. 
	
	- Cambio estructural en las pendientes: Implica que los efectos marginales de nuestras variables, en este caso edad e ingreso del responsable economico, son distintos dependiendo del sexo del responsable. 
	
	
Generalmente, estos cambios deben estar sustentados en la literatura y estudios previos que se hayan realizado respecto al tema. En este caso, nos centraremos unicamente en evaluar si empiricamente se observan dichos cambios en la muestra. 

Para evaluar si existe cambio estructural en el modelo, realizaremos el procedimiento de testeo de la Prueba de Chow. Esta consiste en estimar un modelo para 3 muestras distintas, en este caso la primera muestra será la de aquellos estudiantes cuyos responsables economicos sean de sexo masculino, la segunda muestra será la de aquellos estudiantes cuyo responsable economico sea de sexo femenino y la tercera para todos los individuos que hacen parte de nuestra muestra. Posteriormente evaluaremos si los coeficientes estimados del modelo para un grupo son significativamente distintos de los del otro. Es decir:

	H0:
	- beta0 grupo sexo_responsable=1 = beta0 grupo sexo_responsable=0
	- beta1 grupo sexo_responsable=1 = beta1 grupo sexo_responsable=0
	- beta2 grupo sexo_responsable=1 = beta2 grupo sexo_responsable=0
	- beta3 grupo sexo_responsable=1 = beta3 grupo sexo_responsable=0
	
	Ha: 
	
	- Al menos algunos de los coeficientes es distinto entre los grupos. 



*/

* Regresión para grupo de sexo_responsable==1
reg puntaje_saber11 edad edad2 ingreso_responsable if sexo_responsable==1
scalar SCR_1=e(rss)
scalar N_1=e(N)
scalar K_1=e(df_m)
* Regresión para grupo de sexo_responsable==0
reg puntaje_saber11 edad edad2 ingreso_responsable if sexo_responsable==0
scalar SCR_0=e(rss)
scalar N_0=e(N)
scalar K_0=e(df_m)

* Regresión para todos los individuos
reg puntaje_saber11 edad edad2 ingreso_responsable 
scalar SCR=e(rss)
scalar N=e(N)
scalar K=e(df_m)



scalar num=(SCR-(SCR_1+SCR_0))/(K+1)
scalar denom=(SCR_0+SCR_1)/(N_0+N_1-2*(K+1))
scalar F_chow= (num/denom)
dis F_chow

scalar pvalue= Ftail(K,N_0+N_1-2*(K+1),F_chow)
dis pvalue

* ¿ Qué podemos decir al respecto? 

**  Una forma de ver este mismo resultado de forma conjunta, es correr el siguiente modelo.

reg puntaje_saber11 i.sexo_responsable##c.edad i.sexo_responsable##c.edad2 i.sexo_responsable##c.ingreso_responsable i.sexo_responsable

* Con esta prueba queremos ver si existe alguna diferencia estadisticamente significativa entre los efectos marginales de las variables de un grupo vs los del otro de forma conjunta, teniendo en cuenta el intercepto. 

test (1.sexo_responsable) (1.sexo_responsable#c.edad) (1.sexo_responsable#c.ingreso_responsable) (1.sexo_responsable#c.edad2)

*Sin embargo, la diferencia no es significativa para todas las variables en la prueba individual. Esto debería poder verse graficamente

tw (scatter puntaje_saber11 ingreso_responsable if sexo_responsable==0, mlc(blue) mfc(blue%25)) ///
(scatter puntaje_saber11 ingreso_responsable if sexo_responsable==1, mlcolor(purple) mfcolor(purple%25)) (lfit puntaje_saber11 ingreso_responsable if sexo_responsable==0) ///  
(lfit puntaje_saber11 ingreso_responsable if sexo_responsable==1) 


tw (scatter puntaje_saber11 edad if sexo_responsable==0, mlc(blue) mfc(blue%25)) ///
(scatter puntaje_saber11 edad if sexo_responsable==1, mlcolor(purple) mfcolor(purple%25)) (qfit puntaje_saber11 edad if sexo_responsable==0) ///  
(qfit puntaje_saber11 edad if sexo_responsable==1) 

** Esto nos confirma que en principio no se observan en la muestra efectos marginales distintos en las edades cuando diferenciamos por el sexo del responsbale economico. 
* Sin embargo, existen otras variables categoricas en nuestra base de datos que nos pueden mostrar que existe heterogeneidad en los efectos. 

* ¿ Creerían ustedes que existen diferencias en los efectos marginales de la edad cuando diferenciamos por el sexo del estudiante? 
tw (scatter puntaje_saber11 edad if mujer==0, mlc(blue) mfc(blue%25)) ///
(scatter puntaje_saber11 edad if mujer==1, mlcolor(purple) mfcolor(purple%25)) (qfit puntaje_saber11 edad if mujer==0) ///  
(qfit puntaje_saber11 edad if mujer==1) 


reg puntaje_saber11 i.mujer##c.edad i.mujer##c.edad2 i.sexo_responsable##c.ingreso_responsable i.sexo_responsable

/*
	
	El proceso de analizar heterogeneidad de los efectos marginales se puede extender tanto como el número de categorias en las variables categoricas de nuestra base de datos, pero no necesariamente todas son relevantes. Por ello, todos las interacciones que incluyamos en nuestro modelo deben ser sustentadas por la literatura o la evidencia empirica previa.  
	
	
*/
