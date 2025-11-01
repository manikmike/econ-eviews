' This programs creates the spreadsheet for the data request
' from the Urban Institute

' Required input : atr232.wf1, atr231.wf1, atr233.wf1, cnipopdata.wf1,
'                  dtr232.wf1, dtr231.wf1, dtr233.wf1 
'				  Note: the atr and dtr files are output files from TR23 model runs. They are located at 
'					S:\LRECON\ModelRuns\TR2023\2023-0127-1550-TR232\out\mul,
'					S:\LRECON\ModelRuns\TR2023\2023-0130-1056-TR231\out\mul, and
'					S:\LRECON\ModelRuns\TR2023\2023-0130-1358-TR233\out\mul.
' 					And cnipopdata.wf1 can be found in the econ-ecodev/dat repo.
 
' Required output: Formatted Excel Workbook syoa_pop_lfpr_tr2023.xlsx (The excel file will be created when you run this program.)

exec .\setup2

logmode logmsg

' Update these parameters each year
!TRYEAR = 2023
!FIRST_PROJECTED_YEAR = !TRYEAR - 2
!LAST_PROJECTED_YEAR = 2100
%WORKBOOK = "syoa_pop_lfpr_tr" + @str(!TRYEAR) + "data"

' Each of the (nested) loop variables is iterated in reverse order
' because worksheets are added to the Excel workbook
' in reverse order (right to left)
for %alt 3 1 2
   for %var LFPR CNIPOP
      for %sex Male Female

         ' Create the workfile page
         %page = %sex + "_" + %var + "_Alt" + %alt
         if (%alt = "2") then
            pagecreate(page=%page) a 1968 {!LAST_PROJECTED_YEAR}
         else
            pagecreate(page=%page) a {!FIRST_PROJECTED_YEAR} {!LAST_PROJECTED_YEAR}
         endif
         series _year = @year

         ' Create the series variable names
         ' Age groups
         %s = @lower(@left(%sex,1)) ' f or m
         for %ageGroup 1617 1819 2024 2529 3034 3539 4044 4549 5054 80o
            if (%var = "CNIPOP") then
               series n{%s}{%ageGroup}
            else '%var = LFPR
               series p{%s}{%ageGroup}
            endif
         next
         ' Single-year of age
         for !age = 55 to 79
            if (%var = "CNIPOP") then
               series n{%s}{!age}
            else '%var = LFPR
               series p{%s}{!age}
            endif
         next
         group g
         g.add * not resid _year

         ' Open the proper databanks
         if (%var = "CNIPOP") then
            %wf = "dtr" + @str(!TRYEAR-2000) + %alt + ".wf1"
            wfopen {%wf}
            wfselect work
         else ' %var = "LFPR"
            %wf = "atr" + @str(!TRYEAR-2000) + %alt + ".wf1"
            wfopen {%wf}            
            wfselect work
         endif
         
         ' Copy the series from the workfiles
         %slist = g.@members
         for %ser {%slist}
            copy {%wf}::a\{%ser} {%ser}
            {%ser} = @nan({%ser},0)
         next

         ' Copy some additional historical single-year of age data
         if (%alt = "2") then
            %s = @lower(@left(%sex,1)) ' f or m
            wfopen cnipopdata.wf1
            wfselect work
            if (%var = "CNIPOP") then
               smpl 2001 2003
               for !age = 55 to 79
                  n{%s}{!age} = cnipopdata.wf1::a\n{%s}{!age}_census
                  n{%s}{!age} = @nan(n{%s}{!age},0)
               next
            else '%var = LFPR
               smpl 1968 2003
               for !age = 55 to 79
                  p{%s}{!age} = cnipopdata.wf1::a\p{%s}{!age}
                  p{%s}{!age} = @nan(p{%s}{!age},0)
               next
            endif
            close cnipopdata
            smpl @all
         endif

         ' Export the series to Excel
         %worksheet = %sex + " " + %var + " Alt - " + %alt
         %range = %worksheet + "!a7"
         pagesave(type=excelxml, mode=update, noid) {%WORKBOOK} nonames range=%range @smpl @all

         ' Close the workfile
         close {%wf}
      next

   next
next


