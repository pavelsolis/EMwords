# [Do Central Bank Words Matter in Emerging Markets? Evidence from Mexico](https://www.sciencedirect.com/science/article/pii/S0164070423000708)

by Pavel Solís (pavel.solis@gmail.com)


## System Features
The results in the paper were generated using the following:
- Operating systems: macOS 12.2.1, Windows 10 Enterprise
- Software: Matlab R2019a, Stata 17
- Add-ons. Matlab: statistics toolbox. Stata: scheme-modern, grc1leg2, xtbreak
- Restricted data sources: Bloomberg
- Expected running time: ~6 hrs 47 min


## Contents of Folder
README.md (this file)
- Codes folder with the following subfolder:
	- Analysis: replication codes
- Data folder with the following subfolder:
	- Analytic: analysis dataset
- Docs folder with the following subfolders:
	- Paper folder: files that make up the manuscript
	- Figures folder: files with the figures
	- References folder: .bib file with cited references


## Dataset
With the following exceptions, the variables in the dataset represent (percent) changes (\* is a wildcard):
- date\* contain dates
- idx\* are binary variables
- level\* report end-of-day values

The following variables report intraday (percent) changes in 30-min windows:
- gmxn\*yr, mpsw28t, mpswc, trm\*, usdmxn

Some variables use the following suffixes:
- _ttwd for intraday (percent) changes in 50-min windows
- _ttdm for daily (percent) changes

Some variables can be identified as follows:
- id: intraday values
- dy: daily end-of-day values
- dc: daily (percent) changes
- mp: monetary policy (MP) announcement days and times
- ca: calendar of macroeconomic releases on MP announcement days
- evr: macro events (and their relevance) released on same days of MP announcements
- frq: frequency with which macro events coincide with MP announcements
- ov: macro events released on the same day *and* time of an MP announcement
- im: intraday values on MP announcement days
- dm: daily (percent) changes on MP announcement days
- tg: intraday (percent) changes in 30-min windows around MP announcements
- wd: intraday (percent) changes in 50-min windows around MP announcements


## Instructions for Replication
Execute the pq_analysis.do and the pqm_analysis.m files to replicate the results in the paper

Execute the paper.tex file to generate the PDF version of the manuscript
