* ==============================================================================
* Robustness (rreg)
* ==============================================================================
use dataflowsmy.dta, clear

* ------------------------------------------------------------------------------
* Robustness: Flows to Cetes (monthly)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

rreg dctsbanks l(1/1).dctsbanks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctsbanks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctsmutual `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctsmutual wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctspension `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctspension wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctsinsurers `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctsinsurers wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctsothers l(1/1).dctsothers `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctsothers wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctsforeigners `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctsforeigners wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctsrepos `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctsrepos wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dctscollateral l(1/1).dctscollateral `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dctscollateral wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

* dctsrepos: looks fine
twoway (scatter dctsrepos target11, mlabel(date)) (lfit dctsrepos target11)
twoway (scatter dctsrepos path11, mlabel(date)) (lfit dctsrepos path11)
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Robustness: Flows to Bonds (monthly)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

rreg dqbndbanks l(1/3).dqbndbanks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndbanks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndmutual l(1/1).dqbndmutual `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndmutual wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndpension `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndpension wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndinsurers l(1/2).dqbndinsurers `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndinsurers wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndothers l(1/1).dqbndothers `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndothers wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndforeigners `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndforeigners wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndrepos l(1/12).dqbndrepos `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndrepos wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg dqbndcollateral l(1/4).dqbndcollateral `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' dqbndcollateral wghts if wghts < 0.4, sep(0)
sort datem
drop wghts


* dqbndforeigners: result driven by 2013m3 (largest path shock)
twoway (scatter dqbndforeigners path11, mlabel(date)) (lfit dqbndforeigners path11)
twoway (scatter dqbndforeigners path11 if datem != tm(2013m3), mlabel(date)) (lfit dqbndforeigners path11) (lfit dqbndforeigners path11 if datem != tm(2013m3))

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg dqbndforeigners `shocks', r
reg dqbndforeigners `shocks' if datem != tm(2013m3), r				//  result driven by this observation
reg dqbndforeigners `shocks' `controls', r
reg dqbndforeigners `shocks' `controls' if datem != tm(2013m3), r	//  result driven by this observation


* dqbndrepos: result holds after removing 2016m6
twoway (scatter dqbndrepos target11, mlabel(date)) (lfit dqbndrepos target11)
twoway (scatter dqbndrepos path11, mlabel(date)) (lfit dqbndrepos path11)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg dqbndrepos l(1/12).dqbndrepos `shocks' `controls', r
reg dqbndrepos l(1/12).dqbndrepos `shocks' `controls' if datem != tm(2016m6), r
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Robustness: Net Flows (monthly)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

rreg nflwtbonds l(1/1).nflwtbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' nflwtbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg nflwagcybonds l(1/1).nflwagcybonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' nflwagcybonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg nflwcorpbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' nflwcorpbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg nflwcorpstocks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' nflwcorpstocks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg nflwfrgnbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' nflwfrgnbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg nflwfrgnstocks l(1/2).nflwfrgnstocks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' nflwfrgnstocks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

* nflwtbonds: removing 2013m3 gives significance to path (largest path shock)
twoway (scatter nflwtbonds path11, mlabel(date)) (lfit nflwtbonds path11)
twoway (scatter nflwtbonds path11, mlabel(date)) (lfit nflwtbonds path11) (lfit nflwtbonds path11 if datem != tm(2013m3))

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg nflwtbonds l(1/1).nflwtbonds `shocks' `controls', r
reg nflwtbonds l(1/1).nflwtbonds `shocks' `controls' if datem != tm(2013m3), r	//  significance in path

* nflwfrgnbonds: removing 2013m10 and 2019m9 gives significance to path
twoway (scatter nflwfrgnbonds path11, mlabel(date)) (lfit nflwfrgnbonds path11)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg nflwfrgnbonds `shocks' `controls', r
reg nflwfrgnbonds `shocks' `controls' if !inlist(datem,tm(2013m10),tm(2019m9)), r

* nflwfrgnstocks: result holds after removing 2013m7
twoway (scatter nflwfrgnstocks target11, mlabel(date)) (lfit nflwfrgnstocks target11)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg nflwfrgnstocks l(1/2).nflwfrgnstocks `shocks' `controls', r
reg nflwfrgnstocks l(1/2).nflwfrgnstocks `shocks' `controls' if !inlist(datem,tm(2013m7)), r
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Robustness: Inflows (monthly)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

rreg biflwtbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' biflwtbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg biflwagcybonds l(1/1).biflwagcybonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' biflwagcybonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg biflwcorpbonds l(1/3).biflwcorpbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' biflwcorpbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg biflwcorpstocks l(1/2).biflwcorpstocks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' biflwcorpstocks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg biflwfrgnbonds l(1/1).biflwfrgnbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' biflwfrgnbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg biflwfrgnstocks l(1/3).biflwfrgnstocks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' biflwfrgnstocks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

* biflwfrgnbonds: removing 2013m10, 2015m1, 2019m9 gives significance to target
twoway (scatter biflwfrgnbonds target11, mlabel(date)) (lfit biflwfrgnbonds target11)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg biflwfrgnbonds l(1/1).biflwfrgnbonds `shocks' `controls', r
reg biflwfrgnbonds l(1/1).biflwfrgnbonds `shocks' `controls' if !inlist(datem,tm(2013m10),tm(2015m1),tm(2019m9)), r
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Robustness: Outflows (monthly)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx

rreg boflwtbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' boflwtbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg boflwagcybonds l(1/3).boflwagcybonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' boflwagcybonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg boflwcorpbonds l(1/2).boflwcorpbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' boflwcorpbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg boflwcorpstocks l(1/2).boflwcorpstocks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' boflwcorpstocks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg boflwfrgnbonds l(1/3).boflwfrgnbonds `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' boflwfrgnbonds wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

rreg boflwfrgnstocks l(1/3).boflwfrgnstocks `shocks' `controls', genwt(wghts)
sort wghts
list date `shocks' boflwfrgnstocks wghts if wghts < 0.4, sep(0)
sort datem
drop wghts

* boflwfrgnstocks: result holds after removing 2012m10
twoway (scatter boflwfrgnstocks target11, mlabel(date)) (lfit boflwfrgnstocks target11)

local shocks target11 path11
local controls usdmxn h15t10y vix embi wti tedsprd ticesprd cds5y d.logmxmx
reg boflwfrgnstocks l(1/3).boflwfrgnstocks `shocks' `controls', r
reg boflwfrgnstocks l(1/3).boflwfrgnstocks `shocks' `controls' if !inlist(datem,tm(2012m10)), r
* ------------------------------------------------------------------------------
