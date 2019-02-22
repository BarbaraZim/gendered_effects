********************************************************************************

*** Deskriptive Statistik für Artikel***

********************************************************************************

cd C:\Users\bzimmermann\switchdrive\gendered_paths\Daten\Analysen

use sequences_withPISA_clusters, clear

****Svyset***
svyset psu [pweight=wt9_kal], strata(strata) fpc(fpc) vce(linearized) singleunit(scaled)

********************************************************************************


***color scheme
set scheme s1mono

*set scheme plotplainblind

grstyle init
grstyle set plain, grid compact
grstyle set legend , nobox
grstyle clockdir legend_position 6


*grstyle set color hue, n(5)

***Übersicht****

estpost tabstat wleread wlemath wlescie natmat hparisei cl_dyn51-cl_dyn55 current_isei HighestInc [weight=wt9_kal] ///
, by(fem) statistics(n mean sd) columns(statistics) nototal 
esttab . using "..\Analysen\tables\table1.rtf", replace c("count(label(N)) mean(label(Mean)) sd(label(St.Dev.))")mlabel("")legend noobs label 

