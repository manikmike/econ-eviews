' This program copies the output from a model run
' to the location formerly know as the secret place

logmode -error
exec ./setup2
logmode logmsg

%username = @env("USERNAME")

%src  = "C:\Users\" + %username + "\GitRepos\econ-ecodev"
%dest = "S:\LRECON\ModelRuns\TR2024"

!modelrun = 1690

call copy(!modelrun, %src, %dest)


subroutine copy(scalar !modelrun, string %src, string %dest)

   %config = %src + "\dat\config" + @str(!modelrun) + ".txt"
   Text t
   t.append(file) {%config}
   !n = t.@linecount
   for !i = 1 to !n
      %line = t.@line(!i)
      if (@instr(%line, "OTL_FILE") > 0) then
         %otlfile = @word(%line, 3)
         %afile = "a" + @replace(%otlfile,"otl_","")
         %adfile = "ad" + @replace(%otlfile,"otl_","")
         %dfile = "d" + @replace(%otlfile,"otl_","")
         %rdfile = @replace(%otlfile,"otl_","")
         call parsedate
         %dirname = @upper(%YYYY + "-" + %MMDD + "-" + %HHMM + "-" + @right(%afile,@len(%afile)-1))
       else if (@instr(%line, "FILE_EXTENSION") > 0) then
         %ext = @word(%line, 3)
      endif
      endif
   next
   delete t

   logmsg Creating directories...
   shell mkdir {%dest}\{%dirname}
   shell mkdir {%dest}\{%dirname}\dat
   shell mkdir {%dest}\{%dirname}\out
   shell mkdir {%dest}\{%dirname}\out\cos
   shell mkdir {%dest}\{%dirname}\out\internal
   shell mkdir {%dest}\{%dirname}\out\mul
   shell mkdir {%dest}\{%dirname}\out\revenue

   logmsg Copying files...

   logmsg Output workfiles
   shell copy {%src}\out\mul\{%afile}.wf1 {%dest}\{%dirname}\out\mul
   shell copy {%src}\out\mul\{%dfile}.wf1 {%dest}\{%dirname}\out\mul
   shell copy {%src}\out\mul\{%otlfile}.wf1 {%dest}\{%dirname}\out\mul

   logmsg Addfactor workfile
   shell copy {%src}\dat\{%adfile}.wf1 {%dest}\{%dirname}\dat

   logmsg out\cos directory
   if (%ext = "alt2") then
      shell copy {%src}\out\cos\*.hist {%dest}\{%dirname}\out\cos
   endif
   shell copy {%src}\out\cos\*.{%ext} {%dest}\{%dirname}\out\cos

   logmsg out\internal directory
   shell copy {%src}\out\internal\*.{%ext} {%dest}\{%dirname}\out\internal

   logmsg out\mul directory
   if (%ext = "alt2") then
      shell copy {%src}\out\mul\*.hist {%dest}\{%dirname}\out\mul
   endif
   shell copy {%src}\out\mul\*.{%ext} {%dest}\{%dirname}\out\mul

   logmsg out\revenue directory
   shell copy {%src}\out\revenue\{%rdfile}.rd {%dest}\{%dirname}\out\revenue

   logmsg Labor Force Model Solution
   shell copy {%src}\dat\ru_proj.wf1 {%dest}\{%dirname}\dat
   shell copy {%src}\dat\lfpr_proj_1654.wf1 {%dest}\{%dirname}\dat
   shell copy {%src}\dat\lfpr_proj_55100.wf1 {%dest}\{%dirname}\dat
   shell copy {%src}\dat\lfpr_proj.wf1 {%dest}\{%dirname}\dat
   shell copy {%src}\dat\wsqprojtr.wf1 {%dest}\{%dirname}\dat

   close work

endsub


subroutine parsedate()

   shell(out=temp) dir {%src}\out\mul\{%afile}.wf1
   %dateline = temp(6,1)
   delete temp
   %date = @word(%dateline,1)
   %time = @word(%dateline,2)

   ' Check the date and time format
   ' Default seems to be MM/DD/YYYY HH:MM AM or PM
   ' For Drew, it is YYYY-MM-DD HH:MM
   if (@val(@left(%date,4)) = na) then ' year does not come first => assume default
      %ampm = @word(%dateline,3)
      %YYYY = @right(%date,4)
      %MMDD = @left(%date,2) + @mid(%date,4,2)
      !hr = @val(@left(%time,2))
      if (%ampm = "PM" and !hr < 12) then
         !hr = !hr + 12
      endif
      if (!hr < 10) then
         %HHMM = "0" + @str(!hr) + @right(%time,2)
      else
         %HHMM = @str(!hr) + @right(%time,2)
      endif
   else ' year is first => assume 24-hr
      %YYYY = @left(%date,4)
      %MMDD = @mid(%date,6,2) + @right(%date,2)
      %HHMM = @left(%time,2) + @right(%time,2)
   endif

endsub


