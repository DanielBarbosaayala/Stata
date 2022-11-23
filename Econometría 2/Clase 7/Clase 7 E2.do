* DO file : Clase 7

bcuse 401ksubs, clear

reg e401k nettfa // Esto es equivalente a estimar por MPL
predict pr_mco, xb
margins , dydx(_all)


logit e401k nettfa // Esto es equivalente a estimar por MPL
predict pr_log
margins , dydx(_all)
estat classification

probit e401k nettfa  // Esto es equivalente a estimar por MPL
predict pr_prob
margins , dydx(_all)
estat classification

*twoway (scatter admit gre)
twoway (scatter  e401k nettfa)(scatter pr_mco nettfa)  (scatter pr_log nettfa) (scatter pr_prob nettfa) 
