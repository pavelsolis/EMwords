use $file_dta2, clear


* ------------------------------------------------------------------------------
* Logs vs levels in flows
corr dctsbanks dlnctsbanks dctsmutual dlnctsmutual dctspension dlnctspension dctsinsurers dlnctsinsurers dctsothers dlnctsothers dctsforeigners dlnctsforeigners dbndbanks dlnbndbanks dbndmutual dlnbndmutual dbndpension dlnbndpension dbndinsurers dlnbndinsurers dbndothers dlnbndothers dbndforeigners dlnbndforeigners dudibanks dlnudibanks dudimutual dlnudimutual dudipension dlnudipension dudiinsurers dlnudiinsurers dudiothers dlnudiothers dudiforeigners dlnudiforeigners if datem >= tm(2011m1)
* high correlations b/w d* and dln*

local shocks target11 path11
foreach var of varlist dctsbanks dlnctsbanks dctsmutual dlnctsmutual dctspension dlnctspension dctsinsurers dlnctsinsurers dctsothers dlnctsothers dctsforeigners dlnctsforeigners dbndbanks dlnbndbanks dbndmutual dlnbndmutual dbndpension dlnbndpension dbndinsurers dlnbndinsurers dbndothers dlnbndothers dbndforeigners dlnbndforeigners dudibanks dlnudibanks dudimutual dlnudimutual dudipension dlnudipension dudiinsurers dlnudiinsurers dudiothers dlnudiothers dudiforeigners dlnudiforeigners {
	regress `var' `shocks' if mpday, robust
}
* consistent signs and significance

// with logs:
// different variable for the original research Q but similar, corr b/w d* dln* is 0.92 (cts .87, bnd .94, udi .94); in regressions, consistent signs and significance
// LPs similar shapes and results, bands are not tighter
// normality of residuals in original regressions

	* Unit root tests
*Levels
foreach var of varlist ctsbanks ctsmutual ctspension ctsinsurers ctsothers ctsrepos ctscollateral ctsforeigners qbndbanks qbndmutual qbndpension qbndinsurers qbndothers qbndrepos qbndcollateral qbndforeigners udibanks udimutual udipension udiinsurers udiothers udirepos udicollateral udiforeigners {
	dfuller `var' if datem >= tm(2011m1), trend
	pperron `var' if datem >= tm(2011m1), trend
	dfgls `var' if datem >= tm(2011m1), maxlag(7)
}

* Level changes
foreach var of varlist dctsbanks dctsmutual dctspension dctsinsurers dctsothers dctsrepos dctscollateral dctsforeigners dqbndbanks dqbndmutual dqbndpension dqbndinsurers dqbndothers dqbndrepos dqbndcollateral dqbndforeigners dudibanks dudimutual dudipension dudiinsurers dudiothers dudirepos dudicollateral dudiforeigners {
	dfuller `var' if datem >= tm(2011m1), trend
	pperron `var' if datem >= tm(2011m1), trend
	dfgls `var' if datem >= tm(2011m1), maxlag(7)
}

* Normality of residuals
local shocks target11 path11
local controls l.usdmxn l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx

foreach var of varlist dudibanks dlnudibanks dudimutual dlnudimutual dudipension dlnudipension dudiinsurers dlnudiinsurers dudiothers dlnudiothers dudirepos dlnudirepos dudicollateral dlnudicollateral dudiforeigners dlnudiforeigners {
	drop rsd*
	regress `var' `shocks' if mpday, robust
	predict rsd1, resid
	swilk rsd1 if mpday
	regress `var' `shocks' `controls' if mpday, robust
	predict rsd2, resid
	swilk rsd2 if mpday
}
// dctsbanks dlnctsbanks dctsmutual dlnctsmutual dctspension dlnctspension dctsinsurers dlnctsinsurers dctsothers dlnctsothers dctsrepos dlnctsrepos dctscollateral dlnctscollateral dctsforeigners dlnctsforeigners
// dbndbanks dlnbndbanks dbndmutual dlnbndmutual dbndpension dlnbndpension dbndinsurers dlnbndinsurers dbndothers dlnbndothers dbndrepos dlnbndrepos dbndcollateral dlnbndcollateral dbndforeigners dlnbndforeigners
// dudibanks dlnudibanks dudimutual dlnudimutual dudipension dlnudipension dudiinsurers dlnudiinsurers dudiothers dlnudiothers dudirepos dlnudirepos dudicollateral dlnudicollateral dudiforeigners dlnudiforeigners
	// d* similar to dln* in terms of normality of residuals

