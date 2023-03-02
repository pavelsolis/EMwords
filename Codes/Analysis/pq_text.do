use $file_dta2, clear

* Correlations among intraday and daily Z1 and Z2
summ target04 target11 target_ttdm path04 path11 path_ttdm if mpday & date >= td(1jan2011)
pwcorr target04 target11 target_ttdm path04 path11 path_ttdm if mpday & date >= td(1jan2011), sig
// target = (0.9588+0.9997+0.9617)/3 = 0.973						// [reported]
// path = (0.6019+0.9534+0.6459)/3 = 0.733							// [reported]

* Correlations of Z1 and Z2 w/ PRS and Orthogonal 1Y-3M Swap
corr target11 mpswc_tttg if mpday									// [reported]

reg mpsw1a_tttg mpswc_tttg if mpday, r
predict mpswres1a_tttg if mpday, r
reg mpsw1a_ttdm mpswc_ttdm if mpday, r
predict mpswres1a_ttdm if mpday, r

corr mpswres1a_ttdm path_ttdm										// low b/c zeros in path_ttdm
corr mpswres1a_tttg path11											// low b/c
scatter mpswres1a_tttg path11, mlabel(date)							// 11nov2021 is an outlier
corr mpswres1a_ttdm path_ttdm if path_ttdm !=0						// remove zeros in path_ttdm
corr mpswres1a_tttg path11 if date != td(11nov2021)					// [reported] exclude 11nov2021
scatter mpswres1a_tttg path11 if date != td(11nov2021), mlabel(date)


use $file_dta2, clear

* Effect on Holdings of Bonos
summ bndpension bndforeigners if date > td(1jan2011) & date < td(1jan2022)	// used to report % of effect on holdings

reg path_ttwd path11 if mpday 
reg path_ttdm path11 if mpday 
