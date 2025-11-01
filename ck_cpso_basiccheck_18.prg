' This program produces series needed for the check on the cpso68117 databank.
' It produces a group that is ordered in a way consistent with the Excel spreadsheet
' The user must freeze that group, and then cut and paste the data into an excel spreadsheet.
' The Excel spreadsheet is cpsoCheck_TR2018.xlsx
' The Excel spreadsheet compares civilian noninstitutional population and civilian labor force variables from the TR17 cpso68117.bnk to data newly downloaded from Census website and stored on a worksheet in same Excel file. It notes any differences between data imported from the cpso68117.bnk and the newly downloaded data from the Census site.
' 

' 1. Update dbopen lines to point to the correct data
' 2. Update the wfcreate lines to identify the appropriate years for the TR
' 3. Update the fetch, and close statements to identify the correct data file. 


'exec .\setup2

'Add the new TR18 series
dbopen(type=aremos) "e:\usr\ECON\EcoDev\dat\cpso68117.bnk"
wfcreate a 2016 2017
'pageselect a
'smpl 2016 2017
fetch(d=cpso68117) nf*.a  nm*.a lf*.a  lm*.a  
show  nf16o nf16oMS nf16oMA nf16oNM nm16o nm16oMS nm16oMA nm16oNM lf16o lf16oMS lf16oMA lf16oNM lm16o lm16oMS lm16oMA lm16oNM
pagesave wf_test byrow
close cpso68117


