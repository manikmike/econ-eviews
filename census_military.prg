' This program reads the raw Census data for the
' resident plus armed forces overseas (p) and
' civilian (c) populations and stores them in a
' workfile named censuspop

logmode logmsg

!TRYEAR = 2025
!LAST_CENSUS_YEAR = 2020

!firstYr = !LAST_CENSUS_YEAR
!lastYr = !TRYEAR - 1
!vintage = !TRYEAR - 2

wfcreate(wf=censuspop, page=resident) m {!firstYr}:1 {!lastYr}:12
pagecreate(page=civilian) m {!firstYr}:1 {!lastYr}:12
pagecreate(page=military) m {!firstYr}:1 {!lastYr}:12

!file = 0
%sample = ""
for !year = {!firstYr} to {!lastYr}
   for !half = 1 to 2

   !file = !file + 1
   %f = @str(!file,"i02")

   if (!year = !firstYr and !half = 1) then
      %sample = @str(!year) + "M04 " + @str(!year) + "M06"
   else if (!half = 1) then
      %sample = @str(!year) + "M01 " + @str(!year) + "M06"
   else
      %sample = @str(!year) + "M07 " + @str(!year) + "M12"
   endif
   endif

   ' Resident plus Armed Forces Overseas Population
   call getPop("S:\LRECON\Data\Raw\Census\ResidentPlusAF_OverseasPop\nc-est" + _
               @str(!vintage) + "-alldata-p-file" + %f +".csv", %sample, "p", "resident")

   ' Civilian Population
   call getPop("S:\LRECON\Data\Raw\Census\CivilianPop\nc-est" + _
               @str(!vintage) + "-alldata-c-file" + %f + ".csv", %sample, "c", "civilian")

   next
next

wfsave(2) censuspop.wf1
wfclose censuspop


subroutine getPop(string %filename, string %sample, string %code, string %type)

   wfopen(page=rawdata) %filename ftype=ascii rectype=crlf skip=0 fieldtype=delimited _
      delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page={%code}) m {%sample}
   	'Read in raw age-sex specific data
	for !a=0 to 100
	   pageselect rawdata
		pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
		rename tot_pop tot_pop{!a}
      rename tot_male tot_male{!a}
		rename tot_female tot_female{!a}
		copy untitled\* {%code}\* 
		pagedelete untitled
  	next
   copy(m,smpl=%sample)  {%code}\* censuspop::{%type}\*
   %file = @left(@right(%filename,31),27)
   logmsg %file
   close %file

endsub


