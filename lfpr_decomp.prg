' ***********************************************************************************************************************************************************
' **** This program creates LFPR decomposition for demographic groups specified by user FOR THE NEW LFPR MODEL first used for TR2021.
' **** Polina Vlasenko 3-24-2021
' **** This version is changed to use EVIEWS WORKFILES instead of databanks when loading data from a TR.  --- Polina Vlasenko, June 2022


' The full superset of DEMOGRAPHIC GROUPS that the user can specify follows. 
' Any (or all) groups from this list can be used in the %user_groups below. 
' %user_groups MUST be a subset of the list below, using the EXACT mnemonics given. 
' Groups not listed here CANNOT be used (for example, you CANNOT do decomposition for group f2554).

' "M1617 M1819 M2024NM M2024MS M2024MA M2529NM M2529MS M2529MA M3034NM M3034MS M3034MA	
' M3539NM M3539MS M3539MA M4044NM M4044MS M4044MA M4549NM M4549MS M4549MA M5054NM M5054MS M5054MA 
' M55 M56 M57 M58 M59 M60 M61 M62 M63 M64 M65 M66 M67 M68 M69 M70 M71 M72 M73 M74 M75 M76 M77 M78 M79
' M80 M81 M82 M83 M84 M85 M86 M87 M88 M89 M90 M91 M92 M93 M94 M95 M96 M97 M98 M99 M100
' F1617 F1819 F2024MAC6U F2024MANC6 F2024MSC6U F2024MSNC6 F2024NMC6U F2024NMNC6 
' F2529MAC6U F2529MANC6 F2529MSC6U F2529MSNC6 F2529NMC6U F2529NMNC6
' F3034MAC6U F3034MANC6 F3034MSC6U F3034MSNC6 F3034NMC6U F3034NMNC6
' F3539MAC6U F3539MANC6 F3539MSC6U F3539MSNC6 F3539NMC6U F3539NMNC6
' F4044MAC6U F4044MANC6 F4044MSC6U F4044MSNC6 F4044NMC6U F4044NMNC6 
' F4549MA F4549MS F4549NM F5054MA F5054MS F5054NM
' F55 F56 F57 F58 F59 F60 F61 F62 F63 F64 F65 F66 F67 F68 F69 F70 F71 F72 F73 F74 F75 F76 F77 F78 F79
' F80 F81 F82 F83 F84 F85 F86 F87 F88 F89 F90 F91 F92 F93 F94 F95 F96 F97 F98 F99 F100"
'  m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m7074 m7579 m8084 m8589 m9094 m9599 
'  m85o m80o m75o m70o m65o 
'  m16o 
'  f2024nm f2024ms f2024ma f2024 f2529nm f2529ms f2529ma f2529 f3034nm f3034ms f3034ma f3034 f3539nm f3539ms f3539ma f3539 f4044nm f4044ms f4044ma f4044 
'  f4549 f5054 f5559 f6064 f6569 f7074 f7579 f8084 f8589 f9094 f9599 
'  f85o f80o f75o f70o f65o 
'  f16o
'  16o 

' *** IMPORTANT NOTE on DI effect***
' For the new LFPR model first used in TR21:
' This program computes the DI effect as the difference between values of p..._diadj_ and p..._p from the EViews projections file  lfpr_proj_...wf1. 
' This approach assumes that NO OTHER CHNAGE IS MADE between p..._diadj_ and p..._p when creating projections. 
' Currently (as of TR21) this assumption is correct. 
' Should there be changes to the projection programs in the future that alter this feature -- make sure to make corresponding changes here as well. 
' *****

' **** KNOWN ISSUES ***** as of 1-12-2022
' (1) For decomposition for UNADJUSTED LFPRs -- the program indicates that the final LFPRs for ages F70o F75o and F80o constructed here do not match the same LFPRs in the A-bank. 
' 	I checked -- the differences are very small, in the 7th decimal place, thus I think they come from rounding in Aremos databanks. This difference would not show up at the precision levels we display the values; so this is not a problem.
'    UPD 06-10-2022  Even after converting the program to use EViews workfiles, this issue is still present, so this is not specific to Aremos databanks. 
' NO OTHER known issues at this time.

'User should set the parameters listed under "****SET these parameters before running the program *****.

'***** This program requires the following workfiles (we still call them a-BANK, but they are really workfiles now):
'***** a-bank (current TR)
'***** d-bank (current TR)
'***** addfactor bank, i.e. ad-bank (current TR)
'***** op-bank (previous TR)
' AND the two EViews files with projected LFPRs:
' **** lfpr_proj_1654.wf1
' **** lfpr_proj_55100.wf1


'***************************************************************************
'**********SET these parameters before running the program **********

' !!!!! Search the code for phrase "SPECIAL FOR TR" in ALL CAPS -- it will indicate one-time special changes made for particular TR. Review to make sure those are still needed (they are usually not needed).

%usr = @env("USERNAME") 

!TRyr = 2025 	'the LFPR decomposition table will start from TRyr-1 Q4, i.e. Q4 of the last historical year. 
					'NOTE: this program assumes that TRyr is in the form 20XX. The program will NOT work for TRyr 1999 or earlier.

!startyr=1995 ' first year in the workfile; need to start far enough in the past to catch all lagged values
!endyr=2105 'end year for the LFPR decomposition table, usually the last year of the TR projection period, i.e. the latest year in the TR databanks; Decomposition tables go through !endyr


' Add any note you want to incoude in the summary spool. Can leave blank.
%note = "alt3 from LRECON\ModelRuns\TR2025\2025-0206-1218-TR253\"

'alt -- uncomment ONE option below; note that these are STRING variables
'%alt="2" 'ALT for which  the decomposition is to be done
'%alt="1"
%alt="3"

' Indicate location of the WORKFILES to be used for the program run
'  IMPORTANT -- don't forget the "\" at the end of the folder path
'	!!!!!     MAKE SURE these files match the ALT you indicated above !!!
' a-bank
%folder_a = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0206-1218-TR253\out\mul" + "\"		
%abank = "atr" + @str(!TRyr-2000) + %alt		' a-bank name only, no extension
' d-bank
%folder_d = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0206-1218-TR253\out\mul" + "\"
%dbank = "dtr" + @str(!TRyr-2000) + %alt
'add-factor bank (ad-bank)
%folder_ad = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0206-1218-TR253\dat" + "\"
%adbank = "adtr" + @str(!TRyr-2000) + %alt
'op-bank (Note that this is op-bank from previous-year TR, i.e. op1162o.bnk when the current TR is 2017)
' NOTE: we no longer use op-bank for this; the information needed from it (DI effect) is now computyed by using lfpr_proj...wf1 files.
'%folder_op = "C:\Users\032158\GitRepos\econ-ecodev\dat\"
'%opbank = "op1" + @str(!TRyr-2001) + %alt + "o"

' EViews workfiles that contain the projected LFPRs
%lfprs_1654_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0206-1218-TR253\dat" + "\lfpr_proj_1654.wf1" 	' full path
%lfprs_1654 = "lfpr_proj_1654" 'short filename from the path above

%lfprs_55100_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0206-1218-TR253\dat" + "\lfpr_proj_55100.wf1" 	' full path
%lfprs_55100 = "lfpr_proj_55100" 'short filename from the path above


' Parameters that determine which output is to be produced

'group(s) for which the decomposition is to be done, space delimited
' the expanded set of user groups; it also includes SYOA LFPRs:
%user_groups=		"m1617 m1819 m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m70o " + _
						"f1617 f1819 f2024 f2529 f3034 f3539 f4044 f4549 f5054 f5559 f6064 f6569 f70o " + _
						"f16o m16o 16o " + _
						"m55 m56 m57 m58 m59 m60 m61 m62 m63 m64 m65 m66 m67 m68 m69 m70 m71 m72 m73 m74 " + _
						"f55 f56 f57 f58 f59 f60 f61 f62 f63 f64 f65 f66 f67 f68 f69 f70 f71 f72 f73 f74" 

' The standard set of %user_groups is:
'%user_groups=		"m1617 m1819 m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m70o " + _
'						"f1617 f1819 f2024 f2529 f3034 f3539 f4044 f4549 f5054 f5559 f6064 f6569 f70o " + _
'						"f16o m16o 16o " '+ _

' LFPR type -- uncomment ONE option below (CASE sensitive)
'%lfpr="a" 	' Adjusted for age, sex, marital status, presence of children
%lfpr="u" 	' Unadjusted (i.e. gross)


' BASE YEAR for Adjusted LFPRs
' Indicate the period that serves as base for age-sex-mar.status-children adjustment of LFPRs
	'if using a specific quarter, enter here 
	' OR comment out if not using
		'%LFPR_adj_base = "2011Q4" 

	'if using annual values -- enter year below
	' If using a specific quarter you indicated above in %LFPR_adj_base -- enter ZERO here
		'!annual = 0
		!annual = 2020  '!!!!! IMPORTANT -- Set to ZERO if not using!!!!!


' Output created by this program:
%folder_output = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_Decomp_Output\TR2025\"
'name to be given to the workfile created by this program
%thisfile = "lfpr_decomp_tr" + @str(!TRyr-2000) + %alt + "_AndSYOA_" + %lfpr	 'produces filename like "lfpr_decomp_tr232_AndSYOA_a"
'%thisfile = "lfpr_decomp_tr" + @str(!TRyr-2000) + %alt + "_" + %lfpr	 'produces filename like "lfpr_decomp_tr182_u"

