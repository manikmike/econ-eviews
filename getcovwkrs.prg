exec .\setup2

pageselect a
smpl @all

logmode logmsg

' Update the following parameters as necessary
sample export 2000 2095
%range1 = "a1"   ' ce series
%range2 = "a99"  ' n series
%range3 = "a197" ' cwrate series

!TRYEAR = 2020
!BASEYEAR = 2011

%sheet = "TR17 TR18 TR19 BD01 BD02 BD03 BD04 BD05 BD06 BD07 BD08 BD09 BD10 BD11 BD12 BD13 BD14 BD15 BD16 " + _
         "BE01 BE02 BE03 BE04 BE05 BE06 BE07 BE08 BE09 BE10 BE11 NCTR TR20"

' Compute age-sex adjusted covered workers rates
' Initialize base year population
%basepopfile = "\\lrserv1\usr\dem." + @str(!TRYEAR - 2000) + "\Pop\out\mul\PopJul.alt2"
exec .\popjul {%basepopfile}
!ntotal_by = 0
for %sex m f
   for %ag 0t19 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
      !n{%sex}{%ag}_by = @elem(n{%sex}{%ag}, @str(!BASEYEAR))
      !ntotal_by = !ntotal_by + !n{%sex}{%ag}_by
      delete n{%sex}{%ag}
   next
next

'for %s {%sheet} ' forward order
!N = @wcount(%sheet) 
for !i = !N to 1 step -1 ' backward order because XL sheets are created right-to-left
   call covwkr2excel(@word(%sheet,!i))
next


subroutine covwkr2excel(string %sheetname)

   %cwfile = "\\lrserv1\usr\cwp.19\out\mul\cwpopn"
   %popfile = "\\lrserv1\usr\dem.19\Pop\out\mul\PopJul"
   %ext = "alt2"

   if (@left(%sheetname,2) = "TR") then
      %ext = "alt2"
   else if (@left(%sheetname,2) = "BD") then
      %ext = "bu_dem_" + @right(%sheetname,2)
   else if (@left(%sheetname,2) = "BE") then
      %ext = "bu_eco_" + @right(%sheetname,2)
   else
      %ext = "NoCTRepeal"
   endif
   endif
   endif

   if (%sheetname = "TR20") then
      %cwfile =  @replace(%cwfile, "cwp.19","cwp.20")
      %popfile = @replace(%popfile,"dem.19","dem.20")
   endif

   if (%sheetname = "TR18") then
      %cwfile =  @replace(%cwfile, "cwp.19","cwp.18")
      %popfile = @replace(%popfile,"dem.19","dem.18")
   endif

   if (%sheetname = "TR17") then
      %cwfile =  @replace(%cwfile, "cwp.19","cwp.17")
      %popfile = @replace(%popfile,"dem.19","dem.17")
   endif

   %cwfile = %cwfile + "." + %ext
   if (%ext = "bu_eco_03" or %ext = "bu_eco_04") then
      %cwfile = @replace(%cwfile,%ext,"bu_eco_02")
   endif

   if (@left(%sheetname,2) <> "BE") then
     %popfile = %popfile + "." + %ext
   else 
     if (%sheetname >= "BE09") then
        %popfile = %popfile + "." + "bu_dem_15"
     else
        %popfile = %popfile + "." + "alt2"
     endif
   endif
   if (%ext = "bu_dem_16" or %ext = "NoCTRepeal") then
      %popfile = @replace(%popfile,%ext,"bu_dem_15")
   endif

   logmsg %sheetname
   logmsg cwfile:  %cwfile
   logmsg popfile: %popfile
   logmsg

   exec .\cwpopn {%cwfile}
   exec .\PopJul {%popfile}

   ' Create total group for spreadsheet
   series cetotal = 0
   series ntotal = 0
   series cwratetotal = 0
   series cwratetotal_asa = 0
   for %sex m f
      for %ag 0t19 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
         cetotal = cetotal + ce{%sex}{%ag}
         ntotal = ntotal + n{%sex}{%ag}
         cwratetotal_asa = cwratetotal_asa + (ce{%sex}{%ag} / n{%sex}{%ag}) * !n{%sex}{%ag}_by  
      next
   next
   cwratetotal = cetotal / ntotal
   cwratetotal_asa = cwratetotal_asa / !ntotal_by

   group ceg ce* not cetotal
   group ng n* not ntotal
   
   %ce = ceg.@members
   %n = ng.@members
   delete ceg ng
   
   %groups = @winterleave(%ce,%n)
   for %ceg %ng {%groups}
      %asg = @right(%ng,@len(%ng)-1)
      series cwrate{%asg} = {%ceg} / {%ng}
   next
   
   series _year = @year
   %range = %sheetname + "!" + %range1
   pagesave(type="excelxml",mode="update",noid) CoveredWorkerCompare.xlsx range=%range @smpl export @keep _year ce*
   
   %range = %sheetname + "!" + %range2
   pagesave(type="excelxml",mode="update",noid) CoveredWorkerCompare.xlsx range=%range @smpl export @keep _year n*
   
   %range = %sheetname + "!" + %range3
   pagesave(type="excelxml",mode="update",noid) CoveredWorkerCompare.xlsx range=%range @smpl export @keep _year cwrate*
   
   delete ce* n* cwrate*

endsub


