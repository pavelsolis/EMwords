* ==============================================================================
* Comparing MP factors
* ==============================================================================

* ------------------------------------------------------------------------------
* Figure 3.1. Monetary Policy Surprises in Mexico: Intraday vs. Daily Data
use dataprsfxyc.dta, clear
local figlbl "factorslines"
line target04 target_ttdm target datem if idx04, lpattern(solid shortdash_dot dash) ///
		title("Z1 (Target) Surprises") xtitle("") ytitle("Basis Points", placement(n) orient(horizontal) size(small)) yscale(outergap(-20)) legend(off)
		gr_edit yaxis1.title.DragBy 4 17
		graph save $pathfigs/target, replace
line path04 path_ttdm path datem if idx04, lpattern(solid shortdash_dot dash) ///
		title("Z2 (Path) Surprises") xtitle("") ytitle("Basis Points", placement(n) orient(horizontal) size(small)) yscale(outergap(-20)) legend(label(1 "Daily since 2004") label(2 "Daily since 2011") label(3 "Intraday since 2011") pos(6) ring(6) row(1))
		gr_edit yaxis1.title.DragBy 4 17
		graph save $pathfigs/path, replace
grc1leg2 $pathfigs/target.gph $pathfigs/path.gph, cols(1) legendfrom($pathfigs/path.gph)
quietly graph export $pathfigs/`figlbl'.eps , replace
quietly graph export $pathfigs/`figlbl'.pdf , replace
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Figure 3.2. Monetary Policy Dimensions with Tight Windows
use dataprsfxyc.dta, clear
local figlbl "factorspointstg"
scatter path target if ( radius > 6.5 & regular & !inlist(date,td(25oct2013),td(29sep2016),td(15dec2016),td(18may2017),td(14may2020),td(12nov2020),td(12aug2021)) ) | inlist(date,td(22jun2017)), ///
		mlabel(datelbl) mlabv(posmrkr) yline(0) xline(0) ytitle(, placement(n) orient(horizontal)) ///
		yscale(range(-15 11) outergap(-28)) ylabel(-15(5)10) xscale(range(-46 21)) xlabel(-40(10)20)
gr_edit yaxis1.title.DragBy 4 33
gr_edit xaxis1.title.DragBy -2 0
quietly graph export $pathfigs/`figlbl'.eps , replace
quietly graph export $pathfigs/`figlbl'.pdf , replace
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Figure 3.2. Monetary Policy Dimensions with Wide Windows
use dataprsfxyc.dta, clear
local figlbl "factorspointswd"
label variable target_ttwd "Target Surprises"
label variable path_ttwd "Path Surprises"
scatter path_ttwd target_ttwd if ( radius > 6.5 & regular & !inlist(date,td(25oct2013),td(29sep2016),td(15dec2016),td(18may2017),td(14may2020),td(12nov2020),td(12aug2021)) ) | inlist(date,td(22jun2017)), ///
		mlabel(datelbl) mlabv(posmrkr) yline(0) xline(0) ytitle(, placement(n) orient(horizontal)) ///
		yscale(range(-15 10) outergap(-28)) ylabel(-15(5)10) xscale(range(-46 21)) xlabel(-40(10)20)
gr_edit yaxis1.title.DragBy 4 33
gr_edit xaxis1.title.DragBy -2 0
quietly graph export $pathfigs/`figlbl'.eps , replace
quietly graph export $pathfigs/`figlbl'.pdf , replace
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Figure 3.2. Monetary Policy Dimensions with Daily Windows since 2011
use dataprsfxyc.dta, clear
local figlbl "factorspointsdy"
label variable target_ttdm "Target Surprises"
label variable path_ttdm "Path Surprises"
replace posmrkr = 1 if inlist(date,td(27apr2012))
replace posmrkr = 7 if inlist(date,td(11nov2021),td(16dec2021))
replace posmrkr = 9 if inlist(date,td(22jun2017),td(24jun2021))
replace posmrkr = 11 if inlist(date,td(15aug2019))
replace posmrkr = 12 if inlist(date,td(17nov2016),td(12nov2020))
scatter path_ttdm target_ttdm if ( radius > 6.5 & regular & !inlist(date,td(25oct2013),td(29sep2016),td(15dec2016),td(18may2017),td(14may2020),td(12aug2021)) ) | inlist(date,td(22jun2017)), ///
		mlabel(datelbl) mlabv(posmrkr) yline(0) xline(0) ytitle(, placement(n) orient(horizontal)) ///
		yscale(range(-20 25) outergap(-28)) ylabel(-20(5)25) xscale(range(-46 21)) xlabel(-40(10)20)
