/* Clase 15 - Heteroscedasticidad */

	bcuse wage2 , clear

/* 1. CASO BÁSICO Y=F(X) */ 

	reg wage IQ
	imtest , white
	predict res, residual
	gen res2=res^2 
	scatter res2 IQ  
		* La dispersión del res2 es mayor en valores más altos del IQ
	* Breusch-Pagan: 
		reg res2 IQ
		scalar BP=e(F)
	* White: 
		reg res2 c.IQ##c.IQ
		scalar chi2_W=e(N)*e(r2)
		
	* Breusch-Pagan-Godfrey: 
	sum res2
	local s2=r(mean)
	gen rho=res2/`s2'
		reg rho IQ
		scalar chi2_BPG=0.5*e(mss)
		*scalar pvalue = chi2tail(e(df_m),chi2_BPG)
	scalar chi_tablas = invchi2tail(e(df_m),0.05)
	reg wage IQ
	hettest , iid 
	imtest, white 
	scalar list 
	
/* 2. CASO CON GRUPOS Y=F(X,D) */

	reg wage IQ black
	hettest, iid 
	imtest, white 
	drop res*
	predict res , res
	gen res2=res^2
	sdtest res2, by(black)
	scatter res2 black
	
/* 3. SOLUCIONES */

	/* 3.1. Mínimos Cuadrados Ponderados */
	/* 3.1.1. Sabemos la fórmula funcional */
		/* supongamos que S2*=S2*IQ donde S2* es el estimador de varianza con
		heteroscedasticidad y S2 es el estimador correcto. Entonces habría que 
		dividir todo el modelo por la raiz del problema -> √(F(IQ)) = √IQ. 
		Hacemos esta ponderación incluso con el uno que acompaña a la constante: 
		*/
		gen y=wage/sqrt(IQ)
		gen cons=1/sqrt(IQ)
		gen x1= IQ/sqrt(IQ)
		gen x2= black/sqrt(IQ)
		reg y x1 x2 cons, nocons
			imtest , white
			hettest, iid
		* El comando directo de BP no está soportado para regresiones sin cons. 
		reg wage IQ black [aw= 1/IQ]
			hettest, iid
			imtest , white
		* El comando directo de White no está soportado para regresiones con pesos.	
		* Tiene más sentido revisar con el aw, puesto que este modelo no distorsiona tanto la ANOVA como, el F y el R2.
		* Revisar: https://www.stata.com/support/faqs/statistics/analytical-weights-with-linear-regression/
	
	/* 3.1.2. Sabemos que hay heteroscedasticidad por grupos */
		/* Según la variable Black, hay diferencias en la varianza del error 
		estimado. Por ende, para cada grupo ponderaremos cada variable, incluida
		la constante por la raiz de la varianza, según la variable black.
		*/
		sum res2 if black==0
		scalar sd_0=r(sd)
		sum res2 if black==1
		scalar sd_1=r(sd)
		
		drop y x1 x2 cons
		local comando gen 
		forval x=0(1)1{
			`comando' y=wage/sqrt(sd_`x') if black==`x'
			`comando' cons=1/sqrt(sd_`x') if black==`x'
			`comando' x1= IQ/sqrt(sd_`x') if black==`x'
			`comando' x2= black/sqrt(sd_`x') if black==`x'
			local comando replace
		}
		
		reg y x1 x2 cons, nocons
		/* si sabemos con certeza que la variable Black es la única que genera 
		heteroscedasticidad, al ponderar de esta forma, estamos normalizando la 
		varianza a 1, lo cual es constante y arregla el problema. 
		*/
		predict u, res
		gen u2=u^2
		sdtest u2, by(black) 
		*fijarse en los valores de sd. 
		
	
	/* 3.2. Recalcular los Errores estándar */	
		/* 3.2.1. Robustos */
			/* Usamos estos cuando no podemos identificar bien cual es la forma
			funcional de la varianza */
		reg wage IQ black
		reg wage IQ black , robust
		
		/* 3.2.1. Cluster */
			/* Usamos estos si tenemos clara una característica que podría 
			generar un efecto de tipo aglomeración que haga que la varianza del 
			modelo dependa de dichas agrupaciones */
		reg wage IQ black
		reg wage IQ black, cl(south)
		predict w, res
		gen w2=w^2
		sdtest w2, by(south)
		
	/* 3.3. Revisar la forma funcional */	
		reg wage IQ black
		hettest 
		reg lwage IQ black
		hettest 
		gen lnIQ=ln(IQ)
		reg wage lnIQ black
		hettest 
		reg lwage lnIQ black
		hettest 
		
		
