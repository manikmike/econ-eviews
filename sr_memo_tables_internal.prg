' Polina Vlasenko 
' 3-11-2020
' This is the program that makes SR memo tables for internal discussion. 
' These tables contain more data series than the SR tables included in the official memo. 

' 	This program produces tables that we use INTERNALLY while developing SR assumptions.
'	The program loads data from various workfiles as well as outside sources to produce the tables, comparisons to earlier TRs, and other analysis that is useful for the internal deliberations on SR assumptions.
' 	A separate program (sr_memo_tables_official.prg) produces the cleaned-up set tables (with pre-specified list of series) that are later included in the official SR memo. 
' 	The tables are saved in CSV format so that they can later be viewed in Excel.
' 	The CSV version of the summary table produced by this program is then linked to an Excel file that computes various useful comparisons (between current and prior TR, between different alts, etc.)

' !!!!!!!!!! Before running this program for a new TR, search for text 'SPECIAL FOR TR' (all caps) -- it marks all idiosyncratic fixes that were done for particular TRs. Check to make sure any of those still apply!!!!
' NOTE 12-05-2022: for TR23 I changed the code so that the program uses WORKFILES only (no databanks) to read in data for TR (both current and prior-year)

' This program requires the following workfiles:
' a-bank from current TR, alt2 only or all alts (depending on the kind fo tables desired)
' d-bank from current TR, alt2 only or all alts (depending on the kind fo tables desired)
' a-bank from previous-yr TR, all alts
' d-bank from previous-yr TR, all alts
' aombXX.wf1 that contains data from the budget run
' Excel file from OMB with the budget assumptions
' EViews workfile containing the forecast from S&P Global (formerly IHS Markit) -- we use either "Short-term Macro Forecast (baseline)" or "Long-term Macro Forecast (baseline)" (decided every year case by case)
' Excel file that contains Moody's forecast (currently, I download it from Moody's DataBuffet)
' EViews workfile that contains CBO data (usually from the latest LTBO)
' Excel file that contains data from Blue Chip forecast 

' FYI: Historical nominal interest rates on new issues https://mwww.ba.ssa.gov/OACT/ProgData/newIssueRates.html 

' ****** !!!!! Make sure the Excel source files referred to in here (Budget, Moody's, CBO) are NOT open by anyone, otherwise EViews will crash (without saving the program changes, if any)!!!! *****


'***********************************************************************************************************************
'***** UPDATE these parameters before running the program ****
'***** The Update section is LONG; make sure you check all of it -- all the way to '*****END of UPDATE section   
'***** !!! Pay special attention to SAVE options (%sav, %csv, %longtab, %sumtab, %pdf) to avoid overwriting output files !!!
' **********************************************************************************************************************

%usr = @env("USERNAME")

!TRyr = 2025	' current TR year

'	Output created by this program
%run = "2025-0106-1433-TR252X"		' ALWAYS start with underscore _. A (short) identifier for the run, it should describe what was changed from the last time the program was run (example: _noCT for "no Cadillac tax"). 
 									' This will be appended to the filenames to identify which LONG tables belong to which run. The summary table will is ALWAYS named 'summary_table.csv" -- the name must be identical for all runs to allow for reference in Excel template.
%thisfile = "SRtables_internal_TR" + @str(!TRyr) + %run

%outputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\analysis\" 	' location where EViews workfile is to be saved (files with identical names get overwriiten)

%tablespath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\analysis\" 	' location where the CSV version of the finished tables are to be saved; can be the same as or different from %outputpath (files with identical names get overwritten)

' ***** SAVE options ******
' Do you want the Eviews WORKFILE with output to be saved on this run? 
' Usually, enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location (%outputpath and %tablespath above) is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "Y" 		' enter "N" or "Y" case sensitive; this governs ONLY whether the WORKFILE is saved; saving individual tables into files is governed by parameters below

' Which TABLES to save to separate files? (You can save tables even if you do not save the output workfile)
' For internal review we usually only need CSV tables, so it would be convenient NOT to make the numerous PDF files in such cases.
%pdf = "N" 			' !!! ALWAYS N for internal tables!!!
%csv = "Y" 			' enter "Y" to save tables in CSV format, "N" to not save tables in CSV (case sensitive). 'N' here would mean NO tables will be saved in the separate files. The only tables one would be able to see will be in the workfile itself.
%sumtab = "Y"		' enter "Y" to save SUMMARY table in one file (CSV, PDF, or both depending on %pdf and %csv parameters above). Saving the summary table broken into separate pages (the way we do for the official memo) is not available in this internal program because here the Summary Table is way too long and changes shape with adding/re-ordering the series.
%longtab = "N"		' enter "Y" to save LONG tables each in its own separate file (CSV, PDF, or both depending on %pdf and %csv parameters above). 'N' here allows one not to save the MANY long tables if they are not of interest on the current run.

'Example of save options: 
' the following combination is likely to be used most frequently: %sav = "Y", %pdf = "N", %csv = "Y", %sumtab = "Y", %longtab = "N". It saves the workfile and the summary table in the CSV format (and does not save long tables or any PDF files, thus saving time and minimizing the clutter in the folder).  
' The final run (once we really decided which series we want) might also have %longtab = "Y" to save the long tables for the record.

' For CSV tables -- full precision or rounded. NOTE: PDF tables, if we make them, display rounded values ONLY. 
' NOTE: typically, we use FULL precision for internal deliberations.
%full = "Y" 		' enter "Y" if full precision is desired, "N" if rounded values are OK (case sensitive). 
' ***** end of SAVE options *****
' *****

!yrstart = 2000 						' the earliest year for which to load data
!yrend=2050 								' the latest year for which to load data
!tablestart = !TRyr -1 				' the earliest year to be DISPLAYED in the LONG tables 	
!sum_tablestart = !tablestart -2 	' the first year to dispaly in each panel of the SUMMARY table.
!tableend = !TRyr + 9 '+ 10			' the last year to be DISPLAYED in the tables													
											' SPECIAL FOR TR24	-- extend !tableend for 10 years in order to display projected interest rate path 
											' 							If using this option, the resulting CSV tables might not look "pretty" (esp for Summary Table).
											' 							Use this option mainly to create "long" tables for the interest rates (by setting %longtab = "Y"); 
											' 							then can re-run this program again WITHOUT this extension to create nice-looking summary table and other tables.
' Previous_year TR
!TRpr = !TRyr-1

'*** current TR databanks ***
' ALTS -- current TR alts to be included; space-delimited list. 
' Normally we have either alt2 only, or all three alts.
' Make sure databank file locations are given (below) for ALL alts you list here. 
%alt_cur = "1 2 3" 		' "1 2 3" or "2"	
'	a-bank (comment out the alts that are not used)
%abank_alt2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2024-1215-0811-TR252\out\mul\atr252.wf1" 		' alt2	
%abank_alt1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\atr251.wf1" 		' alt1 
%abank_alt3 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\atr253.wf1" 		' alt3 
' 	d-bank -- this is needed to get population for e/pop ratio (comment out the alts that are not used)
%dbank_alt2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2024-1215-0811-TR252\out\mul\dtr252.wf1" 		' alt2
%dbank_alt1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\dtr251.wf1" 		' alt1  
%dbank_alt3 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\dtr253.wf1"		' alt3 

' short names for files
%abank1 = "atr" + @str(!TRyr-2000) + "1"
%abank2 = "atr" + @str(!TRyr-2000) + "2" 	
%abank3 = "atr" + @str(!TRyr-2000) + "3"

%dbank1 = "dtr" + @str(!TRyr-2000) + "1"
%dbank2 = "dtr" + @str(!TRyr-2000) + "2" 
%dbank3 = "dtr" + @str(!TRyr-2000) + "3"

'*** previous TR databanks ***
' We always include all 3 alts; enter locations for ALL file listed here.
' WORKFILE  version -- TR22 and later have workfiles
'	a-bank																												
%abank_pr_alt2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\atr242.wf1" 	' alt2	 
%abank_pr_alt1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\atr241.wf1" 	' alt1
%abank_pr_alt3 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\atr243.wf1" 	' alt3 

' 	d-bank -- this is needed to get population for e/pop ratio 
%dbank_pr_alt2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\dtr242.wf1" 	' alt2	
%dbank_pr_alt1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\dtr241.wf1" 	' alt1
%dbank_pr_alt3 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\dtr243.wf1" 	' alt3

%abank1pr = "atr" + @str(!TRpr-2000) + "1"
%abank2pr = "atr" + @str(!TRpr-2000) + "2"
%abank3pr = "atr" + @str(!TRpr-2000) + "3"

%dbank1pr = "dtr" + @str(!TRpr-2000) + "1"
%dbank2pr = "dtr" + @str(!TRpr-2000) + "2"
%dbank3pr = "dtr" + @str(!TRpr-2000) + "3"

'' SPECIAL FOR TR24
''*** SPECIAL TR databanks ***
'' These are the banks for CV19 run																											
'%abank_alt2ini = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2024\TR24_Update\atr242ini.wf1" 	' a-bank for CV19 run
'%dbank_alt2ini = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2024\TR24_Update\dtr242ini.wf1" 	' d-bank for CV19 run
'%date_2ini = "01-2024"
'' short names for files
'%abank2ini = "atr" + @str(!TRyr-2000) + "2ini" 	
'%dbank2ini = "dtr" + @str(!TRyr-2000) + "2ini" 


'*** Outside forecasters data *** 
'	Budget -- FY26																														
%FY = "2026" 					' Fiscal year applicable to the budget assumptions 								
%date_bgt = "11-2024" 		' Date when budget projections are released (to be displayed in the table column headings)	I use the date we RECEIVED these assumptions, the date they are RELEASED is likely later!
!yr_bgt = 2023					' First year of data in the OMB Excel file												
%budget_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\aomb26.wf1" 	' EViews workfile with Budget data, full path.	
%budget = "aomb26" 		' filename ONLY, no extension
%omb =  "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\econB26-SSA.xlsx" 		'  OMB's Excel file with budget assumption data, full path. 

' S&P Global (IHS Markit)																															
%ihs_source = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\all1124.wf1"	' EViews workfile downloaded from IHS that contains Baseline Macro Forecast
%ihs_file = "all1124"		' short filename only; this is ALSO the name of the page in the workfile!			
%date_ihs = "11-2024" 	' Date corresponding to IHS forecast (to be displayed in table column headings)	

' Moody's																											 
%mdy_source = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\Moodys_SRTables_20241108.xlsx"	' Moody's Excel file, full path. This file must combine quarterly and annual data from Moody's DataBuffet
																					' !!! MAKE SURE this file is NOT protected (click "Enable editing" if necessary; make a copy to be safe). Import command cannot read Excel files that are protected from editing.
%date_mdy = "11-2024" 		' Date corresponding to Moody's forecast (to be displayed in table column headings)		
%mdy_startq = "2010Q1"		' The date for first observation in Moodys Quarterly data
%mdy_starta = "2010"			' The year for first observation in Moodys Annual data
' Locations within Excel file; These SHOULD NOT change from year to year, if Moodys sends the file in the same format
'  Still -- it is a good idea to double-check every year that the format is still the same. If not, adjust the cell references here.
!mdy_head = 7 			' parameter that goes into colhead= option for Moodys' Excel file; number of rows that contain column headings
%mdy_names = "first"	' parameter that indicates that the FIRST row of column heading in Moodys Excel file contains the series names
%mdy_range_q = "Sheet1!B:AB"	' Columns in Moody's Excel file that contain LEVELS for Quarterly data (if there are also growth rates for quarterly data -- ignore those columns).
%mdy_range_a = "Sheet1!AE:BE" ' Columns in Moody's Excel file that contain LEVELS for Annual data (if there are also growth rates for annual data -- ignore those columns).

' CBO -- For TR25  use LTBO from March 2024
%cbo_source = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\Data_for_SSA_2024.wf1" 	' EViews workfile that CBO sends us upon request.
%cbo_file = "Data_for_SSA_2024"		' file name only; the file has page 'annual' and page 'quarterly'
%date_cbo = "03-2024" 		' Date the CBO forecast was released (to be displayed in table column headings)

' Blue Chip indicators 
%bch_source = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\data\bluechip_oct2024.xlsx"  ' Excel file with the relevant data from Blue Chip Economic Indicators
																																				' This file has a prespecified structure -- sheets 'data_a' and 'data_q', the required series names in the column heading.
%bch_file = "bluechip_oct2024"  ' file name only
%date_bch = "10-2024" 		' Date the BlueChip forecast was released (to be displayed in table column headings)
%bch_startq = "2023Q1"		' The date for first observation in BlueChip Quarterly data
%bch_starta = "2024"			' The date for first observation in BlueChip Annual data

' ****	BASE YEAR **** 
' This section deals with the possibility that the BASE YEAR (used for real values) differs between current TR and previous TR.
' The variables below are needed to appropriately label the series and their units in the tables
' In most years, the base year will be the same -- if so, list the same value for !by_cur and !by_pr below.
' Occasionally, when BEA changes the base year in their real series (once in a few years, usually during a comprehensive revisions), the two base years will differ
!by_cur = 2017		' base year for the CURRENT TR			
!by_pr = 2017 		' base year for the previous TR				
' Series whose names are affected by base year changes. 
' Enter names in BOTH lists below. If the base year is the same, enter identical names for both lists, otherwise, enter the names as they appear in the a-banks.
%gdp_list = "gdp17 kgdp17" 			'	names of real GDP and real potential GDP in CURRENT TR		
%gdp_list_pr = "gdp17 kgdp17" 		' 	names of real GDP and real potential GDP in PREVIOUS TR		
'	DONE with base-year-related variables

' ****  Summary table ****
' List of series as they appear in the Summary Table, IN THE ORDER we want them to appear.  
' To add/remove/change the order of panels in the summary table, adjust this list.
' !!!!! If you add a series -- remember to add ..._title, average indicator (..._ai), decimal formal indicator (_dc), and any applicable notes (_nt) strings for the series in the code below !!!!
' proposed new order for summary table -- 2/27/2020
%summ_list = "r_gdp_gr r_gdp gdp r_kgdp_gr r_kgdp rtp nomintr rintr cpiw_u_gr pgdp_gr price_diff e e_gr p16o p16o_asa epop ru ru_asa lc ahrs_gr lc_gr prod_gr lc_fex_gr prod_fex_gr te te_gr tcea tcea_gr wsd wsd_to_gdp lbrshr r_avg_earn_gr acwa_gr r_wage_diff"

' **** Long tables ****
' List the series to be shown in the long tables, IN THE ORDER the tables should appear. 
' To add/remove/change the order of tables, adjust this list -- the rest of code will adjust automatically.
' !!!! If you add a series -- remember to add a ..._tabtitle, average indicator (..._ail), decimal format indicator (_dc), and any applicable notes (_nt) strings for the series in the code below !!!!
' 2/27/2020 New version -- the set of "official tables" plus all the other extra ones!!!!
%tables_list =  "r_gdp_gr r_gdp r_kgdp_gr r_kgdp rtp cpiw_u_gr cpiw_gr pgdp_gr cpiw_u pgdp price_diff nomintr rintr gdp e e_gr p16o p16o_asa epop ru ru_asa lc ahrs_gr lc_gr prod_gr lc_fex_gr prod_fex_gr wsd wsd_to_gdp lbrshr r_avg_earn_gr"

' List of ALL series we need for the tables. -- should be unchanged UNLESS you ADD growth rate series to %tables_list or %summ_list above that require additional level series for average computation.
' Right now this is a combination of %summ_list and %tables_list with repetitions removed PLUS some level variables that are not included in tables but needed to compute compounded growth rates PLUS COLA we need for one long table
' If you removed series from %tables_list or %summ_list -- leave %global_list unchnaged
%global_list = @wunion(%tables_list, %summ_list) + " r_kgdp cpiw_gr cpiw_u pgdp" + " acwa ahrs cpiw lc_fex prod prod_fex r_avg_earn" + " cola"	

' Columns in the tables; it lists the 'extension' to the series names indicating the source; this list determines the order of columns in ALL tables (the order of columns is assumed to be the same in the summary table and all long tables); 
' To adjust the order of columns -- change this list.
%col_list = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 ihs mdy cbo bch bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3"
!table_cols =1+ @wcount(%col_list)
'' the original list for a standard set of SR tables
'%col_list = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 ihs mdy cbo bch bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3"
'!table_cols =1+ @wcount(%col_list)

' ****** !!!!! Make sure the Excel source files referred to in here (Budget data, Moodys) are NOT open by anyone, otherwise EViews will crash!!!! *****

' **************************************************************
'*****END of UPDATE section that needs updating for each run*****
' ********************************************************************************
' ********************************************************************************


' **** Several section of the program below can be changed to address formatting issues for the tables:

' 	*** Summary Table attributes *** provides
' 		titles for all panels within the Summary Table
' 		Average Indicator (ai) variable denoting whether and what kind of average to create for each series (simple, compounded, or no average)
' 		Note (_nt) to be included at the bottom of each panel (also accommodates no note); same notes are used for Long Tables where applicable

' 	**** Long Tables attributes **** provides
' 		titles for all Long Tables
' 		Average Indicator (ail) variable denoting whether and what kind of average to create in ***Long*** tables (simple, compounded, or no average)

' 	Section named "Decimal places (_dc) to be displayed for each series" specifies the precision to be displayed for each series
' 	These are the same whether the series is shown in Long tables or Summary table; thus every series is listed here ONLY ONCE.

' 	Section ' ******** Parameters needed to properly load data from various source files **********
' 	specifies parameters for importing data from external files (Excel sheet names, column references, etc)
' 	These would need to be changed only if the format of the input files changes (but good idea to double-check every year). 

' 	Section   ' ***** Formal all tables (close to the end of the program)
' 	formats all tables. To alter format -- look into code in this section.

' 	Section '		make summary spool
' 	makes the summary spool that is displyed once the program is run. To add to the spool or alter its contents -- edit this section.

' ************************************************


wfcreate(wf={%thisfile}, page=annual) a !yrstart !yrend		' page with annual data
pagecreate(page=quarterly) q !yrstart !yrend					' page with quarterly data
pagecreate(page=monthly) m !yrstart !yrend				 		' This page will be used for CPIW data (SA and NSA) from Budget
pagecreate(page=tables) q !yrstart !yrend						' page to store the final tables

' Display log messages as the program runs
logmode l
%msg = "Running SR_tables.prg" 
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect tables
smpl @all
'	table object that holds column headings for all tables (they depend on the elements in %col_list)
'	Here I assume that whenever TR alternative are listed, ALL 3 of them are listed in adjacent columns -- i.e. we can have TR18 alt 1, alt 2, alt 3 in this order in 3 adjacent columns, but we cannot have, for example, TR18 alt2, then Budget, then TR18 alt3.
table(5,!table_cols) head
for !t=1 to !table_cols
	head.setlines(5,!t) +d 		' insert double line through last row of the heading
next
head(3,1) = "Year"
for !t=1 to @wcount(%col_list)
	!cl = !t+1
	'S&P Global (formerly IHS Markit)
	if @wordq(%col_list,!t) = "ihs" then
		head(1,!cl) = "S&P"
		head(2,!cl) = "Global"
		head(3,!cl) = %date_ihs
	endif
	' Moody's
	if @wordq(%col_list,!t) = "mdy" then
		head(1,!cl) = "Moody's"
		head(2,!cl) = "Analytics"
		head(3,!cl) = %date_mdy
	endif
	' Budget
	if @wordq(%col_list,!t) = "bgt" then
		head(1,!cl) = "FY " + %FY
		head(2,!cl) = "Budget"
		head(3,!cl) = %date_bgt
	endif
	' CBO
	if @wordq(%col_list,!t) = "cbo" then
		head(2,!cl) = "CBO"
		head(3,!cl) = %date_cbo
	endif
	' BlueChip Economic Indicators
	if @wordq(%col_list,!t) = "bch" then
		head(1,!cl) = "Blue Chip"
		head(2,!cl) = "Econ. Ind."
		head(3,!cl) = %date_bch
	endif
