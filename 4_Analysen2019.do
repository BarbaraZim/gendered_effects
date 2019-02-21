cd C:\Users\bzimmermann\switchdrive\gendered_paths\Daten\Analysen

use sequences_withPISA_analyses, clear

***color scheme
set scheme s1mono
*set scheme plotplainblind

grstyle init
grstyle set plain, grid compact
grstyle set legend , nobox
grstyle clockdir legend_position 6

****Svyset***
svyset psu [pweight=wt9_kal], strata(strata) fpc(fpc) vce(linearized) singleunit(scaled)

// -------------------------------------------------------------------------------------------------
// Step 1: Highest ISEI on reading skills
// -------------------------------------------------------------------------------------------------

*Das quadratische Modell hat eine minimal bessere Modellanpassung bei read & natmat
center hparisei

svy: reg wleread i.female##c.c_hparisei##c.c_hparisei
eststo read
two (scatter wleread hparisei , mc(*0.3) ms(o) msize(tiny))                                                                                       ///
    (qfitci wleread hparisei if  female,   lc(gs12) lw(*2) clstyle(p1) acol(sky%50)   alcol(%0) range(10 90) clc(sky))                                                         ///
    (qfitci wleread hparisei if !female,   lc(gs12) lw(*2) clstyle(p1) acol(black%50) alcol(%0) range(10 90)),                                                                 ///
        xtitle("Parent's Highest Social Status (ISEI)") xlabel(10(20)90)                                                                        ///
        ytitle("PISA Estimates of Reading Skills")      ylabel(200 500 800) legend(order(3 "female" 5 "male") subtitle(Quadratic Fit:, size(*0.8))) ///
        yscale(titlegap(*10)) ///
         title("Reading Skills at the End of Compulsory School")                                                              ///
        xsize(9.45) ysize(7) scale(1.15) name(read, replace)

*natmat
svy: reg natmat i.female##c.c_hparisei##c.c_hparisei
eststo natmat
two (scatter natmat hparisei , mc(*0.3) ms(o) msize(tiny))                                                                                       ///
    (qfitci natmat hparisei if  female,   lc(gs12) lw(*2) clstyle(p1) acol(sky%50)   alcol(%0) range(10 90) clc(sky))                                                         ///
    (qfitci natmat hparisei if !female,   lc(gs12) lw(*2) clstyle(p1) acol(black%50) alcol(%0) range(10 90)),                                                                 ///
        xtitle("Parent's Highest Social Status (ISEI)") xlabel(10(20)90)                                                                        ///
        ytitle("PISA Estimates of Math & Science Skills")      ylabel(200 500 800) legend(order(3 "female" 5 "male") subtitle(Quadratic Fit:, size(*0.8))) ///
        yscale(titlegap(*10)) ///
         title("Math & Science Skills at the End of Compulsory School")                                                              ///
        xsize(9.45) ysize(7) scale(1.15) name(natmat, replace)

graph combine read natmat, xsize(10)
graph export "..\Analysen\graphs\Figure1.png", replace

esttab read natmat using "..\Analysen\tables\table2.rtf", replace se label compress nogaps interaction(*) nobaselevels wide


// -------------------------------------------------------------------------------------------------
// Step 2: Highest ISEI on probability of belonging to cluster X
// -------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// 5 Cluster sind gute Anzahl, bei 6 wird nur das akademische nochmals aufgetrennt in solche, die
// kürzer oder länger studieren...
// OMA oder DYN? Bei 5 gruppiert DYN die höhere Fachschule besser.
// -------------------------------------------------------------------------------------------------

chronogram state*, prop ///
    by(cl_dyn5, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(24)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9 10 11)) ///
    xsize(20) ysize(3.5) name(dyn5, replace) aspectratio(0.75, placement(left))

graph export "..\Analysen\graphs\Figure2.png", replace

