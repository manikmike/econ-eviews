' This program compares the full set of LFPRs between two versions of a TR run.

' Polina Vlasenko

' !!!! This version COMMENTED OUT all parts that load things from lfpr_proj files.

' Describe what we are comparing

%v1 = "TR24"
%v2 = "TR25"
%v3 = "NONE"  ' set to "NONE" if not using; ALL CAPS (case sensitive)

' source files for the things being compared

%path_v1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul\atr242.wf1"
%file_v1 = "atr242"

%path_v2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0106-1433-TR252\out\mul\atr252.wf1"
%file_v2 = "atr252"

%path_v3 = ""
%file_v3 = ""

' EViews workfiles with projected LFPRs -- we get the estimated equations from here, not the LFPRs
%path_projfiles_v1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\dat\"  ' the folder
%path_projfiles_v2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0106-1433-TR252\dat\"  ' the folder
%path_projfiles_v3 = ""  ' the folder
%file_proj1654 = "lfpr_proj_1654"
%file_proj55100 = "lfpr_proj_55100"

' Specify the dates for whcih to construct age profile for SYOA LFPRs
' NOTE: these must be NAMED consecutively with no gaps  -- i.e. we must have %date1, %date2, %date3 etc, BUT NOT %date1, %date3, %date4 (this omits %date2). No omitted %dates!!!! The date values themselves can be in any order. 
%date1 = "2024Q3"	' last historical for cpso_nilf data used in projecting SYOA LFPRs
%date2 = "2024Q4"	' first projected period
%date3 = "2034Q4" 	' end of SR period
%date4 = "2062Q4" 	' mid-point of projections
%date5 = "2099Q4" 	' end of projection period
!ndate = 5				' indicates we have 5 special dates; if we add/remove dates, adjust this number accordingly

!tol = 0.001 				' Tolerance leven to determine which differences are considred "large"; 0.01 = 1 percentage point

' Lists to construct the LFPRs to compare

%age5yr = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579"
%agesy1 = "55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74"
%agesy2 = "75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100"
%ageagr = "65o 70o 75o 80o 85o 16o"

' Output file created by thisprogram
%output_path="C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\TR2025\Checks\"
if %V3 = "NONE" then
	%output_file = "LFPRs_" + %v2 + "_vs_" + %v1
	else %output_file = "LFPRs_" + %v3 + "_vs_" + %v2 + "_vs_" + %v1
endif
 

'*** Done with the header section that needs updating

' **** Create the workfile
%startyr = "2010Q1"
%endyr = "2105Q4"

wfcreate(wf={%output_file}, page=q) q %startyr %endyr
smpl @all

' copy LFPRs to be compare
' For V1 !!!WORKFILE!!!
wfopen %path_v1
for %s m f
	for %a {%age5yr}
		copy {%file_v1}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v1}
	next
	for %a {%agesy1} {%agesy2}
		copy {%file_v1}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v1}
	next
	for %a {%ageagr}
		copy {%file_v1}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v1}
	next
next
wfclose {%file_v1}

' IF V1 happens to be a !!!DATABANK!!! instead of workfile
'dbopen(type=aremos) %path_v1
'' fetch the series and rename
'for %s m f
'	for %a {%age5yr}
'		fetch p{%s}{%a}.q
'		rename p{%s}{%a} p{%s}{%a}_{%v1}
'	next
'	for %a {%agesy1} {%agesy2}
'		fetch p{%s}{%a}.q
'		rename p{%s}{%a} p{%s}{%a}_{%v1}
'	next
'	for %a {%ageagr}
'		fetch p{%s}{%a}.q
'		rename p{%s}{%a} p{%s}{%a}_{%v1}
'	next
'next
'close @db

wfselect {%output_file}
pageselect q
smpl @all

' For V2 !!! WORKFILE!!!
wfopen %path_v2
for %s m f
	for %a {%age5yr}
		copy {%file_v2}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v2}
	next
	for %a {%agesy1} {%agesy2}
		copy {%file_v2}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v2}
	next
	for %a {%ageagr}
		copy {%file_v2}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v2}
	next
next
wfclose {%file_v2}

wfselect {%output_file}
pageselect q
smpl @all

' For V3 !!! WORKFILE!!!
if %V3 <> "NONE" then
	wfopen %path_v3
	for %s m f
		for %a {%age5yr}
			copy {%file_v3}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v3}
		next
		for %a {%agesy1} {%agesy2}
			copy {%file_v3}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v3}
		next
		for %a {%ageagr}
			copy {%file_v3}::q\p{%s}{%a} {%output_file}::q\p{%s}{%a}_{%v3}
		next
	next
	wfclose {%file_v3}
	
	wfselect {%output_file}
	pageselect q
	smpl @all
endif

'' Load Edscore and MSshare series
'' These are always loaded from workfiles, they are not stored in databanks
wfselect {%output_file}
pageselect q
smpl @all
	
if %V3 <> "NONE" then
	%versions = "v1 v2 v3"
	else %versions = "v1 v2"
