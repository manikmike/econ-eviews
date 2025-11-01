'	This program creates LFPR check tables that can then be easily copied into Excel. 
'	The tables compare projected LFPRs for m16o, f16o, all 16o, for alts 1, 2, and 3, for two TR years (usually the curent Tr and previous-year TR). 
'	 The user must specify the TR years to be compared, as well as the locations of the LFPR decomposition workfiles that serve as input into the program.

'	STEPS to take to run this program:
'	1. Run LFPR decomposition program (stored in Git repo econ-eview, named 'lfpr_decomp.prg') SIX times
'		(1) alt 1, adjusted LFPRs
'		(2) alt 1, unadjusted LFPRs
'		(3) alt 2, adjusted LFPRs
'		(4) alt 2, unadjusted LFPRs
'		(5) alt 3, adjusted LFPRs
'		(6) alt 3, unadjusted LFPRs
'		in all cases LFPR decomp should be done for %user_groups that include m16o, f16o, 16o (can also include other groups if need their decomp for other purposes).
'	2. Save the resulting workfiles and note the location. [I am putting them into E:\usr\pvlasenk\LFPR Decomp Output\  in folders denoting TR year]
'	3. Find the same files that were ran for the previous TR year, note their location
'	4. Enter the TR years that need to be compared, and the corresponding file locations in the *****UPDATE***** section below; update other required parameters.
'	5. Run the program.


'************* UPDATE this section for every run of the program *************************
!TRyr = 2025 		' Current/latest TR year -- the newest TR that is being compared to previous/earlier values
!TRc = 2024 			' TR to which the latest TR is to be compared -- usually, the prior-year TR, to which the new TR numbers will be compared, but in general can be any other earlier TR.

!endyr = 2100 			' The year when TR projections end (this changes infrequently, every 5 years or so)

%folder_tr = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\_Internal\LFPRdecomposition\"  ' location of the lfpr-decomp workfiles for the !TRyr (i.e. latest TR)
%folder_trc = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_Decomp_Output\TR2024\"  ' location of the lfpr-decomp workfiles for the !TRc (i.e. previous TR)
 
'output of this program:
%thisfile = "check_lfpr_decomp_tr" + @str(!TRyr-2000) + "_vs_tr" + @str(!TRc-2000)
%folder_output =  "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\LFPR_ConsistencyChecks\"

' Do you want to save the resulting workfile?
%sav = "Y" 	' enter "Y" or "N" (case sensitive)

'************END of the update section *********************

wfcreate(wf={%thisfile}, page=lfpr_decomp) a 2000 !endyr 

%tr = @str(!TRyr-2000)   'string version of TR year (two digit, i.e. 18 for TR2018)
%trc = @str(!TRc-2000)   'string version of year for "comparison" TR (two digit, i.e. 17 for TR2017)
!firstyr=!TRyr-1 'first year in the LFPR decomposition table, i.e. 2016 for TR2017 (Q4 of this year is the first projection period for any TR)
!LRyr=!TRyr+74 'last year of the long-range period, i.e. 2091 for TR2017
' ******* NOTE! !firstyr and LRyr should stay the same even when we are doing decomposition tables for the previous-year TR. 

' copy lfpr decomp tables form other workfiles and rename accordingly

' latest TR, alt 1, Adjusted
%file = "lfpr_decomp_tr"+ %tr + "1_andsyoa_a" 	' lfpr_decomp_tr231_andsyoa_a.wf1
%input = %folder_tr + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%tr}1a
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%tr}1a
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%tr}1a
wfclose %input

' latest TR, alt 1, Unadjusted
%file = "lfpr_decomp_tr"+ %tr + "1_andsyoa_u"
%input = %folder_tr + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%tr}1u
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%tr}1u
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%tr}1u
wfclose %input

' latest TR, alt 2, Adjusted
%file = "lfpr_decomp_tr"+ %tr + "2_andsyoa_a"
%input = %folder_tr + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%tr}2a
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%tr}2a
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%tr}2a
wfclose %input

' latest TR, alt 2, Unadjusted
%file = "lfpr_decomp_tr"+ %tr + "2_andsyoa_u"
%input = %folder_tr + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%tr}2u
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%tr}2u
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%tr}2u
wfclose %input

' latest TR, alt 3, Adjusted
%file = "lfpr_decomp_tr"+ %tr + "3_andsyoa_a"
%input = %folder_tr + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%tr}3a
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%tr}3a
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%tr}3a
wfclose %input

