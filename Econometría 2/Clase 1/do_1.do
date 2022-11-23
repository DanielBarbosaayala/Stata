*** Econometria 2

//`Dofile 1 - Clase 1

// Cuando se usa un 9 o 99 es un "no sabe  no responde".


replace married = 99 in 22/33

replace married = . if married == 99

*** If & in ayudan a modificar la base de datos.

//Basico iniciaal

inspect //ayuda a ver una distribución general

// * es un comodin, e*, busca todo lo que inicie e y las opera.     //_all ayuda a tomar todas las variables

corr _all


//sintaxis del help.


** cuando hay [] son opcionales.

reg wage  //entrega un solo estimador, B_0 = Ybarra por MCO.

sum wage  //desv. estandar = sobre la distribución de las variables.  Al sumar y restar a la media, se encuentra la mayoría de la población. 75%. (una desviación estandar) 93%(dos distribuciones estandar)
		//err. estand.==pertenece a un estimador.
		
// Cuando los datos no se distribuyen normal, se aplica logaritmo natural. 

gen lnwage = ln(wage)

hist lnwage, normal

h function // muestra los tios de funciones y operaciones que se pueden hacer en stata


