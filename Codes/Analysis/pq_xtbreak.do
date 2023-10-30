* ==============================================================================
* Local projections: Structural breaks
* ==============================================================================
use $file_dta2, clear
forvalues h = 0/30 {
	gen logusdmxn11`h' = f`h'.logusdmxn - l.logusdmxn
}
foreach v in gmxn02yr_ttdy gmxn05yr_ttdy gmxn10yr_ttdy gmxn30yr_ttdy {
	forvalues h = 0/30 {
		gen `v'11`h' = (f`h'.`v' - l.`v')*100
	}
}

local vars domestic foreigners
local ii = 0
forvalues group = 1/3 {
	local ++ii
	if `ii' == 1 local scty cts
	if `ii' == 2 local scty qbnd
	if `ii' == 3 local scty udi
	
	foreach var in `vars' {
			local v `scty'`var'
			forvalues h = 0/30 {
				gen `v'11`h' = f`h'.`v' - l.`v'
			}
		}
}
// browse date target11 path11 logusdmxn110-udiforeigners1130 if tin(1jan2011,30jun2023)	// check


//tsset date
	// needed for xtbreak, don't generate new variables with lead or lag operators after this

* Testing for a break and estimate date: Intraday
local nbrks 1
foreach var in usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg gmxn10yr_tttg gmxn30yr_tttg dctsdomestic dctsforeigners dqbnddomestic dqbndforeigners dudidomestic dudiforeigners {
	capture xtbreak test `var' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), hypothesis(1) breaks(`nbrks')
	if r(supWtau) > r(c90) {
		reg `var' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), r
		xtbreak test `var' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), hypothesis(1) breaks(`nbrks')
	}
}
// 1 break - FX: 10/31/2014	2Y: No (4/30/2015)	5Y: 2/7/2019	10Y: 4/30/2015	30Y: 3/26/2015
// 2 break - FX: 9/5/2014  6/30/2016	2Y: No (4/30/2015 11/12/2020)	5Y: 12/20/2018  6/24/2021	10Y: 4/30/2015   2/8/2018	30Y: 3/26/2015  9/29/2016	Udi Dom: 8/10/2017  5/16/2019 Udi Frgn: (10/31/2014  8/11/2016)

/*
* Estimate dates with CI
local nbrks 1
foreach var in usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg gmxn10yr_tttg gmxn30yr_tttg dctsdomestic dctsforeigners dqbnddomestic dqbndforeigners dudidomestic dudiforeigners {
	xtbreak estimate `var' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), showindex breaks(`nbrks')
}
// essentially the same dates
*/

* FX & YC: Pre- & post- intrday break results (and robustness)
regress usdmxn_tttg target11 path11 if mpday == 1 & tin(1jan2011,30oct2014), r
	rreg usdmxn_tttg target11 path11 if mpday == 1 & tin(1jan2011,30oct2014)
regress usdmxn_tttg target11 path11 if mpday == 1 & tin(31oct2014,30jun2023), r
	rreg usdmxn_tttg target11 path11 if mpday == 1 & tin(31oct2014,30jun2023)

regress gmxn05yr_tttg target11 path11 if mpday == 1 & tin(1jan2011,6feb2019), r
	rreg gmxn05yr_tttg target11 path11 if mpday == 1 & tin(1jan2011,6feb2019)
regress gmxn05yr_tttg target11 path11 if mpday == 1 & tin(7feb2019,30jun2023), r
	rreg gmxn05yr_tttg target11 path11 if mpday == 1 & tin(7feb2019,30jun2023)

regress gmxn10yr_tttg target11 path11 if mpday == 1 & tin(1jan2011,29apr2015), r
	rreg gmxn10yr_tttg target11 path11 if mpday == 1 & tin(1jan2011,29apr2015)
regress gmxn10yr_tttg target11 path11 if mpday == 1 & tin(30apr2015,30jun2023), r
	rreg gmxn10yr_tttg target11 path11 if mpday == 1 & tin(30apr2015,30jun2023)
	
regress gmxn30yr_tttg target11 path11 if mpday == 1 & tin(1jan2011,25mar2015), r
	rreg gmxn30yr_tttg target11 path11 if mpday == 1 & tin(1jan2011,25mar2015)
