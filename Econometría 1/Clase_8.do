* Clase 8. 2021-1
* ¿Cómo impactan los años de educación el salario?
* Variables de control y modelos no lineales 

clear all
set more off

*Directorio: carpeta de econometria
cd "/Users/sofiacastro/Dropbox/Econometria 1 - 2021-10/Clases complementarias/Clase 8"

*** Efectos marginales variables y loops

*Abrimos la base de datos:
use "runners.dta", clear
	*La base runners es una base de datos que nos muestra los diferentes tiempos de deportistas de 100 metros planos, con la cual nos podemos hacer la pregunta de si la estatura influye en el tiempo que demoran los deportistas en completar la carrera de los 100 m. 

*Primero analizamos la diferencia de estatura entre hombres y mujeres
sum estatura if hombre==1
sum estatura if hombre=0

	*Con un loop podríamos hacer los dos pasos de arriba ^
forvalues x=0(1)1 {
display "`x'"
sum estatura if hombre==`x'
}
*¿Que nos dice esta información acerca de la diferencia en estatura entre hombres y mujeres?

*También podemos observar estas diferencias gráficamente:
twoway hist estatura if hombre, color(pink%40)|| hist estatura if !hombre, frac color(navy%75) legend(order(1 "Hombre" 2 "Mujer")) graphregion(color(white))

*Ahora miramos la relación entre el tiempo y la estatura
scatter tiempo estatura 

*Un ajuste lineal nos muestra que los deportistas más altos son los más veloces, pero la recta no parece explicar los datos de forma correcta. El error crece mucho para los valores extremos (muy bajitos o muy altos)
twoway (scatter tiempo estatura) (lfitci tiempo estatura), graphregion(color(white)) saving(graph1) // La opción saving guarda el grafico como .gph por default

*¿Que tipo de relación podría ajustarse mejor a los datos?

*Miramos el grafico con qfitci
twoway (scatter tiempo estatura) (qfitci tiempo estatura), graphregion(color(white)) saving(graph2)

graph combine graph1.gph graph2.gph

*La única diferencia entre ambos graficos es el lfitci, luego podemos usar un loop para no escribir lo mismo dos veces.
foreach x in lfitci qfitci {
twoway (scatter tiempo estatura) (`x' tiempo estatura), graphregion(color(white)) saving(`x') 
}
*Y luego el graph combine
graph combine lfitci.gph qfitci.gph

*Ya notamos que la relación parece ser cuadratica, entonces, pasamos al análisis de regresión como tal. 

*Creamos la variable al cuadrado y corramos la regresión
gen estatura2 = estatura^2
reg tiempo estatura

*Antes de correr el modelo ¿Qué signos esperamos para B1 y B2?
reg tiempo estatura estatura2
* ¿Cómo interpretamos el efecto de la estatura en la marca? 
*Se analiza desde la media de la variable X. Es importante notar que el efecto marginal no es constante.

* ¿Pero los hombres y las mujeres aquí qué?
graph twoway scatter tiempo estatura if hombre, color(pink%20) || scatter tiempo estatura if !hombre, color(navy%20) legend(order(1 "Hombre" 2 "Mujer")) graphregion(color(white))

*A primera vista pareciera que los hombres son más rapidos que las mujeres.
reg tiempo hombre

*Sabemos que la estatura también es un factor importante para explicar el tiempo que se demoran los deportistas en terminar la carrera, luego debemos incluir ambas variables en nuestra regresión:

reg tiempo hombre estatura estatura2
*¿Que sucede con el coeficientes asociado a la variable hombre?
*¿Por que pasa esto? - BONO TALLER

/////

*Ahora vamos a usar datos reales, también para analizar relaciones cuadráticas.
bcuse wage2, clear
* Importamos una base de datos con información sobre el salario mensual y factores que podrían explicarlo para una muestra de 935 personas en EEUU

* Note que nuestra variable de interés el salario, y esta a nivel mensual. Luego puede haber gente que esté trabajando tiempo completo, medio tiempo, un cuarto de tiempo, etc.
* Para realmente comparar peras con peras y manzanas con manzanas, convirtamos el salario mensual a salario por horas
gen wage_h = wage/hours

* Veamos la distribución de nuestra variable
sum wage_h
local m = r(mean)
*Recuerde correr los locals al tiempo con el comando que los utiliza
twoway hist wage_h, frac bcolor(navy%90) xline(`m') graphregion(color(white)) // La genta gana más o menos 20 dolares la hora
   
* También podemos ver si hay una relación cuadratica de estas variables contra el salario por horas
foreach i of varlist educ IQ exper tenure age feduc meduc brthord sibs {
twoway (scatter wage_h `i') (qfit wage_h `i'), name(`i', replace) 
}
* El efecto marginal no se ve muy significativo y diferente de 0

*La educación parece tener un efecto cuadratico sobre el salario.

reg wage_h educ // Vemos que la educación explica el salario. 
* Vemos que esta relación es lineal. Si la cambiamos pierde su significancia
gen educ2 = educ^2
reg wage_h educ educ2
	*Cómo interpretarían esos coeficientes?

*Ahora estimamos un modelo más completo, por ejemplo:
reg wage_h educ educ2 exper IQ tenure age feduc
	*¿Cómo podemos interpretar esta regresión?

** Ejercicio de loops:
*Queremos guardar el beta, error estandar y el tc para cada una de las variables epxlicativas. Para eso, vamos a utilizar el vector de betas y la matriz varcov, entonces los creamos:

matrix beta=e(b)
matrix beta=beta'
matlist beta

matrix VARCOV=e(V)

			matrix t = J(8,1,.)
			forval x=1(1)8{
				scalar tc_`x' 	= beta[`x',1] / sqrt(VARCOV[`x',`x'])
				matrix t[`x',1] = tc_`x'
			}
			matlist t 
			
			matrix ee = J(8,1,.)
			forval x=1(1)8{
				scalar ee_`x' 	=  sqrt(VARCOV[`x',`x'])
				matrix ee[`x',1] = ee_`x'
			}
			matlist ee

			matrix resultados = beta, ee, t 
			matrix colnames resultados = wage ee t
			matlist resultados








