'This program extracts disability "In-Current-Pay" (DICP) data and disability-insured (DINS) data from excel spreadsheets and transfers them to the datafiles op1xx1r.wf1, op1xx2r.wf1 and op1xx3r.wf1 (i.e., the "raw" datafiles), where "xx" is the last 2 digits of the year of the most recently published TR. 
'The original ICP data is separated into historical and short-range projected data (both received from David Olson), and long-range projected data (received from Johanna Maleh). The original DINS data comes from Katie Sutton.
'After transferring the data into the raw banks, we need to run another program, updibk.prg, to create concepts that we use in our modeling, most notably ratios of DICP to DINS, and store them in the operational datafiles: op1241o.wf1, op1242o.wf1, op1243o.wf1. 

'9-19-24: This version is modified for the Prior Relevant Work (PRW) analysis, which uses di-icp data modified to refect the June 2024 change in regulation that presumably makes it easier on the margin for disability claims to be approved. 
'The projected ICP data under the PRW regulation replaces the Alt2 projection from tr24 final, and the code below is modified to use the PRW data in place of tr24 Alt2 data.  
'11-4-24: This version is further modified to use PRW-modified ICP data for all three alts.


'%perend = "2100"
'Store user name in variable.
'%usrnm = @env("715256")
'Set up temporary workfile.

exec C:\Users\715256\GitRepos\econ-eviews\setup2

logmode logmsg

'Assign year of Trustees Report.
!tr = 124

pageselect a
for %s m f
   for !a = 15 to 66
     %p{%s}dicp = %p{%s}dicp + "p" + %s + @str(!a) + "dicp " 
   next
next   

'HISTORICAL ICP

logmsg importing historical ICP data from Excel file

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=HISTORICAL!$B$5:$AX$56 byrow names=%pmdicp @smpl 1975 2023
show {%pmdicp}
                                                                                                                                                                                                                                                                                                                                         
import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=HISTORICAL!$B$61:$AX$112 byrow names=%pfdicp @smpl 1975 2023
show {%pfdicp}
                                                                                                                                                                                  
'Putting historical ICP data into datafiles op1241r_prw.wf1, op1242r.wf1_prw, op1243r_prw.wf1
'ALTs I,II, and III

for !i = 1 to 3

logmsg Entering historical ICP data into op{!tr}{!i}r_prw
wfopen op{!tr}{!i}r_prw + ".wf1"
wfselect work
pageselect a
copy * op{!tr}{!i}r_prw::a\*
wfselect op{!tr}{!i}r_prw
wfsave(2) op{!tr}{!i}r_prw
close op{!tr}{!i}r_prw

next
logmsg
logmsg Historical ICP data SAVED to all 3 op124xr_prw (raw) workfiles

'Putting PROJECTED ICP data into op workfiles.

'First, Alt 1 projections...
'ALT1 ICP SHORT-RANGE - IMPORT

logmsg pulling Alt 1 short-range projected ICP data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=ALT1PRW!$AZ$135:$BI$186 byrow names=%pmdicp @smpl 2024 2033
show {%pmdicp}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=ALT1PRW!$AZ$191:$BI$242 byrow names=%pfdicp @smpl 2024 2033
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 1 SR projected ICP data

'ALT1 ICP LONG-RANGE - IMPORT
logmsg pulling Alt 1 long-range projected ICP data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability ICP_LR_for OP124_PRW.xlsx" range=ALT1PRW!$BM$4:$EA$55 byrow names=%pmdicp @smpl 2034 2100
show {%pmdicp}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability ICP_LR_for OP124_PRW.xlsx" range=ALT1PRW!$BM$76:$EA$127 byrow names=%pfdicp @smpl 2034 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt 1 LR projected ICP data

