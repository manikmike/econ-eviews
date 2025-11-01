' This program exports the Monthly, Quarterly, and March
' military data to an Excel workbook in order to check
' whether the source data matches what is in the 
' bkdo1 and bkdr1 workfiles

!TRYEAR = 2025
!LAST_DATA_YEAR = !TRYEAR - 1

%FILENAME = "military - excel export.xlsx"

exec .\setup2

' Monthly
wfopen bkdo1.wf1
wfselect work
pageselect m
smpl 2020M4 {!LAST_DATA_YEAR}M12
copy bkdo1::m\edmil work::m\edmil
close bkdo1
pagesave(type=excelxml, mode=update) %FILENAME range="MONTHLY!A1" @smpl 2020M4 {!LAST_DATA_YEAR}M12

' Quarterly
wfopen bkdr1.wf1
wfselect work
pageselect q
smpl 2020Q2 {!LAST_DATA_YEAR}Q4

for %s m f
  genr n{%s}m = 0
  for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559
    genr n{%s}{%a}m = bkdr1.wf1::q\n{%s}{%a}m
    n{%s}m = n{%s}m + n{%s}{%a}m
  next
next
close bkdr1
pagesave(type=excelxml, mode=update) %FILENAME range="QUARTERLY!A1" @smpl 2020Q2 {!LAST_DATA_YEAR}Q4

' March
wfopen bkdr1.wf1
wfselect work
pageselect a
smpl 2021 {!LAST_DATA_YEAR}

for %s m f
  genr n{%s}m_3 = 0
  for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559
    genr n{%s}{%a}m_3 = bkdr1.wf1::a\n{%s}{%a}m_3
    n{%s}m_3 = n{%s}m_3 + n{%s}{%a}m_3
  next
next
close bkdr1
pagesave(type=excelxml, mode=update) %FILENAME range="MARCH!A1" @smpl 2021 {!LAST_DATA_YEAR}

close work


