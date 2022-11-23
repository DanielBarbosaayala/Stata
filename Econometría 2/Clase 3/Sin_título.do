
cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\6 semestre\Econometría 2\Complementarias de stata\Clase 3"

use "variables instrumentales. multiple.dta"

reg ldrugexp hi_empunion

corr hi_empunion ssiratio, covariance

scalar cov_xz = r(cov_12)

corr ssiratio ldrugexp

scalar cov_yz=r(rho)

scalar list

scalar b1=cov_yz/cov_xz

scalar list b1

sum ldrugexp

scalar me_ldrugexp=r(mean)

summarize hi_empunion

scalar me_hi_empunion =r(mean)

scalar b0= me_ldrugexp-b1*me_hi_empunion

scalar list b0 b1

ivregress 2sls ldrugexp 

hausman mco iv // me compara los estimadores de las regresiones






