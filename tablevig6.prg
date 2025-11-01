' This programs creates Table VI.G6 for the Trustees Report

!TRYEAR = 2025
!ENDYEAR = 2105

exec .\setup2
pageselect a
smpl {!TRYEAR}-1 {!ENDYEAR}

for !alt = 1 to 3
  %afile = "atr" + @right(@str(!TRYEAR),2) + @str(!alt)
  wfopen {%afile}
  wfselect work
  series cpiw_u_{!alt} = {%afile}.wf1::a\cpiw_u
  series cpiw_u_adj_{!alt} = 100 * cpiw_u_{!alt} / @elem(cpiw_u_{!alt},{!TRYEAR})
  series aiw_{!alt} = {%afile}.wf1::a\aiw
  series oasdi_etp_{!alt} = {%afile}.wf1::a\oasdi_etp
  series gdp_{!alt} = {%afile}.wf1::a\gdp
  copy {%afile}::m\nomintr nomintr_{!alt}
  series nomyld_{!alt} = (1 + nomintr_{!alt} / 200) ^ 2
  series comint_{!alt}
  smpl {!TRYEAR}-1 {!TRYEAR}-1
  comint_{!alt} = 1 / nomyld_{!alt}
  smpl {!TRYEAR} {!ENDYEAR}
  comint_{!alt} = comint_{!alt}(-1) * nomyld_{!alt}(-1)
  smpl {!TRYEAR}-1 {!ENDYEAR}
  wfclose {%afile}
next

%workbook = "C:\GitRepos\econ-eviews\VIG6_" + @right(@str(!TRYEAR),2) + "tr.xlsx"
!TRYEARM1 = !TRYEAR - 1
import {%workbook} range=Effective!$O$3:$Q$81 colhead=1 na="#N/A" @freq A {!TRYEARM1} @smpl @all
rename alt* cominteff_*

Text t
%line = "       Table VI.G6.--Selected Economic Variables, Calendar Years " + @str(!TRYEAR-1) + "-" + @str(!ENDYEAR)
t.append %line
t.append "                     [GDP and taxable payroll in $ billions]         "
t.append "                                                                         Compound"
t.append "                                                             Compound   effective"
t.append "                                                Gross       new-issue  trust fund"
t.append "              Adjusted   SSA average  Taxable  domestic      interest    interest"
t.append "Calendar year      CPI    wage index  payroll   product        factor      factor"

for %alt 2 1 3

   if (%alt == "2") then
      t.append "Intermediate:"
   else
   if (%alt == "1") then
         t.append "Low Cost:"
   else
   if (%alt == "3") then
      t.append "High Cost:            "
   endif
   endif
   endif

   for !year = {!TRYEAR}-1 to {!TRYEAR}+9
      !c1 = @elem(cpiw_u_adj_{%alt},@str(!year))
      !c2 = @elem(aiw_{%alt},@str(!year))
      !c3 = @elem(oasdi_etp_{%alt},@str(!year))
      !c4 = @elem(gdp_{%alt},@str(!year))
      !c5 = @elem(comint_{%alt},@str(!year))
      !c6 = @elem(cominteff_{%alt},@str(!year))
       if (%alt <> 3) then
         %line = @str(!year) + "          " + @str(!c1,"f8.2") + @str(!c2,"ft14.2") + @str(!c3,"ft9.0") + @str(!c4,"ft10.0") + @str(!c5,"f14.4") + @str(!c6,"f12.4")

      else
         %line = @str(!year) + "          " + @str(!c1,"f7.2") + " " + @str(!c2,"ft14.2") +  + @str(!c3,"ft9.0") + @str(!c4,"ft10.0") + @str(!c5,"f14.4") + @str(!c6,"f12.4")
      endif
      t.append %line
   next

   if (%alt == "2") then
      t.append " "
   else
      t.append
   endif

   for !year = {!TRYEAR}+10 to {!ENDYEAR}
      !c1 = @elem(cpiw_u_adj_{%alt},@str(!year))
      !c2 = @elem(aiw_{%alt},@str(!year))
      !c3 = @elem(oasdi_etp_{%alt},@str(!year))
      !c4 = @elem(gdp_{%alt},@str(!year))
      !c5 = @elem(comint_{%alt},@str(!year))
      !c6 = @elem(cominteff_{%alt},@str(!year))
      if (@mod(!year,5) == 0) then
         if (%alt <> "3") then
            %line = @str(!year) + "          " + @str(!c1,"f8.2") + @str(!c2,"ft14.2")  + @str(!c3,"ft9.0") + @str(!c4,"ft10.0") + @str(!c5,"f14.4") + @str(!c6,"f12.4")
         else
            %line = @str(!year) + "          " + @str(!c1,"f7.2") + " " + @str(!c2,"ft14.2")  + @str(!c3,"ft9.0") + @str(!c4,"ft10.0") + @str(!c5,"f14.4") + @str(!c6,"f12.4")
         endif
         t.append %line
      endif
   next

   if (%alt <> "3") then
      t.append
   endif

next

t.save TableVIG6.txt
delete *_* t