%sav = "Y" 	' enter "Y" or "N" (case sensitive); governs whether the output workfile is saved

'*****END of section that needs updating for each run*****
' *************************************************************


wfcreate(wf={%thisfile}, page=q) q !startyr !endyr 'create workfile with quarterly data between !startyr Q1 and !endyr Q4. 

'create new page called "results" which is annual from TRyr-1 to endyr -- this is where the final LFPR decomposition tables will be stored
!tablestart = !TRyr-1 
!tableend = !endyr
pagecreate(page=results) a !tablestart !tableend 

pageselect q 

logmode l			' this program will display log messages
%msg = "Running LFPR decomposition" 
logmsg {%msg}
logmsg 

'If using ANNUAL base period, create strings to denote quarters of the year
if !annual >0 then 
	%base1=@str(!annual)+"q1"
	%base2=@str(!annual)+"q2"
	%base3=@str(!annual)+"q3"
	%base4=@str(!annual)+"q4"
endif

%tralt = @str(!TRyr-2000) + %alt 	' string that holds TR and alt, e.g. "212" for TR21 alt2; used below in various object names

' Sample period for which LFPR decomposition will  be done
%datestart=@str(!TRyr-1)+"q4" 	' Q4 of year (TRyr-1), the FIRST period in LFPR decomposition table
%dateend=@str(!endyr)+"q4" 		'Q4 of the last year of TR projections

%datelasthist=@str(!TRyr-1)+"q3" 'last historical date, i.e. Q3 of (TRyr-1), saved as a string

%trstr=@str(!TRyr-2000) 'string variable with two-digit TR year, i.e. "17" for 2017.
%tr_pr=@str(!TRyr-2000-1) 'string variable with previous TR year, i.e. "16" when the current TR is 2017; need this for the op-bank.

'string variables that denote databanks with corresponding filepaths 
%abankpath=%folder_a+%abank+".wf1" 
%dbankpath=%folder_d+%dbank+".wf1" 
'%opbankpath=%folder_op+%opbank+".wf1" 
%adbankpath=%folder_ad+%adbank+".wf1" 

'list of RHS variables that need to be kept constant when computing Adjusted LFPRs
%reset_list = 	"rf1617cu6 rf1819cu6 " + _
					"msshare_m55 msshare_m56 msshare_m57 msshare_m58 msshare_m59 msshare_m60 msshare_m61 msshare_m62 msshare_m63 msshare_m64 " + _
					"msshare_m65 msshare_m66 msshare_m67 msshare_m68 msshare_m69 msshare_m70 msshare_m71 msshare_m72 msshare_m73 msshare_m74 " + _
					"msshare_f55 msshare_f56 msshare_f57 msshare_f58 msshare_f59 msshare_f60 msshare_f61 msshare_f62 msshare_f63 msshare_f64 " + _
					"msshare_f65 msshare_f66 msshare_f67 msshare_f68 msshare_f69 msshare_f70 msshare_f71 msshare_f72 msshare_f73 msshare_f74 "

'list of 153 "primary" demographic groups -- the ones for which we have estimated LFPR equations
%groups_primary = "M1617 M1819 M2024NM M2024MS M2024MA M2529NM M2529MS M2529MA M3034NM M3034MS M3034MA" + _
						" M3539NM M3539MS M3539MA M4044NM M4044MS M4044MA M4549NM M4549MS M4549MA M5054NM M5054MS M5054MA" + _
						" M55 M56 M57 M58 M59 M60 M61 M62 M63 M64 M65 M66 M67 M68 M69 M70 M71 M72 M73 M74" + _
						" M75 M76 M77 M78 M79 M80 M81 M82 M83 M84 M85 M86 M87 M88 M89 M90 M91 M92 M93 M94 M95 M96 M97 M98 M99 M100" + _
						" F1617 F1819 F2024MAC6U F2024MANC6 F2024MSC6U F2024MSNC6 F2024NMC6U F2024NMNC6" + _
						" F2529MAC6U F2529MANC6 F2529MSC6U F2529MSNC6 F2529NMC6U F2529NMNC6 F3034MAC6U F3034MANC6 F3034MSC6U F3034MSNC6 F3034NMC6U F3034NMNC6" + _
						" F3539MAC6U F3539MANC6 F3539MSC6U F3539MSNC6 F3539NMC6U F3539NMNC6 F4044MAC6U F4044MANC6 F4044MSC6U F4044MSNC6 F4044NMC6U F4044NMNC6" + _
						" F4549MA F4549MS F4549NM F5054MA F5054MS F5054NM F55 F56 F57 F58 F59 F60 F61 F62 F63 F64 F65 F66 F67 F68 F69 F70 F71 F72 F73 F74" + _
						" F75 F76 F77 F78 F79 F80 F81 F82 F83 F84 F85 F86 F87 F88 F89 F90 F91 F92 F93 F94 F95 F96 F97 F98 F99 F100"

' list of all demo groups for which we have ESTIMATED LFPR equations -- i.e. 1617 to 5054, disaggregated by MS and POC, and 55 to 74 SYOA					
%groups_eqns_1654 = 	" M1617 M1819 M2024NM M2024MS M2024MA M2529NM M2529MS M2529MA M3034NM M3034MS M3034MA" + _
						" M3539NM M3539MS M3539MA M4044NM M4044MS M4044MA M4549NM M4549MS M4549MA M5054NM M5054MS M5054MA" + _
						" F1617 F1819 F2024MAC6U F2024MANC6 F2024MSC6U F2024MSNC6 F2024NMC6U F2024NMNC6" + _
						" F2529MAC6U F2529MANC6 F2529MSC6U F2529MSNC6 F2529NMC6U F2529NMNC6 F3034MAC6U F3034MANC6 F3034MSC6U F3034MSNC6 F3034NMC6U F3034NMNC6" + _
						" F3539MAC6U F3539MANC6 F3539MSC6U F3539MSNC6 F3539NMC6U F3539NMNC6 F4044MAC6U F4044MANC6 F4044MSC6U F4044MSNC6 F4044NMC6U F4044NMNC6" + _
						" F4549MA F4549MS F4549NM F5054MA F5054MS F5054NM"
						
%groups_eqns_5574 = 	" M55 M56 M57 M58 M59 M60 M61 M62 M63 M64 M65 M66 M67 M68 M69 M70 M71 M72 M73 M74" + _
								" F55 F56 F57 F58 F59 F60 F61 F62 F63 F64 F65 F66 F67 F68 F69 F70 F71 F72 F73 F74"

'all aggregated groups in a specific order (do NOT change the order they are listed in here)
%groups_aggr= 	"m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m7074 m7579 m8084 m8589 m9094 m9599 " + _
						"m85o m80o m75o m70o m65o " + _
						"m16o " + _
						"f2024nm f2024ms f2024ma f2024 f2529nm f2529ms f2529ma f2529 f3034nm f3034ms f3034ma f3034 f3539nm f3539ms f3539ma f3539 f4044nm f4044ms f4044ma f4044 " + _
						"f4549 f5054 f5559 f6064 f6569 f7074 f7579 f8084 f8589 f9094 f9599 " + _
						"f85o f80o f75o f70o f65o " + _
						"f16o "
					'	"16o" -- excluding 16o from the list because EViews does not allow series names that start with a number.

%list_col = "ga le ia tb ag ge ms ch bc di ed rr et lc tr" 'columns of the LFPR decomposition table, in a specific order

' Various lists useful for loops in the program
%ageg = "1617 1819 2024 2529 3034 3539 4044 4549 5054" 		' list of age-interval groups
%age5yr = "2024 2529 3034 3539 4044 4549 5054" 				' list of 5yr age groups
%age = "55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 "		' SYOA for which we have equations
%age_syoa = %age + "75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100"   ' ALL SYOA


' ***** NOTE on naming convention ******
' In this program there will be several versions of LFPR series; they differ by their source and will be distinguished by name as follows:
' Series named p/s/a/ms/ch_final (pf2024msc6u_final, pm4045nm_final, pm5054_final, pf58_final, pm75_final, etc) are the LFPR series CREATED by this program; they are compared against those loaded from TR A-bank
' Series named p/s/a/ms/ch_evp (pf2024msc6u_evp, pm5054_evp, pf58_evp, as well as pf2024msc6u_p_evp and pf2024msc6u_diadj_p_evp) are copied from EViews files with Projections (lfpr_proj_1654.wf1 and lfpr_proj_55100.wf1)
' Series named p/s/a/ms/ch_tr/yr/alt/ (pf2024msc6u_212, pm5054_212, pf58_212, etc) are loaded from the A-bank for the corresponding TR. IMPORTANT: these are NOT equal to the similarly named series from EViews projections files (e.g. pf2024_212 is NOT equal to pf2024_evp)


' ***************************************************
' *****  Step 1 -- Copy information from other files

' *********** Load estimated equations **********
%msg = "Loading equations estimated elsewhere"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

' *** For ages 1617 to 5054
wfopen {%lfprs_1654_path}
pageselect q		

copy {%lfprs_1654}::q\eq_* {%thisfile}::q\		' copy ALL equations objects and preserve their names

' load coefficients from the estimated equations for schooling
for %s m f
	for %m ma ms nm
		copy {%lfprs_1654}::q\sch_{%s}2024{%m} {%thisfile}::q\
		copy {%lfprs_1654}::q\sch_{%s}2529{%m} {%thisfile}::q\
	next
