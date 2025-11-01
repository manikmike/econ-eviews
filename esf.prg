
' When covdata.bnk was eliminated (TR 2016), some series needed a new home. 
' This program:
' - was originally written in Aremos by Drew Sawyer in 2015.
' - imports series from an Excel file (e.g., SF_Q3_ESTF20161027.xlsx) and stores them in esf.bnk.
' - was converted from Aremos to EViews by Drew Sawyer in 2017.


exec .\setup2


' user inputs ************************************************************ 

%excel_file = "E:\usr\econ\EViews\SF_Q3_ESTF20171107.xlsx"
' Excel file to import from
' original location: \\S1F906B\econ\Raw data\ESF\

%excel_range = "ESF_20171107!$B$1:$J$67"
' Excel sheet and range to import from


' main ************************************************************ 

pageselect a

import %excel_file range=%excel_range colhead=2 namepos=first @freq A 1951
' colhead: number of table rows to be treated as column headers
' namepos: which row(s) of the column headers should be used to form the column name

' create group containing all series except "resid"
group g * not resid

' create string variable containing names of all series in group "g"
%to_store = g.@members

for %s {%to_store}

  ' set "remarks" field of series label equal to "description" field
  ' in Aremos, "remarks" field is displayed upon "index series" command
  {%s}.label(r) ' clear "remarks" field of series label
  %d = {%s}.@description
  {%s}.label(r) %d

  if (@left(%s, 3) = "WE_") then

    ' wages, so round to nearest penny
    {%s} = @round({%s} * 1e11) / 1e11

  else

    if (@left(%s, 3) = "TE_") then

    ' employment, so round to nearest person
      {%s} = @round({%s} * 1e6) / 1e6

    endif

  endif

next

' open or create database
' esf.bnk will only contain these imported series, so creating is OK
db(type=aremos) esf.bnk

store(d=esf) {%to_store}

close @db

close @wf


