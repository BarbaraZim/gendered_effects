
********************************************************************************

***		Robustness Checks   ***

********************************************************************************

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
********************************************************************************

*Zusammenhang hparisei salary*

two (lpolyci lnHighestInc hparisei [aw= wt9_kal] if !(cl_oma5==3 & !female) & eduend<td(01jul2012) & !female, bw(6)) ///
    (lpolyci lnHighestInc hparisei [aw= wt9_kal] if !(cl_oma5==3 & !female) & eduend<td(01jul2012) & female, bw(6))
	
	
*Nur wer mind. vor 2 Jahren abgeschl. hat*

svy: reg lnHighestInc i.female##c.hparisei self if !(cl_oma4plus==3 & !female) & eduend<td(01jul2012)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg lnHighestInc i.female##c.hparisei self i.cl_oma4plus if !(cl_oma4plus==3 & !female) & eduend<td(01jul2012)
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

       graph export "..\Analysen\graphs\salaeduend.png", replace
	   
	   
////////////////////////////////////////////////////////////////////////////////////////////

											*ALT*

////////////////////////////////////////////////////////////////////////////////////////////
	   
cd H:\Dokumente_SOZ\Arbeitsmarkt\P2_Soziale_Herkunft\Daten\TREE\Episodendaten\2018-Analysen

use sequences_withPISA, clear // die sind ohne Cluster

use sequences_withPISA_clustersPH, clear // mit OMA & DYN Clusters

***color scheme
set scheme plotplainblind

svyset psu [pweight=wt9_kal], strata(strata) fpc(fpc) vce(linearized) singleunit(scaled)

********************************************************************************
two (lpolyci lnHighestInc hparisei [aw= wt9_kal] if !(cl_oma5==3 & !female) & eduend<td(01jul2012) & female, bw(6)) ///
    (lpolyci lnHighestInc hparisei [aw= wt9_kal] if !(cl_oma5==3 & !female) & eduend<td(01jul2012) & !female, bw(6))

*Salary
*Vgl. Linear quadrat*
reg lnHighestInc i.female##c.hparisei self if !(cl_oma5==3 & !female), vce(cluster psu)
eststo lin

reg lnHighestInc i.female##c.hparisei##c.hparisei self if !(cl_oma5==3 & !female), vce(cluster psu)
eststo qua

esttab lin qua using 201810_vgl_linqua_salary.rtf, replace

*Lohn quadratisch*
svy: reg lnHighestInc i.female##c.hparisei##c.hparisei self if !(cl_oma5==3 & !female) & eduend<td(01jul2012)
margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg lnHighestInc i.female##c.hparisei##c.hparisei self i.cl_oma5 if !(cl_oma5==3 & !female) & eduend<td(01jul2012)
margins, at(hparisei = (10(1)90)) over(female) post coefl
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

			  graph export 201810_effectsSALARY_total-dirQ.png, replace
*******************
*F & M getrennt*
*linear*
reg lnHighestInc c.hparisei self if fem==0, vce(cluster psu)
eststo ml
reg lnHighestInc c.hparisei self if fem==1, vce(cluster psu)
eststo fl

*quadratisch*
reg lnHighestInc c.hparisei##c.hparisei self if fem==0, vce(cluster psu)
eststo mq
reg lnHighestInc c.hparisei##c.hparisei self if fem==1, vce(cluster psu)
eststo fq

esttab ml fl mq fq  using 201810_vgl_linquaFM_salary.rtf, replace r2 ar2

***************
*ISEI zentriert linear
reg lnHighestInc i.female##c.c_hparisei self if !(cl_oma5==3 & !female), vce(cluster psu)
qui margins, at(c_hparisei = (-40(1)40)) over(female) post coefl
eststo total

reg lnHighestInc i.female##c.c_hparisei self i.cl_oma5 if !(cl_oma5==3 & !female), vce(cluster psu)
qui margins, at(c_hparisei = (-40(1)40)) over(female) post coefl
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
              xlabel(-40 0 40) ///
              xsize(15) ysize(6) aspectratio(0.6072, placement(left)) name(Effects, replace)


*ISEI
*Vgl. Linear quadrat*
reg current_isei i.female##c.hparisei i.not_current if !(cl_oma5==3 & !female), vce(cluster psu)
eststo lin

reg current_isei i.female##c.hparisei##c.hparisei i.not_current if !(cl_oma5==3 & !female), vce(cluster psu)
eststo qua

esttab lin qua, r2 ar2

*******************************
*ISEI mit Gewicht linear

