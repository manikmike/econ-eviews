' This program produces a series needed for the bkdr1 COW Check
' It produces a group that is ordered in a way consistent with the Excel spreadsheet
' The user must freeze that group, and then cut and paste the data into an excel spreadsheet.
' The Excel spreadsheet is TR20172 and TR20162 - Comparison of key earnings variables - 20170105.xlsm
' The Excel spreadsheet compares key earnings variables from TR16 to TR17 and notes differences between TRs and the reasons for differences
' Bob Weathers, 1-05-2017

' Update all entries at the start fo the program, up to the line  *** END of Update section ***

' Updated for 2021 TR by Sven Sinclair, 08-24-2021
' Updated for 2022 TR by Drew Sawyer, 05-29-2022
' Updated for 2023 TR by Polina Vlasenko, 03-02-2023; further updates are saved in Git repo econ-eviews

%TR = "25" 				' current TR year
%abankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\atr252.wf1" 	' location of the relevant A-bank
%abank = "atr252"
%yrlast = "2034" 	' last year for which to load data; usually, the end of SR for current TR

%TRpr = "24" 	' prior TR year
%abankpathpr = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul\atr242.wf1" 	' location of the relevant A-bank
%abankpr = "atr242"

%outputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\EconConsistencyChecks\" 	' location to save the resulting workfile to
' *** END of Update section ***

%wfname = "ck_avgearn" + %TR + "2"
%pg_cur = "atr" + %TR + "2data"
%pg_pr = "atr" + %TRpr + "2data"

wfcreate(wf={%wfname},page={%pg_pr}) a 2006 {%yrlast}
pagecreate(page={%pg_cur}) a 2006 {%yrlast}
pageselect {%pg_pr}
smpl @all

'Start wtih extending the series from TRprior one year
wfopen %abankpathpr 
pageselect a

for %ser aiw oasdi_tw oasdise_ti tcea e edmil eas enas wsd y wsca cse_tot cpiw_u acwa oasdi_merw
	copy {%abankpr}::a\{%ser} {%wfname}::{%pg_pr}\*
next
wfclose {%abankpr}

wfselect {%wfname}
pageselect {%pg_pr}
smpl @all

genr ate=(oasdi_tw+oasdise_ti-oasdi_merw)/tcea
genr ausearn=(wsd+y)/(e+edmil)
genr acovearn=(wsca+cse_tot)/tcea
genr ausws=wsd/(e-enas-eas+edmil)
genr tratio=(oasdi_tw+oasdise_ti)/(wsca+cse_tot)
group atr{%TRpr}2_avg aiw ate acwa ausearn acovearn ausws tratio cpiw_u


'Add the new TR22 series
wfselect {%wfname}
pageselect {%pg_cur}
smpl @all

wfopen %abankpath 
pageselect a

for %ser aiw oasdi_tw oasdise_ti tcea e edmil eas enas wsd y wsca cse_tot cpiw_u acwa oasdi_merw 
	copy {%abank}::a\{%ser} {%wfname}::{%pg_cur}\*
next
wfclose {%abank}

wfselect {%wfname}
pageselect {%pg_cur}
smpl @all

genr ate=(oasdi_tw+oasdise_ti-oasdi_merw)/tcea
genr ausearn=(wsd+y)/(e+edmil)
genr acovearn=(wsca+cse_tot)/tcea
genr ausws=wsd/(e-enas-eas+edmil)
genr tratio=(oasdi_tw+oasdise_ti)/(wsca+cse_tot)
group atr{%TR}2_avg aiw ate acwa ausearn acovearn ausws tratio cpiw_u


%save = %outputpath + %wfname + ".wf1"
wfsave(2) %save
'wfclose %wfname


