cd "C:/Users/`c(username)'/switchdrive/gendered_paths/Daten/Analysen"
use sequences_withPISA_clusters_revisions.dta, clear

***color scheme
*set scheme s1mono
*set scheme s2color // stata default
creturn list

grstyle init
grstyle set plain, grid compact
grstyle set legend , nobox
grstyle clockdir legend_position 6
/*grstyle set color black%50, plots(1): p1
grstyle color p1markline black%50
grstyle color p1markfill black
grstyle set color sky%50, plots(2): p2
grstyle color p2markline sky%50
grstyle color p2markfill sky */


****Svyset***
svyset psu [pweight=wt9_kal], strata(strata) fpc(fpc) vce(linearized) singleunit(scaled)

*Add variable education of parents from T8
merge 1:1 id using H:\Dokumente_SOZ\Arbeitsmarkt\P2_Soziale_Herkunft\Daten\TREE\Episodendaten\2018-Aufbereitung\816_tree_data_c1_wave-8-2010_version_2016_de_v1.dta, ///
keepusing (id t8edcmoth t8edcfath) keep(matched)
drop _merge
mvdecode t8edcmoth t8edcfath, mv(14 97 98 99 = .)
fre t8edcmoth t8edcfath
fre fisced misced
capture drop meduc feduc
recode t8edcmoth t8edcfath ///
    (1/3  = 1 "less than VET") ///
    (4    = 2 "VET") ///
    (5/7  = 3 "Higher secondary") ///
    (8/12 = 4 "College of higher education ") ///
    (13   = 5 "University"), gen(meduc feduc) label(peduc)
label var meduc "mother's educational attainment"
label var feduc "father's educational attainment"
fre meduc feduc

bysort female: tab meduc cl_dyn5

*Bei der original Pisa-Variable gibt es weniger fehlende Werte aber sie ist schlecht...*

label var cl_dyn5 "clusters of educational trajectories"


gen misei_hm = misei
replace misei_hm = 0 if misco ==.a
label var misei_hm "mother's ISEI, homemakers included"
gen m_hm = misco==.a if misco<.b
label var m_hm "mother was homemaker"
label def hm 0 "not homemaker" 1 "homemaker"
label val m_hm hm
fre m_hm

keep id strata fpc psu wt9_kal t1 t2 t3 t4 t5 t6 t7 t8 t9 no_miss_wave ///
    age female ///
    wleread natmat ///
    cl_dyn5 current_isei not_current self lnHighestInc  ///
    fisei misei_hm m_hm meduc feduc hparisei
order id strata fpc psu wt9_kal t1 t2 t3 t4 t5 t6 t7 t8 t9 no_miss_wave ///
    age female ///
    wleread natmat ///
    cl_dyn5 current_isei not_current self lnHighestInc  ///
    fisei misei_hm m_hm meduc feduc hparisei

save sequences_withPISA_clusters_revisions.dta, replace

********************************************************************************
********************************************************************************

svy: reg current_isei i.female##i.feduc
margins feduc, over(female)
marginsplot
svy: reg wleread i.female##(i.fisced)
margins fisced, over(female)
marginsplot
svy: reg lnHighestInc i.female##(i.misced_r2 i.fisced_r2 i.m_hm c.misei_hm##c.misei_hm c.fisei##c.fisei)
margins misced_r2, over(female)
marginsplot

svy: reg natmat i.female##i.fisced_r2
svy: reg natmat i.female##i.misced_r2

svy: mlogit cl_dyn5 i.female##i.fisced_r

reg wleread i.female##(i.m_hm c.misei_hm c.fisei) i.not_current if !(cl_dyn5==3 & !female)
eststo linear
reg wleread i.female##(i.m_hm c.misei_hm##c.misei_hm c.fisei##c.fisei) i.not_current if !(cl_dyn5==3 & !female)
eststo quad
lrtest linear quad, stat

********************************************************************************
********************************************************************************
varma

use sequences_withPISA_clusters, clear
set scheme plotplainblind

*Neue Labels State*
label def stateNew  1 "NEET" ///
                    2 "Other educ., etc." ///
                    3 "Employment" ///
                    4 "VET" ///
                    5 "Secondary, spec." ///
                    6 "Secondary, general" ///
                    7 "College of higher educ." ///
                    8 "Univ. of applied sciences" ///
				            9 "Univ. of teacher education" ///
				            10 "University" ///
				            11 "Advanced studies"

label val state* stateNew

***neue Grafik Chronogramme*
chronogram state*, prop ///
    by(cl_dyn5, rows(2) legend(at(6) position(0)) ixaxes note("") graphregion(margin(small)) scale(1) /*title(Clusters of Educational Trajectories)*/) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9 10 11)) ///
    /*xsize(8) ysize(3.5)*/ name(dyn5, replace) aspectratio(0.75, placement(left)) xtitle("")

graph export "..\Analysen\revisions\Figure2.png", replace width(5700)
graph export "..\Analysen\revisions\Figure2.eps", replace
graph export "..\Analysen\revisions\Figure2.emf", replace


*gleiches mit Manualcluster*

use sequences_withPISA_analyses, clear

set scheme plotplainblind

*Neue Labels State*
label def stateNew  1 "NEET" ///
                    2 "Other educ., etc." ///
                    3 "Employment" ///
                    4 "VET" ///
                    5 "Secondary, spec." ///
                    6 "Secondary, general" ///
                    7 "College of higher educ." ///
                    8 "Univ. of applied sciences" ///
				            9 "Univ. of teacher education" ///
				            10 "University" ///
				            11 "Advanced studies"

label val state* stateNew

***neue Grafik Chronogramme*
chronogram state*, prop ///
    by(cl_dyn5, rows(2) legend(at(6) position(0)) ixaxes note("") graphregion(margin(small)) scale(1) /*title(Clusters of Educational Trajectories)*/) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9 10 11)) ///
    /*xsize(8) ysize(3.5)*/ name(dyn5, replace) aspectratio(0.75, placement(left)) xtitle("")

graph export "..\Analysen\revisions\Figure10.png", replace width(5700)
graph export "..\Analysen\revisions\Figure10.eps", replace
graph export "..\Analysen\revisions\Figure10.emf", replace
