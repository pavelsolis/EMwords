* ==============================================================================
* Response of BdM flows to MP shocks (monthly frequency)
* ==============================================================================
use dataflowsmy.dta, clear

* ------------------------------------------------------------------------------
* Table: Summary of BdM flows
local tbllbl "f_bdmflowssumm"
eststo clear

estpost summ dctsbanks dctsmutual dctspension dctsinsurers dctsothers dctsforeigners dqbndbanks dqbndmutual dqbndpension dqbndinsurers dqbndothers dqbndforeigners if idx11	// dctsrepos dctscollateral  dqbndrepos  dqbndcollateral

esttab using "$pathtbls/`tbllbl'.tex", replace fragment cell(( mean(fmt(%3.2f) label(Mean)) sd(fmt(%3.2f) label(Std. Dev.)) min(fmt(%3.2f) label(Min.)) max(fmt(%3.2f) label(Max.)) count(fmt(%3.0f) label(Obs.)) )) nomtitles nonumbers nonotes noobs label booktabs varlabels(, elist(dctsforeigners \midrule))	// dctscollateral
* ------------------------------------------------------------------------------


* Select lag order
// foreach scty in cts qbnd {
// 	foreach inst in repos banks mutual pension insurers others foreigners collateral domestic total {
// 		varsoc d`scty'`inst', maxlag(12) exog(target11 path11)	// same as if no exog since 2011
// 	}
// }

* ------------------------------------------------------------------------------
* Table: Flows to Cetes (monthly)

local tbllbl "f_fctrsctsmy"
eststo clear
local j = 0
local shocks target11 path11	// 04 09	// asymmetric: eastarget11 tgttarget11 easpath11 tgtpath11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

reg dctsbanks l(1/1).dctsbanks `shocks' `controls', r
local ++j
eststo mcts`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
reg dctsmutual `shocks' `controls', r
local ++j
eststo mcts`j', addscalars(Lags 0 R2 e(r2) Obs e(N))
reg dctspension `shocks' `controls', r
local ++j
eststo mcts`j', addscalars(Lags 0 R2 e(r2) Obs e(N))
reg dctsinsurers `shocks' `controls', r
local ++j
eststo mcts`j', addscalars(Lags 0 R2 e(r2) Obs e(N))
reg dctsothers l(1/1).dctsothers `shocks' `controls', r
local ++j
eststo mcts`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
reg dctsforeigners `shocks' `controls', r
local ++j
eststo mcts`j', addscalars(Lags 0 R2 e(r2) Obs e(N))

// reg dctsrepos `shocks' `controls', r
// local ++j
// eststo mcts`j', addscalars(Lags 0 R2 e(r2) Obs e(N))
// reg dctscollateral l(1/1).dctscollateral `shocks' `controls', r
// local ++j
// eststo mcts`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
// "Repos" "Collateral"

esttab mcts* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Foreign", pattern(1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule)) scalars("Lags" "Obs Obs." "R2 \(R^{2}\)") sfmt(%4.0fc %4.0fc %4.2fc)
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Bonds (monthly)

local tbllbl "f_fctrsbndmy"
eststo clear
local j = 0
local shocks target11 path11	// 04 09
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

reg dqbndbanks l(1/3).dqbndbanks `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 3 R2 e(r2) Obs e(N))
reg dqbndmutual l(1/1).dqbndmutual `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
reg dqbndpension `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 0 R2 e(r2) Obs e(N))
reg dqbndinsurers l(1/2).dqbndinsurers `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 2 R2 e(r2) Obs e(N))
reg dqbndothers l(1/1).dqbndothers `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
reg dqbndforeigners `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 0 R2 e(r2) Obs e(N))

// reg dqbndrepos l(1/12).dqbndrepos `shocks' `controls', r
// local ++j
// eststo mbnd`j', addscalars(Lags 12 R2 e(r2) Obs e(N))
// reg dqbndcollateral l(1/4).dqbndcollateral `shocks' `controls', r
// local ++j
// eststo mbnd`j', addscalars(Lags 4 R2 e(r2) Obs e(N))
// "Repos" "Collateral"

esttab mbnd* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Foreign", pattern(1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule)) scalars("Lags" "Obs Obs." "R2 \(R^{2}\)") sfmt(%4.0fc %4.0fc %4.2fc)
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Flows to Bonds (monthly, no valuation adjustment)

local tbllbl "f_fctrsbndmynova"
eststo clear
local j = 0
local shocks target11 path11	// 04 09
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

reg dbndbanks l(1/3).dbndbanks `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 3 R2 e(r2) Obs e(N))
reg dbndmutual l(1/1).dbndmutual `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
reg dbndpension `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 0 R2 e(r2) Obs e(N))
reg dbndinsurers l(1/2).dbndinsurers `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 2 R2 e(r2) Obs e(N))
reg dbndothers l(1/1).dbndothers `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 1 R2 e(r2) Obs e(N))
reg dbndforeigners `shocks' `controls', r
local ++j
eststo mbnd`j', addscalars(Lags 0 R2 e(r2) Obs e(N))

// reg dbndrepos l(1/12).dbndrepos `shocks' `controls', r
// local ++j
// eststo mbnd`j', addscalars(Lags 12 R2 e(r2) Obs e(N))
// reg dbndcollateral l(1/4).dbndcollateral `shocks' `controls', r
// local ++j
// eststo mbnd`j', addscalars(Lags 4 R2 e(r2) Obs e(N))
// "Repos" "Collateral"

esttab mbnd* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
starl( * 0.10 ** 0.05 *** 0.010) keep(`shocks') nomtitles nonumbers nonotes nolines noobs label booktabs collabels(none) ///
mgroups("Banks" "Mutual" "Pension" "Insurers" "Others" "Foreign", pattern(1 1 1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
varlabels(, elist(path11 \midrule)) scalars("Lags" "Obs Obs." "R2 \(R^{2}\)") sfmt(%4.0fc %4.0fc %4.2fc)
// VA matters less in monthly regressions
* ------------------------------------------------------------------------------
