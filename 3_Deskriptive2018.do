********************************************************************************

*** Deskriptive Statistik für Artikel***

********************************************************************************

cd C:\Users\bzimmermann\switchdrive\gendered_paths\Daten\Analysen

use sequences_withPISA_clusters, clear

****Svyset***
svyset psu [pweight=wt9_kal], strata(strata) fpc(fpc) vce(linearized) singleunit(scaled)

********************************************************************************


***color scheme
*set scheme plotplainblind

grstyle init
grstyle set plain, grid compact
grstyle set legend , nobox
grstyle clockdir legend_position 6


*grstyle set color hue, n(5)

***Übersicht****

estpost tabstat wleread wlemath wlescie natmat hparisei cl_dyn51-cl_dyn55 current_isei HighestInc [weight=wt9_kal] ///
, by(fem) statistics(n mean sd) columns(statistics) nototal
esttab . using "..\Analysen\tables\table1.rtf", replace c("count(label(N)) mean(label(Mean)) sd(label(St.Dev.))")mlabel("") ///
legend noobs label unstack nonumb

**** Verteilung in Clusters ****
********************************

mean cl_dyn51 if fem==0 [aweight=wt9_kal]
eststo cl1m
mean cl_dyn51 if fem==1 [aweight=wt9_kal]
eststo cl1f
mean cl_dyn52 if fem==0 [aweight=wt9_kal]
eststo cl2m
mean cl_dyn52 if fem==1 [aweight=wt9_kal]
eststo cl2f
mean cl_dyn53 if fem==0 [aweight=wt9_kal]
eststo cl3m
mean cl_dyn53 if fem==1 [aweight=wt9_kal]
eststo cl3f
mean cl_dyn54 if fem==0 [aweight=wt9_kal]
eststo cl4m
mean cl_dyn54 if fem==1 [aweight=wt9_kal]
eststo cl4f
mean cl_dyn55 if fem==0 [aweight=wt9_kal]
eststo cl5m
mean cl_dyn55 if fem==1 [aweight=wt9_kal]
eststo cl5f

coefplot  (cl1m, label(Men)   pstyle(p1)recast(bar) barwidth(0.2) color(black)  fcolor(*.8) lcolor(*.6) ciopts(recast(rcap) lc(black)) citop offset(0.20)) /*
		*/(cl1f, label(Women) 		pstyle(p2)recast(bar) barwidth(0.2) color(sky)    fcolor(*.5) lcolor(*.4) ciopts(recast(rcap) lc(sky)) citop offset(-.20)) /*
		*/(cl2m,  			  				pstyle(p1)recast(bar) barwidth(0.2) color(black)  fcolor(*.8) lcolor(*.6) ciopts(recast(rcap) lc(black)) citop offset(0.20)) /*
		*/(cl2f, 			  					pstyle(p2)recast(bar) barwidth(0.2) color(sky)    fcolor(*.5) lcolor(*.4) ciopts(recast(rcap) lc(sky)) citop offset(-.20)) /*
		*/(cl3m,  			 					pstyle(p1)recast(bar) barwidth(0.2) color(black)  fcolor(*.8) lcolor(*.6) ciopts(recast(rcap) lc(black)) citop offset(0.20)) /*
		*/(cl3f, 			  					pstyle(p2)recast(bar) barwidth(0.2) color(sky)    fcolor(*.5) lcolor(*.4) ciopts(recast(rcap) lc(sky)) citop offset(-.20)) /*
		*/(cl4m,  			  				pstyle(p1)recast(bar) barwidth(0.2) color(black)  fcolor(*.8) lcolor(*.6) ciopts(recast(rcap) lc(black)) citop offset(0.20)) /*
		*/(cl4f, 			  					pstyle(p2)recast(bar) barwidth(0.2) color(sky)    fcolor(*.5) lcolor(*.4) ciopts(recast(rcap) lc(sky)) citop offset(-.20)) /*
		*/(cl5m,  			  				pstyle(p1)recast(bar) barwidth(0.2) color(black)  fcolor(*.8) lcolor(*.6) ciopts(recast(rcap) lc(black)) citop offset(0.20)) /*
		*/(cl5f, 			  					pstyle(p2)recast(bar) barwidth(0.2) color(sky)    fcolor(*.5) lcolor(*.4) ciopts(recast(rcap) lc(sky)) citop offset(-.20)) /*
		*/(cl1m, 			   					pstyle(p1) mlabcolor(black) msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.40)) /*
		*/(cl1f, 			   					pstyle(p2) mlabcolor(sky)   msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.00)) /*
		*/(cl2m, 			   					pstyle(p1) mlabcolor(black) msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.40)) /*
		*/(cl2f, 			   					pstyle(p2) mlabcolor(sky)   msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.00)) /*
		*/(cl3m, 			   					pstyle(p1) mlabcolor(black) msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.40)) /*
		*/(cl3f, 			   					pstyle(p2) mlabcolor(sky)   msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.00)) /*
		*/(cl4m, 			   					pstyle(p1) mlabcolor(black) msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.40)) /*
		*/(cl4f, 			   					pstyle(p2) mlabcolor(sky)   msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.00)) /*
		*/(cl5m, 			   					pstyle(p1) mlabcolor(black) msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.40)) /*
		*/(cl5f, 			   					pstyle(p2) mlabcolor(sky)   msymbol(i) noci mlabel(string(@b,"%9.1f")) mlabposition(3) mlabgap(*2) offset(0.00)) /*
		*/, xlabel(0(10)50) rescale(100) legend(order(1 "Men" 3 "Women"))

graph export "..\Analysen\graphs\Figure3.png", replace