* ------------------------------------------------------------------------------
* Why the constant in FX & 30Y yield is significant?
// Due to large negative values in the dependent variables
stem usdmxn_tttg if mpday & date >= td(1jan2011)
summ usdmxn_tttg if mpday & date >= td(1jan2011)
summ usdmxn_tttg if mpday & date >= td(1jan2011) & usdmxn_tttg > -73
regress usdmxn_tttg target11 path11 if mpday, robust
predict yhatfx, xb
predict resfx, resid
scatter resfx yhatfx if mpday & resfx >= -50 || scatter resfx yhatfx if mpday & resfx < -50, mlabel(date) mcolor(red)
list date resfx if mpday & resfx < -55, divider
regress usdmxn_tttg target11 path11 if mpday & usdmxn_tttg > -73
scatter usdmxn_tttg target11 if mpday & usdmxn_tttg >= -73
scatter usdmxn_tttg target11 if mpday & usdmxn_tttg >= -73 || scatter usdmxn_tttg target11 if mpday & usdmxn_tttg < -73, mlabel(date) mcolor(red)
scatter usdmxn_tttg path11 if mpday & usdmxn_tttg >= -73 || scatter usdmxn_tttg path11 if mpday & usdmxn_tttg < -73, mlabel(date) mcolor(red)
rreg usdmxn_tttg target11 path11 if mpday
	// after removing 10 largest negative values, average FX value goes to zero & target11 effect decreases by >1bp b/c associated w/8 of the largest target11 values
	// constant is no longer significant w/rreg (results for target11 robust but not for path11 b/c low variability)
regress usdmxn_tttg target11 path11 if mpday
predict xdist, hat
lvr2plot, mlabel(date)
summ xdist if mpday, detail
list date usdmxn_tttg target11 path11 xdist resfx if mpday & date > td(1jan2011) & xdist > 0.15, divider
dfbeta
list date usdmxn_tttg target11 path11 _dfbeta_1 resfx if mpday & date > td(1jan2011) & abs(_dfbeta_1) > 2/sqrt(99), divider
list date usdmxn_tttg target11 path11 _dfbeta_2 resfx if mpday & date > td(1jan2011) & abs(_dfbeta_2) > 2/sqrt(99), divider
regress usdmxn_tttg target11 path11 if mpday & !inlist(date,td(6sep2013),td(6jun2014),td(30jun2016)), robust
	// most influential observations: 8mar2013, 6sep2013, 6jun2014, 30jun2016, 9feb2023
	// only one observation with high leverage (9feb2023) has a large change in FX

stem gmxn30yr_tttg if mpday & date >= td(1jan2011)
summ gmxn30yr_tttg if mpday & date >= td(1jan2011)
summ gmxn30yr_tttg if mpday & date >= td(1jan2011) & gmxn30yr_tttg > -14
regress gmxn30yr_tttg target11 path11 if mpday, robust
regress gmxn30yr_tttg target11 path11 if mpday & gmxn30yr_tttg > -14
scatter gmxn30yr_tttg target11 if mpday & gmxn30yr_tttg > -14
scatter gmxn30yr_tttg path11 if mpday & gmxn30yr_tttg > -14
scatter gmxn30yr_tttg target11 if mpday & gmxn30yr_tttg >= -14 || scatter gmxn30yr_tttg target11 if mpday & gmxn30yr_tttg < -14, mlabel(date) mcolor(red)
scatter gmxn30yr_tttg path11 if mpday & gmxn30yr_tttg >= -14 || scatter gmxn30yr_tttg path11 if mpday & gmxn30yr_tttg < -14, mlabel(date) mcolor(red)
rreg gmxn30yr_tttg target11 path11 if mpday
	// after removing 2 largest negative values, average 30Y value goes to zero & target11 effect decreases b/c associated w/the lowest target11 value
	// constant is no longer significant w/rreg (results for target11 & path11 robust)
	
