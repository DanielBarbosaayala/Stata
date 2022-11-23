************************************
*** COMPLEMENTARIA ECONOMETRIA 1 ***
*** CLASE 13 - MULTICOLINEALIDAD ***
************************************

cls
set more off 


*****************************
*Base: Acemoglu, Naidu, Restrepo y Robinson (2019) Democracy Does Cause Growth.

*Utilizan datos del PIB per capita y un indicador de democracia que se basa en medidas previas. Los autores encuentran una relación positiva entre democracia y PIB percapita. En particular, muestran que la democratización incrementa el PIB per capita en alrededor de un 20% en el L.P. Los autores utilizan estrategias mas avanzadas (Panel dinámico y Variables Instrumentales). Aca vamos a utilizar los datos transformados para hacer un MCO

cd "/Users/veronica/Dropbox/Econometria 1 - 2021-10/Clases complementarias/Clase 13"

use DDCGdata_claseE1, clear

des

//dem: un indicador = 1 si el pais era democratico en ese año
//loginvpc: log Investment share of GDP per capita
//ltrade2: log Trade share of GDP per capita
//lprienr: log Primary-school enrollment rate
//lsecenr: log Secondary-school enrollment rate
//lgov: log Tax revenue share of GDP 
//lmort: log Child mortality per 1,000 births 
//unrest: Unrest rate
//marketref: Market reforms index

*Tenemos 7 categorías de region

	*AFR: Sub-Saharan Africa
	*EAP: East Asia & Pacific
	*ECA: Europe & Central Asia
	*INL: Set of developed countries in NA and europe
	*LCA: Latin America & the Caribbean
	*MNA: Middle East & North Africa 
	*SAS: South Asia

	****** Evaluamos los diferentes posibles niveles de multicolinealidad:
*******************************
*** 1. Perfecta (r_x1x2=1): ***
*******************************

global dummy_region "dummy_region1 dummy_region2 dummy_region3 dummy_region4 dummy_region5 dummy_region6 dummy_region7"


*primero voy a correr todos los controles en 2000
global year = 2000

global controles "loginvpc_$year ltrade2_$year lprienr_$year lsecenr_$year lgov_$year lmort_$year unrest_$year marketref_$year"

reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles
reg logpib_2010 logpib_2000 dem_1990 $dummy_region *_2000

*Note que STATA omite una variable a causa de la existencia de multicolinealidad perfecta. 


*En este caso, los betas no están identificados y por eso STATA omite una de las categorias para poderlos estimar. 

********************************
***** 2. Alta (r_x1x2->1): *****
********************************

*Dada que no es exactamente 1, los betas si estarán identificados. 
	
*Que tan alta es dependerá del criterio de cada quien. 
*Un criterio posible es que ρ ̂_(X_1,X_2 )>0.7 sea ya demasiado alto. 
	
	*Los coeficientes se pueden estimar pero tienen algunos problemas:
	*1. Signos pueden ser contra intuitivos
	*2. La varianza es más alta (aumenta la probabilidad de cometer error tipo ¿?)

	
**** Ejemplo 1:
***************

*Por ejemplo:
	*suponga que usted quiere incluir el estado de la democracia en dos momentos
	*del tiempo, en el año 2000 y en 1990. Puede que los paises mantengan sus niveles
	*de democracia estables en este periodo. 
	
	*tambien puede haber correlacion alta entre el pib y la democracia si se usan valores
	*rezagados como controles

	*Veamos la correlación entre las variables:
corr logpib_2000 dem_2000 dem_1990 $controles

*Hay una correlación de 0.64 entre la democracia en el 2000 y la democracia en 1990
*tambien es bastante alta entre logpib 2000 y democracia entre 1990 y el 2000
	
pwcorr logpib_2000 dem_2000 dem_1990 $controles, star(0.05) //son diferentes, manejan los
	*missing values de formas diferentes 
*Al sacar el coeficiente de correlación de pearson nos dice que esta relación es significativa al 95% (prueba de hipotesisi sobre rho)

*arreglo la multicolinealidad perfecta del la dummy de region, voy a sacar LAC
global dummy_region "dummy_region1 dummy_region2 dummy_region3 dummy_region4 dummy_region6 dummy_region7"

*Estimamos 1:

reg logpib_2010 dem_2000
estimates store reg1