next
wfclose {%lfprs_1654}

wfselect {%thisfile}
pageselect q
smpl @all

' *** For ages 55 to 100
wfopen {%lfprs_55100_path}
pageselect q		

copy {%lfprs_55100}::q\eq_* {%thisfile}::q\		' copy ALL equation objects and preserve their names

wfclose {%lfprs_55100}

' ***************************************************
' ****** Step 2 -- Load data from EViews files with LFPR projections
' These are named 
' lfpr_proj_1654.wf1
' lfpr_proj_55100.wf1

%msg = "Loading data series from LFPR projection files (EViews)"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

wfopen {%lfprs_1654_path}
pageselect q		

for %a 1617 1819 2024 2529
	for %s f m 
		copy {%lfprs_1654}::q\tr_{%s}{%a} {%thisfile}::q\ 		' copy time trends
	next
next

copy {%lfprs_1654}::q\edscore* {%thisfile}::q\ 		' copy EDSCORE series

for %g {%groups_eqns_1654}
	copy {%lfprs_1654}::q\p{%g}_p {%thisfile}::q\p{%g}_p_evp						' copy p/s/a/ms_p and rename it ..._evp (as explained above)
	copy {%lfprs_1654}::q\p{%g}_diadj_p {%thisfile}::q\p{%g}_diadj_p_evp		' copy p/s/a/ms_diadj_p and rename it ..._evp
	copy {%lfprs_1654}::q\p{%g} {%thisfile}::q\p{%g}_evp							' copy p/s/a/ms and rename it ..._evp
next

for %a {%ageg}
	for %s m f
		copy {%lfprs_1654}::q\p{%s}{%a}_p {%thisfile}::q\p{%s}{%a}_p_evp 	' copy p/s/a_p and rename it ..._evp; note -- this uis for series like pm2024_p, as different from pm 2024ms_p done above.
	next
next

wfclose {%lfprs_1654}

wfselect {%thisfile}
pageselect q
smpl @all

' *** For ages 55 to 100
wfopen {%lfprs_55100_path}
pageselect q		

copy {%lfprs_55100}::q\edscore* {%thisfile}::q\ 	' copy EDSCORE variables

copy {%lfprs_55100}::q\msshare_* {%thisfile}::q\ ' copy MSshare variables

copy {%lfprs_55100}::q\rradj* {%thisfile}::q\ 		' copy replacement rate variables
copy {%lfprs_55100}::q\rrcf* {%thisfile}::q\ 		' copy replacement rate coefficients

copy {%lfprs_55100}::q\pot_et_txrt* {%thisfile}::q\ 	' copy earnings test variables
copy {%lfprs_55100}::q\etcf {%thisfile}::q\ 				' copy earnings test coefficient (only one coefficient)

for %a {%age_syoa}
	for %s m f 
		copy {%lfprs_55100}::q\p{%s}{%a}_p {%thisfile}::q\p{%s}{%a}_p_evp		' copy p/s/a_p and rename it ..._evp (as explained above)
		copy {%lfprs_55100}::q\p{%s}{%a} {%thisfile}::q\p{%s}{%a}_evp				' copy p/s/a and rename it ..._evp
	next
next
for %g {%groups_eqns_5574}
	copy {%lfprs_55100}::q\p{%g}_diadj_p {%thisfile}::q\p{%g}_diadj_p_evp		' copy p/s/a_diadj_p and rename it ..._evp (as explained above)
next

wfclose {%lfprs_55100}

' *********************************************
' ****** Step 3 -- Load data from databanks

%msg = "Loading data from TR databanks"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

wfopen {%abankpath}
pageselect q		

' Load Un rates
for %s m f
	for %a {%ageg} 
		copy {%abank}::q\r{%s}{%a} {%thisfile}::q\		' RUs (un rates)
	next
next

' load ALL final LFPRs (need them for comparison purposes later)
for %g {%groups_primary} {%groups_aggr} 16o
	copy {%abank}::q\p{%g} {%thisfile}::q\p{%g}_{%tralt} 	' copy from a-bank and rename to indicate the source
next

copy {%abank}::q\p16o_asa {%thisfile}::q\p16o_asa_{%tralt} 
copy {%abank}::q\pf16o_asa {%thisfile}::q\pf16o_asa_{%tralt}
copy {%abank}::q\pm16o_asa {%thisfile}::q\pm16o_asa_{%tralt}

wfclose {%abank}

wfselect {%thisfile}
pageselect q
smpl @all

series p_16o_{%tralt} = p16o_{%tralt} 	' need this strange name for p16o series (p_16o... instead of just p16o...) b/c 
												' EViews does not let me name components series starting with a number (16o) so I have to do it with an underscore (_16o)

' Copy various other series we need from TR databanks

wfopen {%dbankpath}
pageselect q	
for %a 1617 1819		
	copy {%dbank}::q\rf{%a}cu6 {%thisfile}::q\  ' POC series
next

for %s m f
 for %a {%age5yr} {%age_syoa}
    copy {%dbank}::q\p{%s}{%a}adj {%thisfile}::q\ 		' life-expectancy adjustment; the series exist for all ages 2024 and older, but for many younger groups they are zero
  next
next
wfclose {%dbank}


wfopen {%adbankpath}
pageselect q
for %s m f
 for %a {%age}
    copy {%adbank}::q\p{%s}{%a}_add {%thisfile}::q\ 			'_add factors for ages 55 to 74
    copy {%adbank}::q\p{%s}{%a}_add2 {%thisfile}::q\ 		'_add2 factors for ages 55 to 74
  next
  for %a {%ageg}
  	copy {%adbank}::q\p{%s}{%a}_add2 {%thisfile}::q\ 	'_add2 factors for ages 1617 to 5054
  next
next
wfclose {%adbank}

wfselect {%thisfile}
pageselect q
smpl @all

' ****************************************************************************************
' ****** Step 4 -- Create the clusters for PRIMARY groups ******
' ****************************************************************************************

%msg = "Creating all clusters for PRIMARY groups..."
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' Create series for ALL clusters for all PRIMARY groups and initialize them to zero *****
for %c {%list_col} in	' all columns in the decomposition table PLUS _in (global intercept)
	for %g {%groups_primary}
		series {%g}_{%c} = 0
	next
next

' for Adjusted LFPRs, reset certain series to a constant value equal to the "base period"; for unadjusted LFPRs this step is skipped
if %lfpr="a" then 
	for %ser {%reset_list}  
	smpl %datestart %dateend
	if !annual>0 then 
		{%ser} = 0.25*@elem({%ser}, %base1) + 0.25*@elem({%ser}, %base2) + 0.25*@elem({%ser}, %base3) + 0.25*@elem({%ser}, %base4)  
		else {%ser} = @elem({%ser}, %LFPR_adj_base)
	endif
	next
	smpl @all
endif 


' **** BC cluster *****
%msg = "... Business-Cycle effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' ** Create projected BC effect series named bc_/s/a/ using the estimated BC equations and the RUs loaded above

' ages 1617 to 5054
' Note: this creates series like f2529_bc, but NOT series like f2529msc6u_bc or f2529mc_bc 
for %s m f 
	for %a {%ageg}
		series r{%s}{%a}_dpk3 = r{%s}{%a}	' This looks strange but there is a reason for it. 
														' The RHS variables in BC equations are named r/s/a/_dpk3 
														' To use the eq_.fit command (on next line) there MUST be series of this exact name.
														' This looks non-standard, but this IS the intention here.
		eq_p{%s}{%a}_bc.fit {%s}{%a}_bc
		
		delete r{%s}{%a}_dpk3 ' once done, we can delete r{%s}{%a}_dpk3
	next
next

' BC effect for the more disaggregated groups
for %s m
	for %a {%age5yr}
		for %m ms ma nm
			{%s}{%a}{%m}_bc = {%s}{%a}_bc
		next
	next
next

for %s f 
	for %a 2024 2529 3034 3539 4044
		for %m ms ma nm
			for %k c6u nc6
				{%s}{%a}{%m}{%k}_bc = {%s}{%a}_bc
			next
		next
	next
next

for %s f
	for %a 4549 5054
		for %m ms ma nm
			{%s}{%a}{%m}_bc = {%s}{%a}_bc
		next
	next
next

' ages 55 to 100 (SYOA) -- no BC effect, so these series remain at zero

' ***** Disability Cluster ******
' Exist for all ages up to 74, zero for 75 and older
' !!!!! Since the EViews files store both "DI-adjusted" and "pure" preliminary LFPRs, I can compute the DI cluster as their difference
' !!!!! Important -- make sure that these series are ALWAYS stored in the file in the future!!!!!

%msg = "... Disability cluster ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

for %g {%groups_eqns_1654}
	{%g}_di = p{%g}_p_evp - p{%g}_diadj_p_evp
next

for %g {%groups_eqns_5574}
	{%g}_di = p{%g}_p_evp - p{%g}_diadj_p_evp
next

' **** Education cluster *****
%msg = "... Education effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' Ages 55 to 74, SYOA
for %s m f 
	for %a {%age}
		{%s}{%a}_ed = eq_p{%s}{%a}.c(1) * edscore{%s}{%a}
	next
next

' F5054MS
f5054ms_ed = eq_pf5054ms.c(2)*edscoref5054

' For all other ages education effect remains zero


' **** Replacement Rate and Earnings Test clusters *****
%msg = "... Replacement Rate and Earnings Test effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' Ages 62 to 69, male and female