'	'SPECIAL FOR TR24 -- INITIAL run
'	if @wordq(%col_list,!t) = "242ini" then
'		head(1,!cl) = "Initial"
'		head(2,!cl) = "2024TR alt2"
'		head(3,!cl) = %date_2ini
'	endif
	' TR previous
	%str1 = @str(!TRpr-2000) + "1"
	%str2 = @str(!TRpr-2000) + "2"
	%str3 = @str(!TRpr-2000) + "3"
	if @wordq(%col_list,!t) = %str1 then 
		head(3,!cl) = "I"
		head(2,!cl) = @str(!TRpr) + " TR by Alternative"
		head.setmerge(2,!cl,2,!cl+2)
	endif
	if @wordq(%col_list,!t) = %str2 then 
		head(3,!cl) = "II"
	endif
	if @wordq(%col_list,!t) = %str3 then 
		head(3,!cl) = "III"
	endif
	' TR current
	%str1 = @str(!TRyr-2000) + "1"
	%str2 = @str(!TRyr-2000) + "2"
	%str3 = @str(!TRyr-2000) + "3"
	if @wordq(%col_list,!t) = %str1 then 
		head(3,!cl) = "I"
		head(1,!cl) = "Proposed "+ @str(!TRyr) + " TR"
		head.setmerge(1,!cl,1,!cl+2)
	endif
	if @wordq(%col_list,!t) = %str2 then 
		head(3,!cl) = "II"
		head(2,!cl) = "OCACT"
	endif
	if @wordq(%col_list,!t) = %str3 then 
		head(3,!cl) = "III"
	endif
	head.setfont(@all) +b	' make text bold
	head.setjust(@all) top	' text is aligned to the TOP of each row -- to solve the problem of long letters (like g, p, y) being cut off at the bottom.
next

wfselect {%thisfile}
pageselect annual
smpl @all

'	*** Summary Table attributes ***
' 	Titles to be used for each panel in the Summary table and for Summary table as a whole
'	 These correspond to the series names in the %summ_list defined above.
'	 Generally, these should not change from year to year, but sometimes they could (if we decide to alter them).
'	Titles are stored as string objects (and not %title) so that they can be seen in the workfile for easy editing.

%summ_table_title = "Summary Table - Comparison of Estimated Economic Parameters for " + @str(!TRyr) + " Trustees Report"
if !by_cur = !by_pr then
	string r_gdp_gr_title = "Annual Percentage Change in GDP in " + @str(!by_cur) + " Dollars"
	string r_gdp_title = "GDP in " + @str(!by_cur) + " Dollars (in billions)"
	'string r_kgdp_gr_title = "Annual Percentage Change in Potential GDP in " + @str(!by_cur) + " Dollars"
	string r_kgdp_gr_title = "Annual Percentage Change in Potential GDP in " + @str(!by_cur) + " Dollars" + ", S&P Global in 2012 Dollars" ' SPECIAL FOR TR25 -- S&PGlobal Nov 2024 forecast provides potential GDP in 2012 dollars, but real GDP in 2017 dollars 
	'string r_kgdp_title = "Potential GDP in " + @str(!by_cur) + " Dollars (in billions)"
	string r_kgdp_title = "Potential GDP in " + @str(!by_cur) + " Dollars (in billions)" + ", S&P Global in 2012 Dollars (in billions)" ' SPECIAL FOR TR25 -- S&PGlobal Nov 2024 forecast provides potential GDP in 2012 dollars, but real GDP in 2017 dollars
	else 
	string r_gdp_gr_title = "Annual Percentage Change in GDP in " + @str(!by_cur) + " Dollars" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars"
	string r_gdp_title = "GDP in " + @str(!by_cur) + " Dollars (in billions)" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars (in billions) "
	string r_kgdp_gr_title = "Annual Percentage Change in Potential GDP in " + @str(!by_cur) + " Dollars" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars" 
	'string r_kgdp_gr_title = "Annual Percentage Change in Potential GDP in " + @str(!by_cur) + " Dollars" + ", CBO, S&P Global, and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars" ' SPECIAL FOR TR24
	string r_kgdp_title = "Potential GDP in " + @str(!by_cur) + " Dollars (in billions)" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars (in billions)"
	'string r_kgdp_title = "Potential GDP in " + @str(!by_cur) + " Dollars (in billions)" + ", CBO, S&P Global, and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars (in billions)" ' SPECIAL FOR TR24
endif

string gdp_title = "GDP in Current Dollars (in billions)"
string wsd_title = "U. S. Wage and Salary Disbursements in Current Dollars (in billions)"
string wsd_to_gdp_title = "U. S. Wage and Salary Disbursement as a Percentage of GDP"
string r_avg_earn_gr_title = "Annual Percentage Change in Average Weekly Real Earnings (U.S. earnings)"
string acwa_gr_title = "Annual Percentage Change in Average OASDI Covered Wage"
string r_wage_diff_title = "Real Growth in Average OASDI Covered Wage "
string ru_title = "Average Annual Civilian Unemployment Rate (gross)"
string lc_title = "Average Annual Civilian Labor Force (millions)"
string ahrs_gr_title = "Annual Percentage Change in Average Weekly Hours Worked (Total Economy)"
string nomintr_title = "Nominal Interest Rate"
string rintr_title = "Real Interest Rate"
string cpiw_u_gr_title = "Average Percentage Change in CPI-W (not seasonally adjusted)"
string pgdp_gr_title = "Annual Percentage Change in GDP Deflator"
string price_diff_title = "Difference Between Annual Percent Change in GDP Deflator and in CPI-W"
string lc_gr_title = "Annual Percentage Change in Civilian Labor Force"
string prod_gr_title = "Implied Annual Percent Change in Labor Productivity (Total Economy)"
string lc_fex_gr_title = "Implied Annual Percentage Change in Full Employment Civilian Labor Force"
string prod_fex_gr_title = "Implied Annual Percentage Change in Full Employment Labor Productivity (Total Economy)"
' additional series for internal use only
string e_title = "Employment (average annual, CPS concept), 16+, millions"
string e_gr_title = "Annual Percentage Change in Employment (CPS concept), 16+, percent"
string rtp_title = "Ratio of Actual to Potential GDP"
string te_title = "Employment (total at-any-time), millions"
string te_gr_title = "Annual Percentage Change in Employment (total at-any-time), percent"
string tcea_title = "OASDI Covered Employment (total at-any-time), millions"
string tcea_gr_title = "Annual Percentage Change in OASDI Covered Employment (total at-any-time), percent"
string ru_asa_title = "Average Annual Civilian Unemployment Rate (age-sex-adjusted)"
string p16o_title = "Labor Force Participation Rate (gross), 16+"
string p16o_asa_title = "Labor Force Participation Rate (age-sex-adjusted), 16+"
string epop_title = "Ratio of Employment to Population (CPS concept), 16+"
string lbrshr_title = "Labor Share (labor compensation as a percentage of GDP)"


' 	Average Indicator (ai) variable denoting whether and what kind of average to create for each series in the ***Summary*** table
' 	Generally, these would not change from year to year, but can be adjusted if needed
'	"N" = no average; 
'	"C" = compound average growth of the underlying level series; 
'	"S" = simple average of the 10 annual values

string r_gdp_gr_ai = "C"
string r_gdp_ai = "N"
string gdp_ai = "N"
string r_kgdp_gr_ai = "C"
string wsd_ai = "N"
string wsd_to_gdp_ai = "S"
string r_avg_earn_gr_ai = "C" ' "S"
string acwa_gr_ai = "C"
string r_wage_diff_ai = "S"
string ru_ai = "S"
string lc_ai = "N"
string ahrs_gr_ai = "C"
string nomintr_ai = "N"
string cpiw_u_gr_ai = "C" '  "S"
string pgdp_gr_ai = "C" ' "S"
string price_diff_ai = "S"
string lc_gr_ai = "C"
string prod_gr_ai = "C" ' "S"
string lc_fex_gr_ai = "C"
string prod_fex_gr_ai = "C" ' "S"
string r_kgdp_ai = "N"
' additional series for internal use only
string e_ai = "N"
string e_gr_ai = "C"
string rtp_ai = "S"
string te_ai = "N"
string tcea_ai = "N"
string te_gr_ai = "C"
string tcea_gr_ai = "C"
string ru_asa_ai = "S"
string p16o_ai = "S"
string p16o_asa_ai = "S"
string epop_ai = "S"
string rintr_ai = "N"
string lbrshr_ai = "S"

' 	Note (_nt) to be included at the bottom of each panel in the ***Summary*** table
' 	Generally, these would not change from year to year, but can be adjusted if needed
'	"N" = no note 
string r_gdp_gr_nt = "N"
string r_gdp_nt = "N"
string gdp_nt = "N"
string r_kgdp_gr_nt = "N"
string wsd_nt = "N"
string wsd_to_gdp_nt = "N"
string r_avg_earn_gr_nt = "N"
string acwa_gr_nt = "Note: For FY " + %FY + " Budget, S&P Global, Moody's, and CBO, the annual percentage change in average *earnings* for the U.S. is presented."
string r_wage_diff_nt = "N"
string ru_nt = "N"
string lc_nt = "N"
string ahrs_gr_nt = "Note: For S&P Global and Moody's Analytics, percentage change is for average weekly hours in the private nonfarm sector." 
'string ahrs_gr_nt2 = "For CBO, 10-year averages are simple averages of the annual growth rates. "				' Special note for CBO averages (we need this because we have no level series for ahrs for CBO). NO LONGER NEEDED -- the new method computed compount annual average even without the level series.
string nomintr_nt = "Note: For S&P Global, Moody's Analytics, CBO, and Blue Chip Ec. Ind., nominal interest rates for 10-year Treasury notes are presented."
string rintr_nt = "Note: For S&P Global, Moody's Analytics, CBO, and Blue Chip Economic Indicators, interest rates for 10-year Treasury notes are presented."
string cpiw_u_gr_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, percentage change in CPI-U (not seasonally adjusted) is presented."
string cpiw_gr_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, percentage change in CPI-U (seasonally adjusted) is presented."
string cpiw_u_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, CPI-U (not seasonally adjusted) is presented."
string pgdp_gr_nt = "N"
string price_diff_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, percent change in CPI-U is used in place of percent change in CPI-W."
string lc_gr_nt = "N"
string prod_gr_nt = "Note: For S&P Global and Moody's Analytics, the computation assumes that the growth rate of average weekly hours is " 
string prod_gr_nt2 = "the same for total economy and for the private nonfarm sector. "
string lc_fex_gr_nt = "N"
string prod_fex_gr_nt = "N" 
string r_kgdp_nt = "N"
string rtp_nt = "N"
string pgdp_nt = "N"

' additional series for internal use only
string e_nt = "N"
string e_gr_nt = "N"
string te_nt = "N"
string tcea_nt = "N"
string te_gr_nt = "N"
string tcea_gr_nt = "N"
string ru_asa_nt = "N"
string p16o_nt = "N"
string p16o_asa_nt = "N"
string epop_nt = "N"
string lbrshr_nt = "N"

'	**** Long Tables attributes ****
'	Long Tables titles
' 	the list of series to be displayed in the long tables is given in %tables_list above

