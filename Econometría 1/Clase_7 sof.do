********************************************************************************
*				Complementaria econometría 1 2021-1.						   *
*							Clase 7											   *
********************************************************************************

clear all
set more off

bcuse wage2

*Wage es una base de datos de salarios y caracteristicas individuales de n=935 individuos. 

***** Determinante del Salario *********
/*
En la clase de hoy vamos a estudiar que factores son los más importantes 
a la hora de determinar el salario.
*/

reg wage hours IQ educ exper age black

*¿Que podemos concluir de la relación entre nuestras variables independientes y el salario? ¿Obtuvimos los signos esperados en la teoría?

*Ahora para poder recuperar la información de los parámetros que estimamos primero necesitamos saber...

******* ¿Donde guarda Stata la información? **********

/*
Stata guardas todos los resultados de sus operaciones en:

	1) r(): Los resultados de los comandos generales (ej: sum) se guardan en esta sección
	2) e(): Los resultados de las estimaciones que hagamos (ej: reg) se guardan en esta sección
	
Por ahora, estamos interesados en acceder a la información de la regresión. 
¿Como hacemos para acceder a los betas o a la matriz varcov?
*/
ereturn list
* Nos muestra todos los resultados de la estimación a los cuales podemos acceder que estan guardados en e(). 

*Por ejemplo:
* el N de la nuestra base de datos
scalar N=e(N)

* El R2 
scalar R2=e(r2)
	*¿Cómo interpretamos el R2?

scalar list

*Para acceder a la matriz de beta estimados utilizamos 
matrix beta=e(b)
matlist beta
* Es un vector fila de tamaño (1x(k+1)). En la clase usualmente tenemos a beta como un vector columna por lo cual lo traspondremos 
matrix beta=beta'
matlist beta

* La matriz Var-Cov de nuestro modelo
matrix varcov=e(V)
matlist varcov

*********** Pruebas de Hipotesis sobre Valores Esperados ************
/*
A veces queremos realizar pruebas de hipotesis sobre los valores que esperamos 
que tome la variable dados ciertos valores de las variables independientes.

Por ejemplo, es posible que queramos ver si el salario de una persona que:

	- trabaja 48 horas semanales
	- tiene un IQ de 160 (como el de Einstein)
	- tiene 16 años de educacion
	- tiene 5 años de experiencia
	- tiene 30 años
	- es de raza negra
	
Es distinto de 1500 dolares

¿Cómo se traduce esto a una prueba de hipotesis?
De la siguiente forma:

H0: 1500	=	 ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1 
											VS
Ha: 1500 	!=	 ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1		
			
			con un alpha=0.05, el estadístico de prueba sería: 
			
			tc = ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1 - 1000 / 
					ee(ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1)
					
En donde el error estandar de esa expresión es igual a:

			ee(ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1)
										=
			sqrt(Var(ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1))
			
Y si recordamos nuestras clases de estadística:
				Var(A+B)=Var(A)+Var(B)+2Cov(A,B)
 el denominador de esa expresión es una operación gigantesca. Para lo cual, aprovecharemos las matrices que tenemos. 

Las hipótesis se pueden reescribir como:

				H0: 1500	=	 L*beta 
											VS
				Ha: 1500 	!=	 L*beta
				
			donde L es un vector fila que contiene la información que acompaña a
			cada coeficiente: L= [48,160,16,5,30,1,1].El vector L también lo 
			podemos definir como un vector columna, lo que importa es que al 
			multiplicarlo con el vector de betas, la multiplicación esté 
			definida (Si es vector columna entonces H0: 1500= L'*beta). 
			
			Si seguimos con esta lógica, el estadístico de prueba también se 
			simplifica: 
			
				tc = L*beta - 1500 / sqrt(L*VARCOV*L')
			
			donde sqrt(L*VARCOV*L')= ee(ß0 + ß1*48 + ß2*160 + ß3*16 + ß4*5 + ß5*30+ß6*1)

*/

matrix L= 48,160,16,5,30,1,1

* Para el numerador: 
	matrix LB = L*beta
	matlist LB 
	scalar theta = 1500
	
	* Para el denominador: 
	matrix LV =L*varcov
	matlist LV
	matrix LVL= L*varcov*L'
	matlist LVL
	scalar den=sqrt(LVL[1,1])
	
	* Calculamos el tc: 
	scalar tc_VE= (LB[1,1]-theta) / den 
	scalar list tc_VE 
	
	* Forma rápida de verificar lo que hicimos:
	
	reg wage hours IQ educ exper age black
	lincom _cons+hours*48+IQ*160+educ*16+exper*5+age*30+black*1 - 1500

****** Loops y Macros en Stata ***************
/*¿Qué son las Macros en Stata?

- Son abreviaciones que usa Stata para cadenas de caracteres muy largas y terminan representado expresiones para programar de una forma más eficiente.

Existen 2 tipos de Macros en Stata: 
	- Globals: son macros persistentes y duran toda la sesión
	- Locals: son macros más efimeras, y deben ser declaradas cada vez que son usadas 
*/

*** Locals
local variables "wage hours IQ educ exper age black"
sum `variables'
* De esta forma se acorta la lista de variables

** Globals
global variables_independientes "hours IQ educ exper age black"
reg wage $variables_independientes

* Las macros sirven también para abreviar opciones. Por ejemplo:
local opciones "title(Grafico de Dispersion) subtitle(Salario-Horas Trabajadas)"
tw (scatter wage hours, `opciones')

**** Loops ****
/* Son estructuras de programación que repiten una serie de instrucciones hasta que cierta condición se cumple.

* En Stata existen varios tipos de loops, sin embargo nosotros vamos a trabajar con:
	- forvalues
	- foreach
Cuando estamos escribiendo el codigo del loop después de escribir el comando, 
escribimos el nombre de la variable temporal que vamos a utilizar para recorrer la lista de valores que estamos iterando.
*/

** forvalues
/*
La sintaxis es: 
forvalues nombre= rango{
serie de instrucciones 
}

forvalues itera sobre una lista de elementos númericos
*/

matrix ejemplo=J(6,1,0)
matlist ejemplo
forvalues i=1(1)6{
display `i'
matrix ejemplo[`i',1]=1
matlist ejemplo
}

matrix matriz_de_ejemplo=J(5,5,0)
matlist matriz_de_ejemplo

forvalues i=1(1)5{
dis `i'
matrix matriz_de_ejemplo[`i',`i']=1
matlist matriz_de_ejemplo
}

/*
foreach es un loop más general y puede iterar sobre macros, strings, y diferentes tipos de listas

sintaxis:

foreach nombre in macro{
serie de instrucciones 
}

*/
** Otra forma de usar las macros:

* Comando levelsof
* Nos permite crear un local a partir de los valores que puede tomar una variable.

levelsof sibs, local(hermanos)
display `hermanos'

foreach num_hermanos in `hermanos'{
dis "Estadistica descriptivas de individuos con `num_hermanos' hermanos"
sum wage if sibs==`num_hermanos'
}

*Nota: Si vamos a usar un local dentro de un loop, tenemos que correr el comando que crea el local y el que lo utiliza, al mismo tiempo.


