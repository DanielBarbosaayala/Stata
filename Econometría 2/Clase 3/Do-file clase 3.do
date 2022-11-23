*****CLASE 3/PRUEBAS DE IDENTIFICACION DE SESGO DE ESPECIFICACION*****

* TIP: comando cls: limpia la ventana de Stata


* Abrimos la base
use "Especificacion.dta", clear


/* roe: rendimiento de los pagarés de la empresa
ros: rendimiento de las acciones de la empresa 
ventas: índice de ventas
salario: salario promedio de una empresa */


* Generamos variables en logaritmo

foreach var of varlist _all{
	display "esta es la transformación de log para la variable `var'"
	gen log_`var'=log(`var')
}




*** PRUEBA DE RAMSEY-RESET ***
scatter salario ventas // Intuición: parecen haber rendimientos mg decrecientes.
twoway (scatter salario ventas) (lfit salario ventas) // Linea de tendencia


reg log_salario log_ventas roe ros // Modelo restringido
estat ovtest //Luego de reg (Incluye formas no lineales)
* Rechazamos H0: modelo tiene forma polinómica/no lineal inadecuada.


// Manual

* Restringido
reg log_salario log_ventas roe ros
predict yhat, xb // Estimamos y 
scalar sce_r=e(rss) // Obtenemos Suma Cuadrados Error restringido

forval x=2(1)4{
	gen yhat`x'=yhat^`x'
}


gen yhat2=y_hat^2 // y estimado al cuadrado
gen yhat3=y_hat^3 // y estimado al cubo
gen yhat4=y_hat^4


* Modelo no restringido
reg log_salario log_ventas roe ros yhat2 yhat3 // Incluimos cuadráticas
scalar sce_nr=e(rss) //SCE no restringido

scalar Fc=((sce_r-sce_nr)/2)/(sce_nr/203) // 3 restricciones (L), 

scalar probF=Ftail(2,203,Fc) //(L:restricciones, n-k-1:209-6-1(indep. en NR))

scalar list probF //Rechazamos H0: forma polinómica inadecuada.




***TEST J DAVIDSON-MCKINNON ***

*Modelo A: log_salario log_ventas roe ros
*Modelo B: log_salario ventas roe ros comercio

reg log_salario log_ventas roe ros // Estimamos A
predict salario_A, xb // Predecimos A
reg log_salario ventas roe ros comercio salario_A // A en B
* salario_A es significativo: B está mal especificado.

reg log_salario ventas roe ros comercio // Estimamos B
predict salario_B, xb // Predecimos B
reg log_salario log_ventas roe ros salario_B // B en A
* salario_B es significativo: A está mal especificado




*** PRUEBA DE MULTIPLICADORES DE LAGRANGE (LM) ***
* ¿Comercio es redundante u omitida?

reg log_salario log_ventas roe ros // Reg base

predict error, residual // Capturamos error

reg error log_ventas roe ros comercio // Reg auxiliar

scalar n=e(N) // Observaciones del auxiliar

scalar r2=e(r2) // Bondad de ajuste del auxiliar

scalar LM=n*r2 // Estadístico de prueba

scalar prob=chi2tail(1,LM) // Distribución: p valor asociado a la prueba

scalar list prob 
* Rechazamos Ho: Comercio es una variable omitida
