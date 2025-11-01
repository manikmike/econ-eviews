' This program creates quarterly and annual replacement rate series in the
' operational databank using data on retirement replacement rates from the raw databank

' IMPORTANT: This parameter is for the most recently published Trustees Report
!TRYEAR = 2024

exec .\setup2
logmode logmsg

for !alt = 1 to 3

exec .\setup2

   ' Raw workfile
   %input1 = "op" + @str(!TRYEAR - 1900) + @str(!alt) + "r"
   
   ' Operational workfile
   %input2 = "op" + @str(!TRYEAR - 1900) + @str(!alt) + "o"
   
   pageselect a
   
logmsg opening raw workfile; saving reprate data to temporary workfile
   wfopen {%input1}.wf1
   wfselect work
   pageselect a
   copy {%input1}::a\REPRATE* work::a\REPRATE*
wfselect work
wfsave(2)work
  

   group g * not resid
   %all = g.@members
   delete g

logmsg dividing by 100
   for %s {%all}
      ' Divide by 100 if the raw databank already has units of percent
      ' prior to interpolation
      {%s} = {%s} / 100
   next
  
logmsg use Denton averaging method to create quarterly data from the annual data
	wfselect work
   copy(c="dentona") a\reprate* q\reprate*
   
   for %f a q
      pageselect {%f}
      for %s {%all}
         ' Convert back to percent for operational databank
         ' after interpolation
         {%s} = {%s} * 100
      next
   next
   
logmsg opening operational workfile
   wfopen {%input2}.wf1
   wfselect work
   
   for %f a q
	  pageselect {%f}
      copy work::{%f}\REPRATE* {%input2}::{%f}\REPRATE* 
   next
   
logmsg stored data in operational workfile
   wfclose work
   wfclose {%input1}
   wfselect {%input2}
   wfsave {%input2}.wf1
   wfclose {%input2}
   logmsg closed operational workfile. finished with alt {!alt}
   logmsg

next