*neu linear: Feb. 19*
svy: mlogit cl_dyn5 i.female##c.hparisei##c.hparisei c.wleread##c.natmat // warum interaktion zw. read & math?
eststo probmod
set matsize 10000
qui margins female, at(hparisei = (10(1)90))
marginsplot, by(_outcome) byopts(rows(1) legend(position(4)) graphregion(margin(small)) plotregion(margin(l=2)) ///
                                    title("Educational Trajectories:  Predicted Probabilities, Net of Reading & Maths/Sciences Skills")) subtitle("")  ///
        recastci(rline) ciopts(lc(gs12) lw(*0.7)) recast(line) plot2(clc(sky)) ///
        xtitle("Parent's Highest Social Status (ISEI)") ytitle(Predicted Probability) ///
        xlabel(10 50 90) ///
        xsize(20) ysize(3.5) aspectratio(0.76, placement(left)) ///
        name(marginscluster, replace)
forval i = 1/5 {
    local label : label clusters `i'
    addplot marginscluster `i':, subtitle(`label') norescaling
}
addplot marginscluster:, legend(order(4 "female" 3 "male")) norescaling

graph export "..\Analysen\graphs\Figure4.png", replace

*Tabelle*
est restore probmod
forvalue i = 1/`e(k_out)' {
	margins, dydx(*)  predict(pr outcome(`i')) post
	eststo prob`i', title(`: label (cl_oma4plus) `i'')
	est restore probmod
}

esttab prob? using "..\Analysen\tables\table3.rtf", mtitle nonumb replace se label compress nogaps nobaselevels wide

// -------------------------------------------------------------------------------------------------
// Step 3: Origin on Destination; Total, Direct, Conditional Effect
// -------------------------------------------------------------------------------------------------

*Modellfits bei q minim besser.

svy: reg current_isei i.female##c.hparisei##c.hparisei i.not_current if !(cl_dyn5==3 & !female)
eststo totalT
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg current_isei i.female##c.hparisei##c.hparisei i.cl_dyn5##i.not_current if !(cl_dyn5==3 & !female)
eststo directT
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo direct


svy: reg current_isei i.cl_dyn5##(i.female##c.hparisei##c.hparisei i.not_current) if !(cl_dyn5==3 & !female)

   coefplot (total,       keep(*1.female)            at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
            (total,       keep(*0.female)            at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
            , bylabel(Total Effect) ///
         || (direct,      keep(*1.female)            at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
            (direct,      keep(*0.female)            at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
            , bylabel(Direct Effect, Net of Clusters) ///
         || , byopts(rows(1) holes(8 9 10) legend(position(4)) title("Effects on Social Status (ISEI) in 2014 (Age ~30)") ///
                        graphregion(margin(small)) plotregion(margin(l=4)) iscale(*1.35) ixax) ///
              xtitle("Parent's Highest Social Status (ISEI)") ytitle("Own Social Status (ISEI)") ///
              xlabel(10 50 90) ///
              xsize(15) ysize(6) aspectratio(0.6072, placement(left)) name(Effects, replace)

		graph export "..\Analysen\graphs\Figure5.png", replace


********Tabelle

esttab totalT directT using "..\Analysen\tables\table4.rtf", replace se label compress nogaps interaction(*) nobaselevels wide

***********************
*Effekte Clusters*
**********************

svy: reg curr i.cl_dyn5 not_c if fem==0
margins cl_dyn5, post coefl
eststo Men

svy: reg curr i.cl_dyn5 not_c if fem==1
margins cl_dyn5, post coefl
eststo Women

coefplot Men Women, xline(0) drop(Men:3.cl_dyn5) title(Status) name(status, replace)
graph export "..\Analysen\graphs\Figure7.png", replace



//------------------------------------------------------------------------------
// Step 4: Effects on salary at age 30
//------------------------------------------------------------------------------

*Höchster Lohn aus T9, vorerst kein Ausschluss von extremen Werten
*Ob selbständig oder nicht, macht keinen Unterschied, kann ggfs. als Robustness Check integriert werden
*Einen Unterschied machen würden hingegen in Privathaushalt oder Familienbetrieb angestellt (stark neg.)
*Das wäre aber m.E. schon wieder Overcontrol, da von elterl. Status & Bildung ggfs. beeinflusst.

*Bei den Männern verschwindet der Effekt des elterlichen Status unter Kontrolle der Trajectories.

svy: reg lnHighestInc i.female##c.hparisei self if !(cl_dyn5==3 & !female)
eststo totalT
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 if !(cl_dyn5==3 & !female)
eststo directT
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo direct

 coefplot   (total,       keep(*1.female) at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
            (total,       keep(*0.female) at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
            , bylabel(Total Effect) ///
         || (direct,      keep(*1.female) at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
            (direct,      keep(*0.female) at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
            , bylabel(Direct Effect, Net of Clusters) ///
         || , byopts(rows(1) holes(8 9 10) legend(position(4)) title("Effects on salary in 2014 (Age ~30)") ///
                        graphregion(margin(small)) plotregion(margin(l=4)) iscale(*1.35) ixax) ///
              xtitle("Parent's Highest Social Status (ISEI)") ytitle("Salary") ///
              xlabel(10 50 90) ///
              xsize(15) ysize(6) aspectratio(0.6072, placement(left)) name(Effects, replace)

graph export "..\Analysen\graphs\Figure6.png", replace

*******Tabelle
esttab totalT directT using "..\Analysen\tables\table5.rtf", replace se label compress nogaps interaction(*) nobaselevels wide
beep

***********************
*Effekte Clusters*
**********************

svy: reg lnHighestInc i.cl_dyn5 self if fem==0
margins cl_dyn5, post coefl
eststo Men

svy: reg lnHighestInc i.cl_dyn5 self if fem==1
margins cl_dyn5, post coefl
eststo Women

coefplot Men Women, xline(0) drop(Men:3.cl_dyn5) title(Salary) name(salary, replace)
graph export "..\Analysen\graphs\Figure8.png", replace

**********************
*Mit Ende Ausbildung*
**********************
svy: reg lnHighestInc i.female##c.hparisei self c.lastmonth_educ##c.lastmonth_educ if !(cl_dyn5==3 & !female)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 c.lastmonth_educ##c.lastmonth_educ if !(cl_dyn5==3 & !female)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo direct

coefplot   (total,       keep(*1.female) at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
           (total,       keep(*0.female) at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
           , bylabel(Total Effect) ///
        || (direct,      keep(*1.female) at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
           (direct,      keep(*0.female) at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
           , bylabel(Direct Effect, Net of Clusters) ///
        || , byopts(rows(1) holes(8 9 10) legend(position(4)) title("Effects on salary in 2014 (Age ~30)") ///
                       graphregion(margin(small)) plotregion(margin(l=4)) iscale(*1.35) ixax) ///
             xtitle("Parent's Highest Social Status (ISEI)") ytitle("Salary") ///
             xlabel(10 50 90) ///
             xsize(15) ysize(6) aspectratio(0.6072, placement(left)) name(Effects, replace)

   graph export 201812_effectsSALARY_total-dirDynSVYeduc.png, replace

*Nur wer mind. vor 2 Jahren abgeschl. hat*
svy: reg lnHighestInc i.female##c.hparisei self if !(cl_dyn5==3 & !female) & month_since_endeduc>23
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 if !(cl_dyn5==3 & !female) & month_since_endeduc>23
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo direct

coefplot   (total,       keep(*1.female) at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
           (total,       keep(*0.female) at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
           , bylabel(Total Effect) ///
        || (direct,      keep(*1.female) at(at[.,3]) recast(line) clstyle(p1) clc(sky) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(female)) ///
           (direct,      keep(*0.female) at(at[.,3]) recast(line) clstyle(p1) clc(gs0) ciopts(recast(rline) lc(gs12) lw(*0.5)) label(male) )  ///
           , bylabel(Direct Effect, Net of Clusters) ///
        || , byopts(rows(1) holes(8 9 10) legend(position(4)) title("Effects on salary in 2014 (Age ~30)") ///
                       graphregion(margin(small)) plotregion(margin(l=4)) iscale(*1.35) ixax) ///
             xtitle("Parent's Highest Social Status (ISEI)") ytitle("Salary") ///
             xlabel(10 50 90) ///
             xsize(15) ysize(6) aspectratio(0.6072, placement(left)) name(Effects, replace)

       graph export 201812_effectsSALARY_total-dirDynSVYeducS.png, replace

********************************************************************************
********************************************************************************

*Zusätzliche Analysen mit Terzilen von Parental ISEI und Klassen

*BISHER NICHT VERWENDET!!!!!

*Net of reading/science skills
foreach var of varlist cl_dyn51-cl_dyn55 {
      svy: logit `var' i.parentegprec c.wleread##c.natmat if fem==0
	  margins parentegprec, post coefl
      estimates store m_`var'
      svy: logit `var' i.parentegprec c.wleread##c.natmat if fem==1
	  margins parentegprec, post coefl
      estimates store f_`var'
   }

coefplot (m_cl_dyn51, label(Men)) (f_cl_dyn51, label(Women)), bylabel("Vocational") || ///
         (m_cl_dyn52, label(Men)) (f_cl_dyn52, label(Women)), bylabel("Voc. & Tertiary") || ///
		 (m_cl_dyn53, label(Men)) (f_cl_dyn53, label(Women)), bylabel("Specialized Sec. & Tertiary") || ///
		 (m_cl_dyn54, label(Men)) (f_cl_dyn54, label(Women)), bylabel("Academic Mixed") || ///
		 (m_cl_dyn55, label(Men)) (f_cl_dyn55, label(Women)), bylabel("Academic") || ///
		 , byopts(xrescale legend(position(4)))

graph export probabilityclassNet.png, replace

svy: mlogit cl_dyn5 i.parentegprec c.wleread##c.natmat if fem==0
margins parentegprec, post
eststo male

svy: mlogit cl_dyn5 i.parentegprec c.wleread##c.natmat if fem==1
margins parentegprec, post
eststo female

coefplot male female, keep(*:) drop(_cons) xline(0) name(coefdyn5, replace)  ///
title(Probability of belonging to Cluster by parental status) swap


*Tertiles of parental ISEI

 pctile hpterz = hparisei, nq(3)

 gen hpt =.
 replace hpt = 1 if hparisei<.
 replace hpt = 2 if hparisei<57
 replace hpt = 3 if hparisei<46

 label def hpt 1 "Upper Tertile" 2 "Middle Tertile" 3 "Lower Tertile"
 lab val hpt hpt

foreach var of varlist cl_dyn51-cl_dyn55 {
      svy: logit `var' i.hpt c.wleread##c.natmat if fem==0
	  margins hpt, post coefl
      estimates store m_`var'
      svy: logit `var' i.hpt c.wleread##c.natmat if fem==1
	  margins hpt, post coefl
      estimates store f_`var'
   }

coefplot (m_cl_dyn51, label(Men)) (f_cl_dyn51, label(Women)), bylabel("Vocational") || ///
         (m_cl_dyn52, label(Men)) (f_cl_dyn52, label(Women)), bylabel("Voc. & Tertiary") || ///
		 (m_cl_dyn53, label(Men)) (f_cl_dyn53, label(Women)), bylabel("Specialized Sec. & Tertiary") || ///
		 (m_cl_dyn54, label(Men)) (f_cl_dyn54, label(Women)), bylabel("Academic Mixed") || ///
		 (m_cl_dyn55, label(Men)) (f_cl_dyn55, label(Women)), bylabel("Academic") || ///
		 , byopts(xrescale legend(position(4)))

graph export probabilityStatusTertileNet.png, replace

/////////////////////////////////////////////////////

svy: reg curr i.cl_dyn5 not_c if fem==0
margins cl_dyn5, post coefl
eststo Men1

svy: reg curr i.cl_dyn5 not_c if fem==1
margins cl_dyn5, post coefl
eststo Women1

svy: reg lnHighestInc i.cl_dyn5 self if fem==0
margins cl_dyn5, post coefl
eststo Men2

svy: reg lnHighestInc i.cl_dyn5 self if fem==1
margins cl_dyn5, post coefl
eststo Women2

coefplot (Men1, label(Men))  (Women1, label(Women)),  bylabel(Status)  || ///
		 (Men2, label(Men))  (Women2, label(Women)),  bylabel(Salary) || ///
		 , byopts(xrescale) xline(0) drop(Men:3.cl_dyn5)
graph export statussalary.png, replace
