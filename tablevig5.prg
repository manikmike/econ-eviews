' This programs creates Table VI.G5 for the Trustees Report

!TRYEAR = 2025
!ENDYEAR = 2105
!HISTYEAR = 1970

exec .\setup2
pageselect a
for !alt = 1 to 3
  %afile = "atr" + @right(@str(!TRYEAR),2) + @str(!alt)
  wfopen {%afile}
  wfselect work
  smpl {!HISTYEAR} {!ENDYEAR}
  series r{!alt} = {%afile}.wf1::a\oasdi_etp / {%afile}.wf1::a\gdp
  smpl 1983 2001
  series r{!alt} = {%afile}.wf1::a\oasdi_etp_tot / {%afile}.wf1::a\gdp
  wfclose {%afile}
next

smpl {!HISTYEAR} {!ENDYEAR}

' Trustees Report Table (Beth Hima)

Text t
%line = "Table VI.G5.--Ratio of OASDI Taxable Payroll to GDP  Calendar Years " + @str(!TRYEAR) + "-" + @str(!ENDYEAR)
t.append %line
t.append "Calendar year Intermediate  Low-Cost  High-Cost"

for !year = {!TRYEAR} to {!TRYEAR}+9
   !r2 = @elem(r2,@str(!year))
   !r1 = @elem(r1,@str(!year))
   !r3 = @elem(r3,@str(!year))
   if (!year <> !TRYEAR) then
      %line = @str(!year) + "                  " + @right(@str(!r2,"f=5.3"),4) + "      " + @right(@str(!r1,"f=5.3"),4) + "       " + @right(@str(!r3,"f=5.3"),4)
   else
      %line = @str(!year) + "                 " + @str(!r2,"f=5.3") + "     " + @str(!r1,"f=5.3") + "      " + @str(!r3,"f=5.3")
   endif
   t.append %line
next

t.append

for !year = {!TRYEAR}+10 to {!ENDYEAR}
   !r2 = @elem(r2,@str(!year))
   !r1 = @elem(r1,@str(!year))
   !r3 = @elem(r3,@str(!year))
   if (@mod(!year,5) == 0) then
      %line = @str(!year) + "                  " + @right(@str(!r2,"f=5.3"),4) + "      " + @right(@str(!r1,"f=5.3"),4) + "       " + @right(@str(!r3,"f=5.3"),4)
      t.append %line
   endif
next

t.save TableVIG5.txt
delete t

' Same Table with Less Formatting (???)

Text t
t.append "Calendar year,Intermediate,Low-Cost,High-Cost"

for !year = {!TRYEAR} to {!TRYEAR}+9
   !r2 = @elem(r2,@str(!year))
   !r1 = @elem(r1,@str(!year))
   !r3 = @elem(r3,@str(!year))
   %line = @str(!year) + "," + @str(!r2,"f=5.3") + "," + @str(!r1,"f=5.3") + "," + @str(!r3,"f=5.3")
   t.append %line
next

for !year = {!TRYEAR}+10 to {!ENDYEAR}
   !r2 = @elem(r2,@str(!year))
   !r1 = @elem(r1,@str(!year))
   !r3 = @elem(r3,@str(!year))
   if (@mod(!year,5) == 0) then
      %line = @str(!year) + "," + @str(!r2,"f=5.3") + "," + @str(!r1,"f=5.3") + "," + @str(!r3,"f=5.3")
      t.append %line
   endif
next

t.save TableVIG5Proj.csv
delete t

' Historical Supplemental Single-Year Table (Karen Rose)

Text t
t.append "Historical,"

for !year = {!HISTYEAR} to {!TRYEAR}-1
   !r2 = @elem(r2,@str(!year))
   %line = @str(!year) + ", " + @str(!r2,"f=5.3")
   t.append %line
next

t.save TableVIG5Hist.csv
delete t

' Projected Supplemental Single-Year Table (Karen Rose)

Text t
t.append "Calendar year,Intermediate,Low-Cost,High-Cost"

for !year = {!TRYEAR} to {!ENDYEAR}
   !r2 = @elem(r2,@str(!year))
   !r1 = @elem(r1,@str(!year))
   !r3 = @elem(r3,@str(!year))
   %line = @str(!year) + "," + @str(!r2,"f=5.3") + "," + @str(!r1,"f=5.3") + "," + @str(!r3,"f=5.3")
   t.append %line
next

t.save lrvig5ProjSing.csv


' delete r* t