' latest TR, alt 3, Unadjusted
%file = "lfpr_decomp_tr"+ %tr + "3_andsyoa_u"
%input = %folder_tr + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%tr}3u
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%tr}3u
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%tr}3u
wfclose %input


' prior TR, alt 1, Adjusted
%file = "lfpr_decomp_tr"+ %trc + "1_andsyoa_a"
%input = %folder_trc + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%trc}1a
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%trc}1a
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%trc}1a
wfclose %input

' prior TR, alt 1, Unadjusted
%file = "lfpr_decomp_tr"+ %trc + "1_andsyoa_u"
%input = %folder_trc + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%trc}1u
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%trc}1u
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%trc}1u
wfclose %input

' prior TR, alt 2, Adjusted
%file = "lfpr_decomp_tr"+ %trc + "2_andsyoa_a"
%input = %folder_trc + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%trc}2a
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%trc}2a
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%trc}2a
wfclose %input

' prior TR, alt 2, Unadjusted
%file = "lfpr_decomp_tr"+ %trc + "2_andsyoa_u"
%input = %folder_trc + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%trc}2u
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%trc}2u
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%trc}2u
wfclose %input

' prior TR, alt 3, Adjusted
%file = "lfpr_decomp_tr"+ %trc + "3_andsyoa_a"
%input = %folder_trc + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%trc}3a
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%trc}3a
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%trc}3a
wfclose %input

' prior TR, alt 3, Unadjusted
%file = "lfpr_decomp_tr"+ %trc + "3_andsyoa_u"
%input = %folder_trc + %file + ".wf1"
wfopen %input
copy {%file}::results\lfpr__16o {%thisfile}::lfpr_decomp\lfpr__16o_{%trc}3u
copy {%file}::results\lfpr_f16o {%thisfile}::lfpr_decomp\lfpr_f16o_{%trc}3u
copy {%file}::results\lfpr_m16o {%thisfile}::lfpr_decomp\lfpr_m16o_{%trc}3u
wfclose %input
'	DONE copying in the decomp data

'declare the tables of appropriate size
%atable = "TR" + %tr + "vs" + %trc + "_adjusted"
%utable = "TR" + %tr + "vs" + %trc + "_unadjusted"

table(20, 21) {%atable}
{%atable}.title Decomposition of Cumulative Change from 4th Qtr. of {!firstyr} to 4th Qtr. of {!LRyr} (adjusted for age, sex, mar. status, child pres.)
table(20, 21) {%utable}
{%utable}.title Decomposition of Cumulative Change from 4th Qtr. of {!firstyr} to 4th Qtr. of {!LRyr} 

'format table headings
for %t {%atable} {%utable}
	{%t}(3, 1) = "TR" + @str(!TRyr)
	{%t}(12, 1) = "TR" + @str(!TRc)
	{%t}(3, 2) = "alt 1"
	{%t}(6, 2) = "alt 2"
	{%t}(9, 2) = "alt 3"
	{%t}(12, 2) = "alt 1"
	{%t}(15, 2) = "alt 2"
	{%t}(18, 2) = "alt 3"
	for !r=3 to 18 step 3
		{%t}(!r, 3) = "m16o"
	next
	for !r=4 to 19 step 3
		{%t}(!r, 3) = "f16o"
	next
	for !r=5 to 20 step 3
		{%t}(!r, 3) = "all16o"
	next
	{%t}(1, 4) = "Proj. LFPR in " + @str(!LRyr)
	{%t}(2, 4) = "Level"
	{%t}(2, 5) = "Cum. Chg."
	{%t}(1, 6) = "Adjustments"
	{%t}(2, 6) = "Total LF"
	{%t}(2, 7) = "Life Exp."
	{%t}(2, 8) = "Indiv."
	{%t}(1, 9) = "Base"
	{%t}(2, 9) = "Total"
	{%t}(1, 10) = "Change in Demo. Dist."
	{%t}(2, 10) = "Age"
	{%t}(2, 11) = "Gender"
	{%t}(2, 12) = "Mar. Status"
	{%t}(2, 13) = "Child Pres."
	{%t}(1, 14) = "Components"
	{%t}(2, 14) = "Bus. Cycle"
	{%t}(2, 15) = "Disab."
	{%t}(2, 16) = "Educ."
	{%t}(2, 17) = "Rep. Rate"
	{%t}(2, 18) = "Earn. test"
	'{%t}(2, 19) = "Female LFPR"	' removing these for TR22 and after
	'{%t}(2, 20) = "1948 coh."
	{%t}(2, 19) = "lagged coh."
	{%t}(2, 20) = "Trend"
	{%t}(2, 21) = "Resid."
