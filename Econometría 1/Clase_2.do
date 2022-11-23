/* 
Econometria 1 - 202110 
CLASE 2
	Este es un ejemplo de do file, donde lo que aparece en verde serán comentarios
	en azul serán los comandos y en rojo expresiones alfanuméricas.
*/

/* Organizamos la casa */
	clear all // Limpia la memoria de Stata, cuando corremos muchas veces un do, cobra sentido ponerlo al inicio. 

	cd "/Users/danielgamboarinckoar/Dropbox/Clases/Econometria 1 - 2021-10/Clases complementarias/Clase 2" // define la carpeta donde guardaremos los datos y los resultados.

/* importar datos */

	import excel "wage2_excel.xlsx", sheet("Sheet1") firstrow clear
	
	import delimited "wage2_csv.csv", encoding(UTF-8) clear 
	
	import delimited "wage2_txt.txt", encoding(UTF-8) clear 
	* Hay más formatos que se pueden importar, pero para tener una ayuda extra, se puede hacer a través de clicks en el menú de stata: archivo > importar >...

/* explorando la base de datos */

	describe // Mostramos todas las variables y sus FORMATOS. Número de var y obs
	codebook //Resumen de todas las variables
	inspect // Histograma feo. Me dice cuántos valores son missing, +, - o 0 x var
	list IQ educ exper age in 1/10  // Ver primeras 10 obs de las var sel
	
	browse // *Para mirar como esta la base de datos
	edit // similar al browse pero permite alterar la información. CUIDADO!

/* Utilidad de display */
	display 10+2
	display 10*2
	display sqrt(144)
	display "La raiz de 144 es: " sqrt(144)

/* utilidad de rename y generate */ 
	rename wage salario // renombra la variable, primero va el nombre actual y después el nombre nuevo
	generate salario_cuadrado = salario^2
	generate var_nueva=iq+kww 
		* Para generar variables nuevas se pueden hacer transformaciones matemáticas, trigonométricas o estadísticas  o incluso hacer funciones que dependan de 2 o más variables. 

/* Utilidad de las etiquetas (labels) */
	label var salario "Salario en miles de dolares por semana" // Etiquetar variables

	label define casados 0 "Soltero" 1 "Casado" // crear etiquetas para los valores de una variable.
	label value married casados // aplicar las etiquetas creadas a la variable. 

/* Utilidad del help!!!! */
	help sum 
	
	
	
		*B. Repaso estadística para el taller
********************************************************************************	
	sum salario //Sum me saca estadisticas descriptivas

	sum * // Me estoy cogiendo todas las variables

	sum salario if hours > 60 // condicionamos las estadísticas a las personas que reportan más de 60 horas de trabajo a la semana. 

	sum salario, detail // más información como percentiles, mediana, skewnesis, etc

	hist salario // muestra la distribución de la variable salario. El sum es un resumen de esta distribución y debe guardar relación. 
	
	 

/* Estadísticas relevantes y algunas definiciones */
	*Promedio
	*Desviacion estandar: 
*Definición: La desviación estándar es la medida de dispersión más común, que indica qué tan dispersos están los datos con respecto a la media. Mientras mayor sea la desviación estándar, mayor será la dispersión de los datos.
*Interpretacion: La desviacion del salario de los individuos de la muestra con respecto al promedio es de __ en promedio. 

	*Minimo
	*Maximo

	*Percentiles
*Definicion: El percentil es una medida que indica, una vez ordenados los datos de menor a mayor, el valor de la variable por debajo del cual se encuentra un porcentaje dado de observaciones en un grupo. Por ejemplo, el percentil 20 es el valor bajo el cual se encuentran el 20 por ciento de las observaciones.

*Interpretacion:
	*Por debajo de salario 310 se encuentran el 1% de las observaciones.

/* Ejercicio: ver cuales es el IQ de las 10 personas con mayores salarios */

gsort - salario // organiza la base de datos en orden descendente (-) del salario.
list salario iq in 1/10 // se muestran los valores de salario e iq para las primeras 10 obs. 
sum salario iq // se puede identificar que 7 de las 10 personas con mayores salarios tienen un iq superior al promedio. 

/* NOTA FINAL: 
	Cuando hemos modificado algo en nuestra base de datos y nos damos cuenta que la embarramos, no hay un devolver y esto puede ser problemático cuando hemos avanzado bastante en nuestro ejercicio. Lo más parecido al ctrl+z son los comandos preserve y restore. Ejemplo: Queremos calcular la media del iq de los trabajadores casados con menos de 1000 dolares de ingreso por semana. Hay dos formas de hacerlo */
	* Opción 1 (condicionales + de 1):
	sum iq if married==1 & salario <1000
	* Opción 2 (eliminar la muestra que no cumple las condiciones y recuperar los datos):
	preserve // guardamos la base antes de modificarla
	keep if married==1 // mantenemos en la base a los que están casados.
	drop if salario>=1000 // eliminamos de la base los que tienen un salario igual o superior a 1000 USD por semana. 
	sum iq // calculamos las estadísticas 
	restore // recobramos la base inicial para seguir haciendo otros calculos. 

	