if !by_cur = !by_pr then
	%r_gdp_gr_tabtitle = "Percentage Change in GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report"
	%r_gdp_tabtitle = "GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report"
	'%r_kgdp_gr_tabtitle = "Percentage Change in Potential GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report"
	%r_kgdp_gr_tabtitle = "Percentage Change in Potential GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (S&P Global in 2012 Dollars)"  ' SPECIAL FOR TR25 -- S&PGlobal Nov 2024 forecast provides potential GDP in 2012 dollars, but real GDP in 2017 dollars
	'%r_kgdp_tabtitle = "Potential GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report"
	%r_kgdp_tabtitle = "Potential GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (S&P Global in 2012 Dollars)"  ' SPECIAL FOR TR25 -- S&PGlobal Nov 2024 forecast provides potential GDP in 2012 dollars, but real GDP in 2017 dollars 
	
	else 
	%r_gdp_gr_tabtitle = "Percentage Change in GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	%r_gdp_tabtitle = "GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	%r_kgdp_gr_tabtitle = "Percentage Change in Potential GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	'%r_kgdp_gr_tabtitle = "Percentage Change in Potential GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (CBO, S&P Global, and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)" ' SPECIAL FOR TR24
	%r_kgdp_tabtitle = "Potential GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	'%r_kgdp_tabtitle = "Potential GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (CBO, S&P Global, and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"  ' SPECIAL FOR TR24
endif

%rtp_tabtitle = "Ratio of Actual to Potential GDP for " + @str(!TRyr) + " Trustees Report"
%cpiw_u_gr_tabtitle = "Percentage Change (annualized) in CPI-W (not seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%cpiw_gr_tabtitle = "Annual Percentage Change in CPI-W (seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%pgdp_gr_tabtitle = "Annual Percentage Change in GDP Deflator (seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%cpiw_u_tabtitle = "CPI-W (not seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%pgdp_tabtitle = "GDP Deflator (seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
'%pgdp_tabtitle = "GDP Deflator (seasonally adjusted, 2017 base year) for " + @str(!TRyr) + " Trustees Report" + " (2012 base year for CBO and " + @str(!TRpr) + " TR)" 		' SPECIAL FOR TR24
%nomintr_tabtitle = "Nominal Interest Rate on New Issues for " + @str(!TRyr) + " Trustees Report"
%rintr_tabtitle = "Real Interest Rate for " + @str(!TRyr) + " Trustees Report, Defined as Realized or Expected Real Yield on Securities Issued in the Fourth Prior Quarter"
' additional series for internal use only
%e_tabtitle = "Employment (average annual, CPS concept), 16+, millions for " + @str(!TRyr) + " Trustees Report"
%e_gr_tabtitle = "Annual Percentage Change in Employment, CPS concept (annualized rate), 16+, for " + @str(!TRyr) + " Trustees Report"
%te_tabtitle = "Employment (total at-any-time), millions, for " + @str(!TRyr) + " Trustees Report"
%tcea_tabtitle = "OASDIovered Employment (total at-any-time), millions, for " + @str(!TRyr) + " Trustees Report"
%te_gr_tabtitle = "Annual Percentage Change in Employment (total at-any-time) for " + @str(!TRyr) + " Trustees Report"
%tcea_gr_tabtitle = "Annual Percentage Change in OASDIovered Employment (total at-any-time) for " + @str(!TRyr) + " Trustees Report"
%ru_tabtitle = "Average Annual Civilian Unemployment Rate (gross), percent, for " + @str(!TRyr) + " Trustees Report"
%ru_asa_tabtitle = "Average Annual Civilian Unemployment Rate (age-sex-adjusted), percent, for " + @str(!TRyr) + " Trustees Report"
%p16o_tabtitle = "Labor Force Participation Rate (gross), 16+"
%p16o_asa_tabtitle = "Labor Force Participation Rate (age-sex-adjusted), 16+"
%epop_tabtitle = "Ratio of Employment to Population (CPS concept), 16+, for " + @str(!TRyr) + " Trustees Report"

%gdp_tabtitle = "GDP ($ billions, SAAR) for " + @str(!TRyr) + " Trustees Report"
%wsd_tabtitle = "U. S. Wage and Salary Disbursements in ($billions) for " + @str(!TRyr) + " Trustees Report"
%wsd_to_gdp_tabtitle = "U. S. Wage and Salary Disbursement as a Percentage of GDP for " + @str(!TRyr) + " Trustees Report"
%r_avg_earn_gr_tabtitle = "Annual Percent Change in Average Real Earnings  (U.S. earnings) for " + @str(!TRyr) + " Trustees Report"
%acwa_gr_tabtitle = "Annual Percentage Change in Average OASDI Covered Wage for " + @str(!TRyr) + " Trustees Report"
%r_wage_diff_tabtitle = "Real Growth in Average OASDI Covered Wage for " + @str(!TRyr) + " Trustees Report"
%lc_tabtitle = "Average Annual Civilian Labor Force (millions) for " + @str(!TRyr) + " Trustees Report"
%ahrs_gr_tabtitle = "Annual Percentage Change in Average Weekly Hours Worked (Total Economy) for " + @str(!TRyr) + " Trustees Report"
%price_diff_tabtitle = "Difference Between Annual Percent Change in GDP Deflator and in CPI-W for " + @str(!TRyr) + " Trustees Report"
%lc_gr_tabtitle = "Annual Percentage Change in Civilian Labor Force for " + @str(!TRyr) + " Trustees Report"
%prod_gr_tabtitle = "Implied Annual Percent Change in Labor Productivity (Total Economy) for " + @str(!TRyr) + " Trustees Report"
%lc_fex_gr_tabtitle = "Implied Annual Percentage Change in Full Employment Civilian Labor Force for " + @str(!TRyr) + " Trustees Report"
%prod_fex_gr_tabtitle = "Implied Annual Percentage Change in Full Employment Labor Productivity (Total Economy) for " + @str(!TRyr) + " Trustees Report"
%lbrshr_tabtitle = "Labor Share (Labor Compensation as a Percentage of GDP) for " + @str(!TRyr) + " Trustees Report"

' 	Average Indicator (ail) variable denoting whether and what kind of average to create in ***Long*** tables
' 	Generally, these would not change from year to year, but can be adjusted if needed
'	"N" = no average; 
'	"C" = compound average growth of the underlying level series; 
'	"S" = simple average of the 10 annual values
	
string r_gdp_gr_ail = "C"
string r_kgdp_gr_ail = "C"
string r_gdp_ail = "N"
string r_kgdp_ail = "N"
string rtp_ail = "N"
string cpiw_u_gr_ail = "C" 
string cpiw_gr_ail = "C" 
string pgdp_gr_ail = "C" 
string cpiw_u_ail = "N" 
string pgdp_ail = "N" 
string nomintr_ail = "S"
string rintr_ail = "S"
' additional series for internal use only
string e_ail = "N"
string e_gr_ail = "C"
string te_ail = "N"
string tcea_ail = "N"
string te_gr_ail = "C"
string tcea_gr_ail = "C"
string ru_ail = "S"
string ru_asa_ail = "S"
string p16o_ail = "S"
string p16o_asa_ail = "S"
string epop_ail = "S"

string gdp_ail = "N"
string wsd_ail = "N"
string wsd_to_gdp_ail = "S"
string r_avg_earn_gr_ail = "C"
string acwa_gr_ail = "C"
string r_wage_diff_ail = "S"
string lc_ail = "N"
string ahrs_gr_ail = "C"
string price_diff_ail = "S"
string lc_gr_ail = "C"
string prod_gr_ail = "C"
string lc_fex_gr_ail = "C"
string prod_fex_gr_ail = "C"
string lbrshr_ail = "S"


' Decimal places (_dc) to be displayed for each series
' These are the same whether the series is shown in Long tables or Summary table; thus every series is listed here ONLY ONCE.
!r_gdp_gr_dc = 1
!r_gdp_dc = 2
!gdp_dc = 2
!r_kgdp_gr_dc = 1
!r_kgdp_dc = 2
!rtp_dc = 4
!wsd_dc = 2
!wsd_to_gdp_dc = 1
!r_avg_earn_gr_dc = 2
!acwa_gr_dc = 2
!r_wage_diff_dc = 2
!ru_dc = 1
!lc_dc = 1
!ahrs_gr_dc = 2
!nomintr_dc = 1
!rintr_dc = 1
!cpiw_u_dc = 5 	' 4 
!cpiw_u_gr_dc = 2
!cpiw_gr_dc = 2 
!pgdp_gr_dc = 2
!pgdp_dc = 4 
!price_diff_dc = 2
!lc_gr_dc = 1
!prod_gr_dc = 2
!lc_fex_gr_dc = 1
!prod_fex_gr_dc = 2
' additional series for internal use only
!e_dc = 1
!e_gr_dc = 2
!te_dc = 1
!tcea_dc = 1
!te_gr_dc = 2
!tcea_gr_dc = 2
!ru_asa_dc = 1
!p16o_dc = 4
!p16o_asa_dc = 4
!epop_dc = 2
!lbrshr_dc = 1

' ** Special notes (_ntl) to be added in the Long Tables ONLY
'	"N" = no note 
string r_gdp_gr_ntl = "Note: Blue Chip Economic Indicators provide quarterly values only for the periods shown, and annual values for a longer period."
string r_gdp_ntl = "Note: Blue Chip Economic Indicators provide quarterly values only for the periods shown; annual values beyond that are computed by combining "
string r_gdp_ntl2 = "their last projected quarterly values and their annual growth rates provided separately. "
string gdp_ntl = "N"
string r_kgdp_gr_ntl = "N"
string wsd_ntl = "N"
string wsd_to_gdp_ntl = "N"
string r_avg_earn_gr_ntl = "N"
string acwa_gr_ntl = "N"
string r_wage_diff_ntl = "N"
string ru_ntl = "N"
string lc_ntl = "N"
string ahrs_gr_ntl = "N" 
string nomintr_ntl = "Blue Chip Economic Indicators provide quarterly values only for the periods shown, and annual values for a longer period."
string rintr_ntl = "Blue Chip Economic Indicators provide quarterly values only for the periods shown, and annual values for a longer period."
string cpiw_u_gr_ntl = "N"
string cpiw_gr_ntl = "Blue Chip Economic Indicators provide quarterly values only for the periods shown, and annual values for a longer period."
string cpiw_u_ntl = "N"
string pgdp_gr_ntl = "Note: Blue Chip Economic Indicators provide quarterly values only for the periods shown, and annual values for a longer period."
string price_diff_ntl = "Blue Chip Economic Indicators provide quarterly values only for the periods shown, and annual values for a longer period."
string lc_gr_ntl = "N"
string prod_gr_ntl = "N" 
string lc_fex_gr_ntl = "N"
string prod_fex_gr_ntl = "N" 
string r_kgdp_ntl = "N"
string rtp_ntl = "N"
string pgdp_ntl = "Note: Blue Chip Economic Indicators provide quarterly values only for the periods shown; annual values beyond that are computed by combining "
string pgdp_ntl2 = "their last projected quarterly values and their annual growth rates provided separately. "

string e_ntl = "N"
string e_gr_ntl = "N"
string te_ntl = "N"
string tcea_ntl = "N"
string te_gr_ntl = "N"
string tcea_gr_ntl = "N"
string ru_asa_ntl = "N"
string p16o_ntl = "N"
string p16o_asa_ntl = "N"
string epop_ntl = "N"
string lbrshr_ntl = "N"


' ******** Parameters needed to properly load data from various source files **********
' This should change infrequently, if at all. If the source files come in in the same format every year, no need to change any of this. 
' Still, it is a good idea to look through the source files to confirm the format corresponds to what's here -- especially for the Excel files!

' *** TRs ***
' list of series to be loaded from TR a-bank:
' %gdp_list and %gdp_list_pr (for REAL gdp values, to be loaded in both quarterly and annual frequency) were defined above to handle the possibility of series name changing with change in base year
%q_list = "gdp pgdp rtp cpiw_u cpiw ws wss y ahrs lc lc_fex prod_fex e edmil ru ru_asa p16o p16o_asa e16o hrs" 'prod			' quarterly series to be loaded from a-bank (current TR and previous TR); PROD (productivity) is not loaded directly from TR bank, but computed in this program as (r_gdp)/(hrs)
%an_list = "gdp pgdp rtp cpiw_u ws wss y acwa ahrs lc lc_fex prod_fex beninc e edmil te tcea ru ru_asa p16o p16o_asa e16o hrs" 'prod	' annual series to be loaded from a-bank (current TR and previous TR); PROD (productivity) is not loaded directly from TR bank, but computed in this program as (r_gdp)/(hrs)
' Note: we also load monthly nomintr.m series and transform it to both quarterly and annual frequency; this is entered manually in the code below.
' list of series to be loaded from TR d-bank:
%d_list = "n16o"	' both quarterly and annual

' *** Budegt data *** -- locations withing Excel file
' These SHOULD NOT change from year to year, if OMB does not change the format of the file they send us.
'  Still -- it is a good idea to double-check every year that the format is still the same. If not, adjust the cell references here.
!gdp_qtr_ch = 4 			' parameter that goes into colhead= option for 'GDP_Qtr' sheet; number of rows that contain column headings (the last row of which contains the invisible series names)
!trust_rates_ch = 4 		' parameter that goes into colhead= option for 'Trust_Rates' sheet; number of rows that contain column headings (the last row of which contains the invisible series names)

%gdp_ann = "B9:K22" 	' range in 'GDP_Annual' sheet; this includes the first row with invisible names
%pi_ann = "F9:I22" 		' range in 'Pers_Inc_Annual' sheet; wages and salaries section; this includes the first row with invisible names
%pi_qtr = "F7:I59" 			' range in 'Pers_Inc_Qtr'' sheet; wages and salaries section; this includes the first row with invisible names
%cola_ann = "B8:B19"  	' range in 'COLAs' sheet, does NOT include any rows with names
%cpi_nsa_cols = "B C D E F G H I J K L M N"  ' columns in 'CPIW_NSA' sheet that contain monthly data
!cpi_nsa_r1 = 7 			'  starting row for monthly data in 'CPIW_NSA' sheet 
!cpi_nsa_r2 = 18 			'  last row for monthly data in 'CPIW_NSA' sheet 
%cpi_sa_cols = "B C D E F G H I J K L M N"  ' columns in 'CPIW_SA' sheet that contain monthly data
!cpi_sa_r1 = 7 			'  starting row for monthly data in 'CPIW_SA' sheet 
!cpi_sa_r2 = 18 			'  last row for monthly data in 'CPIW_SA' sheet 


' *** Done with parameters describing the input files ***

wfselect {%thisfile}
' Placeholders for current TR alt1 and alt3. 
' Need these to exist even when we make tables for alt2 only. If making tables for all alts, this should not be run (hence the if statement).
' SPECIAL FOR TR24 -- commented out the if statement; restore when running all alts!!!
if %alt_cur = "2" then 
	for %p quarterly annual
		pageselect {%p}
		smpl @all
		for %a 1 3 
			for %s {%global_list } 
				%tralt = @str(!TRyr-2000) + %a
				series {%s}_{%tralt}
			next
		next
	next
endif

'' SPECIAL FOR TR23 !!! -- if we do not have aombXX file, need to create placeholder series
'for %p quarterly annual
'	pageselect {%p}
'	smpl @all
'	for %s {%global_list} yf ynf edmil
'		series {%s}_bgt
'	next
'next


'********** QUARTERLY DATA **********
'Load quarterly data
wfselect {%thisfile}
pageselect quarterly
smpl @all

	'Current TR
	'loop through alts
	%msg = "Loading quarterly data for TR" + @str(!TRyr) + "..."
	logmsg {%msg}
	
for %alt {%alt_cur}
	%tralt = @str(!TRyr-2000) + %alt
	
	wfopen %abank_alt{%alt}
	pageselect q
	for %ser {%q_list} 	
		copy {%abank{%alt}}::q\{%ser} {%thisfile}::quarterly\{%ser}_{%tralt} 		' copy from a-bank and rename to indicate TR and alt
	next
	
	for %ser {%gdp_list} 	' copy GDP-related series from abank and rename accordingly
		%test = @left(%ser, 1)
		if %test = "g" then
			copy {%abank{%alt}}::q\{%ser} {%thisfile}::quarterly\r_gdp_{%tralt} 
		endif
		if %test = "k" then
			copy {%abank{%alt}}::q\{%ser} {%thisfile}::quarterly\r_kgdp_{%tralt} 
		endif
	next
	wfselect {%abank{%alt}}
	pageselect m
	copy(c=an) {%abank{%alt}}::m\nomintr {%thisfile}::quarterly\nomintr_{%tralt}

	wfclose {%abank{%alt}}
	
	wfopen %dbank_alt{%alt}
	pageselect q
	for %ser {%d_list} 	
		copy {%dbank{%alt}}::q\{%ser} {%thisfile}::quarterly\{%ser}_{%tralt} 		' copy from d-bank and rename to indicate TR and alt
	next
	wfclose {%dbank{%alt}}
	
	wfselect {%thisfile}
	pageselect quarterly
	smpl @all
	rename ws_{%tralt} wsd_{%tralt} 	' SPECIAL FOR TR23 and TR24 (maybe all future TRs too) -- we are using WS series in place of WSD, but it needs to be named WSD for all other loops to run

next

' SPECIAL FOR TR23 and TR24 -- compute seasonal factors for cpiw_221 NSA using current Tr alt 2 (instead of Budget file); 
' might need to do this for all future TRs -- Budget file does not go back in time far enough to allow me to compute gr rate in CPIW(NSA) for years TRyr-2 and TRyr-1; we need these years for the internal tables.
wfselect {%thisfile}
pageselect quarterly
smpl @all

%tralt = @str(!TRyr-2000) + "2"
series CPIW_seas = cpiw_u_{%tralt}/cpiw_{%tralt}
' end of SPECIAL

	%msg = "Done."
	logmsg {%msg}
	logmsg
	
	'Previous-year TR
	'loop through alts
	%msg = "Loading quarterly data for TR" + @str(!TRpr) + "..."
	logmsg {%msg}
	
	wfselect {%thisfile}
	pageselect quarterly
	smpl @all
	
for %alt 1 2 3	
	' *** WORKFILE version -- for TR22 and later
	%tralt = @str(!TRpr-2000) + %alt
	
	wfopen %abank_pr_alt{%alt}
	pageselect q
	for %ser {%q_list} 	
		copy {%abank{%alt}pr}::q\{%ser} {%thisfile}::quarterly\{%ser}_{%tralt} 		' copy from a-bank and rename to indicate TR and alt
	next
	
	for %ser {%gdp_list_pr} 	' copy GDP-related series from abank and rename accordingly
		%test = @left(%ser, 1)
		if %test = "g" then
			copy {%abank{%alt}pr}::q\{%ser} {%thisfile}::quarterly\r_gdp_{%tralt} 
		endif
		if %test = "k" then
			copy {%abank{%alt}pr}::q\{%ser} {%thisfile}::quarterly\r_kgdp_{%tralt} 
		endif
	next
	wfselect {%abank{%alt}pr}
	pageselect m
	copy(c=an) {%abank{%alt}pr}::m\nomintr {%thisfile}::quarterly\nomintr_{%tralt}
	
	wfclose {%abank{%alt}pr}
	
	wfopen %dbank_pr_alt{%alt}
	pageselect q
	for %ser {%d_list} 	
		copy {%dbank{%alt}pr}::q\{%ser} {%thisfile}::quarterly\{%ser}_{%tralt} 		' copy from d-bank and rename to indicate TR and alt
	next
	wfclose {%dbank{%alt}pr}
 	wfselect {%thisfile}
 	pageselect quarterly
 	smpl @all
 	rename ws_{%tralt} wsd_{%tralt} 	' SPECIAL TR23 -- we are using WS series in place of WSD, but it needs to be named WSD for all other loops to run

next

	%msg = "Done."
	logmsg {%msg}
	logmsg
	
wfselect {%thisfile}
pageselect quarterly
smpl @all

	
' Outside forecasters
' creating placeholder series for now
wfselect {%thisfile}
pageselect quarterly
smpl @all
for %s {%global_list}		
	series {%s}_ihs			'S&P Global (formerly IHS Markit)
	series {%s}_mdy			'Moody's
	series {%s}_bgt			'Budget
	series {%s}_cbo			'CBO
	series {%s}_bch			'BlueChip
next

' ***Load Budget data ***
' data loaded from OMB's Excel file
%msg = "Loading quarterly data for Budget ..." 
logmsg {%msg}

' "GDP_Qtr" worksheet -- real GDP and GDP deflator
import %omb range="GDP_Qtr" colhead={!gdp_qtr_ch} namepos=last @freq q !yr_bgt 'this command relies on the "invisible" variable names located in row 7 in the budget assumption Excel file ('namepos=last' reads these as the variables names for the workfile). 

genr r_gdp_bgt = gdp_real 
genr gdp_bgt = gdp_nominal
genr pgdp_bgt = gdp_price_index/100
genr ru_bgt = unempl_rate
delete gdp_re* gdp_no* gdp_pr* unempl_* 'delete remaning unnecessary series

'' SPECIAL FOR TR23 -- reading LF and employment from Excel file (we usually read this from aombXX file)
'import %omb range="Labor_Qtr" colhead=4 namepos=last @freq q !yr_bgt 
'genr lc_bgt = civ_labor_force 
'genr e_bgt = civ_employed
'delete civ_labor_force civ_employed civ_unemployed unempl_rate

' Wages and salaries
import %omb range="Pers_Inc_Qtr"!{%pi_qtr} colhead=1 namepos=first @freq q !yr_bgt 'the cell range {%pi_ann} is specified above at the start of ptogram; this command relies on the "invisible" variable names located in row 7 in the budget assumption Excel file
genr wsd_bgt = wages_salaries 						' wages and salaries
genr wsd_to_gdp_bgt = wages_salaries_pct
genr wss_bgt = compensation 							' employee compensation
delete wages* compensation* 								'deleting remaning unnecessary series

'	'Trust_Rates' worksheet -- interest rates.
import %omb range="Trust_Rates" colhead={!trust_rates_ch} namepos=last @freq q !TRyr 'this command relies on the "invisible" variable names located in row 7 in the budget assumption Excel file  

genr nomintr_bgt = avg_rate_4 
delete avg_* _20* 'delete remaning unnecessary series

' CPIW_NSA worksheet. The worksheet lists monthly data first and quarterly data below it. We load monthly data. 
wfselect {%thisfile}
pageselect monthly		' monthly page contains CPI data ONLY
smpl @all

!yr = !yr_bgt
for %col {%cpi_nsa_cols}
   import(mode="u") %omb range="CPIW_NSA"!{%col}{!cpi_nsa_r1}:{%col}{!cpi_nsa_r2} names="cpiw_u_bgt_index" @freq m !yr ' cell reference to data location {%col}{!cpi_nsa_r1}:{%col}{!cpi_nsa_r2} is specified at start of this program
   !yr = !yr + 1
next

' CPIW_SA worksheet. Same approach as for CPIW_NSA above. 
!yr = !yr_bgt
for %col {%cpi_sa_cols}
   import(mode="u") %omb range="CPIW_SA"!{%col}{!cpi_sa_r1}:{%col}{!cpi_sa_r2} names="cpiw_bgt_index" @freq m !yr ' cell reference to data loaction {%col}{!cpi_sa_r1}:{%col}{!cpi_sa_r2} is specified at start of this program
   !yr = !yr + 1
next

' re-scale for comparability to TR data
genr cpiw_u_bgt = cpiw_u_bgt_index/100
genr cpiw_bgt = cpiw_bgt_index/100

' copy monthly CPIW NSA and SA series into quarterly page to convert
wfselect {%thisfile}
pageselect quarterly
smpl @all
copy(o, c=an) monthly\cpiw_u_bgt quarterly\
copy(o, c=an) monthly\cpiw_bgt quarterly\

'	Compute the seasonal adjustment factor for CPIW (equivalent to 'CPIW & CPIW_U worksheet' in SR tables Excel file)
' 	genr CPIW_seas = cpiw_u_bgt/cpiw_bgt		' the seasonal adjustment factor is based on Budget data, but used for several other forecasters
		' SPECIAL FOR TR23 and TR24 -- we don't want to use seasonal factors from Budget; instead we will use seasonal factors from TR

' load  series from aombXX databank; rename accordingly
wfselect {%thisfile}
pageselect quarterly
smpl @all

' copy from OMB file and raname to indicate source
wfopen %budget_path
pageselect q
copy {%budget}::q\rtp {%thisfile}::quarterly\rtp_bgt 	
copy {%budget}::q\prod {%thisfile}::quarterly\prod_bgt 
copy {%budget}::q\prod {%thisfile}::quarterly\prod_fex_bgt 	' for budget, we show prod_fex (full-empl productivity) only for yrs where rtp=1, at which point prod_fex=prod
copy {%budget}::q\lc {%thisfile}::quarterly\lc_bgt
copy {%budget}::q\lc {%thisfile}::quarterly\lc_fex_bgt 		' for budget, we show lc_fex (full-empl labor force) only for yrs where rtp=1, at which point lc_fex=lc
copy {%budget}::q\ahrs {%thisfile}::quarterly\ahrs_bgt
copy {%budget}::q\e {%thisfile}::quarterly\e_bgt
copy {%budget}::q\edmil {%thisfile}::quarterly\edmil_bgt
copy {%budget}::q\yf {%thisfile}::quarterly\yf_bgt
copy {%budget}::q\ynf {%thisfile}::quarterly\ynf_bgt
copy {%budget}::q\p16o {%thisfile}::quarterly\p16o_bgt
copy {%budget}::q\p16o_asa {%thisfile}::quarterly\p16o_asa_bgt
copy {%budget}::q\ru_asa {%thisfile}::quarterly\ru_asa_bgt

wfselect {%thisfile}
pageselect monthly
smpl @all

wfselect {%budget}
pageselect m
smpl @all
copy {%budget}::m\nomintr {%thisfile}::monthly\nomintr_bgt

wfclose {%budget}

wfselect {%thisfile}
pageselect quarterly
smpl @all
genr r_kgdp_bgt = r_gdp_bgt/rtp_bgt				' generate potential GDP from real GDP and rtp
copy(o, c=an) monthly\nomintr_bgt quarterly\ 	' transform nomintr from monthly to quarterly

%msg = "Done."
logmsg {%msg}
logmsg

' *** Load Moody's Analytics data  -- Quarterly***
%msg = "Loading quarterly data for Moody's ..." 
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all
import %mdy_source range=%mdy_range_q colhead=!mdy_head namepos={%mdy_names} @freq q {%mdy_startq}  ' import ALL quaterly series in Moody's Excel file.

' NOTE1: all series names in Moody's Excel files start with "F". AT THIS POINT in the workfile, there are NO other series (or any objects) whose name starts with F. Once we rename the Moody's series we need, can delete the rest by doing simply: delete f*.
' NOTE2: when importing series from Moody's Excel file, EViews has populated some of the fields in Label. Specifically, in 'Description' field it put in a very useful description combining rows 2 through 7 of Excel. Here is an example from CPIW:
'  "Baseline Scenario (November 2018): CPI: Urban Wage Earner - All Items, (Index 1982-84=100, SA) U.S. Bureau of Labor Statistics (BLS); Moody's Analytics Forecasted None AVERAGED IUSA 11/05/2018"

' rename series to indicate Moody's as source; this is done via genr command so that the newly renamed series will replace the existing series filled with NAs that were created as placeholder earlier.
' Note: doing this via genr command does NOT transfer the fields in Label that were automatically filled in. using 'rename' would have preserved them. I might consider changing this to 'rename' and eliminating the placeholder series for Moody's, but it might create other problems (we need placeholders to exist for other loops to run.)

genr cpiw_mdy = fcpiw / 100 		' CPIW SA level
genr pgdp_mdy = fpdpgdp / 100 	' PGDP level			
genr gdp_mdy = fgdp					' nominal GDP		
genr r_gdp_mdy = fgdp$ 				' real GDP
genr r_kgdp_mdy = fgdp$_pot		' real potential GDP
genr nomintr_mdy = frgt10y 			' nominal interest rate, 10yr Treasurys
genr lc_mdy = flbf 						' civ LF
genr e_mdy = flbe 						' employment
genr ru_mdy = flbr 						' un. rate
genr n16o_mdy = flbp					' civ. noninst. pop
genr p16o_mdy = flbt / 100			' LFPR 16+ in the form 0.6345 etc.
genr wsd_mdy = fypewsq 			' wages and salaries
genr wss_mdy = fyle 						' compensation of employees
genr lc_fex_mdy = flbf_pot 			' potential labor force
genr yf_mdy = fypeppfrq 				' farm prop. income
genr ynf_mdy = fypeppnfq 			' nonfarm prop. income
genr ahrs_mdy = fpcnbawh 			' avg. weekly hrs 
genr ru_fe_mdy = fnairu				' FE un. rate (for Moody's we use NAIRU)

genr rtp_mdy = r_gdp_mdy / r_kgdp_mdy	' compute RTP
genr cpiw_u_mdy = cpiw_mdy * CPIW_seas	' create CPIW NSA level by using the seasonal adjustment factor (CPIW_seas) derived from budget data
' create special series cpiwq3_mdy that contains Q3 values of cpiw_u_mdy and NAs everywhere else; need this for COLA values in long table 6
genr cpiwq3_mdy = cpiw_u_mdy
smpl @all if @quarter <>3
cpiwq3_mdy = NA
smpl @all

delete f* 		' deleting remaining series loaded from Moodys Excel.

%msg = "Done."
logmsg {%msg}
logmsg

' *** Load S&P Global (IHS Markit) data ***
%msg = "Loading quarterly data for S&P Global...." 
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all

wfopen %ihs_source		' %ihs_source is an EViews workfile.
' these series we need in quarterly frequency
copy {%ihs_file}::\gdp_0 {%thisfile}::quarterly\gdp_ihs				' nominal GDP
copy {%ihs_file}::\gdpr_0 {%thisfile}::quarterly\r_gdp12_ihs		' real GDP SPECIAL FOR TR24 and TR25-- rename this r_grp12_ihs; need this series ONLY to compute RTP (b/c potential GDP is given only with base year 2012)!!!
'copy {%ihs_file}::\gdpr_0 {%thisfile}::quarterly\r_gdp_ihs			' real GDP
copy {%ihs_file}::\gdpr17_0 {%thisfile}::quarterly\r_gdp_ihs		' real GDP SPECIAL FOR TR24 and TR25 -- S&P Global provides real GDP with 2017 base year under a different series name
copy {%ihs_file}::\gdpfer_0 {%thisfile}::quarterly\r_kgdp_ihs		' real potential GDP
'copy {%ihs_file}::\jpgdp_0 {%thisfile}::quarterly\pgdp_ihs			' GDP deflator
copy {%ihs_file}::\jpgdp17_0 {%thisfile}::quarterly\pgdp_ihs		' GDP deflator SPECIAL FOR TR24 and TR25 -- S&P Global provides GDP deflator with 2017 base year under a different series name
copy {%ihs_file}::\cpi_0 {%thisfile}::quarterly\cpiw_ihs				' CPI-U, seasonally adjusted
copy {%ihs_file}::\rmtcm10y_0 {%thisfile}::quarterly\nomintr_ihs	' 10yr Treasury rates, nominal

' these series we need in annual frequency, but IHS EViews file has only quarterly frequency for everything; thus we load them quarterly and then will transform to annual
copy {%ihs_file}::\ypcompwsd_0 {%thisfile}::quarterly\wsd_ihs	' wsd
copy {%ihs_file}::\ypcomp_0 {%thisfile}::quarterly\wss_ihs 		' wss = compensation of employees
copy {%ihs_file}::\hrnfpri_0 {%thisfile}::quarterly\ahrs_ihs			' avg wkly hrs
copy {%ihs_file}::\nlfc_0 {%thisfile}::quarterly\lc_ihs					' civ LF
copy {%ihs_file}::\ruc_0 {%thisfile}::quarterly\ru_ihs					' un rate
copy {%ihs_file}::\ehhc_0 {%thisfile}::quarterly\e_ihs					' employment
copy {%ihs_file}::\yppropadjf_0 {%thisfile}::quarterly\yf_ihs		' prop. income farm
copy {%ihs_file}::\yppropadjnf_0 {%thisfile}::quarterly\ynf_ihs		' prop. income nonfarm
copy {%ihs_file}::\nlfcfe {%thisfile}::quarterly\lc_fex_ihs				' FE labor force
copy {%ihs_file}::\rufe {%thisfile}::quarterly\ru_fe_ihs				' FE un rate
copy {%ihs_file}::\npciv16a_0 {%thisfile}::quarterly\n16o_ihs		' population

wfclose %ihs_source

wfselect {%thisfile}
pageselect quarterly
smpl @all
'genr rtp_ihs = r_gdp_ihs / r_kgdp_ihs		' compute rtp
genr rtp_ihs = r_gdp12_ihs / r_kgdp_ihs		' compute rtp SPECIAL FOR TR24 and TR25 -- use r_grp12_ihs from above to match the base year of 2012 for real and potential GDP
pgdp_ihs = pgdp_ihs/100						' re-scale PGDP 

genr cpiw_u_ihs = cpiw_ihs * CPIW_seas	' create non-SA CPI by using the seasonal adjustment factor (CPIW_seas) derived from budget data
' create special series cpiwq3_ihs that contains Q3 values of cpiw_u_ihs and NAs everywhere else; need this for COLA values in long table 6
genr cpiwq3_ihs = cpiw_u_ihs
smpl @all if @quarter <>3
cpiwq3_ihs = NA
smpl @all

%msg = "Done."
logmsg {%msg}
logmsg
' *** Done with IHS quarterly data


' *** Load CBO's data  -- Quarterly***
%msg = "Loading quarterly data for CBO ..." 
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all

' **** NEW VERSION -- loading data from CBO's EViews file"

wfopen %cbo_source		' %cbo_source is an EViews workfile.
' these series we need in quarterly frequency
copy {%cbo_file}::quarterly\real_gdp {%thisfile}::quarterly\r_gdp_cbo				' real GDP
copy {%cbo_file}::quarterly\real_potential_gdp {%thisfile}::quarterly\r_kgdp_cbo			' real potential GDP
copy {%cbo_file}::quarterly\gdp_price_index {%thisfile}::quarterly\pgdp_cbo			' GDP deflator
copy {%cbo_file}::quarterly\cpiu {%thisfile}::quarterly\cpiw_cbo					' CPI-U, seasonally adjusted, (CBO has no CPIW data, same as IHS and Moody's)
copy {%cbo_file}::quarterly\treasury_note_rate_10yr {%thisfile}::quarterly\nomintr_cbo		' 10yr Treasury rates, nominal

wfclose %cbo_source

'import %cbo_source range=%cbo_range_q colhead=!cbo_head namepos={%cbo_names} @freq q {%cbo_startq}	' this imports ALL series in the Excel file with CBO data. Since it was created by me, it contains only the series we need. 
																																		' The series in the Excel files are named by me, so they already have the names we need.
wfselect {%thisfile}
pageselect quarterly
smpl @all
cpiw_cbo = cpiw_cbo/100						' re-scale CPI
pgdp_cbo = pgdp_cbo/100						' re-scale PGDP
genr rtp_cbo = r_gdp_cbo / r_kgdp_cbo		' compute rtp
genr gdp_cbo = r_gdp_cbo * pgdp_cbo 		' compute nominal GDP

genr cpiw_u_cbo = cpiw_cbo * CPIW_seas	' create non-SA CPI by using the seasonal adjustment factor (CPIW_seas) derived from budget data
' create special series cpiwq3_cbo that contains Q3 values of cpiw_u_cbo and NAs everywhere else; need this for COLA values in long table 6
genr cpiwq3_cbo = cpiw_u_cbo
smpl @all if @quarter <>3
cpiwq3_cbo = NA
smpl @all

%msg = "Done."
logmsg {%msg}
logmsg
' *** Done with CBO quarterly data

' *** Load BlueChip data  -- Quarterly***
%msg = "Loading quarterly data for BlueChip ..." 
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all

import %bch_source range="data_q" colhead=5 namepos=last @freq q {%bch_startq}		' this imports ALL series in the Excel file with BleChip data (sheet 'data_q'). Since it was created by me, it contains only the series we need. 
																										' The series in the Excel files are named by me, so they already have the names we need.
																																		
wfselect {%thisfile}
pageselect quarterly
smpl @all
cpiw_bch = cpiw_bch/100						' re-scale CPI
pgdp_bch = pgdp_bch/100						' re-scale PGDP
genr gdp_bch = r_gdp_bch * pgdp_bch 		' compute nominal GDP		

genr cpiw_u_bch = cpiw_bch * CPIW_seas	' create non-SA CPI by using the seasonal adjustment factor (CPIW_seas) derived from budget data
' create special series cpiwq3_bch that contains Q3 values of cpiw_u_bch and NAs everywhere else; need this for COLA values in long table 6
genr cpiwq3_bch = cpiw_u_bch
smpl @all if @quarter <>3
cpiwq3_bch = NA
smpl @all

%msg = "Done."
logmsg {%msg}
logmsg
	
' *** Done with BlueChip quarterly data			

' ***** Done loading ALL quarterly data ***																											
																																		


'********** ANNUAL DATA **********
'Load annual data
wfselect {%thisfile}
pageselect annual
smpl @all

	'Current TR
	'loop through alts
	%msg = "Loading/creating annual data for TR" + @str(!TRyr) + "..."
	logmsg {%msg}
	
for %alt {%alt_cur}
	%tralt = @str(!TRyr-2000) + %alt
	
	wfopen %abank_alt{%alt}
	pageselect a
	for %ser {%an_list} 	
		copy {%abank{%alt}}::a\{%ser} {%thisfile}::annual\{%ser}_{%tralt} 		' copy from a-bank and rename to indicate TR and alt
	next
	
	for %ser {%gdp_list} 	' copy GDP-related series from abank and rename accordingly
		%test = @left(%ser, 1)
		if %test = "g" then
			copy {%abank{%alt}}::a\{%ser} {%thisfile}::annual\r_gdp_{%tralt} 
		endif
		if %test = "k" then
			copy {%abank{%alt}}::a\{%ser} {%thisfile}::annual\r_kgdp_{%tralt} 
		endif
	next
	wfselect {%abank{%alt}}
	pageselect m
	copy(c=an) {%abank{%alt}}::m\nomintr {%thisfile}::annual\nomintr_{%tralt}
	wfclose {%abank{%alt}}
	
	wfopen %dbank_alt{%alt}
	pageselect a
	for %ser {%d_list} 	
		copy {%dbank{%alt}}::a\{%ser} {%thisfile}::annual\{%ser}_{%tralt} 		' copy from d-bank and rename to indicate TR and alt
	next
	wfclose {%dbank{%alt}}
	
	wfselect {%thisfile}
	pageselect annual
	smpl @all
	rename beninc_{%tralt} cola_{%tralt}
	rename ws_{%tralt} wsd_{%tralt} 	' SPECIAL TR23 -- we are using WS series in place of WSD, but it needs to be named WSD for all other loops to run

next

%msg = "Done."
logmsg {%msg}
logmsg

	'Previous-year TR
	'loop through alts
	%msg = "Loading/creating annual data for TR" + @str(!TRpr) + "..."
	logmsg {%msg}
	
for %alt 1 2 3	
	%tralt = @str(!TRpr-2000) + %alt
		
	' *** WORKFILE version -- for TR22 and later
	wfopen %abank_pr_alt{%alt}
	pageselect a
	for %ser {%an_list} 	
		copy {%abank{%alt}pr}::a\{%ser} {%thisfile}::annual\{%ser}_{%tralt} 		' copy from a-bank and rename to indicate TR and alt
	next
	
	for %ser {%gdp_list_pr} 	' copy GDP-related series from abank and rename accordingly
		%test = @left(%ser, 1)
		if %test = "g" then
			copy {%abank{%alt}pr}::a\{%ser} {%thisfile}::annual\r_gdp_{%tralt} 
		endif
		if %test = "k" then
			copy {%abank{%alt}pr}::a\{%ser} {%thisfile}::annual\r_kgdp_{%tralt} 
		endif
	next
	wfselect {%abank{%alt}pr}
	pageselect m
	copy(c=an) {%abank{%alt}pr}::m\nomintr {%thisfile}::annual\nomintr_{%tralt}
	
	wfclose {%abank{%alt}pr}
	
	wfopen %dbank_pr_alt{%alt}
	pageselect a
	for %ser {%d_list} 	
		copy {%dbank{%alt}pr}::a\{%ser} {%thisfile}::annual\{%ser}_{%tralt} 		' copy from d-bank and rename to indicate TR and alt
	next
	wfclose {%dbank{%alt}pr}
	
 	wfselect {%thisfile}
 	pageselect annual
 	smpl @all
 	rename beninc_{%tralt} cola_{%tralt}
 	rename ws_{%tralt} wsd_{%tralt} 	' SPECIAL TR23 -- we are using WS series in place of WSD, but it needs to be named WSD for all other loops to run

next

%msg = "Done."
logmsg {%msg}
logmsg


'Outside forecasters
' creating placeholder series for now
wfselect {%thisfile}
pageselect annual
smpl @all
for %s {%global_list}
	series {%s}_ihs		'S&P Global (formerly IHS Markit)
	series {%s}_mdy		'Moody's			
	series {%s}_bgt		'Budget
	series {%s}_cbo		'CBO
	series {%s}_bch		'BlueChip
next

' Budget
%msg = "Loading/creating annual data for Budget ..."
logmsg {%msg}

wfselect {%thisfile}	
pageselect annual
smpl @all
import %omb range="GDP_Annual"!{%gdp_ann} colhead=1 namepos=first @freq a !yr_bgt 	'the cell range {%gdp_ann} is specified above at the start of program; this command relies on the "invisible" variable names located in row 9 in the budget assumption Excel file ('namepos=first' reads these as the variables names for the workfile). 
' rename to indicate sourse as bgt (budget)
genr r_gdp_bgt = gdp_real 
genr ru_bgt = unempl_rate
delete gdp_nom* gdp_re* gdp_price* unem* 	'delete remaning unnecessary series

'' SPECIAL FOR TR23 -- reading LF and employment from Excel file (we usually read this from aombXX file)
'import %omb range="Labor_Annual"!B8:C21 colhead=1 namepos=last @freq a !yr_bgt 
'genr lc_bgt = civ_labor_force 
'genr e_bgt = civ_employed
'delete civ_labor_force civ_employed 

import %omb range="Pers_Inc_Annual"!{%pi_ann} colhead=1 namepos=first @freq a !yr_bgt 	'the cell range {%pi_ann} is specified above at the start of program; this command relies on the "invisible" variable names located in row 9 in the budget assumption Excel file
genr wsd_bgt = wages_salaries 						' wages and salaries
genr wsd_to_gdp_bgt = wages_salaries_pct
genr wss_bgt = compensation 							' employee compensation
delete wages* compensation* 								'deleting remaning unnecessary series

'projected COLAs
import %omb range="COLAs"!{%cola_ann} colhead=0 names="cola_bgt" @freq a !yr_bgt 	'the cell range {%cola_ann} is specified above at the start of program. Note that B8 is labeled in Budget file as 'cola for Jan 2018' but here I call it COLA for 2017, and similarly for all later years.

' copy from OMB workfile and rename to indicate source
wfselect {%thisfile}
pageselect annual
smpl @all

wfopen %budget_path
pageselect a
copy {%budget}::a\prod {%thisfile}::annual\prod_bgt 
copy {%budget}::a\prod {%thisfile}::annual\prod_fex_bgt 	' for budget, we show prod_fex (full-empl productivity) only for yrs where rtp=1, at which point prod_fex=prod
copy {%budget}::a\lc {%thisfile}::annual\lc_bgt
copy {%budget}::a\lc {%thisfile}::annual\lc_fex_bgt 		' for budget, we show lc_fex (full-empl labor force) only for yrs where rtp=1, at which point lc_fex=lc
copy {%budget}::a\ahrs {%thisfile}::annual\ahrs_bgt
copy {%budget}::a\e {%thisfile}::annual\e_bgt
copy {%budget}::a\edmil {%thisfile}::annual\edmil_bgt
copy {%budget}::a\yf {%thisfile}::annual\yf_bgt
copy {%budget}::a\ynf {%thisfile}::annual\ynf_bgt
copy {%budget}::a\p16o {%thisfile}::annual\p16o_bgt
copy {%budget}::a\p16o_asa {%thisfile}::annual\p16o_asa_bgt
copy {%budget}::a\ru_asa {%thisfile}::annual\ru_asa_bgt
wfclose {%budget}

wfselect {%thisfile}
pageselect annual
smpl @all

'copy series from quarterly and monthly into annual
copy(o, c=an) monthly\nomintr_bgt annual\
copy(o, c=an) monthly\cpiw_u_bgt annual\
copy(o, c=an) monthly\cpiw_bgt annual\
copy(o, c=an) quarterly\nomintr_bgt annual\
copy(o, c=an) quarterly\rtp_bgt annual\
copy(o, c=an) quarterly\gdp_bgt annual\
copy(o, c=an) quarterly\pgdp_bgt annual\

genr r_kgdp_bgt = r_gdp_bgt/rtp_bgt	' generate potential GDP from real GDP and rtp

%msg = "Done."
logmsg {%msg}
logmsg

' *** Load Moody's Analytics data  -- Annual***
%msg = "Loading/creating annual data for Moody's ..."
logmsg {%msg}

wfselect {%thisfile}
pageselect annual
smpl @all

import %mdy_source range=%mdy_range_a colhead=!mdy_head namepos={%mdy_names} @freq a {%mdy_starta}  ' this impoart all annual series from Moody's file

' NOTE1: all series names in Moody's Excel files start with "F". AT THIS POINT in the workfile, there are NO other series (or any objects) whose name starts with F. Once we rename the Moody's series we need, can delete the rest by doing simply: delete f*.
' NOTE2: when importing series from Moody's Excel file, EViews has populated some of the fields in Label. Specifically, it 'Description' field it put in a very useful description combining rows 2 through 7 of Excel. Here is an example from CPIW:
'  "Baseline Scenario (November 2018): CPI: Urban Wage Earner - All Items, (Index 1982-84=100, SA) U.S. Bureau of Labor Statistics (BLS); Moody's Analytics Forecasted None AVERAGED IUSA 11/05/2018"

' rename series to indicate Moody's as source; this is done via genr command so that the newly renamed series will replace the existing series filled with NAs that were created as placeholder earlier.
' Note: doing this via genr comment does NOT transfer the fields in Label that were automatically filled in. using 'rename' would have preserved them. I might consider changing this to 'rename' and eliminating the placeholder series for Moody's, but it might create other problems (we need placeholders to exist for other loops to run.)

genr cpiw_mdy = fcpiw / 100 		' CPIW SA level
genr pgdp_mdy = fpdpgdp / 100 	' PGDP level			
genr gdp_mdy = fgdp 					' nominal GDP			
genr r_gdp_mdy = fgdp$ 				' real GDP
genr r_kgdp_mdy = fgdp$_pot		' real potential GDP	
genr nomintr_mdy = frgt10y 			' nominal interest rate, 10yr Treasurys	
genr lc_mdy = flbf 						' civ LF	
genr e_mdy = flbe 						' employment
genr ru_mdy = flbr 						' un. rate
genr n16o_mdy = flbp					' civ. noninst. pop
genr p16o_mdy = flbt / 100			' LFPR 16+ in the form 0.6345 etc.
genr wsd_mdy = fypewsq 			' wages and salaries
genr wss_mdy = fyle 						' compensation of employees
genr lc_fex_mdy = flbf_pot 			' potential labor force	
genr yf_mdy = fypeppfrq 				' farm prop. income
genr ynf_mdy = fypeppnfq 			' nonfarm prop. income
genr ahrs_mdy = fpcnbawh 			' avg. weekly hrs --- NOT SURE about this one
genr ru_fe_mdy = fnairu				' FE un. rate (for Moody's we use NAIRU)

