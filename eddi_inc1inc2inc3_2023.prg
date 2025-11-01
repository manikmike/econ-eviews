'This program extracts disability "In-Current-Pay" (DICP) data and disability-insured (DINS) data from excel spreadsheets and transfers them to the databanks op1xx1r.bnk, op1xx2r.bnk and op1xx3r.bnk (i.e., the "raw" banks), where "xx" is the last 2 digits of the year of the most recently published TR. 
'The original ICP data is separated into historical and short-range projected data (both received from David Olson), and long-range projected data (received from Johanna Maleh). The original DINS data comes from Katie Sutton.
'After transferring the data into the raw banks, we need to run another program, updibk.prg, to create concepts that we use in our modeling, most notably ratios of DICP to DINS, and store them in the operational databanks: op1221o.bnk, op1222o.bnk, op1223o.bnk. 

'%perend = "2100" 
%username = @env("username")
%filename1 = """C:\Users\" + %username + "\GitRepos\econ-eviews\Disability ICP_LR_for OP122_inc1inc2inc3.xlsx"""
%filename2 = """C:\Users\" + %username + "\GitRepos\econ-eviews\Disability Insured ALT 1, ALT 2, ALT 3 for OP122.xlsx"""

exec .\setup2

logmode logmsg

' Assign year of Trustees Report which corresponds to disability workfile name
!tr = 122

pageselect a
for %s m f
   for !a = 15 to 66
     %p{%s}dicp = %p{%s}dicp + "p" + %s + @str(!a) + "dicp " 
   next
next   

'HISTORICAL ICP

logmsg importing historical ICP data from Excel file

import(mode="u") {%filename1} range=Hist&SR.inc1!$BD$3:$CX$54 byrow names=%pmdicp @smpl 1975 2021
show {%pmdicp}
                                                                                                                                                                                                                                                                                                                                         
import(mode="u") {%filename1} range=Hist&SR.inc1!$BD$65:$CX$116 byrow names=%pfdicp @smpl 1975 2021
show {%pfdicp}
                                                                                                                                                                                    
'Putting historical ICP data into workfiles op1221r_inc1inc2inc3.wf1, op1222r_inc1inc2inc3.wf1, op1223r_inc1inc2inc3.wf1
'ALTs I,II, and III

for !i = 1 to 3

   logmsg Entering historical ICP data into op{!tr}{!i}r_inc1inc2inc3
   db(type=aremos) op{!tr}{!i}r_inc1inc2inc3
store *
close @wf
next
logmsg
logmsg Historical ICP data SAVED to all 3 op122xr (raw) workfiles

'Putting PROJECTED ICP data into op workfiless.

'First, Alt 1 projections...
'ALT1 ICP SHORT-RANGE - IMPORT

logmsg pulling Alt 1 short-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=Hist&SR.inc1!$CY$3:$DH$54 byrow names=%pmdicp @smpl 2022 2031
show {%pmdicp}

import(mode="u") {%filename1} range=Hist&SR.inc1!$CY$65:$DH$116 byrow names=%pfdicp @smpl 2022 2031
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 1 SR projected ICP data

'ALT1 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 1 long-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=ALT1inc1!$BM$4:$EC$55 byrow names=%pmdicp @smpl 2032 2100
show {%pmdicp}

import(mode="u") {%filename1} range=ALT1inc1!$BM$78:$EC$129 byrow names=%pfdicp @smpl 2032 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 1 LR projected ICP data

'ALT1 - ICP SR and LR DATA LOADED INTO OP1221r_inc1inc2inc3 WORKFILE
logmsg Entering ALT1 ICP SR and LR data into op1221r_inc1inc2inc3
wfopen op1221r_inc1inc2inc3.wf1
wfselect work
wfsave(2) op1221r_inc1inc2inc3.wf1
close @wf

logmsg
logmsg All Alt 1 ICP projected data loaded into raw workfile


'Next, Alt 2 projections...
'ALT2 ICP SHORT-RANGE - IMPORT
logmsg Starting Alt 2 now
logmsg pulling Alt 2 short-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=Hist&SR.inc2!$CY$3:$DH$54 byrow names=%pmdicp @smpl 2022 2031
show {%pmdicp}

import(mode="u") {%filename1} range=Hist&SR.inc2!$CY$65:$DH$116 byrow names=%pfdicp @smpl 2022 2031
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 2 SR projected ICP data

'ALT2 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 2 long-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=ALT2inc2!$BM$4:$EC$55 byrow names=%pmdicp @smpl 2032 2100
show {%pmdicp}

import(mode="u") {%filename1} range=ALT2inc2!$BM$78:$EC$129 byrow names=%pfdicp @smpl 2032 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 2 LR projected ICP data

'ALT2 - ICP SR and LR DATA LOADED INTO OP1222r workfile
logmsg Entering ALT2 ICP SR and LR data into op1222r_inc1inc2inc3
wfopen op1222r_inc1inc2inc3.wf1
wfselect work
wfsave(2) op1222r_inc1inc2inc3.wf1
close @wf

logmsg
logmsg All Alt 2 ICP projected data loaded into raw databank


