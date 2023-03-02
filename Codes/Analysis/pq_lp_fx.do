* ==============================================================================
* Local projections: FX
* ==============================================================================
use $file_dta2, clear

* Define local variables
scalar alpha = 0.05
local regcmd reg								// xtreg
local regopt r level(`= 100*(1-alpha)')
local maxlag = 1

local vars logusdmxn_ttdy
foreach t in 11 {	// 04 09 00 07 _ttdm _ttwd
	// regressions
	foreach v in `vars' {
	
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
			local ctrl`v'`t' l(1/`maxlag').d`v' l(1/`maxlag').h15t10y l(1/`maxlag').vix l(1/`maxlag').embi l(1/`maxlag').wti l(1/`maxlag').tedsprd l(1/`maxlag').ticesprd l(1/`maxlag').cds5y l(1/`maxlag')d.logmxmx
		
		forvalues h = 0/$horizon {
			// response variables
			capture gen `v'`t'`h' = (f`h'.`v' - l.`v')*100		// expressed in basis points
			
			// one regression for each horizon
			if `h' == 0 {
				`regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'', `regopt'	// on-impact effect
				foreach shock in `indvars' {
					local pvalue = (2 * ttail(e(df_r),abs(_b[`shock']/_se[`shock'])))
					if `pvalue' < alpha local `shock'`v'  = 1*_b[`shock']
					else local `shock'`v' = 0
				}
			}
			quiet `regcmd' `v'`t'`h' `indvars' `ctrl`v'`t'', `regopt'
			
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
	}		// `v' variable
	
	// graphs
	local j = 0
	foreach shock in `indvars' {
		local ++j
		if `j' == 1 local shk "Target"
		if `j' == 2 local shk "Path"
		
		local k = 0
		foreach v in `vars' {
			local ++k
			if `k' == 1 local yxtitles ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall))
			else local yxtitles xtitle("Days", size(medsmall))
			twoway 	(line ll1_`shock'_`v' days, lcolor(gs6) lpattern(dash)) ///
					(line ul1_`shock'_`v' days, lcolor(gs6) lpattern(dash)) ///
					(line b_`shock'_`v' days, lcolor(blue*1.25) lpattern(solid) lwidth(thick)) /// 
					(line zero days, lcolor(black)), ///
			`yxtitles' xlabel(0(15)$horizon, nogrid) ylabel(``shock'`v'' "{bf:{&rArr}}", add custom labcolor(red) tlcolor(red) nogrid) ///
			graphregion(color(white)) plotregion(color(white)) legend(off) name(`v'`t', replace) ///
			title(`: variable label `v'', color(black) size(medium))

// 				graph export $pathfigs/LPs/`shk'/`v'`t'.eps, replace
			local graphs`shock'`t' `graphs`shock'`t'' `v'`t'
			drop *_`shock'_`v'				// b_ and confidence intervals
		}	// `v' variable

		graph combine `graphs`shock'`t'', rows(1) ycommon
		graph export $pathfigs/LPs/`shk'/`shk'`t'FX.eps, replace
		graph drop _all
	}		// `shock'
}		// `t' tenor