for %a 62 63 64 65 66 67 68 69
	for %s m f
		{%s}{%a}_rr = - rrcf{%s}{%a} * rradj_{%s}{%a}	' replacement rate effect
		{%s}{%a}_et = - etcf * pot_et_txrt_{%a}			' earnings test effect
	next
next

' **** Lagged Cohort cluster *****
%msg = "... Lagged Cohort effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' Ages 75 and older
' For ages 75 and older, this is basically the entire LFPR equation for the PRELIMINARY value
' In other words, all I need to do is copy pm75_p through pm100p, and pf75_p through pf100_p from %lfprs_55100

wfopen {%lfprs_55100_path}
pageselect q		

for %a 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100
	for %s f m 
		copy {%lfprs_55100}::q\p{%s}{%a}_p {%thisfile}::q\{%s}{%a}_lc
	next
next

wfclose {%lfprs_55100}


' **** Time Trend cluster *****
%msg = "... Time Trend effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' Ages 1617 and 1819
' Here the trend enters through rnlm/age/_nilf_fitted for males and rnlf/age/_so for females
' NOTE that I include in the "trend" cluster the constant term from the RNLF and RNLM equations (the @coef(3) term).
' This is done so that the later loop that saves the global constant term can be uniform for all equations. 

for %a 1617 1819
	m{%a}_tr = -1 * (eq_rnlm{%a}.c(2) * tr_m{%a} + eq_rnlm{%a}.c(3))
	f{%a}_tr = -1 * (eq_rnlf{%a}_so.c(2) * tr_f{%a} + eq_rnlf{%a}_so.c(3))
next

' Ages 2024 and 2529 -- schooling effect only
for %a 2024 2529
	for %m ms ma nm
		m{%a}{%m}_tr = -sch_m{%a}{%m} * tr_m{%a}
		f{%a}{%m}nc6_tr = -sch_f{%a}{%m} * tr_f{%a}
	next
next


' **** Marital Status cluster ****
%msg = "... Marital Status effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

' Ages 55 to 74, SYOA
for %s m f 
	for %a {%age}
		{%s}{%a}_ms = eq_p{%s}{%a}.c(2) * msshare_{%s}{%a}
	next
next

' For all other ages marital status effect remains zero

' **** POC effect  ****
' Only applies to females ages 1617 and 1819
%msg = "... Presence of Children effect ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

for %a 1617 1819
	eq_rnlf{%a}_h.fit f{%a}_ch 		' POC effect is the fitted value from equations eq_rnlf1617_h and eq_rnlf1819_h; note that this include both intercept and slope!
	f{%a}_ch = -1 * f{%a}_ch 			' The final POC effect is NEGATIVE in the LFPR equation, i.e. -1 * the fitted value from above. 	 
next

' For all other ages in primary groups, POC effect remains zero; (there will be POC effect when we aggregate various groups later). 

' **** Global intercept *****
' This is the constant term from the main LFPR equations
%msg = "... Global intercept ... "
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl @all

for %g {%groups_eqns_1654} {%groups_eqns_5574}
	{%g}_in = eq_p{%g}.c(1)
next
for %g {%groups_eqns_5574}
	{%g}_in = eq_p{%g}.c(3)
next


' *** All clusters based on equation variables have been created. 
%msg = "... Done. All clusters have been created for primary groups. "
logmsg {%msg}
logmsg


' **** Create Total Base ****
%msg = "Computing Total Base for primary groups"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl %datestart %dateend 'sample period for the decomposition tables

for %g {%groups_primary}
	{%g}_tb={%g}_ag + {%g}_ge + {%g}_ms + {%g}_ch + {%g}_bc + {%g}_di + {%g}_ed + {%g}_rr + {%g}_et + {%g}_lc + {%g}_tr + {%g}_in
next

' At this point we have clusters corresponding to all elements in the equations.
' But none of the addfactors.
' Let's check that things add up so far.

' **** Intermediate check #1****
%msg = "Checking for consistency -- check #1 (Total  Base)"
logmsg {%msg}

smpl %datestart %dateend

' this is only done for UNADJUSTED LFPRs; the check would always fail for the adjusted LFPRs.
if %lfpr="u" then
	' Compare the 'total base' to p..._p from workfiles
	for %g {%groups_primary}
		series {%g}_ck1 = {%g}_tb - p{%g}_p_evp
	next
	
	' create a warning of the check fails
	string ck1_result = " " 	' this string will hold all warnings generated below
	!warn = 0
	for %g {%groups_primary}
		if @max({%g}_ck1) > 0.000001 then 
			!warn = !warn +1
			%warning = "Total base for " + %g + " does not match P" + %g + "_p loaded from " + %lfprs_1654 + " or " + %lfprs_55100
			ck1_result = ck1_result + %warning + @chr(13)
			else if @min({%g}_ck1) < - 0.000001 then
					!warn = !warn +1
					%warning = "Total base for " + %g + " does not match P" + %g + "_p loaded from " + %lfprs_1654 + " or " + %lfprs_55100
					ck1_result = ck1_result + %warning + @chr(13)
			endif
		endif
	next
	
	if !warn = 0 then %warning = "Consistency check #1 (Total Base) -- all clear!"
		ck1_result = ck1_result + %warning + @chr(13)
	endif
	ck1_result.display
endif

if %lfpr="a" then
	%msg = "SKIPPED for Adjusted LFPRs."
	logmsg {%msg}
	logmsg
endif
logmsg

' *********************************************************
' **** Step 5 -- Addfactors for PRIMARY groups *******
' ****

' ***** Individual Addfactors ******
' This is a SUM of _add and _add2 addfactors
%msg = "Create Inidividual Addfactors"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

' Addfactors in the LFPR model
' _add factor exists for all SYOA groups 55 to 74, M and F
' _add2 factors exists for all SYOA groups 55 to 74, M and F, and for M and F ages 1617 1819 2024 2529 3034 3539 4044 4549 5054. 
' NOTE: these 5yr groups are NOT primary groups, as they are not disaggregated by MS and POC.

' Collect _add and _add2 factors into the _ia cluster
' Before we start, series for .._ia clusters already exist for all a-s groups and they are all equal to zero

' For ages 55 to 74 SYOA, add BOTH addfactors (_add and _add2)
for %s m f
	for %a {%age}
		{%s}{%a}_ia = p{%s}{%a}_add + p{%s}{%a}_add2 	' for ages 55 to 74 SYOA, add BOTH addfactors (_add and _add2)
	next
next

' For ages 1617 to 5054, include _add2 only

' For ages 1617 and 1819, simply include  p..._add2
for %s m f 
	for %a 1617 1819
		{%s}{%a}_ia = p{%s}{%a}_add2
	next
next

' For Males 2024 to 5054, disaggregate by MS
for %a {%age5yr}
	for %m ms ma nm
		m{%a}{%m}_ia = pm{%a}_add2 * (pm{%a}{%m}_p_evp / pm{%a}_p_evp)		' this formula follows the way we apply _add2 addfactors in lfpr_proj_1654
	next
next

' For females ages 2024 to 4044, disaggregate by MS and POC
for %a 2024 2529 3034 3539 4044
	for %m ms ma nm
		for %k nc6 c6u
			f{%a}{%m}{%k}_ia = pf{%a}_add2 * (pf{%a}{%m}{%k}_p_evp / pf{%a}_p_evp) 	' this formula follows the way we apply _add2 addfactors in lfpr_proj_1654
		next
	next
next

' For females ages4549 and 5054, disaggregate by MS only
for %a 4549 5054
	for %m ms ma nm
		f{%a}{%m}_ia = pf{%a}_add2 * (pf{%a}{%m}_p_evp / pf{%a}_p_evp) 	' this formula follows the way we apply _add2 addfactors in lfpr_proj_1654
	next
next


' **** Life Expectancy Adjustment ****
' exist for all ages 2024 and older (all the way to 100), but are normally zero for many younger ages.
%msg = "Create Life Expectancy Adjustment"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

for %g {%groups_primary}
	%gr5=@lower(@left(%g, 5))			' extract from group name only the first 5 characters; example: f3034msc6u becomes f3034; if group name has fewer than 5 characters (say, m65), this string holds them all.
	!ck_age = @val(@right(%gr5, 2)) 	' NUMBER that corresponds to the LAST TWO digits in the age for each group; example for f1819 this is 19, for m64 it is 64; one problem -- for f100 and m100it is ZERO (we deal with this problem a few lines below).
	if !ck_age >20 then			' the LE adjustment exists only for ages 2024 and older, not for 1617 or 1819; last two digits of the age will always be larger than 20
		{%g}_le = 0.4 * p{%gr5}adj 	' this is the LE adjustment itself; note that the 0.4 coefficient we use for it is HARD CODED here; example: f4549ms_le = 0.4*pf4549adj
	endif
next
f100_le = 0.4 * pf100adj
m100_le = 0.4 * pm100adj


' **** Total Labor Force addfactor ****
' aka "global addfactor", thus the name _ga
' this is the addfactors that does the smoothing between the last historical and model values.
' There is no series that reflects its value, so we compute it by comparing the projected LFPRs in EViews files and the final ones as saved in TR databank
' The final LFPRs in TR databanks are obtained as follows:
' 	LFPR series (named like pm3034nm etc) are loaded from EViews projections files (these series are named p.._evp in this program);
'	Then LE adjustment and Total Labor Force adjustment are applied
' 	The result is the final LFPRs in TR banks (they are named p..._tr/yr/alt/ in this program)
' Thus, Total Labor Force adjustment (_ga) can be computed as follows:
' GA = p...._tr212 - p..._evp - LE adjustment

