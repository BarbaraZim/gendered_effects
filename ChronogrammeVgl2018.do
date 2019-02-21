use sequences_withPISA_OMA, clear // mit OMA Clusters

mychronogram state*, prop count ///
    by(cl_oma4, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9)) ///
    xsize(20) ysize(3.5) ytitle("Cases in Cluster") yscale(alt axis(1)) yscale(alt axis(2)) ylabel(0(200)800, grid) ///
	ylabel(0 1, axis(2)) name(oma4, replace) aspectratio(0.75, placement(left))


mychronogram state*, prop count ///
    by(cl_oma5, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9)) ///
    xsize(20) ysize(3.5) ytitle("Cases in Cluster") yscale(alt axis(1)) yscale(alt axis(2)) ylabel(0(200)800, grid) ///
	ylabel(0 1, axis(2)) name(oma5, replace) aspectratio(0.75, placement(left))


mychronogram state*, prop count ///
    by(cl_oma6, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9)) ///
    xsize(20) ysize(3.5) ytitle("Cases in Cluster") yscale(alt axis(1)) yscale(alt axis(2)) ylabel(0(200)800, grid) ///
	ylabel(0 1, axis(2)) name(oma6, replace) aspectratio(0.75, placement(left))

use sequences_withPISA_DYN, clear // mit DYN-Hamming Clusters

mychronogram state*, prop count ///
    by(cl_dyn5, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9)) ///
    xsize(20) ysize(3.5) ytitle("Cases in Cluster") yscale(alt axis(1)) yscale(alt axis(2)) ylabel(0(200)800, grid) ///
	ylabel(0 1, axis(2)) name(dyn4, replace) aspectratio(0.75, placement(left))

mychronogram state*, prop count ///
    by(cl_dyn5, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9)) ///
    xsize(20) ysize(3.5) ytitle("Cases in Cluster") yscale(alt axis(1)) yscale(alt axis(2)) ylabel(0(200)800, grid) ///
	ylabel(0 1, axis(2)) name(dyn5, replace) aspectratio(0.75, placement(left))

mychronogram state*, prop count ///
    by(cl_dyn5, rows(1) legend(position(4)) note("") graphregion(margin(small)) scale(1) title(Clusters of Educational Trajectories)) ///
    tlabel(487(84)653, format(%tmCCYY) /*angle(45)*/) legend(order( - " " 1 2 3 4 5 6 7 8 9)) ///
    xsize(20) ysize(3.5) ytitle("Cases in Cluster") yscale(alt axis(1)) yscale(alt axis(2)) ylabel(0(200)800, grid) ///
	ylabel(0 1, axis(2)) name(dyn6, replace) aspectratio(0.75, placement(left))

	use sequences_withPISA_OMA, clear // mit OMA Clusters
chronogram state*, by(cl_oma4, rows(1) legend(off)) xtitle("")name(oma4, replace)
chronogram state*, by(cl_oma5, rows(1) legend(off)) xtitle("")name(oma5, replace)
chronogram state*, by(cl_oma6, rows(1) legend(off)) xtitle("")name(oma6, replace)
   use sequences_withPISA_DYN, clear // mit DYN-Hamming Clusters
chronogram state*, by(cl_dyn4, rows(1) legend(off)) xtitle("")name(dyn4, replace)
chronogram state*, by(cl_dyn5, rows(1) legend(off)) xtitle("")name(dyn5, replace)
chronogram state*, by(cl_dyn6, rows(1) legend(off)) xtitle("")name(dyn6, replace)

graph combine oma4 dyn4 oma5 dyn5 oma6 dyn6, ycommon rows(6) ysize(20) xsize(10)

graph export 201810ChronoVgl.pdf, replace