'copy series from quarterly into annual
copy(o, c=an) quarterly\cpiw_u_mdy annual\		' CPIW NSA series
copy(o, c=l) quarterly\cpiwq3_mdy annual\		' copy Qtr3 value of CPI(NSA) as annual; this is used to compute COLA below 

wfselect {%thisfile}
pageselect annual
smpl @all
genr rtp_mdy = r_gdp_mdy / r_kgdp_mdy	
genr cola_mdy = ((cpiwq3_mdy / cpiwq3_mdy(-1)) -1) *100
genr wsd_to_gdp_mdy = 100* (wsd_mdy / gdp_mdy)
genr prod_mdy = r_gdp_mdy / e_mdy

delete f* 		' delete remaining series loaded from Moodys Excel.

%msg = "Done."
logmsg {%msg}
logmsg

' *** Load S&P Global (IHS Markit) data -- Annual ***
%msg = "Loading/creating annual data for S&p Global ..."
logmsg {%msg}

wfselect {%thisfile}
pageselect annual
smpl @all

'copy series from quarterly into annual; IHS has only quarterly data, which we loaded above into the 'quarterly' page. here we only transform those series to annual.
copy(o, c=an) quarterly\gdp_ihs annual\
copy(o, c=an) quarterly\r_gdp_ihs annual\
copy(o, c=an) quarterly\r_gdp12_ihs annual\ 	' SPECIAL FOR TR24 and TR25 -- copy in REAL GDP with base 2012; 
copy(o, c=an) quarterly\r_kgdp_ihs annual\
copy(o, c=an) quarterly\pgdp_ihs annual\
copy(o, c=an) quarterly\nomintr_ihs annual\
copy(o, c=an) quarterly\cpiw_u_ihs annual\
copy(o, c=an) quarterly\cpiw_ihs annual\

