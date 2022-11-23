/*
	CLASE SIMULACIÓN Y MODELOS DE SUAVIZAMIENTO EXPONENCIAL
*/

*******************************************************************************
// Suavizamiento exponencial

clear

cd"C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\6 semestre\Econometría 2\Complementarias de stata\Clase 13\Estudiantes"

use mcmm.stata.dta, replace
gen tiempo=ym(year, month)
format %tm tiempo
tsset tiempo, monthly

*Para realizar los pronósticos se requiere incrementar la base de datos

tsappend, add(3)

tsline com // Análisis de componentes de la serie


**Promedio Móvil Simple de Orden 3: Ciclo
tssmooth ma com_pms=com, window(3 0 0)

/*Para la opción window(l,c,f): 
-l indica el número de observaciones rezagadas a tener en cuenta 
-c toma el valor de 1 si se tiene en cuenta la variable contemporánea, 0 dlc
-f es el número de términos hacia adelante a tener en cuenta
*/

tsline com com_pms
*No tan bueno, no captura bien el comportamiento estacional

**Exponencial simple (MIRAR EL RMSE) // Contempla los ciclos suavizados
tssmooth exponential com_exp=com, forecast(3) //Forecast: periodos a pronosticar
tsline com com_exp


**Exponencial doble // Contempla los ciclos y tendencia suavizados
tssmooth dexponential com_dexp=com, forecast(3) 
tsline com com_dexp


**Holt-Winters no estacional // Contempla los ciclos y tendencia
tssmooth hwinters com_hw=com, forecast(3) 
tsline com com_hw

**Holt-Winters estacional multiplicativo // Componentes se multiplican (Y componente estacional)
tssmooth shwinters com_hwsm=com, forecast(3) iterate(24) period(12)
//Estacionalidad: 12
tsline com com_hwsm, name(d)


**Holt-Winters estacional aditivo // Componentes se adicionan (Y componente estacional)
tssmooth shwinters com_hwsa=com, forecast(3) iterate(24) period(12) additive
tsline com com_hwsa, name(f)
gr combine d f


*** Ejercicio en la clase

gen com_prom= com/140
gen sqrt_com_prom=sqrt(com_prom)

foreach x in com_pms com_exp com_dexp com_hw com_hwsm com_hwsa {
	*gen u_`x'=com-`x'
	*gen abs_u_`x'=abs(u_`x')
	*gen u2_`x'=u_`x'^2
	*gen seneca_`x'=abs(u_`x'/com)
	*gen u2_n_`x'=u2_`x'/140
	*gen prom_`x'=`x'/140
	*gen sqrt_u2_n_`x'=sqrt(u2_n_`x')
	*gen sqrt_prom_`x'=sqrt(prom_`x')
	*gen den_`x'=sqrt_com_prom+sqrt_prom_`x'
	gen theil_coef_`x'=sqrt_u2_n_`x'/den_`x'
}




***Coeficiente de theil












