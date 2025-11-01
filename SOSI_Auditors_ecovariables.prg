' This program places data requested by the Ernst Young auditors from the 2023
' Trustees Report Intermediate alternative in an Excel file.

' Store user name in variable.
%usrnm = @env("username")

' Set up temprorary workfile.
exec c:\Users\{%usrnm}\GitRepos\econ-eviews\setup2.prg

' Store Trustees Report year in variable.
!yrtr = 2023
' Set first year after short-range period year.
!yrasr = !yrtr + 10
' Set first output year.
!yrfo = 1980
' Set last year of data on ssaprogdata.
!yrlso = !yrtr - 2
' Set last output year.
!yrlo = !yrtr + 74

' Store name of folder containing A workfile.
%swff = "S:\LRECON\ModelRuns\TR2023\2023-0127-1550-TR232\out\mul\"
' Convert TR year to string.
%syrtr = @str(!yrtr)
' Store last two digits of TR year in string variable.
%syrtrr2 = @right(%syrtr, 2)
' Set string variable for A workfile.
%swf = "atr" + %syrtrr2 + "2.wf1"
' Set full path of A workfile.
%swffp = %swff + %swf
' Set full path of intermediate Excel file to contain data.
%xlfile = "S:\LRECON\TrusteesReports\TR" + %syrtr + _
          "\Requests\SOSI\RelatedFiles\SOSI_Auditors_ecovariables_tr" + _
          %syrtrr2 + "2Prelim.xlsx"

' Store names of output series as character variable.
%nameso = "gdp gdp12 tothrs ahrs lc e ew es edmil eu te tefc_n tcea seo cmb wsd y wsca cse_tot oasdi_tw oasdise_ti oasdi_merw oasdi_etp"

' Store names of input series on ssaprogdata.
%namess = "cse_tot oasdi_tw oasdise_ti oasdi_merw oasdi_etp"
' Store names of input series on atr232.
%namesa = "gdp gdp12 tothrs ahrs lc e eaw enaw eas enas edmil eau enau te tefc_n tcea seo cmb wsd y wsca cse_tot oasdi_tw oasdise_ti oasdi_merw oasdi_etp"

' Open workfile containing historical taxable earnings.
open c:\Users\{%usrnm}\GitRepos\econ-ecodev\dat\ssaprogdata.wf1

' Select annual frequency.
pageselect a

 'Get needed series from bank.
for %s {%namess}
  copy %s work::a\
next

' Close workfile containing historical taxable earnings.
close ssaprogdata

' Select annual frequency in temporary workfile.
pageselect a

' Store historical values for OASDI covered self-employment earnings, taxable
' wages, multi-employer refund wages, and self-employment income in series for
'later use.
smpl !yrfo 1990
series cse_tot_s = cse_tot
smpl !yrfo !yrlso
series oasdi_tw_s = oasdi_tw
series oasdi_merw_s = oasdi_merw
series oasdise_ti_s = oasdise_ti
series oasdi_etp_s = oasdi_etp

' Open A workfile.
open %swffp

' Select annual frequency.
pageselect a

' Get needed values from bank.
for %s {%namesa}
  copy %s work::a\
next

' Close A workfile.
close %swf

' Select annual frequency in temporary workfile.
pageselect a

' Store historical covered and taxable values in series to be written to Excel
' file.
smpl !yrfo 1990
series cse_tot = cse_tot_s
smpl !yrfo !yrlso
series oasdi_tw = oasdi_tw_s
series oasdi_merw = oasdi_merw_s
series oasdise_ti = oasdise_ti_s
series oasdi_etp = oasdi_etp_s

smpl !yrfo !yrlo

' Add agricultural and non-agricultural values to get total wage workers,
' self-employesd workers, and unpaid family workers.
series ew = eaw + enaw
series es = eas + enas
series eu = eau + enau

' Write data to Excel file.
wfsave(type=excelxml, mode=update) _
  %xlfile range="DATA!A2" @smpl !yrfo !yrlo @keep {%nameso}

close @all
