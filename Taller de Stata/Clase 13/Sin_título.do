
cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 13\"

use "panelcede", replace

*dummy de tiempo

gen d_negoc = (ano>=2011)


* putexcel

putexcel set "tabla_dif_medias.xlsx", sheet("t_test", replace) modify

** Encabezado de la tabla dif_medias

* Antes

putexcel C3 = ("Antes de las negociaciones")

putexcel (C3:F3), merge hcenter

putexcel B4 = ("Variable") C4 = ("No guerrilla (C)") D4 = ("Guerrilla (T)") E4 = ("Dif. (C-T)") F4 = ("Significancia")

* Despues

putexcel H3 = ("Despues de las negociaciones")

putexcel (H3:K3), merge hcenter

putexcel H4 = ("No guerrilla(C)") I4 = ("Guerrilla (T)") J4 = ("Guerrilla (C-T)") K4 = ("Significancia") 


local fila = 5

foreach var of varlist TMI-col_total{

* Antes de las negociaciones

ttest H_coca if d_negoc == 0, by(dumguer_9705)

local label: var label `var'

putexcel B`fila' = "`label'"

putexcel C`fila' =(r(mu_1))

putexcel D`fila' = (r(mu_2))

putexcel E`fila' = (r(mu_1) - r(mu_2))


if r(p)<0.1 {
	
	putexcel F`fila' = "Si"
	
}

else{
	
	putexcel F`fila' = "No"
	
}



* Despues de las negociaciones

ttest H_coca if d_negoc == 1, by(dumguer_9705)

putexcel H`fila' = (r(mu_1))

putexcel I`fila' = (r(mu_2))

putexcel J`fila' = (r(mu_1) - r(mu_2))


if r(p)<0.1 {
	
	putexcel K`fila' = "Si"
	
}

else{
	
	putexcel K`fila' = "No"
	
}

local ++fila

}