foreach var in usdmxn gmxn02yr gmxn05yr gmxn10yr gmxn30yr {
	ttest `var'_tttg == 0 if mpday & date >= td(1jan2011)
}
// kdensity `var'_tttg if mpday, normal
ttest usdmxn_tttg == 0 if mpday & date >= td(1jan2011) & usdmxn_tttg > -86
	// only the mean for usdmxn is significantly different from zero, but changes when outliers excluded
	
* ------------------------------------------------------------------------------
* Regressions when variables <>1 SD and KBO decomposition
do "$pathcode/pq_sd_lp_fx"
do "$pathcode/pq_sd_lp_yc"
do "$pathcode/pq_sd_lp_flows"
do "$pathcode/pq_kbo_lp_fx"
do "$pathcode/pq_kbo_lp_yc"
do "$pathcode/pq_kbo_lp_flows"

* ------------------------------------------------------------------------------
* LP FX relationship with target and path surprises
scatter usdmxn_tttg path11 if date <= td(1nov2021) || scatter usdmxn_tttg path11 if date > td(1nov2021), mlabel(date)
scatter usdmxn_tttg target11 if date <= td(1nov2021) || scatter usdmxn_tttg target11 if date > td(1nov2021), mlabel(date)
// conditions for pq_lp_fx: if date < td(1nov2021); if !inlist(date,td(16dec2021),td(9feb2023),td(23jun2022))

* ------------------------------------------------------------------------------
* Structural break in FX
line usdmxn date, tline(1jan2011 30nov2014)
line wti date if tin(1nov2014,31dec2015), tline(30nov2014)
regress usdmxn_tttg target11 path11 if mpday, robust
rreg usdmxn_tttg target11 path11 if mpday
regress usdmxn_tttg target11 path11 if mpday & tin(1jan2011,30nov2014), robust
rreg usdmxn_tttg target11 path11 if mpday & tin(1jan2011,30nov2014)
regress usdmxn_tttg target11 path11 if mpday & tin(1dec2014,30jun2023), robust
rreg usdmxn_tttg target11 path11 if mpday & tin(1dec2014,30jun2023)
// 2011-2023 R2 = 0.32		// 2011-2014 R2 = 0.47		// 2014-2023 R2 = 0.61		// results robust after split
generate idx14 = (date>=td(1dec2014))
regress usdmxn_tttg target11 path11 idx14#c.target11 idx14#c.path11 idx14 if mpday, robust // change in intercept and slope
regress usdmxn_tttg target11 path11 idx14#c.target11 idx14#c.path11 idx14 if mpday & date != td(30jun2016), robust // remove one date
regress usdmxn_ttdm target00_ttdm path00_ttdm idx14#c.target00_ttdm idx14#c.path00_ttdm idx14 if mpday & date > td(1jan2011), robust // daily changes
regress usdmxn_ttdm target00_ttdm path00_ttdm if mpday & tin(1jan2011,30nov2014), robust	// daily changes 2011-2014
regress usdmxn_ttdm target00_ttdm path00_ttdm if mpday & date > td(1dec2014), robust		// daily changes 2014-2023
scatter usdmxn_tttg target11 if mpday & tin(1jan2011,30nov2014) || scatter usdmxn_tttg target11 if mpday & tin(1dec2014,30jun2023), mcolor(red)
scatter usdmxn_tttg path11 if mpday & tin(1jan2011,30nov2014) || scatter usdmxn_tttg path11 if mpday & tin(1dec2014,30jun2023), mcolor(red)
scatter path11 target11 if mpday & tin(1jan2011,30nov2014) || scatter path11 target11 if mpday & tin(1dec2014,30jun2023), mcolor(red)
scatter path11 target11 if mpday & tin(1jan2011,30nov2014) & target11 > -14 || scatter path11 target11 if mpday & tin(1dec2014,30jun2023) & target11 > -14, mcolor(red)
line mxonbr_ttdy date, tline(1jan2011 30nov2014)
summ target11 path11 if mpday & tin(1jan2011,30nov2014)
summ target11 path11 if mpday & tin(1jan2011,30nov2014) & target11 > -14
summ target11 path11 if mpday & tin(1dec2014,30jun2023) // wider range in target after 2014 (excl. 3 cases)
// Before nov2014, FX responded more to path suprises. Afterwards, it became more responsive to target surprises

* ------------------------------------------------------------------------------
* Structural break in FX
local shocks target11 path11
foreach var in gmxn02yr gmxn05yr gmxn10yr gmxn30yr {
	foreach k in 1 2 {
		if `k' == 1 local condit if mpday & tin(1jan2011,7nov2016)
		if `k' == 2 local condit if mpday & tin(8nov2016,30jun2023)
	
		regress `var'_tttg `shocks' `condit', robust
		rreg `var'_tttg `shocks' `condit'
	}
}

* ------------------------------------------------------------------------------
* Structural breaks in flows
line ctsdomestic ctsforeigners date, tline(1jan2011 30mar2016 28feb2019)
line bnddomestic bndforeigners date, tline(1jan2011 28feb2019)
line ctsdomestic ctsforeigners bnddomestic bndforeigners date, tline(1jan2011 30mar2016 28feb2019)
line udiforeigners date, tline(1jan2011 30mar2013 30mar2016 28feb2019)