'Last, Alt 3 projections...
'ALT3 ICP SHORT-RANGE - IMPORT

logmsg Starting Alt 3 now
logmsg pulling Alt 3 short-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=Hist&SR.inc3!$CY$3:$DH$54 byrow names=%pmdicp @smpl 2022 2031
show {%pmdicp}

import(mode="u") {%filename1} range=Hist&SR.inc3!$CY$65:$DH$116 byrow names=%pfdicp @smpl 2022 2031
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 3 SR projected ICP data

'ALT3 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 3 long-range projected ICP data from Excel file 

import(mode="u") {%filename1} range=ALT3inc3!$BM$4:$EC$55 byrow names=%pmdicp @smpl 2032 2100
show {%pmdicp}

import(mode="u") {%filename1} range=ALT3inc3!$BM$78:$EC$129 byrow names=%pfdicp @smpl 2032 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 3 LR projected ICP data

'ALT3 - ICP SR and LR DATA LOADED INTO OP1223dr (raw) WORKFILE
logmsg Entering ALT3 ICP data into op1223r_inc1inc2inc3
wfopen op1223r_inc1inc2inc3.wf1
wfselect work
wfsave(2) op1223r_inc1inc2inc3.wf1
close @wf

'%perend = "2099"
exec .\setup2

logmsg

logmsg All Alt 3 ICP projected data loaded into raw workfile

logmsg  All ICP Data loaded into op122xr (raw) databanks - All  3 Alts

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

import(mode="u") {%filename2} range=ALT1!$B$4:$BB$58 byrow names=%pmdins @smpl 1969 2021
show {%pmdins}

import(mode="u") {%filename2} range=ALT1!$B$63:$BB$117 byrow names=%pfdins @smpl 1969 2021
show {%pfdins}

logmsg
logmsg Historical Data imported


'HISTORICAL INS DATA LOADED INTO OP122xr WORKFILE
'Putting historical data into workfiles op1221r_inc1inc2inc3.wf1, op1222r_inc1inc2inc3.wf1, op1223r_inc1inc2inc3.wf1
'ALTs I,II, and III

for !i = 1 to 3

logmsg Entering historical INS data into op{!tr}{!i}r_inc1inc2inc3
dbopen(type=aremos) op{!tr}{!i}r_inc1inc2inc3
store *
close @db
next

logmsg
logmsg Historical INS data loaded into all 3 op122xr databanks


'Next, Alt 1 INS projections...
'ALT1 PROJECTED INS - IMPORT

logmsg importing Alt 1 projected INS data from Excel file 

import(mode="u") {%filename2} range=ALT1!$BC4:$EC$58 byrow names=%pmdins @smpl 2022 2100
show {%pmdins}

import(mode="u") {%filename2} range=ALT1!$BC63:$EC$117 byrow names=%pfdins @smpl 2022 2100
show {%pfdins}

logmsg
logmsg Alt 1 projected INS data imported


'ALT1 - PROJECTED INS DATA LOADED INTO OP1221r DATABANK
logmsg Entering ALT1 INS data into op1221r_inc1inc2inc3
dbopen(type=aremos) op1221r_inc1inc2inc3
store *
close @db

logmsg
logmsg Alt 1 INS projected data loaded into op1221r databank


'Next, Alt 2 INS projections...
'ALT2 PROJECTED INS - IMPORT

logmsg importing Alt 2 projected INS data from Excel file 

import(mode="u") {%filename2} range=ALT2!$BC4:$EC$58 byrow names=%pmdins @smpl 2022 2100
show {%pmdins}

import(mode="u") {%filename2} range=ALT2!$BC62:$EC$116 byrow names=%pfdins @smpl 2022 2100
show {%pfdins}

logmsg
logmsg Alt 2 projected INS data imported


'ALT2 - PROJECTED INS DATA LOADED INTO OP1222r DATABANK
logmsg Entering ALT2 INS data into op1222r_inc1inc2inc3
dbopen(type=aremos) op1222r_inc1inc2inc3
store *
close @db


logmsg
logmsg Alt 2 INS projected data loaded into op1222r_inc1inc2inc3 databank


'Next, Alt 3 INS projections...
'ALT3 PROJECTED INS - IMPORT

logmsg importing Alt 3 projected INS data from Excel file 

import(mode="u") {%filename2} range=ALT3!$BC4:$EC$58 byrow names=%pmdins @smpl 2022 2100
show {%pmdins}

import(mode="u") {%filename2} range=ALT3!$BC63:$EC$117 byrow names=%pfdins @smpl 2022 2100
show {%pfdins}

logmsg
logmsg Alt 3 projected INS data imported


'ALT3 - PROJECTED INS DATA LOADED INTO OP1223r DATABANK
logmsg Entering ALT3 INS data into op1223r_inc1inc2inc3
dbopen(type=aremos) op1223r_inc1inc2inc3
store *
close @db


logmsg
logmsg Alt 3 INS projected data loaded into op1223r_inc1inc2inc3 databank
logmsg  All INS Data loaded into op122xr databanks - All  3 Alts


