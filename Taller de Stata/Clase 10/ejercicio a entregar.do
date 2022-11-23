
** TALLER


** PASO 0

global dir "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 11\"

use "${dir}bog_2011", replace

**PUNTO 1

egen catm2res11=cut(m2_res11), at(0, 200000, 400000, 600000, 800000, 1000000, 1200000) icodes 
graph box val_m2_res11, name(box1)


** PUNTO 3

graph box val_m2_res11, over(catm2res11) name(box2)

**PUNTO 4

twoway (scatter val_m2_res11 m2_res11) (lfit val_m2_res11 m2_res11)

pwcorr val_m2_res11 m2_res11

** PUNTO 5

foreach i of numlist 1/6{

twoway (scatter val_m2_res11 m2_res11) (lfit val_m2_res11 m2_res11) if catm2res11 == `i', name(gscatter`i')  

}

graph combine gscatter1 gscatter2 gscatter3 gscatter4 gscatter5 gscatter6

*PUNTO 6

tw (scatter val_m2_res11 m2_res11)(lfit val_m2_res11 m2_res11), by(catm2res11)  name(gscatter_by,replace)





s