endif

for %fl {%versions}
	%fileeq = %path_projfiles_{%fl} + %file_proj55100 + ".wf1"
	wfopen %fileeq
	pageselect q
	smpl @all
	for %s m f
		for %a {%agesy1}
			copy {%file_proj55100}::q\edscore{%s}{%a} {%output_file}::q\edscore{%s}{%a}_{%{%fl}}
			copy {%file_proj55100}::q\msshare_{%s}{%a} {%output_file}::q\msshare_{%s}{%a}_{%{%fl}}
		next
	next
	wfclose {%file_proj55100}
next


' All data are loaded. 


'' *** Load the LFPR equations so that we have them here for easy reference
wfselect {%output_file}
pageselect q
smpl @all

' The equatuons are identical for V1, V2, and V3 here, so I am taking them from V1 only.

%fileeq = %path_projfiles_v1 + %file_proj1654 + ".wf1"
wfopen %fileeq
pageselect q
smpl @all
copy {%file_proj1654}::q\eq_* {%output_file}::q\
wfclose {%file_proj1654}

%fileeq = %path_projfiles_v1 + %file_proj55100 + ".wf1"
wfopen %fileeq
pageselect q
smpl @all
copy {%file_proj55100}::q\eq_* {%output_file}::q\
wfclose {%file_proj55100}



' *** Now we can start making charts ***
' Reminder
'%age5yr = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579"
'%agesy1 = "55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74"
'%agesy2 = "75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100"
'%ageagr = "65o 70o 75o 80o 85o 16o"

' ***(1)***  Compare LFPR  LEVELS for all three versions -- EVERY a/s group on a separate graph
wfselect {%output_file}
pageselect q
smpl @all

if %V3 <> "NONE" then
	for %s m f
		for %a {%age5yr} {%agesy1} {%ageagr}
			group {%s}{%a} p{%s}{%a}_{%v1} p{%s}{%a}_{%v2} p{%s}{%a}_{%v3}
			freeze(g_p{%s}{%a}) {%s}{%a}.line
		next
	next
	else 
		for %s m f
			for %a {%age5yr} {%agesy1} {%ageagr}
				group {%s}{%a} p{%s}{%a}_{%v1} p{%s}{%a}_{%v2} 
				freeze(g_p{%s}{%a}) {%s}{%a}.line
			next
		next
endif


' ***(2)*** AGE PROFILE of LFPRs for SYOA -- 55 to 74
' put on a chart LFPRs for each age
' at the dates specified on top of the program		

wfselect {%output_file}
pageselect q
smpl @all

' put relevant values into matrixes
' each column contains 20 numbers, coresponding to LFPRs for ages 55 to 74 at a partcular date; the next column contains the same but for a different date. 
' That is -- rows denote the age, columns denote the date for which LFPR is taken.

if %V3 <> "NONE" then
	for %ver {%v1} {%v2} {%v3}
		for %s m f
			matrix(20, !ndate) ageprofile_{%s}_{%ver}
			!r = 1
			for %a {%agesy1}
				for !c = 1 to !ndate
					ageprofile_{%s}_{%ver}(!r,!c) =  @elem(p{%s}{%a}_{%ver}, %date{!c})
				next
				!r = !r +1
			next
		next
	next
	else
			for %ver {%v1} {%v2} 
			for %s m f
				matrix(20, !ndate) ageprofile_{%s}_{%ver}
				!r = 1
				for %a {%agesy1}
					for !c = 1 to !ndate
						ageprofile_{%s}_{%ver}(!r,!c) =  @elem(p{%s}{%a}_{%ver}, %date{!c})
					next
					!r = !r +1
				next
			next
		next
endif


' make charts 
if %V3 <> "NONE" then
	for %ver {%v1} {%v2} {%v3}
		for %s m f
			freeze(LFPR_ageprfl_{%s}_{%ver}) ageprofile_{%s}_{%ver}.line
			LFPR_ageprfl_{%s}_{%ver}.displayname LFPR age profile for SYOA 55 to 74
			if %s = "m" then 
				%title = "LFPR age profile for SYOA at select dates, for Men \r as projected in " + %ver
				else
					%title = "LFPR age profile for SYOA at select dates, for Women \r as projected in " + %ver
			endif
			LFPR_ageprfl_{%s}_{%ver}.addtext(font(+b), t) %title
			LFPR_ageprfl_{%s}_{%ver}.setobslabel {%agesy1}
			LFPR_ageprfl_{%s}_{%ver}.addtext(b) "age"
			for !c = 1 to !ndate
					LFPR_ageprfl_{%s}_{%ver}.setelem(!c) legend(%date{!c})
			next
		next
	next
	else
		for %ver {%v1} {%v2}
			for %s m f
				freeze(LFPR_ageprfl_{%s}_{%ver}) ageprofile_{%s}_{%ver}.line
				LFPR_ageprfl_{%s}_{%ver}.displayname LFPR age profile for SYOA 55 to 74
				if %s = "m" then 
					%title = "LFPR age profile for SYOA at select dates, for Men \r as projected in " + %ver
					else
						%title = "LFPR age profile for SYOA at select dates, for Women \r as projected in " + %ver
				endif
				LFPR_ageprfl_{%s}_{%ver}.addtext(font(+b), t) %title
				LFPR_ageprfl_{%s}_{%ver}.setobslabel {%agesy1}
				LFPR_ageprfl_{%s}_{%ver}.addtext(b) "age"
				for !c = 1 to !ndate
						LFPR_ageprfl_{%s}_{%ver}.setelem(!c) legend(%date{!c})
				next
			next
		next
