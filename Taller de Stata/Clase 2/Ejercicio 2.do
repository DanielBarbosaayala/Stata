* Ejercicio 2
* Carlos A. Ayala
* Fecha: Hoy


* PUNTO 1: Definir entorno de trabajo

cd "C:\Users\Carlos A. Ayala\Desktop\universidad\Cuarto Semestre\Taller de Stata\Clase 2\"


* PUNTO 2: Importar base de datos

import delimited "1567349900409.csv", delimiter (";") clear 

br


* PUNTO 3: Eliminar las 3 primeras filas

drop if _n <=3

* PUNTO 4: Generar 2 nuevas variables

gen cod_estación = v2[1]

gen estación = v2[2]

* PUNTO 5: Renombrar las variables

rename (v*) (fecha hora co pm10 pm2_5)

* PUNTO 6: Eliminar las primeras 4 filas

drop if _n <=4

* PUNTO 7: Reemplazar 00:00 por 24:00

replace hora = "00:00" if  hora == "24:00"

* PUNTO 8: concatenar hora y fecha

replace fecha = hora + ["/"] + fecha

* PUNTO 9: 

tab hora if co == ""

* PUNTO 10: Borrar variable hora

drop hora

* PUNTO 11: Convertir de numero a texto 

destring co pm10 pm2_5, replace

destring co , replace dpcomma

* PUNTO 12: Cambiar formato

format co %02.1f 

* PUNTO 13: Ordenar 

order cod_estación estación fecha

* PUNTO 14: tabla de estadisticas descriptivas en detalle

sum pm10, detail 


* PUNTO 15: Nueva variable pm10

gen pm_10 = pm10

replace pm_10 = r(p1) if pm_10 < r(p1)

replace pm_10 = r(p95) if r(p95) < pm_10 & pm_10 < r(p100)

drop pm_10

* PUNTO 16: Tabla de estadisticas descriptivas básicas 

tabstat pm10 pm_10, stat( count mi mean ma sd )

* En cuanto a la cantidad de variables, estas se han mantenido constantes, pero se presentan cambios en los valores minimos y máximo, como resultado del punto 15. De igual forma, la desviación estadar cambió, muy seguramente por el cambio en el minimo y el máximo.











