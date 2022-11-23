/*******************************************************************************
							*Clase 9 - 202110
					*Mínimos Cuadrados Restringidos
*******************************************************************************/


**************************************
*		BASE DE DATOS				 *
**************************************

	cd "/Users/veronicaperez/Dropbox/Econometria 1 - 2021-10/Clases complementarias/Clase 9"
	
	/*Tenemos 3 bases principales con información de jugadores
	de la NBA
	1. players: info personal sobre los jugadores, identificador = id
	2. stats: estadisticas de los jugadores (identificador id)
		incluye la variable team
	3. teams: informacion de los equipos (identificador =team)
	*/
	
*0. Inspeccionando las bases
******************************

	*players:
	****************

		use players.dta, clear
		*en esta base la variable id identifica de forma unica a los jugadores

	*stats:
	****************
		
		use stats.dta, clear
		*en la base stats la variable id es el identificador unico
		
			*Podemos utilizar id para unir a los jugadores con sus estadísticas. En stats tenemos la variable team que nos indica a que equipo pertenecen los jugadores, esta variable no es un identificador único.

	*teams:
	****************

		use teams.dta, clear
		*en teams la variable team si es identificador único del equipo.
	
*1. Uniendo las bases
******************************
	use players.dta, clear
	
	*pegamos las estadísticas usando el id
	merge 1:1 id using stats.dta
	
	*borramos los resultados del merge para hacer el merge con teams
	drop _merge
	
	*pegamos los datos de team
	merge m:1 team using teams
	
	*hay un problema porque la variable team es numero en el master (la base que estamos usando) y str en el using (la base que queremos pegar) 
	*Lo que tenemos que hacer es convertir team a str en el master 
	tostring team, replace
	
	*ahora si podemos hacer el merge
	merge m:1 team using teams.dta
	
	*Los resultados de este merge son diferentes al anterior. Por que? Hay dos equipos que estan en la base de teams, pero sus jugadores no están en la base de players

	

**************************************
*	MCR Multiples restricciones	 *
**************************************
	
	/*MCR CON MULTIPLES RESTRICCIONES
		*1. Enfoque lineal
		*2. Enfoque matricial
		
	Variables a utilizar:
	
	lwage= ln(Salario del jugador)
	exper = años en la liga
	games = promedio de partidos jugados por año
	points = promedio de puntos por partido
	avgmin = minutos promedio por partido
	allstar = VARIABLE DICÓTOMA = 1 si el jugador 
		fue all star la última temporada
	

	*EJERCICIO 1 - Enfoque lineal:
	
	Tenemos el siguiente modelo:

	lwage= B0 + B1exper + B2games + B3points + B4avgmin + B5allstar + U 

	*Se desea probar la hipótesis nula de que, una vez controlando por años 
	en liga, partidos por año y si fue all star, los estadísticos que miden el desempeño 
	(points avgmin) no tienen efecto sobre el salario de los jugadores de 
	baloncesto

	* Ho: B3=0, B4=0
	* Ha: Ho no es verdadera

	*Para probarlo, utilizamos la prueba conjunta F con los modelos restringido y no restringido.

	*Modelo NO RESTRINGIDO
	********************************************************************************/
	
	reg lwage exper games points avgmin allstar
	scalar SCRnr=e(rss)
	scalar glnr=e(N)-e(rank)
	scalar r2nr=e(r2)

	*Modelo RESTRINGIDO
	********************************************************************************
	reg lwage exper games allstar
	scalar SCRr=e(rss)
	scalar glr=e(N)-e(rank)
	scalar q=glr-glnr
	scalar r2r=e(r2)

	*Estadístico F
	**************
	scalar F=((SCRr-SCRnr)/q)/(SCRnr/glnr)
	dis F
		*50.50
		*RHo? que significa?
		
	*De forma automática con test
	reg lwage exper games points avgmin allstar
	test points avgmin 

	*Forma R2 del estadístico F
	scalar F_R2=(((r2nr-r2r)/q))/((1-r2nr)/glnr)
	dis F_R2

	********************************************************************************
	
		lwage= B0 + B1exper + B2games + B3points + B4avgmin + B5allstar + U 

	
	*EJERCICIO 2 - matricial
	
	/* Tenemos el siguiente modelo:

	lwage= B0 + B1exper + B2games+ B3points + U 

	Ahora suponga que ud quiere probar las siguientes tres hipotesis:
	
	1. El efecto de los años en la liga sobre el salario es igual a dos veces el ƒ
		efecto de los partidos jugados por año + el promedio de puntos, ceteris 
		paribus
	2. El efecto de los partidos jugados por año sobre el salario es igual a el 
		promedio de puntos, ceteris paribus
	3. El efecto de los años en la liga sobre el salario es igual a el promedio 
		de puntos, ceteris paribus.

	Luego las hipotesis son las siguientes:
	H0: B1=B3, B2=B3, B1=2B2+3B3
	HA: H0 no es verdadera

	En vez de reemplazar los betas en el modelo teórico podemos utilizar un 
	enfoque matricial:

	Definimos las hipotesis de la siguiente manera:
	HO: B1=2B2+3B3, B2=B3, B1=B3
	Ha: H0 no es verdadera
	*/

	reg lwage exper games points
	ereturn list 
	 
	matrix beta=e(b)
	matlist beta
	matrix VARCOV=e(V)
	matlist VARCOV

	*Matriz R
	*Nota: el beta0 va a al final
	matrix define R=(1,-2,-3,0\0,1,-1,0\1,0,-1,0)
	matlist R

	*Matriz RB
	matrix define RB=R*beta'
	matlist RB

	*Matrix r
	matrix define r=(0\0\0)
	matlist r

	*Matrix W
	matrix define W=(RB-r)'*(inv(R*VARCOV*R'))*(RB-r)
	matlist W

	*Estadístico F
	scalar W=W[1,1]
	display W

	scalar F=W/3
	display F
	*79.38
		
	*Utilizando el comando automatico	
	reg lwage exper games points 
	test (exper=2*games+3*points) (games=points) (exper=points)
	*79.38
