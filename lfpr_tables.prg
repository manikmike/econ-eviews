' This program creates tables that summarize any given TR's projections for LFPRs and E/POP, and compare them to the previous TR's projections. 
' These charts and tables (most fo them) are used in the Empl/LF Projections paper
' THIS VERSION  is adjusted to reflect the new LF model first introduced for TR21.

' TODO
' consider creating a comaprison for edscore and msshare series between current TR and prior TR
' Frequently, one reason for LFPR projections being different from one TR to the next is educational attainment; 
' would help to have an automated comparison of eduscores to be able to see it.
' Currently, edscored and mssahre series are copied into the TR???_q page; but comparison with last TR must be done manually. Consider automating.
' update 2025-01-17 -- this comparison already exists, it is done by the program lfpr_compare.prg, 
'    result currently saved in file lfprs_tr25_vs_tr24.wf1 in \\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\LFPR_ConsistencyChecks

'This program uses the following databanks:
' NOTE -- the program has been changed ot use EVIEWS WORKFILES only!!!
' bkdo1.bnk (to get pop data for computing ASA values); Note: using pop data from D-banks does not work -- see comments around line 235 below.
' a-bank (current TR and previous-year TR)
' d-bank (current TR and previous-year TR)
' AND it requires four LFPR decomposition files:
' current TR Unadjusted LFPRs
' current TR Adjusted LFPRs
' previous TR Unadjusted LFPRs
' previous TR Adjusted LFPRs

' The program creates the following figures and tables 
' Name in paper 		Description											Name in the workfile/program 
' Figures (recurring note numbering, updated for TR23)
' Fig 1	(skip)			E/Pop projections, gross							proj_epop_chart
' Fig 2	(1)					E/Pop projections, ASA								proj_epop_asa_chart
' NEW for recurring note TR23
' 			Fig 2  E/Pop Men by age group 											me_lvl
' 			Fig 3  E/Pop Women by age group									fe_lvl		
' Fig 3	(skip)			E/Pop change by age group, MEN					me_chg 		(see values in matrix males_e in page 'TR232_q')
' Fig 4	(skip)			E/Pop change by age group, WOMEN			fe_chg 			(see values in matrix females_e in page 'TR232_q')
' Fig 5	(skip)			RU projections, gross								proj_ru_chart 
' Fig 6	(4)					RU projections, ASA									proj_ru_asa_chart
' NEW for recurring note TR23
' 			Fig 5 RU Men by age group 												mru_lvl
' 			Fig 6 RU Women by age	group										fru_lvl
' Fig 7	(skip)			RU change by age group							ru_chg_sr 		(see values in matrix all_ru_sr in page 'TR232_q')
' Fig 8	(skip)				LFPR projections, gross						proj_lfpr_chart
' Fig 9	(7)				LFPR projections, ASA									proj_lfpr_asa_chart	
' Fig 10	(skip)			LFPR Model factors, ASA, MEN						m_decomp_a 		(values are from tables table_tr2023_sr_a and table_tr2023_lr_a, and also collected in matrix m_adj in page 'tables')
' Fig 11	(skip)			LFPR Model factors, ASA, WOMEN				f_decomp_a 		(values are from tables table_tr2023_sr_a and table_tr2023_lr_a, and also collected in matrix f_adj in page 'tables')
' Fig 12	(skip)			LFPR Model factors, gross, MEN					m_decomp_u 		(values are from tables table_tr2023_sr_u and table_tr2023_lr_u, and also collected in matrix m_unadj in page 'tables')
' Fig 13	(skip)			LFPR Model factors, gross, WOMEN			f_decomp_u 		(values are from tables table_tr2023_sr_u and table_tr2023_lr_u, and also collected in matrix f_unadj in page 'tables')
' NEW for recurring note
' combined (8)		LFPR Model factors, MEN										m_decomp  	(values are from tables table_tr2023_sr_a and table_tr2023_lr_a, and also collected in matrix m_comb in page 'tables')
' 									LFPR Model factors, MEN (expanded)			m_deomp_ex  	(totals are colored different color)
'  			 			(9)		LFPR Model factors, WOMEN								f_decomp  	(values are from tables table_tr2023_sr_a and table_tr2023_lr_a, and also collected in matrix f_comb in page 'tables')
' 									LFPR Model factors, WOMEN (expanded)	f_deomp_ex  	(totals are colored different color)
' (not used in paper) LFPR model factors, ASA, all 16+			all_decomp_a 	(values are from tables table_trXXXX_sr_a and table_trXXXX_lr_a)
'									LFPR model factors, gross, all 16+				all_decomp_u 	(values are from tables table_trXXXX_sr_u and table_trXXXX_lr_u)

' Tables
' Table A 				Comparison to prior TR for E/POP and LFPRs	comp_ep_lfpr 		(a companion table, comp_ru, is useful for reference but not included in the note)
' Table 1				E/Pop projections, Men (by age group) 			proj_me_alt2 		
'																																proj_me_alt2_lim -- same table but shows SELECT years; we use this version for the recurring note
' Table 2				E/Pop projections, Women (by age group) 	proj_fe_alt2 		
'																																proj_fe_alt2_lim -- same table but shows SELECT years; use for the recurring note
' Table 3				E/Pop projections, 16+					 			proj_alle_alt2 		
'																												proj_alle_alt2_lim -- same table but shows SELECT years; use for the recurring note
' Table 4				LFPR projections, Men (by age group) 				proj_m_alt2 			
'																																proj_m_alt2_lim -- same table but shows SELECT years; use for the recurring note
' Table 5				LFPR projections, Women (by age group) 		proj_f_alt2 			
'																																proj_f_alt2_lim -- same table but shows SELECT years; use for the recurring note
' Table 6				LFPR projections, 16+						 			proj_all_alt2 		
'																													proj_all_alt2_lim -- same table but shows SELECT years; use for the recurring note
' Table 7				LFPR decomp SR (adjusted) 				 			table_tr2021_sr_a  		%table_s_a
' Table 8				LFPR decomp LR (adjusted) 							table_tr2021_lr_a  		%table_l_a
' Table 9				LFPR decomp SR (unadjusted) 						table_tr2021_sr_u  		%table_s_u
' Table 10			LFPR decomp LR (unadjusted) 						table_tr2021_lr_u  		%table_l_u
' Table 11 (skip)	LFPR decomp comparison to prior TR, SR (adjusted) 	comp_sr_a 	(unadjusted version also exists comp_sr_u)
' Table 12 (skip)	LFPR decomp comparison to prior TR, LR (adjusted) 	comp_lr_a 	(unadjusted version also exists comp_lr_u)
' unnumbered tables
' There are tables with QUARTERLY projected values that we thought we might provide online or upon request. They are not included in the paper.	
' projq_me 			QUARTERLY equivalent to proj_me_alt2
' projq_fe 				QUARTERLY equivalent to proj_fe_alt2
' projq_alle 			QUARTERLY equivalent to proj_alle_alt2
' projq_m 				QUARTERLY equivalent to proj_m_alt2
' projq_f 					QUARTERLY equivalent to proj_f_alt2
' projq_all 				QUARTERLY equivalent to proj_all_alt2

' Other charts used for internal analysis; there are NOT included in the published note

' cf_ed -- shows coefficients on the edscore variable in LFPR equations for men and women, by age 55 to 74
' cf_ed -- shows coefficients on the MSshare variable in LFPR equations for men and women, by age 55 to 74

' g_edscoref -- shows the difference between the level of edscore in TRcurrent vs in TRprior, for women age 55-74
' g_edscorem -- shows the difference between the level of edscore in TRcurrent vs in TRprior, for men age 55-74
' g_edscoref55 ...g_edscoref74  -- shows the the level of edscore in TRcurrent and in TRprior, for women by SYOA 55-74 (one charts per age)
' g_edscorem55 ...g_edscorem74  -- shows the the level of edscore in TRcurrent and in TRprior, for men by SYOA 55-74 (one charts per age)

' g_mssharef -- shows the difference between the level of MSshare in TRcurrent vs in TRprior, for women age 55-74
' g_mssharem -- shows the difference between the level of Msshare in TRcurrent vs in TRprior, for men age 55-74
' g_mssharef55 ...g_mssharef74 -- shows the the level of MSshare in TRcurrent and in TRprior, for women by SYOA 55-74 (one charts per age)
' g_mssharem55 ...g_mssharem74 -- shows the the level of MSshare in TRcurrent and in TRprior, for men by SYOA 55-74 (one charts per age)



'!!!!!!!!!! IMPORTANT !!!!!!!!!!!
' Before running this program, run the LFPR_decomp program BOTH for current TR and previous TR to create LFPR decomposition for the following demographic groups:
'%user_groups=	"m1617 m1819 m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m70o " + _
'						"f1617 f1819 f2024 f2529 f3034 f3539 f4044 f4549 f5054 f5559 f6064 f6569 f70o " + _
'						"f16o m16o 16o"
' copy and paste the above %user_groups definition directly in LFPR decomp program.
' Note the location of the resulting LFPR_decomp workfiles and enter them in the update section below.

'User should enter the information listed under "****SET these parameters before running the program *****.

'Resulting tables are created within the EViews workfile. They can then be exported ot PDF or Excel, but this step is not currently included in the code.

'This program creates summary tables and comparison tables for ALT2 ONLY of the current and previous TR. In principle, the same can be done for other alts (and some code for this is in here, but commented out), but not yet programmed in the code. -- Polina Vlasenko 12-5-2017



'*****SET these parameters before running the program *****

'!!!! REMEMBER -- Run the LFPR_decomp program to create LFPR decomposition for all demographic groups that are to be included in these tables.!!!!!

!TRyr = 2025 			'Current TR year
!startyr = 1971			' workfile starts in this year; usually remains unchanged
!endyr = 2100			' workfile ends in this year 
!last_hist_yr = 2024	' last year for which we have historical data;  it is used for computing historical ASA LFPRs and for putting the dividing line between 'historical' and 'projected' on time series charts.
							' typically, we have data through Q3 of a give year, for exampel through 2022Q3 -- in this case, put 2022 here
!table_start = 1981	 ' the first year to be displayed in the projection TABLES
!table_end = 2099	 	' the first year to be displayed in the projection TABLES and last year ot show on time series charts; must be ON or BEFORE !endyr

%databank_folder="C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_projections_paper\TR2025\TR25wfiles\"  'folder that contains the databanks (A-bank, D-Bank, AD-bank, and EViews projections files) with final data for the current TR
%databank_pr_folder = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_projections_paper\TR2024\TR24banks\"   'folder that contains databanks for the previous-year TR

%bkdbank = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_projections_paper\TR2025\TR25wfiles\bkdo1.wf1"	' location of BKDO1 bank (need it to compute historical ASA values)
' Note: we use BKDO1 bank (and not the D-bank)  to get population series for computing historical ASA values. 
' Historical population series are not identical between BKDO1 bank and d-bank (although the deviations are small)
' IMPORTANT for our purpose of computing the ASA values -- data for nm70o and nf70o in D-banks starts in 2004, but in BKDO1 bank is starts in 1971

%base = "2020" 	' STRING denoting the base year for the population distribution, i.s. the LFPRs will be age-sex adjusted to the population in this year (annual).

'!!!! Run the lfpr_decomp.prg to create LFPR decomposition for all demographic groups to be included in these tables. 
'This program assumes that there exist workfiles (created by LFPR_decomp program) that contain full LFPR decompostion for the demographic groups to be included in the tables. 
'The location of these workfiles is specified below:
%decomp_path_current="C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_Decomp_Output\TR2025\" 	' filepath to the folder where the LFPR decomposition workfiles for CURRENT TR are stored
%current_a="lfpr_decomp_tr252_AndSYOA_a" 	'name of the workfile for ***LFPR decomp, current TR year, age-sex-Adjusted***, WITHOUT wf1 extension
%current_u="lfpr_decomp_tr252_AndSYOA_u" 	'name of the workfile for ***LFPR decomp, current TR year, Unadjusted***

%decomp_path_prior="C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_Decomp_Output\TR2024\" 		'filepath to the folder where the LFPR decomposition workfiles for PRIOR TR are stored
%prior_a="lfpr_decomp_tr242_AndSYOA_a" 		'name of the workfile that contains ***LFPR decomp, previous TR year, age-sex-Adjusted***
%prior_u="lfpr_decomp_tr242_AndSYOA_u" 		'name of the workfile that contains ***LFPR decomp, previous TR year, Unadjusted***

%output_path="C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_projections_paper\TR2025\"
%output_file = "LFPRs_tables_TR"+@str(!TRyr)  
%csv_location = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_projections_paper\TR2025\" 'location where to save the CSV files with quarterly projected LFPRs (we plan to make these available for download)
%pdf_location = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\LFPR_projections_paper\TR2025\" 'location where to save the CHARTS in special format reqired ot insert into paper

' save options
%sav = "N"  	' enter Y or N (case sensitive) -- governs whether to save the WORKFILE
%csv = "N" 	' enter Y or N (case sensitive) -- governs whether to save the projections tables in CSV format in separate files; if Y, then %csv_location above is REQUIRED
%pdf = "N" 	' enter Y or N (case sensitive) -- governs whether to save the CHARTS to PDF in a specil format required for insertion into the paper; if Y, then %pdf_location above is REQUIRED

'*****END of section that needs updating for each run*****

logmode logmsg

logmsg Running lfpr_tables.prg
logmsg

' Useful constants
!TRyr_pr=!TRyr-1 		' Full TR year, e.g. 2024
!try = !TRyr - 2000 		' Short TR year, e.g. 24
!trp = !TRyr_pr - 2000

'string variables that denote databanks with corresponding filepaths 
' current TR databanks
%abnk = "atr"+@str(!try)+"2" 	' short name of the A-bank
%dbnk = "dtr"+@str(!try)+"2" 	' short name of the D-bank
%abank_alt2=%databank_folder+ %abnk+".wf1" 'filepath and name for A-bank alt2 in workfile format, i.e. atr232.wf1
%dbank_alt2=%databank_folder+ %dbnk+".wf1" 'same for D-bank

'%abank_alt1=%databank_folder+ "atr"+@str(!TRyr-2000)+"1.bnk" 'filepath and name for A-bank alt1, i.e. atr171.bnk
'%dbank_alt1=%databank_folder+ "dtr"+@str(!TRyr-2000)+"1.bnk" 'same for D-bank

'%abank_alt3=%databank_folder+ "atr"+@str(!TRyr-2000)+"3.bnk" 'filepath and name for A-bank alt3, i.e. atr173.bnk
'%dbank_alt3=%databank_folder+ "dtr"+@str(!TRyr-2000)+"3.bnk" 'same for D-bank

%lfpr_proj_55100 = %databank_folder + "lfpr_proj_55100.wf1"  

' previous-year TR databanks
%abnkpr = "atr"+@str(!trp)+"2" 	' short name of the A-bank for prior TR
%dbnkpr = "dtr"+@str(!trp)+"2" 	' short name of the D-bank for prior TR
%abank_alt2pr=%databank_pr_folder+ %abnkpr +".wf1" 'filepath and name for A-bank alt2 in workfile format, i.e. atr232.wf1
%dbank_alt2pr=%databank_pr_folder+ %dbnkpr +".wf1" 'same for D-bank
%lfpr_proj_55100pr = %databank_pr_folder + "lfpr_proj_55100.wf1" 

'%abank_alt1pr=%databank_pr_folder+ "atr"+@str(!TRyr_pr-2000)+"1.bnk" 'filepath and name for A-bank alt1, i.e. atr171.bnk
'%dbank_alt1pr=%databank_pr_folder+ "dtr"+@str(!TRyr_pr-2000)+"1.bnk" 'same for D-bank

'%abank_alt3pr=%databank_pr_folder+ "atr"+@str(!TRyr_pr-2000)+"3.bnk" 'filepath and name for A-bank alt3, i.e. atr173.bnk
'%dbank_alt3pr=%databank_pr_folder+ "dtr"+@str(!TRyr_pr-2000)+"3.bnk" 'same for D-bank


'create the workfile that will contain the data and tables created by this program

'names of the pages within the workfile
'data from the current TR
%page_alt2="TR"+@str(!try)+"2"
'%page_alt1="TR"+@str(!TRyr-2000)+"1"
'%page_alt3="TR"+@str(!TRyr-2000)+"3"
'data from previous-year TR
'%page_alt1pr="TR"+@str(!TRyr_pr-2000)+"1"
%page_alt2pr="TR"+@str(!trp)+"2"
'%page_alt3pr="TR"+@str(!TRyr_pr-2000)+"3"

'list of series to be included in the projections tables
%list_f = "pf1617 pf1819 pf2024 pf2529 pf3034 pf3539 pf4044 pf4549 pf5054 pf5559 pf6064 pf6569 pf70o pf16o pf16o_asa"
%list_fe= "epf1617 epf1819 epf2024 epf2529 epf3034 epf3539 epf4044 epf4549 epf5054 epf5559 epf6064 epf6569 epf70o epf16o epf16o_asa"
%list_m = "pm1617 pm1819 pm2024 pm2529 pm3034 pm3539 pm4044 pm4549 pm5054 pm5559 pm6064 pm6569 pm70o pm16o pm16o_asa"
%list_me= "epm1617 epm1819 epm2024 epm2529 epm3034 epm3539 epm4044 epm4549 epm5054 epm5559 epm6064 epm6569 epm70o epm16o epm16o_asa"
%list_all = "p16o p16o_asa"
%list_alle = "ep16o ep16o_asa"
%list_empl = "e16o ef16o em16o"


wfcreate(wf={%output_file}, page=a) a !startyr !endyr
pagecreate(page=q) q !startyr !endyr
pagecreate(page=tables) a !startyr !endyr

pagecreate(page={%page_alt2}_a) a !startyr !endyr
pagecreate(page={%page_alt2}_q) q !startyr !endyr

pagecreate(page={%page_alt2pr}_a) a !startyr !endyr
pagecreate(page={%page_alt2pr}_q) q !startyr !endyr


' **** Compute Historical ASA values *****
' *** In the tables and charts, we want to be able to show p16o_asa, pm16o_asa, and pf16o_asa all the way back to 1971. 
' *** But in the A-bank the values for p16o_asa, pm16o_asa, and pf16o_asa start in 2001.
' *** To get historical ASA values prior to 2001, we have to compute them here.

'these will be used to construct names of the age-sex groups
%sex="f m"
%age1="1617 1819" 
%age2="2024 2529 3034 3539 4044 4549 5054" 
%age3="5559 6064 6569 70o"
%age4="16o"
%agesy = "55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74"

' Load required data
wfselect {%output_file}
pageselect a
smpl @all

for %page a q 
	pageselect {%page}
	
	wfopen %abank_alt2
	pageselect {%page}
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4} 
	   		copy {%abnk}::{%page}\p{%s}{%a} {%output_file}::{%page}\*
		next
	next
	copy {%abnk}::{%page}\p16o_asa {%output_file}::{%page}\*
	copy {%abnk}::{%page}\pf16o_asa {%output_file}::{%page}\*
	copy {%abnk}::{%page}\pm16o_asa {%output_file}::{%page}\*
	wfclose %abnk

	wfopen %bkdbank
	pageselect {%page}
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4}
			copy bkdo1::{%page}\n{%s}{%a} {%output_file}::{%page}\*
		next
	next
	copy bkdo1::{%page}\n16o {%output_file}::{%page}\*
	wfclose bkdo1
next

' Done loading all data for ASA series

' **** This was a testing step to see if pop data in BKDO1 and D-bank are identical for computing the historical ASA values.
'	dbopen(type=aremos) %dbank_alt2 
'	for %s {%sex}
'		for %a {%age1} {%age2} {%age3} {%age4}
'	  		fetch n{%s}{%a}.{%page} 
'	  		rename n{%s}{%a} n{%s}{%a}_dbank
'		next
'	next
'	fetch n16o.{%page}
'	rename n16o n16o_dbank
'	close @db
'	
'	'check to see if BKDO1 pop date and D-bank pop data are identical
'	smpl !startyr !last_hist_yr
'	for %s {%sex}
'		for %a {%age1} {%age2} {%age3} {%age4}
'	   		series n{%s}{%a}_ck = n{%s}{%a}_bkdo1 - n{%s}{%a}_dbank
'		next
'	next
'	series n16o_ck = n16o_bkdo1 - n16o_dbank
'	smpl @all
'	' The answer is NO -- the pop series are not identical. 
'	' The deviations are small for most, but sizable for 70o
'	' Importantly, data for nm70o and nf70o in D-banks starts in 2004, but in BKDO1 bank it starts in 1971

'compute the ASA series

wfselect {%output_file}
pageselect a  	' annual series
smpl @all


series pf16o_asa_g = 0 'pX16o_asa_g are Generated here; pX16o_asa (no _g) are loaded from a-bank for comparison
series pm16o_asa_g = 0
series p16o_asa_g = 0

