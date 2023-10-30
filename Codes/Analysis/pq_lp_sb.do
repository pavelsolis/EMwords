* ==============================================================================
* Local projections: Structural breaks
* ==============================================================================
use $file_dta2, clear

* Define local variables
* ------------------------------------------------------------------------------
local tbllbl "f_fctrssb"
scalar alpha = 0.05
local regcmd reg
local regopt r level(`= 100*(1-alpha)')
local condit if tin(1jan2011,30jun2023)
local sbt slr							// type of structural break test
local maxlag = 1
local t = 11
local indvars target`t' path`t'
local h = 0								// horizon for the test
local j = 0								// models

* FX
* ------------------------------------------------------------------------------
eststo clear
local vars logusdmxn
foreach v in `vars' {
	local ++j
	// controls
	local ctrl`v'`t' l(1/`maxlag').`v' l(1/`maxlag').h15t10y l(1/`maxlag').vix l(1/`maxlag').embi l(1/`maxlag').wti l(1/`maxlag').tedsprd l(1/`maxlag').ticesprd l(1/`maxlag').cds5y l(1/`maxlag').dlogmexbol
	// response variables
	capture gen `v'`t'`h' = f`h'.`v'
	// regression at h = 0
	`regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'' `condit', `regopt'
	eststo mdl`j'
	estat sbsingle, nodots breakvars(l(1/`maxlag').`v') `sbt'
	estadd scalar sbt_chi2 = r(chi2_`sbt')
	estadd scalar sbt_p    = r(p_`sbt')
	estadd scalar sbt_date = date(r(breakdate), "DMY")
	estadd scalar sbt_obs  = r(N)
}		// `v' variable

* YC
* ------------------------------------------------------------------------------
local vars gmxn02yr_ttdy gmxn05yr_ttdy gmxn10yr_ttdy gmxn30yr_ttdy
foreach v in `vars' {
	local ++j
	tempvar v2
	gen `v2' = L`maxlag'.`v'*100
	// controls
	local ctrl`v'`t' `v2' l(1/`maxlag').dlogusdmxn l(1/`maxlag').h15t10y l(1/`maxlag').vix l(1/`maxlag').embi l(1/`maxlag').wti l(1/`maxlag').tedsprd l(1/`maxlag').ticesprd l(1/`maxlag').cds5y l(1/`maxlag').dlogmexbol
	// response variables
	capture gen `v'`t'`h' = f`h'.`v'*100
	// regression at h = 0
	`regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'' `condit', `regopt'
	eststo mdl`j'
	estat sbsingle, nodots breakvars(`v2') `sbt'
	estadd scalar sbt_chi2 = r(chi2_`sbt')
	estadd scalar sbt_p    = r(p_`sbt')
	estadd scalar sbt_date = date(r(breakdate), "DMY")
	estadd scalar sbt_obs  = r(N)
}		// `v' variable

* Flows
* ------------------------------------------------------------------------------
local vars domestic foreigners
local ii = 0
forvalues group = 1/3 {
	local ++ii
	if `ii' == 1 local scty cts
	if `ii' == 2 local scty qbnd
	if `ii' == 3 local scty udi
	
	foreach var in `vars' {
			local ++j
			local v `scty'`var'
			
			// controls
			local ctrl`v'`t' l(1/`maxlag').`v' l(1/`maxlag').dlogusdmxn l(1/`maxlag').h15t10y l(1/`maxlag').vix l(1/`maxlag').embi l(1/`maxlag').wti l(1/`maxlag').tedsprd l(1/`maxlag').ticesprd l(1/`maxlag').cds5y l(1/`maxlag').dlogmexbol
			// response variables
			capture gen `v'`t'`h' = f`h'.`v'
			// regression at h = 0
			`regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'' `condit', `regopt'
			eststo mdl`j'
			estat sbsingle, nodots breakvars(l(1/`maxlag').`v') `sbt'
			estadd scalar sbt_chi2 = r(chi2_`sbt')
			estadd scalar sbt_p    = r(p_`sbt')
			estadd scalar sbt_date = date(r(breakdate), "DMY")
			estadd scalar sbt_obs  = r(N)
		}
}

* Report results
* ------------------------------------------------------------------------------
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace keep("") fragment nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) /// 
stats(k sbt_chi2 sbt_p sbt_date sbt_obs, fmt(%4.2fc %4.2fc %4.3fc %tdNN/DD/YY %9.0fc) labels(\midrule "Statistic" "\textit{p}-value" "Break Date" "Obs.")) ///
mgroups("FX Returns" "2Y Yield" "5Y Yield" "10Y Yield" "30Y Yield" "Cetes Domes."  "Cetes Foreign"  "Bonos Domes."  "Bonos Foreign" "Udibonos Domes."  "Udibonos Foreign", pattern(1 1 1 1 1 1 1 1 1 1 1))
