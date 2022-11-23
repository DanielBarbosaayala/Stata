********************************
*****   CLASE 10 - 202110  *****
********************************

/* 	Bernal y Camacho (2010) encuentran evidencia que el peso de los niños al nacer
	es un determinante de la calidad de vida en el futuro de los recien nacidos, 
	pues encuentran que un mejor cuidado durante el embarazo y unos buenos 
	cuidados en los primeros años de infancia se relacionan con las habilidades
	y capacidades que tendrán los niños en el futuro. A partir de esto, concluyen
	que la primera infancia es vital para promover el bienestar y la igualdad de 
	oportunidades. 

	Por lo anterior, contaremos con una base de datos que contiene la información
	del peso al nacer de los niños para una muestra de 1832 nacimientos, contando
	con información de los padres y su relación con el uso del cigarrillo. 
	Teniendo en cuenta que se han realizado estudios donde se encuentra que el 
	consumo de 10 o más cigarrillos diarios se asocian con complicaciones en el 
	embarazo, partos prematuros y por lo mismo un menor peso al nacer 
	(Chinchilla et al, 2019), con la base de datos de esta clase buscaremos 
	identificar si el peso se ve afectado negativamente con simplemente consumir 
	cigarrillos. 
	
Referencias: 


Bernal, R., & Camacho, A. (2010). La importancia de los programas para 
la primera infancia en Colombia. Universidad de los Andes, Facultad de Economía.
	
Chinchilla Araya, T., & Durán Monge, M. D. P. (2019). Efectos fetales y posnatales 
del tabaquismo durante el embarazo. Medicina Legal de Costa Rica, 36(2), 68-75.	

*/

	

sum bwght cigs mage mwhte mblck moth




	/*
	¿cuál es el peso al nacer promedio? ¿es normal este valor? Google!
	¿cuál es la edad promedio de la madre? ¿desde qué edad es riesgoso un 
		embarazo? ¿Los embarazos en personas muy jovenes son riesgosos? Google! 
	¿Será que la raza podría incidir en el peso al nacer? 
	¿cuál es la distribución de la raza de las madres? 
	*/

hist cigs
	/*
	Para probar la hipótesis de que el peso se ve afectado negativamente con 
	simplemente consumir cigarrillos, es necesario identificar en la base de 
	datos las personas que fuman independientemente de cuantos cigarrillos fumen.
	
	La diferencia de este análisis con lo que se comprueba en Chinchilla et al 
	es que se quiere ver un efecto negativo ya sea con 1 cigarrillo o con 40. En 
	otras palabras, se quiere ver si el efecto nocivo del cigarrillo es más 
	amplio. 
	
	Con este fin, crearemos una dummy que nos ayude a responder la PH. 
	*/
	
gen fuma=cigs>0
tab fuma
ttest bwght, by(fuma) //se hace con la idea de buscar la dif en el promedio en los dos grupos. Se usa para dif de medias.

//con esta prueba saco estadisticos t y puedo comparar por medias mediante prueba de hipótesis

	/* 
	¿Se puede decir que los hijos recien nacidos de las mamas fumadoras tienen 
	menor peso al nacer? 
	
	si se puede
	
	¿De cuánto es la diferencia?
	es de 187.3862
	
	*/

reg bwght fuma 


//Cuando uso la reg para una var ind y una dicotoma, se puede ver valores esperados, dif del beta_0, podría decirse


	/* mismo resultado del ttest, pero hay más información disponible que puede 
	explicar el peso. Aquí entran los controles para limpiar el efecto encontrado
	
	usaremos la edad de la madre lineal y al cuadrado, el número de visitas 
	prenatales (npvis) y la raza. 
	
	El efecto de las visitas se espera que se relacione con un mayor peso ¿por qué?
	
	*/

egen raza_madre=group(mwhte mblck moth) //me genera una asignacióno de 1 a n para cada grupo. 

tab raza_madre