%msg = "Create Total Labor Force Addfactor"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

for %g {%groups_primary}
	{%g}_ga = p{%g}_{%tralt} - p{%g}_evp - {%g}_le
next


' ***** ALL clusters for PARIMARY groups have been computed ********
' ****************************************************************************

' **** Re-create the LFPRs and then do a consistency check -- PRIMARY GROUPS***
' Compute LFPRs from the components:
for %g {%groups_primary}
	series p{%g}_final =  	{%g}_bc + _' Bus Cycle cluster
								{%g}_di + _'  Disability Cluster
								{%g}_ed + _' Education cluster
								{%g}_rr + _'   Replacement rate
								{%g}_et + _'   Earnings test
								{%g}_lc + _'   Lagged cohort
								{%g}_tr + _'   Time trend
								{%g}_in + _'   Global intercept
								{%g}_ag + _'  Age effect (zero for primary groups)
								{%g}_ge + _'  Gender effect (zero for primary groups)
								{%g}_ms + _' Marital status effect
								{%g}_ch + _'  POC effect 
								{%g}_ia + _'   Individual addfactors (_add and _add2)
								{%g}_le + _'   Life expectancy adjustment
								{%g}_ga  	' Total Labor Force addfactor
next

' ***** In the final version Consistency Check #2 is commented out because all of it is done within the Consistency Check #3 ****
' But keep the code in case need this check for any development/debugging later
%msg = "Checking for consistency -- check #2 is skipped; please see Check #3 instead."
logmsg {%msg}
logmsg

'%msg = "Checking for consistency -- check #2"
'logmsg {%msg}
'logmsg

' **** Intermediate check #2 -- compare LFPRs for Primary groups between those computed here and those in A-bank
'wfselect {%thisfile}
'pageselect q
'smpl %datestart %dateend  ' sample over which we do decomposition; it only includes the projected values (from TRyr-1 Q4 onward); there is no reason why clusters should add up to LFPR in old historical periods.
'
'for %g {%groups_primary}
'	series {%g}_ck2 = p{%g}_{%tralt} - _'  LFPR loaded from TR databank
'						    p{%g}_final 			' LFPR re-created in this program above
'next

' create a warning of the check fails
'string ck2_result = " " 	' this string will hold all warnings generated below
'!warn = 0
'for %g {%groups_primary}
'	if @max({%g}_ck2) > 0.000001 then 
'		!warn = !warn +1
'		%warning = "Final LFPR for " + %g + " does not match P" + %g + " loaded from " + %abank
'		ck2_result = ck2_result + %warning + @chr(13)
'		else if @min({%g}_ck2) < - 0.000001 then
'				!warn = !warn +1
'				%warning = "Final LFPR for " + %g + " does not match P" + %g + " loaded from " + %abank
'				ck2_result = ck2_result + %warning + @chr(13)
'		endif
'	endif
'next
'if !warn = 0 then %warning = "Consistency check #2 -- all clear!"
'	ck2_result = ck2_result + %warning + @chr(13)
'endif
'ck2_result.display

' *****************************************************************************
' **** Step 6 -- Create LFPR decomposition for PRIMARY groups ********
' ******
%msg = "Creating decomposition for PRIMARY groups"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl %datestart %dateend 'sample period for the decomposition tables

for %g {%groups_primary}
	'compute cumulative change for each column in the table
	for %i {%list_col}
		series {%g}_{%i}_c={%g}_{%i}-@elem({%g}_{%i}, %datestart) 
	next
next

smpl @all 

' ***** Decomposition for PARIMARY groups is DONE ********
%msg = "Decomposition for PRIMARY groups is DONE."
logmsg {%msg}
logmsg



' ****************************************************************************************
' ****** Step 7 -- Create decomposition for AGGREGATE groups ******
' ****************************************************************************************

%msg = "Starting to work on AGGREGATE groups..."
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl @all

' *** Load all population series we will need
%msg = "Loading population series"
logmsg {%msg}
logmsg

' Create a list of all pop series we will need
%pop_list = "n16o"
for %name {%groups_primary}
	%pop_list=%pop_list+" n"+@lower(%name)
next

for %name {%groups_aggr}
	%pop_list=%pop_list+" n"+@lower(%name)
next

' get ALL population series from D-bank
wfopen {%dbankpath}
pageselect q		
for %ser {%pop_list} 
	copy {%dbank}::q\{%ser} {%thisfile}::q\ 		' copy from d-bank 
next
wfclose {%dbank}

'all population series have now been loaded


' **** Now start aggregating the primary groups up to aggregate ones
wfselect {%thisfile}
pageselect q
smpl %datestart %dateend  		' sample for decomposition

'for Adjusted LFPRs, reset population to a constant value equal to that in th base year; for unadjusted LFPRs this step is skipped
if %lfpr="a" then 
	for %ser {%pop_list}
	if !annual>0 then 
		{%ser} = 0.25*@elem({%ser}, %base1) + 0.25*@elem({%ser}, %base2) + 0.25*@elem({%ser}, %base3) + 0.25*@elem({%ser}, %base4)  
		else {%ser} = @elem({%ser}, %LFPR_adj_base)
	endif
	next
endif 

%levels="le ia tb in ga" 							'columns for which we compute weighted average of LEVELs
%clusters="ag ge ms ch bc di ed rr et lc tr" 	'list of clusters for which we compute weighted average of CHANGES, and the demo effects

'declare series for level and change for the aggregate groups and initialize them to zero
for %name {%groups_aggr}
	for %col {%clusters}	
		series {%name}_{%col}_c=0
		series _16o_{%col}_c=0
	next
next

'********* Loop through all aggregated groups ******
%msg = "Computing decomposition for AGGREGATE groups..."
logmsg {%msg}

wfselect {%thisfile}
pageselect q
smpl %datestart %dateend 