regress gmxn30yr_tttg target11 path11 if mpday == 1 & tin(26mar2015,30jun2023), r
	rreg gmxn30yr_tttg target11 path11 if mpday == 1 & tin(26mar2015,30jun2023)
// shift in FX from path to target
// shift in YC from target to path, both smaller impact post, R2 pre-break > 0.9, R2 post-break (0.5,0.7)
// results are robust

* FX & YC: Pre- & post- over-horizon break results using intraday data (and robustness)
regress usdmxn_tttg target11 path11 if mpday == 1 & tin(1jan2011,20mar2014), r
	rreg usdmxn_tttg target11 path11 if mpday == 1 & tin(1jan2011,20mar2014)
regress usdmxn_tttg target11 path11 if mpday == 1 & tin(21mar2014,30jun2023), r
	rreg usdmxn_tttg target11 path11 if mpday == 1 & tin(21mar2014,30jun2023)
foreach var in gmxn02yr_tttg gmxn05yr_tttg gmxn10yr_tttg gmxn30yr_tttg {
	regress `var' target11 path11 if mpday == 1 & tin(1jan2011,14dec2016), r
		rreg `var' target11 path11 if mpday == 1 & tin(1jan2011,14dec2016)
	regress `var' target11 path11 if mpday == 1 & tin(15dec2016,30jun2023), r
		rreg `var' target11 path11 if mpday == 1 & tin(15dec2016,30jun2023)
}
// less robust than with intraday break dates


* ------------------------------------------------------------------------------
* Structural breaks for asset prices (intraday)
local tbllbl "f_sbreaksfxyc"
local j = 0								// models
eststo clear
local nbrks 1
foreach var in usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg gmxn10yr_tttg gmxn30yr_tttg {
	local ++j
	reg `var' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), r
	eststo mdl`j'
	xtbreak test `var' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), hypothesis(1) breaks(`nbrks')
	gen sbdate = date[el(r(breaks),2,1)+1]
	estadd scalar sbt_sup = r(supWtau)
	estadd scalar sbt_c99 = r(c99)
	estadd scalar sbt_c95 = r(c95)
	estadd scalar sbt_c90 = r(c90)
	estadd scalar sbt_date = sbdate[1]
	drop sbdate
}

* Report results
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace keep("") fragment nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) /// 
stats(k sbt_sup sbt_c99 sbt_c95 sbt_c90 sbt_date N, fmt(%4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %tdNN/DD/YY %9.0fc) labels(\cmidrule(lr){2-6} "Test Statistic" "1\% Crit. Value" "5\% Crit. Value" "10\% Crit. Value" "Break Date" "Obs.")) ///
mgroups("FX Returns" "2Y Yield" "5Y Yield" "10Y Yield" "30Y Yield", pattern(1 1 1 1 1))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Structural breaks for portfolio flows (h = 0/30)
local tbllbl "f_sbreaksflows"
local vars ctsdomestic11 ctsforeigners11 qbnddomestic11 qbndforeigners11 udidomestic11 udiforeigners11
local nbrks 1
local nhorz 30
local ncls : word count `vars'
matrix sbh = J(`nhorz'+1,`ncls',.)
local rk = 1
forvalues h = 0/`nhorz' {
	local ck = 1
	foreach var in `vars' {
		capture xtbreak test `var'`h' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), hypothesis(1) breaks(`nbrks')
		if r(supWtau) > r(c90) {
			reg `var'`h' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), r
			xtbreak test `var'`h' target11 path11 if mpday == 1 & tin(1jan2011,30jun2023), hypothesis(1) breaks(`nbrks')
			gen sbdate = date[el(r(breaks),2,1)+1]
			matrix sbh[`rk',`ck'] = sbdate[1]
			drop sbdate
		}
		local ++ck
	}
	local ++rk
}

* Report results
numlist "0/`nhorz'"
matrix rownames sbh = `r(numlist)'
//matlist sbh, format(%tdNN/DD/YY)
esttab matrix(sbh, fmt(%tdNN/DD/YY)) using "$pathtbls/`tbllbl'.tex", replace fragment nomtitles nonumbers nolines ///
collabels("Domestic" "Foreign" "Domestic" "Foreign" "Domestic" "Foreign") ///
mgroups("Cetes" "Bonos" "Udibonos", pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
* ------------------------------------------------------------------------------