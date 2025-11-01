' Thisprogram checks the values in cps_nilf_monthly_for_checking.wf1 for reasonablness
' The workfile cps_nilf_monthly_for_checking.wf1 is created by the program transform_nilf_monthly.prg
' This program checks whether the series rnl.... and pl.... exceed 1 in any period (they should not)

' Run this program, note the series and periods where they exceed 1 (they will pop up on the screen), and do the MANUAL adjustment of these values within the transform_nilf_monthly.prg
' To record the results, this program produces a workfile named cps_nilf_monthly_checked.wf1 Look for tables named warning_{seriesname} to see all series that violated the check.

' The program assumes that file cps_nilf_monthly_for_checking.wf1 is in the DEFAULT location and it will save file cps_nilf_monthly_checked.wf1 intot he DEFAULT location.
' Make sure the default location is set accordingly.

' Polina Vlasenko


logmode logmsg

logmode l
%msg = "Loading cps_nilf_monthly_for_checking. This may take a few minutes." 
logmsg {%msg}
logmsg

tic

wfopen cps_nilf_monthly_for_checking.wf1

%last_yr = "2019"		'latest year for which we have CPS NILF data; typically we would have data for only part of the year, usually through September
%last_mo = "9"			' the last month in the %last_yr for which we have data; typically this is September, i.e. month 9
%last_qr = "3"				' the last quarter in the %last_yr for which we have data (for the entire quarter); typically we have data through September, i.e. quarter 3
%last_full_yr = "2018"	'last year for which we have FULL YEAR of CPS NILF data

%msg = "Checking values for rnl... and pl... series, monthly " 
logmsg {%msg}
logmsg

pageselect m
smpl 1994 {%last_yr}

%age = _
   "16 17 18 19 " + _
   "20 21 22 23 24 25 26 27 28 29 " + _
   "30 31 32 33 34 35 36 37 38 39 " + _
   "40 41 42 43 44 45 46 47 48 49 " + _
   "50 51 52 53 54 55 56 57 58 59 " + _
   "60 61 62 63 64 65 66 67 68 69 " + _
   "70 71 72 73 74 75 76 77 78 79 " + _
   "80 81 82 83 84 85 86 87 88 89 " + _
   "90"

for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %c r1 d1 o1 d2 r2 i s h o2 dc o3
 		smpl 1994 {%last_yr} if rnl{%s}{%a}_{%c}>1.0001
 		if @obssmpl>0 then 
 			freeze(warning_rnl{%s}{%a}_{%c}) rnl{%s}{%a}_{%c}.sheet
 			show warning_rnl{%s}{%a}_{%c}
 		endif
 		smpl 1994 {%last_yr}
 	next
 next
next

for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %c r1 d1 o1 d2 r2 i s h o2 dc o3
 		for %m nm ms ma
 			smpl 1994 {%last_yr} if rnl{%s}{%a}{%m}_{%c} >1.0001
 			if @obssmpl>0 then 
 				freeze(warning_rnl{%s}{%a}{%m}_{%c}) rnl{%s}{%a}{%m}_{%c}.sheet
 				show warning_rnl{%s}{%a}{%m}_{%c}
 			endif
 			smpl 1994 {%last_yr}
 		next
 	next
 next
next

for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	smpl 1994 {%last_yr} if pl{%s}{%a} >1.0001
 	if @obssmpl>0 then 
 		freeze(warning_pl{%s}{%a}) pl{%s}{%a}.sheet
 		show warning_pl{%s}{%a}
 	endif
 	smpl 1994 {%last_yr}
 next
next

for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %m nm ms ma
 		smpl 1994 {%last_yr} if pl{%s}{%a}{%m} >1.0001
 		if @obssmpl>0 then 
 			freeze(warning_pl{%s}{%a}{%m}) pl{%s}{%a}{%m}.sheet
 			show warning_pl{%s}{%a}{%m}
 		endif
 		smpl 1994 {%last_yr}
 	next
 next
next

%msg = "Done -- values for rnl... and pl... exceeding 1 are shown on screen. " 
logmsg {%msg}
logmsg

%msg = "Saving the workfile as cps_nilf_monthly_checked.wf1 " 
logmsg {%msg}
logmsg

wfsave cps_nilf_monthly_checked

!runtime = @toc
%msg = "Done... Runtime " + @str(!runtime) + " sec" 
logmsg {%msg}


