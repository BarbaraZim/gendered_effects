cd H:\Dokumente_SOZ\Arbeitsmarkt\P2_Soziale_Herkunft\Daten\TREE\Episodendaten\2018-Analysen

use sequences_withPISA, clear


***OMA***** 
// kommen in ein gemeinsames Datenset

*set rmsg on
*preserve
        keep if no_miss_wave
        set matsize 10000
		
		reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide
		
        oma state*, subsmat(smat) pwd(omd) length(167) indel(1.5)
		
		 matwrite omd using omd.mwrite
        matread using omd.mwrite
        clustermat wards omd, name(omd) add
         cluster gen cl_oma=groups(2 3 4 5 6 7 8 9 12)

label def clusters   1 "Vocational"  ///
                     2 "Voc. & Tertiary" ///
                     3 "Specialized Sec. & Tertiary" ///
                     4 "Academic Mixed" ///
                     5 "Academic"
			
lab val cl_oma5 clusters
		 
tabulate cl_oma5, generate(cl_oma5) nofreq

foreach i of numlist 1(1)5 { 
	lab var cl_oma5`i' `" `: label clusters `i''"' 
	}

***Dynamic Hamming***


        dynhamming state*, pwd(dyn)
        matwrite dyn using dyn.mwrite
        matread using dyn.mwrite
        clustermat wards dyn, name(dyn) add
        cluster gen cl_dyn=groups(2 3 4 5 6 7 8 9 12)

lab val cl_dyn5 clusters
		
tabulate cl_dyn5, generate(cl_dyn5) nofreq

foreach i of numlist 1(1)5 { 
	lab var cl_dyn5`i' `" `: label clusters `i''"' 
	}
	
         save sequences_withPISA_clusters.dta, replace
*restore		
*beep

*use sequences_withPISA_clustersPH.dta, clear

*lab val cl_dyn5 clusters 

*fre cl_dyn7

*chronogram state*, by(cl_dyn7)

*recode cl_dyn7 (1=2) (2=1)

/*label def clusters7   1 "Vocational"  ///
                      2 "Voc. & Tertiary B" ///
					  3 "Voc. & Tertiary A" ///
                      4 "Specialized Sec. & Tertiary" ///
                      5 "Academic Mixed" ///
                 	  6	"Academic Short" ///
					  7 "Academic Long"
			
lab val cl_dyn7 clusters7
		 
tabulate cl_dyn7, generate(cl_dyn7) nofreq 

foreach i of numlist 1(1)7 { 
	lab var cl_dyn7`i' `" `: label clusters7 `i''"' 
	}
	
*save sequences_withPISA_clustersPH.dta, replace	*/
	
***OMAV*****

/*set rmsg on
preserve
        keep if no_miss_wave
        set matsize 10000
		
		reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide*/
		
        omav state*, subsmat(smat) pwd(omv) length(167) indel(1.5)
		
		 matwrite omv using omv.mwrite
        matread using omv.mwrite
        clustermat wards omv, name(omv) add
         cluster gen cl_omv=groups(2 3 4 5 6 7 8 9)
		 
   *save "../Episodendaten/_sequence_fullTraj_omv_cluster.dta", replace
*restore		


***Hollister****

/*set rmsg on
preserve
        keep if no_miss_wave
        set matsize 10000 
		
		reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide */
		
		hollister state*, subsmat(smat) pwd(hol) length(167) timecost(0.5) localcost(0.5)
		
matwrite hol using hol.mwrite
        matread using hol.mwrite
        clustermat wards hol, name(hol) add
         cluster gen cl_hol=groups(2 3 4 5 6 7 8 9)
		 
*save "../Episodendaten/_sequence_fullTraj_hol_cluster.dta", replace
*restore		


***Twed***		
		
/*set rmsg on
preserve
        keep if no_miss_wave
        set matsize 10000 
		
		reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide         */

		twed state*, subsmat(smat) pwd(twd) length(167) lambda(0.5) nu(0.04)
		
		matwrite twd using twd.mwrite
        matread using twd.mwrite
        clustermat wards twd, name(twd) add
        cluster gen cl_twd=groups(2 3 4 5 6 7 8 9)
		
*save "../Episodendaten/_sequence_fullTraj_twd_cluster.dta", replace
*restore			


***Hamming****

/*set rmsg on
preserve
        keep if no_miss_wave
        set matsize 10000 
		
		reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide         */
		
		hamming state*, subsmat(smat) pwd(ham)
		
        matwrite ham using ham.mwrite
        matread using ham.mwrite
        clustermat wards ham, name(ham) add
        cluster gen cl_ham=groups(2 3 4 5 6 7 8 9)
		
 save  sequences_withPISA_clustersPH2.dta, replace	
restore		
		 


