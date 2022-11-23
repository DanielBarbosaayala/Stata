

* do-file: puedo guardar lineas de código

* preliminar

clear all

cd "C:\Users\Carlos A. Ayala\Desktop\universidad\Cuarto Semestre\Taller de Stata\Clase 1\Ejercicios de clase\"

log using "Bitácora_Clase 1", replace

* help log: ayuda para los comandos


* punto 1: importación de base de datos

import excel "ProyeccionMunicipios2005_2020.xls", sheet("Mpios") cellrange(A9:T1131) firstrow case(lower)
 
	

