* ==============================================================================
* Descriptive analysis
* ==============================================================================
use $file_dta2, clear

summ cts* bnd* qbnd* udi* if datem >= tm(2011m1)
summ dcts* dbnd* dqbnd* dudi* if datem >= tm(2011m1)
corr dcts* dbnd* dqbnd* dudi* if datem >= tm(2011m1)


* ------------------------------------------------------------------------------
* Table: Summary of cetes, bonos and udibonos flows
local tbllbl "f_summflowsdy"
eststo clear

estpost summ dctsbanks dctsmutual dctspension dctsinsurers dctsothers dctsdomestic dctsforeigners dqbndbanks dqbndmutual dqbndpension dqbndinsurers dqbndothers dqbnddomestic dqbndforeigners dudibanks dudimutual dudipension dudiinsurers dudiothers dudidomestic dudiforeigners if datem >= tm(2011m1)

esttab using "$pathtbls/`tbllbl'.tex", replace fragment cell(( mean(fmt(3) label(Mean)) sd(fmt(%3.2f) label(Std. Dev.)) min(fmt(%3.2f) label(Min.)) max(fmt(%3.2f) label(Max.)) count(fmt(%9.0fc) label(Obs.)) )) nomtitles nonumbers nonotes noobs label booktabs varlabels(, elist(dctsforeigners \midrule dqbndforeigners \midrule))
* ------------------------------------------------------------------------------


* ==============================================================================
* Event study
* ==============================================================================
local shocks target11 path11
local controls l.usdmxn l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx

foreach var of varlist dcts* dqbnd* dudi* {
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

foreach var of varlist dctsbanks dctsmutual dctspension dctsinsurers dctsothers dctsrepos dctscollateral dctsforeigners {
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Repos" "Collateral" "Foreigners", pattern(1 1 1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Bonos (event study, with valuation adjustment)

local tbllbl "f_fctrsbndidva"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dqbndbanks dqbndmutual dqbndpension dqbndinsurers dqbndothers dqbndrepos dqbndcollateral dqbndforeigners {
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Repos" "Collateral" "Foreigners", pattern(1 1 1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Bonos (event study, no valuation adjustment)

local tbllbl "f_fctrsbndidnova"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dbndbanks dbndmutual dbndpension dbndinsurers dbndothers dbndrepos dbndcollateral dbndforeigners {
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Repos" "Collateral" "Foreigners", pattern(1 1 1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Udibonos (event study)

local tbllbl "f_fctrsudiid"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dudibanks dudimutual dudipension dudiinsurers dudiothers dudirepos dudicollateral dudiforeigners {
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Repos" "Collateral" "Foreigners", pattern(1 1 1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Total holdings of Cetes and Bonos (event study, with valuation adjustment)

local tbllbl "f_fctrstotidva"
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


* ------------------------------------------------------------------------------
* Table: Total holdings of Cetes, Bonos and Udibonos (event study, no valuation adjustment)
 
local tbllbl "f_fctrstotidnova"
eststo clear
local j = 0
local shocks target11 path11

foreach var of varlist dctstotal dbndtotal duditotal {
	regress `var' `shocks' if mpday, robust
	local ++j
	eststo mcts`j'
}

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) stats(N r2, labels ("Obs." "\(R^{2}\)") fmt(0 2)) ///
keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Cetes" "Bonos" "Udibonos", pattern(1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule))
* ------------------------------------------------------------------------------