for %a {%age1} {%age2} {%age3}
	pf16o_asa_g = pf16o_asa_g + pf{%a}*@elem(nf{%a}, %base)/@elem(nf16o, %base)
	pm16o_asa_g = pm16o_asa_g + pm{%a}*@elem(nm{%a}, %base)/@elem(nm16o, %base)
	p16o_asa_g = p16o_asa_g + pf{%a}*@elem(nf{%a}, %base)/@elem(n16o, %base) + pm{%a}*@elem(nm{%a}, %base)/@elem(n16o, %base) 
next

pageselect q 'quarterly series

%base1=%base+"q1"
%base2=%base+"q2"
%base3=%base+"q3"
%base4=%base+"q4"

series pf16o_asa_g = 0 'pX16o_asa_g are Gerenerated here; pX16o_asa (no _g) are loaded from a-bank for comparison
series pm16o_asa_g = 0
series p16o_asa_g = 0

for %a {%age1} {%age2} {%age3}
	pf16o_asa_g = 	pf16o_asa_g + _
						0.25*pf{%a}*@elem(nf{%a}, %base1)/@elem(nf16o, %base1) + 0.25*pf{%a}*@elem(nf{%a}, %base2)/@elem(nf16o, %base2) + 0.25*pf{%a}*@elem(nf{%a}, %base3)/@elem(nf16o, %base3) + 0.25*pf{%a}*@elem(nf{%a}, %base4)/@elem(nf16o, %base4)
	pm16o_asa_g = pm16o_asa_g + _
						0.25*pm{%a}*@elem(nm{%a}, %base1)/@elem(nm16o, %base1) + 0.25*pm{%a}*@elem(nm{%a}, %base2)/@elem(nm16o, %base2) + 0.25*pm{%a}*@elem(nm{%a}, %base3)/@elem(nm16o, %base3) + 0.25*pm{%a}*@elem(nm{%a}, %base4)/@elem(nm16o, %base4)
	p16o_asa_g = p16o_asa_g + _
						0.25*pf{%a}*@elem(nf{%a}, %base1)/@elem(n16o, %base1) + 0.25*pf{%a}*@elem(nf{%a}, %base2)/@elem(n16o, %base2) + 0.25*pf{%a}*@elem(nf{%a}, %base3)/@elem(n16o, %base3) + 0.25*pf{%a}*@elem(nf{%a}, %base4)/@elem(n16o, %base4) + _
						0.25*pm{%a}*@elem(nm{%a}, %base1)/@elem(n16o, %base1) + 0.25*pm{%a}*@elem(nm{%a}, %base2)/@elem(n16o, %base2) + 0.25*pm{%a}*@elem(nm{%a}, %base3)/@elem(n16o, %base3) + 0.25*pm{%a}*@elem(nm{%a}, %base4)/@elem(n16o, %base4)
next

' all historical ASA series are computed


'******* LFPR Projections Tables *******
'load data for TR alt2, annual
wfselect {%output_file}
pageselect {%page_alt2}_a
smpl @all

wfopen %dbank_alt2
for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
   		copy {%dbnk}::a\n{%s}{%a} {%output_file}::{%page_alt2}_a\*
	next
next
copy {%dbnk}::a\n16o {%output_file}::{%page_alt2}_a\*
close {%dbnk}
	
wfopen %abank_alt2
for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
   		copy {%abnk}::a\p{%s}{%a} {%output_file}::{%page_alt2}_a\* 	' LFPRs
   		copy {%abnk}::a\e{%s}{%a} {%output_file}::{%page_alt2}_a\* 	' Employment
   		copy {%abnk}::a\r{%s}{%a} {%output_file}::{%page_alt2}_a\* 	' RUs
	next
next
for %ser p16o_asa pf16o_asa pm16o_asa p16o e16o rum ruf ru rum_asa ruf_asa ru_asa
	copy {%abnk}::a\{%ser} {%output_file}::{%page_alt2}_a\*
next
close {%abnk}

' done loading data

' Compute e/pop ratios
wfselect {%output_file}
pageselect {%page_alt2}_a
smpl @all

for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  		series ep{%s}{%a} = e{%s}{%a}/n{%s}{%a}
	next
next
series ep16o = e16o/n16o

' Create ASA e/pop ratios
pageselect {%page_alt2}_a

series epf16o_asa = 0 
series epm16o_asa = 0
series ep16o_asa = 0

for %a {%age1} {%age2} 5559 6064 6569 7074 75o
	epf16o_asa = epf16o_asa + epf{%a}*@elem(nf{%a}, %base)/@elem(nf16o, %base)
	epm16o_asa = epm16o_asa + epm{%a}*@elem(nm{%a}, %base)/@elem(nm16o, %base)
	ep16o_asa = ep16o_asa + epf{%a}*@elem(nf{%a}, %base)/@elem(n16o, %base) + epm{%a}*@elem(nm{%a}, %base)/@elem(n16o, %base) 
next

' Create RU_ASA series (all, M, F) for the period 1981 onward
' A-bank has rum_asa, ruf_asa and ru_asa for years 2001 onward
' Here I compute these for years 1981 onwardx
' use method similar to the way I did it for e/pop above. 
' REMEMBER that later, when I load ru_asa's from databank, they will overwrite these, so name them acordingly.
wfselect {%output_file}
pageselect {%page_alt2}_a
smpl @all

series rum_asa_g = 0 'ruX_asa_g are Gerenerated here; ruX_asa (no _g) are loaded from a-bank; I will compare and conbine them later
series ruf_asa_g = 0
series ru_asa_g = 0

' make Labor Force weights in the base year
for %a {%age1} {%age2} {%age3}
	for %s m f 
		!lw{%s}{%a} = (@elem(p{%s}{%a}, %base)*@elem(n{%s}{%a}, %base)) /(@elem(p{%s}16o, %base)*@elem(n{%s}16o, %base))
	next
next
!lwm16o = (@elem(pm16o, %base)*@elem(nm16o, %base)) /(@elem(p16o, %base)*@elem(n16o, %base))
!lwf16o = (@elem(pf16o, %base)*@elem(nf16o, %base)) /(@elem(p16o, %base)*@elem(n16o, %base))

' Now compte the RU ASA values
for %a {%age1} {%age2} {%age3}
	rum_asa_g = rum_asa_g + rm{%a} * !lwm{%a}
	ruf_asa_g = ruf_asa_g + rf{%a} * !lwf{%a}
next
ru_asa_g = rum_asa_g * !lwm16o + ruf_asa_g * !lwf16o

' ASA values for RUs are computed;
' for years 1981-200 -- use ruX_asa_g
' for years 2001 onwards, use ruX_asa 


'get historical ASA lfprs for years prior to 2001
copy a\*_g {%page_alt2}_a\  	'this copies 3 series -- pf16o_asa_g, pm16o_asa_g, and p16o_asa_g -- from page a to page {%page_alt2}_a (like TR212_a)

wfselect {%output_file}
pageselect {%page_alt2}_a

'assign value from *_asa_g to already existing *_asa for 1981-2000 period.
smpl !table_start 2000
' LFPRs
pf16o_asa = pf16o_asa_g
pm16o_asa = pm16o_asa_g
p16o_asa = p16o_asa_g
'RUs
rum_asa = rum_asa_g
ruf_asa = ruf_asa_g
ru_asa = ru_asa_g

smpl @all
'done loading/updating historical ASA values

logmsg Done loading data
logmsg


' **** Re-scale LFPRs and E/POP ratios to display as 63.31 percent instead of 0.6331
logmsg Re-scaling annual values...

wfselect {%output_file}
pageselect {%page_alt2}_a
smpl @all
	
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  			ep{%s}{%a} = ep{%s}{%a} * 100		' e/pop
 	 		p{%s}{%a} = p{%s}{%a} * 100			' LFPRs
		next
	next
	ep16o = ep16o * 100
	p16o = p16o * 100

	for %s pf16o pm16o p16o
		{%s}_asa = {%s}_asa * 100		' LFPRs ASA
		e{%s}_asa = e{%s}_asa * 100	' e/pop ASA
	next
 
 logmsg ... done.
 logmsg

' **** Create  the tables ****
wfselect {%output_file}
pageselect {%page_alt2}_a
smpl !table_start !TRyr+74 'period to be displyed in projections tables

logmsg Creating projections tables -- Annual
logmsg

'create 3 tables that show projected LFPRs -- all16o, all female, all male
group females {%list_f}
freeze(proj_f_alt2) females.sheet

group males {%list_m}
freeze(proj_m_alt2) males.sheet

group all16o {%list_all}
freeze(proj_all_alt2) all16o.sheet

' create tables to show projected E/POP ratios -- all16o, all female, all male
group epop_f {%list_fe}
freeze(proj_fe_alt2) epop_f.sheet

group epop_m {%list_me}
freeze(proj_me_alt2) epop_m.sheet

group epop_all {%list_alle}
freeze(proj_alle_alt2) epop_all.sheet

' ** Create condenced tables for the recurring note **
' define the special sample, designed to include only the years we want
!fyr = !last_hist_yr - 9		' 2013 for Tr23
!sryr = !last_hist_yr + 10	' 2032 for Tr23
!last_dgt = @val(@right(@str(!sryr),1))

if !last_dgt < 5 then
	!sryr = !sryr + 5 - !last_dgt
	else if !last_dgt > 5 then
			!sryr = !sryr + 10 - !last_dgt
			endif
endif

string smpl_list = @str(!fyr) + " " + @str(!sryr) + " "
!t = !sryr + 5
while !t < !table_end
	smpl_list = smpl_list + @str(!t) + " " + @str(!t) + " "
	!t = !t +5
wend

smpl_list = smpl_list + @str(!table_end) + " " + @str(!table_end)

'sample hist5yrs {smpl_list}
smpl {smpl_list}
!limsample = @obssmpl 	' the number !limsample tells me how many observations are in this sample; need it for tables later
freeze(proj_f_alt2_lim) females.sheet 	' creates LIMited tables that show only selected years for LFPRs
freeze(proj_m_alt2_lim) males.sheet
freeze(proj_all_alt2_lim) all16o.sheet

freeze(proj_fe_alt2_lim) epop_f.sheet 			' same for E/POP
freeze(proj_me_alt2_lim) epop_m.sheet
freeze(proj_alle_alt2_lim) epop_all.sheet

'copy tables to the "tables" page
smpl @all
copy {%page_alt2_a}\proj_* tables\

wfselect {%output_file}
pageselect tables
smpl @all