svy: reg current_isei i.female##c.hparisei self if !(cl_oma5==3 & !female)
qui margins, at(hparisei = (10(1)90)) over(female) post coefl
eststo total

svy: reg current_isei i.female##c.hparisei self i.cl_oma5 if !(cl_oma5==3 & !female)
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

	graph export 201811_total_direct_linear_svy.png, replace


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

									*** EGP ***

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

*** Diverse Tests ****


svy: mean lnHighestInc if fem==0, over(parentegp)
eststo lnincM
svy: mean lnHighestInc if fem==1, over(parentegp)
eststo lnincF
coefplot (lnincM, label(Men) pstyle(p1)recast(bar) barwidth(0.2) fcolor(*.8) lcolor(*.6) ciopts(recast(rcap)) citop offset(0.20)) ///
         (lnincF, label(Women) pstyle(p2)recast(bar) barwidth(0.2) fcolor(*.5) lcolor(*.4) ciopts(recast(rcap)) citop offset(-.20)) ///
		 , coeflabels(_subpop_1 = "Higher Controllers" _subpop_2 = "Lower Controllers" _subpop_3 = "Routine Non-Manual" _subpop_4 = "Skilled Manual" ///
		 _subpop_5 = "Semi-Unskilled Manual" _subpop_6 = "Farm Labor" _subpop_7 = "Selfempl. Farmer")
		 graph export lnmeanincEGP-G.png, replace

svy: mean HighestInc if fem==0, over(parentegp)
eststo incM
svy: mean HighestInc if fem==1, over(parentegp)
eststo incF
coefplot (incM, label(Men) pstyle(p1)recast(bar) barwidth(0.2) fcolor(*.8) lcolor(*.6) ciopts(recast(rcap)) citop offset(0.20)) ///
         (incF, label(Women) pstyle(p2)recast(bar) barwidth(0.2) fcolor(*.5) lcolor(*.4) ciopts(recast(rcap)) citop offset(-.20)) ///
		 , coeflabels(_subpop_1 = "Higher Controllers"  _subpop_2 = "Lower Controllers" _subpop_3 = "Routine Non-Manual" _subpop_4 = "Skilled Manual" ///
		 _subpop_5 = "Semi-Unskilled Manual" _subpop_6 = "Farm Labor" _subpop_7 = "Selfempl. Farmer")
		 graph export meanincEGP-G.png, replace

reg lnHighestInc i.parentegp if fem==0, vce(cluster psu)
eststo m
reg lnHighestInc i.parentegp if fem==1, vce(cluster psu)
eststo f
esttab m f using EGP.rtf, replace


egen meaninc = mean(HighestInc), by(parentegp)
tabulate meaninc, generate(meaninc) nofreq

estpost prtest meaninc1-meaninc8, by(fem)
esttab . using meaninc.rtf, replace cell("b se p _star") label

/////////////////////////////////////////////////////////////////////////////////
*End of education
reshape long state jobisei_state, i(id) j(tv)
bysort id: gen _tmp_obsineduc = _n if state!=1 & state!=3
egen _tmp_lastobsineduc = max(_tmp_obsineduc), by(id)
by id: gen end_educ = state[_tmp_lastobsineduc]
by id: gen lastmonth_educ = tv[_tmp_lastobsineduc]
gen month_since_endeduc = 653 - lastmonth_educ
drop _tmp*
reshape wide
fre lastmonth_educ month_since_endeduc
bysort fem: sum lastmonth_educ

save sequences_withPISA_clustersPH, replace

center eduend
eststo clear
svy: reg lnHighestInc i.female##c.hparisei self if !(cl_dyn5==3 & !female)
eststo total1
svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 if !(cl_dyn5==3 & !female)
eststo direct1
svy: reg lnHighestInc i.female##c.hparisei self c.c_eduend##c.c_eduend if !(cl_dyn5==3 & !female)
eststo total2
svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 c.c_eduend##c.c_eduend if !(cl_dyn5==3 & !female)
eststo direct2
svy: reg lnHighestInc i.female##c.hparisei self if !(cl_dyn5==3 & !female) &  & 
eststo total3
svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 if !(cl_dyn5==3 & !female) & eduend<td(01jul2012)
eststo direct3

/*svy: reg lnHighestInc i.female##c.hparisei self eduendsec eduendter if !(cl_dyn5==3 & !female)
eststo total2
svy: reg lnHighestInc i.female##c.hparisei self i.cl_dyn5 eduendsec eduendter if !(cl_dyn5==3 & !female)
eststo direct2*/

esttab total* direct* using 201812_total_direct_salaryDynSVY-vgl3.rtf, replace se label compress nogaps interaction(*) nobaselevels 