'ALT1 - ICP SR and LR DATA LOADED INTO OP1241r_prw WORKFILE
logmsg Entering ALT1PRW ICP SR and LR data into op1241r_prw
wfopen op1241r_prw 'open the workfile we want to write to
wfselect work 'select the already existing, temporary "working" workfile, where the pulled data is residing at the moment
pageselect a 'select the annual page in the working workfile, because this is annual data
copy * op1241r_prw::a\* 'copy everything in the working workfile to the op workfile's annual page, keep all series names the same
wfselect op1241r_prw 'select the op workfile to be saved in the next step (this line is possible overkill)
wfsave(2) op1241r_prw 'save the op workfile
close op1241r_prw 'close the op workfile

logmsg
logmsg All Alt 1 ICP projected data loaded into raw workfile

'Next, Alt 2 (PRW) projections...
'ALT2PRW ICP SHORT-RANGE - IMPORT
logmsg Starting ALT2PRW now
logmsg pulling ALT2PRW short-range projected ICP data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=ALT2PRW!$AZ$143:$BI$194 byrow names=%pmdicp @smpl 2024 2033
show {%pmdicp}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=ALT2PRW!$AZ$199:$BI$250 byrow names=%pfdicp @smpl 2024 2033
show {%pfdicp}

logmsg
logmsg Finished pulling ALT2PRW SR projected ICP data

'ALT2/PRW ICP LONG-RANGE - IMPORT
logmsg pulling ALT2PRW long-range projected ICP data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability ICP_LR_for OP124_PRW.xlsx" range=ALT2PRW!$BN$4:$EB$55 byrow names=%pmdicp @smpl 2034 2100
show {%pmdicp}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability ICP_LR_for OP124_PRW.xlsx" range=ALT2PRW!$BN$74:$EB$125 byrow names=%pfdicp @smpl 2034 2100
show {%pfdicp}

logmsg
logmsg Finished pulling ALT2PRW LR projected ICP data

'ALT2/PRW - ICP SR and LR DATA LOADED INTO OP1242r_prw WORKFILE
logmsg Entering ALT2PRW ICP SR and LR data into op1242r_prw

wfopen op1242r_prw
wfselect work
pageselect a
copy * op1242r_prw::a\*
wfselect op1242r_prw
wfsave(2) op1242r_prw
close op1242r_prw

logmsg
logmsg All ALT2PRW ICP projected data loaded into raw workfile


'Last, Alt 3 projections...
'ALT3 ICP SHORT-RANGE - IMPORT

logmsg Starting Alt3PRW now
logmsg pulling Alt3PRW short-range projected ICP data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=ALT3PRW!$AZ$135:$BI$186 byrow names=%pmdicp @smpl 2024 2033
show {%pmdicp}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Short-range\Historical & Short-Range DIB's ICP by single year of age for OP124 banks_PRW.xlsx" range=ALT3PRW!$AZ$191:$BI$242 byrow names=%pfdicp @smpl 2024 2033
show {%pfdicp}

logmsg
logmsg Finished pulling Alt3PRW SR projected ICP data

'ALT3 ICP LONG-RANGE - IMPORT
logmsg pulling Alt3PRW long-range projected ICP data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability ICP_LR_for OP124_PRW.xlsx" range=ALT3PRW!$BM$4:$EA$55 byrow names=%pmdicp @smpl 2034 2100
show {%pmdicp}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability ICP_LR_for OP124_PRW.xlsx" range=ALT3PRW!$BM$76:$EA$127 byrow names=%pfdicp @smpl 2034 2100
show {%pfdicp}

logmsg
logmsg Finished pulling Alt3PRW LR projected ICP data

'ALT3 - ICP SR and LR DATA LOADED INTO OP1243r_prw (raw) WORKFILE
logmsg Entering ALT3 ICP data into op1243r_prw
wfopen op1243r_prw
wfselect work
pageselect a
copy * op1243r_prw::a\*
wfselect op1243r_prw
wfsave(2) op1243r_prw
close op1243r_prw

logmsg

logmsg All Alt3PRW ICP projected data loaded into raw workfile