copy(o, c=an) quarterly\wsd_ihs annual\
copy(o, c=an) quarterly\wss_ihs annual\
copy(o, c=an) quarterly\ahrs_ihs annual\
copy(o, c=an) quarterly\lc_ihs annual\
copy(o, c=an) quarterly\ru_ihs annual\
copy(o, c=an) quarterly\e_ihs annual\
copy(o, c=an) quarterly\yf_ihs annual\
copy(o, c=an) quarterly\ynf_ihs annual\
copy(o, c=an) quarterly\lc_fex_ihs annual\
copy(o, c=an) quarterly\ru_fe_ihs annual\

copy(o, c=an) quarterly\n16o_ihs annual\

copy(o, c=l) quarterly\cpiwq3_ihs annual\cpiwq3_ihs	' copy Qtr3 value of CPI(NSA) as annual; this is used to compute COLA below 

wfselect {%thisfile}
pageselect annual
smpl @all
'rtp_ihs = r_gdp_ihs / r_kgdp_ihs
genr rtp_ihs = r_gdp12_ihs / r_kgdp_ihs		' compute rtp SPECIAL FOR TR24 and TR25 -- use r_grp12_ihs from above to match the base year of 2012 for real and potential GDP

prod_ihs = r_gdp_ihs / e_ihs
prod_fex_ihs = r_kgdp_ihs / lc_fex_ihs/(1 - ru_fe_ihs/100)			
wsd_to_gdp_ihs = 100* (wsd_ihs / gdp_ihs)
cola_ihs = ((cpiwq3_ihs / cpiwq3_ihs(-1)) -1) *100

%msg = "Done."
logmsg {%msg}
logmsg


' *** Load CBO data -- Annual ***
%msg = "Loading/creating annual data for CBO ..."
logmsg {%msg}

wfselect {%thisfile}
pageselect annual
smpl @all

' Loading data from CBO's EViews file
wfopen %cbo_source		' %cbo_source is an EViews workfile.

' series annual 
copy {%cbo_file}::annual\wages_and_salaries {%thisfile}::annual\wsd_cbo		' wsd
copy {%cbo_file}::annual\earnings_as_a_share_of_compensation {%thisfile}::annual\earn2comp_cbo		'ratio of earnings to compensation
copy {%cbo_file}::annual\labor_force {%thisfile}::annual\lc_cbo			' civ LF
copy {%cbo_file}::annual\unemployment_rate {%thisfile}::annual\ru_cbo		' un rate
copy {%cbo_file}::annual\empl_civ_16yo {%thisfile}::annual\e_cbo			' employment
copy {%cbo_file}::annual\prop_income {%thisfile}::annual\y_cbo			' prop. income TOTAL (farm + nonfarm)
copy {%cbo_file}::annual\potential_lf {%thisfile}::annual\lc_fex_cbo			' FE labor force
copy {%cbo_file}::annual\noncyclical_rate_of_unemployment {%thisfile}::annual\ru_fe_cbo				' FE un rate

copy {%cbo_file}::annual\cpiu {%thisfile}::annual\cpiw_cbo				' CPI-U, seasonally adjusted, (CBO has no CPIW data, same as IHS and Moody's)
copy {%cbo_file}::annual\output_per_hr_nfb {%thisfile}::annual\prod_cbo		' productivity (CBO provides "output per hr in NFB sector")
copy {%cbo_file}::annual\gdp {%thisfile}::annual\gdp_cbo				' nominal GDP
copy {%cbo_file}::annual\real_gdp {%thisfile}::annual\r_gdp_cbo			' real GDP
copy {%cbo_file}::annual\real_potential_gdp {%thisfile}::annual\r_kgdp_cbo		' real potential GDP
copy {%cbo_file}::annual\gdp_price_index {%thisfile}::annual\pgdp_cbo		' GDP deflator
copy {%cbo_file}::annual\population_civ_16yo {%thisfile}::annual\n16o_cbo		' population
copy {%cbo_file}::annual\treasury_note_rate_10yr {%thisfile}::annual\nomintr_cbo	' 10yr Treasury rates, nominal

copy {%cbo_file}::annual\avg_weekly_hours_growth {%thisfile}::annual\ahrs_gr_cbo	' avg wkly hrs GR RATE; CBO provided the growth rate (but not the level) directly in their EViews workfile.

wfclose %cbo_source

wfselect {%thisfile}
pageselect quarterly
smpl @all

copy(o, c=an) quarterly\cpiw_u_cbo annual\
copy(o, c=l) quarterly\cpiwq3_cbo annual\cpiwq3_cbo	' copy Qtr3 value of CPI(NSA) as annual; this is used to compute COLA below. 

wfselect {%thisfile}
pageselect annual
smpl @all
p16o_cbo = lc_cbo/n16o_cbo 			' compute LFPR
rtp_cbo = r_gdp_cbo / r_kgdp_cbo		' create RTP
pgdp_cbo = pgdp_cbo/100				' re-scale PGDP
cpiw_cbo = cpiw_cbo/100				' re-scale CPI
prod_fex_cbo = r_kgdp_cbo / lc_fex_cbo/(1 - ru_fe_cbo/100)			
wsd_to_gdp_cbo = 100* (wsd_cbo / gdp_cbo)
cola_cbo = ((cpiwq3_cbo / cpiwq3_cbo(-1)) -1) *100
epop_cbo = 100 * e_cbo / n16o_cbo

genr r_avg_earn_cbo = (wsd_cbo + y_cbo)/(e_cbo)/cpiw_u_cbo  ' NOTE: CBO provided total prop. income, y_cbo, directly in their file, so no need to add YF + YNF.
genr acwa_cbo = (wsd_cbo + y_cbo)/(e_cbo)			     			   
genr acwa_gr_cbo = @pca(acwa_cbo)

series r_wage_diff_cbo	' series filled with NAs
series ahrs_gr_cbo_keep = ahrs_gr_cbo		' SPECIAL for CBO -- save ahrs_gr series loaded from CBO's EViews file so that they are not replaces in the loop that follows.

series prod_tote_cbo = r_gdp_cbo / e_cbo  	' Special for CBO; this 'productivity for total economy' is computed but will not be used directly in the tables; 
																				' prod_cbo = "output per hr in NFB" will be used in the tables
																				' this series we will use ONLY to create the implied growth rate of total economy productivity (see below)																																		

%msg = "Done."
logmsg {%msg}
logmsg


' *** Load BlueChip data  -- Annual***
%msg = "Loading annaul data for BlueChip ..." 
logmsg {%msg}

wfselect {%thisfile}
pageselect annual
smpl @all

' First, import all the annual data; these are mostly growth rates, and then the levels for RU and nomintr
import %bch_source range="data_a" colhead=5 namepos=last @freq a {%bch_starta}		' this imports ALL series in the Excel file with BlueChip data (sheet 'data_a'). Since it was created by me, it contains only the series we need. 
																										' The series in the Excel files are named by me, so they already have the names we need.

' now, copy the data for the LEVEL series we have in quarterly frequency into annual
' these exist for only a couple of years at the start of the sample; and they DO NOT overlap with the years we just imported form Excel above
' need to do a MERGE (option m after copy), else it will erase the values we just loaded above.

copy(m, c=an) quarterly\r_gdp_bch annual\
copy(m, c=an) quarterly\gdp_bch annual\
copy(m, c=an) quarterly\pgdp_bch annual\
copy(m, c=an) quarterly\cpiw_bch annual\
copy(m, c=an) quarterly\cpiw_u_bch annual\
copy(m, c=an) quarterly\nomintr_bch annual\
copy(m, c=an) quarterly\ru_bch annual\

copy(m, c=l) quarterly\cpiwq3_bch annual\cpiwq3_bch	' copy Qtr3 value of CPI(NSA) as annual; this is used to compute COLA below.

wfselect {%thisfile}
pageselect annual
smpl @all

cola_bch = ((cpiwq3_bch / cpiwq3_bch(-1)) -1) *100

' SPECIAL for BCH
' preserve the ANNUAL values for GROWTH RATES for r_gdp_gr, pgdp_gr, and cpiw_gr
' we load these growth rates directly from BCEI file; later on this program will attempt to compute them from level, which would overwrite the values with NAs; we need to preserve them to restore them later

for %ser r_gdp_gr_bch pgdp_gr_bch cpiw_gr_bch
	series {%ser}_keep = {%ser}
next

%msg = "Done."
logmsg {%msg}
logmsg


'	***** DONE loading and renaming ALL data

%msg = "Done loading and renaming all data."
logmsg {%msg}
logmsg


' *** Now COMPUTE various series using the data we loaded *****

'***** generate necessary series *****
'quarterly		
wfselect {%thisfile}	
pageselect quarterly	
smpl @all		
%msg = "Generating necessary quarterly series ..."
logmsg {%msg}

' Current TR
%msg = "for TR" + @str(!TRyr) + "..."
logmsg {%msg}

