* ==============================================================================
* Local projections: Flows
* ==============================================================================
use $file_dta2, clear

* Define local variables
scalar alpha = 0.05
local regcmd reg									// xtreg
local regopt r level(`= 100*(1-alpha)')
local condit  if tin(1jan2011,30jun2023)
local sfx ""										// pre mid post
local maxlag = 1

local i = 0
forvalues block = 1/3 {
	local ++i
	if `i' == 1 {
		local ctg "Categ1"							// "Residence"
		local vars domestic foreigners				// total
		
	}
	if `i' == 2 {
		local ctg "Categ2"							// "Domestic types"
		local vars banks mutual pension others
	}
	if `i' == 3 {
		local ctg "Categ3"							// "Others"
		local vars insurers repos collateral
	}
	
	
	local ii = 0
	forvalues group = 1/5 {
		local ++ii
		local units "MXN   Billions"
		if `ii' == 1 {
			local scty cts
			local grp "Cetes"
		}
		if `ii' == 2 {
			local scty bnd
			local grp "Bonos"
		}
		if `ii' == 3 {
			local scty lnbnd
			local grp "BonosLN"
		}
		if `ii' == 4 {
			local scty qbnd
			local grp "BonosVA"
		}
		if `ii' == 5 {
			local scty udi
			local grp "Udibonos"
			local units "UDI   Billions"
		}
		
		foreach t in 11 {	// 04 09 _ttdm _ttwd
			// regressions
			foreach var in `vars' {
				
				local v `scty'`var'
				local indvars target`t' path`t'
				
				// variables to store the betas and confidence intervals
				capture {
				foreach shock in `indvars' {
					gen b_`shock'_`v'   = .
					gen ll1_`shock'_`v' = .
					gen ul1_`shock'_`v' = .
				}	// `shock'
				}
				
				// controls
				local ctrl`v'`t' l(1/`maxlag').`v' l(1/`maxlag').dlogusdmxn l(1/`maxlag').h15t10y l(1/`maxlag').vix l(1/`maxlag').embi l(1/`maxlag').wti l(1/`maxlag').tedsprd l(1/`maxlag').ticesprd l(1/`maxlag').cds5y l(1/`maxlag').dlogmexbol
				
				forvalues h = 0/$horizon {
					// response variables
					capture gen `v'`t'`h' = f`h'.`v'
					
					// one regression for each horizon
					if `h' == 0 {
						`regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'' `condit', `regopt'		// on-impact effect
						//estat sbsingle, nodots breakvars(l(1/`maxlag').`v') all gen(wdt`v' lrt`v')
						foreach shock in `indvars' {
							local pvalue = (2 * ttail(e(df_r),abs(_b[`shock']/_se[`shock'])))
							if `pvalue' < alpha local `shock'`v'  = 1*_b[`shock']
							else local `shock'`v' = 0
						}
					}
					quiet `regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'' `condit', `regopt'	//
					
					capture {				
					foreach shock in `indvars' {
						replace b_`shock'_`v'  = 1*_b[`shock'] if _n == `h'+1
						
						// confidence intervals
						matrix R = r(table)
						replace ll1_`shock'_`v' = 1*el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `h'+1
						replace ul1_`shock'_`v' = 1*el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `h'+1
					}		// `shock'
					drop `v'`t'`h'
					}
				}		// `h' horizon
			}		// `v' yield component
			
			// graphs
			local j = 0
			foreach shock in `indvars' {
				local ++j
				if `j' == 1 local shk "Target"
				if `j' == 2 local shk "Path"
				
				local k = 0
				foreach var in `vars' {
					local v `scty'`var'
					local ++k
					if `k' == 1 local yxtitles ytitle(`units', size(medsmall)) xtitle("Days", size(medsmall))
					else local yxtitles xtitle("Days", size(medsmall))
					twoway 	(line ll1_`shock'_`v' days, lcolor(gs6) lpattern(dash)) ///
							(line ul1_`shock'_`v' days, lcolor(gs6) lpattern(dash)) ///
							(line b_`shock'_`v' days, lcolor(blue*1.25) lpattern(solid) lwidth(thick)) /// 
							(line zero days, lcolor(black)), ///
					`yxtitles' xlabel(0(15)$horizon, nogrid) ylabel(``shock'`v'' "{bf:{&rArr}}", add custom labcolor(red) tlcolor(red) nogrid) ///
					graphregion(color(white)) plotregion(color(white)) legend(off) name(`v'`t', replace) ///
					title(`: variable label `v'', color(black) size(medium))

					// graph export $pathfigs/LPs/`shk'/`grp'/`v'`t'.eps, replace
					local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'
					drop *_`shock'_`v'				// b_ and confidence intervals
				}	// `v' yield component

				graph combine `graphs`shock'`grp'`t'', rows(1) ycommon
				graph export $pathfigs/LPs/`shk'/`grp'/`shk'`t'`grp'`ctg'`sfx'.eps, replace
				graph drop _all
				local graphs`shock'`grp'`t'			// blanks out the macro, making it non-existent
			}	// `shock'
		}	// `t' tenor
	}	// `group'
}	//	`block'
