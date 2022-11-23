
cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 13\"

use "panelcede", replace

gen d_negoc = (ano >=2011)


putexcel set "tabla_dif_medias.xlxs", sheet("t_test",replace)

putexcel C3 = ("Antes de las negociaciones")





*Despues de las negociaciones
ttest H_coca if d_negoc == 0, by (dumguer)

putexcel B10 = "Hectareas cultivadas de coca"

putexcel C10 = (r(mu_1))

putexcel D10=(r(mu_2))

putexcel E10=(r(mu_1) - r(mu_2))


if r(p)< 0.1 {
	
	putexcel F10 = "Si"
	
}
else{
	
	putexcel F10 = "No"
	
}





