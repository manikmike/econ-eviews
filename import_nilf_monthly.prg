' This program imports CPS not in the labor force data  into the cps_nilf_month databank

' Update information listed in ***UPDATE section below

'********* UPDATE here

%y_last = "24" ' two-digit calendar year. The latest year for which we have data in Excel files (typically for only part of the year). The program assumes we have data through September.
!mo = 9 ' last month in %y_last for which we have data; usually this is September, i.e. month 9. List the months for which we have data in %month2 below:
%month2 = "jan feb mar apr may jun jul aug sep" 	' Data would typically end in September; if this changes -- adjust the code here!
%y_full = "23" ' two-digit calendar year -- the year for which we have FULL YEAR of data in Excel files

' folder where the Excel files with raw data are located
%path = ""
%path = "S:\LRECON\Data\Processed\CPS\NotInTheLaborForce"
'%path = "C:\Users\095784\GitRepos\Econ-EViews"  

'NOTE: this program saves the cps_nilf_month.bnk into DEFAULT location, and will overwrite any file named identically. Make sure the default location is what you intend it to be!!!

'********* END of update section

!year_start = 2000 + @val(%y_full) 	'start year for the workfile
!year_end = 2000 + @val(%y_last) 	'end year for the workfile

%type = "nlcbyreas nlcdisc lcstatus"

%cells = "$B$5:$C$81 $E$5:$F$81 $H$5:$I$81 $K$5:$L$81 " + _
         "$B$85:$C$161 $E$85:$F$161 $H$85:$I$161 $K$85:$L$161 " + _
         "$B$165:$C$241 $E$165:$F$241 $H$165:$I$241 $K$165:$L$241 " + _
         "$B$245:$C$321 $E$245:$F$321 $H$245:$I$321 $K$245:$L$321 " + _
         "$B$325:$C$401 $E$325:$F$401 $H$325:$I$401 $K$325:$L$401 " + _
         "$B$405:$C$481 $E$405:$F$481 $H$405:$I$481 $K$405:$L$481 " + _
         "$B$485:$C$561 $E$485:$F$561 $H$485:$I$561 $K$485:$L$561 " + _
         "$B$565:$C$641 $E$565:$F$641 $H$565:$I$641 $K$565:$L$641 " + _
         "$B$645:$C$721 $E$645:$F$721 $H$645:$I$721 $K$645:$L$721 " + _
         "$B$725:$C$801 $E$725:$F$801 $H$725:$I$801 $K$725:$L$801 " + _
         "$B$805:$C$881 $E$805:$F$881 $H$805:$I$881 $K$805:$L$881 " + _
         "$B$885:$C$961 $E$885:$F$961 $H$885:$I$961 $K$885:$L$961"

wfcreate(wf=cps_nilf_temp, page=m) m {!year_start}m1 {!year_end}m12

logmode l
%msg = "Running import_nilf_monthly.prg" 
logmsg {%msg}
logmsg

tic

' loading data for the last FULL year
!year = 2000 + @val(%y_full)
%file1 = "20" + %y_full + " monthly nlc by reason by marital status.xlsx"		' .xlsx" The program works with .xlsx or .xls files. BUT .xls files are A LOT faster (they take about 3 times less time than .xlsx files)
%file2 = "20" + %y_full + " monthly nlc discouraged by marital status.xlsx"	' .xlsx"
%file3 = "20" + %y_full + " monthly lc status by marital status.xlsx"				' .xlsx"

%month = "jan feb mar apr may jun jul aug sep oct nov dec"	

' i is the file, j is the month, and k is the range
for !i = 1 to 3
   %file = %file{!i}
   for !j = 1 to 12
       for !k = 1 to 48
          if (!i > 1 and !k > 32) then
             exitloop
          endif
          %range = @wordq(%month,!j) + %y_full + @wordq(%type,!i) + "!" + @wordq(%cells,!k)
          import(mode="md") %file range={%range} byrow colhead=1 na="#N/A" @freq M {!year}M{!j} @smpl @all
       next
       %msg = "Finished " + @wordq(%month,!j) + " " + %file{!i}
       logmsg {%msg}
   next
   logmsg
next

' loading data for the latest PARTIAL year
!year = 2000 + @val(%y_last)
%file1 = "20" + %y_last + " monthly nlc by reason by marital status.xlsx"			' .xlsx"
%file2 = "20" + %y_last + " monthly nlc discouraged by marital status.xlsx"		' .xlsx"
%file3 = "20" + %y_last + " monthly lc status by marital status.xlsx"				' .xlsx"

' String %month2 = "jan feb mar apr may jun jul aug sep" is defined at the start of the program and lists the months for which we have data in the partial year.	

' i is the file, j is the month, and k is the range
for !i = 1 to 3
   %file = %file{!i}
   for !j = 1 to !mo
       for !k = 1 to 48
          if (!i > 1 and !k > 32) then
             exitloop
          endif
          %range = @wordq(%month2,!j) + %y_last + @wordq(%type,!i) + "!" + @wordq(%cells,!k)
          import(mode="md") %file range={%range} byrow colhead=1 na="#N/A" @freq M {!year}M{!j} @smpl @all
       next
       %msg = "Finished " + @wordq(%month2,!j) + " " + %file{!i}
       logmsg {%msg}
   next
   logmsg
next

wfsave cps_nilf_month

'db(type=aremos) cps_nilf_month.bnk
'store(db=cps_nilf_month) *
'close cps_nilf_month

!runtime = @toc
%msg = "Runtime " + @str(!runtime) + " sec" 
logmsg {%msg}


