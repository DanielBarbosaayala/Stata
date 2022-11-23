
**************************************************
***** Clase Autocorrelación *********************
**************************************************


clear all

cd "C:\Users\carli\Dropbox\Econometria 1 - 2021-10\Clases complementarias\Clase 15"

import excel "C:\Users\carli\Dropbox\Econometria 1 - 2021-10\Clases complementarias\Clase 15\anexo_desestacionalizado_empleo_dic_18.xlsx", sheet("Datos_Procesados") firstrow

d
* acabamos de importar la base de datos que contiene la serie de tiempo de la tasa global de participación, tasa de ocupación,  tasa de desempleo, número de ocupados, número de desocupados, inactivos, para las 13 ciudades y areas metropolitanas más grandes
gen fecha=mofd(Fecha)
format fecha %tm
tsset fecha, monthly
* le especificamos a stata cual es nuestra variable de tiempo y el espacio de tiempo entre cada fecha. Revisar el help de tsset si queiren averiguar más de eso. 

* Graficamos la tasa global de participación y la tasa de ocupación
line TGP TO Fecha, legend(size(medsmall))
* ¿Que ven? 

* Ahora le metemos al grafico la tasa de desempleo
line TGP TO TD Fecha, legend(size(medsmall))


reg TD Inactivos

/* Detección */
	*obtenemos los residuales
	predict u, residual
	*creamos el rezago del residuo
	gen Lag_u= u[_n-1]
	twoway (scatter u L1.u) (lfit u L1.u)
	reg u Lag_u , nocons 
	scalar rho= _b[Lag_u]
	scalar d=2*(1-rho)
	scalar list 
	* comparamos con d_u=1.54 y d_l=1.44. 
	scalar du=1.54
	scalar dl=1.44
	scalar cuatro_du=4-du
	scalar cuatro_dl=4-dl
	
	scalar list
	
	
	* Acabando de calcular la prueba de durbin watson, dirían ustedes que tenemos autocorrelación en el modelo?
	
	*como todo, Stata ya tiene un comando para estimar la prueba de forma más sencilla
reg TD Inactivos

	estat dwatson
	
*¿Qué podemos concluir con el resultado de la prueba?


** Corrigiendo la autocorrelación

** Aproximación manual

local variables "TD Inactivos"
foreach var_ in `variables'{

	gen `var_'_t=`var'-rho*L1.`var_'
	
}
br
*fijense que perdemos la primera observación
local variables "TD Inactivos"
foreach var_ in `variables'{

	replace `var_'_t=`var_'*sqrt(1-rho^2) in 1
	
}
br

*Ahora la recuperamos

	*hacemos la regresión con las variables transformadas. 
	reg TD_t Inactivos_t
	predict v, residual
	
/* Detección (para el nuevo modelo) */
	twoway (scatter v L.v) (lfit v L.v)
	
	reg v L.v , nocons 
	scalar rho= _b[L1.v]
	scalar d=2*(1-rho)
	scalar list 
	* comparamos con d_u=1.54 y d_l=1.44. 
	scalar du=1.54
	scalar dl=1.44
	scalar cuatro_du=4-du
	scalar cuatro_dl=4-dl
	
	scalar list
** ¿Seguimos teniendo autocorrelación? 

* La respuesta es sí. Por eso tendríamos que iterar otra vez hasta solucionar el problema. Afortunadamente, como todo en Stata, ya hay un comando que lo hace por nosotros.

* Correción de autocorrelación por el metodo Cochrane-Orcutt
prais TD TGP, corc
