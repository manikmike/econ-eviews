' This program combines the old March CPS data with the updated data

!year = 2024 ' last year of updated data (default)

' Use first argument of program call to override default year
if (%0 <> "") then
   !year = @val(%0)
endif

%dbname1 = "cpsr68" + @str(!year - 1900 - 1) ' previous year raw workfile
%dbname2 = "cpsr68" + @str(!year - 1900)     ' current  year raw workfile

%wfname = "cpsr" + @str(!year - 1900) ' workfile with latest year of raw data to be incorporated

shell copy {%dbname1}.wf1 {%dbname2}.wf1 ' more efficient than creating an empty workfile and copying individual series

wfopen {%wfname}.wf1
'dbopen(type=aremos) %dbname2 ' copying from workfile to databank is slow, but working around an EViews bug
wfopen {%dbname2}.wf1
pageselect a
rename *xampx *_


wfselect {%wfname}
pageselect a

'copy(m) a\*_ {%dbname2}::*&.a ' ampersands not allowed in workspace, so rename in databank

copy(merge, smpl="2024 2024") a\* {%dbname2}::a\

'delete *_

'store(db={%dbname2}) *
wfselect {%dbname2}
wfsave {%dbname2}.wf1

'close %wfname
'close @db
close @wf