for %gr {%groups_aggr}

	'create strings from the group name that will be used to denote variables in the computation
	%groupfull=@lower(%gr) 			' full name of the group, all letters are made to be lower-case
	%grg=@lower(@left(%gr, 1)) 	'single-character gender identifier
	%gr5=@lower(@left(%gr, 5))	' first 5 characters of group name; if group name has fewer than 5 characters, this string holds them all.
	!gr2num=@val(@mid(%gr, 2, 2)) 'first two numerals in the group name, saved as a number (not a string)
	%o=@mid(%gr, 4, 1) 				'returns "o" for m16o, m65o, m70o, m75o, m80o, m85o (same for female groups), but not for other groups; it does NOT return "o" for 16o. 

	'compute LFPR decomposition values for the aggregate groups; computation differs for different kinds of groups, so several if's below to account for that
	if !gr2num<55 and @len(%groupfull)>4 then 'for all male and female 5yr groups up to age 5054
		if %gr5=%groupfull then 'male and female 5yr groups up to 5054 (f2024, F4044, M4549 etc)
			'create pop weights
			series {%groupfull}nm_wt=n{%gr5}nm/n{%gr5}
			series {%groupfull}ms_wt=n{%gr5}ms/n{%gr5}
			series {%groupfull}ma_wt=n{%gr5}ma/n{%gr5}
			for %col {%levels} 'weighted average of levels for some columns
				series {%groupfull}_{%col}=	{%groupfull}nm_wt*{%groupfull}nm_{%col} + _
													{%groupfull}ms_wt*{%groupfull}ms_{%col} + _
													{%groupfull}ma_wt*{%groupfull}ma_{%col} 
				series {%groupfull}_{%col}_c = {%groupfull}_{%col} - @elem({%groupfull}_{%col}, %datestart) 'compute change from levels
			next
			for %col {%clusters} 'weighted avg of changes for some columns
				{%groupfull}_{%col}_c=	{%groupfull}_{%col}_c + _
												{%groupfull}nm_wt*{%groupfull}nm_{%col}_c + _
												{%groupfull}ms_wt*{%groupfull}ms_{%col}_c + _
												{%groupfull}ma_wt*{%groupfull}ma_{%col}_c 
			next
			'marital status effect
			{%groupfull}_ms_c = {%groupfull}_ms_c + _
									@elem({%groupfull}nm_tb, %datestart)*({%groupfull}nm_wt-@elem({%groupfull}nm_wt, %datestart)) + _
									@elem({%groupfull}ms_tb, %datestart)*({%groupfull}ms_wt-@elem({%groupfull}ms_wt, %datestart)) + _
									@elem({%groupfull}ma_tb, %datestart)*({%groupfull}ma_wt-@elem({%groupfull}ma_wt, %datestart))
									
		else 'this applies only to females (f2024nm, f2024ms, etc)
			series {%groupfull}c6u_wt=n{%groupfull}c6u/n{%groupfull}
			series {%groupfull}nc6_wt=n{%groupfull}nc6/n{%groupfull}
			for %col {%levels}
				series {%groupfull}_{%col}=	{%groupfull}c6u_wt*{%groupfull}c6u_{%col} + _
													{%groupfull}nc6_wt*{%groupfull}nc6_{%col}			
				series {%groupfull}_{%col}_c = {%groupfull}_{%col} - @elem({%groupfull}_{%col}, %datestart) 'compute change from levels
			next
			for %col {%clusters}
				{%groupfull}_{%col}_c=	{%groupfull}_{%col}_c + _
												{%groupfull}c6u_wt*{%groupfull}c6u_{%col}_c + _
												{%groupfull}nc6_wt*{%groupfull}nc6_{%col}_c 
			next
			'child presence effect
			{%groupfull}_ch_c = {%groupfull}_ch_c + _
						 				@elem({%groupfull}c6u_tb, %datestart)*({%groupfull}c6u_wt-@elem({%groupfull}c6u_wt, %datestart)) + _
										@elem({%groupfull}nc6_tb, %datestart)*({%groupfull}nc6_wt-@elem({%groupfull}nc6_wt, %datestart))
		endif
	endif

	if  !gr2num>50 and @len(%groupfull)>4 then 'for male and female groups 5559 to 9599 (they are averages of 5 single-year groups)
		'names of the single-year series
		%g1= %grg+@str(!gr2num)
		%g2= %grg+@str(!gr2num+1)
		%g3= %grg+@str(!gr2num+2)
		%g4= %grg+@str(!gr2num+3)
		%g5= %grg+@str(!gr2num+4)
		'create pop weights
		series {%g1}_wt=n{%g1}/n{%gr5}
		series {%g2}_wt=n{%g2}/n{%gr5}
		series {%g3}_wt=n{%g3}/n{%gr5}
		series {%g4}_wt=n{%g4}/n{%gr5}
		series {%g5}_wt=n{%g5}/n{%gr5}
	
		for %col {%levels}
			series {%groupfull}_{%col}=	{%g1}_wt*{%g1}_{%col} + _
												{%g2}_wt*{%g2}_{%col} + _
												{%g3}_wt*{%g3}_{%col} + _
												{%g4}_wt*{%g4}_{%col} + _
												{%g5}_wt*{%g5}_{%col}	
			series {%groupfull}_{%col}_c = {%groupfull}_{%col} - @elem({%groupfull}_{%col}, %datestart) 'compute change from levels
		next
											
		for %col {%clusters}
			{%groupfull}_{%col}_c =	{%groupfull}_{%col}_c + _
											{%g1}_wt*{%g1}_{%col}_c + _
											{%g2}_wt*{%g2}_{%col}_c + _
											{%g3}_wt*{%g3}_{%col}_c + _
											{%g4}_wt*{%g4}_{%col}_c + _
											{%g5}_wt*{%g5}_{%col}_c
		next
		' age effect
		{%groupfull}_ag_c = 	{%groupfull}_ag_c + _
									@elem({%g1}_tb, %datestart)*({%g1}_wt - @elem({%g1}_wt, %datestart)) + _
									@elem({%g2}_tb, %datestart)*({%g2}_wt - @elem({%g2}_wt, %datestart)) + _
									@elem({%g3}_tb, %datestart)*({%g3}_wt - @elem({%g3}_wt, %datestart)) + _
									@elem({%g4}_tb, %datestart)*({%g4}_wt - @elem({%g4}_wt, %datestart)) + _
									@elem({%g5}_tb, %datestart)*({%g5}_wt - @elem({%g5}_wt, %datestart))			
	endif

	if %o="o" and !gr2num=85 then ' for m85o and f85o 
		'create pop weights
		series {%grg}8589_wt=n{%grg}8589/n{%grg}85o
		series {%grg}9094_wt=n{%grg}9094/n{%grg}85o
		series {%grg}9599_wt=n{%grg}9599/n{%grg}85o
		series {%grg}100_wt=n{%grg}100/n{%grg}85o
	
		for %col {%levels}
			series {%groupfull}_{%col}=	{%grg}8589_wt*{%grg}8589_{%col} + _
												{%grg}9094_wt*{%grg}9094_{%col} + _
												{%grg}9599_wt*{%grg}9599_{%col} + _
												{%grg}100_wt*{%grg}100_{%col} 
			series {%groupfull}_{%col}_c = {%groupfull}_{%col} - @elem({%groupfull}_{%col}, %datestart) 'compute change from levels

		next
		for %col {%clusters}
			{%groupfull}_{%col}_c = 	{%groupfull}_{%col}_c + _
											{%grg}8589_wt*{%grg}8589_{%col}_c + _
											{%grg}9094_wt*{%grg}9094_{%col}_c + _
											{%grg}9599_wt*{%grg}9599_{%col}_c + _
											{%grg}100_wt*{%grg}100_{%col}_c 
		next
		' age effect
		{%groupfull}_ag_c = 	{%groupfull}_ag_c + _
									@elem({%grg}8589_tb, %datestart)*({%grg}8589_wt - @elem({%grg}8589_wt, %datestart)) + _
									@elem({%grg}9094_tb, %datestart)*({%grg}9094_wt - @elem({%grg}9094_wt, %datestart)) + _
									@elem({%grg}9599_tb, %datestart)*({%grg}9599_wt - @elem({%grg}9599_wt, %datestart)) + _
									@elem({%grg}100_tb, %datestart)*({%grg}100_wt - @elem({%grg}100_wt, %datestart)) 
									
									
	else 
		if %o="o" and !gr2num>16 then 'for m65o, m70o, m75o, m80o (and same female), but NOT m16o, f16o, or 16o
			'names of component series -- say, for m80 these are m8084 and m85o
			%g1 = %grg+@str(!gr2num)+@str(!gr2num+4)
			%g2 = %grg+@str(!gr2num+5)+"o"
			'create pop weights
			series {%g1}_wt=n{%g1}/n{%groupfull}
			series {%g2}_wt=n{%g2}/n{%groupfull}
		
			for %col {%levels}
				series {%groupfull}_{%col}=	{%g1}_wt*{%g1}_{%col} + _
													{%g2}_wt*{%g2}_{%col}
				series {%groupfull}_{%col}_c = {%groupfull}_{%col} - @elem({%groupfull}_{%col}, %datestart) 'compute change from levels
			next

			for %col {%clusters}
				{%groupfull}_{%col}_c = 	{%groupfull}_{%col}_c + _
												{%g1}_wt*{%g1}_{%col}_c + _
												{%g2}_wt*{%g2}_{%col}_c
			next
			' age effect
			{%groupfull}_ag_c = {%groupfull}_ag_c + _
									@elem({%g1}_tb, %datestart)*({%g1}_wt - @elem({%g1}_wt, %datestart)) + _
									@elem({%g2}_tb, %datestart)*({%g2}_wt - @elem({%g2}_wt, %datestart)) 
		endif
	endif


	if %o="o" and !gr2num=16 then 'for m16o, f16o, but not 16o
		'create pop weights
		series {%grg}1617_wt=n{%grg}1617/n{%grg}16o
		series {%grg}1819_wt=n{%grg}1819/n{%grg}16o
		series {%grg}2024_wt=n{%grg}2024/n{%grg}16o
		series {%grg}2529_wt=n{%grg}2529/n{%grg}16o
		series {%grg}3034_wt=n{%grg}3034/n{%grg}16o
		series {%grg}3539_wt=n{%grg}3539/n{%grg}16o
		series {%grg}4044_wt=n{%grg}4044/n{%grg}16o
		series {%grg}4549_wt=n{%grg}4549/n{%grg}16o
		series {%grg}5054_wt=n{%grg}5054/n{%grg}16o
		series {%grg}5559_wt=n{%grg}5559/n{%grg}16o
		series {%grg}6064_wt=n{%grg}6064/n{%grg}16o
		series {%grg}65o_wt=n{%grg}65o/n{%grg}16o
	
		for %col {%levels}
			series {%groupfull}_{%col} = {%grg}1617_wt*{%grg}1617_{%col} + _
												{%grg}1819_wt*{%grg}1819_{%col} + _
												{%grg}2024_wt*{%grg}2024_{%col} + _
												{%grg}2529_wt*{%grg}2529_{%col} + _ 
												{%grg}3034_wt*{%grg}3034_{%col} + _ 
												{%grg}3539_wt*{%grg}3539_{%col} + _ 
												{%grg}4044_wt*{%grg}4044_{%col} + _ 
												{%grg}4549_wt*{%grg}4549_{%col} + _ 
												{%grg}5054_wt*{%grg}5054_{%col} + _ 
												{%grg}5559_wt*{%grg}5559_{%col} + _ 
												{%grg}6064_wt*{%grg}6064_{%col} + _ 
												{%grg}65o_wt*{%grg}65o_{%col}
			series {%groupfull}_{%col}_c = {%groupfull}_{%col} - @elem({%groupfull}_{%col}, %datestart) 'compute change from levels
		next
		
		for %col {%clusters}
			{%groupfull}_{%col}_c =	{%groupfull}_{%col}_c + _
											{%grg}1617_wt*{%grg}1617_{%col}_c + _
											{%grg}1819_wt*{%grg}1819_{%col}_c + _
											{%grg}2024_wt*{%grg}2024_{%col}_c + _
											{%grg}2529_wt*{%grg}2529_{%col}_c + _ 
											{%grg}3034_wt*{%grg}3034_{%col}_c + _ 
											{%grg}3539_wt*{%grg}3539_{%col}_c + _ 
											{%grg}4044_wt*{%grg}4044_{%col}_c + _ 
											{%grg}4549_wt*{%grg}4549_{%col}_c + _ 
											{%grg}5054_wt*{%grg}5054_{%col}_c + _ 
											{%grg}5559_wt*{%grg}5559_{%col}_c + _ 
											{%grg}6064_wt*{%grg}6064_{%col}_c + _ 
											{%grg}65o_wt*{%grg}65o_{%col}_c
		next
		' age effect
		{%groupfull}_ag_c =	{%groupfull}_ag_c + _
								@elem({%grg}1617_tb, %datestart)*({%grg}1617_wt - @elem({%grg}1617_wt, %datestart)) + _
								@elem({%grg}1819_tb, %datestart)*({%grg}1819_wt - @elem({%grg}1819_wt, %datestart)) + _
								@elem({%grg}2024_tb, %datestart)*({%grg}2024_wt - @elem({%grg}2024_wt, %datestart)) + _
								@elem({%grg}2529_tb, %datestart)*({%grg}2529_wt - @elem({%grg}2529_wt, %datestart)) + _
								@elem({%grg}3034_tb, %datestart)*({%grg}3034_wt - @elem({%grg}3034_wt, %datestart)) + _
								@elem({%grg}3539_tb, %datestart)*({%grg}3539_wt - @elem({%grg}3539_wt, %datestart)) + _
								@elem({%grg}4044_tb, %datestart)*({%grg}4044_wt - @elem({%grg}4044_wt, %datestart)) + _
								@elem({%grg}4549_tb, %datestart)*({%grg}4549_wt - @elem({%grg}4549_wt, %datestart)) + _
								@elem({%grg}5054_tb, %datestart)*({%grg}5054_wt - @elem({%grg}5054_wt, %datestart)) + _
								@elem({%grg}5559_tb, %datestart)*({%grg}5559_wt - @elem({%grg}5559_wt, %datestart)) + _
								@elem({%grg}6064_tb, %datestart)*({%grg}6064_wt - @elem({%grg}6064_wt, %datestart)) + _
								@elem({%grg}65o_tb, %datestart)*({%grg}65o_wt - @elem({%grg}65o_wt, %datestart))
 
 
	endif