reg bwght fuma mage magesq npvis i.raza_madre 

//El valor de raza_madre, dado 2 o 3, muestra la diferencia del peso del niño por la raza de la madre.

//no muestra relación causal todavía, dadas las diferencias existentes entre grupos.

reg bwght fuma mage magesq npvis mwhte mblck 

	/* Al genera la variable categórica de raza madre, estamos agrupando las 3 
	dummies que ya teníamos. Las dos regresiones realizadas corresponden al 
	mismo cálculo, pero la segunda línea utiliza "i.variable" para que Stata 
	entienda que esa variable es categórica y genere una variable dummy por J-1
	categorías y las incluye en la regresión. De esta forma nos evitamos la 
	trampa de la variable dicotoma y también la necesidad de crear dummies si no
	las tenemos. Para definir la categoria base podemos usar "ib#.variable" 
	donde el # sería la categoría que queremos poner, en este caso puede ser
	1, 2 o 3.
	
	Si combinamos el uso del prefijo "i." con el del "c." que le indica a Stata 
	que la variable que lo acompaña es una variable continua, podemos hacer 
	interacciones sin tener que crear las variables como tal. 
	
	Probemos con la interacción entre la dummy "fuma" y el efecto de la edad.
	(Recordemos que ya se evidencia que hay un efecto marginal variable)
	*/

reg bwght i.fuma##c.mage i.fuma##c.magesq npvis i.raza_m 	
	
/* Pruebas de hipotesis de Cambio estructural */
	/* INTERCEPTO :
	H0: Beta(fuma)=0 Vs Ha: Beta(fuma)!=0 ; alpha=0.05
	Estadístico: tc=B/ee(B) (o una F restringida)
	*/
	test (1.fuma)
	/* Pendiente (o en este caso, efecto marginal) :
	H0: Beta(1.fuma#c.mage)=Beta(1.fuma#c.magesq)=0 Vs Ha: algun B !=0 ; 
	alpha=0.05
	Estadístico cuando es un efecto constante lineal: tc=B/ee(B)
	Estadístico cuando es un efecto variable: La F de restricción. 
	*/
	test (1.fuma#c.mage)(1.fuma#c.magesq) 
	/* Cambio Simulataneo:
	Ha: Beta(fuma)=Beta(1.fuma#c.mage)=Beta(1.fuma#c.magesq)=0 
		Vs 
	H0: algun B !=0 ; 
	alpha=0.05
	Estadístico cuando es un efecto variable: La F de restricción. 
	*/
	test (1.fuma#c.mage)(1.fuma#c.magesq) (1.fuma)

	twoway (scatter bwght mage if fuma==0 ) (qfit bwght mage if fuma==0 ) ///
		(scatter bwght mage if fuma==1 ) (qfit bwght mage if fuma==1 )
	/* A partir de las pruebas de hipótesis de cambio estructural, podemos decir
		que las pruebas de intercepto y pendiente no dan significativas, sin 
		embargo,  todas las variables que representan el cambio estructural en 
		conjunto si resultan ser significativas. Esto es normal, e indica que 
		por separado, la variable dummy y las interacciones de esta con la 
		edad y edad^2 de la madre no aportan suficiente información, pero al 
		evaluarlas al tiempo si. 
		
	La gráfica refleja nuestra estimación con interacciones. Se puede apreciar
		que el peso estimado de los hijos de mamás fumadoras siempre está por 
		debajo de los hijos de las mamás que no fuman. 
		
	BONO: ¿Cuál es la edad que máximiza el peso al nacer de los niños de mamás 
	que fuman y no fuman? (0.3 en el taller 2) Según linea 103 de este do. 
	*/
	
	/* Por último: Qué podemos decir de la raza */
	graph bar bwght, over(raza_madre)
	reg bwght mwhte mblck moth, nocons
	coefplot
	/* ¿alguna raza tiene un peso al nacer mayor? 
	¿alguna intuición detrás del resultado? */
	
	
	
