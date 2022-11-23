********************************************************************************
********************************************************************************
*					CLASE 3: ESTADISTICAS DESCRIPTIVAS, PRUEBAS DE HIPOTESIS Y
*									REGRESIÓN LINEAL
********************************************************************************
********************************************************************************


* Lo primero, ponemos en orden la casa y fijamos nuestro directorio
clear all
cd "C:\Users\carli\Dropbox\Carlos Arturo Ramírez Pinto\Files\Universidad\Maestria\Complementarias\Econometria 1\Complementaria\Semana 3"

**********************
* Importamos los datos
**********************

webuse cancer, clear 
* Con el comando webuse podemos acceder a las bases de datos que se encuentran
* en la página de Stata (https://www.stata-press.com/data/r8/u.html)

* Debemos conocer la base de datos antes de empezar a hacer cualquier cosa
describe 

*  Esta es una base de datos de pruebas de un experimento para pacientes con 
* cancer, donde tenemos la dosis de medicamento suministrada, y el tiempo de supervivencia de los pacientes o final del experimento.

* La variable drug hace referencia a la dosis administrada en el experimento
rename drug dose
/* En donde los valores que toma la variable siguen el siguiente patrón:
	- 1=Placebo
	- 2 = 5mg
	- 3 = 10mg

En función de eso establecemos las siguientes etiquetas para los valores de esa variable	
*/

label define dosage 1 "Placebo" 2 "5 mg" 3 "10 mg"
label values dose dosage



********************************************************************************
*** 	Gráficos de una variable y Prueba de hipotesis
********************************************************************************
* Tabla de frecuencias
tabulate dose
* el comando table nos permite obtener una tabla de frecuencias de los valores que toma la/las variable/s en cuestión.
 
/* A continuación graficaremos un grafico circular para observar dichas proporciones en un gráfico

*/

graph pie, over(dose) plabel(_all percent) title("Dosis Administrada")


/*
Distribuciones

Si estamos interesados en saber como se ve la distribución de una variable, podemos
graficar un histograma. 


*/

hist studytime
* En este caso estamos observando como se distribuye el periodo de tiempo maximo de supervivencia de los pacientes que participaron en el experimento.


** Graficos de una sola variable por grupos



*Es posible que estemos interesados en comparar graficamente los estadisticos de una variable dependiendo del grupo al que pertenece. En este caso queremos comparar los tiempos  maximos de supervivencia promedios dependiendo de la dosis que fue administrada. 
graph bar studytime, by(dose)
* con la opción by obtenemos distintos gráficos para subgrupo
graph bar studytime, over(dose)
* con la opción over() obtenemos las barras de cada subgrupo en un mismo gráfico

** Sin embargo, graficamente no es posible ver si hay una diferencia estadisticamente significativa en los tiempos maximos de supervivencia promedios entre los grupos a los cuales se les administró una dosis de la medicina y aquellos que no. Por lo cual, procederemos a hacer una prueba de hipotesis.

/* 
Con el comando ttest es posible hacer pruebas de hipotesis. En este particular caso
queremos ver si la media de la variable study time, para los grupos a los cuales se les administro el placebo es estadisticamente distinta de la media de los grupos a los cuales se les administró 5mg de la medicina.

Nota: la opción by() de ttest no funciona cuando hay más de dos grupos dentro de la variable categorica por grupos. Por lo cual, filtramos la muestra dentro del comando para solo incluir aquellos que pertenezcan al grupo de dosis placebo o de 5mg

*/

ttest studytime if dose==1|dose==2, by(dose)

/*
Stata nos muestra como resultado:
 - Una tabla donde resume la variable según cada grupo
 - plantea una prueba de hipotesis: 
	+ Generalmente del estilo Ho: E[Y|Grupo=A] - E[Y|Grupo=B]=0 
 - Calcula el estadistico de prueba asociado a una diferencia de medias
 - Plantea los resultados de 3 hipotesis alternas y calcula los valores-p correspondeintes a cada uno
 
Teniendo esto en cuenta ¿Qué podemos concluir?
*/

/*

En el siguiente comando comparamos la media del promedio maximo de supervivencia de los pacientes qué pertenecen al grupo de placebo y aquellos que pertencen al grupo de dosis=10mg
*/
ttest studytime if dose==1|dose==3, by(dose)



*******************************************************************************
* GRAFICOS DE DOS VARIABLES Y PRUEBAS DE CORRELACIÓN
*******************************************************************************


* Muchas veces nos vamos a encontrar con bases de datos en donde queramos graficar
* una variable en función de otra. 

webuse lifeexp, clear
d
/* Con el comando anterior cargamos a Stata una base de datos que contiene las expectativas
de vida de diversos paises, el crecimiento poblacional y el PNB per cápita

*/

scatter lexp gnppcl

*Con el comando scatter obtenemos un gráfico de dispersión. De la siguiente forma: scatter y x . Los gráficos de dispersión son herramientas muy poderosas que sirven para poder ver graficamente relaciones entre variables. 

/*
Estadisticamente estas relaciones las hemos explorado a partir del calculo del coeficiente de correlación. El cual podemos calcular en stata de la siguiente forma:

correlate lexp gnppc

*/
correlate lexp gnppc safewater popgrowth
* Este comando nos calcula la matriz de correlación para la lista de variables que le demos por parámetro. Si quisieramos obtener la significancia estadistica de la matriz de correlación podemos correr el siguiente comando:

pwcorr popgrowth lexp gnppc safewater, sig star(0.1)

*¿Qué nivel de significancia estamos usando?

******* Matriz de Gráficos de dispersión *******************

*Graficamente podemos observar dichas relaciones a partir de una matriz de graficos de dispersión.

graph matrix  lexp gnppc safewater popgrowth2

/* La forma de leer esta matriz es: En el gráfico en la posición (i,j) de la matriz. La variable  de la fila i se encuentra en el eje Y y la variable de la columna j en el eje X.
Por lo tanto en la posición (1,2) tenemos un grafico de dispersión con la expectativa de vida en el Y y el Producto Nacional Bruto en el eje x.   
*/

/* 
Ahora queremos ahondar un poco mejor en la relación que existe entre las dos variables que mencionamos anteriormente. Para esto vamos a volver a graficar un grafico de dispersión sin embargo esta vez añadiremos una linea de tendencia (linea de ajuste), para poder ver la dirección de la relacion. ¿Qué nos dice el gráfico?

*/

twoway (scatter lexp gnppc) (lfit lexp gnppc)


********************************************************************************
* 				Regresión 
********************************************************************************

/* Ahora usaremos una regresión lineal para explorar con mayor detalle la relación existente entre la expectiva de vida y el producto nacional bruto de cada país.


Antes de correr cualquier regresión es importante preguntarse:
1) ¿Qué datos tengo? ¿De donde provienen?
2) ¿Cuál es el nivel de unidad de observación que estoy manejando?
3) ¿Qué quiero estimar?
4) ¿Qué espero encontrar?
*/


reg lexp gnppc

/* De arriba pa abajo que nos muestra Stata:
- 1) La tabla ANOVA (Analisis de Varianza) [Arriba-izquierda]
- 2) Un resumén del nivel de ajuste y la dependencia global del modelo (Prueba conjunta para saber si al menos un parámetro estimado estadisticamente distinto de cero)
- 3) Los coeficientes estimados con sus respectivas pruebas de hipotesis para ver si son estadisticamente distintos de cero de forma individual.


Para ver los coeficientes graficamente vamos a instalar el comando coefplot
*/

ssc install coefplot
coefplot

/* 
Ahora vamos a calcualr y_gorro, o en este caso, la expectativa de vida promedio predicha para cada país a partir del PNB. 
*/

predict y_gorro, xb

tw (scatter lexp gnppc) (scatter y_gorro gnppc)
* Esto se parece a 
tw (scatter lexp gnppc) (scatter y_gorro gnppc) (lfit lexp gnppc)
* ¿Por qué tiene sentido que esto suceda?

*******************************************************************************
* 				Exportando Resultados
*******************************************************************************

/*
Para exportar los resultados de una regresión podemos utilizar el comando outreg2
*/

ssc install outreg2

outreg2 using "my_reg.doc", word title("Primera Regresion")

/*
Este es uno de los comandos más versatiles para exportar resultados en Stata. Si desean explorar más a fondo todas sus funcionalidades les recomiendo revisar este documento:

https://www.princeton.edu/~otorres/Outreg2.pdf

*/
