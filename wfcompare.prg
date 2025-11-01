


' user inputs ************************************************************ 

%type = "wf"
' file type: "db" (Aremos databank) or "wf" (EViews workfile)

%file2 = "cnipopdata"
' file name without extension

%file1 = "cnipopdata_0"
' file name without extension

%f = "q"
' frequency
' only for "db" (not for "wf")

%t = "1e-16"
'%t = ".01"
'%t = "1e-2"
'%t = "1%"
' tolerance



' main ************************************************************ 

if (%type = "db") then

  exec .\setup2

  dbopen(type=aremos) {%file2}
  dbopen(type=aremos) {%file1}

  pagecreate(page={%file2}_{%f}) {%f} 1900 2100
  pagecreate(page={%file1}_{%f}) {%f} 1900 2100

  pageselect {%file2}_{%f}
  fetch(d=%file2) *

  pageselect {%file1}_{%f}
  fetch(d=%file1) *

  wfcompare(tol=%t, list=adum)  {%file2}_{%f}\* {%file1}_{%f}\*
  
  close @db
  
else if (%type = "wf") then

  wfopen {%file2}
  wfopen {%file1}

  wfselect {%file2}

  wfcompare(tol=%t, list=adum) *\* {%file1}.wf1

endif
endif