next 'end of aggr groups loop (it started on line 949)

'do group ****16o**** separately here 
'create pop weights
series m16o_wt=nm16o/n16o
series f16o_wt=nf16o/n16o
for %col {%levels}
	series _16o_{%col}=	m16o_wt * m16o_{%col} + _
									f16o_wt * f16o_{%col}
	series _16o_{%col}_c = _16o_{%col} - @elem(_16o_{%col}, %datestart) 'compute change from levels
next

for %col {%clusters}
	_16o_{%col}_c = 	_16o_{%col}_c + _
								m16o_wt * m16o_{%col}_c + _
								f16o_wt * f16o_{%col}_c
next

' gender effect
series _16o_ge_c = _16o_ge_c + _
							@elem(m16o_tb, %datestart)*(m16o_wt - @elem(m16o_wt, %datestart)) + _
							@elem(f16o_tb, %datestart)*(f16o_wt - @elem(f16o_wt, %datestart))

' _16o group is now done

%msg = "DONE. ALL groups -- both primary and aggregate -- are now done."
logmsg {%msg}
logmsg
'****************** ALL groups are now done -- both primary and aggregated *********


' ********************************************************************************************************
' ******* Step 8 -- Compute "final LFPR"  and residuals for ALL groups (primary and aggregated) and create a list of all residual series
' ********************************************************************************************************
' Also, do a consistency check -- compare 'final' LFPR computed here to that in the TR databanks
%msg = "Computing final LFPRs and consistency check #3 -- Final LFPRs."
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl %datestart %dateend 


%list_resids = ""
for %gr {%groups_primary} {%groups_aggr} _16o 
	series p{%gr}_final = {%gr}_ga + {%gr}_le + {%gr}_ia + {%gr}_tb 			' final LFPR
	series p{%gr}_final_c = p{%gr}_final - @elem(p{%gr}_final, %datestart) 	'cumulative change in final LFPR
	series {%gr}_res_c = {%gr}_tb_c - ({%gr}_ag_c + {%gr}_ge_c + {%gr}_ms_c + {%gr}_ch_c + {%gr}_bc_c + {%gr}_di_c + {%gr}_ed_c + {%gr}_rr_c + {%gr}_et_c + {%gr}_lc_c + {%gr}_tr_c)
	%list_resids=%list_resids + %gr + "_res_c "
	if %lfpr="u" then
		' Consistency check #3 -- Done only for UNADJUSTED LFPRs (it will always fail for the Adjusted ones)
		series {%gr}_ck3 = p{%gr}_final - p{%gr}_{%tralt}
	endif
next

if %lfpr="u" then
	' create a warning if Consistency Check #3 fails
	string ck3_result = " " 	' this string will hold all warnings generated below
	!warn = 0
	for %g {%groups_primary} {%groups_aggr} _16o
		if @max({%g}_ck3) > 0.00001 then 
			!warn = !warn +1
			%warning = "Final LFPR for " + %g + " does not match p" + %g + " loaded from " + %abank
			ck3_result = ck3_result + %warning + @chr(13)
			else if @min({%g}_ck3) < - 0.00001 then
					!warn = !warn +1
					%warning = "Final LFPR for " + %g + " does not match p" + %g + " loaded from " + %abank
					ck3_result = ck3_result + %warning + @chr(13)
			endif
		endif
	next
	
	if !warn = 0 then %warning = "Consistency check #3 (Final LFPRs) -- all clear!"
		ck3_result = ck3_result + %warning + @chr(13)
	endif
	ck3_result.display
endif

if %lfpr="a" then
	%msg = "Consistency check #3 SKIPPED for Adjusted LFPRs."
	logmsg {%msg}
	logmsg
endif


'check that ALL residual are zero and display a message to that effect
spool report 
string warning = "Non-zero residuals found for the following years"
string congrats = "Congratulations! All residuals are zero."

!count=0
for %r {%list_resids}
	smpl %datestart %dateend if @abs({%r})>0.00001
	if @obssmpl>0 then 
		freeze(nz_{%r}) {%r}.sheet
		report.append warning
		report.append nz_{%r}
		!count=!count+1
	endif
	smpl %datestart %dateend
next

if !count=0 then report.append congrats
endif

report.display

' ********************************************************************************************************
' ******* Step 9 -- Create output tables for user-specified groups
' ********************************************************************************************************
%msg = "Creating decomposition tables for groups specified by user..."
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect q
smpl %datestart %dateend 'period for which LFPR decomposition is to be done

!last_row=!endyr - !TRyr + 9 'this is the row number fo the last year in the decomposition table


'********** loop that creates the output tables for groups requested by the user

