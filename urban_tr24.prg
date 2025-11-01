' This program creates the spreadsheet urban_23.xlsx for the data request
' from the Urban Institute

' Required input : atr242.wf1,  atr241.wf1, atr243.wf1,
'                  dtr242.wf1,  dtr241.wf1, dtr243.wf1, 
'				   op1242o.wf1, op1241o.wf1, op1243o.wf1 
'				  Note: the atr and dtr workfiles are output files from TR24 model runs. They are located at 
'					S:\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul,
'					S:\LRECON\ModelRuns\TR2024\2024-0215-0905-TR241\out\mul, and
'					S:\LRECON\ModelRuns\TR2024\2024-0215-0946-TR243\out\mul. 
'                  The op workfiles can also be found among the TR24 model run files, at C:\Users\Pin\GitRepos\econ-ecodev\dat
'					

' Required output: Formatted Excel Workbook urban_24.xlsx - the excel file will be created when you execute this program.

exec .\setup2

logmode logmsg

' Update these parameters each year
!TRYEAR = 2024
!FIRST_PROJECTED_YEAR = !TRYEAR - 1
!LAST_PROJECTED_YEAR = !TRYEAR + 74
%WORKBOOK = "urban_" + @right(@str(!TRYEAR),2)

' Each of the (nested) loop variables is iterated in reverse order
' because worksheets are added to the Excel workbook
' in reverse order (right to left)
for %var EPOP_Ratio LFPR Cov_Wkr_Rates
   for %sex Female Male
      for %alt 3 2 1

         ' Create the workfile page
         %page = %var + "_" + %sex + "_Alt_" + %alt
         if (%alt = "2") then
            pagecreate(page=%page) a 1971 {!LAST_PROJECTED_YEAR}
         else
            pagecreate(page=%page) a {!FIRST_PROJECTED_YEAR} {!LAST_PROJECTED_YEAR}
         endif
         series _year = @year

         ' Create the series variable names
         ' Age groups
         %s = @lower(@left(%sex,1)) ' f or m
         for %ageGroup 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o 16o
            if (%var = "Cov_Wkr_Rates") then
               series cwr{%s}{%ageGroup}
            else
               if (%var = "LFPR") then
                  series p{%s}{%ageGroup}
               else ' %var = EPOP_Ratio
                  series ep{%s}{%ageGroup}
               endif
            endif
         next

         group g
         g.add * not resid _year

         ' Open the proper workfiles
         %awf = "atr" + @str(!TRYEAR-2000) + %alt
         wfopen {%awf}
			wfselect work
			
         %dwf = "dtr" + @str(!TRYEAR-2000) + %alt
         wfopen {%dwf}
			wfselect work

         %popwf = "op" + @str(!TRYEAR-1900) + %alt + "o"
         wfopen {%popwf}
			wfselect work


         ' Calculate (or just assign) the proper values
         if (%var = "Cov_Wkr_Rates") then
            genr ce{%s}16o = 0 ' not in the bank, so we need to compute it
            for %ageGroup 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
               cwr{%s}{%ageGroup} = {%awf}::ce{%s}{%ageGroup} / {%popwf}::n{%s}{%ageGroup}
               ce{%s}16o = ce{%s}16o + {%awf}::ce{%s}{%ageGroup}
            next
            cwr{%s}16o = ce{%s}16o / {%popwf}::n{%s}16o
            delete ce{%s}16o ' delete so it doesn't get imported to Excel         
         else 
            if (%var = "LFPR") then
               for %ageGroup 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o 16o
                  p{%s}{%ageGroup} = {%awf}::p{%s}{%ageGroup}
               next
            else ' %var = EPOP_Ratio
               for %ageGroup 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
                  ep{%s}{%ageGroup} = {%awf}::e{%s}{%ageGroup} / {%dwf}::n{%s}{%ageGroup}
               next
               ep{%s}16o = {%awf}::e{%s} / {%dwf}::n{%s}16o
            endif
         endif
         
         ' Change any missing historical values from NaN to 0 so that they show up in Excel as dashes
         %slist = g.@members
         for %ser {%slist}
            {%ser} = @nan({%ser},0)
         next

         ' Export the series to Excel
         %worksheet = @replace(%var,"_"," ") + " " + %sex + " Alt " + %alt
         ' Since series are saved in lexicographical order, we need two save statements to put 16o groups at the end
         %range = %worksheet + "!a6"
         pagesave(type=excelxml, mode=update, noid) {%WORKBOOK} nonames range=%range @smpl @all @drop *16o
         %range = %worksheet + "!o6"
         pagesave(type=excelxml, mode=update, noid) {%WORKBOOK} nonames range=%range @smpl @all @keep *16o
      ' Close the workfile
    close {%awf}
	close {%dwf}
	close {%popwf}      
'close {%wf}

      next
   next
next


