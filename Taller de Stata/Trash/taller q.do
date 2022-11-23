

* TALLER DE STATA- TALLER 1- CARLOS ALFREDO AYALA BETANCOURT


* PUNTO 0

cd "C:\Users\Carlos A. Ayala\OneDrive - Universidad de los Andes\universidad\Cuarto Semestre\Taller de Stata\Trash\"


* PUNTO 1

use "PANEL_CARACTERISTICAS_GENERALES(2019)", clear

* PUNTO 2

keep codmpio ano indrural gandina gcaribe gpacifica gorinoquia gamazonia pobl_tot

keep if ano >=2004 & ano<=2016

* PUNTO 3

gen ano1=ano

bys codmpio: egen ano2=min(ano1) if indrural!=.

bys codmpio: gen indrual_min=indrural if ano==ano2

bys codmpio: egen indrural_def=min(indrual_min)

* PUNTO 4

keep if ano==2004

gen cuartil=1 if indrural_def<=r(p25)

replace cuartil=2 if r(p25)<indrural_def & indrural_def<=r(p50)

replace cuartil=3 if r(p50)<indrural_def & indrural_def<=r(p75)

replace cuartil=4 if r(p75)<indrural_def & indrural_def<=r(p100)


* PUNTO 5

label var cuartil "Q_indrural"

* PUNTO 6

gen region = "Region andina"

replace region = "Region caribe" if gcaribe==1

replace region = "Region pacifica" if gpacifica==1

replace region = "Region orinoquia" if gorinoquia==1

replace region = "Region amazonia" if gamazonia==1

* PUNTO 7

keep codmpio region cuartil pobl_tot

* PUNTO 8

compress

save "Caracteristicas generales 1.0", replace

* PUNTO 9

use "PANEL_CONFLICTO_Y_VIOLENCIA(2019)", clear


* PUNTO 10

keep codmpio ano homicidios H_coca

* PUNTO 11

gen M_coca="municipio con coca"

replace M_coca= "municipio sin coca" if H_coca==.


* PUNTO 12

keep codmpio ano homicidios M_coca

keep if ano>=2005 & ano<=2018

* PUNTO 13

merge m:1 codmpio using "Caracteristicas generales 1.0"

* PUNTO 14

gen Homicidos_100milH=homicidios

replace Homicidos_100milH=homicidios/100000

* PUNTO 15

*a

preserve

bys codmpio: egen Prom_Homicd_munipos=mean(homicidios)

bys region: egen Prom_Hpmicid_Region=mean(Prom_Homicd_munipos)

egen Mayor_prom=max(Prom_Hpmicid_Region)

egen Min_prom=min(Prom_Hpmicid_Region)

export excel "Max_Min_promedio_por_region.xlsx", firstrow(variables) sheet("max_min", replace)

restore

*b

preserve

bys codmpio: egen Prom_Homicd_munipos=mean(homicidios)

bys M_coca: egen Prom_homicidios=mean(Prom_Homicd_munipos)

egen Max_homicidios=max(Prom_homicidios)

export excel "Tasa_homicidio_mnpio_coca.xlsx", firstrow(variables) sheet("con coca_sin coca", replace)

restore

*c

preserve

bys cuartil: egen Prom_Homicd=mean(homicidios)

egen max_cuartil=max(Prom_Homicd)

egen min_cuartil=min(Prom_Homicd)

export excel "Max_Min_promedio_por_cuartil.xlsx", firstrow(variables) sheet("max_min_cuartil", replace)

restore



drop Prom_Homicd