for %g {%user_groups}  
	if  @lower(%g)="16o" then %g="_16o" 'need this because EViews does not allow series name to start from a number
	endif
		%list_table = "p"+@lower(%g)+"_final" +" p"+@lower(%g)+"_final_c " 'start building a list of series that make up the decomposition table, IN THE DESIRED ORDER 
		for %i {%list_col} 
			%list_table = %list_table + @lower(%g)+"_"+%i+"_c "  'add all cumulative change series to the list
		next
	%list_table = %list_table + @lower(%g)+"_res_c " 'add the residuals column
	
	group table_{%g} {%list_table} 'collect all columns in a group (this will be in page q, and it is quarterly)

	pageselect results 'switch to the "results" page in the workfile (it is annual)
	for %i {%list_table}  'copy all relevant series to the "results" workfile page and convert them from Q to A by taking Q4 value
		copy(c=l) q\{%i}  
	next

	group results_{%g} {%list_table} 		'group the annual series in the desired order
	freeze(lfpr_{%g}) results_{%g}.sheet 	'freeze the table and name it lfpr_group

	delete *_c results* p* 'this deletes the ANNUAL cumulative change series to clean up the workfile

	'format the table 
	%base_text = %LFPR_adj_base
	if !annual > 0 then %base_text = @str(!annual)+" annual"
	endif
	
	if %lfpr="a" then 
		%title = "LFPR Decomposition "+%g+" TR"+@str(!TRyr)+" alt"+%alt+" (adjusted for age, sex, marital status, presence of children, base "+%base_text+")"
		else %title = "LFPR Decomposition "+%g+" TR"+@str(!TRyr)+" alt"+%alt+" (unadjusted)"
	endif 

	lfpr_{%g}.title {%title}
	lfpr_{%g}.setformat(@all) f.5
	lfpr_{%g}.setwidth(@all) 8
	lfpr_{%g}.setwidth(A) 6
	lfpr_{%g}.insertrow(1) 5
	lfpr_{%g}.setjust(A6:S6) center
	for !i=1 to 19
		lfpr_{%g}(6,!i)=" " 		'clear line 6 of the series names
	next

	'create borders for cells in the table heading
	lfpr_{%g}.setlines(A1:S7) +a
	lfpr_{%g}.setlines(A1) +a
	lfpr_{%g}.setlines(D1) +a
	lfpr_{%g}.setlines(A7:S7) -d
		
	lfpr_{%g}.setlines(A1:A7) -i
	lfpr_{%g}.setlines(B1:B3) -i

	lfpr_{%g}.setlines(B4:B7) -i
	lfpr_{%g}.setlines(C4:C7) -i
	lfpr_{%g}.setlines(D3:D7) -i
	lfpr_{%g}.setlines(E3:E7) -i
	lfpr_{%g}.setlines(F3:F7) -i
	lfpr_{%g}.setlines(G3:G7) -i

	lfpr_{%g}.setlines(H5:H7) -i
	lfpr_{%g}.setlines(I5:I7) -i
	lfpr_{%g}.setlines(J5:J7) -i
	lfpr_{%g}.setlines(K5:K7) -i

	lfpr_{%g}.setlines(L4:L7) -i
	lfpr_{%g}.setlines(M4:M7) -i
	lfpr_{%g}.setlines(N4:N7) -i
	lfpr_{%g}.setlines(O4:O7) -i
	lfpr_{%g}.setlines(P4:P7) -i
	lfpr_{%g}.setlines(Q4:Q7) -i
	lfpr_{%g}.setlines(R4:R7) -i
	lfpr_{%g}.setlines(S4:S7) -i

	lfpr_{%g}.setlines(A8:S{!last_row}) +o
	lfpr_{%g}.setlines(A8:A{!last_row}) +r
	lfpr_{%g}.setlines(C8:C{!last_row}) +o
	lfpr_{%g}.setlines(G8:G{!last_row}) +o
	lfpr_{%g}.setlines(S8:S{!last_row}) +l

	lfpr_{%g}(2,1) = "Cal."
	lfpr_{%g}(3,1)="Year"
	lfpr_{%g}.setmerge(b1:c1)
	lfpr_{%g}.setmerge(b2:c2)
	lfpr_{%g}.setmerge(b3:c3)
	lfpr_{%g}(2,2)="Projected LFPR"
	lfpr_{%g}(3,2)="in Q4 of Cal. Year"
	lfpr_{%g}(4,2)="Level"
	lfpr_{%g}(4,3)="Cumul."
	lfpr_{%g}(5,3)="Change"
	lfpr_{%g}.setmerge(d1:s1)
	lfpr_{%g}(1,4)="Decomposition of Cumulative Change from 4th Qtr. of "+@str(!TRyr-1)
	lfpr_{%g}.setmerge(d2:f2)
	lfpr_{%g}(2,4)="Adjustments"
	lfpr_{%g}(3,4)="Total"
	lfpr_{%g}(4,4)="Labor"
	lfpr_{%g}(5,4)="Force"
	lfpr_{%g}(3,5)="Life"
	lfpr_{%g}(4,5)="Expect."
	lfpr_{%g}(3,6)="Individual"
	lfpr_{%g}(4,6)="Add-"
	lfpr_{%g}(5,6)="factors"
	lfpr_{%g}.setmerge(g2:s2)
	lfpr_{%g}(2,7)="Base"
	lfpr_{%g}(3,7)="Total"
	lfpr_{%g}.setmerge(h3:s3)
	lfpr_{%g}(3,8)="Components"
	lfpr_{%g}.setmerge(h4:k4)
	lfpr_{%g}(4,8)="Change in Demo. Dist."
	lfpr_{%g}(5,8)="Age"
	lfpr_{%g}(5,9)="Gender"
	lfpr_{%g}(5,10)="Mar. "
	lfpr_{%g}(6,10)="Status"
	lfpr_{%g}(5,11)="Child"
	lfpr_{%g}(6,11)=" Pres."
	lfpr_{%g}(4,12)="Bus. "
	lfpr_{%g}(5,12)="Cycle"
	lfpr_{%g}(4,13)="Disab."
	lfpr_{%g}(5,13)="Prev."
	lfpr_{%g}(4,14)="Educ."
	lfpr_{%g}(4,15)="Rep."
	lfpr_{%g}(5,15)="Rate"
	lfpr_{%g}(4,16)="Earn."
	lfpr_{%g}(5,16)="Test"
	lfpr_{%g}(4,17)="Lagged"
	lfpr_{%g}(5,17)="Cohort"
	lfpr_{%g}(6,17)="(75o)"
	lfpr_{%g}(4,18)="Trend"
	lfpr_{%g}(4,19)="Residual"

	pageselect q 'go back to page q for the next group in the loop

next ' (end of loop that started on line 1284)

'********** end of loop that creates the output tables

%msg =  "LFPR decomposition is complete. Resulting tables are in the ""results"" page."
logmsg {%msg}
logmsg

string summary = "LFPR decomposition is complete. Resulting tables are in the ""results"" page."
report.append summary
report.display 'display on screen the spool that would indicate if we found any non-zero residuals

pageselect results

' **********************************************************************************************
' ******* Step 10 -- Compare LFPRs produced by this program to those in the databanks
' **********************************************************************************************

' Compare LFPRs produced by this program to those in the databank. Here is done only for all160, f160, and m16o. 
' For Unadjusted LFPRs other comparisons are done in Consistency Check #3. 
' For Adjusted LFPRs, only all160, f160, and m16o comparison are possible b/c we do not have any other _asa series in databanks.

pagecreate(page=comparison) q %datestart %dateend

pageselect comparison

' copy the series I need to the page 'comparison'
copy q\p_16o_final comparison\ 
copy q\pf16o_final comparison\ 
copy q\pm16o_final comparison\ 

copy q\p16o_{%tralt} comparison\ 
copy q\pf16o_{%tralt} comparison\ 
copy q\pm16o_{%tralt} comparison\ 

copy q\p16o_asa_{%tralt} comparison\ 
copy q\pf16o_asa_{%tralt} comparison\ 
copy q\pm16o_asa_{%tralt} comparison\ 

' do the comparison and report results on screen
if %lfpr="a" then 
	group all16o p_16o_final p16o_asa_{%tralt}
	series p16o_ck = p16o_asa_{%tralt} - p_16o_final
	group f16o pf16o_final  pf16o_asa_{%tralt}
	series pf16o_ck = pf16o_asa_{%tralt} - pf16o_final
	group m16o pm16o_final  pm16o_asa_{%tralt}
	series pm16o_ck = pm16o_asa_{%tralt} - pm16o_final
endif

if %lfpr="u" then 
	group all16o p_16o_final p16o_{%tralt}
	series p16o_ck = p16o_{%tralt} - p_16o_final
	group f16o pf16o_final  pf16o_{%tralt}
	series pf16o_ck = pf16o_{%tralt} - pf16o_final
	group m16o pm16o_final  pm16o_{%tralt}
	series pm16o_ck = pm16o_{%tralt} - pm16o_final
endif

' Check to see if any of the p.._ck series are nonzero and display a warning to that effect
spool compare 'spool to display messages
!count=0
for %ser p16o_ck pf16o_ck pm16o_ck
	smpl %datestart %dateend if @abs({%ser})>0.00001
	if @obssmpl>0 then 
		freeze(nz_{%ser}) {%ser}.sheet
		string warn = "!!! Non-zero differences found for " + %ser + ". Please see the relevant group comparison in page ""comparison""! " + @chr(13) + "If this is decomposition for ADJUSTED LFPRs, the discrepancy may be due to adjustment for marital status and presence of children. "
		compare.append warn
		'compare.append nz_{%ser}
		!count=!count+1
	endif
	smpl %datestart %dateend
next

string match = "Final LFPRs for F16o, M16o, and All16o match those in bank " + %abank
if !count=0 then compare.append match
endif

compare.display


' *****************************************************
' ******* Step 11 -- Final spool and save the file
' *****************************************************
wfselect {%thisfile}
pageselect results
smpl %datestart %dateend

copy comparison\compare results\ 

if %lfpr="u" then
	copy q\ck1_result results\ 
	copy q\ck3_result results\
	else 
		pageselect results
		string ck1_result = "Consistency Check #1 is skipped for Adjusted LFPRs."
		string ck3_result = "Consistency Check #3 is skipped for Adjusted LFPRs."
endif
 
pageselect results

spool consistency_checks
string line1 = "Consistency Check #1 -- Total Base"
consistency_checks.insert line1
consistency_checks.append ck1_result
string line1 = "Consistency Check #3 -- Final LFPRs"
consistency_checks.insert line1
consistency_checks.append ck3_result

'create a spool that would contain summary info for the run
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %usr
string line2 = "The run represents a run for TR" + @str(!TRyr) + ", alt " + %alt + ", and LFPRs that are [" + %lfpr + "];" + @chr(13) + "[a]=adjusted, [u]=unadjusted"
string line3 = "The run uses the following inputs:"
string line4 = "a-bank: " + %abankpath
string line5 = "d-bank: " + %dbankpath
string line6 = "[we no longer use op-bank for decomposition] " 
string line7 = "add-bank: " + %adbankpath
string line8 = "LFPR equations and coefficients from " + @chr(13) + %lfprs_1654_path + @chr(13) + " and " + @chr(13) + %lfprs_55100_path
if !annual > 0 then
	string line9 = "If LFPRs are adjusted, the base used for the adjustment is annual values for " + @str(!annual)
	else string line9 = "If LFPRs are adjusted, the base used for the adjustment is " + %LFPR_adj_base
endif
string line10 = "See spools 'compare' and 'consistency_checks' for various checks on the resulting LFPRs!"
string line11 = %note

if %sav = "Y" then
	string line12 = "The resulting workfile -- " + %thisfile + " -- has been saved to " +%folder_output
	logmsg {line12}
	logmsg
endif
if %sav = "N" then
	string line12 = "The resulting workfile -- " + %thisfile + " -- has NOT been saved. Please save the file manually if desired."
	logmsg {line12}
	logmsg
endif

_summary.insert line1 
_summary.append compare
_summary.insert line2 line3 line4 line5 line6 line7 line8 line9 line10 line11
if %sav = "Y" then
	_summary.insert line12
endif
_summary.display

delete line*

if %sav = "Y" then 
	'save the workfile
	%save_file = %folder_output + %thisfile  
	wfsave %save_file
endif

logmsg FINISHED

' wfclose


