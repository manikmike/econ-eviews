' This program produces series needed for the check on the cpso_nilf databank.
' It produces two groups (annual and monthly) that are ordered in a way consistent with the Excel spreadsheet
' The user must freeze the group, and then cut and paste the data into an excel spreadsheet.
' The Excel spreadsheet is check_cpso_nilf_trYY.xlsx where YY is the two-digit representation of the Trustees Report year
' The Excel spreadsheet compares cpso_nilf variables from the TRYY cpso_nilf.wf1 to data published by BLS and 
'   stored on a worksheet in same Excel file. It notes any differences between data imported from cpso_nilf and that from the BLS.
' Annual data for the latest full year, and monthly data for the last 12 months are examined.

' 1. Update %folder to point to the correct data
' 2. Update !yr and %mon to identify the appropriate years/months to pull the data for

' The data to be plugged into the Excel check workbook is in 
' tables _annual and _monthly (in page a and page m, respectively) OR
' groups g_ann and g_mon (in page a and page m, respectively)

' !!!!! SAVE WORKFILE MANNUALLY WHEN DONE !!!!!!


!yr = 2023 	' indicate here the year for which to pull ANNUAL data (usually it is just one year)

%mon = "2023m10 2024m09" 	' indicate here the period for which to pull the MONTHLY data

%folder = "C:\GitRepos\econ-ecodev\dat" 	' folder that holds the file cpso_nilf.wf1 for the TR you are checking

%cpsofile = %folder + "\cpso_nilf.wf1"

wfcreate(wf=ck_cpso_nilf, page=a) a !yr !yr
pagecreate(wf=ck_cpso_nilf, page=m) m {%mon}

pageselect a
wfopen {%cpsofile}
for %ser NM16O EM16O UM16O NF16O EF16O UF16O NM16OMS EM16OMS UM16OMS NF16OMS EF16OMS UF16OMS NM16OMA EM16OMA UM16OMA NF16OMA EF16OMA UF16OMA NM16ONM EM16ONM UM16ONM NF16ONM EF16ONM UF16ONM
	copy cpso_nilf::a\{%ser} ck_cpso_nilf::a\*
next

wfselect ck_cpso_nilf
pageselect m
for %ser NM16O EM16O UM16O NF16O EF16O UF16O NM16OMS EM16OMS UM16OMS NF16OMS EF16OMS UF16OMS NM16OMA EM16OMA UM16OMA NF16OMA EF16OMA UF16OMA NM16ONM EM16ONM UM16ONM NF16ONM EF16ONM UF16ONM 
	copy cpso_nilf::m\{%ser} ck_cpso_nilf::m\*
next

wfclose cpso_nilf

wfselect ck_cpso_nilf
pageselect a
group g_ann NM16O NM16OMA NM16OMS NM16ONM NF16O NF16OMA NF16OMS NF16ONM EM16O EM16OMA EM16OMS EM16ONM EF16O EF16OMA EF16OMS EF16ONM UM16O UM16OMA UM16OMS UM16ONM UF16O UF16OMA UF16OMS UF16ONM
freeze(_annual) g_ann.sheet(t)

pageselect m
group g_mon NM16O NM16OMA NM16OMS NM16ONM NF16O NF16OMA NF16OMS NF16ONM EM16O EM16OMA EM16OMS EM16ONM EF16O EF16OMA EF16OMS EF16ONM UM16O UM16OMA UM16OMS UM16ONM UF16O UF16OMA UF16OMS UF16ONM
freeze(_monthly) g_mon.sheet(t)


