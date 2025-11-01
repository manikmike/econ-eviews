 'This program extracts Replacement Rate data from excel spreadsheets and transfers them to the workfiles op1xx1r.wf1, op1xx2r.wf1 and op1xx3r.wf1, 
 'where "xx" is the last 2 digits of the year of the most recently published TR. 
 'The original data is received from Kyle Burkhalter. We get the data for each alternative scenario, including historical and projected to the end of the LR period.
'Data represents SSA Replacement Rates as of January 1 
'i.e., Reprate in year t is the ratio of PIA in year t to wage in year t-1. PIA is the monthly benefit a person would receive if they retired at the normal retirement age.
' Note:  Male replacement rates and female replacement rates are equal after 1972.  
'Prior to 1972, for people born in 1912 and earlier, benefit computations were based on age 65 for men and age 62 for women.
'Updated this program to use EViews workfiles (example: OP1XX1R.WF1) rather than Aremos databanks (example: OP1XX1R.BNK).-BLH 8/22/23
'Updated program to use op workfiles from tr24 (found in econ-ecodev/dat repo)- BLH 6/24/24

exec .\setup2

logmode logmsg

' Assign year of most recently published Trustees Report.
!tr = 124

pageselect a
for %s m f
   for !a = 62 to 70
     %reprate{%s}pia = %reprate{%s}pia + "reprate" + %s + @str(!a) + "pia " 
   next
next


'Putting Replacement Rate data into op workfiles.

'First, Alt 1...
'Import ALT1 PIA-based Rep rates

logmsg importing Alt 1 reprate data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\ReplacementRates\reprate_pia_2024_update.xlsx" range=AllAltsFinal!$D$2:$FH$10 byrow names=%repratempia @smpl 1940 2100
'show {%repratempia}

import(mode="u") "T:\LRECON\Data\Processed\ReplacementRates\reprate_pia_2024_update.xlsx" range=AllAltsFinal!$D$29:$FH$37 byrow names=%repratefpia  @smpl 1940 2100
'show {%repratefpia}

logmsg
logmsg Finished importing Alt1 reprate data.

'ALT1 REPRATE DATA LOADED INTO OP1241r WORKFILE
logmsg Entering ALT1 reprate data into op1241r
wfopen op1241r 'open the workfile we want to write to
wfselect work 'select the already existing, temporary "working" workfile (created by 'setup2'), where the pulled data is residing at the moment
pageselect a 'select the annual page in the working workfile, because this is annual data
copy * op1241r::a\* 'copy everything in the working workfile to the op workfile's annual page, keep all series names the same
wfselect op1241r 'select the op workfile to be saved in the next step (this line is possible overkill)
wfsave(2) op1241r 'save the op workfile
close op1241r 'close the op workfile
logmsg
logmsg Alt 1 reprate data loaded into op1241r workfile


'Next, Alt 2 projections...
'ALT2 PIA-based Rep rates - IMPORT
logmsg 
logmsg importing Alt 2 reprate data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\ReplacementRates\reprate_pia_2024_update.xlsx" range=AllAltsFinal!$D$11:$FH$19 byrow names=%repratempia @smpl 1940 2100
'show {%repratempia}

import(mode="u") "T:\LRECON\Data\Processed\ReplacementRates\reprate_pia_2024_update.xlsx" range=AllAltsFinal!$D$38:$FH$46 byrow names=%repratefpia  @smpl 1940 2100
'show {%repratefpia}

logmsg
logmsg Finished importing Alt2 reprate data.


'ALT2 REPRATE DATA LOADED INTO OP1242r WORKFILE
logmsg Entering ALT2 reprate data into op1242r
wfopen op1242r
wfselect work
pageselect a
copy * op1242r::a\*
wfselect op1242r
wfsave(2) op1242r
close op1242r

logmsg
logmsg Alt 2 reprate data loaded into op1242r workfile


'Last, Alt 3 projections...
'ALT3 PIA-based Rep rates - IMPORT

logmsg Starting Alt 3 now
logmsg importing Alt 3 reprate data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\ReplacementRates\reprate_pia_2024_update.xlsx" range=AllAltsFinal!$D$20:$FH$28 byrow names=%repratempia @smpl 1940 2100
'show {%repratempia}

import(mode="u") "T:\LRECON\Data\Processed\ReplacementRates\reprate_pia_2024_update.xlsx" range=AllAltsFinal!$D$47:$FH$55 byrow names=%repratefpia  @smpl 1940 2100
'show {%repratefpia}

logmsg
logmsg Finished importing Alt 3 reprate data.


'ALT3 REPRATE DATA LOADED INTO OP1243r WORKFILE
logmsg Entering ALT3 reprate data into op1243r
wfopen op1243r
wfselect work
pageselect a
copy * op1243r::a\*
wfselect op1243r
wfsave(2) op1243r
close op1243r 

logmsg
logmsg Alt 3 reprate data loaded into op1243r workfile