endif


' ***(3)***  Compare LEVELS for EDSCORE and MSSHARE for all three versions -- for M and F ages 55 to 74

wfselect {%output_file}
pageselect q
smpl @all

	
for %s m f
	for %a {%agesy1}
		' edscore
		if %V3 <> "NONE" then
			group edscr_{%s}{%a} edscore{%s}{%a}_{%v1} edscore{%s}{%a}_{%v2} edscore{%s}{%a}_{%v3}
			else group edscr_{%s}{%a} edscore{%s}{%a}_{%v1} edscore{%s}{%a}_{%v2} 
		endif
		freeze(g_edscore{%s}{%a}) edscr_{%s}{%a}.line
		' MSshare
		if %V3 <> "NONE" then
			group msshr_{%s}{%a} msshare_{%s}{%a}_{%v1} msshare_{%s}{%a}_{%v2} msshare_{%s}{%a}_{%v3}
			else group msshr_{%s}{%a} msshare_{%s}{%a}_{%v1} msshare_{%s}{%a}_{%v2}
		endif
		freeze(g_msshare{%s}{%a}) msshr_{%s}{%a}.line
	next
next


' QQQ What other graphs do we need?


' Check for unusually large changes
' For EVERY age group, find when the difference is larger than the !ck limit
!wrn = 0
!ck = !tol 	' tolerance limit for what we consider to be a "large" change; Note: 0.01 is one percentage point
for %s m f
	for %a {%age5yr} {%agesy1} {%ageagr}
		series diff_p{%s}{%a}_{%v2}_vs_{%v1} = p{%s}{%a}_{%v2} - p{%s}{%a}_{%v1}
		if %V3 <> "NONE" then
			series diff_p{%s}{%a}_{%v3}_vs_{%v1} = p{%s}{%a}_{%v3} - p{%s}{%a}_{%v1}
			series diff_p{%s}{%a}_{%v3}_vs_{%v2} = p{%s}{%a}_{%v3} - p{%s}{%a}_{%v2}
		endif
		
		smpl if @abs(diff_p{%s}{%a}_{%v2}_vs_{%v1}) > !ck
		if @obssmpl>0 then
			!wrn = !wrn +1
			string warning_!wrn = "Large difference found for p" + %s+ %a + " between " + %v2 + " and " + %v1
			'warning_{%wn}.display
		endif
		smpl @all
	
		if %V3 <> "NONE" then
			smpl if @abs(diff_p{%s}{%a}_{%v3}_vs_{%v1}) > !ck
			if @obssmpl>0 then
				!wrn = !wrn +1
				string warning_!wrn = "Large difference found for p" + %s+ %a + " between " + %v3 + " and " + %v1
				'warning_{%wn}.display
			endif
			smpl @all
		
			smpl if @abs(diff_p{%s}{%a}_{%v3}_vs_{%v2}) > !ck
			if @obssmpl>0 then
				!wrn = !wrn +1
				string warning_!wrn = "Large difference found for p" + %s+ %a + " between " + %v3 + " and " + %v2
				'warning_{%wn}.display
			endif
			smpl @all
		endif
	next
next

spool _warnings
if !wrn = 0 then
	string tmp = "No warnings to display. All LFPRs across the TRs being compared are within " + @str(!ck) + " of each other (where 0.01 means one percentage point for LFPR)."
	_warnings.append tmp
	else 
		string tmp = "Difference are *Large* if, in ANY period, they exceed " + @str(!ck) + " (where 0.01 means one percentage point for LFPR)."
		_warnings.append tmp
		for !i=1 to !wrn
			_warnings.append warning_!i
		next
		_warnings.display
endif

%usr = @env("USERNAME")
spool _summary
string line1 = 	"This file was created on  " + @date + " at " + @time + " by " + %usr
string line2 = " This files compares LFPR projections and related series between " + %v2 + " and " + %v1 + " using the following source files" + @chr(13) + _
					"For " + %v2 + ": " +  %path_v2 + @chr(13) + _
						" and lfpr_proj files from " + %path_projfiles_v2 + @chr(13) + _
					"For " + %v1 + ": " +  %path_v1 + @chr(13) + _
						 " and lfpr_proj files from " + %path_projfiles_v1

_summary.insert line1 line2

delete line*

delete warning_* tmp