next

'	copy data from lfpr decomp tables into the check table
'	Section for the latest TR;  both tables (A and U)
'	alt 1 (latest TR)
	%decomp_m_a = "lfpr_m16o_" + %tr + "1a"
	%decomp_m_u = "lfpr_m16o_" + %tr + "1u"
	%decomp_f_a = "lfpr_f16o_" + %tr + "1a"
	%decomp_f_u = "lfpr_f16o_" + %tr + "1u"
	%decomp_t_a = "lfpr__16o_" + %tr + "1a"
	%decomp_t_u = "lfpr__16o_" + %tr + "1u"
	scalar endrow=0
	for !row=1 to 100 'find which row in the LFPR decomp table corresponds to the last year of the proj period (like 2092 for Tr2018) 
		if {%decomp_m_a}(!row,1)=!LRyr then endrow=!row
		endif
	next		'at this point 'endrow' is the row number in the decomp tables that need to be pulled into the check tables
	
	for !col=4 to 21
		{%atable}(3,!col) = @val({%decomp_m_a}(endrow,!col-2))
		{%utable}(3,!col) = @val({%decomp_m_u}(endrow,!col-2))
		{%atable}(4,!col) = @val({%decomp_f_a}(endrow,!col-2))
		{%utable}(4,!col) = @val({%decomp_f_u}(endrow,!col-2))
		{%atable}(5,!col) = @val({%decomp_t_a}(endrow,!col-2))
		{%utable}(5,!col) = @val({%decomp_t_u}(endrow,!col-2))
	next
	
'	alt 2 (latest TR)
	%decomp_m_a = "lfpr_m16o_" + %tr + "2a"
	%decomp_m_u = "lfpr_m16o_" + %tr + "2u"
	%decomp_f_a = "lfpr_f16o_" + %tr + "2a"
	%decomp_f_u = "lfpr_f16o_" + %tr + "2u"
	%decomp_t_a = "lfpr__16o_" + %tr + "2a"
	%decomp_t_u = "lfpr__16o_" + %tr + "2u"
	scalar endrow=0
	for !row=1 to 100 'find which row in the LFPR decomp table corresponds to the last year of the proj period (like 2092 for Tr2018) 
		if {%decomp_m_a}(!row,1)=!LRyr then endrow=!row
		endif
	next		'at this point 'endrow' is the row numbe rint he decomp tables that need to be pulled into the check tables
	
	for !col=4 to 21
		{%atable}(6,!col) = @val({%decomp_m_a}(endrow,!col-2))
		{%utable}(6,!col) = @val({%decomp_m_u}(endrow,!col-2))
		{%atable}(7,!col) = @val({%decomp_f_a}(endrow,!col-2))
		{%utable}(7,!col) = @val({%decomp_f_u}(endrow,!col-2))
		{%atable}(8,!col) = @val({%decomp_t_a}(endrow,!col-2))
		{%utable}(8,!col) = @val({%decomp_t_u}(endrow,!col-2))
	next
	
'	alt 3 (latest TR)
	%decomp_m_a = "lfpr_m16o_" + %tr + "3a"
	%decomp_m_u = "lfpr_m16o_" + %tr + "3u"
	%decomp_f_a = "lfpr_f16o_" + %tr + "3a"
	%decomp_f_u = "lfpr_f16o_" + %tr + "3u"
	%decomp_t_a = "lfpr__16o_" + %tr + "3a"
	%decomp_t_u = "lfpr__16o_" + %tr + "3u"
	scalar endrow=0
	for !row=1 to 100 'find which row in the LFPR decomp table corresponds to the last year of the proj period (like 2092 for Tr2018) 
		if {%decomp_m_a}(!row,1)=!LRyr then endrow=!row
		endif
	next		'at this point 'endrow' is the row numbe rint he decomp tables that need to be pulled into the check tables
	
	for !col=4 to 21
		{%atable}(9,!col) = @val({%decomp_m_a}(endrow,!col-2))
		{%utable}(9,!col) = @val({%decomp_m_u}(endrow,!col-2))
		{%atable}(10,!col) = @val({%decomp_f_a}(endrow,!col-2))
		{%utable}(10,!col) = @val({%decomp_f_u}(endrow,!col-2))
		{%atable}(11,!col) = @val({%decomp_t_a}(endrow,!col-2))
		{%utable}(11,!col) = @val({%decomp_t_u}(endrow,!col-2))
	next


