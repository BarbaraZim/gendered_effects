cd C:\Users\bzimmermann\switchdrive\gendered_paths\Daten\Analysen

use sequences_withPISA_analyses, clear

***color scheme
set scheme plotplainblind

grstyle init
grstyle set plain, grid compact
grstyle set legend , nobox
grstyle clockdir legend_position 6

****Svyset***
svyset psu [pweight=wt9_kal], strata(strata) fpc(fpc) vce(linearized) singleunit(scaled)
			  

********************************************************************************
// -------------------------------------------------------------------------------------------------
// Step 1: Highest ISEI on reading skills
// -------------------------------------------------------------------------------------------------

*Das quadratische Modell hat eine minimal bessere Modellanpassung bei read & natmat
center hparisei

*read
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


chronogram state*, prop ///
    by(cl_oma4plus, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(24)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9 10 11)) ///
    xsize(20) ysize(3.5) name(oma5, replace) aspectratio(0.75, placement(left))

graph export "..\Analysen\graphs\Figure2.png", replace	

	
**************	
svy: mlogit cl_oma4plus i.female##c.hparisei##c.hparisei c.wleread##c.natmat 
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

svy: reg current_isei i.female##c.hparisei##c.hparisei i.not_current if !(cl_oma4plus==3 & !female)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg current_isei i.female##c.hparisei##c.hparisei i.cl_oma4plus##i.not_current if !(cl_oma4plus==3 & !female)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo direct

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



***********************
*Effekte Clusters*
**********************

svy: reg curr i.cl_oma4plus not_c if fem==0
margins cl_oma4plus, post coefl
eststo Men

svy: reg curr i.cl_oma4plus not_c if fem==1
margins cl_oma4plus, post coefl
eststo Women

coefplot Men Women, xline(0) drop(Men:3.cl_oma4plus) title(Status) name(status, replace)
graph export "..\Analysen\graphs\Figure7.png", replace
 
			  
//------------------------------------------------------------------------------
// Step 4: Effects on salary at age 30
//------------------------------------------------------------------------------

*Höchster Lohn aus T9, vorerst kein Ausschluss von extremen Werten
*Ob selbständig oder nicht, macht keinen Unterschied, kann ggfs. als Robustness Check integriert werden
*Einen Unterschied machen würden hingegen in Privathaushalt oder Familienbetrieb angestellt (stark neg.)
*Das wäre aber m.E. schon wieder Overcontrol, da von elterl. Status & Bildung ggfs. beeinflusst.

		  
svy: reg lnHighestInc i.female##c.hparisei self if !(cl_oma4plus==3 & !female)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg lnHighestInc i.female##c.hparisei self i.cl_oma4plus if !(cl_oma4plus==3 & !female)
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
			  
svy: reg lnHighestInc i.female##c.hparisei self if !(cl_oma4plus==3 & !female)

eststo total1

svy: reg lnHighestInc i.female##c.hparisei self i.cl_oma4plus if !(cl_oma4plus==3 & !female)

eststo direct1

esttab total1 direct1 using "..\Analysen\tables\table4.rtf", replace se label compress nogaps interaction(*) nobaselevels wide


***********************
*Effekte Clusters*
**********************

svy: reg lnHighestInc i.cl_oma4plus self if fem==0
margins cl_oma4plus, post coefl
eststo Men

svy: reg lnHighestInc i.cl_oma4plus self if fem==1
margins cl_oma4plus, post coefl
eststo Women

coefplot Men Women, xline(0) drop(Men:3.cl_oma4plus) title(Salary) name(salary, replace)
graph export "..\Analysen\graphs\Figure8.png", replace

beep	   
********************************************************************************
********************************************************************************
