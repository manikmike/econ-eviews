' This program reads the QCEW data files and
' loops through each line-by-line creating
' a string object for each line

logmode logmsg

exec .\setup2

%files = "SSANAT231_230810_f.txt " + _
         "SSAPR231_230810_f.txt "  + _
         "SSAVI231_230810_f.txt"

Text t

for %f {%files}
   t.append(file) {%f}
   !n = t.@linecount
   for !i = 1 to !n
      %s = t.@line(!i)
      call processLine(%s)
   next
   t.clear
next

delete t

subroutine processLine(string %line)

   logmsg {%line}

endsub