'	Section for the earlier (comparison) TR;  both tables (A and U)
'	alt 1 (earlier TR)
	%decomp_m_a = "lfpr_m16o_" + %trc + "1a"
	%decomp_m_u = "lfpr_m16o_" + %trc + "1u"
	%decomp_f_a = "lfpr_f16o_" + %trc + "1a"
	%decomp_f_u = "lfpr_f16o_" + %trc + "1u"
	%decomp_t_a = "lfpr__16o_" + %trc + "1a"
	%decomp_t_u = "lfpr__16o_" + %trc + "1u"
	
	scalar startrow=0
	scalar endrow=0
	for !row=1 to 100 'find which row in the LFPR decomp table corresponds to the last year of the proj period (like 2092 for Tr2018) 
		if {%decomp_m_a}(!row,1)=!LRyr then endrow=!row
		endif
		if {%decomp_m_a}(!row,1)=!firstyr then startrow=!row
		endif 
	next		'at this point 'endrow' is the row number in the decomp tables that corresponds to the last year and 'startrow" is the row number in the decomp tables that corresponds to the first year; the difference between these two years is to be plugged intot eh check table

	{%atable}(12,4) = @val({%decomp_m_a}(endrow,2)) 
	{%utable}(12,4) = @val({%decomp_m_u}(endrow,2))
	{%atable}(13,4) = @val({%decomp_f_a}(endrow,2)) 
	{%utable}(13,4) = @val({%decomp_f_u}(endrow,2)) 
	{%atable}(14,4) = @val({%decomp_t_a}(endrow,2)) 
	{%utable}(14,4) = @val({%decomp_t_u}(endrow,2)) 	

	for !col=5 to 21
		{%atable}(12,!col) = @val({%decomp_m_a}(endrow,!col-2)) - @val({%decomp_m_a}(startrow,!col-2)) 
		{%utable}(12,!col) = @val({%decomp_m_u}(endrow,!col-2)) - @val({%decomp_m_u}(startrow,!col-2))
		{%atable}(13,!col) = @val({%decomp_f_a}(endrow,!col-2)) - @val({%decomp_f_a}(startrow,!col-2))
		{%utable}(13,!col) = @val({%decomp_f_u}(endrow,!col-2)) - @val({%decomp_f_u}(startrow,!col-2))
		{%atable}(14,!col) = @val({%decomp_t_a}(endrow,!col-2)) - @val({%decomp_t_a}(startrow,!col-2))
		{%utable}(14,!col) = @val({%decomp_t_u}(endrow,!col-2)) - @val({%decomp_t_u}(startrow,!col-2))
	next
	
'	alt 2 (latest TR)
	%decomp_m_a = "lfpr_m16o_" + %trc + "2a"
	%decomp_m_u = "lfpr_m16o_" + %trc + "2u"
	%decomp_f_a = "lfpr_f16o_" + %trc + "2a"
	%decomp_f_u = "lfpr_f16o_" + %trc + "2u"
	%decomp_t_a = "lfpr__16o_" + %trc + "2a"
	%decomp_t_u = "lfpr__16o_" + %trc + "2u"
	
	scalar startrow=0
	scalar endrow=0
	for !row=1 to 100 'find which row in the LFPR decomp table corresponds to the last year of the proj period (like 2092 for Tr2018) 
		if {%decomp_m_a}(!row,1)=!LRyr then endrow=!row
		endif
		if {%decomp_m_a}(!row,1)=!firstyr then startrow=!row
		endif 
	next		'at this point 'endrow' is the row number in the decomp tables that corresponds to the last year and 'startrow" is the row number in the decomp tables that corresponds to the first year; the difference between these two years is to be plugged intot eh check table

	{%atable}(15,4) = @val({%decomp_m_a}(endrow,2)) 
	{%utable}(15,4) = @val({%decomp_m_u}(endrow,2))
	{%atable}(16,4) = @val({%decomp_f_a}(endrow,2)) 
	{%utable}(16,4) = @val({%decomp_f_u}(endrow,2)) 
	{%atable}(17,4) = @val({%decomp_t_a}(endrow,2)) 
	{%utable}(17,4) = @val({%decomp_t_u}(endrow,2)) 	
	
	for !col=5 to 21
		{%atable}(15,!col) = @val({%decomp_m_a}(endrow,!col-2)) - @val({%decomp_m_a}(startrow,!col-2)) 
		{%utable}(15,!col) = @val({%decomp_m_u}(endrow,!col-2)) - @val({%decomp_m_u}(startrow,!col-2))
		{%atable}(16,!col) = @val({%decomp_f_a}(endrow,!col-2)) - @val({%decomp_f_a}(startrow,!col-2))
		{%utable}(16,!col) = @val({%decomp_f_u}(endrow,!col-2)) - @val({%decomp_f_u}(startrow,!col-2))
		{%atable}(17,!col) = @val({%decomp_t_a}(endrow,!col-2)) - @val({%decomp_t_a}(startrow,!col-2))
		{%utable}(17,!col) = @val({%decomp_t_u}(endrow,!col-2)) - @val({%decomp_t_u}(startrow,!col-2))
	next
	
