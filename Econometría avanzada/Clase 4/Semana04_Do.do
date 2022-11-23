* Econometría Avanzada
* Clase Complementaria
* 2021-2
clear all
cap log close
set more off
cls 

global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 04"

if "`c(username)'"=="dnewb"{
	cd "D:/OneDrive - Universidad de los Andes/2-Complementarias/${dir}" 
	gl path "D:/OneDrive - Universidad de los Andes/2-Complementarias"
} 
else if "`c(username)'"=="storr"{
	cd "C:\Users\torre\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:/Users/torre/OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Dac12"{
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}" 
	gl path "C:\Users\Dac12\OneDrive - Universidad de los Andes"
} 
else if "`c(username)'"=="Camilo"{
	cd "/Users/camilo/OneDrive - Universidad de los Andes/Academia/Clases/${dir}" 
	gl path "C:/OneDrive - Universidad de los Andes"
} 

else cd "C:\Users\caaya\OneDrive - Universidad de los Andes\universidad\8 semestre\Econometría avanzada\Clases complementarias\Clase 4"
	 

gl data "${path}\Econ. Av. - COMP\Bases de datos/RCT"
*********************************************************************************
** CLASE 5 - RCT 															   **
*********************************************************************************

use "AeioTU.dta", clear
describe
	* Outcome de interés (Y): Habilidades cognitivas
	* Variable indep. de interés (X): Asignación a centro de cuidado
		/* ¿Cuál es el efecto de la asignación de un cupo en un centro de 
			cuidado sobre el desarrollo cognitivo? 								*/
	
* 1. Balance muestral
* -------------------------------------------------------------------------------
global covs "cognitivo_BL sexo centrocuidadp_BL"
di "${covs}"

