*** Ejercicio 6

*PUNTO 1

cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Clase 7\"


*PUNTO 2

use "data_homic_mun", replace


*PUNTO 3

keep tasa_homi H_coca indrural pib_percapita codmpio ano 

*PUNTO 4

keep if tasa_homi!=. & H_coca!=.& indrural!=. & pib_percapita!=.


*PUNTO 5


*PUNTO 6

reg tasa_homi H_coca indrural pib_percapita

*xtset codmpio ano

*reg tasa_homi H_coca indrural pib_percapita i.ano i.codmpio

*PUNTO 7

mata

*PUNTO 8

st_view(y=.,.,"tasa_homi")
st_view(x=.,.,("H_coca","indrural","pib_percapita","cons"))

*PUNTO 9

coef = invsym(x'x)*x'y

*PUNTO 1O

*residuo
e=y-x*coef

*nro de observaciones
n=rows(x)

* nro de parámetros
k=cols(x)


s2=S(e'e)/(n-k)

v= s2*invsym(x'x)

*PUNTO 11

se=sqrt(diagonal(v))

*PUNTO 12

t=coef:/se

*PUNTO 13

results=(coef, se, t)

*PUNTO 14

stata('"display "results contine los resultados de la estimación""')

*PUNTO 15

st_matrix("results",results)

*PUNTO 16

end

*visualizar matriz

matlist results

*PUNTO 17

*CAMBIAR NOMBRE DE COLUMNAS








