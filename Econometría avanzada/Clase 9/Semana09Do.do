* Econometría Avanzada
* Clase Complementaria
* 2022-2
clear all
cap log close
set more off
cls 

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 08"

if "`c(username)'"=="storr"{
	cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:/Users/torre/OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Dac12"{
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:\Users\Dac12\OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="valentinadaza"{
	cd "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}"
	gl path "/Users/valentinadaza/Library/CloudStorage/OneDrive-UniversidaddelosAndes"
} 

else //cd "ESTUDIANTE: COPIE AQUÍ LA RUTA DE SU DIRECTORIO"


gl data "${path}\Econ. Av. - COMP\Bases de datos"
	 
*********************************************************************************
** CLASE 9 - Panel lineal							 						   **
*********************************************************************************

* 1. Modelos de efectos fijos
* -------------------------------------------------------------------------------
use "${data}/Panel lineal/Mandatory Seat Belts/SeatBelts", clear
describe

	* Outcome de interés (Y): número de accidentes fatales por millón de millas 
	* de tráfico.
	* Variable indep. de interés (D): 1 si tiene regulación de uso de cinturón, 
	* 0 de lo contrario. 
	
	/* ¿Cuál es el efecto de la obligatoriedad del uso del cinturón de seguridad
		sobre el número de accidentes de tránsito fatales?						*/
	
*) Organización de datos

	* Nivel de observación
	duplicates report state
	duplicates report state year
	
	*Comando alternativo: unique
	
	* ssc install unique
	
	unique state
	unique state year
		
	* Periodicidad
	tab year
		
	* Definición de la base como panel 
	sort state year
	xtset fips year, yearly
	xtdescribe 

*) Estadísticas descriptivas
	
	* Tarea: revisar el código. Evolución de la Variable dependiente
	local label_fat: var label fatalityrate
	macro list 

	preserve
		collapse fatalityrate, by(year) 
		tsset year
		tsline fatalityrate, yti(" ") ti(`label_fat') graphregion(color(white))
	restore 

	* Medias: overall, between, within.	
	sum fips year income
	xtsum fips year income
		
		global controles "vmt speed65 speed70 drinkage21 ba08 income age"
		d ${controles}

*) Estimación de Modelos de Efectos Fijos: E[X,mu]!=0

	* 1. Incluir dummies
	reghdfe fatalityrate Treatment ${controles}, absorb(fips year) 				///
		cluster(fips year)
					
	* 2. Within
	xtreg fatalityrate Treatment ${controles} i.year, fe cluster(fips)

	* 3. Primeras Diferencias
	global d_controles 
	foreach xvar of global controles {
		cap gen d_`xvar' = d.`xvar'
		global d_controles ${d_controles} d_`xvar'
	}
		
	reg d.fatalityrate d.Treatment ${d_controles}, nocons 
	
	* 4. Primeras Diferencias IV
	*ssc install xtivreg2
	xtivreg2 fatalityrate (Treatment=l.Treatment) ${controles}, fd nocons first

* 2. Panel Dinámico
* -------------------------------------------------------------------------------
use "${data}/Panel Dinámico/policyreformbpea", clear
describe 

	* Outcome de interés (Y): inflación.
	* Variable indep. de interés (D): 1 si el país tiene un Banco Central 
	* independiente, 0 de lo contrario. 
	
	/* ¿Cuál es el efecto de la independencia del Banco Central sobre la 
		inflación?																*/

*) Identificador numérico

	* Función group
	egen id_country = group(country)
	drop id_country
	
	* Comando encode
	encode country, gen(id_country)

*) Definición de la base como panel 
xtset id_country year, yearly
xtdes

*) 1. Anderson-Hsiao (PD-IV)
ivreg2 D.inflation (D.L.inflation=L2.inflation) D.(cbi_dummy) i.year, nocons first

*) 2. Arellano-Bond
*ssc install xtabond2
xtabond2 inflation L.inflation cbi_dummy i.year, noleveleq robust 				///
	small gmm(L.inflation) 
		// Especificación estandar de un modelo de A-B. 
	
xtabond2 inflation L.inflation cbi_dummy i.year, noleveleq robust 				///
	small gmm(L.inflation) iv(cbi_dummy i.year)
		// Aqui definimos que cbi_dummy i.year son varaibles exógenas.
		// Con la opción laglimits(# .) dentro gmm() es posible definir
		// a partir de qué rezago se toman los intrumentos
