cd C:\Users\bzimmermann\switchdrive\gendered_paths\Daten\Analysen

*NEU Cluster 1 (nur Berufslehre) manuell, funktioniert nur mit OMA gut - Februar 2019*

***OMA***** 

use sequences_withPISA, clear

egen furtheredu = anycount(state*), v(5/11)

gen app = 1
foreach var of varlist state* {
    replace app = 0 if `var' > 4
}

save sequences_withPISA, replace

keep if no_miss_wave 
drop if app==1
set matsize 10000
		
			reshape long state jobisei_state, i(id) j(tv)
trans2subs state, id(id) subs(smat)
reshape wide
		
        oma state*, subsmat(smat) pwd(omd) length(167) indel(1.5)
		
		matwrite omd using omd.mwrite
        matread using omd.mwrite
        clustermat wards omd, name(omd) add
        cluster gen cl_oma=groups(2 3 4 5 6 7 8 9 12)
		
		/* dynhamming state*, pwd(dyn)
        matwrite dyn using dyn.mwrite
        matread using dyn.mwrite
        clustermat wards dyn, name(dyn) add
        cluster gen cl_dyn=groups(2 3 4 5 6 7 8 9 12) */
		
		save sequences_withPISA_clusters.dta, replace
	

use sequences_withPISA, clear

merge 1:1 id using sequences_withPISA_clusters, keepusing(id cl_oma*) 
drop _merge*

keep if no_miss_wave

gen cl_oma4plus = cl_oma4
recode cl_oma4plus (1=2) (2=3) (3=4) (4=5)
replace cl_oma4plus = 1 if app==1

gen cl_oma5plus = cl_oma5
recode cl_oma5plus (1=2) (2=3) (3=4) (4=5) (5=6)
replace cl_oma5plus = 1 if app==1

label def clusters   1 "Vocational"  ///
                     2 "Voc. & Tertiary" ///
                     3 "Specialized Sec. & Tertiary" ///
                     4 "Academic Mixed" ///
                     5 "Academic"
			
lab val cl_oma4plus clusters
		 
tabulate cl_oma4plus, generate(cl_oma4plus) nofreq

foreach i of numlist 1(1)5 { 
	lab var cl_oma4plus`i' `" `: label clusters `i''"' 
	}
save sequences_withPISA_analyses, replace 

beep
