* DO file : Clase 7

bcuse 401ksubs, clear

reg e401k nettfa // Esto es equivalente a estimar por MPL
predict pr_mco, xb
margins , dydx(_all)


logit e401k nettfa //
predict pr_log
margins , dydx(_all) atmeans
estat classification

probit e401k nettfa  // Esto es equivalente a estimar por MPL
predict pr_prob
margins , dydx(_all) atmeans
estat classification

*twoway (scatter admit gre)
twoway (scatter  e401k nettfa)(scatter pr_mco nettfa)  (scatter pr_log nettfa) (scatter pr_prob nettfa) ,xline(19)

/* CONTINUACiÓN CLASE 8 */

reg e401k nettfa
margins, dydx(_all) at(nettfa =20) 
tab e401k 
tab pr_mco
gen mpl_prediccion=pr_mco >=0.5
tab mpl_prediccion 
tab mpl_prediccion e401k 
scalar  porc_corr_mpl=(5523+206)/9275
scalar list
reg e401k nettfa 
reg e401k nettfa inc marr male age fsize nettfa
predict pr_mco_2
gen mpl_prediccion_2=pr_mco_2 >=0.5
tab mpl_prediccion_2 e401k 
tab mpl_prediccion e401k 
tab mpl_prediccion e401k , cell
tab mpl_prediccion_2 e401k , cell 

margins , dydx(_all) 
sum nettfa 
display r(sd)*0.1778
logit e401k nettfa
margins , dydx(_all) 
margins , dydx(_all) atmeans
margins , dydx(_all) at(nettfa =100)
margins , dydx(_all) at(nettfa =0)
margins , dydx(_all) at(nettfa =-30)
margins , dydx(_all) at(nettfa =-500)
margins , dydx(_all) at(nettfa =2000)

*predict pr_log
twoway (scatter e401k nettfa ) (scatter pr_log  nettfa )
estat classification
scalar list 
logit e401k ne
ereturn list 
return list 
ereturn list 
scalar ll=e(ll)
scalar ll_0=e(ll_0)
scalar seudoR=(1-ll/ll_0)
scalar list 
scalar ERV=2*(ll-ll_0)
scalar list 
probit e401k ne
*predict pr_prob
estat classification
margins , dydx(_all) 
ereturn list


probit e401k nettfa inc marr male age fsize nettfa
predict probit 
twoway (scatter e401k nettfa ) (scatter probit  nettfa )
