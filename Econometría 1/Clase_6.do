********************************************************************************
*				Complementaria econometría 1 2021-1.						   *
*							Clase 6											   *
********************************************************************************

clear all
set more off

****** Regresion lineal multiple
ssc install bcuse

bcuse nbasal.dta, clear // Abrimos la base de datos
* Y = XB + E

*Generamos las matrices necesarias para la estimación:
	* Hay dos formas de hacerlo, la primera: 
	gen uno=1
	mkmat wage points rebounds exper marr black uno 
	matrix x=points, rebounds, exper, marr, black, uno  // la coma diferencia las columnas. Para diferenciar las filas se utiliza el "\".
	matlist x
	/* Acabamos de crear la matriz de la forma: 
		[X]=	 	 x_11	 x_12	 x_13	...  1
					 x_21	 x_22	 x_23	...  1
					 x_31	 x_32	 x_33	...  1
					 .		 .		 .		 .	 .
					 .		 .		 .		 .	 .			 
					 .		 .		 .		 .	 .
					 x_n1	 x_n2	 x_n3	...  1
	*/
	
	* la segunda puede ser en una sola linea (ya tenemos la variable uno generada): 
	mkmat uno points rebounds exper marr black , matrix(x)
	matlist x
	/* Acabamos de crear la matriz de la forma: 
		[X]=	 	 1		x_11	 x_12	 ...	x_1k
					 1 		x_21	 x_22	 ...	x_2k
					 1 		x_31	 x_32	 ...	x_3k	
					 .	 	 .		 .		  .	 
					 .		 .		 .		  .	 			 
					 .		 .		 .		  .	 
					 1		x_n1	 x_n2	 ...	x_nk	
	*/
	
	/* 	El mkmat sin la opción "matrix(mat_name)" hace que stata entienda las 
		variables como vectores columna. En la línea 18, estamos ordenando que 
		se entiendan todas las variables seleccionadas como vectores. En la 
		linea 32 estamos creando la matriz directamente con la opción 
		"matrix(mat_name)"	y por eso en esta línea no ponemos wage (que no 
		hace parte de la matriz X).
		
		El orden en que conformamos la matriz X es muy importante!
		
		Para la matriz Y, podemos hacerlo como se observa en la línea 19 
		(solo si previamente usamos mkmat con wage), o como se observa en la 
		linea 32. 
		*/
		
	*MATRIZ Y
	matrix y=wage

	*Generemos el vector de betas estimados
	/*MATRIZ BETA = inv(x'*x)*x'*y: 
		Necesitamos: 1) multiplicar matrices, 2) transponer, y 3) invertir. 
		Todas estas funciones las encontramos si escribimos en stata: 
			help matrix functions
		
		1) usamos el operador "*"
		2) usamos el operador " ' "
		3) usamos la función "inv(mat_name)"
		
		Es importante que la multipliación de matrices esté definidad, es decir 
		que para la multiplicación de matrices A[mxn]*B[ixj], n=i. Adicional, 
		si intentamos invertir una matriz A[mxn], esta debe ser cuadrada, o en 
		otras palabras m=n. 
	*/
	matrix xt 		= 	x'
	matrix xtx		=	x'*x
	matrix xtx_inv	=	inv(x'*x)
		matrix list xtx // la entrada [1,1] corresponde al tamaño de la muestra, y la primera fila y primera columna corresponde a la sumatoria de cada variable, y el resto de la matriz es la sumatorio de la multiplicación de las variables explicativas en parejas (ejemplo: ∑X1*X2, ∑X1,X3, etc). 
		matlist xtx_inv	
	matrix xty		=	x'*y
		matlist xty		// La entrada [1,1] corresponde a la sumatoria de la variable dependiente, mientras el resto de entradas es la sumatoria de la multiplicación de Y con cada una de las variables explicativas (por pares: ∑Y*X1, ∑Y*X2, etc.)
	
	matrix beta		=	xtx_inv * xty
		matlist beta
	* o la forma abreviada combinando todas las funciones en una sola línea
	matrix beta=inv(x'*x)*(x'*y)
		matlist beta

	/* 	Si hacemos la regresion automatica, obtenemos el mismo resultado, 
		siempre	y cuando dejemos la variable uno al final de la matriz X. 
		Si la ponemos al principio como en la notación de clase, lo único que
		cambiará será el orden y debemos mantener este orden para el resto del 
		ejercicio: 
		*/
	reg wage points rebounds exper marr black 


	************************************
	***** 2. Suma de los cuadrados  ****
	*****	         MCO           *****
	************************************

	***SCT***
	*La suma de los cuadrados totales representa la variación de la variable explicada. 

	*sumatoria: (yi-ybarra)^2

	matrix unos=J(269,1,1) // la función J(r,c,x) llena una matriz de r filas, c columnas, del contenido x que queramos.
	matrix suma=unos'*y

	matlist suma
	scalar n=xtx[1,1] // al utilizar los corchetes cuadrados, llamamos la entrada 1,1 de la matriz xtx, que ya sabemos por la línea 77 que corresponde al total de observaciones. 
	matrix y_promedio=suma/n // las matrices no se pueden dividir, pero con esta linea le decimos a stata que divida cada entrada de la matriz por el valor n. En este caso es un escalar, pero funciona para cualquier matriz mxn. 
	scalar 		y_promedio		=	y_promedio[1,1]
	matrix vector_y_promedio	=	J(269,1,y_promedio)
	matrix 		desv_media 		=	y-vector_y_promedio
	matrix 			SCT			=	(desv_media'*desv_media)
	scalar 			SCT			=	SCT[1,1]
	display %12.2g SCT

	*267878925 

	***SCR***
	/*	La suma de cuadrados de la regresión (o del modelo para Stata) es la 
		variación de la variable dependiente que es explicada por las variables
		explicativas.  */

	*sumatoria: (ygorroi-ybarra)^2 donde ygorro es la predicción del modelo X*beta

	*Sacamos el y predicho:
	matrix			yhat		=	x*beta
	matrix 	desv_media_gorro	=	yhat-vector_y_promedio
	matrix 			SCR		 	=	(desv_media_gorro'*desv_media_gorro)
	scalar 			SCR			=	SCR[1,1]
	matlist SCR
	dis %12.2f SCR
		*147446081	
		
	***SCE***
	/* 	La suma de los cuadrados del error residual es la variación de nuestra 
		variable explicativa que le atribuimos al error. */

	*sumatoria: (yi-ygorroi)^2 = (uhat)^2
	matrix	uhat	=	y-yhat
	matrix 	SCE		=	(uhat'*uhat)
	matlist SCE
	scalar 	SCE		=	SCE[1,1]
	dis %12.2g SCE
		*120432844
		
	****Note que: SCT=SCR+SCE, lo cual también nos muestra la tabla ANOVA de la regresión. 

	************************************
	***** 2. VAR COV  ****
	************************************
	
/* Ahora es importante ver la derivación de la VARCOV. 
	
	Recordemos que 
	
		VARCOV = s^2 * inv(X'*X)
	
	De esta forma, tenemos la VARCOV. 
	
	Para calcularla, ya tenemos el término inv(X'*X). Para obtener el término 
	s^2 es útil tener E'E, dado que esto resulta en la suma de los errores al 
	cuadrado. A este, lo dividimos por n-k-1 que son los grados de libertad del 
	residuo. 
	
		s^2 = E'E / (n-k-1)
	
	Esto se puede calcular en Stata de la siguiente forma:
	
*/
	scalar residual_df 	=	rowsof(y) - rowsof(beta)
	scalar s2 = SCE / residual_df
	scalar list s2
	
	*Cálculo de la VARCOV
	matrix VARCOV = s2* inv(x'*x)
	matlist VARCOV
	
	*Para confirmar. 
	
	reg wage points rebounds exper marr black
	vce // stata muestra la misma información pero la constante está al final. recuerden que el orden es muy importante. Seguimos trabajando con la matriz que creamos "VARCOV"
	
	/* PRUEBAS DE HIPÓTESIS */
	
		/* 	Significancia individual: 
				H0: ßi =0  	vs 		Ha: ßi !=0 
			simplemente debemos acceder a la información que tenemos en las 
			matrices "beta" y "VARCOV". Recordemos que:
			
				tc= beta_j / ee(beta_j)
		Para rebounds: 
		*/
		
		scalar tc_2 = beta[3,1] / sqrt(VARCOV[3,3]) 
		
			/* 	OPCIONAL: 
				Ahora que sabemos de donde sacar los valores, podemos replicar 
				la salida de regresión en una matriz. Usaremos loops y las 
				funciones que ya conocemos */
			
			matrix t = J(6,1,.)
			forval x=1(1)6{
				scalar tc_`x' 	= beta[`x',1] / sqrt(VARCOV[`x',`x'])
				matrix t[`x',1] = tc_`x'
			}
			matlist t 
			
			matrix ee = J(6,1,.)
			forval x=1(1)6{
				scalar ee_`x' 	=  sqrt(VARCOV[`x',`x'])
				matrix ee[`x',1] = ee_`x'
			}
			matlist ee
			
			matrix p_value = J(6,1,.)
			forval x=1(1)6{
				scalar p_value_`x' = 2*ttail(residual_df, abs( t[`x',1]))
				matrix p_value[`x',1] = p_value_`x'
			}
			matlist p_value
			
			matrix resultados = beta, ee, t, p_value 
			matrix colnames resultados = wage ee t p_value
		
		/* 	Dependencia global: 
				H0: ßi =0 para todo i 	vs 		Ha: ßi !=0 para algún i
			simplemente debemos acceder a la información que tenemos de las 
			Sumas de los Cuadradros y recordar los grados de libertad para cada 
			una. Recordemos que:
			
				Fc = (SCRegresión / df_regresión) / (SCError / df_residuo)
				Fc = MSRegresión / MSError 
					donde MS indica Mean Square (cuadrados medios).
					
			Ya tenemos las SCRegresión "SCR", la SCError "SCE" y los grados de 
			libertad del error residual "residual_df". Solo nos faltan los 
			grados de libertad del modelo que corresponden al número de 
			variables explicativas o el número de parámetros que estimamos
			menos 1 de la constante (K-1, siendo K el número de parámetros).
			En este caso los grados de libertad del modelo son 5
		*/			
		scalar model_df = 5 
		scalar F= (SCR / SCE) * (residual_df / model_df)
		scalar F_p_value = Ftail(model_df, residual_df, F)
		scalar list F F_p_value
		
		/* Valores esperados: 
		
			A veces queremos saber si un jugador tiene un salario particular 
			dado que cumple ciertas características. Por ejemplo, si un jugador 
			con 30 puntos por partido, 25 rebotes, 5 años de experiencia, 
			que esté casado y que no sea de raza negra, tiene un salario de 
			1 millón de dolares por año. Esto se reduce a: 
			
				H0: 1000	=	 ß0 + ß1*30 + ß2*25 + ß3*5 + ß4*1 + ß5*0 
											VS
				Ha: 1000 	!=	 ß0 + ß1*30 + ß2*25 + ß3*5 + ß4*1 + ß5*0 		
			
			con un alpha=0.05, el estadístico de prueba sería: 
			
			tc = ß0 + ß1*30 + ß2*25 + ß3*5 + ß4*1 + ß5*0 - 1000 / 
					ee(ß0 + ß1*30 + ß2*25 + ß3*5 + ß4*1 + ß5*0)
					
			Y si recordamos nuestras clases de estadística, el numerador 
			resulta ser una operación gigantesca. Para lo cual, aprovecharemos
			las matrices que tenemos. Las hipótesis se pueden reescribir como:

				H0: 1000	=	 L*beta 
											VS
				Ha: 1000 	!=	 L*beta
				
			donde L es un vector fila que contiene la información que acompaña a
			cada coeficiente: L= [1, 30, 25, 5, 1, 0].El vector L también lo 
			podemos definir como un vector columna, lo que importa es que al 
			multiplicarlo con el vector de betas, la multiplicación esté 
			definida (Si es vector columna entonces H0: 1000= L'*beta). 
			
			Si seguimos con esta lógica, el estadístico de prueba también se 
			simplifica: 
			
				tc = L*beta - 1000 / sqrt(L*VARCOV*L')
			
			donde sqrt(L*VARCOV*L')= ee(ß0 + ß1*30 + ß2*25 + ß3*5 + ß4*1 + ß5*0)
		*/

	matrix L = 1, 30, 25, 5, 1, 0 
	* Para el numerador: 
	matrix LB = L*beta
		matlist LB 
	scalar theta = 1000
	
	* Para el denominador: 
	matrix LV =L*VARCOV
	matlist LV
	matrix LVL= L*VARCOV*L'
		matlist LVL
	scalar den=sqrt(LVL[1,1])
	
	* Calculamos el tc: 
	scalar tc_VE= (LB[1,1]-theta) / den 
	scalar list tc_VE 
	
	* Forma rápida de verificar lo que hicimos:
	reg wage points rebounds exper marr black
	lincom _cons +points*30 + rebounds*25 + exper*5 + marr*1 +  black*0 - 1000