for %alt {%alt_cur}
	%tralt = @str(!TRyr-2000) + %alt
	genr prod_{%tralt} = r_gdp_{%tralt} / hrs_{%tralt}
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})	
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr rintr_{%tralt} = ((nomintr_{%tralt}(-4)/100/2+1)^2/(cpiw_{%tralt}/cpiw_{%tralt}(-4))-1)*100
	' additional series for internal use only
	genr e_gr_{%tralt} = @pca(e_{%tralt})
	genr epop_{%tralt} = 100 * (e16o_{%tralt} / n16o_{%tralt})

	genr wsd_to_gdp_{%tralt} = 100*wsd_{%tralt}/gdp_{%tralt}
	genr lbrshr_{%tralt} = 100*(wss_{%tralt} + y_{%tralt}) / gdp_{%tralt}
	genr r_avg_earn_{%tralt} = (wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt}
	genr r_avg_earn_gr_{%tralt} = @pca(r_avg_earn_{%tralt}) 
	genr ahrs_gr_{%tralt} = @pca(ahrs_{%tralt})
	genr price_diff_{%tralt} = @pca(pgdp_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr lc_gr_{%tralt} = @pca(lc_{%tralt})
	genr prod_gr_{%tralt} = @pca(prod_{%tralt})
	genr lc_fex_gr_{%tralt} = @pca(lc_fex_{%tralt})
	genr prod_fex_gr_{%tralt} = @pca(prod_fex_{%tralt})
next

' Previous-yr TR
%msg = "for TR" + @str(!TRpr) + "..."
logmsg {%msg}

for %alt 1 2 3
	%tralt = @str(!TRpr-2000) + %alt
	genr prod_{%tralt} = r_gdp_{%tralt} / hrs_{%tralt}
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})	
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr rintr_{%tralt} = ((nomintr_{%tralt}(-4)/100/2+1)^2/(cpiw_{%tralt}/cpiw_{%tralt}(-4))-1)*100
	' additional series for internal use only
	genr e_gr_{%tralt} = @pca(e_{%tralt})
	genr epop_{%tralt} = 100 * (e16o_{%tralt} / n16o_{%tralt})

	genr wsd_to_gdp_{%tralt} = 100*wsd_{%tralt}/gdp_{%tralt}
	genr lbrshr_{%tralt} = 100*(wss_{%tralt} + y_{%tralt}) / gdp_{%tralt}
	genr r_avg_earn_{%tralt} = (wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt}
	genr r_avg_earn_gr_{%tralt} = @pca(r_avg_earn_{%tralt}) 
	genr ahrs_gr_{%tralt} = @pca(ahrs_{%tralt})
	genr price_diff_{%tralt} = @pca(pgdp_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr lc_gr_{%tralt} = @pca(lc_{%tralt})
	genr prod_gr_{%tralt} = @pca(prod_{%tralt})
	genr lc_fex_gr_{%tralt} = @pca(lc_fex_{%tralt})
	genr prod_fex_gr_{%tralt} = @pca(prod_fex_{%tralt})
next	

' Outside forecasters -- quarterly
%msg = "for outside forecasters ..."
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all
' Some special computations that vary by source:
' Budget
genr epop_bgt = (1-ru_bgt/100) * p16o_bgt * 100		'compute epop from ru and lfpr
genr r_avg_earn_bgt = (wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt)/cpiw_u_bgt
genr acwa_bgt = (wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt)		' note that we use avg earnings for acwa in Budget
genr acwa_gr_bgt = @pca((wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt))
genr lbrshr_bgt = 100*(wss_bgt + yf_bgt + ynf_bgt) / gdp_bgt		' labor share


' IHS
genr prod_ihs = r_gdp_ihs / e_ihs				' generate productivity
genr prod_fex_ihs = r_kgdp_ihs / lc_fex_ihs/(1 - ru_fe_ihs/100)			
genr r_avg_earn_ihs = (wsd_ihs + yf_ihs + ynf_ihs)/(e_ihs)/cpiw_u_ihs
genr epop_ihs = 100 * e_ihs / n16o_ihs		' compute e-to-pop ratio
genr p16o_ihs = lc_ihs / n16o_ihs				' compute LFPR
genr acwa_ihs = (wsd_ihs + yf_ihs + ynf_ihs)/(e_ihs)			' note that we use avg earnings for acwa for IHS
genr acwa_gr_ihs = @pca(acwa_ihs)
genr lbrshr_ihs = 100*(wss_ihs + yf_ihs + ynf_ihs) / gdp_ihs 		' labor share

'Moodys
genr prod_mdy = r_gdp_mdy / e_mdy
genr acwa_mdy = (wsd_mdy + yf_mdy + ynf_mdy)/(e_mdy)	' note that we use avg earnings for acwa for MDY
genr r_avg_earn_mdy = (wsd_mdy + yf_mdy + ynf_mdy)/(e_mdy)/cpiw_u_mdy
genr prod_fex_mdy = r_kgdp_mdy / lc_fex_mdy/(1 - ru_fe_mdy/100)
genr acwa_gr_mdy = @pca(acwa_mdy)
series r_wage_diff_mdy	' series filled with NAs
genr lbrshr_mdy = 100*(wss_mdy + yf_mdy + ynf_mdy) / gdp_mdy 	' labor share

genr epop_mdy = 100 * e_mdy / n16o_mdy		' compute e-to-pop ratio

' CBO -- nothing needed

for %src bgt ihs mdy cbo bch
	genr r_gdp_gr_{%src} = @pca(r_gdp_{%src})
	genr r_kgdp_gr_{%src} = @pca(r_kgdp_{%src})	
	genr cpiw_u_gr_{%src} = @pca(cpiw_u_{%src})
	genr cpiw_gr_{%src} = @pca(cpiw_{%src})	
	genr pgdp_gr_{%src} = @pca(pgdp_{%src})

	genr price_diff_{%src} = @pca(pgdp_{%src}) - @pca(cpiw_u_{%src})
	genr lc_gr_{%src} = @pca(lc_{%src})
	genr prod_gr_{%src} = @pca(prod_{%src})
	genr lc_fex_gr_{%src} = @pca(lc_fex_{%src})
	genr prod_fex_gr_{%src} = @pca(prod_fex_{%src})
	genr r_avg_earn_gr_{%src} = @pca(r_avg_earn_{%src})	
	genr ahrs_gr_{%src} = @pca(ahrs_{%src})

	genr rintr_{%src} = ((nomintr_{%src}(-4)/100/2+1)^2/(cpiw_{%src}/cpiw_{%src}(-4))-1)*100
	' additional series for internal use only
	genr e_gr_{%src} = @pca(e_{%src})
	genr wsd_to_gdp_{%src} = 100*(wsd_{%src} / gdp_{%src})
next	


' Special for Implied growth of total-economy productivity
prod_gr_ihs = prod_gr_ihs - ahrs_gr_ihs
prod_fex_gr_ihs = prod_fex_gr_ihs - ahrs_gr_ihs 		

prod_gr_mdy = prod_gr_mdy - ahrs_gr_mdy
prod_fex_gr_mdy = prod_fex_gr_mdy - ahrs_gr_mdy 	

' Nothing for CBO -- CBO does not provide quarterly productivity or hours series to us, only annual.		

%msg = "Done."
logmsg {%msg}
logmsg


' *** Create labels for all quarterly series ***
%msg = "Creating labels for quarterly series ..."
logmsg {%msg}

%col_list_lim = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3" ' +ihs mdy cbo
' only create labels for TR and Budget, the rest have labels loaded from their respective source files (this may no longer be the case, since we use genr to rename the series instead of rename -- think about changing this approach)

for %src {%col_list_lim}
	cpiw_gr_{%src}.label(d) Percent change in CPI-W (seasonally adjusted)
	cpiw_gr_{%src}.label(u) percentage points
	
	cpiw_u_{%src}.label(d) CPI-W (level, not seasonally adjusted)	
	cpiw_u_{%src}.label(u) 1982-1984 = 1	
	
	cpiw_u_gr_{%src}.label(d) Percent change in CPI-W (not seasonally adjusted)
	cpiw_u_gr_{%src}.label(u) percentage points
	
	nomintr_{%src}.label(d) Nominal interest rate
	nomintr_{%src}.label(u) percentage points
	
	pgdp_{%src}.label(d) GDP deflator
	if !by_cur = !by_pr then
		%label = @str(!by_cur) + " = 1"
		pgdp_{%src}.label(u) {%label} 
	endif
	
	pgdp_gr_{%src}.label(d) Percent change in GDP deflator (SAAR)
	pgdp_gr_{%src}.label(u) percentage points
	
	r_gdp_{%src}.label(d) Real GDP (SAAR)
	if !by_cur = !by_pr then
		%label = "Billions of chained " + @str(!by_cur) + " dollars"
		r_gdp_{%src}.label(u) {%label} 
	endif
	
	r_gdp_gr_{%src}.label(d) Percent change in real GDP 
	r_gdp_gr_{%src}.label(u) percentage points
	
	r_kgdp_{%src}.label(d) Real potential GDP (SAAR)
	if !by_cur = !by_pr then
		%label = "Billions of chained " + @str(!by_cur) + " dollars"
		r_kgdp_{%src}.label(u) {%label} 
	endif
	
	r_kgdp_gr_{%src}.label(d) Percent change in real potential GDP 
	r_kgdp_gr_{%src}.label(u) percentage points
	
	rintr_{%src}.label(d) Real interest rate
	rintr_{%src}.label(u) percentage points
	rintr_{%src}.label(r) Computed as realized or expected real yield on securities issued in the fourth prior quarter
	
	rtp_{%src}.label(d) Ratio of real to potential GDP
	
	' additional series for internal use only
	e_{%src}.label(d) Employment (average annual, CPS concept), 16+
	e_{%src}.label(u) millions of people
	
	ru_asa_{%src}.label(d) Average annual civilian unemployment rate, age-sex-adjusted
	ru_asa_{%src}.label(u) percentage points
	
	ru_{%src}.label(d) Average annual civilian unemployment rate
	ru_{%src}.label(u) percentage points
	
	lbrshr_{%src}.label(d) Share of labor compensation in GDP
	lbrshr_{%src}.label(u) percentage points
next	

'cpiw_seas.label(d) Seasonal adjustment factor for CPIW (derived from Budget forecast)
cpiw_seas.label(d) Seasonal adjustment factor for CPIW (derived from current TR alt 2) 	' SPECIAL FOR TR23 and TR24 -- we use TR seasonal factors for TR23 instead of the Budegt seaonal factors

' labels that vary with base year -- pgdp, r_grp, r_kgdp 
' only create labels for TRs, the rest have labels loaded from their respective source files
if !by_cur <> !by_pr then
	' *current TR labels*
	%alt1 = @str(!TRyr-2000)+"1"
	%alt2 = @str(!TRyr-2000)+"2"
	%alt3 = @str(!TRyr-2000)+"3"
	'pgdp
	%label = @str(!by_cur) + " = 1"
	pgdp_{%alt1}.label(u) {%label}
	pgdp_{%alt2}.label(u) {%label}
	pgdp_{%alt3}.label(u) {%label} 
	'r_gdp
	%label = "Billions of chained " + @str(!by_cur) + " dollars"
	r_gdp_{%alt1}.label(u) {%label}
	r_gdp_{%alt2}.label(u) {%label}
	r_gdp_{%alt3}.label(u) {%label} 
	'r_kgdp
	r_kgdp_{%alt1}.label(u) {%label}
	r_kgdp_{%alt2}.label(u) {%label}
	r_kgdp_{%alt3}.label(u) {%label}  
	' *previous TR labels*
	%alt1 = @str(!TRpr-2000)+"1"
	%alt2 = @str(!TRpr-2000)+"2"
	%alt3 = @str(!TRpr-2000)+"3"
	'pgdp
	%label = @str(!by_pr) + " = 1"
	pgdp_{%alt1}.label(u) {%label}
	pgdp_{%alt2}.label(u) {%label}
	pgdp_{%alt3}.label(u) {%label} 
	'r_gdp
	%label = "Billions of chained " + @str(!by_pr) + " dollars"
	r_gdp_{%alt1}.label(u) {%label}
	r_gdp_{%alt2}.label(u) {%label}
	r_gdp_{%alt3}.label(u) {%label} 
	'r_kgdp
	r_kgdp_{%alt1}.label(u) {%label}
	r_kgdp_{%alt2}.label(u) {%label}
	r_kgdp_{%alt3}.label(u) {%label}  
endif

' indicate source
for %ser {%tables_list}
	' outside forecaster
	%bgt_txt = "FY " + %FY + " Budget Projections, released " + %date_bgt
	%ihs_txt = "S&P Global Projections, released " + %date_ihs
	%cbo_txt = "CBO Projections, released " + %date_cbo
	%mdy_txt = "Moody's Analytics Projections, released " + %date_mdy
	%bch_txt = "Blue Chip Economic Indicators, released " + %date_bch
	{%ser}_bgt.label(s) {%bgt_txt}
	{%ser}_ihs.label(s) {%ihs_txt}
	{%ser}_cbo.label(s) {%cbo_txt}
	{%ser}_mdy.label(s) {%mdy_txt}
	{%ser}_bch.label(s) {%bch_txt}
	' TRs
	for %a 1 2 3 
		%tr_c = @str(!TRyr-2000)+%a
		%tr_c_txt = "Projections from TR" + @str(!TRyr) + ", alt " + %a
		%tr_p = @str(!TRpr-2000)+%a
		%tr_p_txt = "Projections from TR" + @str(!TRpr) + ", alt " + %a
		
		{%ser}_{%tr_c}.label(s) {%tr_c_txt}
		{%ser}_{%tr_p}.label(s) {%tr_p_txt}
	next
next

%msg = "Done."
logmsg {%msg}
logmsg
' *** Done with labels for quarterly series	 			
	 		
	 			
' * Annual
wfselect {%thisfile}
pageselect annual
smpl @all
%msg = "Generating necessary annual series ..."
logmsg {%msg}

' Current TR -- annual
for %alt {%alt_cur}
	%tralt = @str(!TRyr-2000) + %alt
	'copy some series from quarterly (as annual averages) 
	copy(c=an) quarterly\rintr_{%tralt} annual\  	' quarterly rintr series, transform to annual as average
	copy(c=an) quarterly\cpiw_{%tralt} annual\  	' cpiw series, transform to annual as average
	
	genr prod_{%tralt} = r_gdp_{%tralt} / hrs_{%tralt}
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})	
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr wsd_to_gdp_{%tralt} = 100*wsd_{%tralt}/gdp_{%tralt}
	genr r_avg_earn_{%tralt} = (wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt}
	genr r_avg_earn_gr_{%tralt} = @pca(r_avg_earn_{%tralt}) '(wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt})
	genr acwa_gr_{%tralt} = @pca(acwa_{%tralt})
	genr r_wage_diff_{%tralt} = ((1+@pch(acwa_{%tralt})) / (1+@pch(cpiw_u_{%tralt})) -1)*100
	genr ahrs_gr_{%tralt} = @pca(ahrs_{%tralt})
	genr price_diff_{%tralt} = @pca(pgdp_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr lc_gr_{%tralt} = @pca(lc_{%tralt})
	genr prod_gr_{%tralt} = @pca(prod_{%tralt})
	genr lc_fex_gr_{%tralt} = @pca(lc_fex_{%tralt})
	genr prod_fex_gr_{%tralt} = @pca(prod_fex_{%tralt})
	' additional series for internal use only
	genr lbrshr_{%tralt} = 100*(wss_{%tralt} + y_{%tralt}) / gdp_{%tralt}
	genr e_gr_{%tralt} = @pca(e_{%tralt})
	genr te_gr_{%tralt} = @pca(te_{%tralt})
	genr tcea_gr_{%tralt} = @pca(tcea_{%tralt})
	genr epop_{%tralt} = 100 * (e16o_{%tralt} / n16o_{%tralt})
next

' Previous-yr TR -- annual
for %alt 1 2 3
	%tralt = @str(!TRpr-2000) + %alt
	'copy some series from quarterly (as annual averages) 
	copy(c=an) quarterly\rintr_{%tralt} annual\  	' quarterly rintr series, transform to annual as average
	copy(c=an) quarterly\cpiw_{%tralt} annual\  	' cpiw series, transform to annual as average
	
	genr prod_{%tralt} = r_gdp_{%tralt} / hrs_{%tralt}
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})	
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr wsd_to_gdp_{%tralt} = 100*wsd_{%tralt}/gdp_{%tralt}
	genr r_avg_earn_{%tralt} = (wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt}
	genr r_avg_earn_gr_{%tralt} = @pca(r_avg_earn_{%tralt}) '(wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt})
	genr acwa_gr_{%tralt} = @pca(acwa_{%tralt})
	genr r_wage_diff_{%tralt} = ((1+@pch(acwa_{%tralt})) / (1+@pch(cpiw_u_{%tralt})) -1)*100
	genr ahrs_gr_{%tralt} = @pca(ahrs_{%tralt})
	genr price_diff_{%tralt} = @pca(pgdp_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr lc_gr_{%tralt} = @pca(lc_{%tralt})
	genr prod_gr_{%tralt} = @pca(prod_{%tralt})
	genr lc_fex_gr_{%tralt} = @pca(lc_fex_{%tralt})
	genr prod_fex_gr_{%tralt} = @pca(prod_fex_{%tralt})
	' additional series for internal use only
	genr lbrshr_{%tralt} = 100*(wss_{%tralt} + y_{%tralt}) / gdp_{%tralt}
	genr e_gr_{%tralt} = @pca(e_{%tralt})
	genr te_gr_{%tralt} = @pca(te_{%tralt})
	genr tcea_gr_{%tralt} = @pca(tcea_{%tralt})
	genr epop_{%tralt} = 100 * (e16o_{%tralt} / n16o_{%tralt})
next	


' Outside forecasters -- annual
wfselect {%thisfile}
pageselect annual
smpl @all

' *** SPECIAL FOR TR -- we do this for all TRs now (so far, TR23, TR24, and Tr25)
' Copy some of the historical data from TR alt2 to the forecasters that don't include it in their files
wfselect {%thisfile}
pageselect annual
smpl !TRyr-4 !TRyr-3  ' for Tr23, this is 2019 to 2020

%tralt = @str(!TRyr-2000) + "2" ' denote which TR and alt to copy values from
' real and nominal GDP level to BlueChip and to Budget
r_gdp_bch = r_gdp_{%tralt}
r_gdp_bgt = r_gdp_{%tralt}
gdp_bch = gdp_{%tralt}
gdp_bgt = gdp_{%tralt}
' PGDP level to BlueChip and to Budget
pgdp_bch = pgdp_{%tralt}
pgdp_bgt = pgdp_{%tralt}
' RU to BlueChip and to Budget
ru_bch = ru_{%tralt}
ru_bgt = ru_{%tralt}
' CPIW for Budget; Budget reports actual CPIW (not CPI-U), so we will copy from TR 
cpiw_bgt = cpiw_{%tralt}
' CPIW NSA for Budget; Budget reports actual CPIW (not CPI-U), so we will copy from TR 
cpiw_u_bgt = cpiw_u_{%tralt}
' CPIW for BlueChip; BlueChip reports CPI-U, so we will copy from IHS; Note -- this is cpiw_231-U for both BllueCjop and IHS, but the series is named cpiw
cpiw_bch = cpiw_ihs
' CPIW NSA for BlueChip; BlueChip reports CPI-U, so we will copy from IHS 
cpiw_u_bch = cpiw_u_ihs
' WSD and WSS to Budget
wsd_bgt = wsd_{%tralt}
wss_bgt = wss_{%tralt}
' compute WSD/GDP ratio for Budget
wsd_to_gdp_bgt = 100 * wsd_bgt / gdp_bgt
' Nomintr for BlueChip
nomintr_bch = nomintr_{%tralt}

wfselect {%thisfile}
pageselect annual
smpl @all
' ** END of SPECIAL for TR


' Some special computations that vary by source:
' Budget
genr acwa_bgt = (wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt)		' note that we use avg earnings for acwa in Budget
genr acwa_gr_bgt = @pca((wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt))
genr r_avg_earn_bgt = (wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt)/cpiw_u_bgt
genr epop_bgt = (1-ru_bgt/100) * p16o_bgt * 100		'compute epop from ru and lfpr
genr lbrshr_bgt = 100*(wss_bgt + yf_bgt + ynf_bgt) / gdp_bgt 	' labor share

'Moodys
genr epop_mdy = 100 * e_mdy / n16o_mdy		' compute e-to-pop ratio
genr r_avg_earn_mdy = (wsd_mdy + yf_mdy + ynf_mdy)/(e_mdy)/cpiw_u_mdy
genr acwa_mdy = (wsd_mdy + yf_mdy + ynf_mdy)/(e_mdy)
genr prod_fex_mdy = r_kgdp_mdy / lc_fex_mdy/(1 - ru_fe_mdy/100)
series acwa_gr_mdy = @pca(acwa_mdy)
series r_wage_diff_mdy	' series filled with NAs
genr lbrshr_mdy = 100*(wss_mdy + yf_mdy + ynf_mdy) / gdp_mdy 	' labor share

' IHS
genr r_avg_earn_ihs = (wsd_ihs + yf_ihs + ynf_ihs)/(e_ihs)/cpiw_u_ihs
genr acwa_ihs = (wsd_ihs + yf_ihs + ynf_ihs)/(e_ihs)			
genr acwa_gr_ihs = @pca(acwa_ihs)
genr epop_ihs = 100 * e_ihs / n16o_ihs		' compute e-to-pop ratio
genr p16o_ihs = lc_ihs / n16o_ihs				' compute LFPR
genr lbrshr_ihs = 100*(wss_ihs + yf_ihs + ynf_ihs) / gdp_ihs 	' labor share

' CBO 
genr wss_cbo = wsd_cbo / (earn2comp_cbo / 100)				' compensation of employees
genr lbrshr_cbo = 100*(wss_cbo + y_cbo) / gdp_cbo 			' labor share

' BCH -- nothing needed
'' extend nominal int rates past 10 years, assuming constant after year 10
' This should NOT be done b/c interest rates in BlueChip publication are given as average for 5yr periods, not as "long-run" average.
'pageselect annual
'smpl !TRyr+11 !TRyr+19  ' for Tr25, this is 2036 to 2044
'nomintr_bch = nomintr_bch(-1)

wfselect {%thisfile}
pageselect annual
smpl @all

for %src bgt ihs mdy cbo bch
	genr r_gdp_gr_{%src} = @pca(r_gdp_{%src})
	genr r_kgdp_gr_{%src} = @pca(r_kgdp_{%src})	
	genr cpiw_u_gr_{%src} = @pca(cpiw_u_{%src})	
	genr cpiw_gr_{%src} = @pca(cpiw_{%src})
	genr pgdp_gr_{%src} = @pca(pgdp_{%src})
	genr price_diff_{%src} = @pca(pgdp_{%src}) - @pca(cpiw_u_{%src})
	genr lc_gr_{%src} = @pca(lc_{%src})
	genr prod_gr_{%src} = @pca(prod_{%src})
	genr lc_fex_gr_{%src} = @pca(lc_fex_{%src})
	genr prod_fex_gr_{%src} = @pca(prod_fex_{%src})
	genr r_avg_earn_gr_{%src} = @pca(r_avg_earn_{%src})	'(wsd_{%src} + yf_{%src} + ynf_{%src})/(e_{%src}+edmil_{%src})/cpiw_u_{%src})
	genr ahrs_gr_{%src} = @pca(ahrs_{%src})
	genr e_gr_{%src} = @pca(e_{%src})
	genr rintr_{%src} = (((1+nomintr_{%src}(-1)/100/2)^2)/(1+cpiw_gr_{%src}/100) - 1)*100
next	

' special for Budget -- remove values for r_kgdp_gr_bgt, r_kgdp_bgt, rtp_bgt, lc_fex, lc_fex_gr, prod_fex, prod_fex_gr when rtp is not euqal to 1. 
wfselect {%thisfile}
for %p quarterly annual
	pageselect {%p} 
	smpl @all
	genr r_kgdp_bgt = @recode(rtp_bgt=1, r_kgdp_bgt, NA)
	genr r_kgdp_gr_bgt = @recode(rtp_bgt=1, r_kgdp_gr_bgt, NA)
	genr lc_fex_bgt = @recode(rtp_bgt=1, lc_fex_bgt, NA)
	genr prod_fex_bgt = @recode(rtp_bgt=1, prod_fex_bgt, NA)
	genr lc_fex_gr_bgt = @recode(rtp_bgt=1, lc_fex_gr_bgt, NA)
	genr prod_fex_gr_bgt = @recode(rtp_bgt=1, prod_fex_gr_bgt, NA)
	genr rtp_bgt = @recode(rtp_bgt=1, rtp_bgt, NA)
next

wfselect {%thisfile}
pageselect annual
smpl @all
' SPECIAL for CBO
' restore ahrs_gr series that just got replaced by NAs in the loop above
ahrs_gr_cbo = ahrs_gr_cbo_keep
delete ahrs_gr_cbo_keep
' compute/replace prod_gr_cbo (in the above loop it was computed as growth rate of NFB productivity); the formula below REPLACES that
prod_gr_cbo = @pca(prod_tote_cbo)
' replece the productivity LEVEL with 'total-economy productivity' (this is neded so that the 10-year compound avg growth arte is computed correctly), but save the prod loaded from CBO data as prod_nfb
series prod_nfb_cbo = prod_cbo
prod_cbo = prod_tote_cbo

' **SPECIAL for BCH
' restore the ANNUAL values for GROWTH RATES for r_gdp_gr, pgdp_gr, and cpiw_gr that were loaded directly from the BCEI file;
' we saved the earlier (line 1430) into designated series
wfselect {%thisfile}
pageselect annual
smpl {%bch_starta} @last 		' aply only to the period where the annual data for BCH exist
for %ser r_gdp_gr_bch pgdp_gr_bch cpiw_gr_bch
	series {%ser} = {%ser}_keep
	delete {%ser}_keep
next

' Extend the LEVEL for the following series -- real GDP, PGDP, nominal GDP (using the the Level provided for the first two years and the projected gr rates)
' note that this is still the sample smpl {%bch_starta} @last
r_gdp_bch = r_gdp_bch(-1) * (1+r_gdp_gr_bch/100)
pgdp_bch = pgdp_bch(-1) * (1+pgdp_gr_bch/100)
gdp_bch = r_gdp_bch * pgdp_bch

wfselect {%thisfile}
pageselect annual
smpl !TRyr-1 @last 	' the rest is done for the entire period

rintr_bch = (((1+nomintr_bch(-1)/100/2)^2)/(1+cpiw_gr_bch/100) - 1)*100		' re-compute rintr_bch, now that we have values for gr rate of CPI and PGDP
price_diff_bch = pgdp_gr_bch - cpiw_gr_bch  ' re-compute price_diff for BCH, now that we have values for gr rate of CPI and PGDP

' Done with Special for BCH

' Special for Implied growth of total-economy productivity
wfselect {%thisfile}
pageselect annual
smpl @all

for %src ihs mdy cbo bch
	prod_gr_{%src} = prod_gr_{%src} - ahrs_gr_{%src}
	prod_fex_gr_{%src} = prod_fex_gr_{%src} - ahrs_gr_{%src} 	
next
' Note: the growth rate of (total-economy) productivity is computed taking into account the gr rate of avg hours.
' Therefores, it would be incorrect to compute the compaound growth rate of total-economy-productivity from the level of prod_{src}. 
' Need to have special formular for the 10-year compound average for prod and prod_fex.

%msg = "Done."
logmsg {%msg}
logmsg


' *** Create labels for all annual series ***
%msg = "Creating labels for annual series ..."
logmsg {%msg}

wfselect {%thisfile}
pageselect annual
smpl @all

' create this similar to how it was done for quarterly series, but use %summ_list or %global_list as the  master list of names
	%col_list_lim = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3" ' +ihs mdy cbo
' only create labels for TR and Budget, the rest have labels loaded from their respective source files (this may no longer be the case, since we use genr to rename the series insted of rename -- think about changing this approach)

for %src {%col_list_lim}
	ahrs_{%src}.label(d) Average weekly hours worked
	ahrs_{%src}.label(u) Hours per week
	
	ahrs_gr_{%src}.label(d) Annual percent change in Average weekly hours worked
	ahrs_gr_{%src}.label(u) percentage points
	
	cola_{%src}.label(d) OASDI cost-of-living adjustment (announced in Oct of the year listed; effective Jan of the following year)
	cola_{%src}.label(u) percentage points
	
	cpiw_{%src}.label(d) CPI-W (seasonally adjusted)
	cpiw_{%src}.label(u) 1982-1984 = 1
	
	cpiw_gr_{%src}.label(d) Percent change in CPI-W (seasonally adjusted)
	cpiw_gr_{%src}.label(u) percentage points
	
	cpiw_u_{%src}.label(d) CPI-W (level, not seasonally adjusted)	
	cpiw_u_{%src}.label(u) 1982-1984 = 1
	
	cpiw_u_gr_{%src}.label(d) Percent change in CPI-W (not seasonally adjusted)
	cpiw_u_gr_{%src}.label(u) percentage points
	
	gdp_{%src}.label(d) Nominal GDP 
	gdp_{%src}.label(u) Billions of current dollars
	
	lc_{%src}.label(d) Average annual civilian labor force 
	lc_{%src}.label(u) Millions of people
	
	lc_gr_{%src}.label(d) Annual percent change in civilian labor force 
	lc_gr_{%src}.label(u) percentage points
	
	lc_fex_{%src}.label(d) Full-employment civilian labor force 
	lc_fex_{%src}.label(u) Millions of people
	
	lc_fex_gr_{%src}.label(d) Implied annual percent change in full-employment civilian labor force 
	lc_fex_gr_{%src}.label(u) percentage points
	
	nomintr_{%src}.label(d) Nominal interest rate
	nomintr_{%src}.label(u) percentage points
	
	pgdp_gr_{%src}.label(d) Percent change in GDP deflator (SAAR)
	pgdp_gr_{%src}.label(u) percentage points
	
	price_diff_{%src}.label(d) Price differential
	price_diff_{%src}.label(r) Computed as the difference between growth rate of GDP deflator and growth rate of CPI-W (SA)
	price_diff_{%src}.label(r) Usually negative
	price_diff_{%src}.label(u) percentage points
		
	r_gdp_gr_{%src}.label(d) Percent change in real GDP 
	r_gdp_gr_{%src}.label(u) percentage points
	
	r_kgdp_gr_{%src}.label(d) Percent change in real potential GDP 
	r_kgdp_gr_{%src}.label(u) percentage points
	
	rintr_{%src}.label(d) Real interest rate
	rintr_{%src}.label(u) percentage points
	rintr_{%src}.label(r) Computed as realized or expected real yield on securities issued in the fourth prior quarter
	
	rtp_{%src}.label(d) Ratio of real to potential GDP
	
	r_wage_diff_{%src}.label(d) Real growth in average OASDI Covered Wage
	
	ru_{%src}.label(d) Average annual civilian unemployment rate
	ru_{%src}.label(u) percentage points
	
	wsd_{%src}.label(d) U.S. Wage and salary disbursements, current dollars
	wsd_{%src}.label(u) $ billions
	
	wsd_to_gdp_{%src}.label(d) U.S. Wage and salary disbursements, percentage of GDP
	wsd_to_gdp_{%src}.label(u) percentage points
	
	prod_fex_{%src}.label(d) Full-employment labor productivity (total economy)
	' units???
	
	prod_fex_gr_{%src}.label(d) Implied annual percent change in full-employment labor productivity (total economy) 
	prod_fex_gr_{%src}.label(u) percentage points
	
	prod_{%src}.label(d) Labor productivity (total economy) 
	' units???
	
	prod_gr_{%src}.label(d) Implied annual percent change in labor productivity (total economy) 
	prod_gr_{%src}.label(u) percentage points
	
	r_avg_earn_{%src}.label(d) Average real U.S. earnings 
	' units???
	
	r_avg_earn_gr_{%src}.label(d) Annual percent change in Average real U.S. earnings 
	r_avg_earn_gr_{%src}.label(u) percentage points
	
	pgdp_{%src}.label(d) GDP deflator
	if !by_cur = !by_pr then
		%label = @str(!by_cur) + " = 1"
		pgdp_{%src}.label(u) {%label} 
	endif
	
	r_gdp_{%src}.label(d) Real GDP (SAAR)
	if !by_cur = !by_pr then
		%label = "Billions of chained " + @str(!by_cur) + " dollars"
		r_gdp_{%src}.label(u) {%label} 
	endif
	
	r_kgdp_{%src}.label(d) Real potential GDP (SAAR)
	if !by_cur = !by_pr then
		%label = "Billions of chained " + @str(!by_cur) + " dollars"
		r_kgdp_{%src}.label(u) {%label} 
	endif

	' additional series for internal use only
	e_{%src}.label(d) Employment (average annual, CPS concept), 16+
	e_{%src}.label(u) millions of people
	
	te_{%src}.label(d) Employment (total, at-any-time)
	te_{%src}.label(u) millions of people
	
	tcea_{%src}.label(d) OASDI Covered Employment (total, at-any-time)
	tcea_{%src}.label(u) millions of people
	
	ru_asa_{%src}.label(d) Average annual civilian unemployment rate, age-sex-adjusted
	ru_asa_{%src}.label(u) percentage points
	
	lbrshr_{%src}.label(d) Share of labor compensation in GDP
	lbrshr_{%src}.label(u) percentage points
next
	
' labels that vary with base year -- pgdp, r_grp, r_kgdp 
' !!!!!! This is done for TRs (current and previous); others have labels loaded from their corresponding source files. 
if !by_cur <> !by_pr then
	' *current TR labels*
	%alt1 = @str(!TRyr-2000)+"1"
	%alt2 = @str(!TRyr-2000)+"2"
	%alt3 = @str(!TRyr-2000)+"3"
	'pgdp
	%label = @str(!by_cur) + " = 1"
	pgdp_{%alt1}.label(u) {%label}
	pgdp_{%alt2}.label(u) {%label}
	pgdp_{%alt3}.label(u) {%label} 
	'r_gdp
	%label = "Billions of chained " + @str(!by_cur) + " dollars"
	r_gdp_{%alt1}.label(u) {%label}
	r_gdp_{%alt2}.label(u) {%label}
	r_gdp_{%alt3}.label(u) {%label} 
	'r_kgdp
	r_kgdp_{%alt1}.label(u) {%label}
	r_kgdp_{%alt2}.label(u) {%label}
	r_kgdp_{%alt3}.label(u) {%label}  
	' *previous TR labels*
	%alt1 = @str(!TRpr-2000)+"1"
	%alt2 = @str(!TRpr-2000)+"2"
	%alt3 = @str(!TRpr-2000)+"3"
	'pgdp
	%label = @str(!by_pr) + " = 1"
	pgdp_{%alt1}.label(u) {%label}
	pgdp_{%alt2}.label(u) {%label}
	pgdp_{%alt3}.label(u) {%label} 
	'r_gdp
	%label = "Billions of chained " + @str(!by_pr) + " dollars"
	r_gdp_{%alt1}.label(u) {%label}
	r_gdp_{%alt2}.label(u) {%label}
	r_gdp_{%alt3}.label(u) {%label} 
	'r_kgdp
	r_kgdp_{%alt1}.label(u) {%label}
	r_kgdp_{%alt2}.label(u) {%label}
	r_kgdp_{%alt3}.label(u) {%label}  
endif

' indicate source
for %ser {%global_list}
	' outside forecaster
	%bgt_txt = "FY " + %FY + " Budget Projections, released " + %date_bgt
	%ihs_txt = "S&P Global Projections, released " + %date_ihs
	%cbo_txt = "CBO Projections, released " + %date_cbo
	%mdy_txt = "Moody's Analytics Projections, released " + %date_mdy
	%bch_txt = "Blue Chip Economic Indicators, released " + %date_bch
	{%ser}_bgt.label(s) {%bgt_txt}
	{%ser}_ihs.label(s) {%ihs_txt}
	{%ser}_cbo.label(s) {%cbo_txt}
	{%ser}_mdy.label(s) {%mdy_txt}
	{%ser}_bch.label(s) {%bch_txt}
	' TRs
	for %a 1 2 3 
		%tr_c = @str(!TRyr-2000)+%a
		%tr_c_txt = "Projections from TR" + @str(!TRyr) + ", alt " + %a
		%tr_p = @str(!TRpr-2000)+%a
		%tr_p_txt = "Projections from TR" + @str(!TRpr) + ", alt " + %a
		
		{%ser}_{%tr_c}.label(s) {%tr_c_txt}
		{%ser}_{%tr_p}.label(s) {%tr_p_txt}
	next
next

' Additional labels for series notincluded above
for %src mdy ihs cbo
	lbrshr_{%src}.label(d) Share of labor compensation in GDP
	lbrshr_{%src}.label(u) percentage points
next

%msg = "Done."
logmsg {%msg}
logmsg
' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


'****** LONG TABLES******
%msg = "Creating Long tables."
logmsg {%msg}
logmsg

' *****Create quarterly and annual sections of the tables in the corresponding workfile pages 
%msg = "Creating quarterly and annual sections for each table."
logmsg {%msg}
logmsg

wfselect {%thisfile}
smpl @all
for %p quarterly annual
	pageselect {%p}
	' loop through all long tables -- this loop creates the tables in general, then they need to be formatted.
	!n = 1
	for %t {%tables_list}		' remember that %tables_list lists the series in the long tables IN THE ORDER of tables.
		if %t = "cpiw_u_gr" then
			 !cola_t = !n		' !cola_t is the NUMBER of the table containing CPIW growth rate, into which we will later insert COLA values.
		endif
		' make a list of columns
		%tab_list = ""
		for %col {%col_list}
			%tab_list = %tab_list + %t + "_" + %col + " "
		next
		group tab{!n} {%tab_list}
		smpl !tablestart !tableend
		freeze(table{!n}) tab{!n}.sheet
		%title = "Table " + @str(!n) + " - " + %{%t}_tabtitle
		table{!n}.title {%title}
		smpl @all
		!n = !n+1
	next
next

!ntabs = !n -1 	'!ntabs is the number of long tables we have; this number is determined by the number of components in the %tables_list

' Create special COLA table (annual only), it will be inserted into CPI-W (NSA) long table
wfselect {%thisfile}
pageselect annual
smpl @all
' SPECIAL for COLA
' At the time we normally make SR tables (Dec of each year) the official COLA scheduled to come into effect the following January has already been announced
' This, the COLA in the first year to be shown in the table (i.e. !TRyr-1( is known with certainty; this value would be in the new TR A-file.
' Copy the "official" COLA value from the new TR A-file up to year !tryr-1 to all private forecasters. 

!colayr = !TRyr -1
%tralt = @str(!TRyr-2000) + "2"
smpl @first !colayr

for %src ihs mdy cbo bch bgt
	cola_{%src} = cola_{%tralt}
next

smpl @all

' make a list of columns
%tab_list = ""
for %col {%col_list}
	%tab_list = %tab_list + "cola_" + %col + " "
next
group colas {%tab_list}
smpl !tablestart !tableend
freeze(cola_table) colas.sheet
cola_table.title OASDI Cost of Living Adjustment (effective January of the following year)
cola_table.setformat(@all) f.1	' COLAs should be displayed with 1 decimal (always!)
smpl @all


' Create appropriate averages for series in the long tables; these tables will be called {series}_lavg (i.e. long avg)
wfselect {%thisfile}
pageselect annual
smpl @all
for %ser {%tables_list}
	if {%ser}_ail = "S" then
		table(3, !table_cols) {%ser}_lavg  'declare table
		' fill in headings
		{%ser}_lavg(1,1) = "Average Rate"
		{%ser}_lavg.setjust(1,1) top
		{%ser}_lavg(2,1) = @str(!tablestart-1) + "-" + @str(!tableend-1)
		{%ser}_lavg(3,1) = @str(!tablestart) + "-" + @str(!tableend)
		'compute values
		!cl = 2 	'first column for inserting averages
		for %v {%col_list} 
			!s1 = !tablestart
			!s2 = !tableend-1
			smpl !s1 !s2
			{%ser}_lavg(2,!cl) = @mean({%ser}_{%v})
			!s1 = !tablestart+1
			!s2 = !tableend
			smpl !s1 !s2
			{%ser}_lavg(3,!cl) = @mean({%ser}_{%v})
			!cl = !cl+1
			smpl @all
		next
	endif
	if {%ser}_ail = "C" then
		table(3, !table_cols) {%ser}_lavg  'declare table
		' fill in headings
		{%ser}_lavg(1,1) = "Compound Annual Average Rate of Change"
		{%ser}_lavg.setjust(1,1) top
		{%ser}_lavg(2,1) = @str(!tablestart-1) + "-" + @str(!tableend-1)
		{%ser}_lavg(3,1) = @str(!tablestart) + "-" + @str(!tableend)
		'compute values
		!cl = 2 	'first column for inserting averages
		for %v {%col_list} 
			'create series name (remember, we need to refer to the underlying LEVEL series)
			!l = @length(%ser) - 3					' the name of the series is obtained it by cutting off _gr from the name of %ser
			%name = @left(%ser, !l) + "_" + %v 	' and then adding the extension, such as _191, _192, _bgt, etc.
			
			!s1 = !tablestart-1
			!s2 = !tableend-1
			{%ser}_lavg(2,!cl) = 100*((@elem({%name},@str(!s2))/@elem({%name},@str(!s1)))^(1/(!s2 - !s1)) - 1)
			{%ser}_lavg(3,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name},@str(!tablestart)))^(1/(!tableend - !tablestart)) - 1)
			
			!cl = !cl+1
		next
	endif
	if {%ser}_ail = "N" then
		table(1,1) {%ser}_lavg  'declare empty 1x1 table
		{%ser}_lavg(1,1) = " "  ' need to give a value to the cell in the table; for some reason EViews13 does not want to work with completely empty tables and gives me an error in the loop below on line 2397
	endif
