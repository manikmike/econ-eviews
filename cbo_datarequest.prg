' This program produces an EViews workfile that contains the data series requested by CBO every year. 
' It also produces CSV files with the same data (which can be used in programs other than EViews)

'BEFORE RUNNING this program, the user should update the top section of the code, which indicates the TR to be used and the location of the relevant workfiles. 

'*****UPDATE these variables before running the program to make sure it uses correct files****

!tryear = 2024 'the Trustees Report year
!startyr = 1991 'the first year of data to be sent to CBO
!endyr = !tryear + 74 'the last year of data to be sent to CBO
' Convert TR year to string.
%stryear = @str(!tryear)
' Store last two digits of TR year in string variable.
%stryear2 = @right(%stryear, 2)

%folder = "2024-0215-0725-TR242"

%inputpath = "S:\LRECON\ModelRuns\TR" + %stryear + "\" + %folder + "\out\mul\" 'filepath that points to location of workfiles corresponding to final TR run 

%outputpath = "S:\LRECON\TrusteesReports\TR" + %stryear + "\Requests\CBO\" 'filepath that points to location to store the output file

' Save CSV files with data? 
' Enter Y or N, case sensitive. Y will save BOTH CSV files and WF, N will save WF only. 
%csv = "N"

'*****END of section that needs updating for each TR run*****
'******************************************************************

'*** Create string variables to denote necessary filepaths and filenames

%afile = "atr" + %stryear2 + "2" 'short reference to workfile
%dfile = "dtr" + %stryear2 + "2" 

%afilepath = %inputpath + %afile + ".wf1" 'full path to the workfile
%dfilepath = %inputpath + %dfile + ".wf1" 

'*******************
%wfname = "arnold_" + %stryear2 'name for the resulting workfile
%pagen = "CNIPOP_TR" + %stryear 'names for the pages within the workfile
%pagel = "LABOR_TR" + %stryear
%pagep = "LFPR_TR" + %stryear

wfcreate(wf=%wfname, page=%pagen) a !startyr !endyr 'create workfile with the above name, annual frequency, for period from startyr to endyr

pagecreate(page=%pagel) a !startyr !endyr 'create two additional pages in the workfile
pagecreate(page=%pagep) a !startyr !endyr

%age = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o"

%list_n = @wreplace(%age, "*", "nf*") + " " + @wreplace(%age, "*", "nm*") + " nf16o nm16o n16o"

%list_l = @wreplace(%age, "*", "lf*") + " " + @wreplace(%age, "*", "lm*") + " lc lcf lcm"

%list_p = @wreplace(%age, "*", "pf*") + " " + @wreplace(%age, "*", "pm*") + " pf16o pm16o p16o"

' Get civilian noninstitutional population from the D file.
open %dfilepath
pageselect a

for %s {%list_n}
  copy %s {%wfname}::{%pagen}\
next

close %dfile

pageselect {%pagen}                                   ' select appropriate page in the workfile
group cnipop {%list_n}                                ' groups series in the desired order
freeze({%pagen}) cnipop.sheet                         ' save the group in a table -- for ease of view and for saving in other formats
%tab_title = "TR" + %stryear + " Civilian Noninstitutional Population (millions)"  ' create table title
{%pagen}.title {%tab_title} 
{%pagen}(1,1)="DATE"
if %csv = "Y" then
  %cnipop_csv=%outputpath+%pagen
  {%pagen}.save {%cnipop_csv}                         ' save the table as CSV file
endif


' Get labor force and labor force participation rate values from the A file.

open %afilepath
pageselect a

for %s {%list_l}
  copy %s {%wfname}::{%pagel}\
next

for %s {%list_p}
  copy %s {%wfname}::{%pagep}\
next

close %afile

pageselect {%pagel}
group laborforce {%list_l}
freeze({%pagel}) laborforce.sheet
%tab_title = "TR" + %stryear + " Labor Force (millions)"
{%pagel}.title  {%tab_title}
{%pagel}(1,1)="DATE"
if %csv = "Y" then
  %lf_csv=%outputpath+%pagel
  {%pagel}.save {%lf_csv} 
endif
    

pageselect {%pagep}
fetch(d={%abank}) {%list_p_a}
group lfpr {%list_p}
freeze({%pagep}) lfpr.sheet
%tab_title = "TR" + %stryear + " Labor Force Participation Rate"
{%pagep}.title {%tab_title}
{%pagep}(1,1)="DATE"
if %csv = "Y" then
  %lfpr_csv=%outputpath+%pagep
  {%pagep}.save {%lfpr_csv}
endif
  
%wfpath = %outputpath + %wfname
wfsave %wfpath ' save the workfile

close @all


