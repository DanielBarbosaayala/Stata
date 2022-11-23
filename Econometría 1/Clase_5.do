********************************************************************************
*				Complementaria econometría 1 2021-1.						   *
*							Clase 5.										   *
********************************************************************************

clear all
set more off

****** Regresion lineal multiple

bcuse nbasal.dta, clear // Abrimos la base de datos

*Generamos las matrices necesarias para la estimación:
	
	gen uno=1
	mkmat wage points rebounds exper marr black uno 
	
	*MATRIZ X
	matrix x=points, rebounds, exper, marr, black, uno 

	
	*MATRIZ Y
	matrix y=wage

	*Generemos el vector de betas estimados
	*MATRIZ BETA
	matrix xx=x'*x  //matriz traspuesta
	matrix beta=inv(xx)*(x'*y) //matriz inversa
	matlist beta //muestra la matris
//el resultado es la matriz de valores estimados
	
	
	*Si hacemos la regresion automatica, obtenemos el mismo resultado:
	reg wage points rebounds exper marr black 


	************************************
	***** 2. Suma de los cuadrados  ****
	*****	         MCO           *****
	************************************

	***SCT***
	*La suma de los cuadrados totales representa una medida de variación o desviación con respecto a la media. 

	*sumatoria: (yi-ybarra)^2

	matrix unos=J(269,1,1)
	matrix suma=unos'*y

	matlist suma
	scalar n=e(N) // scalar "name"=e(N) e=return value

	matrix y_promedio=suma/n
		matlist y_promedio
	sum wage
	
	scalar y_promedio=y_promedio[1,1] //[] especifica fila y columna
	matrix vector_y_promedio=J(269,1,y_promedio)
	matlist vector_y_promedio
	
	matrix sct=y-vector_y_promedio
	matrix sct2=(sct'*sct)
	matlist sct2
	
	scalar sct2=sct2[1,1]
	display %12.2g sct2

	*267878925 

	***SCR***
	*La suma de cuadrados de la regresión es la parte que las variables explicativas sí son capaces de explicar. Es variabilidad de la variable explicada que nuestro modelo si logra captar.

	*sumatoria: (ygorroi-ybarra)^2

	*Sacamos el y predicho:
	matrix yhat=x*beta
	matrix scr=yhat-vector_y_promedio
	matrix scr2=(scr'*scr)
	scalar scr2=scr2[1,1]
	matlist scr2
	dis %12.2f scr2
		*147446081	
		
	***SCE***
	*La suma de los cuadrados del error residual es la variación de nuestra variable explicativa que le atribuimos al error. 

	*sumatoria: (yi-ygorroi)^2 - (uhat)^2
	matrix uhat=y-yhat
	matrix sce2=(uhat'*uhat)
	matlist sce2
	scalar sce2=sce2[1,1]
	dis %12.2g sce2
		*120432844
		
	****Note que: SCT=SCR+SCE, lo cual también nos muestra la tabla ANOVA de la regresión. 

	************************************
	***** 2. VAR COV  ****
	************************************
	
/* Ahora es importante ver la derivación de la VARCOV. Para esto, necesitamos 
	la siguiente definición del residual: 
	E_hat = Y-Y_hat = Y-XB
	Importante que se aclaré que B es el vector de Betas estimados.
	
	Luego, la definición de varianza es: E[(B_hat-E(B_hat|X))^2|X], sin embargo 
	nosotros tenemos matrices. Por lo mismo, debemos tener en cuenta como 
	obtener en términos matriciales de lo que está en el valor esperado. Asi 
	como al multiplicar E'E tenemos la suma de los cuadrados de los errores, se 
	debe pensar que algo similar podemos usar. 
	Sin embargo, (B_hat-E(B_hat|X))'*(B_hat-E(B_hat|X)) da como resultado un 
	escalar, y nosotros necesitamos una matriz, por lo que realmente debemos 
	tener en cuenta es (B_hat-E(B_hat|X))*(B_hat-E(B_hat|X))'. (revisar las dim)
	
	Ahora, para simplificar, reemplacemos inicialmente Y en el vector estimado 
	de betas. 
		B_hat= inv(X'*X)*X'*Y
		B_hat= inv(X'*X)*X'*(X*B + E)
		B_hat= inv(X'*X)*X'*X*B + inv(X'*X)*X'*E
		B_hat= inv(X'*X)*(X'*X)*B + inv(X'*X)*X'*E
	Teniendo en cuenta que inv(X'*X)*(X'*X)=I por definición de inv(A)*A=I y que
	A*I=I*A=A 
		B_hat= B + inv(X'*X)*X'*E (ECUACIÓN RELEVANTE)
	Resolviendo primero E(B_hat)
		E(B_hat|X) = E(B + inv(X'*X)*X'*E|X) = E(B|X) +E(inv(X'*X)*X'*E|X)
		E(B_hat|X) = B + E(inv(X'*X)*X'*E|X) 
		E(B_hat|X) = B + inv(X'*X)*E(X'E|X) 
	Por supuesto de no endogeneidad o de independencia condicional, E(E|X) = E(E) = 0. Esto
	Se traduce también en que el vector E es ortogonal a las X, por lo que 
	X'*E=0 en valor esperado. Por lo tanto: 
		E(B_hat|X) = B
	Con este resultado -> B_hat-E(B_hat|X) = B_hat-B
	
	Ahora, fijemonos en la ECUACIÓN RELEVANTE, donde B_hat= B + inv(X'*X)*X'*E. 
	Si Restamos B (el parametro poblacional) a ambos lados de la igualdad:
		B_hat-B = B + inv(X'*X)*X'*E - B 
		B_hat-B = inv(X'*X)*X'*E
	Y esta expresión es más amable a la hora de simplifcar la ecuación 
	VARCOV = E[(B_hat-E(B_hat|X))^2|X]. Entonces reemplazando lo que hemos 
	encontrado hasta ahora: 
		VARCOV = E[(B_hat-E(B_hat|X))*(B_hat-E(B_hat|X))'|X]
		VARCOV = E[(B_hat-B)*(B_hat-B)'|X]
		VARCOV = E[(inv(X'*X)*X'*E)*(inv(X'*X)*X'*E)'|X] *****
	Con la ecuación resaltada con asteriscos, podemos avanzar aplicando las 
	propiedades de las matrices. Recordemos que: 
		(A*B)'=B'*A' 
	Si A'A es invertible, entonces A'A es cuadrada y simetrica por lo tanto
	inv(A'*A)' también es simétrica (en otras palabra B'=B con B=A'*A)
	
	Aplicando estas propiedades: 
		VARCOV = E[(inv(X'*X)*X'*E)*(inv(X'*X)*X'*E)'|X]
		VARCOV = E[inv(X'*X)*X'*E*E'*X*inv(X'*X)'|X]
		
	Dado el condicional de las X, todo lo que tenga X se puede excluir del Valor
	Esperado: 
		
		VARCOV = inv(X'*X)*X'*E[E*E'|X]*X*inv(X'*X)' 
	
	Con especial atención en el término E*E', si resolvemos tenemos: 
	
	E*E' =	E_1
			E_2
			 .
			 .		* 	[E_1, E_2, ... , E_N]
			 .
			E_N
			
	E*E' = 	E_1^2	E_1*E_2	E_1*E_3	...	E_1*E_N
			E_1*E_2	E_2^2 	E_2*E_3	...	E_2*E_N
			E_1*E_3	E_2*E_3 E_3^2	...	E_3*E_N	
			 .		 .		 .		 .	 .
			 .		 .		 .		 .	 .			 
			 .		 .		 .		 .	 .
			E_1*E_N	E_2*E_N E_3^E_N	...	E_N^2
	
	Esta es una matriz NXN. Cuando aplicamos E[E*E'|X], es como aplicar E[.|X] 
	a cada entrada de la matriz E*E'. En ese sentido, nos importan dos casos: 
		1) E[E_i^2 |X] = s^2 para cualquier i (supuesto de 
			homoscedasticidad), con s siendo el estimador de sigma. 
		2) E[E_i*E_j|X] = 0 para cualquier i!=j (supuesto de no autocorrelación 
			residual)
	Aplicando los supuestos de homoscedasticidad y no autocorrelación residual: 
	
	[E*E'|X]= 	s^2		 0		 0		...  0
				 0		s^2 	 0		...	 0
				 0		 0	 	s^2		...	 0
				 .		 .		 .		 .	 .
				 .		 .		 .		 .	 .			 
				 .		 .		 .		 .	 .
				 0		 0		 0		...	s^2
	
	Sacando factor comun de s^2 		
	[E*E'|X]= 			 1		 0		 0		...  0
						 0		 1	 	 0		...	 0
						 0		 0	 	 1		...	 0
				s^2	 *	 .		 .		 .		 .	 .
						 .		 .		 .		 .	 .			 
						 .		 .		 .		 .	 .
						 0		 0		 0		...	 1
	
	La matriz de la izquierda no es otra sino la identidad I, por lo cual: 
	
	[E*E'|X]= s^2 * I = s^2 
	
	De esta forma, retomando la demostración: 
	
		VARCOV = inv(X'*X)*X'*E[E*E'|X]*X*inv(X'*X)'
		VARCOV = inv(X'*X)*X'*s^2*X*inv(X'*X)' 
	
	como s^2 es escalar podemos ponerlo en cualquier parte de la multiplicación
	
		VARCOV = s^2 * inv(X'*X)*(X'*X)*inv(X'*X)'
	
	Recordemos que inv(X'*X)*(X'*X) = I 
	
		VARCOV = s^2 * inv(X'*X)
	
	De esta forma, tenemos la VARCOV. 
	
	Para calcularla, ya tenemos el término inv(X'*X). Para obtener el término 
	s^2 es útil tener E'E, dado que esto resulta en la suma de los errores al 
	cuadrado. A este, lo dividimos por n-k-1 que son los grados de libertad del 
	residuo. 
	
		s^2 = E'E / (n-k-1)
	
	Esto se puede calcular en Stata de esta forma alterna. 
	*/
	
	matrix SSR = (y-x*beta)' * (y-x*beta) 
	matrix XtX= x'*x
		/*fijarse en las dimensiones y que representan. Usualmente en un 
		ejercicio de parcial, la entrada [1,1] de XtX es N, pero en este caso
		deberia ser la entrada [6,6]*/
	
	
	scalar s2 = SSR[1,1]/(XtX[6,6]-5-1)
	scalar list s2 
	
	*Calculo de la VARCOV
	matrix VARCOV = s2* inv(x'*x)
	matlist VARCOV
	
	*Para confirmar. 
	
	reg wage points rebounds exper marr black
	vce























