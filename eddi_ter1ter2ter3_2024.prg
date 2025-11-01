'This program extracts disability "In-Current-Pay" (DICP) data and disability-insured (DINS) data from excel spreadsheets and transfers them to the databanks op1xx1r.bnk, op1xx2r.bnk and op1xx3r.bnk (i.e., the "raw" banks), where "xx" is the last 2 digits of the year of the most recently published TR. 
'The original ICP data is separated into historical and short-range projected data (both received from David Olson), and long-range projected data (received from Johanna Maleh). The original DINS data comes from Katie Sutton.
'After transferring the data into the raw banks, we need to run another program, updibk.prg, to create concepts that we use in our modeling, most notably ratios of DICP to DINS, and store them in the operational databanks: op1221o.bnk, op1222o.bnk, op1223o.bnk. 

'%perend = "2100" 
%username = @env("username")
%filename1 = """C:\Users\" + %username + "\GitRepos\econ-eviews\Disability ICP_LR_for OP123_ter1ter2ter3.xlsx"""
%filename2 = """C:\Users\" + %username + "\GitRepos\econ-eviews\Disability Insured ALT 1, ALT 2, ALT 3 for OP123.xlsx"""

exec .\setup2

logmode logmsg

' Assign year of Trustees Report which corresponds to disability workfile name - for tr24, this would be 123. This refers to the OP123xr workfile...
!tr = 123

pageselect a
for %s m f
   for !a = 15 to 66
     %p{%s}dicp = %p{%s}dicp + "p" + %s + @str(!a) + "dicp " 
   next
next   

'HISTORICAL ICP

logmsg importing historical ICP data from Excel file

import(mode="u") {%filename1} range=Hist&SR.ter1!$BD$3:$CY$54 byrow names=%pmdicp @smpl 1975 2022
show {%pmdicp}
                                                                                                                                                                                                                                                                                                                                         
import(mode="u") {%filename1} range=Hist&SR.ter1!$BD$65:$CY$116 byrow names=%pfdicp @smpl 1975 2022
show {%pfdicp}
                                                                                                                                                                                    
'Putting historical ICP data into workfiles op1231r_ter1ter2ter3.wf1, op1232r_ter1ter2ter3.wf1, op1233r_ter1ter2ter3.wf1
'ALTs I,II, and III

for !i = 1 to 3

logmsg Entering historical ICP data into op{!tr}{!i}r_ter1ter2ter3
wfopen op{!tr}{!i}r_ter1ter2ter3 
wfselect work
pageselect a
copy * op{!tr}{!i}r_ter1ter2ter3::a\*
wfselect op{!tr}{!i}r_ter1ter2ter3
wfsave(2) op{!tr}{!i}r_ter1ter2ter3
close op{!tr}{!i}r_ter1ter2ter3

next
logmsg
logmsg Historical ICP data SAVED to all 3 op123xr__ter1ter2ter3 (raw) workfiles

'Putting PROJECTED ICP data into op workfiles.

'First, Alt 1 projections...
'ALT1 ICP SHORT-RANGE - IMPORT

logmsg pulling Alt 1 short-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=Hist&SR.ter1!$CZ$3:$DI$54 byrow names=%pmdicp @smpl 2023 2032
show {%pmdicp}

import(mode="u") {%filename1} range=Hist&SR.ter1!$CZ$65:$DI$116 byrow names=%pfdicp @smpl 2023 2032
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 1 SR projected ICP data

'ALT1 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 1 long-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=ALT1ter1!$BD$4:$DS$55 byrow names=%pmdicp @smpl 2033 2100
show {%pmdicp}

import(mode="u") {%filename1} range=ALT1ter1!$BD$77:$DS$128 byrow names=%pfdicp @smpl 2033 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 1 LR projected ICP data

'ALT1 - ICP SR and LR DATA LOADED INTO OP1231r_ter1ter2ter3 WORKFILE
logmsg Entering ALT1 ICP SR and LR data into op1231r_ter1ter2ter3
wfopen op1231r_ter1ter2ter3.wf1
wfselect work
pageselect a
copy * op1231r_ter1ter2ter3::a\*
wfselect op1231r_ter1ter2ter3
wfsave(2) op1231r_ter1ter2ter3.wf1
close op1231r_ter1ter2ter3