next

' SPECIAL for TR (this section assumes the order of columns in the tables is given; might need to adjust in the future to link to %col_list)
' Manually create 10-yr compound averages for certainf series
' (1) ahrs_gr for CBO (in Summary Table); We have CBO data for ahrs GROWTH, but no data for ahrs LEVEL, so can't compute the compound avg from levels.
' (2) prod_gr and prod_fex_gr for IHS, MDY, CBO -- for these prod_gr is computed by subtracting ahrs_gr from prod_gr, making the corresponding prod level no longer consistent with grpwth rates

' create appropriate samples -- these will be used for computation sbelow
!s1 = !tableend-10
!s2 = !tableend-1
sample s10a !s1 !s2	' sample covers 10 years ending in year before last -- e.g. 2023-2032 for TR24, where the last year in table is 2033
%10astart = @str(!s1)
%10aend = @str(!s2)
!10ayrs = !s2 - !s1

!s1 = !tableend-9
!s2 = !tableend
sample s10b !s1 !s2 	' sample covers 10 years ending in year !tableend -- e.g. 2024-2033 for TR24, where the last year in table is 2033
%10bstart = @str(!s1)
%10bend = @str(!s2)
!10byrs = !s2 - !s1

' (1) ahrs_gr for CBO
smpl s10a
series temp = 1 + ahrs_gr_cbo/100
series temp_prd = @cumprod(temp, s10a)
ahrs_gr_lavg(2,7) = 100*(@elem(temp_prd, %10aend)^(1/(!10ayrs + 1)) - 1)

smpl s10b
series temp = 1 + ahrs_gr_cbo/100
series temp_prd = @cumprod(temp, s10b)
ahrs_gr_lavg(3,7) = 100*(@elem(temp_prd, %10bend)^(1/(!10byrs + 1)) - 1)

smpl @all

' (2) prod_gr and prod_fex_gr for IHS, Moodys, CBO

!col = 5 		' column in the avg table where values for S&P Global (IHS) should go, followed by Moody's in column 6, and CBO in column 7.
for %ser ihs mdy cbo
	
	smpl s10a
	series temp = 1 + prod_gr_{%ser}/100
	series temp_prd = @cumprod(temp, s10a)
	prod_gr_lavg(2,!col) = 100*(@elem(temp_prd, %10aend)^(1/(!10ayrs + 1)) - 1)
	
	series temp = 1 + prod_fex_gr_{%ser}/100
	series temp_prd = @cumprod(temp, s10a)
	prod_fex_gr_lavg(2,!col) = 100*(@elem(temp_prd, %10aend)^(1/(!10ayrs + 1)) - 1)
	
	smpl s10b
	series temp = 1 + prod_gr_{%ser}/100
	series temp_prd = @cumprod(temp, s10b)
	prod_gr_lavg(3,!col) = 100*(@elem(temp_prd, %10bend)^(1/(!10byrs + 1)) - 1)
	
	series temp = 1 + prod_fex_gr_{%ser}/100
	series temp_prd = @cumprod(temp, s10b)
	prod_fex_gr_lavg(3,!col) = 100*(@elem(temp_prd, %10bend)^(1/(!10byrs + 1)) - 1)
	
	!col = !col + 1
next
' end of SPECIAL
smpl @all

' Combine quarterly, annual, and average long tables into one full long table
%msg = "Combining quarterly, annual, and average sections into long tables."
logmsg {%msg}
logmsg

' and put the resulting tables into page 'tables'
wfselect {%thisfile}
pageselect tables
smpl @all
'copy relevant tables to page 'tables'
for !t = 1 to !ntabs
	copy quarterly\table{!t} tables\
	copy annual\table{!t} tables\table{!t}_an
next
copy annual\cola_table tables\
copy annual\*_lavg tables\		' copy strings that indicate lavg
copy annual\*_nt* tables\		' copy strings that indicate all Notes for long tables -- include _nt, _nt2, _ntl, _ntl2

'insert annual tables into quarterly to make full tables
!t = 1
for %atab {%tables_list}
	!last_row = table{!t}.@rows + 2
	%loc = "A" + @str(!last_row)
	table{!t}_an.deleterow(1) 2  				' delete first 2 rows of the annual table (series names and line)
	table{!t}_an.copytable table{!t} {%loc}	' insert annual table into long table
	delete table{!t}_an 
	!last_row = table{!t}.@rows + 2			' new last row
	%loc = "A" + @str(!last_row)
	{%atab}_lavg.copytable table{!t} {%loc}	' insert average table into long table
	delete {%atab}_lavg
	table{!t}.setformat(@all) ft.{!{%atab}_dc}	' set decimal places for each table (determined by parameters !<ser name>_dc defined early in the program), and use comma to separate thousands
	!t = !t + 1
next
' insert cola table into the appropriate long table (i.e. long table number !cola_t)
cola_table.deleterow(1) 2 ' delete first 2 rows of the cola table (series names and line)
!last_row = table{!cola_t}.@rows +2
table{!cola_t}(!last_row,1) = cola_table.@title
table{!cola_t}.setjust(!last_row,1) top
!last_row = table{!cola_t}.@rows +1
%loc = "A" + @str(!last_row)
cola_table.copytable table{!cola_t} {%loc}
delete cola_table

