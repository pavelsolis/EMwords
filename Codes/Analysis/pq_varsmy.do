* ==============================================================================
* Read and merge datasets
* ==============================================================================


* TIC flows
* ------------------------------------------------------------------------------
import excel using dataticflows.xlsx, clear firstrow case(lower)
// gen datem = mofd(dofc(date))					// from Excel to continuos to monthly
gen datem = mofd(date)
format datem %tm
order datem, first
gen byte idx11 = datem >= tm(2011m1)
gen byte idx04 = datem >= tm(2004m1)
foreach var of varlist oflwtbonds-iflwfrgnstocks {
	gen b`var' = `var'/1000						// flows in billions of dollars
}
foreach var in tbonds agcybonds corpbonds corpstocks frgnbonds frgnstocks {
	gen nflw`var' = biflw`var' - boflw`var'		// net inflows in USD billions
}
order nflw* biflw* boflw*, after(datem)
keep datem date nflwtbonds-boflwfrgnstocks target path idx11 idx04

* Label variables
unab oldlabels: nflwtbonds-boflwfrgnstocks
local newlabels `" "Net Flows: T-Bonds, T-notes" "Net Flows: U.S. Agency Bonds" "Net Flows: U.S. Corp. Bonds" "Net Flows: U.S. Corp. Stocks" "Net Flows: Non-U.S. Bonds" "Net Flows: Non-U.S. Stocks" "Inflows: T-Bonds, T-notes" "Inflows: U.S. Agency Bonds" "Inflows: U.S. Corp. Bonds" "Inflows: U.S. Corp. Stocks" "Inflows: Non-U.S. Bonds" "Inflows: Non-U.S. Stocks" "Outflows: T-Bonds, T-notes" "Outflows: U.S. Agency Bonds" "Outflows: U.S. Corp. Bonds" "Outflows: U.S. Corp. Stocks" "Outflows: Non-U.S. Bonds" "Outflows: Non-U.S. Stocks" "'
local p : word count `oldlabels'
forvalues i = 1/`p' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

sort datem
save dataticflows.dta, replace


* Banxico flows
* ------------------------------------------------------------------------------

use $file_dta2, clear
collapse (sum) target04 path04 target09 path09 target11 path11 dcts* dqbnd* dbnd* dudi* ///
		(last) usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y logmxmx ctsbanxico-uditotal, by(datem)

* Prepare variables
foreach shock in target11 target09 target04 {
	label variable `shock' "Target"
}
foreach shock in path11 path09 path04 {
	label variable `shock' "Path"
}

replace target04 = . if datem < tm(2004m1)
replace path04   = . if datem < tm(2004m1)
replace target09 = . if datem < tm(2009m1)
replace path09   = . if datem < tm(2009m1)
replace target11 = . if datem < tm(2011m1)
replace path11   = . if datem < tm(2011m1)

* Label variables
unab oldlabels: dctsbanxico-dqbndtotal dbndbanxico-duditotal ctsbanks ctsmutual ctspension ctsinsurers ctsothers ctsrepos ctscollateral bndbanks bndmutual bndpension bndinsurers bndothers bndrepos bndcollateral udibanks udimutual udipension udiinsurers udiothers udirepos udicollateral ctsforeigners ctsdomestic bndforeigners bnddomestic udiforeigners udidomestic
local newlabels `" "Cetes: Banxico" "Cetes: Repos" "Cetes: Banks" "Cetes: Collateral" "Cetes: Pension Funds" "Cetes: Mutual Funds" "Cetes: Insurers" "Cetes: Non-Financial" "Cetes: Domestic" "Cetes: Foreigners" "Cetes: Total" "Bonos: Banxico" "Bonos: Repos" "Bonos: Banks" "Bonos: Collateral" "Bonos: Pension Funds" "Bonos: Mutual Funds" "Bonos: Insurers" "Bonos: Non-Financial" "Bonos: Domestic" "Bonos: Foreigners" "Bonos: Total" "Bonos: Banxico" "Bonos: Repos" "Bonos: Banks" "Bonos: Collateral" "Bonos: Pension Funds" "Bonos: Mutual Funds" "Bonos: Insurers" "Bonos: Non-Financial" "Bonos: Domestic" "Bonos: Foreigners" "Bonos: Total" "Udibonos: Banxico" "Udibonos: Repos" "Udibonos: Banks" "Udibonos: Collateral" "Udibonos: Pension Funds" "Udibonos: Mutual Funds" "Udibonos: Insurers" "Udibonos: Non-Financial" "Udibonos: Domestic" "Udibonos: Foreigners" "Udibonos: Total" "Banks" "Mutual Funds" "Pension Funds" "Insurers" "Non-Financial" "Cetes: Repos" "Cetes: Collateral" "Banks" "Mutual Funds" "Pension Funds" "Insurers" "Non-Financial" "Bonos: Repos" "Bonos: Collateral" "Banks" "Mutual Funds" "Pension Funds" "Insurers" "Non-Financial" "Repos" "Collateral" "Cetes: Foreigners" "Cetes: Domestic" "Bonos: Foreigners" "Bonos: Domestic" "Udibonos: Foreigners" "Udibonos: Domestic" "'
local p : word count `oldlabels'
forvalues i = 1/`p' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

sort datem


* Merge datasets
* ------------------------------------------------------------------------------
merge 1:1 datem using dataticflows

global t datem
sort  $t
tsset $t 									// declare dataset as time series

save dataflowsmy.dta, replace