'format the projections tables; these are FULL tables that include all years
proj_f_alt2.title Table 5. Civilian Labor Force Participation Rates, Women (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
proj_m_alt2.title Table 4. Civilian Labor Force Participation Rates, Men (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
proj_all_alt2.title Table 6. Civilian Labor Force Participation Rates, historical and projected ({!TRyr} Trustees Report, intermediate assumptions)

proj_fe_alt2.title Table 2. Ratio of Employment to Civilian Noninstitutional Population, Women (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
proj_me_alt2.title Table 1. Ratio of Employment to Civilian Noninstitutional Population, Men (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
proj_alle_alt2.title Table 3. Ratio of Employment to Civilian Noninstitutional Population, historical and projected ({!TRyr} Trustees Report, intermediate assumptions)

!proj_row=!TRyr-!table_start+1+5 'row of the tables where the projected data starts
!last_row = !TRyr-!table_start+76+6
!fn_row = !last_row +1 'row for the footnote


for %tab proj_f_alt2 proj_m_alt2 proj_fe_alt2 proj_me_alt2
	{%tab}.insertrow(1) 3
	{%tab}.setlines(5) -d		' remove double line in the last row of the heading
	{%tab}.insertrow(!proj_row) 1
	{%tab}.setmerge(B1:P1)
	{%tab}.setmerge(B2:P2)
	{%tab}(2,2)=@str(!TRyr)+" Trustees Report (intermediate assumptions, percent)"
	{%tab}(3,2)="16-17"
	{%tab}(3,3)="18-19"
	{%tab}(3,4)="20-24"
	{%tab}(3,5)="25-29"
	{%tab}(3,6)="30-34"
	{%tab}(3,7)="35-39"
	{%tab}(3,8)="40-44"
	{%tab}(3,9)="45-49"
	{%tab}(3,10)="50-54"
	{%tab}(3,11)="55-59"
	{%tab}(3,12)="60-64"
	{%tab}(3,13)="65-69"
	{%tab}(3,14)="70+"
	{%tab}(3,15)="16+"
	{%tab}(3,16)="16+ Age-Adj."
	{%tab}(5,2)="Historical"
	{%tab}(!proj_row,2)="Projected"
	{%tab}(!fn_row,1)="Note: For compactness, the table displays annual values. Annual values are averages of the quarterly values. Quarterly values are available on request."
	
	{%tab}.setformat(@all) f.2
	{%tab}.setjust(@all) center
	{%tab}.setfont(B2) +b
	{%tab}.setwidth(2:15) 8
	{%tab}.setlines(A4) +b
	{%tab}.setlines(B1:P2) +a
	{%tab}.setjust(B3:P3) center
	{%tab}.setlines(A1:A{!last_row}) +o
	{%tab}.setlines(A1:P{!last_row}) +o
	{%tab}.setlines(O3:O{!last_row}) +o
	
	!cl=2
	for %c B C D E F G H I J K L M N O P
		{%tab}.setlines({%c}3:{%c}4) +o
		{%tab}(4,!cl) = " "
		!cl=!cl+1
	next
	{%tab}(4,16)="(" + %base + " pop.)"
next

proj_f_alt2(1,2)="Civilian Labor Force Participation Rates -- Women"
proj_m_alt2(1,2)="Civilian Labor Force Participation Rates -- Men"
proj_f_alt2.setfont(B1) +b
proj_m_alt2.setfont(B1) +b

proj_fe_alt2(1,2)="Ratio of Employment to Civilian Noninstitutional Population -- Women"
proj_me_alt2(1,2)="Ratio of Employment to Civilian Noninstitutional Population -- Men"
proj_fe_alt2.setfont(B1) +b
proj_me_alt2.setfont(B1) +b

'tables for all16o
for %tab proj_all_alt2 proj_alle_alt2
	{%tab}.insertrow(1) 3
	{%tab}.setlines(5) -d		' remove double line in the last row of the heading
	{%tab}.insertrow(!proj_row) 1
	{%tab}(5,2)="   Historical"
	{%tab}(!proj_row,2)="   Projected"
	{%tab}.setmerge(A1:C1)
	{%tab}.setmerge(A2:C2)

	{%tab}(2,1)=@str(!TRyr)+" Trustees Report "
	{%tab}(3,2)="16+"
	{%tab}(4,2)=" "
	{%tab}(3,3)="16+ Age-Sex-Adj."
	{%tab}(4,3)="(" + %base + " pop.)"

	{%tab}(!fn_row,1)="Note: For compactness, the table displays annual values; quarterly values are available on request."

	{%tab}.setformat(@all) f.2
	{%tab}.setjust(@all) center
	{%tab}.setjust(B5) left
	{%tab}.setjust(B{!proj_row}) left
	{%tab}.setwidth(2:3) 23
		' insert one more row on top
		{%tab}.insertrow(3) 1
		{%tab}.setmerge(A3:C3)
		{%tab}(3,1) = " (intermediate assumptions, percent)"
	
	{%tab}.setlines(A1:C5) +a
	{%tab}.setlines(A4:A5) -i
	{%tab}.setlines(B4:B5) -i
	{%tab}.setlines(C4:C5) -i
	{%tab}.setlines(A2:C3) -i
	{%tab}.setlines(A1:C{!last_row}) +o
	{%tab}.setlines(B3:B{!last_row}) +o

	
	{%tab}.setfont(A1) +b
	{%tab}.setfont(A2) +b
	{%tab}.setfont(A3) +b
next

proj_all_alt2(1,1)="Civilian Labor Force Participation Rates"
proj_alle_alt2(1,1)="Ratio of Employment to Civilian Noninstitutional Population"


'format the projections tables; these tables for SELECTED years
proj_f_alt2_lim.title Table 5. Civilian Labor Force Participation Rates, Women (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions, select years)
proj_m_alt2_lim.title Table 4. Civilian Labor Force Participation Rates, Men (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions, select years)
proj_all_alt2_lim.title Table 6. Civilian Labor Force Participation Rates, historical and projected ({!TRyr} Trustees Report, intermediate assumptions, select years)

proj_fe_alt2_lim.title Table 2. Ratio of Employment to Civilian Noninstitutional Population, Women (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions, select years)
proj_me_alt2_lim.title Table 1. Ratio of Employment to Civilian Noninstitutional Population, Men (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions, select years)
proj_alle_alt2_lim.title Table 3. Ratio of Employment to Civilian Noninstitutional Population, historical and projected ({!TRyr} Trustees Report, intermediate assumptions, select years)

!proj_row = 10 + 1 + 5 'row of the tables where the projected data starts; constant b/c we always show only 10 years of historical data
!last_row = !limsample+6
!fn_row = !last_row +1 'row for the footnote

for %tab proj_f_alt2_lim proj_m_alt2_lim proj_fe_alt2_lim proj_me_alt2_lim
	{%tab}.insertrow(1) 3
	{%tab}.setlines(5) -d		' remove double line in the last row of the heading
	{%tab}.insertrow(!proj_row) 1
	{%tab}.setmerge(B1:P1)
	{%tab}.setmerge(B2:P2)
	{%tab}(2,2)=@str(!TRyr)+" Trustees Report (intermediate assumptions, percent)"
	{%tab}(3,2)="16-17"
	{%tab}(3,3)="18-19"
	{%tab}(3,4)="20-24"
	{%tab}(3,5)="25-29"
	{%tab}(3,6)="30-34"
	{%tab}(3,7)="35-39"
	{%tab}(3,8)="40-44"
	{%tab}(3,9)="45-49"
	{%tab}(3,10)="50-54"
	{%tab}(3,11)="55-59"
	{%tab}(3,12)="60-64"
	{%tab}(3,13)="65-69"
	{%tab}(3,14)="70+"
	{%tab}(3,15)="16+"
	{%tab}(3,16)="16+ Age-Adj."
	{%tab}(5,2)="Historical"
	{%tab}(!proj_row,2)="Projected"
	{%tab}(!fn_row,1)="Note: For compactness, the table displays select years for the projection period. Data for all years are available on request."
	
	{%tab}.setformat(@all) f.2
	{%tab}.setjust(@all) center
	{%tab}.setfont(B2) +b
	{%tab}.setwidth(2:15) 8
	{%tab}.setlines(A4) +b
	{%tab}.setlines(B1:P2) +a
	{%tab}.setjust(B3:P3) center
	{%tab}.setlines(A1:A{!last_row}) +o
	{%tab}.setlines(A1:P{!last_row}) +o
	{%tab}.setlines(O3:O{!last_row}) +o
	
	!cl=2
	for %c B C D E F G H I J K L M N O P
		{%tab}.setlines({%c}3:{%c}4) +o
		{%tab}(4,!cl) = " "
		!cl=!cl+1
	next
	{%tab}(4,16)="(" + %base + " pop.)"
next
proj_f_alt2_lim(1,2)="Civilian Labor Force Participation Rates -- Women"
proj_m_alt2_lim(1,2)="Civilian Labor Force Participation Rates -- Men"
proj_f_alt2_lim.setfont(B1) +b
proj_m_alt2_lim.setfont(B1) +b

proj_fe_alt2_lim(1,2)="Ratio of Employment to Civilian Noninstitutional Population -- Women"
proj_me_alt2_lim(1,2)="Ratio of Employment to Civilian Noninstitutional Population -- Men"
proj_fe_alt2_lim.setfont(B1) +b
proj_me_alt2_lim.setfont(B1) +b

!last_row = !last_row+1
for %tab proj_all_alt2_lim proj_alle_alt2_lim
	{%tab}.insertrow(1) 3
	{%tab}.setlines(5) -d		' remove double line in the last row of the heading
	{%tab}.insertrow(!proj_row) 1
	{%tab}(5,2)="   Historical"
	{%tab}(!proj_row,2)="   Projected"
	{%tab}.setmerge(A1:C1)
	{%tab}.setmerge(A2:C2)

	{%tab}(2,1)=@str(!TRyr)+" Trustees Report "
	{%tab}(3,2)="16+"
	{%tab}(4,2)=" "
	{%tab}(3,3)="16+ Age-Sex-Adj."
	{%tab}(4,3)="(" + %base + " pop.)"

	{%tab}(!fn_row,1)="Note: For compactness, the table displays select years for the projection period. Data for all years are available on request."

	{%tab}.setformat(@all) f.2
	{%tab}.setjust(@all) center
	{%tab}.setjust(B5) left
	{%tab}.setjust(B{!proj_row}) left
	{%tab}.setwidth(2:3) 23
		' insert one more row on top
		{%tab}.insertrow(3) 1
		{%tab}.setmerge(A3:C3)
		{%tab}(3,1) = " (intermediate assumptions, percent)"
	
	{%tab}.setlines(A1:C5) +a
	{%tab}.setlines(A4:A5) -i
	{%tab}.setlines(B4:B5) -i
	{%tab}.setlines(C4:C5) -i
	{%tab}.setlines(A2:C3) -i
	{%tab}.setlines(A1:C{!last_row}) +o
	{%tab}.setlines(B3:B{!last_row}) +o

	
	{%tab}.setfont(A1) +b
	{%tab}.setfont(A2) +b
	{%tab}.setfont(A3) +b
next
proj_all_alt2_lim(1,1)="Civilian Labor Force Participation Rates"
proj_alle_alt2_lim(1,1)="Ratio of Employment to Civilian Noninstitutional Population"

logmsg Projections tables done
logmsg

'  *** Comaprison to prior TR ***
'  NOTE: for TR22 and earlier, this comparison must be done using databanks -- see earlier version of this program to do it. 
' 			The comparison below uses WORKFILES only.
'	'*** Load data for prior-year TR in a separate page of the workfile

logmsg Creating comparison to previous-year TR
logmsg Loading data from previous-year TR ...

	wfselect {%output_file}
	pageselect {%page_alt2pr}_a  
	smpl @all
	wfopen %abank_alt2pr
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  			copy {%abnkpr}::a\p{%s}{%a} {%output_file}::{%page_alt2pr}_a\* 	' LFPRs
  			copy {%abnkpr}::a\l{%s}{%a} {%output_file}::{%page_alt2pr}_a\* 	' Labor force (level)
   			copy {%abnkpr}::a\e{%s}{%a} {%output_file}::{%page_alt2pr}_a\* 	' Employment
   			copy {%abnkpr}::a\r{%s}{%a} {%output_file}::{%page_alt2pr}_a\* 	' RUs
  		next
  		copy {%abnkpr}::a\ru{%s} {%output_file}::{%page_alt2pr}_a\*		' rum, ruf
  		copy {%abnkpr}::a\p{%s}16o {%output_file}::{%page_alt2pr}_a\*	' pm16o, pf16o
  		copy {%abnkpr}::a\l{%s}16o {%output_file}::{%page_alt2pr}_a\*	' lm16o, lf16o
  		
	next
'  do NOT copy ASA avlues b/c we will compute them later
'	for %ser p16o_asa pf16o_asa pm16o_asa p16o e16o rum ruf ru rum_asa ruf_asa ru_asa
'		copy {%abnkpr}::a\{%ser} {%output_file}::{%page_alt2pr}_a\*
'	next
	for %ser p16o e16o l16o ru 
		copy {%abnkpr}::a\{%ser} {%output_file}::{%page_alt2pr}_a\*
	next

	close {%abnkpr}
	
	wfopen %dbank_alt2pr
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  			copy {%dbnkpr}::a\n{%s}{%a} {%output_file}::{%page_alt2pr}_a\* 	' pop
  		next
	next
	copy {%dbnkpr}::a\n16o {%output_file}::{%page_alt2pr}_a\*
	close {%dbnkpr}
	
logmsg Done loading data for previous-year TR
logmsg

' done loading data

' Compute e/pop ratios
wfselect {%output_file}
pageselect {%page_alt2pr}_a  
smpl @all

for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  		series ep{%s}{%a} = e{%s}{%a}/n{%s}{%a}
	next
next
series ep16o = e16o/n16o

' Create ASA values for LFPRs, RUs, and e/pop
' e/pop ratios  -- EXAPND this to create ASA values for e/pop, RU, and LFPRs for a given %base year !!!!!
pageselect {%page_alt2pr}_a
smpl @all

' create Base Year values (<name>_by)
' Base Year is set by parameter %base
for %s f m
  series n{%s}16o_by = @elem(n{%s}16o,%base)
  series l{%s}16o_by = @elem(l{%s}16o,%base)
  
  for %a {%age1} {%age2} 5559 6064 6569 7074 75o
    series n{%s}{%a}_by = @elem(n{%s}{%a},%base)
    series l{%s}{%a}_by = @elem(l{%s}{%a},%base)
  next
  
next
series n16o_by = nf16o_by + nm16o_by
series l16o_by = lf16o_by + lm16o_by

' compute ASA values
series p16o_asa = 0	' LFPR
series ep16o_asa = 0	' E/POP
series ru_asa = 0		' RU

for %s f m
  series p{%s}16o_aa = 0
  series ep{%s}16o_aa = 0
  series r{%s}16o_aa = 0

  for %a {%age1} {%age2} 5559 6064 6569 7074 75o
    p{%s}16o_aa = p{%s}16o_aa + p{%s}{%a} * n{%s}{%a}_by
    ep{%s}16o_aa = ep{%s}16o_aa + ep{%s}{%a} * n{%s}{%a}_by
    r{%s}16o_aa = r{%s}16o_aa + r{%s}{%a} * l{%s}{%a}_by
  next
  
  p{%s}16o_aa = p{%s}16o_aa / n{%s}16o_by
  ep{%s}16o_aa = ep{%s}16o_aa / n{%s}16o_by
  r{%s}16o_aa = r{%s}16o_aa / l{%s}16o_by
next

series p16o_asa = (pf16o_aa * nf16o_by + pm16o_aa * nm16o_by) / n16o_by
series ep16o_asa = (epf16o_aa * nf16o_by + epm16o_aa * nm16o_by) / n16o_by
series ru_asa = (rf16o_aa * lf16o_by + rm16o_aa * lm16o_by) / l16o_by

for %s f m
	series p{%s}16o_asa = p{%s}16o_aa
	series ep{%s}16o_asa = ep{%s}16o_aa
	series ru{%s}_asa = r{%s}16o_aa
next

' delete *_aa

'series epf16o_asa = 0 
'series epm16o_asa = 0
'series ep16o_asa = 0
'
'for %a {%age1} {%age2} 5559 6064 6569 7074 75o
'	epf16o_asa = epf16o_asa + epf{%a}*@elem(nf{%a}, %base)/@elem(nf16o, %base)
'	epm16o_asa = epm16o_asa + epm{%a}*@elem(nm{%a}, %base)/@elem(nm16o, %base)
'	ep16o_asa = ep16o_asa + epf{%a}*@elem(nf{%a}, %base)/@elem(n16o, %base) + epm{%a}*@elem(nm{%a}, %base)/@elem(n16o, %base) 
'next
	
logmsg Done computing ASA values for previous-year TR
logmsg

' **** Re-scale LFPRs and E/POP ratios to display as 63.31 percent instead of 0.6331
logmsg Re-scaling annual values (prior TR)...

	wfselect {%output_file}
	pageselect {%page_alt2pr}_a
	smpl @all
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  			ep{%s}{%a} = ep{%s}{%a} * 100		' e/pop
 	 		p{%s}{%a} = p{%s}{%a} * 100			' LFPRs
		next
	next
	ep16o = ep16o * 100
	p16o = p16o * 100

	for %s pf16o pm16o p16o
		{%s}_asa = {%s}_asa * 100		' LFPRs ASA
		e{%s}_asa = e{%s}_asa * 100	' e/pop ASA
	next
 
 logmsg ... done.
 logmsg

'create 3 tables that show projected LFPRs -- all16o, all female, all male

wfselect {%output_file}
pageselect {%page_alt2pr}_a
smpl !table_start !TRyr+74 '-- period for projection tables
	
logmsg Create simple tables of time series (prior TR)
logmsg

group females {%list_f}
freeze(proj_f_alt2pr) females.sheet

group males {%list_m} 
freeze(proj_m_alt2pr) males.sheet

group all16o {%list_all} 
freeze(proj_all_alt2pr) all16o.sheet

' create tables to show projected E/POP ratios -- all 16o, all female, all male
group epop_f {%list_fe}
freeze(proj_fe_alt2pr) epop_f.sheet

group epop_m {%list_me}
freeze(proj_me_alt2pr) epop_m.sheet

group epop_all {%list_alle}
freeze(proj_alle_alt2pr) epop_all.sheet

	'compute the difference between TR_current projections and TR_previous projections
	'copy all series into the 'tables' page
	wfselect {%output_file}
	pageselect tables
	smpl @all
	
	for %ser {%list_f} {%list_m} {%list_all} {%list_empl} {%list_fe} {%list_me} {%list_alle} ru_asa ruf_asa rum_asa
		copy {%page_alt2}_a\{%ser} tables\  'current TR values
		copy {%page_alt2pr}_a\{%ser} tables\{%ser}_pr 'prior-year TR values
		genr {%ser}_ch = {%ser} - {%ser}_pr 'compute the difference between current TR and prior TR values
	next
	
	'create tables for the "change" series
	logmsg Compute the change between current and prior TR and make tables
	logmsg

	wfselect {%output_file}
	pageselect tables
	smpl 2010 !TRyr+74 'starting in 2010 since values prior to 2010 are definitely zero 

	group females_chg pf1617_ch pf1819_ch pf2024_ch pf2529_ch pf3034_ch pf3539_ch pf4044_ch pf4549_ch pf5054_ch pf5559_ch pf6064_ch pf6569_ch pf70o_ch pf16o_ch pf16o_asa_ch
	freeze(chg_f_alt2) females_chg.sheet
	group males_chg pm1617_ch pm1819_ch pm2024_ch pm2529_ch pm3034_ch pm3539_ch pm4044_ch pm4549_ch pm5054_ch pm5559_ch pm6064_ch pm6569_ch pm70o_ch pm16o_ch pm16o_asa_ch
	freeze(chg_m_alt2) males_chg.sheet
	group all16o_chg p16o_ch p16o_asa_ch
	freeze(chg_all_alt2) all16o_chg.sheet
	
	group femalese_chg epf1617_ch epf1819_ch epf2024_ch epf2529_ch epf3034_ch epf3539_ch epf4044_ch epf4549_ch epf5054_ch epf5559_ch epf6064_ch epf6569_ch epf70o_ch epf16o_ch epf16o_asa_ch
	freeze(chg_fe_alt2) femalese_chg.sheet
	group malese_chg epm1617_ch epm1819_ch epm2024_ch epm2529_ch epm3034_ch epm3539_ch epm4044_ch epm4549_ch epm5054_ch epm5559_ch epm6064_ch epm6569_ch epm70o_ch epm16o_ch epm16o_asa_ch
	freeze(chg_me_alt2) malese_chg.sheet
	group all16oe_chg ep16o_ch ep16o_asa_ch
	freeze(chg_alle_alt2) all16oe_chg.sheet
	
	' create Table A -- comparison between of E/Pop and LFPRs between current TR and prior TR
	' also create Table B -- comparison of RUs between current TR amd prior TR; we do not publich this one but it is useful for writing the text.
	
	'declare the tables of appropriate size
	table(17,7) comp_ep_lfpr 
	table(17,4) comp_ru
	!SRyr=!TRyr+9 	'last year of the short-range period, i.e. 2026 for TR2017
	!LRyr=!TRyr+74 	'last year of the long-range period, i.e. 2091 for TR2017
	
	' labels for columns
	comp_ep_lfpr(3,2) = @str(!last_hist_yr)
	comp_ep_lfpr(3,5) = @str(!last_hist_yr)
	
	comp_ep_lfpr(3,3) = @str(!SRyr)
	comp_ep_lfpr(3,6) = @str(!SRyr)

	comp_ep_lfpr(3,4) = @str(!LRyr)
	comp_ep_lfpr(3,7) = @str(!LRyr)

	comp_ru(3,2) = @str(!last_hist_yr)
	comp_ru(3,3) = @str(!SRyr)
	comp_ru(3,4) = @str(!LRyr)
	
	comp_ep_lfpr(1,2) = "Projected Ratio of Employment to Population"
	%txt = "(age-sex-adjusted, " + %base + " pop.)"
	comp_ep_lfpr(2,2) = %txt
	comp_ep_lfpr(1,5) = "Projected Labor Force Participation Rate"
	comp_ep_lfpr(2,5) = %txt
	
	comp_ru(1,2) = "Projected Unemployment Rate"
	%txt = "(age-sex-adjusted, " + %base + " labor force)"
	comp_ru(2,2) = %txt
	
	for %tab comp_ep_lfpr comp_ru		
		' labels in the first column
		{%tab}(1,1) = "Age-Sex"
		{%tab}(2,1) = "Group"
		
		{%tab}(4,1) = "16+"
		{%tab}(9,1) = "M16+"
		{%tab}(14,1) = "F16+"
		
		{%tab}(5,1) = "TR" + @str(!TRyr)
		{%tab}(6,1) = "TR" + @str(!TRyr_pr)
		{%tab}(7,1) = "Difference"
		
		{%tab}(10,1) = "TR" + @str(!TRyr)
		{%tab}(11,1) = "TR" + @str(!TRyr_pr)
		{%tab}(12,1) = "Difference"

		{%tab}(15,1) = "TR" + @str(!TRyr)
		{%tab}(16,1) = "TR" + @str(!TRyr_pr)
		{%tab}(17,1) = "Difference"
	next

	' values
	' 16+
	comp_ep_lfpr(5,2) = @elem(ep16o_asa, @str(!last_hist_yr))
	comp_ep_lfpr(6,2) = @elem(ep16o_asa_pr, @str(!last_hist_yr))
	comp_ep_lfpr(7,2) = @val(comp_ep_lfpr(5,2)) - @val(comp_ep_lfpr(6,2))
	
	comp_ep_lfpr(5,3) = @elem(ep16o_asa, @str(!SRyr))
	comp_ep_lfpr(6,3) = @elem(ep16o_asa_pr, @str(!SRyr))
	comp_ep_lfpr(7,3) = @val(comp_ep_lfpr(5,3)) - @val(comp_ep_lfpr(6,3))
	
	comp_ep_lfpr(5,4) = @elem(ep16o_asa, @str(!LRyr))
	comp_ep_lfpr(6,4) = @elem(ep16o_asa_pr, @str(!LRyr))
	comp_ep_lfpr(7,4) = @val(comp_ep_lfpr(5,4)) - @val(comp_ep_lfpr(6,4))

	comp_ep_lfpr(5,5) = @elem(p16o_asa, @str(!last_hist_yr))
	comp_ep_lfpr(6,5) = @elem(p16o_asa_pr, @str(!last_hist_yr))
	comp_ep_lfpr(7,5) = @val(comp_ep_lfpr(5,5)) - @val(comp_ep_lfpr(6,5))

	comp_ep_lfpr(5,6) = @elem(p16o_asa, @str(!SRyr))
	comp_ep_lfpr(6,6) = @elem(p16o_asa_pr, @str(!SRyr))
	comp_ep_lfpr(7,6) = @val(comp_ep_lfpr(5,6)) - @val(comp_ep_lfpr(6,6))

	comp_ep_lfpr(5,7) = @elem(p16o_asa, @str(!LRyr))
	comp_ep_lfpr(6,7) = @elem(p16o_asa_pr, @str(!LRyr))
	comp_ep_lfpr(7,7) = @val(comp_ep_lfpr(5,7)) - @val(comp_ep_lfpr(6,7))

	' M16+
	comp_ep_lfpr(10,2) = @elem(epm16o_asa, @str(!last_hist_yr))
	comp_ep_lfpr(11,2) = @elem(epm16o_asa_pr, @str(!last_hist_yr))
	comp_ep_lfpr(12,2) = @val(comp_ep_lfpr(10,2)) - @val(comp_ep_lfpr(11,2))
	
	comp_ep_lfpr(10,3) = @elem(epm16o_asa, @str(!SRyr))
	comp_ep_lfpr(11,3) = @elem(epm16o_asa_pr, @str(!SRyr))
	comp_ep_lfpr(12,3) = @val(comp_ep_lfpr(10,3)) - @val(comp_ep_lfpr(11,3))
	
	comp_ep_lfpr(10,4) = @elem(epm16o_asa, @str(!LRyr))
	comp_ep_lfpr(11,4) = @elem(epm16o_asa_pr, @str(!LRyr))
	comp_ep_lfpr(12,4) = @val(comp_ep_lfpr(10,4)) - @val(comp_ep_lfpr(11,4))

	comp_ep_lfpr(10,5) = @elem(pm16o_asa, @str(!last_hist_yr))
	comp_ep_lfpr(11,5) = @elem(pm16o_asa_pr, @str(!last_hist_yr))
	comp_ep_lfpr(12,5) = @val(comp_ep_lfpr(10,5)) - @val(comp_ep_lfpr(11,5))

	comp_ep_lfpr(10,6) = @elem(pm16o_asa, @str(!SRyr))
	comp_ep_lfpr(11,6) = @elem(pm16o_asa_pr, @str(!SRyr))
	comp_ep_lfpr(12,6) = @val(comp_ep_lfpr(10,6)) - @val(comp_ep_lfpr(11,6))

	comp_ep_lfpr(10,7) = @elem(pm16o_asa, @str(!LRyr))
	comp_ep_lfpr(11,7) = @elem(pm16o_asa_pr, @str(!LRyr))
	comp_ep_lfpr(12,7) = @val(comp_ep_lfpr(10,7)) - @val(comp_ep_lfpr(11,7))

	' F16+
	comp_ep_lfpr(15,2) = @elem(epf16o_asa, @str(!last_hist_yr))
	comp_ep_lfpr(16,2) = @elem(epf16o_asa_pr, @str(!last_hist_yr))
	comp_ep_lfpr(17,2) = @val(comp_ep_lfpr(15,2)) - @val(comp_ep_lfpr(16,2))
	
	comp_ep_lfpr(15,3) = @elem(epf16o_asa, @str(!SRyr))
	comp_ep_lfpr(16,3) = @elem(epf16o_asa_pr, @str(!SRyr))
	comp_ep_lfpr(17,3) = @val(comp_ep_lfpr(15,3)) - @val(comp_ep_lfpr(16,3))
	
	comp_ep_lfpr(15,4) = @elem(epf16o_asa, @str(!LRyr))
	comp_ep_lfpr(16,4) = @elem(epf16o_asa_pr, @str(!LRyr))
	comp_ep_lfpr(17,4) = @val(comp_ep_lfpr(15,4)) - @val(comp_ep_lfpr(16,4))

	comp_ep_lfpr(15,5) = @elem(pf16o_asa, @str(!last_hist_yr))
	comp_ep_lfpr(16,5) = @elem(pf16o_asa_pr, @str(!last_hist_yr))
	comp_ep_lfpr(17,5) = @val(comp_ep_lfpr(15,5)) - @val(comp_ep_lfpr(16,5))

	comp_ep_lfpr(15,6) = @elem(pf16o_asa, @str(!SRyr))
	comp_ep_lfpr(16,6) = @elem(pf16o_asa_pr, @str(!SRyr))
	comp_ep_lfpr(17,6) = @val(comp_ep_lfpr(15,6)) - @val(comp_ep_lfpr(16,6))

	comp_ep_lfpr(15,7) = @elem(pf16o_asa, @str(!LRyr))
	comp_ep_lfpr(16,7) = @elem(pf16o_asa_pr, @str(!LRyr))
	comp_ep_lfpr(17,7) = @val(comp_ep_lfpr(15,7)) - @val(comp_ep_lfpr(16,7))
	
	' RUs
	comp_ru(5,2) = @elem(ru_asa, @str(!last_hist_yr))
	comp_ru(6,2) = @elem(ru_asa_pr, @str(!last_hist_yr))
	comp_ru(7,2) = @val(comp_ru(5,2)) - @val(comp_ru(6,2))
	
	comp_ru(5,3) = @elem(ru_asa, @str(!SRyr))
	comp_ru(6,3) = @elem(ru_asa_pr, @str(!SRyr))
	comp_ru(7,3) = @val(comp_ru(5,3)) - @val(comp_ru(6,3))
	
	comp_ru(5,4) = @elem(ru_asa, @str(!LRyr))
	comp_ru(6,4) = @elem(ru_asa_pr, @str(!LRyr))
	comp_ru(7,4) = @val(comp_ru(5,4)) - @val(comp_ru(6,4))
	
	comp_ru(10,2) = @elem(rum_asa, @str(!last_hist_yr))
	comp_ru(11,2) = @elem(rum_asa_pr, @str(!last_hist_yr))
	comp_ru(12,2) = @val(comp_ru(10,2)) - @val(comp_ru(11,2))
	
	comp_ru(10,3) = @elem(rum_asa, @str(!SRyr))
	comp_ru(11,3) = @elem(rum_asa_pr, @str(!SRyr))
	comp_ru(12,3) = @val(comp_ru(10,3)) - @val(comp_ru(11,3))
	
	comp_ru(10,4) = @elem(rum_asa, @str(!LRyr))
	comp_ru(11,4) = @elem(rum_asa_pr, @str(!LRyr))
	comp_ru(12,4) = @val(comp_ru(10,4)) - @val(comp_ru(11,4))

	comp_ru(15,2) = @elem(ruf_asa, @str(!last_hist_yr))
	comp_ru(16,2) = @elem(ruf_asa_pr, @str(!last_hist_yr))
	comp_ru(17,2) = @val(comp_ru(15,2)) - @val(comp_ru(16,2))
	
	comp_ru(15,3) = @elem(ruf_asa, @str(!SRyr))
	comp_ru(16,3) = @elem(ruf_asa_pr, @str(!SRyr))
	comp_ru(17,3) = @val(comp_ru(15,3)) - @val(comp_ru(16,3))
	
	comp_ru(15,4) = @elem(ruf_asa, @str(!LRyr))
	comp_ru(16,4) = @elem(ruf_asa_pr, @str(!LRyr))
	comp_ru(17,4) = @val(comp_ru(15,4)) - @val(comp_ru(16,4))
	
	'delete pf* pm* p16* *_chg

	'format the tables
	logmsg Format the tables
	logmsg
	
	comp_ep_lfpr.setmerge(B1:D1)
 	comp_ep_lfpr.setmerge(B2:D2)
 	comp_ep_lfpr.setmerge(E1:G1)
 	comp_ep_lfpr.setmerge(E2:G2)
	comp_ru.setmerge(B1:D1)
	comp_ru.setmerge(B2:D2)
	
	comp_ep_lfpr.setformat(@all) f.2
	comp_ep_lfpr.setjust(@all) center
	comp_ep_lfpr.setfont(A) +b
	comp_ep_lfpr.setfont(A1:G3) +b
	comp_ep_lfpr.setwidth(2:7) 12
	
	comp_ru.setformat(@all) f.2
	comp_ru.setjust(@all) center
	comp_ru.setfont(A) +b
	comp_ru.setfont(A1:G3) +b

	comp_ep_lfpr.title Table A: Comparison of Projections in the {!TRyr} and {!TRyr_pr} Trustees Reports
	comp_ru.title Table B: Comparison of Projections in the {!TRyr} and {!TRyr_pr} Trustees Reports (for info only, NOT included in paper)
	
	chg_f_alt2.title Civilian Labor Force Participation Rates -- Women (by age group), difference between {!TRyr} Trustees Report and {!TRyr_pr} Trustees Report (intermediate assumptions, percentage points)
	chg_m_alt2.title Civilian Labor Force Participation Rates -- Men (by age group), difference between {!TRyr} Trustees Report and {!TRyr_pr} Trustees Report (intermediate assumptions, percentage points)
	chg_all_alt2.title Civilian Labor Force Participation Rates, difference between {!TRyr} Trustees Report and {!TRyr_pr} Trustees Report (intermediate assumptions, percentage points)
	
	chg_fe_alt2.title Ratio of Employment to Civilian Noninstitutional Population -- Women (by age group), difference between {!TRyr} Trustees Report and {!TRyr_pr} Trustees Report (intermediate assumptions, percentage points)
	chg_me_alt2.title Ratio of Employment to Civilian Noninstitutional Population -- Men (by age group), difference between {!TRyr} Trustees Report and {!TRyr_pr} Trustees Report (intermediate assumptions, percentage points)
	chg_alle_alt2.title Ratio of Employment to Civilian Noninstitutional Population, difference between {!TRyr} Trustees Report and {!TRyr_pr} Trustees Report (intermediate assumptions, percentage points)
	
	!proj_row=!TRyr-2010+6 
	!last_row = !TRyr-2010+76+6
	'tables for females and males
	for %tab chg_f_alt2 chg_m_alt2 chg_fe_alt2 chg_me_alt2
		{%tab}.insertrow(1) 3
		{%tab}.insertrow(6) 1
		{%tab}.insertrow(!proj_row) 1
		{%tab}.setmerge(B1:P1)
		{%tab}.setmerge(B2:P2)
		{%tab}(2,2)=" Difference: "+@str(!TRyr)+" Trustees Report vs. "+@str(!TRyr_pr)+" Trustees Report (intermediate assumptions, percentage points)"
		{%tab}(3,2)="16-17"
		{%tab}(3,3)="18-19"
		{%tab}(3,4)="20-24"
		{%tab}(3,5)="25-29"
		{%tab}(3,6)="30-34"
		{%tab}(3,7)="35-39"
		{%tab}(3,8)="40-44"
		{%tab}(3,9)="45-49"
		{%tab}(3,10)="50-54"
		{%tab}(3,11)="55-59"
		{%tab}(3,12)="60-64"
		{%tab}(3,13)="65-69"
		{%tab}(3,14)="70+"
		{%tab}(3,15)="16+"
		{%tab}(3,16)="16+ Age-Adj."
		{%tab}(6,2)="Historical"
		{%tab}(!proj_row,2)="Projected"
		
		{%tab}.setformat(@all) f.4
		{%tab}.setjust(@all) center
		{%tab}.setfont(B2) +b
		{%tab}.setwidth(2:15) 8
		{%tab}.setlines(B1:P2) +a
		{%tab}.setjust(B3:P3) center
		{%tab}.setlines(A1:A{!last_row}) +o
		{%tab}.setlines(A1:P{!last_row}) +o
		{%tab}.setlines(O3:O{!last_row}) +o
	
		!cl=2
		for %c B C D E F G H I J K L M N O P
			{%tab}.setlines({%c}3:{%c}4) +o
			{%tab}(4,!cl) = " "
			!cl=!cl+1
		next
		{%tab}(4,16)="(" + %base + " pop.)"
	next
	chg_f_alt2(1,2)="Civilian Labor Force Participation Rates -- Women (by age group)"
	chg_m_alt2(1,2)="Civilian Labor Force Participation Rates -- Men (by age group)"
	chg_fe_alt2(1,2)="Ratio of Employment to Civilian Noninstitutional Population -- Women (by age group)"
	chg_me_alt2(1,2)="Ratio of Employment to Civilian Noninstitutional Population -- Men (by age group)"
	chg_f_alt2.setfont(B1) +b
	chg_m_alt2.setfont(B1) +b
	chg_fe_alt2.setfont(B1) +b
	chg_me_alt2.setfont(B1) +b

	'table for all16o
	!proj_row=!Tryr-2010+8 
	!last_row = !TRyr-2010+76+8
for %tab chg_all_alt2 chg_alle_alt2
	{%tab}.insertrow(1) 5
	{%tab}.insertrow(8) 1
	{%tab}.insertrow(!proj_row) 1
	{%tab}(8,2)=" Historical"
	{%tab}(!proj_row,2)=" Projected"
	{%tab}.setmerge(A1:C1)
	{%tab}.setmerge(A2:C2)
	{%tab}.setmerge(A3:C3)
	{%tab}.setmerge(A4:C4)
	'{%tab}(1,1)="Civilian Labor Force Participation Rates"
	{%tab}(2,1)=" Difference: "
	{%tab}(3,1)= @str(!TRyr)+" Trustees Report vs. " + @str(!TRyr_pr)+" Trustees Report "
	{%tab}(4,1) = "(intermediate assumptions, percentage points)"
	{%tab}(5,2)="16+"
	{%tab}(6,2)=" "
	{%tab}(5,3)="16+ Age-Sex-Adj."
	{%tab}(6,3)="(" + %base + " pop.)"

	{%tab}.setformat(@all) f.4
	{%tab}.setjust(@all) center
	{%tab}.setjust(A3) center
	{%tab}.setjust(B8) left
	{%tab}.setjust(B{!proj_row}) left
	{%tab}.setfont(A1) +b
	{%tab}.setfont(A2) +b
	{%tab}.setfont(A3) +b
	{%tab}.setfont(A4) +b
	{%tab}.setwidth(2:3) 20
	{%tab}.setlines(A1) +a
	{%tab}.setlines(A2:C4) +o
	{%tab}.setlines(A5:A6) +o
	{%tab}.setlines(B5:B6) +o
	{%tab}.setlines(C5:C6) +o
	{%tab}.setlines(A1:C{!last_row}) +o
	{%tab}.setlines(B5:B{!last_row}) +o
next
chg_all_alt2(1,1)="Civilian Labor Force Participation Rates"
chg_alle_alt2(1,1)="Ratio of Employment to Civilian Noninstitutional Population"
chg_all_alt2.setfont(A1) +b
chg_alle_alt2.setfont(A1) +b
	
logmsg DONE creating and formatting projections tables
logmsg

'******** LFPR Decomposition Tables *****
logmsg Starting decomposition tables

%agegroups="_16o M16o M1617 M1819 M2024 M2529 M3034 M3539 M4044 M4549 M5054 M5559 M6064 M6569 M70o F16o F1617 F1819 F2024 F2529 F3034 F3539 F4044 F4549 F5054 F5559 F6064 F6569 F70o" 'list of the age groups IN THE ORDER they will appear in the final tables; note the underscore in front of _16o (it is needed to match the names used in the LFPR_decomp workfile) 

!firstyr=!TRyr-1 'first year in the LFPR decomposition table, i.e. 2016 for TR2017 (Q4 of this year is the first projection period for any TR)
!SRyr=!TRyr+9 'last year of the short-range period, i.e. 2026 for TR2017
!LRyr=!TRyr+74 'last year of the long-range period, i.e. 2091 for TR2017

scalar SR = !TRyr+9
scalar LR = !TRyr+74
' ******* NOTE! !firstyr, SRyr, and LRyr should stay the same even when we are doing decomposition tables for the previous-year TR. 

wfselect {%output_file}
pageselect tables
smpl @all

string current = @str(!TRyr)
string prior = @str(!TRyr-1)

%current = current
%prior = prior

'*****Tables for Adjusted LFPRs -- loops through currentTR file and priorTR file

for %TR {current} {prior}	
	'define tables names
	%table_s_a="table_TR"+%TR+"_SR_A"
	%table_l_a="table_TR"+%TR+"_LR_A"

	logmsg Loading data from LFPR_decomp files

	'select which file to open to get decomposition data
	if %TR={%current} then
		%input=%decomp_path_current+%current_a+".wf1" 
		wfopen %input
		copy {%current_a}::results\lfpr* {%output_file}::tables\  	' copy all lfpr decomposition tables
		copy {%current_a}::q\eq_* {%output_file}::tables\ 				' copy equations so that we can later collect coefficients into one chart
		for %ser {%agegroups}
			copy {%current_a}::q\{%ser}_ga {%output_file}::{%page_alt2}_q\*_a 	' copy series that show "total LF addfactor" for each age group
		next
		wfclose %input
	endif
	if %TR={%prior} then
		%input=%decomp_path_prior+%prior_a+".wf1" 
		wfopen %input
		copy {%prior_a}::results\lfpr* {%output_file}::tables\  
		for %ser {%agegroups}
			copy {%prior_a}::q\{%ser}_ga {%output_file}::{%page_alt2pr}_q\*_a 	' copy series that show "total LF addfactor" for each age group
		next
		wfclose %input
	endif

	logmsg Loading data from LFPR_decomp files -- done.
	logmsg Now making the decomp tables

	'declare the tables of appropriate size
	wfselect {%output_file}
	pageselect tables
	table(40,14) {%table_s_a} 
	table(40,14) {%table_l_a} 

	'copy data from LFPR decomp tables into output tables
	'loop through all the LFPRs for different age groups
	!dest_row = 11 ' FIRST row in the output table that contains data (all rows above are the header rows)

	for %tab {%agegroups}
		
		'logmsg group {%tab}
		scalar SRrow=0
		scalar LRrow=0
		for !row=1 to 100 'find which row in the LFPR decomp table corresponds to SR year and which to LRyear
			if lfpr_{%tab}(!row,1)=!SRyr then SRrow=!row
				else if lfpr_{%tab}(!row,1)=!LRyr then LRrow=!row
						endif
			endif
		next
		
		'Short-range tables 
		'logmsg SR_a table

		{%table_s_a}(!dest_row,1) = %tab
		{%table_s_a}(!dest_row,2) = 100 * lfpr_{%tab}(SRrow-10,2)
		
		for !col=3 to 9
			{%table_s_a}(!dest_row,!col) = 100 * (@val(lfpr_{%tab}(SRrow,!col+9)) - @val(lfpr_{%tab}(SRrow-10,!col+9)) ) 
		next
		
		{%table_s_a}(!dest_row,10) = 100 * (@val(lfpr_{%tab}(SRrow,7)) - @val(lfpr_{%tab}(SRrow-10,7)))
		{%table_s_a}(!dest_row,11) = 100 * (@val(lfpr_{%tab}(SRrow,5)) - @val(lfpr_{%tab}(SRrow-10,5)) )
		{%table_s_a}(!dest_row,12) = @val({%table_s_a}(!dest_row,10))+@val({%table_s_a}(!dest_row,11))
		{%table_s_a}(!dest_row,13) = 100 * (@val(lfpr_{%tab}(SRrow,4)) - @val(lfpr_{%tab}(SRrow-10,4)) + @val(lfpr_{%tab}(SRrow,6)) - @val(lfpr_{%tab}(SRrow-10,6)))
		'											  ' total LF addfactor 														' individual addfactors

		{%table_s_a}(!dest_row,14) = 100 * lfpr_{%tab}(SRrow,2)
	
		'Long-range tables  
		'logmsg LR_a table

		{%table_l_a}(!dest_row,1) = %tab

		for !col=3 to 9
			{%table_l_a}(!dest_row,!col) = 100 * (@val(lfpr_{%tab}(LRrow,!col+9)) - @val(lfpr_{%tab}(SRrow,!col+9)) )
		next
		{%table_l_a}(!dest_row,10) = 100 * (@val(lfpr_{%tab}(LRrow,7)) - @val(lfpr_{%tab}(SRrow,7)) )
		{%table_l_a}(!dest_row,11) = 100 * (@val(lfpr_{%tab}(LRrow,5)) - @val(lfpr_{%tab}(SRrow,5)) )
		{%table_l_a}(!dest_row,12) = @val({%table_l_a}(!dest_row,10)) + @val({%table_l_a}(!dest_row,11))
		{%table_l_a}(!dest_row,13) = 100 * (@val(lfpr_{%tab}(LRrow,4)) - @val(lfpr_{%tab}(SRrow,4)) + @val(lfpr_{%tab}(LRrow,6)) - @val(lfpr_{%tab}(SRrow,6)) )
		'											' total LF addfactor (zero in LR; including here to show parallel with the SR_a tables) 	+	' individual addfactors		
		{%table_l_a}(!dest_row,14) = 100 * lfpr_{%tab}(LRrow,2)
	
		!dest_row=!dest_row+1
	next 
	logmsg Formatting the tables

	{%table_s_a}.copyrange N11 N39 {%table_l_a} B11 'copy the "ending" LFPRs in SR table into "initial" LFPRs in LR table 

	'Format the tables 
	{%table_s_a}.title Table 7. Labor Force Participation Rates (Age-Sex-Mar-Child Adjusted, {%base} base): {!firstyr}Q4 to {!SRyr}Q4 ({%TR} Trustees Report, intermediate assumptions)
	{%table_l_a}.title Table 8. Labor Force Participation Rates (Age-Sex-Mar-Child Adjusted, {%base} base): {!SRyr}Q4 to {!LRyr}Q4 ({%TR} Trustees Report, intermediate assumptions) 

	{%table_s_a}(4,1) = "Age-Sex"
	{%table_s_a}(5,1) = "Group"
	{%table_s_a}(1,2) = @str(!firstyr)+" Q4"
	
	{%table_s_a}(1,14) = @str(!SRyr)+" Q4"
	{%table_s_a}(4,2) = "OCACT"
	{%table_s_a}(5,2) = "Model"	
	{%table_s_a}(4,14) = "OCACT"
	{%table_s_a}(5,14) = "Model"
	{%table_s_a}.setmerge(C1:L1)
	{%table_s_a}.setmerge(C2:L2)	
	{%table_s_a}.setmerge(C3:J3)
	{%table_s_a}.setmerge(C4:I4)
	{%table_s_a}(1,3) = "Decomposition of Cumulative OCACT Model Change (percentage points)"
	{%table_s_a}(2,3) = "from "+@str(!firstyr)+" Q4 to "+@str(!SRyr)+" Q4"
	
	{%table_s_a}(3,3) = "LFPR Model Equations"
	{%table_s_a}(4,3) = "Equation Components"
	{%table_s_a}(5,3)="Bus. "
	{%table_s_a}(6,3)="Cycle"
	{%table_s_a}(5,4)="Disab."
	{%table_s_a}(6,4)="Prev."
	{%table_s_a}(6,5)="Educ."
	{%table_s_a}(5,6)="Rep."
	{%table_s_a}(6,6)="Rate"
	{%table_s_a}(5,7)="Earn."
	{%table_s_a}(6,7)="Test"
	{%table_s_a}(5,8)="Lagged"
	{%table_s_a}(6,8)="Cohort"
	{%table_s_a}(7,8)="(75+)"
	{%table_s_a}(5,9)="Time"
	{%table_s_a}(6,9)="Trend"
	{%table_s_a}(6,10)="SubTotal"
	{%table_s_a}(5,11)="Life"
	{%table_s_a}(6,11)="Expect."
	{%table_s_a}(5,12)="Total"
	{%table_s_a}(1,13)="Adjustment"
	{%table_s_a}(2,13)="to link"
	{%table_s_a}(3,13)="model"
	{%table_s_a}(4,13)="to latest"
	{%table_s_a}(5,13)="data, and"
	{%table_s_a}(6,13)="model"
	{%table_s_a}(7,13)="addfactors"
	'{%table_s_a}(7,13)=@str(@val(%TR)+9)+")" 
	{%table_s_a}(8,2)="(b)"
	{%table_s_a}(8,3)="(c)"
	{%table_s_a}(8,4)="(d)"
	{%table_s_a}(8,5)="(e)"
	{%table_s_a}(8,6)="(f)"
	{%table_s_a}(8,7)="(g)"
	{%table_s_a}(8,8)="(h)"
	{%table_s_a}(8,9)="(i)"
	{%table_s_a}(8,10)="(j)"
	{%table_s_a}(9,10)="sum(c:i)"
	{%table_s_a}(8,11)="(k)"
	{%table_s_a}(8,12)="(l)"
	{%table_s_a}(9,12)="(j+k)"
	{%table_s_a}(8,13)="(m)"
	{%table_s_a}(8,14)="(n)"
	{%table_s_a}(9,14)="(b+l+m)"

	'fix some individual cells
	{%table_s_a}(11,1) = "16+"
	{%table_s_a}(12,1) = "M16+"
	{%table_s_a}(25,1) = "M70+"
	{%table_s_a}(26,1) = "F16+"
	{%table_s_a}(39,1) = "F70+"
	
	'formatting the table header section
	{%table_s_a}.setlines(A1:N10) +a
	{%table_s_a}.setlines(B1) +a
	{%table_s_a}.setlines(N1) +a
	{%table_s_a}.setlines(A1:A9) -i
	{%table_s_a}.setlines(B2:B7) -i
	{%table_s_a}.setlines(M1:M7) -i
	{%table_s_a}.setlines(M1:M7) +o
	{%table_s_a}.setlines(N2:N7) -i
	{%table_s_a}.setlines(C1:C2) -i

	{%table_s_a}.setlines(C5:C7) -i
	{%table_s_a}.setlines(D5:D7) -i
	{%table_s_a}.setlines(E5:E7) -i
	{%table_s_a}.setlines(F5:F7) -i
	{%table_s_a}.setlines(G5:G7) -i
	{%table_s_a}.setlines(H5:H7) -i
	{%table_s_a}.setlines(I5:I7) -i
	{%table_s_a}.setlines(J4:J7) -i
	{%table_s_a}.setlines(K3:K7) -i
	{%table_s_a}.setlines(L3:L7) -i
	
	for %c B C D E F G H I J K L M N 'O P
		{%table_s_a}.setlines({%c}8:{%c}9) -i
	next
	'**** header for the SR table is fully formatted
	
	'copy the table header section and first column into LR table
	{%table_s_a}.copyrange A1 N10 {%table_l_a} A1
	{%table_s_a}.copyrange A11 A39 {%table_l_a} A11
	'a few special changes needed
	{%table_l_a}(2,3) = "from "+@str(!SRyr)+" Q4 to "+@str(!LRyr)+" Q4" 
	{%table_l_a}(1,2) = @str(!SRyr)+" Q4"
	{%table_l_a}(1,14) = @str(!LRyr)+" Q4"
	{%table_l_a}(4,13) = "Model"
	{%table_l_a}(5,13) = "Addfactors"
	{%table_l_a}(1,13) = " "
	{%table_l_a}(2,13) = " "
	{%table_l_a}(3,13) = " "
	{%table_l_a}(6,13) = " "
	{%table_l_a}(7,13) = " "
	
	'create borders, do cell formatting and insert "--" into cells that should be empty (both SR table and LR table)
	 for %tab {%table_s_a} {%table_l_a}
	 	{%tab}.setformat(B11:N39) f.2
	 	'{%tab}.setformat(B11:B39) f.2
	  	{%tab}.setwidth(@all) 9
 		{%tab}.setjust(B11:N39) center
 		{%tab}.setfont(B4:B5) +b
 		{%tab}.setfont(C1:C2) +b
 		{%tab}.setfont(B1) +b
 		{%tab}.setfont(N1) +b
 	
 		{%tab}.setlines(A11:N39) +o
 		{%tab}.setlines(A11:A39) +o
 		{%tab}.setlines(B11:B39) +o
 		{%tab}.setlines(J11:J39) +o
 		{%tab}.setlines(K11:K39) +o
 		{%tab}.setlines(L11:L39) +o
 		{%tab}.setlines(M11:M39) +o
	
 		{%tab}.setlines(A11:N11) +o
 		{%tab}.setlines(A12:N12) +o
 		{%tab}.setlines(A26:N26) +o
 		 	
		for !r = 22 to 25
			{%tab}(!r,3) = "--"
		next
		for !r = 36 to 39
			{%tab}(!r,3) = "--"
		next

		for !c=5 to 8 
 			for !r=13 to 21
 				{%tab}(!r,!c) = "--"
 			next
 			for !r=27 to 34
 				{%tab}(!r,!c) = "--"
 			next
 		next
 		
 		for !r = 17 to 25
			{%tab}(!r,9) = "--"
		next
		for !r = 31 to 39
			{%tab}(!r,9) = "--"
		next
 		
 		{%tab}(22,6) = "--"
 		{%tab}(22,7) = "--"
 		{%tab}(22,8) = "--"
 		{%tab}(25,6) = "--"
 		{%tab}(25,7) = "--"
		{%tab}(23,8) = "--"
		{%tab}(24,8) = "--"

		for !c=6 to 8
			for !r=35 to 36
				{%tab}(!r,!c) = "--"
			next
		next
		
		{%tab}(37,7) = "--"
 		{%tab}(37,8) = "--"
 		{%tab}(38,8) = "--"
 		{%tab}(39,6) = "--"
 		{%tab}(39,7) = "--"
		
		for !r=13 to 18
			{%tab}(!r,11) = "--"
		next
		
		for !r=27 to 32
			{%tab}(!r,11) = "--"
		next

	next
	{%table_s_a}.setfont(N4:N5) +b
	{%table_l_a}.setfont(N4:N5) +b
	{%table_s_a}.setlines(N11:N39) +o
	{%table_s_a}.setlines(N11:N12) +a
	{%table_s_a}.setlines(N26) +a
	{%table_s_a}.setformat(N11:N39) f.2
	{%table_s_a}.setwidth(13) 10
 
	delete lfpr_* 'delete all LFPR decomp input tables before loading the next set

next 'end of the loop for Adjusted LFPRtables for currentTR and priorTR

logmsg Deconposition tables (A) done



' Collect coefficients for MSshare and Edscore into vectors to place them on charts later
wfselect {%output_file}
pageselect tables
smpl @all

logmsg Creating charts with MSshare and Edscore coefficients

matrix(20,2) ms
matrix(20,2) ed
!i = 1
for !a = 55 to 74
	ed(!i,1) = eq_pm{!a}.@coef(1)
	ed(!i,2) = eq_pf{!a}.@coef(1)

	ms(!i,1) = eq_pm{!a}.@coef(2)
	ms(!i,2) = eq_pf{!a}.@coef(2)
	
	!i = !i + 1
next

' Make charts and format them
freeze(cf_ms) ms.line
freeze(cf_ed) ed.line

for %gr cf_ms cf_ed
	{%gr}.setelem(1) symbol(circle)
	{%gr}.setelem(2) symbol(circle)
	
	{%gr}.options gridcust(obs,1)
	
	{%gr}.setelem(1) legend(men)
	{%gr}.setelem(2) legend(women)
	
	{%gr}.setobslabel "55" "56" "57" "58" "59" "60" "61" "62" "63" "64" "65" "66" "67" "68" "69" "70" "71" "72" "73" "74"
next

' horizontal line at zero
cf_ms.axis(l) zeroline
cf_ed.axis(l) zeroline

%title = "Coefficients on MSshare variable in SYOA LFPR equations (ages 55 to 74)"
cf_ms.addtext(font(+b), t) %title
%title = "Coefficients on EDscore variable in SYOA LFPR equations (ages 55 to 74)"
cf_ed.addtext(font(+b), t) %title
' Can delete all equation object from the file at this point, if desired


'*****Tables for Unadjusted LFPRs --  loops through currentTR file and priorTR file

for %TR {current} {prior}		
	'define tables names
	%table_s_u="table_TR"+%TR+"_SR_U"
	%table_l_u="table_TR"+%TR+"_LR_U"
	
	'select which file to open to get decomposition data
	if %TR={%current} then
		%input=%decomp_path_current+%current_u+".wf1" 
		wfopen %input
		copy {%current_u}::results\lfpr* {%output_file}::tables\  		 	' copy all lfpr decomposition tables
		for %ser {%agegroups}
			copy {%current_u}::q\{%ser}_ga {%output_file}::{%page_alt2}_q\*_u 	' copy series that show "total LF addfactor" for each age group
		next
		wfclose %input
	endif
	if %TR={%prior} then
		%input=%decomp_path_prior+%prior_u+".wf1" 
		wfopen %input
		copy {%prior_u}::results\lfpr* {%output_file}::tables\  
		for %ser {%agegroups}
			copy {%prior_u}::q\{%ser}_ga {%output_file}::{%page_alt2pr}_q\*_u 	' copy series that show "total LF addfactor" for each age group
		next
		wfclose %input
	endif

	'declare the tables of appropriate size
	pageselect tables
	table(40,19) {%table_s_u} 
	table(40,19) {%table_l_u}

	'copy data from LFPR decomp tables into output tables
	'loop through all the LFPRs for different age groups
	!dest_row=11 'this is the FIRST row in the output table that contains data (all rows above are the header rows)
	for %tab {%agegroups}
		scalar SRrow=0
		scalar LRrow=0
		for !row=1 to 100 'find which row in the LFPR decomp table corresponds to SR year and which to LRyear
			if lfpr_{%tab}(!row,1)=!SRyr then SRrow=!row
				else if lfpr_{%tab}(!row,1)=!LRyr then LRrow=!row
						endif
			endif
		next
		
		'Short-range table
		{%table_s_u}(!dest_row,1) = %tab
		{%table_s_u}(!dest_row,2) = 100 * lfpr_{%tab}(SRrow-10,2)
	
		for !col=3 to 6
			{%table_s_u}(!dest_row,!col) = 100 * (@val(lfpr_{%tab}(SRrow,!col+5)) - @val(lfpr_{%tab}(SRrow-10,!col+5)) )
		next
		{%table_s_u}(!dest_row,7) = @val({%table_s_u}(!dest_row,3))+@val({%table_s_u}(!dest_row,4))+@val({%table_s_u}(!dest_row,5))+@val({%table_s_u}(!dest_row,6))
	
		for !col=8 to 14
			{%table_s_u}(!dest_row,!col) = 100 * (@val(lfpr_{%tab}(SRrow,!col+4)) - @val(lfpr_{%tab}(SRrow-10,!col+4)) )
		next
		{%table_s_u}(!dest_row,15) = 100 * (@val(lfpr_{%tab}(SRrow,7)) - @val(lfpr_{%tab}(SRrow-10,7)) )
		{%table_s_u}(!dest_row,16) = 100 * (@val(lfpr_{%tab}(SRrow,5)) - @val(lfpr_{%tab}(SRrow-10,5)) )
		{%table_s_u}(!dest_row,17) = @val({%table_s_u}(!dest_row,15))+@val({%table_s_u}(!dest_row,16)) 
		{%table_s_u}(!dest_row,18) = 100 * (@val(lfpr_{%tab}(SRrow,4)) - @val(lfpr_{%tab}(SRrow-10,4)) + @val(lfpr_{%tab}(SRrow,6)) - @val(lfpr_{%tab}(SRrow-10,6)) )
		'											  ' total LF addfactor 														' individual addfactors
		
		{%table_s_u}(!dest_row,19) = 100 * lfpr_{%tab}(SRrow,2)
	
		'Long-range table
		{%table_l_u}(!dest_row,1) = %tab
		for !col=3 to 6
			{%table_l_u}(!dest_row,!col) = 100 * (@val(lfpr_{%tab}(LRrow,!col+5)) - @val(lfpr_{%tab}(SRrow,!col+5)) )
		next
		{%table_l_u}(!dest_row,7) = @val({%table_l_u}(!dest_row,3))+@val({%table_l_u}(!dest_row,4))+@val({%table_l_u}(!dest_row,5))+@val({%table_l_u}(!dest_row,6))
		
		for !col=8 to 14
			{%table_l_u}(!dest_row,!col) = 100 * (@val(lfpr_{%tab}(LRrow,!col+4)) - @val(lfpr_{%tab}(SRrow,!col+4)) )
		next
		{%table_l_u}(!dest_row,15) = 100 * (@val(lfpr_{%tab}(LRrow,7)) - @val(lfpr_{%tab}(SRrow,7)) )
		{%table_l_u}(!dest_row,16) = 100 * (@val(lfpr_{%tab}(LRrow,5)) - @val(lfpr_{%tab}(SRrow,5)) )
		{%table_l_u}(!dest_row,17) = @val({%table_l_u}(!dest_row,15)) + @val({%table_l_u}(!dest_row,16))
		{%table_l_u}(!dest_row,18) = 100 * (@val(lfpr_{%tab}(LRrow,4)) - @val(lfpr_{%tab}(SRrow,4)) + @val(lfpr_{%tab}(LRrow,6)) - @val(lfpr_{%tab}(SRrow,6)) )
		'											' total LF addfactor (zero in LR; including here to show parallel with the SR_u table) 	+	' individual addfactors
		{%table_l_u}(!dest_row,19) = 100 * lfpr_{%tab}(LRrow,2)
	
		!dest_row=!dest_row+1
	next
	{%table_s_u}.copyrange S11 S39 {%table_l_u} B11 'copy the "ending" LFPRs in SR table into "initial" LFPRs in LR table   

	'Format the tables
	{%table_s_u}.title Table 9. Labor Force Participation Rates (unadjusted): {!firstyr}Q4 to {!SRyr}Q4 ({%TR} Trustees Report, intermediate assumptions)
	{%table_l_u}.title Table 10. Labor Force Participation Rates (unadjusted): {!SRyr}Q4 to {!LRyr}Q4 ({%TR} Trustees Report, intermediate assumptions)


	{%table_s_u}(4,1) = "Age-Sex"
	{%table_s_u}(5,1) = "Group"
	{%table_s_u}(1,2) = @str(!firstyr)+" Q4"	
	{%table_s_u}(1,19) = @str(!SRyr)+" Q4"
	{%table_s_u}(4,2) = "OCACT"
	{%table_s_u}(5,2) = "Model"
	{%table_s_u}(4,19) = "OCACT"
	{%table_s_u}(5,19) = "Model"
	{%table_s_u}.setmerge(C1:Q1)
	{%table_s_u}.setmerge(C2:Q2)
	{%table_s_u}.setmerge(C3:O3)
	{%table_s_u}.setmerge(C4:F4)
	{%table_s_u}.setmerge(H4:N4)
	{%table_s_u}(1,3) = "Decomposition of Cumulative OCACT Model Change (percentage points)"
	{%table_s_u}(2,3) = "from "+@str(!firstyr)+" Q4 to "+@str(!SRyr)+" Q4"
	{%table_s_u}(3,3) = "LFPR Model Equations"
	{%table_s_u}(4,3) = "Demographic Factors"
	{%table_s_u}(4,8) = "Regression Factors"
	{%table_s_u}(6,3)="Age"
	{%table_s_u}(6,4)="Gender"
	{%table_s_u}(5,5)="Marital"
	{%table_s_u}(6,5)="Status"
	{%table_s_u}(5,6)="Child"
	{%table_s_u}(6,6)="Pres."
	{%table_s_u}(5,7)="Demog."
	{%table_s_u}(6,7)="SubTotal"
	{%table_s_u}(5,8)="Bus. "
	{%table_s_u}(6,8)="Cycle"
	{%table_s_u}(5,9)="Disab."
	{%table_s_u}(6,9)="Prev."
	{%table_s_u}(6,10)="Educ."
	{%table_s_u}(5,11)="Rep."
	{%table_s_u}(6,11)="Rate"
	{%table_s_u}(5,12)="Earn."
	{%table_s_u}(6,12)="Test"

	{%table_s_u}(5,13)="Lagged"
	{%table_s_u}(6,13)="Cohort"
	{%table_s_u}(7,13)="(75+)"
	{%table_s_u}(5,14)="Time"
	{%table_s_u}(6,14)="Trend"
	{%table_s_u}(6,15)="SubTotal"
	{%table_s_u}(5,16)="Life"
	{%table_s_u}(6,16)="Expect."
	{%table_s_u}(5,17)="Total"
	{%table_s_u}(1,18)="Adjustment"
	{%table_s_u}(2,18)="to link"
	{%table_s_u}(3,18)="model"
	{%table_s_u}(4,18)="to latest"
	{%table_s_u}(5,18)="data, and"
	{%table_s_u}(6,18)="model"
	{%table_s_u}(7,18)="addfactors"
	{%table_s_u}(8,2)="(b)"
	{%table_s_u}(8,3)="(c)"
	{%table_s_u}(8,4)="(d)"
	{%table_s_u}(8,5)="(e)"
	{%table_s_u}(8,6)="(f)"
	{%table_s_u}(8,7)="(g)"
	{%table_s_u}(9,7)="sum(c:f)"
	{%table_s_u}(8,8)="(h)"
	{%table_s_u}(8,9)="(i)"
	{%table_s_u}(8,10)="(j)"
	{%table_s_u}(8,11)="(k)"
	{%table_s_u}(8,12)="(l)"
	{%table_s_u}(8,13)="(m)"
	{%table_s_u}(8,14)="(n)"
	{%table_s_u}(8,15)="(o)"
	{%table_s_u}(9,15)="sum(g:n)"
	{%table_s_u}(8,16)="(p)"
	{%table_s_u}(8,17)="(q)"
	{%table_s_u}(9,17)="(o+p)"
	{%table_s_u}(8,18)="(r)"
	{%table_s_u}(8,19)="(s)"
	{%table_s_u}(9,19)="(b+q+r)"
	
	'fix some individual cells
	{%table_s_u}(11,1) = "16+"
	{%table_s_u}(12,1) = "M16+"
	{%table_s_u}(25,1) = "M70+"
	{%table_s_u}(26,1) = "F16+"
	{%table_s_u}(39,1) = "F70+"

	'formatting the table header section
	{%table_s_u}.setlines(A1:S10) +a
	{%table_s_u}.setlines(B1) +a
	{%table_s_u}.setlines(S1) +a
	{%table_s_u}.setlines(A1:A9) -i
	{%table_s_u}.setlines(B2:B7) -i
	{%table_s_u}.setlines(S2:S7) -i
	{%table_s_u}.setlines(C1:C2) -i

	for %c C D E F G H I J K L M N 'O P
		{%table_s_u}.setlines({%c}5:{%c}7) -i
		{%table_s_u}.setlines({%c}8:{%c}9) -i
	next

	{%table_s_u}.setlines(G4:G7) -i
	{%table_s_u}.setlines(O4:O7) -i
	{%table_s_u}.setlines(P3:P7) -i
	{%table_s_u}.setlines(Q3:Q7) -i
	
	{%table_s_u}.setlines(B8:B9) -i
	{%table_s_u}.setlines(O8:O9) -i
	{%table_s_u}.setlines(P8:P9) -i
	{%table_s_u}.setlines(Q8:Q9) -i
	{%table_s_u}.setlines(R1:R7) -i +o
	{%table_s_u}.setlines(R8:R9) -i
	{%table_s_u}.setlines(S8:S9) -i

	'copy the table header section and first column into LR table
	{%table_s_u}.copyrange A1 S10 {%table_l_u} A1
	{%table_s_u}.copyrange A11 A39 {%table_l_u} A11
	'a few special changes needed
	{%table_l_u}(2,3) = "from "+@str(!SRyr)+" Q4 to "+@str(!LRyr)+" Q4" 
	{%table_l_u}(1,2) = @str(!SRyr)+" Q4"
	{%table_l_u}(1,19) = @str(!lRyr)+" Q4"
	{%table_l_u}(4,18) = "Model"
	{%table_l_u}(5,18) = "Addfactors"
	{%table_l_u}(1,18) = " "
	{%table_l_u}(2,18) = " "
	{%table_l_u}(3,18) = " "
	{%table_l_u}(6,18) = " "
	{%table_l_u}(7,18) = " "

	'create borders, do cell formatting, and put "--" into cells in the tables that should be empty (both SR table and LR table)
	 for %tab {%table_s_u} {%table_l_u}
	 	{%tab}.setformat(@all) f.2
		{%tab}.setwidth(@all) 7
		{%tab}.setwidth(1) 8
		{%tab}.setwidth(2) 8
		{%tab}.setwidth(7) 8
		{%tab}.setwidth(15) 8
		{%tab}.setwidth(18) 10
		{%tab}.setjust(B11:S39) center
		{%tab}.setfont(B4:B5) +b
		{%tab}.setfont(C1:C2) +b
		{%tab}.setfont(B1) +b
		{%tab}.setfont(S1) +b

		{%tab}.setlines(A11:S39) +o
		{%tab}.setlines(A11:A39) +o
		{%tab}.setlines(B11:B39) +o
		{%tab}.setlines(G11:G39) +o
		{%tab}.setlines(O11:O39) +o
		{%tab}.setlines(P11:P39) +o
		{%tab}.setlines(Q11:Q39) +o
		{%tab}.setlines(R11:R39) +o
	
		{%tab}.setlines(A11:S11) +o
		{%tab}.setlines(A12:S12) +o
		{%tab}.setlines(A26:S26) +o
 	 	
 		for !r=13 to 21
 			{%tab}(!r,3) = "--"
 			{%tab}(!r,10) = "--"
 		next
 		for !r=27 to 35
 			{%tab}(!r,3) = "--"
 		next
 		for !r=12 to 39
 			{%tab}(!r,4) = "--"
 		next
		
 		{%tab}(13,5) = "--"
 		{%tab}(14,5) = "--"
 	 	{%tab}(27,5) = "--"
 		{%tab}(28,5) = "--"
 		
	  	for !r=12 to 25
 			{%tab}(!r,6) = "--"
 		next	
 	   	for !r=34 to 39
 			{%tab}(!r,6) = "--"
 		next
 		
 		for !r=22 to 25
 			{%tab}(!r,8) = "--"
 		next
  	   	for !r=36 to 39
 			{%tab}(!r,8) = "--"
 		next
 		
 	 	for !r=13 to 22
 			{%tab}(!r,11) = "--"
 			{%tab}(!r,12) = "--"
 		next
 	  	for !r=27 to 34
 			{%tab}(!r,10) = "--"
 		next	
 	  	for !r=27 to 36
 			{%tab}(!r,11) = "--"
 			{%tab}(!r,12) = "--"
 		next
 	 	{%tab}(25,11) = "--"
 	 	{%tab}(25,12) = "--"
 	  	{%tab}(39,11) = "--"
 	 	{%tab}(39,12) = "--"
 	 	
 	 	for !r=13 to 24
 			{%tab}(!r,13) = "--"
 		next
 	 	for !r=27 to 38
 			{%tab}(!r,13) = "--"
 		next
 		
 		for !r=17 to 25
 			{%tab}(!r,14) = "--"
 		next
 	 	for !r=31 to 39
 			{%tab}(!r,14) = "--"
 		next
 		
 		for !r=13 to 18
 			{%tab}(!r,16) = "--"
 		next
 	 	for !r=27 to 32
 			{%tab}(!r,16) = "--"
 		next
 		
 	next
	{%table_s_u}.setfont(S4:S5) +b
	{%table_l_u}.setfont(S4:S5) +b
	{%table_s_u}.setwidth(19) 9
	{%table_l_u}.setwidth(19) 9
	{%table_s_u}.setlines(S11:S39) +o
	{%table_s_u}.setlines(S11:S12) +a
	{%table_s_u}.setlines(S26) +a

	delete lfpr_* 'delete all Unadjusted LFPR decomp tables 
next 'end of loop creating Unadjusted LFPR tables for currentTr and priorTR

'' *** SPECIAL FOR TR21
'' Adjust column heading for SR tables for to indicate that the starting projection quarter is 2021Q2 (and not 2020Q4)
'table_tr2021_sr_a.title Table 7. Labor Force Participation Rates (Age-Sex-Mar-Child Adjusted, 2011 base): 2021Q2 to {!SRyr}Q4 ({%TR} Trustees Report, intermediate assumptions) 
'table_tr2021_sr_u.title Table 9. Labor Force Participation Rates: 2021Q2 to {!SRyr}Q4 ({%TR} Trustees Report, intermediate assumptions)
'table_tr2021_sr_a(1,2) = "2021 Q2"
'table_tr2021_sr_u(1,2) = "2021 Q2"
'table_tr2021_sr_a(2,3) = "from 2021Q2 to "+@str(!SRyr)+" Q4"
'table_tr2021_sr_u(2,3) = "from 2021Q2 to "+@str(!SRyr)+" Q4"
'' *** end of SPECIAL

logmsg Deconposition tables (U) done
logmsg

'	'Comparison tables for LFPR decomposition TRcurrent vs TRprevious
logmsg Create comparison tables for LFPR decomp...

'	'declare tables of appropriate size
	pageselect tables
	table(24,19) comp_SR_U 
	table(24,19) comp_LR_U 
	table(24,14) comp_SR_A 
	table(24,14) comp_LR_A 

	'table titles
	comp_SR_U.title Labor Force Participation Rates: {current} Trustees Report vs. {prior} Trustees Report ({!firstyr}Q4 to {!SRyr}Q4, intermediate assumptions)
	comp_LR_U.title Labor Force Participation Rates: {current} Trustees Report vs. {prior} Trustees Report ({!SRyr}Q4 to {!LRyr}Q4, intermediate assumptions)
	comp_SR_A.title Labor Force Participation Rates (Age-Sex-Mar-Child Adjusted, {%base} base): {current} Trustees Report vs. {prior} Trustees Report ({!firstyr}Q4 to {!SRyr}Q4, intermediate assumptions) 
	comp_LR_A.title Labor Force Participation Rates (Age-Sex-Mar-Child Adjusted, {%base} base): {current} Trustees Report vs. {prior} Trustees Report ({!SRyr}Q4 to {!LRyr}Q4, intermediate assumptions) 

	'copy table headers from existing tables
	{%table_s_u}.copyrange A1 U10 comp_SR_U A1
	{%table_l_u}.copyrange A1 T10 comp_LR_U A1
	{%table_s_a}.copyrange A1 P10 comp_SR_A A1
	{%table_l_a}.copyrange A1 O10 comp_LR_A A1

	for %tab SR_U LR_U SR_A LR_A
		comp_{%tab}(11,1) = "16+"
		comp_{%tab}(12,1) = current + "TR"
		comp_{%tab}(13,1) = prior + "TR"
		comp_{%tab}(14,1) = "Difference"

		comp_{%tab}(16,1) = "M16+"
		comp_{%tab}(17,1) = current + "TR"
		comp_{%tab}(18,1) = prior + "TR"
		comp_{%tab}(19,1) = "Difference"
	
		comp_{%tab}(21,1) = "F16+"
		comp_{%tab}(22,1) = current + "TR"
		comp_{%tab}(23,1) = prior + "TR"
		comp_{%tab}(24,1) = "Difference"
	
		'determine the range of cells to be copied from decomposition tables
		if %tab = "SR_U" then !last_col=19
		endif
		if %tab = "LR_U" then !last_col=19
		endif
		if %tab = "SR_A" then !last_col=14 
		endif
		if %tab = "LR_A" then !last_col=14
		endif
	
		'copy values from decomposition tables
		table_tr{current}_{%tab}.copyrange 11 2 11 !last_col comp_{%tab} 12 2
		table_tr{prior}_{%tab}.copyrange 11 2 11 !last_col comp_{%tab} 13 2
		
		table_tr{current}_{%tab}.copyrange 12 2 12 !last_col comp_{%tab} 17 2
		table_tr{prior}_{%tab}.copyrange 12 2 12 !last_col comp_{%tab} 18 2
		
		table_tr{current}_{%tab}.copyrange 26 2 26 !last_col comp_{%tab} 22 2
		table_tr{prior}_{%tab}.copyrange 26 2 26 !last_col comp_{%tab} 23 2
		
		'compute difference
		' set formal to show more decimals -- the DISPLAYED decimals affects the values used in the computation below
		comp_{%tab}.setformat(@all) f.5
		comp_{%tab}.setformat(B12:B24) f.5
		comp_{%tab}.setformat(R12C{!last_col}:R24C{!last_col}) f.5
		
		for !cols=2 to !last_col
			comp_{%tab}(14,!cols) = @val(comp_{%tab}(12,!cols)) - @val(comp_{%tab}(13,!cols))
			comp_{%tab}(19,!cols) = @val(comp_{%tab}(17,!cols)) - @val(comp_{%tab}(18,!cols))
			comp_{%tab}(24,!cols) = @val(comp_{%tab}(22,!cols)) - @val(comp_{%tab}(23,!cols))
		next
		
		'format tables
		comp_{%tab}.setfont(A11) +b
		comp_{%tab}.setfont(A16) +b
		comp_{%tab}.setfont(A21) +b
		comp_{%tab}.setwidth(3:!last_col) 8
		comp_{%tab}.setjust(A11:A24) left
		comp_{%tab}.setjust(R12C2:R24C{!last_col}) right
		comp_{%tab}.setformat(@all) f.4
		comp_{%tab}.setformat(B12:B24) f.4
		comp_{%tab}.setformat(R12C{!last_col}:R24C{!last_col}) f.4
		comp_{%tab}.setlines(R12C2:R24C{!last_col}) -a
		comp_{%tab}.setlines(A11:A24) +o
		comp_{%tab}.setlines(B11:B24) +o
		comp_{%tab}.setlines(R11C{!last_col}:R24C{!last_col}) +o
		comp_{%tab}.setlines(R11C3:R24C{!last_col}) +o
		comp_{%tab}.setlines(R14C1:R14C{!last_col}) +t
		comp_{%tab}.setlines(R19C1:R19C{!last_col}) +t
		comp_{%tab}.setlines(R24C1:R24C{!last_col}) +t
		comp_{%tab}.setlines(R15C1:R15C{!last_col}) +d
		comp_{%tab}.setlines(R20C1:R20C{!last_col}) +d
	next


delete current prior SRrow LRrow sr lr

logmsg ... done.
logmsg 

' ***** Make charts *****
wfselect {%output_file}
pageselect {%page_alt2}_a
smpl @all 

logmsg Making charts...

' *** Charts -- time series projections -- e/pop, LFPR, RU, gross and ASA.
smpl 1980 !table_end 	 'period to be displayed on the time-series charts
' LFPR gross
group proj_lfpr p16o pf16o pm16o  	
freeze(proj_lfpr_chart) proj_lfpr.line
' LFPR ASA
group proj_lfpr_asa p16o_asa pf16o_asa pm16o_asa 	
freeze(proj_lfpr_asa_chart) proj_lfpr_asa.line
' E/POP gross
group e_pop  ep16o epf16o epm16o
freeze(proj_epop_chart) e_pop.line
' E/POP ASA
group e_pop_asa  ep16o_asa epf16o_asa epm16o_asa
freeze(proj_epop_asa_chart) e_pop_asa.line
' RU gross
smpl 1980 2040 	' special period for RU charts
group rus ru ruf rum
freeze(proj_ru_chart) rus.line
' RU ASA
group rus_asa ru_asa ruf_asa rum_asa
freeze(proj_ru_asa_chart) rus_asa.line
smpl 1980 !table_end 	 're-set back to the standard period for charts

'format ALL charts
for %chrt proj_lfpr_asa_chart proj_lfpr_chart proj_epop_chart proj_epop_asa_chart proj_ru_chart proj_ru_asa_chart
	{%chrt}.datelabel format("YYYY") 	'4-digit year
	' horizontal axis tick marks every 10 yrs
	{%chrt}.axis -minor 					
	{%chrt}.datelabel interval(year, 10, 1/1/1900) 		
	'vertical axis
	{%chrt}.axis(l) format(leadzero) 		
	'{%chrt}.axis(l) range(0.48, 0.80)
	{%chrt}.recshade  			' adda recession shading to the charts
	{%chrt}.draw(line, bottom, pattern(dash1)) {!last_hist_yr} 	' vertical line dividing historical and projected (dashed line placed at !last_hist_y
	' legend
	{%chrt}.setelem(1) legend(all 16+)
	{%chrt}.setelem(2) legend(women 16+)
	{%chrt}.setelem(3) legend(men 16+)
	{%chrt}.addtext(b) Shaded areas represent recessions
	' create a wider recession shading for 2001 and 2020
	{%chrt}.draw(line, bottom, @rgb(234,234,234), pattern(1), linewidth(3)) 2001
	{%chrt}.draw(line, bottom, @rgb(234,234,234), pattern(1), linewidth(3)) 2020
next
' LFPR charts
' set range
proj_lfpr_asa_chart.axis(l) range(48, 80)
proj_lfpr_chart.axis(l) range(48, 80)
' verstical axis title
proj_lfpr_asa_chart.addtext(l) percent 'Labor force participation rate
proj_lfpr_chart.addtext(l) percent 'Labor force participation rate

'E/pop charts
' range
proj_epop_chart.axis(l) range(45, 75)
proj_epop_asa_chart.axis(l) range(45, 75)
' verstical axis title
proj_epop_asa_chart.addtext(l) percent 'Ratio of employment to population
proj_epop_chart.addtext(l) percent 'Ratio of employment to population

' RU charts
' verstical axis title
proj_ru_asa_chart.addtext(l) percent
proj_ru_chart.addtext(l) percent

' At this point, the 6 charts look the way Beth needs them for PDF (i.e. fully formatted EXCEPT for the titles; SAVE them as PDFs here
if %pdf = "Y" then
	logmsg Saving PDF charts for publication to %pdf_location
	for %chrt proj_lfpr_asa_chart proj_lfpr_chart proj_epop_chart proj_epop_asa_chart proj_ru_chart proj_ru_asa_chart
		%loc = %pdf_location + %chrt + ".pdf"
		{%chrt}.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
		logmsg %chrt ...
	next
endif

'chart titles
%title = "Figure 8. \rHistorical and Projected Labor Force Participation Rates \r(Age-Sex-Adjusted, " + %base + " pop.) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
proj_lfpr_asa_chart.addtext(font(+b), t) %title
%title = "Figure 7. \rHistorical and Projected Labor Force Participation Rates \r(unadjusted) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
proj_lfpr_chart.addtext(font(+b), t) %title
%title = "Figure 1. \rHistorical and Projected Ratio of Employment to Population \r(unadjusted) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"	
proj_epop_chart.addtext(font(+b), t) %title
%title = "Figure 2. \rHistorical and Projected Ratio of Employment to Population  \r(Age-Sex-Adjusted, " + %base + " pop.) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"		
proj_epop_asa_chart.addtext(font(+b), t) %title
%title = "Figure 5X. \rProjected Unemployment Rates \r(unadjusted) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"	
proj_ru_chart.addtext(font(+b), t) %title
%title = "Figure 5. \rProjected Unemployment Rates  \r(Age-Sex-Adjusted, " + %base + " pop.) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"		
proj_ru_asa_chart.addtext(font(+b), t) %title

wfselect {%output_file}
pageselect {%page_alt2}_a
smpl @all 

'move the charts to "tables" page
pageselect tables
copy  {%page_alt2}_a\proj*chart tables\ 

logmsg Annual charts done.
logmsg

' ***** QUARTERLY charts and tables
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all 

logmsg Loading quarterly data

'Load quarterly LFPR data for projected charts 
wfopen %abank_alt2
for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 16o_asa
   		copy {%abnk}::q\p{%s}{%a} {%output_file}::{%page_alt2}_q\*
	next
next
copy {%abnk}::q\p16o_asa {%output_file}::{%page_alt2}_q\*
copy {%abnk}::q\p16o {%output_file}::{%page_alt2}_q\*
for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
		copy {%abnk}::q\e{%s}{%a} {%output_file}::{%page_alt2}_q\*
		copy {%abnk}::q\r{%s}{%a} {%output_file}::{%page_alt2}_q\*
	next
next
for %ser p16o_asa p16o e16o rum ruf ru rum_asa ruf_asa ru_asa
	copy {%abnk}::q\{%ser} {%output_file}::{%page_alt2}_q\*
next

wfclose %abnk

' load population
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all

wfopen %dbank_alt2
for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
   		copy {%dbnk}::q\n{%s}{%a} {%output_file}::{%page_alt2}_q\*
	next
next
copy {%dbnk}::q\n16o {%output_file}::{%page_alt2}_q\*
wfclose %dbnk


' load MSshare and Edscore
' we do not use them for any computation, but might need to see them when writing the narrative 
logmsg Loading MSshare and Edscore data

' Current TR
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all

wfopen %lfpr_proj_55100
	copy lfpr_proj_55100::q\msshare* {%output_file}::{%page_alt2}_q\msshare*_tr{!try}  
	copy lfpr_proj_55100::q\edscore* {%output_file}::{%page_alt2}_q\edscore*_tr{!try} 
wfclose %lfpr_proj_55100

' Prior TR
wfselect {%output_file}
pageselect {%page_alt2pr}_q
smpl @all

wfopen %lfpr_proj_55100pr
	copy lfpr_proj_55100::q\msshare* {%output_file}::{%page_alt2pr}_q\msshare*_tr{!trp}  
	copy lfpr_proj_55100::q\edscore* {%output_file}::{%page_alt2pr}_q\edscore*_tr{!trp} 
wfclose %lfpr_proj_55100pr

' Create charts that compare MSshare and Edscore for TR current vs TR prior
' must be done in page that is quarterly
logmsg Creating comparisons for MSshare and Edscore

wfselect {%output_file}
pageselect {%page_alt2}_q
smpl 1990q1 @last

' Charts for SYOA
for %s m f
	for %a {%agesy}
		' edscore
		series diff_edscore{%s}{%a} = edscore{%s}{%a}_tr{!try} - {%page_alt2pr}_q\edscore{%s}{%a}_tr{!trp} 
		group edscr_{%s}{%a} edscore{%s}{%a}_tr{!try} {%page_alt2pr}_q\edscore{%s}{%a}_tr{!trp} 
		freeze(g_edscore{%s}{%a}) edscr_{%s}{%a}.line
		' MSshare
		series diff_msshare_{%s}{%a} = msshare_{%s}{%a}_tr{!try} - {%page_alt2pr}_q\msshare_{%s}{%a}_tr{!trp} 
		group msshr_{%s}{%a} msshare_{%s}{%a}_tr{!try} {%page_alt2pr}_q\msshare_{%s}{%a}_tr{!trp} 
		freeze(g_msshare{%s}{%a}) msshr_{%s}{%a}.line
	next
next

' Charts for groups, showing difference from prior TR
%l = @wlookup("diff_edscorem*")
group edscorem_diff {%l}
freeze(g_edscorem) edscorem_diff.line
g_edscorem.datelabel format("YYYY")

%l = @wlookup("diff_edscoref*")
group edscoref_diff {%l}
freeze(g_edscoref) edscoref_diff.line
g_edscoref.datelabel format("YYYY")

%l = @wlookup("diff_msshare_m*")
group mssharem_diff {%l}
freeze(g_mssharem) mssharem_diff.line
g_mssharem.datelabel format("YYYY")

%l = @wlookup("diff_msshare_f*")
group mssharef_diff {%l}
freeze(g_mssharef) mssharef_diff.line
g_mssharef.datelabel format("YYYY")

logmsg Done with comparisons for MSshare and Edscore
logmsg

' Compute e/pop ratios
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all
for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4} 7074 75o 16o
  		series ep{%s}{%a} = e{%s}{%a}/n{%s}{%a}
	next
next
series ep16o = e16o/n16o

' *** In the future -- ADD here computation of the average Edscore and Average MSshare for 5559, 6064, 6569, 7074, both M and F. Need to load SYOA pop series for this.

' Create ASA e/pop ratios
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all

%base1=%base+"q1"
%base2=%base+"q2"
%base3=%base+"q3"
%base4=%base+"q4"

series epf16o_asa = 0 'pX16o_asa_g are Gerenerated here; pX16o_asa (no _g) are loaded from a-bank for comparison
series epm16o_asa = 0
series ep16o_asa = 0

for %a {%age1} {%age2} 5559 6064 6569 7074 75o
	epf16o_asa = 	epf16o_asa + _
						0.25*epf{%a}*@elem(nf{%a}, %base1)/@elem(nf16o, %base1) + 0.25*epf{%a}*@elem(nf{%a}, %base2)/@elem(nf16o, %base2) + 0.25*epf{%a}*@elem(nf{%a}, %base3)/@elem(nf16o, %base3) + 0.25*epf{%a}*@elem(nf{%a}, %base4)/@elem(nf16o, %base4)
	epm16o_asa = epm16o_asa + _
						0.25*epm{%a}*@elem(nm{%a}, %base1)/@elem(nm16o, %base1) + 0.25*epm{%a}*@elem(nm{%a}, %base2)/@elem(nm16o, %base2) + 0.25*epm{%a}*@elem(nm{%a}, %base3)/@elem(nm16o, %base3) + 0.25*epm{%a}*@elem(nm{%a}, %base4)/@elem(nm16o, %base4)
	ep16o_asa = ep16o_asa + _
						0.25*epf{%a}*@elem(nf{%a}, %base1)/@elem(n16o, %base1) + 0.25*epf{%a}*@elem(nf{%a}, %base2)/@elem(n16o, %base2) + 0.25*epf{%a}*@elem(nf{%a}, %base3)/@elem(n16o, %base3) + 0.25*epf{%a}*@elem(nf{%a}, %base4)/@elem(n16o, %base4) + _
						0.25*epm{%a}*@elem(nm{%a}, %base1)/@elem(n16o, %base1) + 0.25*epm{%a}*@elem(nm{%a}, %base2)/@elem(n16o, %base2) + 0.25*epm{%a}*@elem(nm{%a}, %base3)/@elem(n16o, %base3) + 0.25*epm{%a}*@elem(nm{%a}, %base4)/@elem(n16o, %base4)
next


'*** get historical ASA lfprs for years prior to 2001

copy q\*_g {%page_alt2}_q\  	'this copies 3 series -- pf16o_asa_g, pm16o_asa_g, and p16o_asa_g -- from page q to page {%page_alt2}_q (like TR212_q)

wfselect {%output_file}
pageselect {%page_alt2}_q
'assign value from *_asa_g to already existing *_asa for 1981-2000 period.
smpl @first 2000q4
pf16o_asa = pf16o_asa_g
pm16o_asa = pm16o_asa_g
p16o_asa = p16o_asa_g

smpl @all
'done loading/updating historical ASA values

logmsg Done loading quarterly data
logmsg

' **** Re-scale LFPRs and E/POP ratios to display as 63.31 percent instead of 0.6331
logmsg Re-scaling annual values...
	pageselect {%page_alt2}_q
	smpl @all
	for %s {%sex}
		for %a {%age1} {%age2} {%age3} {%age4} 7074 75o
  			ep{%s}{%a} = ep{%s}{%a} * 100		' e/pop
		next
		for %a {%age1} {%age2} {%age3} {%age4}
  			p{%s}{%a} = p{%s}{%a} * 100			' LFPRs
		next
	next
	ep16o = ep16o * 100
	p16o = p16o * 100

	for %s pf16o pm16o p16o
		{%s}_asa = {%s}_asa * 100		' LFPRs ASA
		e{%s}_asa = e{%s}_asa * 100	' e/pop ASA
	next
 
 logmsg ... done.
 logmsg

' *** Qarterly projection values -- tables (at one point we planned to make these available for download)
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl !table_start !TRyr+296 'period to be displyed in projections tables
' LFPRs
group females_q {%list_f}
freeze(projq_f) females_q.sheet

group males_q {%list_m}
freeze(projq_m) males_q.sheet

group all16o_q {%list_all}
freeze(projq_all) all16o_q.sheet

' E/POP
group females_qe {%list_fe}
freeze(projq_fe) females_qe.sheet

group males_qe {%list_me}
freeze(projq_me) males_qe.sheet

group all16o_qe {%list_alle}
freeze(projq_alle) all16o_qe.sheet

'format the projections tables
projq_f.title Civilian Labor Force Participation Rates, Women (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
projq_m.title Civilian Labor Force Participation Rates, Men (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
projq_all.title Civilian Labor Force Participation Rates, historical and projected ({!TRyr} Trustees Report, intermediate assumptions)

projq_fe.title Ratio of Employment to Population, Women (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
projq_me.title Ratio of Employment to Population, Men (by age group), historical and projected ({!TRyr} Trustees Report, intermediate assumptions)
projq_alle.title Ratio of Employment to Population, historical and projected ({!TRyr} Trustees Report, intermediate assumptions)

!proj_row=4*(!Tryr-!table_start)+5+1 'row of the tables where the projected data starts
'!proj_row=4*(!Tryr-!table_start)+5+1 + 2 'row of the tables where the projected data starts; SPECIAL FOR TR21 -- need to move "projected" row down two rows to account for the fact that proj period starts in 2021Q2 instead of the normal 2020Q4

for %tab projq_f projq_m projq_fe projq_me
	{%tab}.insertrow(1) 3
	{%tab}.insertrow(6) 1
	{%tab}.insertrow(!proj_row) 1
	{%tab}(2,2)=@str(!TRyr)+" Trustees Report (intermediate assumptions, percent)"
	{%tab}(3,1)="Age Group"
	{%tab}(3,2)="16-17"
	{%tab}(3,3)="18-19"
	{%tab}(3,4)="20-24"
	{%tab}(3,5)="25-29"
	{%tab}(3,6)="30-34"
	{%tab}(3,7)="35-39"
	{%tab}(3,8)="40-44"
	{%tab}(3,9)="45-49"
	{%tab}(3,10)="50-54"
	{%tab}(3,11)="55-59"
	{%tab}(3,12)="60-64"
	{%tab}(3,13)="65-69"
	{%tab}(3,14)="70+"
	{%tab}(3,15)="16+"
	{%tab}(3,16)="16+ Age-Adj."
	{%tab}(6,2)="Historical"
	{%tab}(!proj_row,2)="Projected"
	
	{%tab}.setformat(@all) f.2
	{%tab}.setjust(@all) center
	{%tab}.setfont(B2) +b
	
	!cl=2
	for %c B C D E F G H I J K L M N O P
		{%tab}(4,!cl) = " "
		!cl=!cl+1
	next
	{%tab}(4,16)="(" + %base + " pop.)"
next

projq_f(1,2)="Civilian Labor Force Participation Rates, Women (by age group), historical and projected"
projq_m(1,2)="Civilian Labor Force Participation Rates, Men (by age group), historical and projected"
projq_f.setfont(B1) +b
projq_m.setfont(B1) +b

projq_fe(1,2)="Ratio of Employment to Population, Women (by age group), historical and projected"
projq_me(1,2)="Ratio of Employment to Population, Men (by age group), historical and projected"
projq_fe.setfont(B1) +b
projq_me.setfont(B1) +b

'tables for all16o
for %tab projq_all projq_alle
	{%tab}.insertrow(1) 3
	{%tab}.insertrow(6) 1
	{%tab}.insertrow(!proj_row) 1
	{%tab}(6,2)="Historical"
	{%tab}(!proj_row,2)="Projected"
	{%tab}(2,1)=@str(!TRyr)+" Trustees Report (intermediate assumptions, percent)"
	{%tab}(3,2)="16+"
	{%tab}(4,2)=" "
	{%tab}(3,3)="16+ Age-Sex-Adj."
	{%tab}(4,3)="(" + %base + " pop.)"

	{%tab}.setformat(@all) f.2
	{%tab}.setjust(@all) center
	{%tab}.setfont(A1) +b
	{%tab}.setfont(A2) +b
next
projq_all(1,1)="Civilian Labor Force Participation Rates, historical and projected"
projq_alle(1,1)="Ratio of Employment to Population, historical and projected"

'save quarterly projection table as CSV files to be suitable for use in Excel
if %csv = "Y" then
	for %name projq_f projq_m projq_all
		%csvfile = %csv_location + %name + ".csv"
		{%name}.save(t=csv) %csvfile
	next
endif

logmsg Quareterly projections tables done
logmsg

' ***Time Series projections charts -- Quarterly
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl 1980q1 !TRyr+296 'period to be displyed on the time-series charts

group projq_aggr pm16o pf16o p16o
freeze(projq_gross) projq_aggr.line

group projq_asa pm16o_asa pf16o_asa p16o_asa
freeze(projq_asa_chart) projq_asa.line

'format the charts
'4-digit year
projq_asa_chart.datelabel format("YYYY")
projq_gross.datelabel format("YYYY")
'range on horizontal axis
'tick marks every 10 years
projq_asa_chart.axis -minor
projq_gross.axis -minor
projq_asa_chart.datelabel interval(year, 10, 1/1/1900)
projq_gross.datelabel interval(year, 10, 1/1/1900)
'verstical axis
projq_asa_chart.axis(l) format(leadzero)
projq_gross.axis(l) format(leadzero)
projq_asa_chart.axis(l) range(48, 80)
projq_gross.axis(l) range(48, 80)
' vertical line dividing historical and projected (dashed line placed at !last_hist_yr Q3) -- SPECIAL FOR TR21: might ned to manually change the date where this line is
projq_asa_chart.draw(line, bottom, pattern(dash1)) {!last_hist_yr}:3
projq_gross.draw(line, bottom, pattern(dash1)) {!last_hist_yr}:3
'legend
projq_asa_chart.setelem(3) legend(all 16+)
projq_asa_chart.setelem(2) legend(women 16+)
projq_asa_chart.setelem(1) legend(men 16+)
projq_gross.setelem(3) legend(all 16+)
projq_gross.setelem(2) legend(women 16+)
projq_gross.setelem(1) legend(men 16+)
'chart title
%title = "Figure 1. \rProjected Labor Force Participation rates \r(Age-Sex-Adjusted, " + %base + " pop) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
projq_asa_chart.addtext(font(+b), t) %title
%title = "Figure 2. \rProjected Labor Force Participation Rates \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
projq_gross.addtext(font(+b), t) %title

smpl @all

logmsg Quareterly projections charts done
logmsg

' *** BAR CHARTS -- these are the charts that show changes in LFPRs by age group and then contribution of each regression factor to changes in LFPR in SR and LR

' ** Charts showing change over time (SR and LR)
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all

'compute differences for SR and LR for (1) females and (2) males
'define strings for the period we use to compute changes
%start = @str(!TRyr-1)+"Q4" 	' standard form
'%start = "2021Q2" 		' SPECIAL FOR TR21 -- undid for TR22
%SRend = @str(!TRyr+9)+"Q4"
%LRend = @str(!TRyr+74)+"Q4"

' ** Females

' LFPRs change
vector(14) f_sr
vector(14) f_lr
' E/pop change
vector(14) fe_sr
vector(14) fe_lr
' E/pop level
vector(14) fel_start		' value in the first projection quarter, at %start
vector(14) fel_sr			' value at the end of SR, at %SRend
vector(14) fel_lr			' value at the end of LR, at %LRend
' RUs change
vector(14) fru_sr
vector(14) fru_lr
' RUs level
vector(14) frul_start		' value in the first projection quarter, at %start
vector(14) frul_sr			' value at the end of SR, at %SRend

' LFPRs
!v=1
for %ser pf1617 pf1819 pf2024 pf2529 pf3034 pf3539 pf4044 pf4549 pf5054 pf5559 pf6064 pf6569 pf70o pf16o_asa 
	f_sr(!v) = @elem({%ser}, %SRend) - @elem({%ser}, %start)
	f_lr(!v) = @elem({%ser}, %LRend) - @elem({%ser}, %SRend)
	!v=!v+1
next
' E/pop
!v=1
for %ser epf1617 epf1819 epf2024 epf2529 epf3034 epf3539 epf4044 epf4549 epf5054 epf5559 epf6064 epf6569 epf70o epf16o_asa 
	' change
	fe_sr(!v) = @elem({%ser}, %SRend) - @elem({%ser}, %start)
	fe_lr(!v) = @elem({%ser}, %LRend) - @elem({%ser}, %SRend)
	' level
	fel_start(!v) = @elem({%ser}, %start)
	fel_sr(!v) = @elem({%ser}, %SRend)
	fel_lr(!v) = @elem({%ser}, %LRend)
	
	!v=!v+1
next
' RUs
!v=1
for %ser rf1617 rf1819 rf2024 rf2529 rf3034 rf3539 rf4044 rf4549 rf5054 rf5559 rf6064 rf6569 rf70o ruf_asa 
	' change
	fru_sr(!v) = @elem({%ser}, %SRend) - @elem({%ser}, %start)
	fru_lr(!v) = @elem({%ser}, %LRend) - @elem({%ser}, %SRend)
	' level
	frul_start(!v) = @elem({%ser}, %start)
	frul_sr(!v) = @elem({%ser}, %SRend)

	!v=!v+1
next

'legend entries -- these will be used in MANY other charts
%SRlegend = @str(!TRyr-1)+"Q4 to "+@str(!TRyr+9)+"Q4" 	'standard form
%LRlegend = @str(!TRyr+9)+"Q4 to "+@str(!TRyr+74)+"Q4"


'LFPRs
matrix(14,2) females 'matrix that holds values (change in LFPRs) for females to be plotted
colplace(females, f_sr, 1)
colplace(females, f_lr, 2)

freeze(f_chg) females.bar(rotate)		' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
f_chg.setelem(1) legend(%SRlegend)
f_chg.setelem(2) legend(%LRlegend)
f_chg.displayname Change in LFPRs -- Women
%title = "Figure 4. \rProjected Change in Labor Force Participation Rates \rWomen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
f_chg.addtext(font(+b), t) %title
f_chg.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
f_chg.addtext(l) age groups
f_chg.addtext(bl) "* age adjusted"
f_chg.addtext(b) percentage points
f_chg.axis(b) zeroline 
'f_chg.axis(l) range(-0.02, 0.08)


' E/POP -- change
matrix(14,2) females_e 'matrix that holds values (change in EPOP) for females to be plotted
colplace(females_e, fe_sr, 1)
colplace(females_e, fe_lr, 2)

freeze(fe_chg) females_e.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
fe_chg.displayname Change in Emp/Pop -- Women
fe_chg.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
fe_chg.addtext(l) age groups
fe_chg.addtext(bl) "* age adjusted"
fe_chg.addtext(b) percentage points
fe_chg.setelem(1) legend(%SRlegend)
fe_chg.setelem(2) legend(%LRlegend)
fe_chg.axis(b) zeroline

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for fe_chg to %pdf_location 
	%loc = %pdf_location + "fe_chg.pdf"
	fe_chg.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg
%title = "Figure 4. \rProjected Change in Ratio of Employment to Population \rWomen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
fe_chg.addtext(font(+b), t) %title

' E/POP -- level
matrix(14,3) females_elvl 'matrix that holds values (LEVEL of EPOP) for females to be plotted
colplace(females_elvl, fel_start, 1)
colplace(females_elvl, fel_sr, 2)
colplace(females_elvl, fel_lr, 3)

freeze(fe_lvl) females_elvl.bar
fe_lvl.displayname Emp/Pop -- Women
fe_lvl.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
fe_lvl.addtext(l) age groups
fe_lvl.addtext(br) "* age adjusted"
fe_lvl.addtext(l) percent
fe_lvl.setelem(1) legend(%start)
fe_lvl.setelem(2) legend(%SRend)
fe_lvl.setelem(3) legend(%LRend)
fe_lvl.axis(l) range(0, 100)

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for fe_lvl to %pdf_location 
	%loc = %pdf_location + "fe_lvl.pdf"
	fe_lvl.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg
%title = "Figure 4. \rProjected Ratio of Employment to Population \rWomen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
fe_lvl.addtext(font(+b), t) %title


'RUs --change
matrix(14,2) females_ru 'matrix that holds values (change in Rus) for females to be plotted
colplace(females_ru, fru_sr, 1)
colplace(females_ru, fru_lr, 2)

freeze(fru_chg) females_ru.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
fru_chg.setelem(1) legend(%SRlegend)
fru_chg.setelem(2) legend(%LRlegend)
fru_chg.displayname Change in RUs -- Women
%title = "Figure ??. \rProjected Change in Unemployment Rates \rWomen (by age group) \r" + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
fru_chg.addtext(font(+b), t) %title
fru_chg.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
fru_chg.addtext(l) age groups
fru_chg.addtext(bl) "* age adjusted"
fru_chg.addtext(b) percentage points
fru_chg.axis(b) zeroline

'RUs -- level
matrix(14,2) females_rulvl 'matrix that holds values of RUs for females to be plotted
colplace(females_rulvl, frul_start, 1)
colplace(females_rulvl, frul_sr, 2)

freeze(fru_lvl) females_rulvl.bar
fru_lvl.displayname RUs -- Women
fru_lvl.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
fru_lvl.addtext(l) age groups
fru_lvl.addtext(br) "* age adjusted"
fru_lvl.addtext(l) percent
fru_lvl.setelem(1) legend(%start)
fru_lvl.setelem(2) legend(%SRend)
fru_lvl.axis(l) range(0, 17)

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for fru_lvl to %pdf_location 
	%loc = %pdf_location + "fru_lvl.pdf"
	fru_lvl.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg
%title = "Figure 4. \rProjected Unemployment Rates \rWomen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
fru_lvl.addtext(font(+b), t) %title

'RUs -- SR only
freeze(fru_chg_sr) fru_sr.bar(rotate)

fru_chg_sr.displayname Change in RUs -- Women, SRperiod
%title = "Figure ??. \rProjected Change in Unemployment Rates \rWomen (by age group), " + %SRlegend + "\r" + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
fru_chg_sr.addtext(font(+b), t) %title
fru_chg_sr.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
fru_chg_sr.addtext(l) age groups
fru_chg_sr.addtext(bl) "* age adjusted"
fru_chg_sr.addtext(b) percentage points
fru_chg_sr.axis(b) zeroline

logmsg Bar charts (women) done

' ** Males

' LFPRs
vector(14) m_sr
vector(14) m_lr
' E/pop
vector(14) me_sr
vector(14) me_lr
' E/pop level
vector(14) mel_start		' value in the first projection quarter, at %start
vector(14) mel_sr			' value at the end of SR, at %SRend
vector(14) mel_lr			' value at the end of LR, at %LRend
' RUs
vector(14) mru_sr
vector(14) mru_lr
' RUs level
vector(14) mrul_start		' value in the first projection quarter, at %start
vector(14) mrul_sr			' value at the end of SR, at %SRend

' LFPRs
!v=1
for %ser pm1617 pm1819 pm2024 pm2529 pm3034 pm3539 pm4044 pm4549 pm5054 pm5559 pm6064 pm6569 pm70o pm16o_asa
	m_sr(!v) = @elem({%ser}, %SRend) - @elem({%ser}, %start)
	m_lr(!v) = @elem({%ser}, %LRend) - @elem({%ser}, %SRend)
	!v=!v+1
next
' E/pop
!v=1
for %ser epm1617 epm1819 epm2024 epm2529 epm3034 epm3539 epm4044 epm4549 epm5054 epm5559 epm6064 epm6569 epm70o epm16o_asa
	'change
	me_sr(!v) = @elem({%ser}, %SRend) - @elem({%ser}, %start)
	me_lr(!v) = @elem({%ser}, %LRend) - @elem({%ser}, %SRend)
	' level
	mel_start(!v) = @elem({%ser}, %start)
	mel_sr(!v) = @elem({%ser}, %SRend)
	mel_lr(!v) = @elem({%ser}, %LRend)

	!v=!v+1
next
' RUs
!v=1
for %ser rm1617 rm1819 rm2024 rm2529 rm3034 rm3539 rm4044 rm4549 rm5054 rm5559 rm6064 rm6569 rm70o rum_asa 
	' change
	mru_sr(!v) = @elem({%ser}, %SRend) - @elem({%ser}, %start)
	mru_lr(!v) = @elem({%ser}, %LRend) - @elem({%ser}, %SRend)
	' level
	mrul_start(!v) = @elem({%ser}, %start)
	mrul_sr(!v) = @elem({%ser}, %SRend)

	!v=!v+1
next

'LFPRs
matrix(14,2) males 'matrix that holds values (change in LFPRs) for males to be plotted
colplace(males, m_sr, 1)
colplace(males, m_lr, 2)
freeze(m_chg) males.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
m_chg.setelem(1) legend(%SRlegend)
m_chg.setelem(2) legend(%LRlegend)
m_chg.displayname Change in LFPRs -- Men
%title = "Figure 3. \rProjected Change in Labor Force Participation Rates \rMen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
m_chg.addtext(font(+b), t)  %title
m_chg.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
m_chg.addtext(l) age groups
m_chg.addtext(bl) "* age adjusted"
m_chg.addtext(b) percentage points
m_chg.axis(b) zeroline
'm_chg.axis(l) range(-0.02, 0.08)

'E/POP
matrix(14,2) males_e 'matrix that holds values (change in EPOP) for males to be plotted
colplace(males_e, me_sr, 1)
colplace(males_e, me_lr, 2)
freeze(me_chg) males_e.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
me_chg.setelem(1) legend(%SRlegend)
me_chg.setelem(2) legend(%LRlegend)
me_chg.displayname Change in Emp/Pop -- Men
me_chg.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
me_chg.addtext(l) age groups
me_chg.addtext(bl) "* age adjusted"
me_chg.addtext(b) percentage points
me_chg.axis(b) zeroline

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for me_chg to %pdf_location 
	%loc = %pdf_location + "me_chg.pdf"
	me_chg.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg
%title = "Figure 3. \rProjected Change in Ratio of Employment to Population \rMen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
me_chg.addtext(font(+b), t)  %title

' E/POP -- level
matrix(14,3) males_elvl 'matrix that holds values (LEVEL of EPOP) for males to be plotted
colplace(males_elvl, mel_start, 1)
colplace(males_elvl, mel_sr, 2)
colplace(males_elvl, mel_lr, 3)

freeze(me_lvl) males_elvl.bar
me_lvl.displayname Emp/Pop -- Men
me_lvl.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
me_lvl.addtext(l) age groups
me_lvl.addtext(br) "* age adjusted"
me_lvl.addtext(l) percent
me_lvl.setelem(1) legend(%start)
me_lvl.setelem(2) legend(%SRend)
me_lvl.setelem(3) legend(%LRend)
me_lvl.axis(l) range(0, 100)

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for me_lvl to %pdf_location 
	%loc = %pdf_location + "me_lvl.pdf"
	me_lvl.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg
%title = "Figure 4. \rProjected Ratio of Employment to Population \rMen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
me_lvl.addtext(font(+b), t) %title

'RUs
matrix(14,2) males_ru 'matrix that holds values (change in RUs) for females to be plotted
colplace(males_ru, mru_sr, 1)
colplace(males_ru, mru_lr, 2)

freeze(mru_chg) males_ru.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
mru_chg.setelem(1) legend(%SRlegend)
mru_chg.setelem(2) legend(%LRlegend)
mru_chg.displayname Change in RUs -- Men
%title = "Figure ??. \rProjected Change in Unemployment Rates \rMen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
mru_chg.addtext(font(+b), t) %title
mru_chg.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
mru_chg.addtext(l) age groups
mru_chg.addtext(bl) "* age adjusted"
mru_chg.addtext(b) percentage points
mru_chg.axis(b) zeroline

'RUs -- level
matrix(14,2) males_rulvl 'matrix that holds values of RUs for males to be plotted
colplace(males_rulvl, mrul_start, 1)
colplace(males_rulvl, mrul_sr, 2)

freeze(mru_lvl) males_rulvl.bar
mru_lvl.displayname RUs -- Men
mru_lvl.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
mru_lvl.addtext(l) age groups
mru_lvl.addtext(br) "* age adjusted"
mru_lvl.addtext(l) percent
mru_lvl.setelem(1) legend(%start)
mru_lvl.setelem(2) legend(%SRend)
mru_lvl.axis(l) range(0, 17)

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for mru_lvl to %pdf_location 
	%loc = %pdf_location + "mru_lvl.pdf"
	mru_lvl.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg
%title = "Figure 4. \rProjected Unemployment Rates \rMen (by age group) \r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
mru_lvl.addtext(font(+b), t) %title

'RUs -- SR only
freeze(mru_chg_sr) mru_sr.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars

mru_chg_sr.displayname Change in RUs -- Men, SRperiod
%title = "Figure ??. \rProjected Change in Unemployment Rates \rMen (by age group), " + %SRlegend + "\r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
mru_chg_sr.addtext(font(+b), t) %title
mru_chg_sr.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
mru_chg_sr.addtext(l) age groups
mru_chg_sr.addtext(bl) "* age adjusted"
mru_chg_sr.addtext(b) percentage points
mru_chg_sr.axis(b) zeroline


'RUs -- SR only COMBINED
matrix(14,2) all_ru_sr 'matrix that holds values (change in RUs) for males and females, SR only,  to be plotted
colplace(all_ru_sr, mru_sr, 1)
colplace(all_ru_sr, fru_sr, 2)

freeze(ru_chg_sr) all_ru_sr.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
ru_chg_sr.setelem(1) legend("Men")
ru_chg_sr.setelem(2) legend("Women")
ru_chg_sr.displayname Change in RUs -- Men and Women, SR
ru_chg_sr.setobslabel 16-17 18-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70+ 16+*
ru_chg_sr.addtext(l) age groups
ru_chg_sr.addtext(bl) "* age adjusted"
ru_chg_sr.addtext(b) percentage points
ru_chg_sr.axis(b) zeroline

' Save the chart to PDF before adding title (format required by Beth to include in paper)
if %pdf = "Y" then
	logmsg Saving PDF version for publication for ru_chg_sr to %pdf_location 
	%loc = %pdf_location + "ru_chg_sr.pdf"
	ru_chg_sr.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
endif
logmsg

%title = "Figure 6. \rProjected Change in Unemployment Rates \rby age group, " + %SRlegend + "\r"+@str(!TRyr) + " Trustees Report (intermediate assumptions; " + %base + " population used for age adjustment)"
ru_chg_sr.addtext(font(+b), t) %title


logmsg Bar charts (men) done

'**** copy tables and charts to the "tables" page
wfselect {%output_file}
pageselect {%page_alt2}_q
smpl @all

copy {%page_alt2}_q\projq_all tables\
copy {%page_alt2}_q\projq_f tables\
copy {%page_alt2}_q\projq_m tables\

copy {%page_alt2}_q\projq_alle tables\
copy {%page_alt2}_q\projq_fe tables\
copy {%page_alt2}_q\projq_me tables\

copy {%page_alt2}_q\projq_gross tables\
copy {%page_alt2}_q\projq_asa_chart tables\

copy {%page_alt2}_q\f_chg tables\
copy {%page_alt2}_q\m_chg tables\

copy {%page_alt2}_q\fe_chg tables\
copy {%page_alt2}_q\me_chg tables\
copy {%page_alt2}_q\fe_lvl tables\
copy {%page_alt2}_q\me_lvl tables\

copy {%page_alt2}_q\fru_chg tables\
copy {%page_alt2}_q\mru_chg tables\
copy {%page_alt2}_q\fru_lvl tables\
copy {%page_alt2}_q\mru_lvl tables\

copy {%page_alt2}_q\fru_chg_sr tables\
copy {%page_alt2}_q\mru_chg_sr tables\

copy {%page_alt2}_q\ru_chg_sr tables\

copy {%page_alt2}_q\g_* tables\


'go back to "tables" page to create more tables and charts
wfselect {%output_file}
pageselect tables
smpl @all


' ** Charts showing *decomposition* of changes in LFPRs (contribution of each regression factor)
vector(12) f_sr_u 	'female 16+, short-run, unadjusted LFPRs
vector(12) f_lr_u 	'female 16+, long-run, unadjusted LFPRs
vector(12) m_sr_u 	' male, 16+, short-run, unadjusted
vector(12) m_lr_u	' male, 16+, long-run, unadjusted
vector(13) all_sr_u	' all 16+, short-run, unadjusted LFPRs
vector(13) all_lr_u	' all 16+, long-run, unadjusted LFPRs
vector(9) f_sr_a 	' female 16+, short-run, adjusted LFPRs
vector(9) f_lr_a		' female 16+, long-run, adjusted LFPRs
vector(9) m_sr_a 	' male 16+, short-run, adjusted LFPRs
vector(9) m_lr_a 	' male 16+, long-run, adjusted LFPRs
vector(9) all_sr_a 	' all16+, short-run, adjusted LFPRs
vector(9) all_lr_a 	' all 16+, long-run, adjusted LFPRs

%table_s_a="table_TR"+@str(!TRyr)+"_SR_A"
%table_l_a="table_TR"+@str(!TRyr)+"_LR_A"
%table_s_u="table_TR"+@str(!TRyr)+"_SR_U"
%table_l_u="table_TR"+@str(!TRyr)+"_LR_U"

'adjusted LFPR tables
for !v=1 to 6
	!col=!v+2
	f_sr_a(!v) = @val({%table_s_a}(26,!col))
	m_sr_a(!v) = @val({%table_s_a}(12,!col))
	all_sr_a(!v) = @val({%table_s_a}(11,!col))
	f_lr_a(!v) = @val({%table_l_a}(26,!col))
	m_lr_a(!v) = @val({%table_l_a}(12,!col))
	all_lr_a(!v) = @val({%table_l_a}(11,!col))
next
f_sr_a(7) = @val({%table_s_a}(26,11))
m_sr_a(7) = @val({%table_s_a}(12,11))
all_sr_a(7) = @val({%table_s_a}(11,11))
f_lr_a(7) = @val({%table_l_a}(26,11))
m_lr_a(7) = @val({%table_l_a}(12,11))
all_lr_a(7) = @val({%table_l_a}(11,11))

f_sr_a(8) = @val({%table_s_a}(26,13))
m_sr_a(8) = @val({%table_s_a}(12,13))
all_sr_a(8) = @val({%table_s_a}(11,13))
f_lr_a(8) = @val({%table_l_a}(26,13))
m_lr_a(8) = @val({%table_l_a}(12,13))
all_lr_a(8) = @val({%table_l_a}(11,13))

f_sr_a(9) = @val({%table_s_a}(26,14)) -  @val({%table_s_a}(26,2)) 
m_sr_a(9) = @val({%table_s_a}(12,14)) - @val({%table_s_a}(12,2))
all_sr_a(9) = @val({%table_s_a}(11,14)) - @val({%table_s_a}(11,2))
f_lr_a(9) = @val({%table_l_a}(26,14)) - @val({%table_l_a}(26,2))
m_lr_a(9) = @val({%table_l_a}(12,14)) - @val({%table_l_a}(12,2))
all_lr_a(9) = @val({%table_l_a}(11,14)) - @val({%table_l_a}(11,2))

matrix(9,2) f_adj 'matrix that holds values for LFPR decomp for females, adjusted LFPRs
colplace(f_adj, f_sr_a, 1)
colplace(f_adj, f_lr_a, 2)
freeze(f_decomp_a) f_adj.bar

matrix(9,2) m_adj 
colplace(m_adj, m_sr_a, 1)
colplace(m_adj, m_lr_a, 2)
freeze(m_decomp_a) m_adj.bar

matrix(9,2) all_adj 
colplace(all_adj, all_sr_a, 1)
colplace(all_adj, all_lr_a, 2)
freeze(all_decomp_a) all_adj.bar

'unadjusted LFPR tables
f_sr_u(1) = @val({%table_s_u}(26,3))
m_sr_u(1) = @val({%table_s_u}(12,3))
all_sr_u(1) = @val({%table_s_u}(11,3))
f_lr_u(1) = @val({%table_l_u}(26,3))
m_lr_u(1) = @val({%table_l_u}(12,3))
all_lr_u(1) = @val({%table_l_u}(11,3))

all_sr_u(2) = @val({%table_s_u}(11,4))
all_lr_u(2) = @val({%table_l_u}(11,4))

for !v=2 to 3
	!col=!v+3
	!vall=!v+1
	f_sr_u(!v) = @val({%table_s_u}(26,!col))
	m_sr_u(!v) = @val({%table_s_u}(12,!col))
	all_sr_u(!vall) = @val({%table_s_u}(11,!col))
	f_lr_u(!v) = @val({%table_l_u}(26,!col))
	m_lr_u(!v) = @val({%table_l_u}(12,!col))
	all_lr_u(!vall) = @val({%table_l_u}(11,!col))
next

for !v=4 to 9
	!col=!v+4
	!vall=!v+1
	f_sr_u(!v) = @val({%table_s_u}(26,!col))
	m_sr_u(!v) = @val({%table_s_u}(12,!col))
	all_sr_u(!vall) = @val({%table_s_u}(11,!col))
	f_lr_u(!v) = @val({%table_l_u}(26,!col))
	m_lr_u(!v) = @val({%table_l_u}(12,!col))
	all_lr_u(!vall) = @val({%table_l_u}(11,!col))
next

f_sr_u(10) = @val({%table_s_u}(26,16))
m_sr_u(10) = @val({%table_s_u}(12,16))
all_sr_u(11) = @val({%table_s_u}(11,16))
f_lr_u(10) = @val({%table_l_u}(26,16))
m_lr_u(10) = @val({%table_l_u}(12,16))
all_lr_u(11) = @val({%table_l_u}(11,16))

f_sr_u(11) = @val({%table_s_u}(26,18))
m_sr_u(11) = @val({%table_s_u}(12,18))
all_sr_u(12) = @val({%table_s_u}(11,18))
f_lr_u(11) = @val({%table_l_u}(26,18))
m_lr_u(11) = @val({%table_l_u}(12,18))
all_lr_u(12) = @val({%table_l_u}(11,18))

f_sr_u(12) = @val({%table_s_u}(26,19)) - @val({%table_s_u}(26,2))
m_sr_u(12) = @val({%table_s_u}(12,19)) - @val({%table_s_u}(12,2))
all_sr_u(13) = @val({%table_s_u}(11,19)) - @val({%table_s_u}(11,2))
f_lr_u(12) = @val({%table_l_u}(26,19)) - @val({%table_l_u}(26,2))
m_lr_u(12) = @val({%table_l_u}(12,19)) - @val({%table_l_u}(12,2))
all_lr_u(13) = @val({%table_l_u}(11,19)) - @val({%table_l_u}(11,2))

'collect vectors into matrixes to be plotted
matrix(12,2) f_unadj 'matrix that holds values fpr LFPR decomp for females, unadjusted LFPRs
colplace(f_unadj, f_sr_u, 1)
colplace(f_unadj, f_lr_u, 2)
freeze(f_decomp_u) f_unadj.bar

matrix(12,2) m_unadj 
colplace(m_unadj, m_sr_u, 1)
colplace(m_unadj, m_lr_u, 2)
freeze(m_decomp_u) m_unadj.bar

matrix(13,2) all_unadj 
colplace(all_unadj, all_sr_u, 1)
colplace(all_unadj, all_lr_u, 2)
freeze(all_decomp_u) all_unadj.bar

' Create the *combined* charts -- containing unadjusted changes, with subtotals for ASA
matrix(13,2) f_comb 	' matrix that holds values fpr LFPR decomp for females, combined
matrix(13,2) m_comb	' same for males

' collect the values from vectors created above
for %s m f 
	for !c=1 to 2
		for !r=1 to 8 
			{%s}_comb(!r,!c) = {%s}_unadj(!r+3,!c)
		next
		{%s}_comb(9,!c) = {%s}_adj(9,!c)
		for !r=10 to 12
			{%s}_comb(!r,!c) = {%s}_unadj(!r-9,!c)
		next
		{%s}_comb(13,!c) = {%s}_unadj(12,!c)
	next
next

freeze(f_decomp) f_comb.bar(rotate) 	' option (rotate) creates the chart with horizontal bars; remove if want the chart with "normal" vertical bars
freeze(m_decomp) m_comb.bar(rotate)

' Create combined *extended* charts -- these have FOUR columns, they are needed is we want to use different color for totals
matrix(13,4) f_comb_ex = 0 	' matrix that holds values fpr LFPR decomp for females; filled with zeros
matrix(13,4) m_comb_ex = 0	' same for males

' collect the values from vectors created above
for %s m f 
	for !c=1 to 2
		for !r=1 to 8 
			{%s}_comb_ex(!r,!c+2) = {%s}_unadj(!r+3,!c)
		next
		{%s}_comb_ex(9,!c) = {%s}_adj(9,!c)
		for !r=10 to 12
			{%s}_comb_ex(!r,!c+2) = {%s}_unadj(!r-9,!c)
		next
		{%s}_comb_ex(13,!c) = {%s}_unadj(12,!c)
	next
next

freeze(f_decomp_ex) f_comb_ex.bar(rotate)
freeze(m_decomp_ex) m_comb_ex.bar(rotate)

'format all charts
' adjusted and Unadjusted
%factors = "Bus.Cycle* Disab.Prev Education Rep.Rate Earn.Test LaggedCohort LifeExpect. Addfactor Total"
for %s f m all
	{%s}_decomp_a.setobslabel "Bus. Cycle*" "Disab. Prev." "Education" "Rep. Rate" "Earn. Test" "Lagged Cohort" "Life Expect." "Addfactors" "Total"
	{%s}_decomp_u.setobslabel "Age" "Mar. Status" "Child Pres." "Bus. Cycle" "Disab. Prev." "Education" "Rep. Rate" "Earn. Test" "Lagged Cohort" "Life Expect." "Addfactors" "Total"
	{%s}_decomp_a.setelem(1) legend(%SRlegend)
	{%s}_decomp_a.setelem(2) legend(%LRlegend)
	{%s}_decomp_u.setelem(1) legend(%SRlegend)
	{%s}_decomp_u.setelem(2) legend(%LRlegend)
	{%s}_decomp_a.axis(l) range(-1, 2.5)
	{%s}_decomp_u.axis(l) range(-4, 2)
	{%s}_decomp_a.addtext(l) percentage points
	{%s}_decomp_u.addtext(l) percentage points
	%note = "* applies only in "+ %SRlegend + " period"
	{%s}_decomp_a.addtext(b) %note
	{%s}_decomp_a.axis(l) zeroline
	{%s}_decomp_u.axis(l) zeroline
next
all_decomp_u.setobslabel "Age" "Gender" "Mar. Status" "Child Pres." "Bus. Cycle" "Disab. Prev." "Education" "Rep. Rate" "Earn. Test" "Lagged Cohort" "Life Expect." "Addfactors" "Total"

' *Combined* charts
for %s f m
	{%s}_decomp.setobslabel "Business Cycle" "Disability Prevalence" "Education" "Replacement Rate" "Earnings Test" "Lagged Cohort" "Life Expectancy" "Addfactors" "TOTAL, ADJUSTED*" "Age" "Marital Status" "Child Presence" "TOTAL"
	{%s}_decomp.setelem(1) legend(%SRlegend)
	{%s}_decomp.setelem(2) legend(%LRlegend)	
	{%s}_decomp.draw(line, left, @rgb(0,0,0), pattern(3), linewidth(1)) 10
	%txt = " percentage points \r* adjusted to keep demographic distribution (age, marital status, child presence) constant at " + %base + " population"
	{%s}_decomp.addtext(bc, font(11), just(c)) %txt
	{%s}_decomp.axis(b) zeroline

	{%s}_decomp_ex.setobslabel "Business Cycle" "Disability Prevalence" "Education" "Replacement Rate" "Earnings Test" "Lagged Cohort" "Life Expectancy" "Addfactors" "TOTAL, ADJUSTED*" "Age" "Marital Status" "Child Presence" "TOTAL"
	{%s}_decomp_ex.setelem(1) legend()
	{%s}_decomp_ex.setelem(2) legend()	
	{%s}_decomp_ex.setelem(3) legend(%SRlegend)
	{%s}_decomp_ex.setelem(4) legend(%LRlegend)	
	{%s}_decomp_ex.setelem(1) fillcolor(@rgb(0,0,255))		' different color for the TOTAL lines
	{%s}_decomp_ex.setelem(2) fillcolor(@rgb(255,100,26))	' different color for the TOTAL lines
	{%s}_decomp_ex.setelem(3) fillcolor(@rgb(114,147,203))' matching the default colors from earlier charts
	{%s}_decomp_ex.setelem(4) fillcolor(@rgb(225,151,76))	 ' matching the default colors from earlier charts

	{%s}_decomp_ex.options -barspace
	{%s}_decomp_ex.draw(line, left, @rgb(0,0,0), pattern(3), linewidth(1)) 10 	' horizontal line after the "adjusted subtotal" bar
	' the text in the string below is specially placed (with spaces and all) to align it on the charts in a desired way
	%txt = " percentage points \r* adjusted to keep demographic distribution (age, marital status, child presence) constant at " + %base + " population"
	{%s}_decomp_ex.addtext(bc, font(11), just(c)) %txt
	{%s}_decomp_ex.axis(b) zeroline

next

' At this point, the decomp charts look the way Beth needs them for PDF (i.e. fully formatted EXCEPT for the titles; SAVE them as PDFs here
if %pdf = "Y" then
	logmsg Saving PDF charts for publication to %pdf_location
	for %chrt f_decomp_a f_decomp_u m_decomp_a m_decomp_u f_decomp m_decomp f_decomp_ex m_decomp_ex
		%loc = %pdf_location + %chrt + ".pdf"
		{%chrt}.save(t=pdf, c, box, port, w=7.3, h = 4.9, u=in, d=96, trans) %loc
		logmsg %chrt ...
	next
endif
logmsg ... done.
logmsg

'add titles to chart following command below
%title = "Figure 11. \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for Women 16+ \rLFPRs adjusted for age, marital status, and child presence (using " + %base + " pop.) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
f_decomp_a.addtext(font(+b), t)  %title
%title = "Figure 10. \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for Men 16+ \rLFPRs adjusted for age, marital status, and child presence (using " + %base + " pop.) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
m_decomp_a.addtext(font(+b), t) %title
%title =  "Figure ?7 (deleted). \rDecomposition of Factors Contributing to the Projected Changee in Labor Force Participation Rates for All 16+ \rLFPRs adjusted for age, gender, marital status, and child presence (using " + %base + " pop.) \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
all_decomp_a.addtext(font(+b), t) %title

%title = "Figure 13. \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for Women 16+ \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
f_decomp_u.addtext(font(+b), t) %title
%title = "Figure 12. \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for Men 16+ \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
m_decomp_u.addtext(font(+b), t) %title
%title = "Figure ?10 (deleted). \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for All 16+ \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
all_decomp_u.addtext(font(+b), t) %title

%title = "Figure 10. \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for Women 16+ \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
f_decomp.addtext(font(+b), t) %title
f_decomp.legend position(2,4.1) 
f_decomp_ex.addtext(font(+b), t) %title
m_decomp.legend position(2,4.1) 

%title = "Figure 9. \rDecomposition of Factors Contributing to the Projected Change in Labor Force Participation Rates for Men 16+ \r"+@str(!TRyr)+" Trustees Report (intermediate assumptions)"
m_decomp.addtext(font(+b), t) %title
m_decomp_ex.addtext(font(+b), t) %title


logmsg Decomposition bar charts done
logmsg

' Save ALL table to CSV files
wfselect {%output_file}
pageselect tables
smpl @all

' list of tables to be saved into CSV files; can edit to limit the number of files being saved
%tablist = "chg_all_alt2 chg_alle_alt2 chg_f_alt2 chg_fe_alt2 chg_m_alt2 chg_me_alt2 comp_ep_lfpr comp_lr_a comp_lr_u comp_ru comp_sr_a comp_sr_u " + _
			"proj_all_alt2 proj_all_alt2_lim proj_alle_alt2 proj_alle_alt2_lim proj_f_alt2 proj_f_alt2_lim proj_fe_alt2 proj_fe_alt2_lim proj_m_alt2 proj_m_alt2_lim proj_me_alt2 proj_me_alt2_lim " + _
			"projq_alle projq_fe projq_me " + %table_s_a + " " + %table_l_a + " " + %table_s_u + " " + %table_l_u

if %csv = "Y" then
	for %name {%tablist}
		%csvfile = %csv_location + %name + ".csv"
		{%name}.save(t=csv) %csvfile
	next
endif


'make sure the active page is "tables" before saving the file
wfselect {%output_file}
pageselect tables
smpl @all
%usr = @env("USERNAME")

'create a spool that would contain summary info for the run
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %usr
string line2 = "The run represents TR" + @str(!TRyr) + ", alt 2" + @chr(13) + "and uses the following parameters and inputs:"
string line3 = "TR"+@str(!TRyr)+ " a-bank: " + @chr(13) + %abank_alt2
string line4 = "TR"+@str(!TRyr)+ " d-bank: " + @chr(13) + %dbank_alt2

string line5 = "TR"+@str(!TRyr_pr)+ " a-bank: " + @chr(13) + %abank_alt2pr 	
string line6 = "TR"+@str(!TRyr_pr)+ " d-bank: " + @chr(13) + %dbank_alt2pr 	

string line7 = "LFPR decomposition files: " + @chr(13) + %decomp_path_current + %current_a + @chr(13) + %decomp_path_current + %current_u + @chr(13) + %decomp_path_prior + %prior_a + @chr(13) + %decomp_path_prior + %prior_u
string line8 = "The file includes the comparison of TR"+ @str(!TRyr) + " to TR" + @str(!TRyr_pr) + ". Previous-year-TR databanks are used when computing differences (current TR vs prior TR)."

string line9 = "This file includes charts and tables for the recurring-note version of the paper. This includes certain special charts and condensed tables."

if %csv = "Y" then
	string line10 = "CSV files corresponding to all tables have been saved to " + %csv_location
	else
		string line10 = ""
endif
if %pdf = "Y" then
	string line11 = "PDF files for charts (in the form suitable for inserting into the published study) have been saved to " + %pdf_location
	else
		string line11 = ""
endif


_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11
_summary.display

delete line*

'	save the workfile
if %sav = "Y" then 
	%full_output=%output_path+%output_file
	%msg = "Saving the resulting workfile to " + %full_output
	logmsg
	logmsg {%msg}
	logmsg
	wfsave %full_output
endif

if %sav = "N" then 
	logmsg
	logmsg The resulting workfile has NOT been saved! Please save manually if desired.
	logmsg
endif

logmsg FINISHED

'wfclose


