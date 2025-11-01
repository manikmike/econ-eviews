' This program updates the EconMeans spreadsheet for the Assumptions module
' of the Stochastic Model

exec .\setup2
pageselect a

!TRYEAR = 2022

!TRYR = !TRYEAR - 2000
!FIRST_RAWDATA_YEAR = !TRYEAR - 9
%EXCEL_WORKBOOK = "EconMeans" + @str(!TRYEAR) + "tr"

for %alt 2 1 3
   wfopen atr{!TRYR}{%alt}
   pageselect a
   for %s cpiw_u ru acwa
      copy {%s} work::a\{%s}
   next
   pageselect m
   copy nomintr work::a\nomint
   close atr{!TRYR}{%alt}
   if (%alt = "2") then
      pagesave(type=excel,mode=update,noid) {%EXCEL_WORKBOOK}.xls range="rawdata!B3" @keep cpiw_u ru @smpl {!FIRST_RAWDATA_YEAR} 2100
      pagesave(type=excel,mode=update,noid) {%EXCEL_WORKBOOK}.xls range="rawdata!D3" @keep acwa nomint @smpl {!FIRST_RAWDATA_YEAR} 2100
   else
   if (%alt = "1") then
      pagesave(type=excel,mode=update,noid) {%EXCEL_WORKBOOK}.xls range="rawdata!N3" @keep cpiw_u ru @smpl {!FIRST_RAWDATA_YEAR} 2100
      pagesave(type=excel,mode=update,noid) {%EXCEL_WORKBOOK}.xls range="rawdata!P3" @keep acwa nomint @smpl {!FIRST_RAWDATA_YEAR} 2100 
   else
   if (%alt = "3") then
      pagesave(type=excel,mode=update,noid) {%EXCEL_WORKBOOK}.xls range="rawdata!Z3" @keep cpiw_u ru @smpl {!FIRST_RAWDATA_YEAR} 2100
      pagesave(type=excel,mode=update,noid) {%EXCEL_WORKBOOK}.xls range="rawdata!AB3" @keep acwa nomint @smpl {!FIRST_RAWDATA_YEAR} 2100    
   endif
   endif
   endif
next

delete *
close @wf