' insert notes at the bottom of some of the long tables
!t = 1
for %tab {%tables_list}
	if {%tab}_nt<>"N" then
		!note_row = table{!t}.@rows + 2	' row where the note would be inserted = last row +2 (to leave an empty row between data and note)
		table{!t}(!note_row,1) = {%tab}_nt
		table{!t}.setjust(!note_row,1) top
	endif
	if %tab = "prod_gr" then		
		!note_row = table{!t}.@rows + 1	' row where the second-row note would be inserted (below the first note)
		table{!t}(!note_row,1) = {%tab}_nt2
		table{!t}.setjust(!note_row,1) top
	endif
	' insert special notes that are used in the Long Tables only (_ntl)
	if {%tab}_ntl<>"N" then
		if {%tab}_nt<>"N" then 	' determine if another note already exists in the table
			!note_row = table{!t}.@rows + 1 	' if there is another note, move to the next line, no empty line between notes.
			else 
				!note_row = table{!t}.@rows + 2	' if there is no note yet, move two lines down to leave an empty line between data and note
		endif
		table{!t}(!note_row,1) = {%tab}_ntl
		table{!t}.setjust(!note_row,1) top
	endif
	' insert the second line of the note for r_gdp and pgdp
	if %tab = "r_gdp" then		
		!note_row = table{!t}.@rows + 1	' row where the note would be inserted (below the first note)
		table{!t}(!note_row,1) = {%tab}_ntl2
		table{!t}.setjust(!note_row,1) top
	endif
	if %tab = "pgdp" then		
		!note_row = table{!t}.@rows + 1	' row where the note would be inserted (below the first note)
		table{!t}(!note_row,1) = {%tab}_ntl2
		table{!t}.setjust(!note_row,1) top
	endif
	!t = !t + 1
next
delete *_nt *_nt2 *_ntl *_ntl2

%msg = "Done with Long tables."
logmsg {%msg}
logmsg

' DONE with all LONG tables. 

' ***** Create Summary Table ******
%msg = "Creating Summary Table."
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect annual
smpl @all
' %summ_list gives the list and order of series to be included in the Summary table
' !sum_tablestart -- the first year to dispaly in each panel of the summary table is defined at the top of the program

' Create appropriate 10-yr averages for series in the Summary table
for %ser {%summ_list}
	if {%ser}_ai = "S" then
		table(3, !table_cols) {%ser}_avg  'declare table
'		table(1, !table_cols) {%ser}_avgsp  ' SPECIAL FOR TR23 -- averages for period 2019-2032; these tables will store them
		' fill in headings
		{%ser}_avg(1,1) = "10-Year Averages"
		{%ser}_avg.setjust(1,1) top
		{%ser}_avg(2,1) = @str(!tablestart-1) + "-" + @str(!tableend-1)
		{%ser}_avg(3,1) = @str(!tablestart) + "-" + @str(!tableend)
		'compute values
		!cl = 2 	'first column for inserting averages
		for %v {%col_list} 
			!s1 = !tableend-10			' NOTE: We are computing simple average over **10** years. Even though the row label will say something like '2018 - 2028' we are NOT averaging values for years 2018 through 2028 -- because that would be 11 years, not 10. Instead for 2018-2028 period we are averaging value for 2019 through 2028, and for 2019-2029 period we are averaging values 2020-2029. 
			!s2 = !tableend-1			' Note: sometimes we change !tablestart to show more years; but we never change !tableend; so this sample must depend on !tableend only
			smpl !s1 !s2
			series test_na = @isna({%ser}_{%v})	' test if there are any NAs in the sample; if there are any NAs, the average should be NA
			!testna = @sum(test_na)
			if !testna = 0 then
				{%ser}_avg(2,!cl) = @mean({%ser}_{%v})
				else {%ser}_avg(2,!cl) = NA
			endif
			
			!s1 = !tableend-9 		' Note: sometimes we change !tablestart to show more years, but we never change !tableend; so this sample must depend on !tableend only
			!s2 = !tableend
			smpl !s1 !s2
			series test_na = @isna({%ser}_{%v})	' test if there are any NAs in the sample; if there are any NAs, the average should be NA
			!testna = @sum(test_na)
			if !testna = 0 then
				{%ser}_avg(3,!cl) = @mean({%ser}_{%v})
				else {%ser}_avg(3,!cl) = NA
			endif
			
'			smpl 2020 2032 		' SPECIAL FOR TR23 -- averages for period 2019-2032
'			{%ser}_avgsp(1, !cl) = @mean({%ser}_{%v})  ' SPECIAL FOR TR23 -- averages for period 2019-2032
			
			!cl = !cl+1
			smpl @all
		next
	endif
		if {%ser}_ai = "C" then
		table(3, !table_cols) {%ser}_avg  'declare table
'		table(1, !table_cols) {%ser}_avgsp  ' SPECIAL FOR TR23 -- averages for period 2019-2032; these tables will store them
		' fill in headings
		{%ser}_avg(1,1) = "10-Year Compound Annual Averages"
		{%ser}_avg.setjust(1,1) top
		{%ser}_avg(2,1) = @str(!tablestart-1) + "-" + @str(!tableend-1)
		{%ser}_avg(3,1) = @str(!tablestart) + "-" + @str(!tableend)
		'compute values
		!cl = 2 	'first column for inserting averages
		for %v {%col_list} 
			'create series name (remember, we need to refer to the underlying LEVEL series)
			!l = @length(%ser) - 3					' the name of the series is obtained it by cutting off _gr from the name of %ser
			%name = @left(%ser, !l) + "_" + %v ' and then adding the extension, such as _191, _192, _bgt, etc.
			
			!s1 = !tableend-11 		' Note: sometimes we change !tablestart to show more years, but we never change !tableend; so this sample must depend on !tableend only
			!s2 = !tableend-1
			{%ser}_avg(2,!cl) = 100*((@elem({%name},@str(!s2))/@elem({%name},@str(!s1)))^(1/(!s2 - !s1)) - 1)
			{%ser}_avg(3,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name},@str(!tableend-10)))^(1/10) - 1)
			
'			{%ser}_avgsp(1,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name}, "2019"))^(1/13) - 1) 	' SPECIAL FOR TR23 -- averages for period 2019-2032
			
			!cl = !cl+1
		next
	endif
next

' SPECIAL for TR (this section assumes the order of columns in the tables is given; might need to adjust in the future to link to %col_list)
' Manually create 10-yr compound averages for certain series
' (1) ahrs_gr for CBO (in Summary Table); We have CBO data for ahrs GROWTH, but no data for ahrs LEVEL, so can't compute the compound avg from levels.
' (2) prod_gr and prod_fex_gr for IHS, MDY, CBO -- for these prod_gr is computed by subtracting ahrs_gr from prod_gr, making the corresponding prod level no longer consistent with grpwth rates
' this was already done above for the "long average" tables, so here we simply copy them into the "average" tables.

table ahrs_gr_avg_keep = ahrs_gr_avg 	' save existing values in ..._keep table, just in case; can comment this out later
ahrs_gr_avg = ahrs_gr_lavg

table prod_gr_avg_keep = prod_gr_avg 	' save existing values in ..._keep table, just in case; can comment this out later
prod_gr_avg = prod_gr_lavg

table prod_fex_gr_avg_keep = prod_fex_gr_avg 	' save existing values in ..._keep table, just in case; can comment this out later
prod_fex_gr_avg = prod_fex_gr_lavg
' end of SPECIAL

smpl @all
' Create each panel within the Summary table as separate table
!n = 1
for %t {%summ_list}		
	' make a list of columns for each panel
	%panel_list = ""
	for %col {%col_list}
		%panel_list = %panel_list + %t + "_" + %col + " "
	next
	group pnl{!n} {%panel_list}
	smpl !sum_tablestart !tableend 		' each panel covers same range of years (e.g. 2017-2028 for TR19)
	freeze(panel{!n}) pnl{!n}.sheet 	' at this point the table has 14 rows (series names, line, and 12 yrs of data)
	!tcols = panel{!n}.@cols
	for !c=1 to !tcols
		panel{!n}(1,!c) = ""				' remove series names
		panel{!n}.setlines(2,!c) -d 		' remove double line through second row
	next
	panel{!n}(2,1) = {%t}_title 			'Title of the panel
	panel{!n}.setjust(2,1) top
	panel{!n}.setfont(2) +b				' make the title text of each panel bold
	' insert rows with averages as appropriate
	if {%t}_ai<>"N" then
		!avg_row = panel{!n}.@rows + 2
		{%t}_avg.copytable panel{!n} !avg_row 1
	endif
	' insert a note at the botton of panel, as appropriate
	if {%t}_nt<>"N" then
		!note_row = panel{!n}.@rows + 1	' row where the note would be inserted = last row +1
		panel{!n}(!note_row,1) = {%t}_nt
		panel{!n}.setjust(!note_row,1) top
	endif
	
'	if %t = "ahrs_gr" then				NO LONGER NEEDED -- The new method computes ahrs_gr as compounded annual average
'		!note_row = panel{!n}.@rows + 1	
'		panel{!n}(!note_row,1) = {%t}_nt2
'		panel{!n}.setjust(!note_row,1) top
'	endif
	
	if %t = "prod_gr" then		' special two-line note for implied productivity growth; need this every TR.
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt2
		panel{!n}.setjust(!note_row,1) top
	endif
	
	panel{!n}.setformat(@all) ft.{!{%t}_dc} 	' set decimal places for each panel (determined by parameters !<ser name>_dc defined early in the program), and use comma to separate thousands
	smpl @all
	!n = !n+1
next

!npanels = !n - 1 ' number of panels in the Summary table; this number is determined by the number of components in the %summ_list

' combine the panels into one summary table. 
%msg = "Combine all panels into one summary table."
logmsg {%msg}
logmsg

table summary_table
panel1.copytable summary_table A1
!last_row = panel1.@rows + 1
for !p=2 to !npanels
	%loc = "A" + @str(!last_row)
	panel{!p}.copytable summary_table {%loc}
	!last_row = !last_row + panel{!p}.@rows
next

%msg = "Done with Summary Table."
logmsg {%msg}
logmsg

' ***** Formal all tables
%msg = "Formatting all tables."
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect tables 
smpl @all
' Collect all relevant tables to 'tables' page
for !t = 1 to !npanels
	copy annual\panel{!t} tables\
next
copy annual\summary_table tables\

' format Summary table
summary_table.insertrow(1) 4 		'insert 4 rows on top of table to hold column headings
head.copytable summary_table A1 ' copy column headings into summary table
summary_table.setjust(@all) center
summary_table.setwidth(@all) 9
summary_table.title {%summ_table_title}

' replace all NAs with '--'
for !i = 1 to summary_table.@rows
	for !j = 1 to summary_table.@cols
		if summary_table(!i,!j) = " NA" then
			summary_table(!i,!j) = "--"
		endif
	next
next

' add various notes at the bottom of Summary table to identify the run
!note_row = summary_table.@rows + 2	
summary_table(!note_row,1) = "SSA/OCACT " + @date 		' insert  "SSA/OACAT" note on last row +2 (to leave one empty line)
summary_table.setfont(!note_row,1) +b

!time_row = summary_table.@rows + 1	
%time_note = @time
summary_table(!time_row,1) = %run + "  " + %time_note ' add the %run identifier and time stamp on the last row of Summary table to help identify numerous runs for internal discussion


' format long tables
for !t = 1 to !ntabs
	for !c=1 to !table_cols
		table{!t}(1,!c) = ""					' remove series names
		table{!t}.setlines(2,!c) -d 		' remove double line through second row
	next
	table{!t}.insertrow(1) 3  			'insert 3 rows on top of table to hold column headings
	head.copytable table{!t} A1 	' copy column headings into each table
	table{!t}.setjust(@all) center
	table{!t}.setwidth(@all) 10		' 9 is the smallest width that allows to display real GDP with 2 decimal places; at width 9 all columns of long tables fit on one page (portrait orientation).
	' replace all NAs with '--'
	for !i = 1 to table{!t}.@rows
		for !j = 1 to table{!t}.@cols
			if table{!t}(!i,!j) = " NA" then
				table{!t}(!i,!j) = "--"
			endif
		next
	next
	!note_row = table{!t}.@rows + 2	' row where the "SSA/OACAT" note would be inserted = last row +2 (to leave one empty line)
	table{!t}(!note_row,1) = "SSA/OCACT " + @date
	table{!t}.setfont(!note_row,1) +b
	
	!time_row = table{!t}.@rows + 1	
	%time_note = @time
	table{!t}(!time_row,1) = %run + "  " + %time_note  	' add the %run identifier and time stamp on the last row of the table to help identify numerous runs for internal discussion
	!next_row = !time_row +1
	table{!t}(!next_row,1) = table{!t}.@title 					' add table title on the LAST row of the table so that the title is visible when we save the table to a CSV file.
	' create 'empty lines' between years in quarterly section of the table
	for !line = 10 to 49 step 4
		table{!t}.setheight(!line) 1.4
	next
	' SPECIAL FOR TR -- every TR!!!
	' create 'empty lines' every 5 years in the annual section of the table
	' NOTE -- these need to be manually adjusted every year!
	' The wider space should appear AFTER year 0 and AFTER year 5; for example: after 2020 and after 2025;
	' therefore, the row numbers in the commands below should correspond to the rows holding year x1 and x6 (for example, 2021 and 2026)
	table{!t}.setheight(53) 1.4
	table{!t}.setheight(58) 1.4
next

' SPECIAL FOR TR -- every TR!!
' add a few more 'empty lines' to the table that contains COLA section; it is table # !cola_t (this was determines far above in the code)
' The row numbers here will need to be adjusted every year!!!!
' The wider space should appear AFTER year 0 and AFTER year 5; for example: after 2020 and after 2025
' therefore, the row numbers in the commands below should correspond to the rows holding year x1 and x6 (for example, 2021 and 2026)
table{!cola_t}.setheight(70) 1.4
table{!cola_t}.setheight(75) 1.4

delete panel* 'head 'col_list	' clean up the tables page

%msg = "Done with all tables."
logmsg {%msg}
logmsg

'		make summary spool
wfselect {%thisfile}
pageselect tables
smpl @all
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %usr
string line2 = "The file contains data for proposed SR assumptions for TR" + @str(!TRyr) + ". This run is " + %run + ". This file is intended for INTERNAL DELIBARATIONS ONLY."
string line3 = "The file contains data for TR" + @str(!TRyr) + " (alt " + %alt_cur + ") loaded from the following databanks:"
string line4 = "TR"+@str(!TRyr)+ " alt 2 values are taken from banks: " + @chr(13) + %abank_alt2 + @chr(13) + %dbank_alt2
if %alt_cur <> "2" then
	string line5 = "TR"+@str(!TRyr)+ " alt 1 banks: " + @chr(13) + %abank_alt1 + @chr(13) + %dbank_alt1
	string line6 = "TR"+@str(!TRyr)+ " alt 3 banks: " + @chr(13) + %abank_alt3 + @chr(13) + %dbank_alt3
'	string line5 = "TR"+@str(!TRyr)+ " alt 1 banks represents the CORRECTED alt 2 run from \\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0106-1433-TR252X "
'	string line6 = "TR"+@str(!TRyr)+ " alt 3 banks are p[laceholder TO BE IGNORED"

	else 
		string line5 = "Data for alt1 and alt3 not used in this run of the program."
		string line6 = " "
endif
string line7 = "and data for TR" + @str(!TRpr) + " loaded from"
string line8 = "TR"+@str(!TRpr)+ " alt 2 banks: " + @chr(13) + %abank_pr_alt2 + @chr(13) + %dbank_pr_alt2
string line9 = "TR"+@str(!TRpr)+ " alt 1 banks: " + @chr(13) + %abank_pr_alt1 + @chr(13) + %dbank_pr_alt1
string line10 = "TR"+@str(!TRpr)+ " alt 3 banks: " + @chr(13) + %abank_pr_alt3 + @chr(13) + %dbank_pr_alt3
string line11 = "Data for the outside forecasters is loaded from:"
string line12 = "FY"+ %FY + " budget data from " + %omb + " and " + %budget_path
string line13 = "S&P Global data from " + %ihs_source
string line14 = "Moody's Analytics data from " + %mdy_source
string line15 = "CBO data from " + %cbo_source 
string line16 = "Blue Chip data from " + %bch_source 
'string line16a = "This file also includes data from the TR24 alt2 INITIAL run performed in Jan 2024 (\LRECON\ModelRuns\TR2024\2024-0110-1630-TR242), for comparison."
string line17 = "The final tables are in page ''tables''. "
if %csv = "Y" then
	string line18 = "The resulting tables are saved as CSV files in " + %tablespath
	else string line18 = " "
endif


_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12 line13 line14 line15 line16 line17 line18


delete line*

if %longtab = "Y" then
	%msg = "Saving the long tables to files in " + %tablespath
	logmsg {%msg}

	' long tables
	' determine which table contains COLA -- it will need a different scale factor
	!tcola = @wfind(%tables_list, "cpiw_u_gr")
	if %pdf = "Y" then	' this should almost never be done for tables intended for internal discussion
	' save finished tables into PDF files; scale appropriately so that things fit on a page how we intend.		
	table{!tcola}.save(t=pdf, s=75) {%tablespath}table{!tcola}.pdf		' scale table with COLA to 75%
		for !t = 1 to !ntabs
			if !t <> !tcola then
				table{!t}.save(t=pdf, s=88) {%tablespath}table{!t}.pdf			' scale all tables to 88% 
			endif
		next
	endif

	' save finished tables into CSV files replacing NAs with '--'. The precision (full or rounded to the precision displayed in EViews) is controlled by option %full specified at the start of the program.
	' NOTE: table titles do not survive in CSV -- instead they are included on the last line of each long table
	if %csv = "Y" then
		for !t = 1 to !ntabs
			if %full = "N" then
				%name = %tablespath + "table" + @str(!t) + %run		' This adds the %run identifier to the file name to help identify numerous runs for internal discussion. 
																					'Note that this will make it impossible to create a linked Excel file that contains all these tables (which requires filenames to be identical for all runs). But I plan to have a linked Excel file only for the Summary Table, so I decided it is useful to have %run identifiers for the LONG tables. 
				table{!t}.save(t=csv, n=--) {%name}.csv
			endif
			if %full = "Y" then
				%name = %tablespath + "table" + @str(!t) + %run
				table{!t}.save(f, t=csv, n=--) {%name}.csv 				' -- this one is FULL precision
			endif
		next
	endif
endif

if %sumtab = "Y" then
	%msg = "Saving the summary table to a file in " + %tablespath
	logmsg {%msg}	
	logmsg

	if %csv = "Y" then			' CSV format only, no point in saving Summary table to PDF -- it is too large to be viewed in that format.
		if %full = "N" then
			%name = %tablespath + "summary_table" '+ %run		' can't have %run identifier b/c need identical filenames for the linked Excel file.
			summary_table.save(t=csv, n=--) {%name}.csv
		endif
		if %full = "Y" then
			%name = %tablespath + "summary_table" '+ %run
			summary_table.save(f, t=csv, n=--) {%name}.csv	' -- this one is FULL precision
		endif	
	endif
endif


if %sav = "Y" then
	%wfpath=%outputpath + %thisfile + ".wf1"
	wfsave(2) %wfpath ' saves the workfile
	%msg = "Done. The program is finished. Resulting workfile is saved to " + %wfpath
	logmsg {%msg}
	logmsg
endif

if %sav = "N" then
	%msg = "The program is finished. The workfile has NOT been saved. Make sure to save the file(s) you wish preserved."
	logmsg {%msg}
	logmsg
endif

'close {%thisfile} 'close the workfile; comment this out if need to keep the workfile open