*Estimamos 2:
reg logpib_2010 dem_1990 
estimates store reg2

*Estimamos 3: Incluimos las dos variables que presentan multicolinealidad alta
reg logpib_2010 dem_2000 dem_1990 
estimates store reg3

*Observamos los resultados de las tres regresiones
ssc install estout
esttab reg1 reg2 reg3

*Las dos variables por separado dan resultados significativos, pero al incluirlas al tiempo se roban la significancia entre ellas porque están aportando la misma información. 


**** Ejemplo 2:
***************

*Que pasa con la corr entre log del pib y democracia?

*Estimamos 1:

reg logpib_2010 logpib_2000 
estimates store reg1

*Estimamos 2:
reg logpib_2010 dem_2000
estimates store reg2

*Estimamos 3:
reg logpib_2010 dem_1990 
estimates store reg3

*Estimamos 4: Incluimos las 3 variables que presentan multicolinealidad alta
reg logpib_2010 logpib_2000 dem_1990 dem_2000
estimates store reg4

*Observamos los resultados de las tres regresiones

esttab reg1 reg2 reg3  reg4


*Las tres variables por separado dan resultados significativos, pero al incluirlas al tiempo la democracia en el 2000 deja de ser significativa, porque el log del pib de ese año aporta la misma información que la dicotoma de democracia.


**** Ejemplo 3:
***************

//Que pasa si incluimos valores rezagados del PIB?

corr logpib_*

	//las correlaciones son muy altas

*Estimamos 1:

reg logpib_2010 logpib_2000 
estimates store reg1

*Estimamos 2:
reg logpib_2010 logpib_1990
estimates store reg2

*Estimamos 3: Incluimos las 2 variables que presentan multicolinealidad alta
reg logpib_2010 logpib_2000 logpib_1990
estimates store reg3

*Observamos los resultados de las tres regresiones

esttab reg1 reg2 reg3 


**************************************
***** 3. Baja 0 < r_x1x2 < 0.7 : *****
**************************************

*Es la más común.
*El límite superior es criterio del investigador. 
*Los coeficientes se pueden estimar, tienen problemas, pero no son graves. 
*Tiene las mismas implicaciones que la Multicolinealidad alta, pero a menor magnitud

reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles

pwcorr logpib_2000 dem_1990 $dummy_region $controles, star(0.5) 
	**todos los controles son importantes: la region debe incluirse en regresiones entre paises y los controles de capital humano también.
	*las multicolinealidades mas altas son con las regiones: no se pueden eliminar
	*multicolinealidad alta tambien entre el log del PIB pc y la democracia, pero
		*necesitamos la democracia porque es nuestra variable de interés y el log del pib
		*rezagado para controlar por la persistencia de la variable dependiente

	*La multicolinealidad mas alta es entre mortalidad infantil y PIB: Si la sacamos?
	
global controles_nuevos "loginvpc_$year ltrade2_$year lprienr_$year lsecenr_$year lgov_$year unrest_$year marketref_$year"

reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles
estimates store reg1

reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles_nuevos
estimates store reg2

esttab reg1 reg2
*******************************************
*** ¿Cómo detectamos multicolinealidad? ***
*******************************************

*Además de:
	*Contradicciones
	*Correlaciones entre regresoras
	*Regresiones auxiliares

*Podemos utilizar el factor de inflación de la varianza (VIF).

	*El VIF captura la velocidad con la cual las varianzas y las covarianzas aumenta, 
			*VIF=1/((1-R_j^2)) 
	*Se corre regresión auxiliar de la variable x_j respecto a todas las demás regresoras y sacamos el R2.

	*Regla de dedo para el VIF:
		*- "10" as the maximum level of VIF (Hair et al., 1995)
		*- "5" as the maximum level of VIF (Ringle et al., 2015)

*Volviendo al caso de:
reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles_nuevos

			*Ejemplo:
reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles_nuevos
display 1/(1-e(r2))
*El VIF resultante es 215.366, lo cual implica que la varianza resulta ser 215.366veces más grande de lo que debería. 

*También se puede utilizar el comando VIF para que STATA automáticamente saque el VIF de todas las variables, después de correr la regresión de interés. 

*recuerdan la variable de mortalidad que sacamos?
reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles
vif

reg logpib_2010 logpib_2000 dem_1990 $dummy_region $controles_nuevos
vif



* Fin *