gr_edit yaxis1.title.DragBy 4 33
gr_edit xaxis1.title.DragBy -2 0
quietly graph export $pathfigs/`figlbl'.eps , replace
quietly graph export $pathfigs/`figlbl'.pdf , replace
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Figure 3.2. Monetary Policy Dimensions with Daily Windows since 2004
use dataprsfxyc.dta, clear
local figlbl "factorspoints04"
label variable target04 "Target Surprises"
label variable path04 "Path Surprises"
replace posmrkr = 1 if inlist(date,td(16jan2009),td(20mar2009),td(25oct2013))
replace posmrkr = 5 if inlist(date,td(26oct2007))
replace posmrkr = 7 if inlist(date,td(21apr2006),td(26aug2011),td(6jun2014),td(30jun2016))
replace posmrkr = 9 if inlist(date,td(19jun2009))
replace posmrkr = 11 if inlist(date,td(15aug2019))
scatter path04 target04 if (radius04 > 16 | (radius04 > 13 & abspath04 > 5)) & date > td(1jan2006) & !inlist(date,td(20jun2008),td(18jul2008),td(17apr2009),td(27apr2012),td(30jun2016),td(26sep2019)), ///
		mlabel(datelbl) mlabv(posmrkr) yline(0) xline(0) ytitle(, placement(n) orient(horizontal)) ///
		yscale(range(-30 40) outergap(-28)) ylabel(-30(10)40) xscale(range(-60 40)) xlabel(-60(10)40)
gr_edit yaxis1.title.DragBy 4 33
gr_edit xaxis1.title.DragBy -2 0
quietly graph export $pathfigs/`figlbl'.eps , replace
quietly graph export $pathfigs/`figlbl'.pdf , replace
* ------------------------------------------------------------------------------


* ==============================================================================
* Holdings of government securities
* ==============================================================================
use dataflowsmy.dta, clear

// line bnddomestic bndforeigners datem if datem
// line bnddomestic bndforeigners datem if datem >= tm(2007m1)	// CFS
// line bnddomestic bndforeigners datem if datem >= tm(2011m1)	// start of sample

// line ctsbanks ctsmutual ctspension ctsinsurers ctsothers datem if datem >= tm(2011m1) // ** pension
// line ctsbanks ctsmutual ctspension ctsinsurers ctsothers ctsforeigners datem if datem >= tm(2011m1) // foreign
// line ctsrepos ctscollateral datem if datem >= tm(2011m1)	// repos

// line bndbanks bndmutual bndpension bndinsurers bndothers datem if datem >= tm(2011m1)	// ** pension
// line bndbanks bndmutual bndpension bndinsurers bndothers bndforeigners datem if datem >= tm(2011m1) // foreign
// line bndrepos bndcollateral datem if datem >= tm(2011m1)	// repos

// line ctsforeigners ctsdomestic bndforeigners bnddomestic datem if datem >= tm(2011m1)	// ** foreign

// graph bar bnddomestic bndforeigners, over(datem) stack percent	// share of domestic and foreign

* ------------------------------------------------------------------------------
* Figures: Cetes, bonds, foreign vs domestic

local tbllbl "frgnvsdmstc"
line bndforeigners bnddomestic ctsforeigners ctsdomestic datem if datem >= tm(2011m1), lpattern(solid "-" dash_dot "-_") ytitle("MXN Billions", placement(n) orient(horizontal)) xtitle("") yscale(outergap(-25))
gr_edit yaxis1.title.DragBy 4 32
quiet graph export $pathfigs/Flows/`tbllbl'.eps, replace

local tbllbl "bndgroups"
line bndbanks bndmutual bndpension bndinsurers bndothers datem if datem >= tm(2011m1), lpattern(solid dash_dot "-" "-_" "-..") ytitle("MXN Billions", placement(n) orient(horizontal)) xtitle("") yscale(outergap(-25))
gr_edit yaxis1.title.DragBy 4 30
quiet graph export $pathfigs/Flows/`tbllbl'.eps, replace

local tbllbl "ctsgroups"
line ctsbanks ctsmutual ctspension ctsinsurers ctsothers datem if datem >= tm(2011m1), lpattern(solid dash_dot "-" "-_" "-..") ytitle("MXN Billions", placement(n) orient(horizontal)) xtitle("") yscale(outergap(-25))
gr_edit yaxis1.title.DragBy 4 30
quiet graph export $pathfigs/Flows/`tbllbl'.eps, replace
* ------------------------------------------------------------------------------
