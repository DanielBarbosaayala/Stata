**** Taller 11
clear all

global dir "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 11\"

use "${dir}recaudo_dian", replace

isid año seccion concepto //identificador***


collapse (mean) meanshare = share (sd) sdshare = share (count) n = share, by(seccion concepto)

*browse if seccion == "VILLAVICENCIO" & concepto == "externos"  

isid seccion concepto

gen hi = meanshar + invttail(n-1, 0.025)*(sdshare/sqrt(n))

gen lo = meanshar - invttail(n-1, 0.025)*(sdshare/sqrt(n))


gen concepto_num = 1 if concepto == "externos"

replace concepto_num = 2 if concepto == "ivadeclaraciones"

replace concepto_num = 3 if concepto == "otros"

replace concepto_num = 4 if concepto == "retenciones"

*graph set window fontface "Times New Roman"


levelsof seccion, local(seccion)

macro dir

foreach sec of local seccion{
	
preserve

keep if seccion == "`sec'"

#d;

twoway (bar meanshare concepto_num if concepto == "externos")
	   (bar meanshare concepto_num if concepto == "ivadeclaraciones")
	   (bar meanshare concepto_num if concepto == "otros")
	   (bar meanshare concepto_num if concepto == "retenciones")
	   (rcap hi lo concepto_num),
	   legend(rows(1) order(1 "Externos" 2 "Declaraciones" 3 "Otros" 4 "Retenciones") region(lwidth(none)))
	   ytitle("Participación (%)")
	   xtitle("Tipo de impuesto")
	   ylabel(, nogrid)
	   xlabel(, nolabels noticks)
	   graphregion(color(white))
	   title("`sec'")
	   name(g`sec', replace);
	      
	   
#d cr;

local graphs "`graphs' g`sec'"



restore

} 


// Combinar gráfico

#d;

grc1leg `graphs', ycommon grahregion(color(withe)) 
note("Datos de recuado DIAN")
title("Recaudo por seccional y tipo de impuesto")
subtitle("2005-2019");


graph export "${dir}recaudo_porsectipo.pdf", replace;


#d cr;




