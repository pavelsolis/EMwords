* ==============================================================================
* Clean dataset and generate variables
* ==============================================================================
use $file_dta1, clear

* Dates in Stata format
// rename date dateold
// gen    date  = dofc(dateold)
// gen    datem = mofd(dofc(dateold))					// from Excel to continuos to monthly, used to label graphs
gen datem = mofd(date)
// format date %td
format datem %tmCCYY
// drop   dateold
// order  date, first

* Business calendar based on current dataset
capture {
 	bcal create calpqmps, from(date) purpose(Convert daily data into business calendar dates) replace
	bcal load calpqmps
	gen bizdate = bofd("calpqmps",date)
	format %tbcalpqmps bizdate
}

* Clean monetary policy shocks
rename mpday_ttdm mpday
replace mpday = 0 if mpday == .
foreach v of varlist target* path* {
	replace `v' = 0 if `v' == .
}
rename (target04_ttdm path04_ttdm target19_ttdm path19_ttdm target_tttg path_tttg) ///
		(target04 path04 target09 path09 target11 path11)
replace mpday    = 0 if inlist(date,td(27apr2004),td(17feb2016),td(20mar2020),td(21apr2020)) | date > td(31dec2021) // exclude extraordinary meetings & limit sample up to Dec 2021
replace target04 = . if date < td(1jan2004)
replace path04   = . if date < td(1jan2004)
replace target09 = . if date < td(1jan2009)
replace path09   = . if date < td(1jan2009)
replace target11 = . if date < td(1jan2011)
replace path11   = . if date < td(1jan2011)
drop target07_ttdm path07_ttdm // target_ttdm path_ttdm target_ttwd path_ttwd

* Generate variables for asymmetric response
gen byte eastrg = target11 < 0
gen byte tgttrg = target11 > 0 & target11 != .
gen byte easpth = path11 < 0
gen byte tgtpth = path11 > 0 & path11 != .
gen eastarget11 = eastrg*target11 
gen tgttarget11 = tgttrg*target11 
gen easpath11   = easpth*path11
gen tgtpath11   = tgtpth*path11 

* Generate variables for analysis
gen c4766y   = (c4765y + c4767y)/2
gen tedsprd  = (us0003m - usgg3m)*100
gen ticesprd = (mxibtiie - cetrg028)*100
order c4766y, before(c4767y)
order tedsprd ticesprd, after(wti)

* Declare data as time series using business dates
global t bizdate
sort  $t
tsset $t

* Express flows in MXN billions
foreach v of varlist ctsbanxico-bndtotal {
	replace `v' = `v'/1000
}

* Generate first differences
foreach v of varlist ctsbanxico-bndtotal c476*y {			// flows and daily yield changes
	gen d`v' = d.`v'
}
foreach v of varlist gmxn*yr_ttdy {							// in basis points
	gen d`v' = d.`v'*100
}

* Generate average maturity as integer
gen mtyyrs = mtydys/365
gen int mtyyrsul = round(mtyyrs,1)							// nearest integer, upper limit
gen int mtyyrsll = round(mtyyrs,0.1)						// integer part, lower limit


* Generate deflator
gen dfltr = .
local N = _N
forvalues i = 1/`N' {
	local yrs = mtyyrsul[`i']
	qui replace dfltr = 1-dc476`yrs'y*`yrs'/100 in `i'	// change in price = -dyield*maturity
}
gen deflator = 1 + dprice/100

* Adjust for valuation effects
foreach v of varlist bndbanxico-bndtotal {
	gen q`v' = `v'/deflator									// deflated value of holdings
	gen dq`v' = d.q`v'										// flows
}

* Prepare varibles to compute returns (in percent)
foreach v of varlist usdmxn mxmx mexbol {
	gen log`v' = ln(`v')*100
}
gen logusdmxn_ttdy  = ln(usdmxn_ttdy)
gen dlogusdmxn_ttdy = d.logusdmxn*100						// in basis points

* x-axis and zero line
global horizon = 30		// in days
gen days = _n-1 if _n <= $horizon +1
gen zero = 0 	if _n <= $horizon +1

* Label variables for figures and tables
#delimit ;
unab oldlabels : target11 path11 cts* qbnd* gmxn*yr_ttdy;
local newlabels `" "Target" "Path" "Banxico" "Repos" "Banks" "Collateral" "Pension Funds" "Mutual Funds" "Insurers"
"Others" "Domestic" "Foreigners" "Total" "Banxico" "Repos" "Banks" "Collateral" "Pension Funds" "Mutual Funds" "Insurers"
"Others" "Domestic" "Foreigners" "Total" "1Y Yield" "2Y Yield" "3Y Yield" "5Y Yield" "10Y Yield" "30Y Yield" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

save $file_dta2, replace
