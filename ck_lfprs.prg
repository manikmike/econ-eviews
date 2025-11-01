' ck_lfpr.prg
' This program makes a number of comparison of the projected LFPRs and related series for a given TR projection, compared to prior-TR projections.
' This comparison is intended as a check for LFPR projections in the course of developoing the TR projections.

' ---- Polina Vlasenko

' ***** UPDATE parameters here *****
!TRa = 2022		' can compare not only two adjacent TR, but ANY two TRs, so eneter both values. Also, can compare two alts from the same TR -- in this case, enter the same Tr year in both places.
!TRb = 2021
%alta = "2"  	' allows to use this program to compare two alts for the same TR 
%altb = "2"  	' in principle, this can be ANY text; it is used below to create %tralta and %traltb;
					' enter here some identofier of the run being compared

%tralta = @str(!TRa-2000) + %alta
%traltb = @str(!TRb-2000) + %altb

%lfpr55100a = "lfpr_proj_55100_tr222"  	' file name for the file corresponding to TRa; assumes that (1) it is in the default folder; and (2) it is a workfile.
%lfpr55100b = "lfpr_proj_55100_tr212"

%abanka = "atr222"  ' in the future, BOTH of these will be workfiles
%abankb = "atr212" 	' for now, this one of a databank

' file created by this program
%thisfile = "ck_lfpr_tr" + %tralta + "_vs_tr" + %traltb

' ***** END of the update section

' *** Define some useful parameters

' age groups to be used in loops
%age5yr = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074"
%age5574 = "55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74"
%age75100 = "75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100"
%ageaggr = "65o 70o 75o 80o 85o 16o"

' create workfile
exec ./setup2
wfsave {%thisfile}
pageselect q
smpl @all

' *** Copy in series from various other files

' MSshare and Edscore from lfpr_proj_55100 files

wfopen {%lfpr55100a} 		' this file has pages a, q, m, vars, dated from 1900 to 2100; almost all of the data are in page q; page a has very little data, other pages are empty
pageselect q
smpl @all

for %s m f 
	for %a {%age5574}
		copy {%lfpr55100a}::q\edscore{%s}{%a} {%thisfile}::q\edscore{%s}{%a}_tr{%tralta}
		copy {%lfpr55100a}::q\msshare_{%s}{%a} {%thisfile}::q\msshare_{%s}{%a}_tr{%tralta}
	next
next										
wfclose {%lfpr55100a}


wfopen {%lfpr55100b} 		' this file has pages a, q, m, vars, dated from 1900 to 2100;
									' almost all of the data are in page q; page a has very little data, other pages are empty
wfselect {%thisfile}
pageselect q
smpl @all

' copy relevant series into the file and append the _tr212 extension
for %s m f 
	for %a {%age5574}
		copy {%lfpr55100b}::q\edscore{%s}{%a} {%thisfile}::q\edscore{%s}{%a}_tr{%traltb}
		copy {%lfpr55100b}::q\msshare_{%s}{%a} {%thisfile}::q\msshare_{%s}{%a}_tr{%traltb}
	next
next

wfclose {%lfpr55100b}


' LFPRs from Abanks
wfopen {%abanka} 		
pageselect q

wfselect {%thisfile}
pageselect q
smpl @all

for %s m f
	for %a {%age5574} {%age75100} {%age5yr} {%ageaggr}
		copy {%abanka}::q\p{%s}{%a} {%thisfile}::q\p{%s}{%a}_tr{%tralta}
	next
next

wfclose {%abanka}

wfopen {%abankb} 		
pageselect q

wfselect {%thisfile}
pageselect q
smpl @all

for %s m f
	for %a {%age5574} {%age75100} {%age5yr} {%ageaggr}
		copy {%abankb}::q\p{%s}{%a} {%thisfile}::q\p{%s}{%a}_tr{%traltb}
	next
next

wfclose {%abankb}


'' ***NOTE*** Generally, do the same for %abankb -- when it is a WORKFILE -- DONE above (08/22/2023). 
'' Retaining the code below for now, in case we need to compare to older databanks
'
'dbopen(type=aremos){%abankb}.bnk
'wfselect {%thisfile}
'pageselect q
'smpl @all
'
'for %s m f
'	for %a {%age5574} {%age75100} {%age5yr} {%ageaggr}
'		fetch p{%s}{%a}.q 
'		rename p{%s}{%a} p{%s}{%a}_tr{%traltb}
'	next
'next
'
'close @db
'
'wfselect {%thisfile}
'pageselect q
'smpl @all


' Create the comparisons we need
wfselect {%thisfile}
pageselect q
smpl @all

