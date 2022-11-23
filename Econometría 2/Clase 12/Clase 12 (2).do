/* CLASE 12: Tendencia deterministica y suavizamiento */

cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\6 semestre\Econometría 2\Complementarias de stata\Clase 12\"

use "com", clear
gen t=_n	// generar variable de tiempo 
tsset t // esto permite a stata identificar la variable que indica el tiempo en la serie
* Usamos el filtro de Hodrick-Prescott para identificar partes: 

ssc install hprescott
hprescott com, stub(com_hp) smooth(14400)  //saca la tendencia
tsline com com_hp_com_sm_1 , name(tendencia)
tsline com_hp_com_1 , name(ciclo)
graph combine tendencia ciclo , name(hprescott) col(1)

	/* 	
		Dado que el objetivo es predecir, e intentar medir la calidad de la 
		prediccion, las regresiones de tendencia deterministica las haremos con 
		120 observaciones (desde enero 1999 hasta diciembre 2008), así podemos
		comparar nuestras predicciones frente a lo que sucedió en los últimos 2
		años. 
	*/
* Lineal: y=b0+b1t+u
	reg com t in 1/120
	predict com_lin
	twoway (tsline com_lin com if t<=120)(tsline com_lin com if t>120)
		* Con todo el periodo. 
		reg com t 
		predict com_lin2
		tsline com_lin com_lin2 com , name(g1) title(Lineal: y=b0+b1t+u)

* Cuadrática: y=b0+b1t+b2t^2+u
	reg com c.t##c.t in 1/120
	predict com_sq
	twoway (tsline com_sq com if t<=120)(tsline com_sq com if t>120)
		* Con todo el periodo. 
		reg com c.t##c.t
		predict com_sq2
		tsline com_sq com_sq2 com, name(g2) title(Cuadrática: y=b0+b1t+b2t^2+u)

* Log lin: ln(y)=b0+b1t+u
	gen lcom=ln(com)
	reg lcom t in 1/120
	predict ln_com
	gen com_loglin=exp(ln_com)
	twoway (tsline com_loglin com if t<=120)(tsline com_loglin com if t>120)
		* Con todo el periodo. 
		reg lcom t 
		predict ln_com2
		gen com_loglin2=exp(ln_com2)
		tsline com_loglin com_loglin2 com, name(g3) title(Log lin: ln(y)=b0+b1t+u)

* Lin log: y=b0+b1ln(t)+u
	gen lt=ln(t) 
	reg com lt in 1/120
	predict com_linlog
	twoway (tsline com_linlog com if t<=120)(tsline com_linlog com if t>120)
		* Con todo el periodo. 
		reg com lt
		predict com_linlog2
		tsline com_linlog com_linlog2 com	, name(g4)	title(Lin log: y=b0+b1ln(t)+u)
				
* Reciproco en t: y=b0+b1(1/t)+u
	gen invt=1/t
	reg com invt in 1/120
	predict com_invt
	twoway (tsline com_invt com if t<=120)(tsline com_invt com if t>120)
		* Con todo el periodo. 
		reg com invt 
		predict com_invt2
		tsline com_invt com_invt2 com, name(g5) title(Reciproco en t: y=b0+b1(1/t)+u)
* boxcox 
	boxcox com t in 1/120, model(theta)
	predict com_boxcox
	twoway (tsline com_boxcox com if t<=120)(tsline com_boxcox com if t>120)
		* Con todo el periodo. 
		boxcox com t, model(theta)
		predict com_boxcox2
		tsline com_boxcox com_boxcox2 com, name(g6) title(boxcox)

* Comparación: Criterio de Akaike (buscamos el menor valor de AIC)
	reg com t 
	estat ic 
	mat akaike=r(S)
	reg com c.t##c.t
	estat ic 
	mat akaike=akaike\r(S)
	reg lcom t 
	estat ic 
	mat akaike=akaike\r(S)
	reg com lt
	estat ic 
	mat akaike=akaike\r(S)
	reg com invt
	estat ic 
	mat akaike=akaike\r(S)
	boxcox com t, model(theta)
	estat ic 
	mat akaike=akaike\r(S)

	mat rownames akaike = linlin sq loglin linlog invt boxcox
* Revisamos la matriz y seleccionamos los mejores ajustes.	
	matlist akaike
* Comparamos graficamente
	graph combine g1 g2 g3 g4 g5 g6 , name(comparacion)
	tsline com com_sq2 com_loglin2  com_boxcox2, name(top3, replace)
	
