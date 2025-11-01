' This program updates Data for Total Hours Worked for All Persons. 
' Steps to follow:
' (1) Locate the latest total hours data from BLS
' 		Visit https://www.bls.gov/productivity/tables/
' 		Look for "Total U.S. economy: hours and employment"
' 		File Example: https://www.bls.gov/productivity/tables/total-economy-hours-employment.xlsx
' 		Also, we usually save the file to \\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Raw\BLS\Hours
' 		Typically, we use the data rleased in early November (we prefer to have data through Q3 of the year).
' (2) Locate the relevant data series in the workfile
' 		We need Total economy--All workers--Total U.S. economy--Hours worked--Billions of hours; in Quarterly frequency
' 		Make a note of its location in the file and the time period it covers
'		Example: J4:KY4, 1948Q1 to 2023Q3  -- enter this information in the UPDATE section below

' NOTE: the program assumes that the following TWO files exist in the DEFAULT folder:
' 	1. Excel file with the BLS data, it name given in %file below
' 	2. BKDR1.wf1 that is to be updated with the new total hours data
' !!! MAKE SURE the correct versions of these files are lopacte din the dafault folder and double-check with folder is set as default in EViews !!!

 
exec .\setup2

' *** UPDATE parameters here
%startq = "1948Q1"		
%endq = "2024Q3"

%file = "total-economy-hours-employment_20241107.xlsx" 	' name of the source file that contains the data
%pg = "Quarterly"													' name of the page that contains the data
%cells = "J4:LD4"  												' cells that contain the data; MUST correspond to the dates given in %startq and %endq

' *** END of the UPDATE section

pageselect q
smpl {%startq} {%endq}

import %file range=%pg!{%cells} byrow names="tothrs" @freq q {%startq}

pageselect a
%starty = @left(%startq,4)
%endy = @left(%endq,4)

smpl {%starty} {%endy}

copy(c=an) q\tothrs a\tothrs		' option c=an propagates NAs, so the latest (incomplete) year will have value NA b/c Q4 = NA.

wfopen bkdr1
wfselect work

for %f a q
   pageselect {%f}
   smpl @all
   genr hrs = tothrs
   copy tothrs bkdr1::{%f}\tothrs
   copy hrs bkdr1::{%f}\hrs
   delete *
next

wfselect bkdr1
wfsave(2) bkdr1
wfclose bkdr1