' LFPRs -- change between two TRs
for %s m f
	for %a {%age5574} {%age75100} {%age5yr} {%ageaggr}
		series ck_p{%s}{%a} = p{%s}{%a}_tr{%tralta} - p{%s}{%a}_tr{%traltb}
		
	next
next

' MSshare and Edscore -- change between two TRs
for %s m f 
	for %a {%age5574}
		series ck_edscore{%s}{%a} = edscore{%s}{%a}_tr{%tralta} - edscore{%s}{%a}_tr{%traltb}
		series ck_msshare{%s}{%a} = msshare_{%s}{%a}_tr{%tralta} - msshare_{%s}{%a}_tr{%traltb}
	next
next

' Create  useful lists for charts and tables
%l_pf5574 = "" 	' LFPRs for F 55 to 74
%l_pm5574 = "" 	' LFPRs for M 55 to 74
%l_msf5574 = "" 	' MSshare for F 55 to 74
%l_msm5574 =  "" 	' MSshare for M 55 to 74
%l_edf5574 =  "" 	' Edscore for F 55 to 74
%l_edm5574 =  "" 	' Edscore for M 55 to 74

for %a {%age5574}
	%l_pf5574 = %l_pf5574 + "ck_pf" + %a + " "
	%l_pm5574 = %l_pm5574 + "ck_pm" + %a + " "
	%l_msf5574 = %l_msf5574 + "ck_mssharef" + %a + " "
	%l_msm5574 = %l_msm5574 + "ck_mssharem" + %a + " "
	%l_edf5574 = %l_edf5574 + "ck_edscoref" + %a + " "
	%l_edm5574 = %l_edm5574 + "ck_edscorem" + %a + " "
next
		
%l_pf75100 = "" 		 ' LFPRs for F 75 to 100
%l_pm75100 = "" 	' LFPRs for M 75 to 100
for %a {%age75100}
	%l_pf75100 = %l_pf75100 + "ck_pf" + %a + " "
	%l_pm75100 = %l_pm75100 + "ck_pm" + %a + " "
next

%l_pf55100 = %l_pf5574 + %l_pf75100	' LFPRs for F 55 to 100
%l_pm55100 = %l_pm5574 + %l_pm75100 	' LFPRs for M 55 to 100

%l_pf5yr = "" 	' LFPRs for F 1617 to 7074
%l_pm5yr = "" 	' LFPRs for M 1617 to 7074

for %a {%age5yr}
	%l_pf5yr = %l_pf5yr + "ck_pf" + %a + " "
	%l_pm5yr = %l_pm5yr + "ck_pm" + %a + " "
next

' Create tables
wfselect {%thisfile}
pageselect q
smpl 2010Q1 @last

group ck_pm_SYOA {%l_pm55100}
group ck_pf_SYOA {%l_pf55100}
group ck_pm_SYOA5574 {%l_pm5574}
group ck_pf_SYOA5574 {%l_pf5574}
group ck_pm_5yr {%l_pm5yr} 
group ck_pf_5yr {%l_pf5yr} 
group ck_pm_aggr ck_pm65o ck_pm70o ck_pm75o ck_pm80o ck_pm85o ck_pm16o
group ck_pf_aggr ck_pf65o ck_pf70o ck_pf75o ck_pf80o ck_pf85o ck_pf16o
group ck_msm {%l_msm5574}
group ck_msf {%l_msf5574}
group ck_edm {%l_edm5574}
group ck_edf {%l_edf5574}


' Create charts and tables
wfselect {%thisfile}
pageselect q
smpl 2010Q1 @last

' Titles for charts and tables
%titleg = "Difference = TR" + %tralta + " - TR" + %traltb
%titlet = "CK_{series} = TR" + %tralta + " - TR" + %traltb

' this loop makes charts an dtables for the ck_.... series. i.e. the DIFFERENCE betwee the two versions being compares
for %gr ck_pm_SYOA ck_pf_SYOA ck_pm_SYOA5574 ck_pf_SYOA5574 ck_msm ck_msf ck_edm ck_edf ck_pm_5yr ck_pf_5yr ck_pm_aggr ck_pf_aggr
	freeze(g_{%gr}) {%gr}.line 				' create a chart
	g_{%gr}.addtext(font(+b), t) %titleg 	' insert title to a chart
	freeze(t_{%gr}) {%gr}.sheet  			' create a table
	t_{%gr}.title %titlet 					' title for each table
next



' make the lists that create groups for LEVELs

