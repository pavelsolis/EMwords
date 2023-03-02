use dataprsfxyc.dta, clear

* Compare different surprises: more difference b/w intraday and daily in path factor
graph matrix svyshkav target target_ttwd target_ttdm target04, half
graph matrix path path_ttwd path_ttdm path04, half

graph matrix target target_ttwd target_ttdm, half
graph matrix path path_ttwd path_ttdm, half

corr svyshkav mpswc target target_ttwd target_ttdm target04
corr path path_ttwd path_ttdm path04
		
gen byte regular  = !inlist(date,td(27apr2004),td(17feb2016),td(20mar2020),td(21apr2020)) & date < td(1dec2021)


ttest path04, by(sttmnts)
ttest path00, by(sttmnts)

browse date target_ttdm path_ttdm target04 path04 if nosttmnt
browse date target_ttdm path_ttdm target04 path04 if wsttmnt

* No particular difference b/w 2004-2005 decisions w/ and w/o statements
twoway (scatter path04 target04 if nosttmnt) (scatter path04 target04 if wsttmnt)
twoway (scatter abspath04 target04 if nosttmnt) (scatter abspath04 target04 if wsttmnt)
twoway (scatter path00 target00 if nosttmnt) (scatter path00 target00 if wsttmnt)
summ abspath04 if nosttmnt
summ abspath04 if wsttmnt
summ path04 if nosttmnt
summ path04 if wsttmnt
summ path00 if nosttmnt
summ path00 if wsttmnt

* Effects
foreach var of varlist usdmxn gmxn02yr gmxn05yr gmxn10yr gmxn30yr {
	reg `var' target path if regular, r
	reg `var' target_ttwd path_ttwd if regular, r
	reg `var' target_ttdm path_ttdm if regular, r
}

foreach var of varlist usdmxn gmxn02yr gmxn05yr gmxn10yr gmxn30yr {
	reg `var' target path if regular, r
	reg `var'_ttwd target_ttwd path_ttwd if regular, r
	reg `var'_ttdm target_ttdm path_ttdm if regular, r
}

use datapqmps2.dta, clear

* Explanation for no effect of path surprises on FX: small variation in intraday path, corrected with daily path
summ target11 path11 if mpday & date != td(11nov2021)
summ target_ttdm path_ttdm if mpday & date >= td(1jan2011) & date != td(11nov2021)

local controls l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx
regress usdmxn_tttg target11 path11 `controls' if mpday, robust
regress usdmxn_tttg target_ttdm path_ttdm `controls' if mpday & date >= td(1jan2011), robust
regress usdmxn_tttg target11 path_ttdm `controls' if mpday & date >= td(1jan2011), robust

local controls l.h15t10y l.vix l.embi l.wti l.tedsprd l.ticesprd l.cds5y ld.logmxmx
foreach var of varlist usdmxn_tttg gmxn02yr_tttg gmxn05yr_tttg gmxn10yr_tttg gmxn30yr_tttg {
	regress `var' target11 path11 `controls' if mpday, robust
}
