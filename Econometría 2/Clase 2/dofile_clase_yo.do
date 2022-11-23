
***** CLASE 2 - ECONOMETRÍA 2 ******

cd"C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\6 semestre\Econometría 2\Complementarias de stata\Clase 2\"

use Especificacion.dta


** Gen vars con logaritmo

foreach var of varlist _all{
	display "esta es la transformación para la variable `x'"
	
	gen log_`var' = log(`var')
}

twoway (scatter salario ventas) (lfit salario ventas) //con linea de tendencia

twoway (scatter log_salario log_ventas) (lfit log_salario log_ventas) //con linea de tendencia

reg log_salario log_ventas roe ros


/* TEST DE RAMSEY

Considere el modelo 

y=a +a1x1 + a2x2 + e


1. Estimar modelo MCO
2. Caprturar el valor de ygorro

3. Se estima un modelo auxiliar con MCR

	y = a1 + a2x1 + a2ygorro^2 + a3ygorro^3

Ph:

H0: a1=a2=0

H1: diferentes


Fc= (SCEr - SCEnr)/l/SCRnr/N-k-1


Fi Fc>F se rechaza H0, y el modelo está mal especificado. Que a su vez es variable omitida.

		NOTA: ***No identifica error de medición.****

*/

//Para hacer test de Ramsey

*De forma automáticas
estat ovtest

*Forma manual
reg log_salario log_ventas roe ros

predict yhat, xb //xb es para sacar el y predicho

scalar sce_r=e(rss) // para guardar la suma de cuadrados del residuo

br log_salario yhat

forval x=2(1)4{
	
	gen yhat`x' = yhat^`x'
	
} 

reg log_salario log_ventas roe ros yhat2 yhat3

scalar sce_nr=e(rss) //SRR NR

scalar Fc = ((sce_r-sce_nr)/2)/(sce_nr/203)//3nrestricciones

scalar probf = Ftail(2,203,Fc)

scalar list




/* 	TEST DE J DAVIDSON-McKINNON (MODELOS  NO ANIDADOS)
		
		
Considere 2 modelos no anidados:

y = b0 + b1x1 + b2x2 + e

y = a0 + a1z1 + a2z2 + u

1. Se estiman ambos modelos A y B

2. Se introducen los resultados de A en B como variables adicionales

3. 


Prueba de hip:

H0: delta =0

tc = deltagorro / Desviación estandar (Delta) ~ tn-k

si tc> t se Rechaza H0, y el modelo está mal especificado
		
		
*** Resutados

1. Si en ambos es significativo. Desechar y buscar otro.

2. Escoger el que se rechaza o no es significativo

3. Si ambos rechazados, escoger el R^2 mayor

*/


reg log_salario log_ventas roe ros //Mod A

predict salario_A, xb

reg log_salario ventas roe ros comercio salario_A //reg auxiliar de modelo B

reg log_salario ventas roe ros comercio //mod B

predict salario_B, xb

reg log_salario ventas roe ros comercio salario_B

//Como en ambos se rechazan, hay que cambiar de modelo.



/* MULTIPLICADORES DE LAGRANGE : Vars omitidas o redundantes

1. Estimar MCO

2. Capturar el resuidual del modelo e gorro

3. Se estima mod auxiliar donde var dependiente es e gorro.

4. Estadistico

H0: teta = 0

LM = NR^2aux ~ X^2(p), con p igual al nuero de restricciones. Restricciones es # de = en H0

Si NRH0, x es redundante

Si RH0 es omitida

*/

reg log_salario log_ventas roe ros //reg base

predict error, residual //para el ereror

br log_salario yhat error

reg error log_ventas roe ros comercio

scalar LM = e(N)*e(r2)

scalar list

scalar prob = chi2tail(1,LM)

scalar list






		
		
		
		
		
		
		
		
		
		
		
	