for %v tr{%tralta} tr{%traltb}
	%ll_pf5574_{%v} = "" 	' LFPRs for F 55 to 74
	%ll_pm5574_{%v} = "" 	' LFPRs for M 55 to 74
	%ll_msf5574_{%v} = "" 	' MSshare for F 55 to 74
	%ll_msm5574_{%v} =  "" 	' MSshare for M 55 to 74
	%ll_edf5574_{%v} =  "" 	' Edscore for F 55 to 74
	%ll_edm5574_{%v} =  "" 	' Edscore for M 55 to 74

	for %a {%age5574}
		%ll_pf5574_{%v} = %ll_pf5574_{%v} + "pf" + %a + "_" + %v + " "
		%ll_pm5574_{%v} = %ll_pm5574_{%v} + "pm" + %a + "_" + %v + " "
		%ll_msf5574_{%v} = %ll_msf5574_{%v} + "msshare_f" + %a + "_" + %v + " "
		%ll_msm5574_{%v} = %ll_msm5574_{%v} + "msshare_m" + %a + "_" + %v + " "
		%ll_edf5574_{%v} = %ll_edf5574_{%v} + "edscoref" + %a + "_" + %v + " "
		%ll_edm5574_{%v} = %ll_edm5574_{%v} + "edscorem" + %a + "_" + %v + " "
	next

	%ll_pf5yr_{%v} = "" 	' LFPRs for F 1617 to 7074
	%ll_pm5yr_{%v} = "" 	' LFPRs for M 1617 to 7074

	for %a {%age5yr}
		%ll_pf5yr_{%v} = %ll_pf5yr_{%v} + "pf" + %a + "_" + %v + " "
		%ll_pm5yr_{%v} = %ll_pm5yr_{%v} + "pm" + %a + "_" + %v + " "
	next
next


wfselect {%thisfile}
pageselect q
smpl 2010Q1 @last

' this loop makes tables (no charts) with LEVELS of the variables (LFPRs, Edscore, MSshare)
for %v tr{%tralta} tr{%traltb}
	' make groups, then tables, then assign title
	%title = "LFPRs as projected in " + %v
	
	group pm_SYOA5574_{%v} {%ll_pm5574_{%v}}
	freeze(t_pm_SYOA5574_{%v}) pm_SYOA5574_{%v}.sheet
	t_pm_SYOA5574_{%v}.title {%title}
	
	group pf_SYOA5574_{%v} {%ll_pf5574_{%v}}
	freeze(t_pf_SYOA5574_{%v}) pf_SYOA5574_{%v}.sheet
	t_pf_SYOA5574_{%v}.title {%title}
	
	group pm_5yr_{%v} {%ll_pm5yr_{%v}} 
	freeze(t_pm_5yr_{%v}) pm_5yr_{%v}.sheet
	t_pm_5yr_{%v}.title {%title}
	
	group pf_5yr_{%v} {%ll_pf5yr_{%v}} 
	freeze(t_pf_5yr_{%v}) pf_5yr_{%v}.sheet
	t_pf_5yr_{%v}.title {%title}
	
	group pm_aggr_{%v} pm65o_{%v} pm70o_{%v} pm75o_{%v} pm80o_{%v} pm85o_{%v} pm16o_{%v}
	freeze(t_pm_aggr_{%v}) pm_aggr_{%v}.sheet
	t_pm_aggr_{%v}.title {%title}
	
	group pf_aggr_{%v} pf65o_{%v} pf70o_{%v} pf75o_{%v} pf80o_{%v} pf85o_{%v} pf16o_{%v}
	freeze(t_pf_aggr_{%v}) pf_aggr_{%v}.sheet
	t_pf_aggr_{%v}.title {%title}
	
	group msm_{%v} {%ll_msm5574_{%v}}
	freeze(t_msm_{%v}) msm_{%v}.sheet
	%title = "MSshare series as projected in " + %v
	t_msm_{%v}.title {%title}
	
	group msf_{%v} {%ll_msf5574_{%v}}
	freeze(t_msf_{%v}) msf_{%v}.sheet
	%title = "MSshare series as projected in " + %v
	t_msf_{%v}.title {%title}
	
	group edm_{%v} {%ll_edm5574_{%v}}
	freeze(t_edm_{%v}) edm_{%v}.sheet
	%title = "Edscore series as projected in " + %v
	t_edm_{%v}.title {%title}
	
	group edf_{%v} {%ll_edf5574_{%v}}
	freeze(t_edf_{%v}) edf_{%v}.sheet
	%title = "Edscore series as projected in " + %v
	t_edf_{%v}.title {%title}
	
next

' ALL tables and charts are now made

wfsave {%thisfile}

' Can add commands to save tables in CSV, if deried