*) Enfoque 1: Diferencia de medias
	
	* t-test
	foreach var in $covs {
		display ""
		display "******* `var' *******"
		ttest `var', by(D) 
	}
	
	* Chi2 de pearson (Variables categóricas)
	
	xtile q_income=riqueza_BL, n(5) /*Generar quintiles de riqueza*/
	
	tab q_income D, chi2
	
	* Tarea: Revisen esta tabla de diferencia de medias
	mat balance=J(3,10,.)
	mat significancia=J(8,10,0)

	sum cognitivo_BL 
	return list
	
	ttest cognitivo_BL, by(D)
	return list
	
	tokenize ${covs}
	forvalues j=1/3{

		qui sum ``j''
		matrix balance[`j',1]=r(mean)
		matrix balance[`j',2]=r(sd)
		ttest ``j'', by(D) 
		matrix balance [`j',3]=r(mu_2) // tratados
		matrix balance [`j',4]=r(sd_2)
		matrix balance [`j',5]=r(mu_1) // no tratados
		matrix balance [`j',6]=r(sd_1)
		matrix balance[`j',7]=r(mu_2)-r(mu_1)
		matrix balance[`j',8]=r(se)
		matrix balance[`j',9]=r(p) 
		matrix significancia[`j',7]=(r(p)<0.1)+(r(p)<0.05)+(r(p)<0.01)

		matlist balance
		matlist significancia
	}

	frmttable using "Tabla_1_Balance_Muestral.doc", replace sdec(3)				/// 
		statmat(balance) substat(1) annotate(significancia) asymbol(*,**,***)	///
		title("Tabla 1. Balance muestral")										///
		ctitles("", "Muestra completa", "Tratamiento", "Control", "Diferencia",	///
			"p-valor")															///
		rtitles("Cognicion, BL"\ "" \"Sexo"\ "" \ "Asistencia centro, BL")	
	
*) Enfoque 2: Análisis de regresión		
reg D ${covs}, r
test ${covs}
	/*  Se rechaza la H0, por lo que las características observadas
			sí explican la asignación el tratamiento. 
		Note que las pruebas t de esta regresión son distintas a las 
			de la diferencia de medias											*/
		
* 2. Estimación
* -------------------------------------------------------------------------------

*) Efecto en la distribución
ksmirnov cognitivo_ajust, by(D) // revisa si el tratamiento generó diferencia entre contra el control  // no sirve para dicotomas
	/* H0: área que diferencia las CDFs es 0									*/
	/* ¿Funciona esto para variables discretas?									*/
	
*) RLS
reg cognitivo_ajust D

*) RLM
reg cognitivo_ajust D ${covs}
	/* Significancia económica: ¿es 0.39 SD un efecto de magnitud importsnte?
	
	- En una distribución normal el 15% de la muestra se ubica a 0.39 SD de la 
	  media. 
	- El gap cognitivo de niños en el decil más bajo y el más alto (ESE 1-3) 
	  en Bogotá es de 0.57 SD. Eso quiere decir que el efecto del tratamiento 
	  compensaría el 68% del gap, !es inmenso!				
	- Si vars estandarizadas, se lee el efecto en desviaciones estandar
	- El coeficiente de D, es el ITT, intención de tratar.
	- Primero normalizar la variable (-media/desviación estandar) Tomar la
	  distribución normal estandar, y ver cuanto porcentaje está dentro de la
	  distribución																*/
					
*) Errores estándar

	* Heteroscedasticidad
	reg D ${covs}
	reg D ${covs}, r  /// mejor cuando no hay distinción entre ubicación geográfica

	/// Siempre incluir errores robustos
	
	* Autocorrelación
	reg cognitivo_ajust D ${covs}, cluster(barrio) /* si hay poquitos clusters 
	(menos de 32) es mejor usar robust */
		
*********************************************************************************	
** Ejercicio : 														 		   **
** La atrición es un problema importante de los RTCs. Genere una variable que  **
** le indique si para este estudio hubo atrición y haga una tabla con pruebas  **
** estadisticas que le de evidencia si dicha atrición puede o no ser           **
** problemática (pista: use las características observadas para esto). Con     **
** base en esto, concluya si su atrición puede ser problemática.               **
*********************************************************************************

		
			
* genero la variable de atrición

gen attrition = cond(cognitivo_ajust==. & cognitivo_BL!=.,1,0)
tab attrition

order cognitivo_BL cognitivo_ajust attrition
br

mat balance_atri=J(8,10,.)
matlist balance_atri
mat star_atri=J(8,10,0)
	
local n = 0
foreach var in $covs{
	local n = `n'+1
	qui sum `var'
	matrix balance_atri[`n',1]=r(mean)
	matrix balance_atri[`n',2]=r(sd)
	ttest `var', by(attrition) 
	matrix balance_atri [`n',3]=r(mu_2) // tratados
	matrix balance_atri [`n',4]=r(sd_2)
	matrix balance_atri [`n',5]=r(mu_1) // no tratados
	matrix balance_atri [`n',6]=r(sd_1)
	matrix balance_atri[`n',7]=r(mu_2)-r(mu_1)
	matrix balance_atri[`n',8]=r(se)
	matrix balance_atri[`n',9]=r(p) 
	matrix star_atri[`n',7]=(r(p)<0.1)+(r(p)<0.05)+(r(p)<0.01)
}
matlist balance_atri
matlist star_atri

frmttable using "Tabla_bono_Balance_atricion.doc", replace sdec(3)				/// 
statmat(balance_atri) substat(1) annotate(star_atri) asymbol(*,**,***)		///
title("Tabla Bono. Balance Atrición")											///
ctitles("", "Muestra completa", "Atrición", "No atrición", "Diferencia",		///
		"p-valor")															///
rtitles("Cognicion, BL"\ "" \"Sexo"\ "" \ "Raza" \ "" \ "Riqueza, BL"		///
        \ "" \ "No. Ninos en casa, BL"\ "" \ "Asistencia centro, BL"\ "" \ 	///
		"Edad, BL" \ "" \ "Edad^2, BL" \"" )









