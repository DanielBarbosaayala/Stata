// Econometria 1 - 202110
// Clase 4 

*1. Limpiamos la casa
clear all
set more off

*2. Establecemos el directorio de trabajo
cd "/Users/sofiacastro/Dropbox/Econometria 1 - 2021-10/Clases complementarias/Clase 4"

*3. Para esta clase vamos a utilizar la ELCA (es una encuesta longitudinal que sigue cada tres años a aproximadamente 10,000 hogares colombianos en zonas urbanas y rurales de Colombia. La intención de la iniciativa es hacerle seguimiento a estos mismos hogares durante 12 años, de los cuales ya han transcurrido 6.) en su ronda del año 2016 para zonas urbanas. 

*En particular vamos a utilizar información a nivel individual proveniente de dicha encuesta. Queremos evaluar si el hecho de tener más hijos o mayor salario implica que las personas ahorren más o menos.

//Esta misma base de datos, en su versión .dta la pueden descargar en la página web de la ELCA. (https://encuestalongitudinal.uniandes.edu.co/es/datos-elca/2016-ronda-3)

	*Abrimos la base
use "Upersonas_clean.dta", clear

*Queremos ver como se distribuye la variable de ahorro:
histogram vr_ahorro, title("Distribución del ahorro") xtitle("¿Cuanto ahorra mensualmente?")

*Para exportar graficos: 
graph export histograma.pdf, replace
	*Ustedes pueden elegir la extensión (por ejemplo también se puede jpg)

*Vemos que existen algunos valores atipicos de personas que dicen ahorrar muchisimo. Estos valores podemos quitarlos de la muestra para tener estimaciones más limpias. 
	*Una buena forma de hacerlo es considerando valores por encima del percentil 99 como valores atipicos. 
	
	*Vemos las descriptivas de la variable ahorro
sum vr_ahorro, d

	*Generamos una variable de valor atipico que indica que observaciones estan por encima del percentil 99
gen atipico_ahorro=vr_ahorro>r(p99)
*¿Cuantos son?
tab atipico_ahorro
drop if atipico_ahorro==1

*Una vez hemos eliminado los valores atipicos, vemos si la distribución de la variable mejora. 
histogram vr_ahorro, title("Distribución del ahorro") xtitle("¿Cuanto ahorra mensualmente?")
	**** ¿Les parece mejor?

*Ahora queremos ver la cantidad de hijos que tienen las personas de la muestra. 
sum hijos_hombres hijas_mujeres

*Queremos una variable que sume tanto hijos hombres como mujeres:
egen hijos_total=rowtotal(hijos_hombres hijas_mujeres)
	*Con browse podemos ver si creamos lo que queríamos
br hijas_mujeres hijos_hombres hijos_total
	**** ¿Que pueden ver aquí?

*Para corregirlo
replace hijos_total=. if hijas_mujeres==. & hijos_hombres==. 
*Y ahora vemos:
sum hijos_total 

	**** ¿Cuantos hijos en promedio?

*Nuestra pregunta inicial asocia el numero de hijos y el salario al ahorro de un individuo.
	**** ¿Cuál creerían que puede ser el signo esperado del número de hijos y porque?
	**** ¿Cuál creerían que puede ser el signo esperado del salario y porque?

*Como primera aproximación realizamos un grafico scatter y agregamos una linea de tendencia
twoway (scatter vr_ahorro hijos_total) (lfit vr_ahorro hijos_total)
twoway (scatter vr_ahorro vr_salario) (lfit vr_ahorro vr_salario)

	*** ¿Que relación observan?
	
*Los graficos no son concluyentes acerca de una relación entre dos variables. Para poder decir algo, planteamos una regresión. 
reg vr_ahorro hijos_total
	**** ¿Cómo podemos intepretar esta salida de regresión?
		*Significancia individual, global, interpretación de coeficientes.
outreg2 using Regresion1.doc, replace
*O también en formato de excel
outreg2 using Regresion1.xls, replace

reg vr_ahorro vr_salario
	**** ¿Cómo podemos intepretar esta salida de regresión?
		*Significancia individual, global, interpretación de coeficientes.
outreg2 using Regresion2.doc, replace

*Ahora, supongamos que queremos mirar en elasticidades el efecto de las dos variables sobre el ahorro. 
	*Para esto, vamos a convertir nuestras variables a logaritmos:
generate ln_ahorro=ln(vr_ahorro)
generate ln_salario=ln(vr_salario)
generate ln_hijos=ln(hijos_total)

*Podemos hacer un modelo log-log
reg ln_ahorro ln_hijos
	**** ¿Cómo se interpreta el coeficiente asociado a la variable?

*Una manera de ver los resultados de los coeficientes de forma gráfica es utilizando el comando coefplot, que se corre despues de estimar una regresión:
coefplot

*Para ver solo el coeficiente que nos interesa
coefplot, keep(ln_hijos)
	**** ¿Cómo interpretamos este gráfico?

reg ln_ahorro ln_salario
	**** ¿Cómo se interpreta el coeficiente asociado a la variable?

*Un modelo log-lin
reg ln_ahorro hijos_total
reg ln_ahorro vr_salario
	**** ¿Cómo interpretamos estos coeficientes?

*Y un modelo lin-log
reg vr_ahorro ln_hijos
reg vr_ahorro ln_salario
	**** ¿Cómo interpretamos estos coeficientes?

*Finalmente, supongamos que queremos comparar los coeficientes de las dos variables independientes sobre la variable ahorro en el modelo log log. Para esto, en un mismo coefplot podemos plotear ambos coeficientes. 

*Primero corremos las dos regresiones de nuevo pero esta ves guardamos las estimaciones:
reg ln_ahorro ln_hijos
estimates store hijos
reg ln_ahorro ln_salario
estimates store salario

coefplot hijos salario, keep(ln_hijos ln_salario)
	**** ¿Cómo interpretamos este gráfico?