delete *

logmsg
logmsg All Alt 1 ICP projected data loaded into raw workfile


'Next, Alt 2 projections...
'ALT2 ICP SHORT-RANGE - IMPORT
logmsg Starting Alt 2 now
logmsg pulling Alt 2 short-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=Hist&SR.ter2!$CZ$3:$DI$54 byrow names=%pmdicp @smpl 2023 2032
show {%pmdicp}

import(mode="u") {%filename1} range=Hist&SR.ter2!$CZ$65:$DI$116 byrow names=%pfdicp @smpl 2023 2032
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 2 SR projected ICP data

'ALT2 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 2 long-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=ALT2ter2!$BD$4:$DS$55 byrow names=%pmdicp @smpl 2033 2100
show {%pmdicp}

import(mode="u") {%filename1} range=ALT2ter2!$BD$78:$DS$129 byrow names=%pfdicp @smpl 2033 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 2 LR projected ICP data

'ALT2 - ICP SR and LR DATA LOADED INTO OP1232r_ter1ter2ter3 workfile
logmsg Entering ALT2 ICP SR and LR data into op1232r_ter1ter2ter3

wfopen op1232r_ter1ter2ter3.wf1
wfselect work
pageselect a
copy(m) * op1232r_ter1ter2ter3::a\*
wfselect op1232r_ter1ter2ter3
wfsave(2) op1232r_ter1ter2ter3.wf1
close op1232r_ter1ter2ter3

delete *

logmsg
logmsg All Alt 2 ICP projected data loaded into raw databank


'Last, Alt 3 projections...
'ALT3 ICP SHORT-RANGE - IMPORT

logmsg Starting Alt 3 now
logmsg pulling Alt 3 short-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=Hist&SR.ter3!$CZ$3:$DI$54 byrow names=%pmdicp @smpl 2023 2032
show {%pmdicp}

import(mode="u") {%filename1} range=Hist&SR.ter3!$CZ$65:$DI$116 byrow names=%pfdicp @smpl 2023 2032
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 3 SR projected ICP data

'ALT3 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 3 long-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=ALT3ter3!$BD$4:$DS$55 byrow names=%pmdicp @smpl 2033 2100
show {%pmdicp}

import(mode="u") {%filename1} range=ALT3ter3!$BD$79:$DS$130 byrow names=%pfdicp @smpl 2033 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 3 LR projected ICP data

'ALT3 - ICP SR and LR DATA LOADED INTO OP1233r_ter1ter2ter3 (raw) WORKFILE
logmsg Entering ALT3 ICP data into op1233r_ter1ter2ter3
wfopen op1233r_ter1ter2ter3.wf1
wfselect work
pageselect a
copy(m) * op1233r_ter1ter2ter3::a\*
wfselect op1233r_ter1ter2ter3
wfsave(2) op1233r_ter1ter2ter3.wf1
close op1233r_ter1ter2ter3

delete *

logmsg

logmsg All Alt 3 ICP projected data loaded into raw workfile

logmsg  All ICP Data loaded into op123xr_ter1ter2ter3 (raw) databanks - All  3 Alts

' Now working on Disability-Insured data, which are held in a different Excel file...
logmsg  starting import of Disability-Insured (INS) data...

for %s m f
   for !a = 15 to 69
     %p{%s}dins = %p{%s}dins + "p" + %s + @str(!a) + "dins " 
   next
next   

'First Historical INS data...

'Historical INS - IMPORT

logmsg importing Historical INS data from Excel file 

import(mode="u") {%filename2} range=ALT1!$B$4:$BC$58 byrow names=%pmdins @smpl 1969 2022
show {%pmdins}

import(mode="u") {%filename2} range=ALT1!$B$63:$BC$117 byrow names=%pfdins @smpl 1969 2022
show {%pfdins}

logmsg
logmsg Historical Data imported


'HISTORICAL INS DATA LOADED INTO OP123xr_ter1ter2ter3 WORKFILE
'Putting historical data into workfiles op1231r_ter1ter2ter3.wf1, op1232r_ter1ter2ter3.wf1, op1233r_ter1ter2ter3.wf1
'ALTs I,II, and III

