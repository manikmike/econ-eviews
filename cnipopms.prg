' This program imports the Civilian Noninstitutional Population from
' the demography output text files into an EViews workfile
' and performs simple consistency check on the data

' Default Input:  CNIPopJulMS.hist, CNIPopJulMS.alt2, 
'                 CNIPopDecMS.hist, CNIPopDecMS.alt2
' Default Output: cnipopms_alt2.wf1

' To override the defaults:
' An optional program argument specifies the file extension
' of the desired alternative (e.g., exec .\cnipopms alt1)

exec .\setup2
pagecreate(page=dec) a 1901 2105
pagecreate(page=jul) a 1901 2105
smpl @all

%ext = %0   

if (%0 = "") then
   %ext = "alt2"
   %histext = "hist"
else
   !sens = @wfind("fer1 fer3 imm1 imm3 mor1 mor3 mar1 mar3 div1 div3", %ext)
   if (%ext = "alt1" or %ext = "alt2" or %ext = "alt3" or !sens <> 0) then
      %histext = "hist"
   else
      %histext = "hist" + "." + %ext	
   endif
endif

pageselect jul
call createseries
%filename = "CNIPopJulMS." + %ext
call getpop(%filename)
string demo_proj = @str(!yr_first) 		' string demo_proj denotes the FIRST PROJECTION YEAR in Demo data
%filename = "CNIPopJulMS." + %histext
call getpop(%filename)
string demo_first = @str(!yr_first) 		' string demo_first denotes the FIRST YEAR in Demo data when data are available
string demo_hist = @str(!yr_last) 			' string demo_hist denotes the LAST HISTORICAL YEAR in Demo data

' check for data consistency (components add up to totals)
string _checkjul = "Checking the components add up to totals for JUL data..." + @chr(13)
!err = 0
for !a = 0 to 100
   smpl @all
   series ck_n{!a} = n{!a} - nm{!a} - nf{!a}
   smpl @all if ck_n{!a}<>0
   if @obssmpl > 0 then
   		string warn = " Components do not add up to totals in JUL data for n" + @str(!a) + @chr(13)
      _checkjul = _checkjul + warn
      	!err = !err +1
   endif
   for %s m f
      smpl @all
      series ck_n{%s}{!a} = n{%s}{!a} - n{%s}{!a}nm - n{%s}{!a}ms - n{%s}{!a}ma
      smpl @all if ck_n{%s}{!a}<>0
      if @obssmpl > 0 then
      		string warn = " Components do not add up to totals in JUL data for n" + %s + @str(!a) + @chr(13)
      		_checkjul = _checkjul + warn
      		!err = !err +1
      	endif
   next
next
smpl @all
if !err = 0 then
	_checkjul = _checkjul + "All components add up to corresponding totals for JUL data"
	delete ck_*
endif
_checkjul.display


pageselect dec
smpl @all
call createseries
%filename = "CNIPopDecMS." + %ext
call getpop(%filename)
%filename = "CNIPopDecMS." + %histext
call getpop(%filename)

' check for data consistency (components add up to totals)
string _checkdec = "Checking the components add up to totals for DEC data..." + @chr(13)
!err = 0
for !a = 0 to 100
   smpl @all
   series ck_n{!a} = n{!a} - nm{!a} - nf{!a}
   smpl @all if ck_n{!a}<>0
   if @obssmpl > 0 then
   		string warn = " Components do not add up to totals in DEC data for n" + @str(!a) + @chr(13)
      _checkdec = _checkdec + warn
      	!err = !err +1
   endif
   for %s m f
      smpl @all
      series ck_n{%s}{!a} = n{%s}{!a} - n{%s}{!a}nm - n{%s}{!a}ms - n{%s}{!a}ma
      smpl @all if ck_n{%s}{!a}<>0
      if @obssmpl > 0 then
      		string warn = " Components do not add up to totals in DEC data for n" + %s + @str(!a) + @chr(13)
      		_checkdec = _checkdec + warn
      		!err = !err +1
      	endif
   next
next
smpl @all
if !err = 0 then
	_checkdec = _checkdec + "All components add up to corresponding totals for DEC data"
	delete ck_*
endif
_checkdec.display

pageselect a
copy jul\* a\*

wfsave(2) cnipopms_{%ext}


subroutine createseries

   for !a = 0 to 100
      series n{!a}
      for %s m f
         series n{%s}{!a}
         for %ms nm ms ma
            series n{%s}{!a}{%ms}
         next
      next
   next

endsub


subroutine getpop(string %filename)

   Matrix mat
   mat.import(type=text) %filename
   !numrows = mat.@rows
   !yr_first = mat(1,1)
   !yr_last = mat(!numrows,1)
   for !row = 1 to !numrows
      !year = mat(!row,1)
      smpl {!year} {!year}
      !age = mat(!row,2)
      n{!age} = mat(!row,3)
      nm{!age} = mat(!row,4)
      nm{!age}nm = mat(!row,5)
      nm{!age}ms = mat(!row,6) 
      nm{!age}ma = mat(!row,7) + mat(!row,8) + mat(!row,9)
      nf{!age} = mat(!row,10)
      nf{!age}nm = mat(!row,11)
      nf{!age}ms = mat(!row,12)
      nf{!age}ma = mat(!row,13) + mat(!row,14) + mat(!row,15)
   next
   delete mat

endsub


