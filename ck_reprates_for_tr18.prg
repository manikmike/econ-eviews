' This program produces series needed for the check on replacement rates from the op1172o.bnk databank.
' In the initial econ modeling section for the new TR, the replacement rates used are those used in the last TR.
' This eViews program produces a data set of replacement rate variables that must be checked against the original Excel spreadsheet sent by Michael Clingman.
' The user must cut and paste from the resulting workfile into an excel spreadsheet to complete the check.
' The check is in an Excel file titled "RepRateCheck_forTR18.xlsx".
' RepRateCheck_forTR18.xlsx compares replacement rate variables from the databank op1172o.bnk to data received from Michael Clingman
' (via email in the Excel file "reprate_pia_2017_update.xlsx"). It notes any differences between data extracted from the op1172o.bnk databank 
' and the data in the original file from Michael Clingman.
' 

' 1. Update dbopen lines to point to the correct data
' 2. Update the wfcreate lines to identify the appropriate years for the data
' 3. Update the fetch, and close statements to identify the correct databank file. 


'exec .\setup2

dbopen(type=aremos) "e:\usr\ECON\EcoDev\dat\op1172o.bnk"
wfcreate a 1940 2099
'pageselect a
'smpl 1940 2099
fetch(d=op1172o) repratempia*.a repratefpia*.a    
show  repratempia62 repratempia63 repratempia64 repratempia65 repratempia66 repratempia67 repratempia68 repratempia69 repratempia70 repratefpia62 repratefpia63 repratefpia64 repratefpia65 repratefpia66 repratefpia67 repratefpia68 repratefpia69 repratefpia70
pagesave wf_test byrow
close op1172o.bnk


