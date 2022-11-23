/* CLASE 5 */

use "variables instrumentales. multiple.dta", replace
**Se desea conocer cuál es el impacto de estar afiliado o no en un sindicato en el gasto en medicamentos
*ldrugexp=f(hi_empunion)
**La decisión de estar afiliado en un sindicato puede estar correlacionado con el nivel de ingresos de las personas o si el individuo tiene un sistema defensivo muy pobre
**Si se realizara un análisis de varianca-covarianza con el error se puede obtener que sea distinto a cero. 
**Para tratar de solucionar este problema se desea incluir una variable instrumental, en este caso va a ser ssiratio que corresponde a la fracción de ingreso total que viene dado por transferencias públicas.
*Estimación paso a paso
*Para sacar la covarianza, se le hace click en statistics, summary and descriptive statistics, correlations and covariances. Ubican las variables y en opción se le incluye display covariance 
correlate hi_empunion ssiratio, covariance
scalar cov_xz=r(cov_12)
correlate ldrugexp ssiratio, covariance
scalar cov_zy=r(cov_12)
*Para obtener el β_1iv=Cov(z,y)/(Cov(z,x)) 
scalar b1=cov_zy/cov_xz
*Para obtener β_0=y ̅-β_1iv x ̅ 
*Primero el y ̅
summarize ldrugexp
scalar me_ldrugexp=r(mean)
*Segundo la media de  x ̅
summarize hi_empunion
scalar me_hi_empunion =r(mean)
*Obteniendo β_0
scalar b0=me_ldrugexp-b1*me_hi_empunion
scalar list b0 b1
*Vamos a demostrar que son los mismos valores
ivregress 2sls  ldrugexp ( hi_empunion= ssiratio)
**REGRESIÓN MÚLTIPLE**
*ldrugexp=f(hi_empunion,totchr,age,female,blhisp)
*Vamos a considerar primero que el modelo está exactamente identificado
*β ̂_IV=(Z´X)^(-1) (Z´Y)
**Le vamos a ampliar la memoria a STATA
set matsize 5000
**Generar columna de unos
gen uno=1
*Pasar en observaciones a vectores
mkmat ssiratio age female lowincome firmsz multlc totchr hi_empunion ldrugexp blhisp uno
*Vamos a generar la matriz y
matrix y= ldrugexp
*Vamos a generar la matriz x
matrix x= uno, hi_empunion, totchr, age, female, blhisp
*Vamos a generar la matriz z (recuerden que primer van las variables instrumentales y luego las variables exógenas)
matrix z=uno, ssiratio, totchr, age, female, blhisp
*encontrando los estimadores
matrix biv=(inv(z'*x))*(z'*y)
*para ver loes estimador
matrix list biv
**hacer la regresión comando ridecto de stata
ivregress 2sls  ldrugexp ( hi_empunion= ssiratio) totchr age female blhisp
**Modelo identificado**
*β ̂_iv=(X´P_z X)^(-1) X´P_z Y
*P_z=Z(Z´Z)^(-1) Z´
*β ̂_iv=(X ̂´X ̂ )^(-1) X ̂´Y
*Demostración en el tablero con tamaños
*2 etapas
matrix drop z
matrix z= uno, ssiratio, lowincome, totchr, age, female, blhisp
matrix x_estrella= hi_empunion
matrix pi=(inv(z'*z))*(z'*x_estrella)
matrix list pi
matrix x_est=z*pi
matrix x_2=uno,x_est, totchr, age, female, blhisp
matrix bmc2e=(inv(x_2'*x_2))*(x_2'*y)
matrix list bmc2e
*con pz sobreidentificado
matrix pz=z*inv(z'*z)*z'
matrix bpz=inv(x'*pz*x)*x'*pz*y
matrix list bpz
*Mirar por separado las dos etapas
ivregress 2sls  ldrugexp ( hi_empunion= lowincome ssiratio) age female totchr blhisp, first


/* SARGAN */

ivreg ldrugexp (hi_empunion= ssiratio lowincome) totch age female blhisp
predict res, residuals
reg res ssiratio lowincome totch age female blhisp
scalar ml=e(N)*e(r2)
scalar prob=chi2tail(1,ml)
scalar list prob
*el p-value es de 0.117 por lo que no se rechaza la hipótesis nula con lo que los instrumentos son los adecuados y son válidos
**Para instalar el comando directo de Stata 
ssc install overid, replace
 **Se vuelve a correr el modelo 
ivreg ldrugexp (hi_empunion= ssiratio lowincome) totch age female blhisp
*si no es con 
overid
