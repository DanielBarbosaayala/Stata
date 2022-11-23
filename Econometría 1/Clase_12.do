*CLASE COMPLEMENTARIA 12
*ECONOMETRIA 1

clear all
set more off

***** MODELOS DE PROBABILIDAD

*Queremos ver cual es el efecto de ciertas variables de desempeño sobre la probabilidad de que una persona obtenga un trabajo luego de ser entrevistado.

*En particular, vamos a explicar el hecho de si la persona obtuvo o no el trabajo (variable aprueba) a partir de: su genero, su edad y su puntaje en tres tipos de pruebas que se hicieron durante la entrevista: un caso de consultoria, un test de personalidad y un test de trabajo en equipo. 

*El modelo a estimar es entonces:
*aprueba=B0+B1edad+B2genero+B3consultoria+B4personalidad+B5trabajoenequipo+U

	*Utilizamos la base de datos Entrevistas.dta
cd "/Users/sofiacastro/Dropbox/Econometria 1 - 2021-10/Clases complementarias/Clase 12"
use "entrevistas.dta", clear

*Exploramos la base de datos:
sum 
	*Hay algun sesgo de genero en la cantidad de personas entrevistadas?
	*Cual es el test en el cual parece irle mejor a las personas? y ¿cual es el peor?

*Como estadística descriptiva: podemos ver en un grafico de barras si quienes aprueban parecen ser mejores o peores en los tres diferentes tests.
graph bar consultoria, over(aprueba) saving(g1,replace) ytitle("Caso Consultoria")  graphregion(color(white))
graph bar personalidad, over(aprueba) saving(g2,replace) ytitle("Test Personalidad") graphregion(color(white))
graph bar equipo, over(aprueba) saving(g3,replace) ytitle("Test T. equipo") graphregion(color(white))
graph combine g1.gph g2.gph g3.gph, rows(1) graphregion(color(white)) title("=1 si obtuvo el trabajo")

*O también podemos ver si hay más hombres o mujeres entre quienes obtienen el trabajo. 
graph bar if aprueba==1, over(hombre)
label define hombre 1 "Hombre" 0 "Mujer"
label values hombre hombre
	
graph bar if aprueba==1, over(hombre) asyvars bar(1, fcolor(orange)) bar(2, fcolor(green)) bargap(5) ytitle("Porcentaje") title("Género de quienes obtienen el trabajo", size(large)) graphregion(color(white)) 

*** Luego ya pasamos a la estimación.
	*1. POR MCO
reg aprueba edad hombre consultoria personalidad equipo

* ¿Cómo interpretamos estos coeficientes?
	* ¿Cómo funciona la significancia estadística en estos casos?
* Considerando la magnitud de los betas, hay algun test que "pese" más en la probabilidad de obtener el trabajo?

*Predecimos la variable dependiente
predict aprueba_mpl
sum aprueba aprueba_mpl
*Note que el máximo es 1.22 y el minimos es -0.08, por lo cual notamos que la probabilidad predicha no esta acotada [0,1] lo cual es una desventaja de el MPL.

	*2. Por MV
*LOGIT
logit aprueba edad hombre consultoria personalidad equipo
	* ¿Que nos dicen estos coeficientes acerca de los efectos marginales?
	* ¿El modelo tiene dependencia global?
*Efectos marginales
	*En la media
margins, dydx(*) atmeans
	*Promedio
margins, dydx(*)
*¿Cómo interpretamos estos efectos marginales?

	*Predecimos la variable dependiente
predict aprueba_logit
sum aprueba aprueba_logit
*Note que la probabilidad predicha ya esta acotada.

*PROBIT
probit aprueba edad hombre consultoria personalidad equipo
	* ¿Que nos dicen estos coeficientes acerca de los efectos marginales?
	* ¿El modelo tiene dependencia global?
*Efectos marginales 
	*En la media
margins, dydx(*) atmeans
	*Promedio
margins, dydx(*)
*¿Cómo interpretamos estos efectos marginales?
	*Considerando estos efectos marginales, cual test pesa más en la probabilidad de obtener el trabajo?
	
	*Predecimos la variable dependiente
predict aprueba_probit
sum aprueba aprueba_probit
*Note que la probabilidad predicha ya esta acotada

/// Comparamos las tres metodologias
sum aprueba_mpl aprueba_logit aprueba_probit

*Calculamos el porcentaje de predicciones correctas
gen pp_mpl=(aprueba_mpl>0.5)
gen pp_logit=(aprueba_logit>0.5)
gen pp_probit=(aprueba_probit>0.5)

tab aprueba pp_mpl
display (12+297)/337*100

tab aprueba pp_logit
display (28+292)/337*100

tab aprueba pp_probit
display (28+291)/337*100

*Los tres modelos son similares en cuanto a las predicciones correctas, pero el logit y el probit tienen un porcentaje mayor. En particular, el logit es el mejor modelo en cuanto a predicciones correctas. 





	