for !i = 1 to 3

logmsg Entering historical INS data into op{!tr}{!i}r_ter1ter2ter3
wfopen op{!tr}{!i}r_ter1ter2ter3 + ".wf1"
wfselect work
pageselect a
copy * op{!tr}{!i}r_ter1ter2ter3::a\*
wfselect op{!tr}{!i}r_ter1ter2ter3
wfsave(2) op{!tr}{!i}r_ter1ter2ter3
close op{!tr}{!i}r_ter1ter2ter3
next

logmsg
logmsg Historical INS data loaded into all 3 op123xr_ter1ter2ter3 workfiles


'Next, Alt 1 INS projections...
'ALT1 PROJECTED INS - IMPORT

logmsg importing Alt 1 projected INS data from Excel file 

import(mode="u") {%filename2} range=ALT1!$BD4:$EC$58 byrow names=%pmdins @smpl 2023 2100
show {%pmdins}

import(mode="u") {%filename2} range=ALT1!$BD63:$EC$117 byrow names=%pfdins @smpl 2023 2100
show {%pfdins}

logmsg
logmsg Alt 1 projected INS data imported


'ALT1 - PROJECTED INS DATA LOADED INTO OP1231r_ter1ter2ter3 WORKFILE
logmsg Entering ALT1 INS data into op1231r_ter1ter2ter3
wfopen op1231r_ter1ter2ter3
wfselect work
pageselect a
copy * op1231r_ter1ter2ter3::a\*
wfselect op1231r_ter1ter2ter3
wfsave(2) op1231r_ter1ter2ter3
close op1231r_ter1ter2ter3

delete *

logmsg
logmsg Alt 1 INS projected data loaded into op1231r_ter1ter2ter3 workfile


'Next, Alt 2 INS projections...
'ALT2 PROJECTED INS - IMPORT

logmsg importing Alt 2 projected INS data from Excel file 

import(mode="u") {%filename2} range=ALT2!$BD4:$EC$58 byrow names=%pmdins @smpl 2023 2100
show {%pmdins}

import(mode="u") {%filename2} range=ALT2!$BD62:$EC$116 byrow names=%pfdins @smpl 2023 2100
show {%pfdins}

logmsg
logmsg Alt 2 projected INS data imported


'ALT2 - PROJECTED INS DATA LOADED INTO OP1232r_ter1ter2ter3 WORKFILE
logmsg Entering ALT2 INS data into op12232r_ter1ter2ter3
wfopen op1232r_ter1ter2ter3
wfselect work
pageselect a
copy(m) * op1232r_ter1ter2ter3::a\*
wfselect op1232r_ter1ter2ter3
wfsave(2) op1232r_ter1ter2ter3
close op1232r_ter1ter2ter3

delete *

logmsg
logmsg Alt 2 INS projected data loaded into op1232r_ter1ter2ter3 workfile


'Next, Alt 3 INS projections...
'ALT3 PROJECTED INS - IMPORT

logmsg importing Alt 3 projected INS data from Excel file 

import(mode="u") {%filename2} range=ALT3!$BD4:$EC$58 byrow names=%pmdins @smpl 2023 2100
show {%pmdins}

import(mode="u") {%filename2} range=ALT3!$BD63:$EC$117 byrow names=%pfdins @smpl 2023 2100
show {%pfdins}

logmsg
logmsg Alt 3 projected INS data imported


'ALT3 - PROJECTED INS DATA LOADED INTO OP1233r_ter1ter2ter3 WORKFILE
logmsg Entering ALT3 INS data into op1233r_ter1ter2ter3
wfopen op1233r_ter1ter2ter3
wfselect work
pageselect a
copy(m) * op1233r_ter1ter2ter3::a\*
wfselect op1233r_ter1ter2ter3
wfsave(2) op1233r_ter1ter2ter3
close op1233r_ter1ter2ter3

delete *

logmsg
logmsg Alt 3 INS projected data loaded into op1233r_ter1ter2ter3 workfile
logmsg
logmsg  All INS Data loaded into op123xr_ter1ter2ter3 workfiles - All  3 Alts


