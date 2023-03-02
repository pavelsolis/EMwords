* ==============================================================================
* Descriptive analysis
* ==============================================================================
use $file_dta2, clear

summ cts* qbnd*
summ dcts* dqbnd*
corr dcts* dqbnd*

* ==============================================================================
* Event study
* ==============================================================================
local shocks target11 path11
local controls l.usdmxn l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx

foreach var of varlist dcts* dqbnd* {
	regress `var' `shocks' if mpday, robust
	regress `var' `shocks' `controls' if mpday, robust
}
	// results are qualitatively similar when controls are included


* ------------------------------------------------------------------------------
* Table: Flows to Cetes (event study)

local tbllbl "f_fctrsctsid"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dctsbanks dctsmutual dctspension dctsinsurers dctsothers dctsforeigners {	//  dctsrepos dctscollateral	 "Repos" "Collateral"
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Foreigners", pattern(1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Bonds (event study)

local tbllbl "f_fctrsbndid"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dqbndbanks dqbndmutual dqbndpension dqbndinsurers dqbndothers dqbndforeigners {	//  dqbndrepos dqbndcollateral	 "Repos" "Collateral"
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Foreigners", pattern(1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Bonds (event study, no valuation adjustment)

local tbllbl "f_fctrsbndidnova"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist bndbanks bndmutual bndpension bndinsurers bndothers bndforeigners {	//  dqbndrepos dqbndcollateral	 "Repos" "Collateral"
	regress d`var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Foreigners", pattern(1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Total holdings of Cetes and Bonds (event study)

local tbllbl "f_fctrstotid"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dctstotal dqbndtotal {
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Cetes" "Bonos", pattern(1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------