'	alt 3 (latest TR)
	%decomp_m_a = "lfpr_m16o_" + %trc + "3a"
	%decomp_m_u = "lfpr_m16o_" + %trc + "3u"
	%decomp_f_a = "lfpr_f16o_" + %trc + "3a"
	%decomp_f_u = "lfpr_f16o_" + %trc + "3u"
	%decomp_t_a = "lfpr__16o_" + %trc + "3a"
	%decomp_t_u = "lfpr__16o_" + %trc + "3u"
	
	scalar startrow=0
	scalar endrow=0
	for !row=1 to 100 'find which row in the LFPR decomp table corresponds to the last year of the proj period (like 2092 for Tr2018) 
		if {%decomp_m_a}(!row,1)=!LRyr then endrow=!row
		endif
		if {%decomp_m_a}(!row,1)=!firstyr then startrow=!row
		endif 
	next		'at this point 'endrow' is the row number in the decomp tables that corresponds to the last year and 'startrow" is the row number in the decomp tables that corresponds to the first year; the difference between these two years is to be plugged intot eh check table

	{%atable}(18,4) = @val({%decomp_m_a}(endrow,2)) 
	{%utable}(18,4) = @val({%decomp_m_u}(endrow,2))
	{%atable}(19,4) = @val({%decomp_f_a}(endrow,2)) 
	{%utable}(19,4) = @val({%decomp_f_u}(endrow,2)) 
	{%atable}(20,4) = @val({%decomp_t_a}(endrow,2)) 
	{%utable}(20,4) = @val({%decomp_t_u}(endrow,2)) 	

	for !col=5 to 21
		{%atable}(18,!col) = @val({%decomp_m_a}(endrow,!col-2)) - @val({%decomp_m_a}(startrow,!col-2)) 
		{%utable}(18,!col) = @val({%decomp_m_u}(endrow,!col-2)) - @val({%decomp_m_u}(startrow,!col-2))
		{%atable}(19,!col) = @val({%decomp_f_a}(endrow,!col-2)) - @val({%decomp_f_a}(startrow,!col-2))
		{%utable}(19,!col) = @val({%decomp_f_u}(endrow,!col-2)) - @val({%decomp_f_u}(startrow,!col-2))
		{%atable}(20,!col) = @val({%decomp_t_a}(endrow,!col-2)) - @val({%decomp_t_a}(startrow,!col-2))
		{%utable}(20,!col) = @val({%decomp_t_u}(endrow,!col-2)) - @val({%decomp_t_u}(startrow,!col-2))
	next

delete startrow endrow

'	copy finished check tables to a separate page
pagecreate(page=check_tables) a 2000 !endyr 	'page "check_tables" will hold the resulting comparison tables

copy lfpr_decomp\{%atable} check_tables\
copy lfpr_decomp\{%utable} check_tables\

pageselect check_tables

'create a spool that contains summary info for the run
%usr = @env("USERNAME")
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %usr
string line2 = "This file does LFPR decomp check by comparing LFPR decomp data for TR" + @str(!TRyr) + " and TR" + @str(!TRc)
string line3 = "LFPR decomp files for TR" + @str(!TRyr) + " were taken from " + %folder_tr
string line4 = "LFPR decomp files for TR" + @str(!TRc) + " were taken from " + %folder_trc
if %sav = "Y" then 
	string line5 = "This file is saved in " + %folder_output + %thisfile + ".wf1" 
else string line5 = "This file has not been saved. Please save manually if needed. "
endif
string line6 = "NOTE: for TR21 the LFPR model was changed; as a result, the regression factors in the decomposition tables have changed." + @chr(13) + _
				 "This file compares TR" + @str(!TRyr) + " to TR" + @str(!TRc) + ", both of which use the new LFPR model." + @chr(13) + _
				 "The data from the comparison tables in page 'check_tables' should be manually copied into the Excel check file."

_summary.insert line1 line2 line3 line4 line5 line6 
_summary.display

delete line*

'	save the workfile
if %sav = "Y" then 
	%full_output=%folder_output + %thisfile + ".wf1"
	wfsave %full_output
endif 


'wfclose {%thisfile}


