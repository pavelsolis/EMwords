* ==============================================================================
* Event study: FX and YC
* ==============================================================================
use $file_dta2, clear

	* Results including all observations

* Main results
local controls l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx	// usdmxn
foreach var of varlist mpswc_tttg mpsw1a_tttg usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg-gmxn30yr_tttg {
	foreach k in 1 2 {
		if `k' == 1 local shk target11
		if `k' == 2 local shk target11 path11
	
		regress `var' `shk' if mpday, robust
		regress `var' `shk' `controls' if mpday, robust
	}
}
	// effects are generally stronger when controls are included


* ------------------------------------------------------------------------------
* Table: FX and YC
use $file_dta2, clear
local tbllbl "f_fctrsfxyc"
eststo clear
local j = 0

foreach var in usdmxn gmxn02yr gmxn05yr gmxn10yr gmxn30yr {
	foreach k in 1 2 {
		if `k' == 1 local shocks target11				// target_ttwd
		if `k' == 2 local shocks target11 path11		// target_ttwd path_ttwd
	
		regress `var'_tttg `shocks' if mpday, robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with controls
use $file_dta2, clear
local tbllbl "f_fctrsfxycwc"
eststo clear
local j = 0

local controls l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx	// usdmxn
foreach var of varlist usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg-gmxn30yr_tttg {
	foreach k in 1 2 {
		if `k' == 1 local shocks target11
		if `k' == 2 local shocks target11 path11
	
		regress `var' `shocks' `controls' if mpday, robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with daily factors
use $file_dta2, clear
label variable target_ttdm "Target"
label variable path_ttdm "Path"
local tbllbl "f_fctrsdyfxyc"
eststo clear
local j = 0

foreach var of varlist usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg-gmxn30yr_tttg {
	foreach k in 1 2 {
		if `k' == 1 local shocks target_ttdm
		if `k' == 2 local shocks target_ttdm path_ttdm
	
		regress `var' `shocks' if mpday & date >= td(1jan2011), robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with daily data since 2011 (all observations)
use $file_dta2, clear
label variable target_ttdm "Target"
label variable path_ttdm "Path"
local tbllbl "f_fctrsfxycdy"
eststo clear
local j = 0

foreach var of varlist usdmxn_tttg gmxn02yr_ttdm gmxn05yr_ttdm-gmxn30yr_ttdm {
	foreach k in 1 2 {
		if `k' == 1 local shocks target_ttdm
		if `k' == 2 local shocks target_ttdm path_ttdm
	
		regress `var' `shocks' if mpday & date >= td(1jan2011), robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with daily data since 2011 (same observations)
use $file_dta2, clear
label variable target_ttdm "Target"
label variable path_ttdm "Path"
local tbllbl "f_fctrsfxycdy"
eststo clear
local j = 0

foreach var in usdmxn gmxn02yr gmxn05yr gmxn10yr gmxn30yr {
	foreach k in 1 2 {
		if `k' == 1 local shocks target_ttdm
		if `k' == 2 local shocks target_ttdm path_ttdm
		
		if `j' < 2 local type "_tttg"
		else local type "_ttdm"
		regress `var'`type' `shocks' if mpday & date >= td(1jan2011) & `var'_tttg != ., robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with daily data since 2004
use $file_dta2, clear
label variable target_ttdm "Target"
label variable path_ttdm "Path"
local tbllbl "f_fctrsfxyc04"
eststo clear
local j = 0

foreach var of varlist usdmxn_tttg gmxn02yr_ttdm gmxn05yr_ttdm-gmxn30yr_ttdm {
	foreach k in 1 2 {
		if `k' == 1 local shocks target04
		if `k' == 2 local shocks target04 path04
	
		regress `var' `shocks' if mpday & date >= td(1jan2004), robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with daily data since 2004 (pre-GFC)
use $file_dta2, clear
label variable target_ttdm "Target"
label variable path_ttdm "Path"
local tbllbl "f_fctrsfxyc04pre"
eststo clear
local j = 0

foreach var of varlist usdmxn_tttg gmxn02yr_ttdm gmxn05yr_ttdm-gmxn30yr_ttdm {
	foreach k in 1 2 {
		if `k' == 1 local shocks target04
		if `k' == 2 local shocks target04 path04
	
		regress `var' `shocks' if mpday & date >= td(1jan2004) & date < td(1oct2008), robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: FX and YC with daily data since 2004 (post-GFC)
use $file_dta2, clear
label variable target_ttdm "Target"
label variable path_ttdm "Path"
local tbllbl "f_fctrsfxyc04post"
eststo clear
local j = 0

foreach var of varlist usdmxn_tttg gmxn02yr_ttdm gmxn05yr_ttdm-gmxn30yr_ttdm {
	foreach k in 1 2 {
		if `k' == 1 local shocks target04
		if `k' == 2 local shocks target04 path04
	
		regress `var' `shocks' if mpday & date >= td(1oct2008), robust
		local ++j
		eststo mdl`j'
	}
}
esttab mdl* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) stats(N r2, fmt(%4.0fc %4.2fc) labels("Obs." "\(R^{2}\)")) ///
mgroups("FX Returns" "\(\Delta\) 2Y Yield" "\(\Delta\) 5Y Yield" "\(\Delta\) 10Y Yield" "\(\Delta\) 30Y Yield", pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(_cons Constant, elist(_cons \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Intraday & Daily 3M & 12M Swaps

* Daily since 2011
local depvars "mpswc mpsw1a"
local opts_tbl "parentheses(stderr) format(%4.3fc) asterisk()"

* Store results
use $file_dta2, clear
// use datamerged.dta, replace
local tmpfile1 "$pathtbls/Temp/factors3m1y11"
local repapp "replace"
foreach depvar in `depvars' {
	quiet regress `depvar'_tttg target11 if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'1, `opts_tbl') `repapp'
	local repapp "append"
	quiet regress `depvar'_tttg target11 path11 if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'2, `opts_tbl') `repapp'
	quiet regress `depvar'_ttdm target_ttdm if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'3, `opts_tbl') `repapp'
	quiet regress `depvar'_ttdm target_ttdm path_ttdm if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'4, `opts_tbl') `repapp'
}

* Format results
use "`tmpfile1'", clear
// drop if strpos(var,"_cons") != 0
do $pathcode/fn_tbl_format
replace var = "Constant" if strpos(var,"_cons")
replace var = "Daily \(\rtdone\) Factor" if strpos(var,"target_")
replace var = "Daily \(\rtdtwo\) Factor" if strpos(var,"path_")
replace var = "Intraday \(\rtdone\) Factor" if strpos(var,"target11")
replace var = "Intraday \(\rtdtwo\) Factor" if strpos(var,"path11")
replace var = "Obs." if strpos(var,"Observations")
replace var = "\(\Rsqrt\)" if strpos(var,"R-squared")
gen long orig = _n
replace orig = . if orig == 3
replace orig = 3 if orig == 1
replace orig = 1 if orig == .
replace orig = . if orig == 4
replace orig = 4 if orig == 2
replace orig = 2 if orig == .
sort orig
drop orig
save "`tmpfile1'", replace

* Outsheet results
use "`tmpfile1'", clear
local tbllbl "factors3m1y"
local tblcap "Response of Swap Rates to \(\rtdone\) and \(\rtdtwo\) Factors"
local hdrln1 "&\multicolumn{4}{c}{3M-Swap}&\multicolumn{4}{c}{12M-Swap} \cmidrule(lr){2-5}\cmidrule(lr){6-9}"
local hdrln2 "&\multicolumn{2}{c}{Intraday}&\multicolumn{2}{c}{Daily}&\multicolumn{2}{c}{Intraday}&\multicolumn{2}{c}{Daily}"
local hdrln3 "\cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7}\cmidrule(lr){8-9}"
local tblsiz "normalsize"
local ftnsiz "footnotesize"
local ftnote "plchldr"
local tblfn1 "\BSbegin{flushleft}\n\BS`ftnsiz' .\n\BSend{flushleft}\n}"
local tblfn2 "\BSbegin{tablenotes}[para,flushleft]\n\BS`ftnsiz' \BStextit{Notes:} `ftnote'\n\BSend{tablenotes}\n}\n\BSend{threeparttable}"
local ftsen1 "For the 3-month swap rate, the table shows the coefficient estimates in regressions of intraday and daily changes in the 3-month swap rate on the \BS(\BSrtdone\BS) and \BS(\BSrtdtwo\BS) factors obtained from intraday and daily data, as explained in the main text."
local ftsen2 "Similarly for the 12-month swap rate. Daily changes are calculated around monetary policy announcements; intraday changes are calculated starting 10 minutes before to 20 minutes after a monetary policy announcement."
local ftsen3 "The sample includes all regular monetary policy announcements from January 2011 to \BSlastobs."
local ftsen4 "All variables are expressed in basis points. Robust standard errors are shown in parentheses. *, **, *** asterisks respectively indicate significance at the 10\BS%, 5\BS% and 1\BS% level."
tempfile x y z
texsave using `x', title(`tblcap') size(`tblsiz') marker("tab:`tbllbl'") footnote(".", size(`ftnsiz') addlinespace(0cm)) headerlines(`hdrln1' `hdrln2' `hdrln3') hlines(-2) nonames landscape replace
filefilter `x' `y', from("{geometry}\n") to("{geometry}\n\BSusepackage{threeparttable}\n") replace
filefilter `y' `z', from("\n\BScaption") to("\BSbegin{threeparttable}\n\BScaption") replace
filefilter `z' `y', from("`tblfn1'") to("`tblfn2'") replace
forvalues i = 1/4 {
	filefilter `y' `z', from("`ftnote'") to("`ftsen`i'' `ftnote'") replace
	filefilter `z' `y', replace
	}
filefilter `y' `z', from(" `ftnote'") to("") replace
filefilter `z' `x', from("{6-9} \BStabularnewline") to("{6-9}") replace
filefilter `x' "$pathtbls/`tbllbl'11.tex", from("\BSmidrule \BS") to("%\BSmidrule \BS") replace


* Daily data since 2004
local depvars "mpswc mpsw1a"
local opts_tbl "parentheses(stderr) format(%4.3fc) asterisk()"

* Store results
use $file_dta2, clear
// use datamerged.dta, replace
local tmpfile1 "$pathtbls/Temp/factors3m1y04"
local repapp "replace"
foreach depvar in `depvars' {
	quiet regress `depvar'_tttg target11 if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'1, `opts_tbl') `repapp'
	local repapp "append"
	quiet regress `depvar'_tttg target11 path11 if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'2, `opts_tbl') `repapp'
	quiet regress `depvar'_ttdm target04 if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'3, `opts_tbl') `repapp'
	quiet regress `depvar'_ttdm target04 path04 if mpday, robust
	regsave using "`tmpfile1'", table(`depvar'4, `opts_tbl') `repapp'
}

* Format results
use "`tmpfile1'", clear
// drop if strpos(var,"_cons") != 0
do $pathcode/fn_tbl_format
replace var = "Constant" if strpos(var,"_cons")
replace var = "Daily \(\rtdone\) Factor" if strpos(var,"target04")
replace var = "Daily \(\rtdtwo\) Factor" if strpos(var,"path04")
replace var = "Intraday \(\rtdone\) Factor" if strpos(var,"target11")
replace var = "Intraday \(\rtdtwo\) Factor" if strpos(var,"path11")
replace var = "Obs." if strpos(var,"Observations")
replace var = "\(\Rsqrt\)" if strpos(var,"R-squared")
gen long orig = _n
replace orig = . if orig == 3
replace orig = 3 if orig == 1
replace orig = 1 if orig == .
replace orig = . if orig == 4
replace orig = 4 if orig == 2
replace orig = 2 if orig == .
sort orig
drop orig
save "`tmpfile1'", replace

* Outsheet results
use "`tmpfile1'", clear
local tbllbl "factors3m1y"
local tblcap "Response of Swap Rates to \(\rtdone\) and \(\rtdtwo\) Factors"
local hdrln1 "&\multicolumn{4}{c}{3M-Swap}&\multicolumn{4}{c}{12M-Swap} \cmidrule(lr){2-5}\cmidrule(lr){6-9}"
local hdrln2 "&\multicolumn{2}{c}{Intraday}&\multicolumn{2}{c}{Daily}&\multicolumn{2}{c}{Intraday}&\multicolumn{2}{c}{Daily}"
local hdrln3 "\cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7}\cmidrule(lr){8-9}"
local tblsiz "normalsize"
local ftnsiz "footnotesize"
local ftnote "plchldr"
local tblfn1 "\BSbegin{flushleft}\n\BS`ftnsiz' .\n\BSend{flushleft}\n}"
local tblfn2 "\BSbegin{tablenotes}[para,flushleft]\n\BS`ftnsiz' \BStextit{Notes:} `ftnote'\n\BSend{tablenotes}\n}\n\BSend{threeparttable}"
local ftsen1 "For the 3-month swap rate, the table shows the coefficient estimates in regressions of intraday and daily changes in the 3-month swap rate on the \BS(\BSrtdone\BS) and \BS(\BSrtdtwo\BS) factors obtained from intraday and daily data, as explained in the main text."
local ftsen2 "Similarly for the 12-month swap rate. Daily changes are calculated around monetary policy announcements; intraday changes are calculated starting 10 minutes before to 20 minutes after a monetary policy announcement."
local ftsen3 "The sample includes all regular monetary policy announcements until \BSlastobs; the sample starts in January 2011 with intraday data, and in January 2004  with daily data."
local ftsen4 "All variables are expressed in basis points. Robust standard errors are shown in parentheses. *, **, *** asterisks respectively indicate significance at the 10\BS%, 5\BS% and 1\BS% level."
tempfile x y z
texsave using `x', title(`tblcap') size(`tblsiz') marker("tab:`tbllbl'") footnote(".", size(`ftnsiz') addlinespace(0cm)) headerlines(`hdrln1' `hdrln2' `hdrln3') hlines(-2) nonames landscape replace
filefilter `x' `y', from("{geometry}\n") to("{geometry}\n\BSusepackage{threeparttable}\n") replace
filefilter `y' `z', from("\n\BScaption") to("\BSbegin{threeparttable}\n\BScaption") replace
filefilter `z' `y', from("`tblfn1'") to("`tblfn2'") replace
forvalues i = 1/4 {
	filefilter `y' `z', from("`ftnote'") to("`ftsen`i'' `ftnote'") replace
	filefilter `z' `y', replace
	}
filefilter `y' `z', from(" `ftnote'") to("") replace
filefilter `z' `x', from("{6-9} \BStabularnewline") to("{6-9}") replace
filefilter `x' "$pathtbls/`tbllbl'04.tex", from("\BSmidrule \BS") to("%\BSmidrule \BS") replace
// Note: tbllbl is the same for 2004 and 2011 but the name of the tex file is different
* ------------------------------------------------------------------------------
