********************************************************************************

						*MODELLFITS*
						
********************************************************************************						
cd H:\Dokumente_SOZ\Arbeitsmarkt\P2_Soziale_Herkunft\Daten\TREE\Episodendaten\2018-Analysen

*use sequences_withPISA, clear // die sind ohne Cluster -> hier auf no_mis_wave aufpassen

use sequences_withPISA_clusters, clear // mit  Clusters 


set scheme plotplainblind

** Reading, Math & Scienc skills by parental ISEI **
****************************************************
two (lowess wleread hparisei) (lfit wleread hparisei)  (qfit wleread hparisei) , by(female) 
graph export 201810_modelfit_read.pdf

two (lowess wlemath hparisei) (lfit wlemath hparisei)  (qfit wlemath hparisei) , by(female) 
graph export 201810_modelfit_math.pdf

two (lowess wlescie hparisei) (lfit wlescie hparisei)  (qfit wlescie hparisei) , by(female) 
graph export 201810_modelfit_science.pdf
********************************************************************************

** Current ISEI by parental ISEI **
***********************************

*conditional
two (lowess current_isei hparisei) (lfit current_isei hparisei)  (qfit current_isei hparisei) if cl_oma5==1, by(female) name(Voc, replace) title("Vocational")
two (lowess current_isei hparisei) (lfit current_isei hparisei)  (qfit current_isei hparisei) if cl_oma5==2, by(female) name(VocT, replace) title("Vocational Tertiary")
two (lowess current_isei hparisei) (lfit current_isei hparisei)  (qfit current_isei hparisei) if cl_oma5==4, by(female) name(Ac, replace)	 title("Academic")
two (lowess current_isei hparisei) (lfit current_isei hparisei)  (qfit current_isei hparisei) if cl_oma5==5, by(female) name(AcM, replace) title("Academic Mixed")

graph combine Voc VocT Ac AcM
graph export 201810_modelfit_ISEIcond.pdf, replace

*total
two (lowess current_isei hparisei) (lfit current_isei hparisei)  (qfit current_isei hparisei) , by(female) 
graph export 201810_modelfit_ISEItotal.pdf


*** Salary by parental ISEI ***
*******************************

// Untersuchung der Ausreisser (mit studentisierten Residuen) zeigt, dass die sehr hohen Löhne im mittleren ISEI-Bereich v.a. Führungskräfte, Leute
// in der Finanzbranche, IT und (wenige) Lehrer sind. Der überwiegende Teil hat eine Berufslehre und tertiäre Weiterbildung gemacht (v.a. FH)
// Bei den tiefen Löhnen im hohen ISEI-Bereich sind viele Wissenschaftler und auch überwiegend in den akademischen Clustern. 
// Nur Männer untersucht. Warum so grosse Unterschiede zw. Männern und Frauen unklar.
// Bei den Frauen sind hohe Löhne v.a. Führungspersonen, Wissenschaftlerinnen & Lehrkräfte

*Diagnosen*
hist lnHighestInc if fem==1 
hist lnHighestInc if fem==0 
hist lnHighestInc 

two (lowess lnHighestInc hparisei) (lfit lnHighestInc hparisei)  (qfit lnHighestInc hparisei) , by(female) name(std, replace)
graph export 201810_modelfit_salary.png, replace

*nur Männer*
two (lowess lnHighestInc hparisei) (lfit lnHighestInc hparisei)  (qfit lnHighestInc hparisei) if fem==0
graph export 201811_modelfit_salaryM.png, replace

*nicht log, Männer
two (lowess HighestInc hparisei) (lfit HighestInc hparisei)  (qfit HighestInc hparisei) if fem==0
graph export 201811_modelfit_salaryMfr.png, replace


*mit gestutzen Löhnen*
two (lowess lnHighestIncKorr hparisei) (lfit lnHighestIncKorr hparisei)  (qfit lnHighestIncKorr hparisei) if fem==0
two (lowess HighestIncKorr hparisei) (lfit HighestIncKorr hparisei)  (qfit HighestIncKorr hparisei) if fem==0

*conditional
two (lowess lnHighestInc hparisei) (lfit lnHighestInc hparisei)  (qfit lnHighestInc hparisei) if cl_oma5==1, by(female) name(Voc, replace) title("Vocational")
two (lowess lnHighestInc hparisei) (lfit lnHighestInc hparisei)  (qfit lnHighestInc hparisei) if cl_oma5==2, by(female) name(VocT, replace) title("Vocational Tertiary")
two (lowess lnHighestInc hparisei) (lfit lnHighestInc hparisei)  (qfit lnHighestInc hparisei) if cl_oma5==4, by(female) name(Ac, replace)	 title("Academic")
two (lowess lnHighestInc hparisei) (lfit lnHighestInc hparisei)  (qfit lnHighestInc hparisei) if cl_oma5==5, by(female) name(AcM, replace) title("Academic Mixed")

graph combine Voc VocT Ac AcM
graph export 201810_modelfit_SALARYcond.pdf, replace

*nicht nach Geschlecht getrennt
two (lowess HighestInc hparisei) (lfit HighestInc hparisei)  (qfit HighestInc hparisei)
graph export 201810modelfit_salaG.png
two (lowess HighestInc hparisei) (lfit HighestInc hparisei)  (qfit HighestInc hparisei) , by(cl_oma5)
graph export 201810modelfit_salaGcond.pdf

two (lowess HighestInc hparisei) (lfit HighestInc hparisei)  (qfit HighestInc hparisei) , by(fem)

