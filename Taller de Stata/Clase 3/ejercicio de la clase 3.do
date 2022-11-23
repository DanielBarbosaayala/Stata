

** Ejercicio 3 **

** Carlos A. Ayala      201911488

* PUNTO 1:
cd "C:\Users\Carlos A. Ayala\Desktop\universidad\Cuarto Semestre\Taller de Stata\Clase 3\"

* PUNTO 2:

use "read_sanjose", clear

* PUNTO 3: 

browse if regexm(estacion,"S.")

replace estacion = regexr(estacion,"S.","San")

replace estacion = regexr(estacion,"Jd.Satelite","Jardín Satelital")

replace estacion=regexr(estacion,"é","e")

replace estacion=regexr(estacion,"í","i")

replace estacion= strupper(estacion)


*PUNTO 4: 

gen year= substr(fecha,-4,4)

gen month= substr(fecha,-7,2)

gen day= substr(fecha,7,2)

*PUNTO 5:

destring year, replace

drop if year == 2017

*PUNTO 6:

browse if co ==. & pm10 ==. & pm2_5 ==.

gen missing = (co==. & pm10==. & pm2_5==.)


*PUNTO 7:

count if missing == 1
drop if missing == 1

*PUNTO 8:

bysort hora: egen mean_co = mean (co)

bysort hora: egen sd_co= sd(co)

*PUNTO 9:

gen z_co=(co-mean_co)/sd_co


*PUNTO 10:

sort hora

*PUNTO 11:

drop mean_co sd_co missing

*PUNTO 12:

label var co "Monoxido de Carbono (ppm)"

label var pm10 "MP10 (Partıculas inhaladas)-microgramo por metro ćubico(μg/m3)"

label var pm2_5 "MP2.5 (Partıculas inhaladas finas)-microgramo por metro ćubico(μg/m3)"

label var pm10_w "MP10 winsorizada"

label var z_co "Monoxido de Carbono (en desviacion est ́andar)"


*PUNTO 13: 
	
gsort hora -z_co
	
bysort hora: egen rank_co=rank(z_co), field


*PUNTO 14:

gen día_mes = month + "/" + day

sort rank hora

gen y=día_mes if rank == 1

gen Z_CO = "."

replace Z_CO = día_mes if rank_co == 1

drop Z_CO

*PUNTO 15:

compress, nocoalesce 





