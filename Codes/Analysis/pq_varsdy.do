* ==============================================================================
* Clean dataset and generate variables
* ==============================================================================
use $file_dta1, clear

* Dates in Stata format
// rename date dateold
// gen    date  = dofc(dateold)
// gen    datem = mofd(dofc(dateold))						// from Excel to continuos to monthly, used to label graphs
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
replace mpday = 0 if inlist(date,td(27apr2004),td(17feb2016),td(20mar2020),td(21apr2020)) | date > td(30jun2023) // exclude emergency meetings & sample up to June 2023
replace target04 = . if date < td(1jan2004)
replace path04   = . if date < td(1jan2004)
replace target09 = . if date < td(1jan2009)
replace path09   = . if date < td(1jan2009)
replace target11 = . if date < td(1jan2011)
replace path11   = . if date < td(1jan2011)
drop target07_ttdm path07_ttdm // target_ttdm path_ttdm target_ttwd path_ttwd

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

* Express flows in (MXN or UDI) billions
foreach v of varlist ctsbanxico-uditotal {
	replace `v' = `v'/1000
}

* Generate first differences
foreach v of varlist ctsbanxico-uditotal c476*y {			// flows and daily yield changes
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
	qui replace dfltr = 1-dc476`yrs'y*`yrs'/100 in `i'		// change in price = -dyield*maturity
}
gen deflator = 1 + dprice/100

* Adjust for valuation effects (bonos only)
foreach v of varlist bndbanxico-bndtotal {
	gen q`v' = `v'/deflator									// deflated value of holdings
	gen dq`v' = d.q`v'										// flows
}

* Compute returns (in basis points)
foreach v of varlist usdmxn mxmx mexbol {
	gen log`v'  = ln(`v')*10000								// so that difference in basis points
	gen dlog`v' = d.log`v'
}

* Flows in logs and log changes
foreach v of varlist ctsbanks ctsmutual ctspension ctsinsurers ctsothers ctsrepos ctscollateral ctsdomestic ctsforeigners ctstotal bndbanks bndmutual bndpension bndinsurers bndothers bndrepos bndcollateral bnddomestic bndforeigners bndtotal udibanks udimutual udipension udiinsurers udiothers udirepos udicollateral udidomestic udiforeigners uditotal {
	gen ln`v' = ln(`v')*10000								// for log change to be in basis points
	gen dln`v' = d.ln`v'
}

* x-axis and zero line
global horizon = 30		// in days
gen days = _n-1 if _n <= $horizon +1
gen zero = 0 	if _n <= $horizon +1

* Label variables for figures and tables
#delimit ;
unab oldlabels : target11 path11 cts* bnd* qbnd* udi* gmxn*yr_ttdy ln* dctsbanxico-duditotal dqbnd*;
local newlabels `" "Target" "Path" "Banxico" "Repos" "Banks" "Collateral" "Pension Funds" "Mutual Funds" "Insurers"
"Non-Financial" "Domestic" "Foreigners" "Total" "Banxico" "Repos" "Banks" "Collateral" "Pension Funds" "Mutual Funds" "Insurers"
"Non-Financial" "Domestic" "Foreigners" "Total" "Banxico" "Repos" "Banks" "Collateral" "Pension Funds" "Mutual Funds" "Insurers"
"Non-Financial" "Domestic" "Foreigners" "Total" "Banxico" "Repos" "Banks" "Collateral" "Pension Funds" "Mutual Funds" "Insurers"
"Non-Financial" "Domestic" "Foreigners" "Total" "1Y Yield" "2Y Yield" "3Y Yield" "5Y Yield" "10Y Yield" "30Y Yield"
"Banks" "Mutual Funds" "Pension Funds" "Insurers" "Non-Financial" "Repos" "Collateral" "Domestic" "Foreigners" "Total"
"Banks" "Mutual Funds" "Pension Funds" "Insurers" "Non-Financial" "Repos" "Collateral" "Domestic" "Foreigners" "Total"
"Banks" "Mutual Funds" "Pension Funds" "Insurers" "Non-Financial" "Repos" "Collateral" "Domestic" "Foreigners" "Total"
"Cetes: Banxico" "Cetes: Repos" "Cetes: Banks" "Cetes: Collateral" "Cetes: Pension Funds" "Cetes: Mutual Funds" "Cetes: Insurers"
"Cetes: Non-Financial" "Cetes: Domestic" "Cetes: Foreigners" "Cetes: Total" "Bonos: Banxico" "Bonos: Repos" "Bonos: Banks"
"Bonos: Collateral" "Bonos: Pension Funds" "Bonos: Mutual Funds" "Bonos: Insurers" "Bonos: Non-Financial" "Bonos: Domestic" "Bonos: Foreigners"
"Bonos: Total" "Udibonos: Banxico" "Udibonos: Repos" "Udibonos: Banks" "Udibonos: Collateral" "Udibonos: Pension Funds"
"Udibonos: Mutual Funds" "Udibonos: Insurers" "Udibonos: Non-Financial" "Udibonos: Domestic" "Udibonos: Foreigners" "Udibonos: Total"
"Bonos: Banxico" "Bonos: Repos" "Bonos: Banks" "Bonos: Collateral" "Bonos: Pension Funds" "Bonos: Mutual Funds" "Bonos: Insurers"
"Bonos: Non-Financial" "Bonos: Domestic" "Bonos: Foreigners" "Bonos: Total" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

save $file_dta2, replace
