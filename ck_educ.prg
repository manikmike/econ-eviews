' This program produces series needed for the check on the Education databank.
' It produces a group that is ordered in a way consistent with the Excel spreadsheet
' The user must freeze that group, and then cut and paste the data into an excel spreadsheet.
' The Excel spreadsheet is EducationCheck_TR2017.xlsx
' The Excel spreadsheet compares educational attainment variables from the TR17 Education.dbk to data newly downloaded from Census website and stored on a worksheet in same Excel file. It notes any differences between data imported from the Education.dbk and the newly downloaded from the Census site.
' 

' 1. Update dbopen lines to point to the correct data
' 2. Update the wfcreate lines to identify the appropriate SR years for the TR
' 3. Update the fetch, and close statements to identify the correct data file. 


'exec .\setup2

'Add the new TR17 series
dbopen(type=aremos) "z:\Aremos\TR2017 Banks\education.bnk"
wfcreate a 2015 2016
'pageselect a
'smpl 2015 2016
fetch(d=education) nf*E.a  nf*ENOHSG.a nf*EHSGRAD.a  nf*ECOL1T3.a  nf*ECOL4.a  nf*ECOL5O.a  nm*E.a  nm*ENOHSG.a nm*EHSGRAD.a  nm*ECOL1T3.a  nm*ECOL4.a  nm*ECOL5O.a lf*E.a  lf*ENOHSG.a lf*EHSGRAD.a  lf*ECOL1T3.a  lf*ECOL4.a  lf*ECOL5O.a  lm*E.a  lm*ENOHSG.a lm*EHSGRAD.a  lm*ECOL1T3.a  lm*ECOL4.a  lm*ECOL5O.a 
show nf*E  nf*ENOHSG nf*EHSGRAD  nf*ECOL1T3  nf*ECOL4  nf*ECOL5O  nm*E  nm*ENOHSG nm*EHSGRAD  nm*ECOL1T3  nm*ECOL4  nm*ECOL5O lf*E  lf*ENOHSG lf*EHSGRAD  lf*ECOL1T3  lf*ECOL4  lf*ECOL5O  lm*E  lm*ENOHSG lm*EHSGRAD  lm*ECOL1T3  lm*ECOL4  lm*ECOL5O
pagesave wf_test byrow
close education