/*****************************

*Alle zusammenfügen*
*****************************

merge m:1 id using _sequence_fullTraj_oma_cluster.dta, keepusing(id cl_* omd_*)
drop _merge
merge m:1 id using _sequence_fullTraj_omv_cluster.dta, keepusing(id cl_* omv_*)
drop _merge
merge m:1 id using _sequence_fullTraj_hol_cluster.dta, keepusing(id cl_* hol_*)
drop _merge
merge m:1 id using _sequence_fullTraj_twd_cluster.dta, keepusing(id cl_* twd_*)
drop _merge
merge m:1 id using _sequence_fullTraj_ham_cluster.dta, keepusing(id cl_* ham_*)
drop _merge

merge m:1 id using _sequence_fullTraj_dyn_clusterNS, keepusing (id dyn* cl_*)

foreach dist in dyn ham twd hol omv omd {
corrsqm omd `dist', nodiag
}


********************************************************************************
***Dynamic Hamming mit ISEI-States***

preserve
        keep if no_miss_wave
        set matsize 10000
        dynhamming new_state*, pwd(dyn1)
        matwrite dyn1 using dyn1.mwrite
        matread using dyn1.mwrite
        clustermat wards dyn1, name(dyn1) add
        cluster gen cl_dynISEI=groups(2 3 4 5 6 7 8 9 12)
        save "../Episodendaten/_epi_combi_with_PISA_DYN_newstate.dta", replace
restore
********************************************************************************

***OMA mit NEET*****


        keep if no_miss_wave
        set matsize 10000
		
		reshape long combi_state_neet educ_state neet_state jobisei_state, i(id) j(tv)
trans2subs combi_state_neet, id(id) subs(smat)
reshape wide
		
        oma combi_state_neet*, subsmat(smat) pwd(omd) length(167) indel(1.5)
		
		 matwrite omd3 using omd.mwrite
        matread using omd.mwrite
        clustermat wards omd3, name(omd3) add
         cluster gen neet_oma=groups(2 3 4 5 6 7 8 9 12)
		 
	

***DYN mit NEET*****


preserve
        keep if no_miss_wave
        set matsize 10000
        dynhamming combi_state_neet*, pwd(dyn1)
        matwrite dyn1 using dyn1.mwrite
        matread using dyn1.mwrite
        clustermat wards dyn1, name(dyn1) add
        cluster gen neet_dyn=groups(2 3 4 5 6 7 8 9 12)
        save _epi_masterdatensatz_with_PISA_neet_DYN, replace
restore


***DYN mit ISEI*****


preserve
        keep if no_miss_wave
        set matsize 10000
        dynhamming terz_jobisei_state*, pwd(dyn)
        matwrite dyn using dyn.mwrite
        matread using dyn.mwrite
        clustermat wards dyn, name(dyn) add
        cluster gen isei_dyn=groups(2 3 4 5 6 7 8 9 12)
        save _epi_masterdatensatz_with_PISA_ISEI_DYN, replace
restore
//hat nicht funktioniert//

********************************************************************************
********************************************************************************

*Neuer Masterdatensatz, 15. Februar*

use _epi_masterdatensatz_with_PISA_combi.dta, clear

**DYN mit NEET*****

set rmsg on
        keep if no_miss_wave
        set matsize 10000
        dynhamming combi_state_neet*, pwd(dynneet)
        matwrite dynneet using dynneet.mwrite
        matread using dynneet.mwrite
        clustermat wards dynneet, name(dynneet) add
        cluster gen cl_dynneet=groups(2 3 4 5 6 7 8 9 12)
        
save _epi_masterdatensatz_with_PISA_combi.dta, replace

***DYN mit ISEI*****

        keep if no_miss_wave
        set matsize 10000
        dynhamming combi_state_isei*, pwd(dynisei)
        matwrite dynisei using dynisei.mwrite
        matread using dynisei.mwrite
        clustermat wards dynisei, name(dynisei) add
        cluster gen cl_dynisei=groups(2 3 4 5 6 7 8 9 12)
    
save _epi_masterdatensatz_with_PISA_combi.dta, replace

***DYN mit Educ-Detail*****

        keep if no_miss_wave
        set matsize 10000
        dynhamming combi_state_educ*, pwd(dyneduc)
        matwrite dyneduc using dyneduc.mwrite
        matread using dyneduc.mwrite
        clustermat wards dyneduc, name(dyneduc) add
        cluster gen cl_dyneduc=groups(2 3 4 5 6 7 8 9 12)
    
save _epi_masterdatensatz_with_PISA_combi.dta, replace


***OMA mit Educ-Detail*****


        keep if no_miss_wave
        set matsize 10000
		
		reshape long combi_state_isei combi_state_educ combi_state_neet educ_state neet_state jobisei_state terz_jobisei_state, i(id) j(tv)
trans2subs combi_state_educ, id(id) subs(smat)
reshape wide combi_state_isei combi_state_educ combi_state_neet educ_state neet_state jobisei_state terz_jobisei_state, i(id) j(tv)
		
        oma combi_state_educ*, subsmat(smat) pwd(omd) length(167) indel(1.5)
		
		 matwrite omd using omd.mwrite
        matread using omd.mwrite
        clustermat wards omd, name(omd) add
         cluster gen cl_omaeduc=groups(2 3 4 5 6 7 8 9 12)

save _epi_masterdatensatz_with_PISA_combi.dta, replace


*******************************************************************************

****mit Missings****

  set matsize 10000
        dynhamming combi_state_missing*, pwd(dynmissing)
        matwrite dynmissing using dynmissing.mwrite
        matread using dynmissing.mwrite
        clustermat wards dynmissing, name(dynmissing) add
        cluster gen cl_dynmissing=groups(2 3 4 5 6 7 8 9 12) 
		
preserve
       
        set matsize 10000
		
		reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide
		
        oma state*, subsmat(smat) pwd(omd) length(167) indel(1.5)
		
		 matwrite omd using omd.mwrite
        matread using omd.mwrite
        clustermat wards omd, name(omd) add
         cluster gen cl_oma=groups(2 3 4 5 6 7 8 9 12)		
		 
       save sequences_withPISA_mitMissings.dta, replace
restore		
beep		 
*/
