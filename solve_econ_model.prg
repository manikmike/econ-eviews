' This program creates an EcoDev sandbox if needed
' copies the econ.exe to the pro folder if needed, and
' solves the main Economic model with the
' 2022 Trustees Report Alt 2 Assumptions

if (@folderexist("C:\usr\econ\EcoDev\pro") = 0) then
   shell si createsandbox --project D:/MKS_projects/P30081/ECON/EcoDev/project.pj -R --populate C:\usr\econ\EcoDev
endif

if (@folderexist("C:\usr\econ\EcoDev\out") = 0) then
   shell mkdir C:\usr\econ\EcoDev\out
   for %d cos dump internal log mul revenue trfiles
      shell mkdir C:\usr\econ\EcoDev\out\{%d}
   next
endif

if (@fileexist("C:\usr\econ\EcoDev\pro\econ.exe") = 0) then
   shell copy C:\usr\econ\EcoDev\pro\x64\Debug\econ.exe C:\usr\econ\EcoDev\pro\econ.exe
endif

cd C:\usr\econ\EcoDev\dat
shell echo cd ..\pro > run.bat
shell echo econ.exe 1554 >> run.bat
spawn run.bat