logmsg  All PRW ICP Data loaded into op124xr_prw (raw) workfiles - All Alts
delete *

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

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT1!$B$4:$BD$58 byrow names=%pmdins @smpl 1969 2023
show {%pmdins}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT1!$B$63:$BD$117 byrow names=%pfdins @smpl 1969 2023
show {%pfdins}

logmsg
logmsg Historical INS Data imported


'HISTORICAL INS DATA LOADED INTO OP123xr_prw WORKFILES
'Putting historical INS data into workfiles op1241r_prw.wf1, op1242_prw.wf1, op1243r_prw.wf1
'ALTs I,II, and III

for !i = 1 to 3

logmsg Entering historical INS data into op{!tr}{!i}r_prw
wfopen op{!tr}{!i}r_prw + ".wf1"
wfselect work
pageselect a
copy * op{!tr}{!i}r_prw::a\*
wfselect op{!tr}{!i}r_prw
wfsave(2) op{!tr}{!i}r_prw
close op{!tr}{!i}r_prw
next

logmsg
logmsg Historical INS data loaded into all 3 op124xr_prw workfiles


'Next, Alt 1 INS projections...
'ALT1 PROJECTED INS - IMPORT

logmsg importing Alt 1 projected INS data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT1!$BE4:$EC$58 byrow names=%pmdins @smpl 2024 2100
show {%pmdins}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT1!$BE63:$EC$117 byrow names=%pfdins @smpl 2024 2100
show {%pfdins}

logmsg
logmsg Alt 1 projected INS data imported


'ALT1 - PROJECTED INS DATA LOADED INTO OP1241r_prw WORKFILE
logmsg Entering ALT1 INS data into op1241r_prw
wfopen op1241r_prw
wfselect work
pageselect a
copy * op1241r_prw::a\*
wfselect op1241r_prw
wfsave(2) op1241r_prw
close op1241r_prw

logmsg
logmsg Alt 1 INS projected data loaded into op1241r workfile


'Next, Alt 2 INS projections...
'ALT2 PROJECTED INS - IMPORT

logmsg importing Alt 2 projected INS data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT2!$BE4:$EC$58 byrow names=%pmdins @smpl 2024 2100
show {%pmdins}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT2!$BE62:$EC$116 byrow names=%pfdins @smpl 2024 2100
show {%pfdins}

logmsg
logmsg Alt 2 projected INS data imported


'ALT2 - PROJECTED INS DATA LOADED INTO OP1242r_prw WORKFILE
logmsg Entering ALT2 INS data into op1242r_prw
wfopen op1242r_prw
wfselect work
pageselect a
copy * op1242r_prw::a\*
wfselect op1242r_prw
wfsave(2) op1242r_prw
close op1242r_prw

logmsg
logmsg Alt 2 INS projected data loaded into op1242r_prw workfile


'Next, Alt 3 INS projections...
'ALT3 PROJECTED INS - IMPORT

logmsg importing Alt 3 projected INS data from Excel file 

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT3!$BE4:$EC$58 byrow names=%pmdins @smpl 2024 2100
show {%pmdins}

import(mode="u") "T:\LRECON\Data\Processed\Disability\Long-range\Disability Insured ALT 1, ALT 2, ALT 3 for OP124.xlsx" range=ALT3!$BE63:$EC$117 byrow names=%pfdins @smpl 2024 2100
show {%pfdins}

logmsg
logmsg Alt 3 projected INS data imported


'ALT3 - PROJECTED INS DATA LOADED INTO OP1243r_prw WORKFILE
logmsg Entering ALT3 INS data into op1243r_prw
wfopen op1243r_prw
wfselect work
pageselect a
copy * op1243r_prw::a\*
wfselect op1243r_prw
wfsave(2) op1243r_prw
close op1243r_prw

logmsg
logmsg Alt 3 INS projected data loaded into op1243r_prw workfile
logmsg
logmsg  All INS Data loaded into op124xr_prw workfiles - All Alts


