' Polina Vlasenko 
' This version of the program was made for TR24
' NEW in this version -- Long tables 11 and 12 (nominal and real interest rates) go out 20 years and are split into two pages for the PDF verion. 

' !!!!!!!! Before running this program for a new TR, seach for text 'SPECIAL FOR TR' (in all caps) !!!!
' !!!!! It marks any idiosyncratic fixes that were done for particular TRs. Check to make sure any of those still apply!!!!

' This program  produces tables to be included in the Short Range memo
'	The program loads data from EViews workfile that was created by a similar program that makes tables for internal deliberations (sr_memo_tables_internal.prg)
' 	Normally, we always make the tables for internal deliberations before we make the the "official" tables. 
'	Thus, to be absilutely sure the same data are used both times (and to simplify the maintenance of the code) it is easier to load data for the "official" tables from the file that was used to create the "internal" tables.

'	This program makes one long summary table and 12 detailed tables.
' 	The tables can be saved in PDF format (to be included in the PDF version of the memo) and/or the CSV format (to be included in an Excel file we also provide with the memo).

' This program requires the following inpuits:
' !!! EViews file created by sr_memo_tables_internal.prg !!! This is the most important input as we load ALL series form this file.
' AND the information about the sources of data used to create that file, namely:
' (Note that we do not actually load any data from these files; the program uses information about them to make a list of data sources in the _summary spool and to label the tables accordingly)
' 	a-bank from current TR, alt2 only or all alts (depending on the kind fo tables desired)
' 	a-bank from previous-yr TR, all alts
' aombXX.wf1 that contains data from the budget run
' Excel file from OMB with the budget assumptions
' EViews workfile containing the forecast from S&P Global (formerly IHS Markit) -- we use either "Short-term Macro Forecast (baseline)" or "Long-term Macro Forecast (baseline)" (decided every year case by case)
' Excel file that contains Moody's forecast (currently, I download it from Moody's DataBuffet)
' EViews workfile that contains CBO data (usually from the latest LTBO)
' Excel file that contains data from Blue Chip forecast 

' FYI: Historical nominal interest rates on new issues https://mwww.ba.ssa.gov/OACT/ProgData/newIssueRates.html 

' ****** !!!!! ALWAYS CHECK *** SAVE options *** before running the program to avoid overwriting the files accidentally !!! ****

'***********************************************************************************************************************
'***** UPDATE these parameters before running the program to make sure it uses correct files****
'***** The Update section is LONG; make sure you check all of it -- all the way to '*****END of UPDATE section   
'***** !!! Pay special attention to %sav parameter to avoid overwriting output files !!!
' **********************************************************************************************************************

%usr = @env("USERNAME")	

!TRyr = 2025			' current TR year

' Previous_year TR
!TRpr = !TRyr-1

'	Output created by this program
%thisfile = "SRtables_TR" + @str(!TRyr)

%outputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\official\_2025_0117_allalts\" 	' location where EViews workfile is to be saved

%tablespath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\official\_2025_0117_allalts\" 	' location where the PDF and CSV version of the finished tables are to be saved; can be the same as or different from %outputpath

' *** SAVE options ***
' Do you want the output file(s) to be saved on this run? 
' Usually, enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location (%outputpath and %tablespath above) is correct because wfsave OVERWRITES any existing files with identical names without any warning!
' This setting also determines whether the tables will be saved to PDF and CSV files. Files are generated ONLY if %sav = "Y".
%sav = "Y" 		' enter "N" or "Y" case sensitive

' Which tables to save? (these parameters matter only if %sav = "Y" above)
' For official tables we usually make BOTH PDF and CSV tables.
%pdf = "Y" 		' enter "Y" to save tables in PDF format, "N" to not save tables in PDF (case sensitive)
%csv = "Y" 	' enter "Y" to save tables in CSV format, "N" to not save tables in CSV (case sensitive)

' For CSV tables -- full precision or rounded. NOTE: PDF tables  display rounded values ONLY. 
' NOTE: typically, we use full precision only internally for review; when sending Excel copy of tables outside the office, we use rounded values (they also look better aesthetically).
%full = "N" 		' !!! ALWAYS "N" for official tables !!! enter "Y" if full precision is desired, "N" if rounded values are OK (case sensitive).
' *****

'******* DATA FROM INTERNAL VERSION OF THE TABLES ****
' You MUST run program sr_memo_tables_internal.prg (and save the resulting workfile) first. That program produces a workfile with a version of SR tables for internal deliberations.  
' Normally, we would  have a version of SR tables that have been created for internal deliberations in the normal course of developing the SR assumptions.
' Once we have settled on the 'final run' of such tables, the data from that run will be used here  to create the "official" tables.
' (If, for some unfathomable reason, there is no "internal" version of a workfile with SR tables, then run program sr_memo_tables_internal.prg before running this program.)

%internal_tables = "SRtables_internal_TR2025_20250115_test_allalts"  	' filename of the EViews file corresponding to the version of internal tables we intend to make into 'official' ones
																						' note that it does not matter whether this file was create with "long" tables for interest rates or not; 
																						' here we will load the data series form the workfile, not the tables.
%internal_tables_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2025\analysis" + "\" + %internal_tables + ".wf1" 	' full path

' *** Parameters for the workfile

!yrstart = 2000 								' the earliest year for which to load data
!yrend = 2050 									' the latest year for which to load data
!tablestart = !TRyr -1 					' the earliest year to be DISPLAYED in the LONG tables 	
!sum_tablestart = !tablestart -1 	' the first year to dispaly in each panel of the SUMMARY table.
!tableend = !TRyr + 9 					' the last year to be DISPLAYED in the tables	
!intrend = !TRyr + 9 + 10 			' SPECIAL FOR TR - Every TR starting with TR24 -- longer tables for interest rates		
																' !intrend parameter is added to allow the period for interest rate tables (Table 11 and table 12) to be different from other tables.												


' *** Sources***
' we need this info ONLY to create the list of sources in the _summary spool, and to place correct dates/vintages in the column headings.

'*** current TR databanks ***
' ALTS -- current TR alts to be included; space-delimited list. 
' Normally we have either alt2 only, or all three alts.
' Make sure databank file locations are given (below) for ALL alts you list here. 
%alt_cur = "1 2 3"  		' "1 2 3" or "2"	
'	a-bank (comment out the alts that are not used)
'	a-bank (comment out the alts that are not used)
%abank_alt2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0106-1433-TR252\out\mul\atr252.wf1" 		' alt2	
%abank_alt1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0113-1441-TR251\out\mul\atr251.wf1" 		' alt1 
%abank_alt3 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0115-1652-TR253\out\mul\atr253.wf1" 		' alt3 

'*** previous TR databanks ***
' We always include all 3 alts
' WORKFILE  version -- TR22 and later have workfiles
'	a-bank																												
%abank_pr_alt2 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul\atr242.wf1" 	' alt2	 
%abank_pr_alt1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0905-TR241\out\mul\atr241.wf1" 	' alt1
%abank_pr_alt3 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0946-TR243\out\mul\atr243.wf1" 	' alt3 

'' SPECIAL FOR TR24
''*** SPECIAL TR databanks ***
'' These are the banks for CV19 run																											
'%abank_alt2ini = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\Assumptions\SR_Tables\TR2024\TR24_Update\atr242ini.wf1" 	' a-bankf or CV19 run
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


' **** Long tables ****
' List the series to be shown in the long tables, IN THE ORDER the tables should appear. 
' To add/remove/change the order of tables, adjust this list -- the rest of code will adjust automatically.
' !!!! If you add a series -- remember to add a ..._tabtitle, average indicator (..._ail), decimal format indicator (_dc), and any applicable note strings (_nt) for the series in the code below !!!!
%tables_list =  "r_gdp_gr r_kgdp_gr r_gdp r_kgdp rtp cpiw_u_gr cpiw_gr pgdp_gr cpiw_u pgdp nomintr rintr"	

' ****  Summary table ****
' List of series as they appear in the Summary Table, IN THE ORDER we want them to appear.  
' To add/remove/change the order of panels in the summary table, adjust this list.
' !!!!! If you add a series -- remember to add ..._title, average indicator (..._ai), decimal format indicator (_dc), and any applicable note strings (_nt) for the series in the code below !!!!
%summ_list = "r_gdp_gr r_gdp gdp r_kgdp_gr wsd wsd_to_gdp r_avg_earn_gr acwa_gr r_wage_diff ru lc ahrs_gr nomintr cpiw_u_gr pgdp_gr price_diff lc_gr prod_gr lc_fex_gr prod_fex_gr"		

' List of ALL series we need for the tables. -- should be unchanged UNLESS you ADD growth rate series to %tables_list or %summ_list above that require additional level series for average computation.
' Right now this is a combination of %summ_list and %tables_list with repetitions removed PLUS some level variables that are not included in tables but needed to compute compounded growth rates PLUS COLA we need for one long table
' If you removed series from %tables_list or %summ_list -- leave %global_list unchnaged
%global_list = @wunion(%tables_list, %summ_list) + " r_kgdp rtp cpiw_gr cpiw_u pgdp rintr" + " acwa ahrs cpiw lc_fex prod prod_fex r_avg_earn" + " cola"	

' Columns in the tables; it lists the 'extension' to the series names indicating the source; this list detrermines the order of columns in ALL tables (the order of columns is assumed to be the same in the summary table and all long tables); 
' To adjust the order of columns -- change this list.
%col_list = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 ihs mdy cbo bch bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3"
' number of columns in tables (both Summary table and Long tables have the same number of column, one listing date, the rest listing data).
!table_cols =1+ @wcount(%col_list) 	
'' SPECIAL FOR TR24
'%col_list = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 ihs mdy cbo bch bgt 242ini "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3"
'!table_cols =1+ @wcount(%col_list)

' **************************************************************
'*****END of UPDATE section that needs updating for each run*****
' ********************************************************************************
' ********************************************************************************

' **** Several section of the program below can be changed to address formatting issues for the tables:

' 	*** Summary Table attributes *** provides
' 		titles for all panels within the Summary Table
' 		Average Indicator (ai) variable denoting whether and what kind of average to create for each series (simple, compounded, or no average)
' 		Note (_nt) to be included at the bottom of each panel (also accommodates no note)

' 	**** Long Tables attributes **** provides
' 		titles for all Long Tables
' 		Average Indicator (ail) variable denoting whether and what kind of average to create in ***Long*** tables (simple, compounded, or no average)
' 		Note (_ntl) to be included at the bottom of each table (also accommodates no note); some notes are special for Long Tables only

' 	Section named "Decimal places (_dc) to be displayed for each series" specifies the precision to be displayed for each series
' 	These are the same whether the series is shown in Long tables or Summary table; thus every series is listed here ONLY ONCE.

' 	Section   ' ***** Formal all tables ***** (close to the end of the program)
' 	formats all tables. To alter format -- look into code in this section.

' 	Section '		make summary spool
' 	makes the summary spool that is displyed once the program is run. To add to the spool or alter its contents -- edit this section.

' 	Section that starts with   if %sav = "Y" then (very end fo the program)
' 	specifies which files are to be saved, including PDF and CSV copies of the tables. To alter which files are saved (or which formats they are saved in) -- edit this section.
' ************************************************

wfcreate(wf={%thisfile}, page=annual) a !yrstart !yrend	' page with annual data
pagecreate(page=quarterly) q !yrstart !yrend							' page with quarterly data
pagecreate(page=monthly) m !yrstart !yrend 						' This page will be used for CPIW data (SA and NSA) from Budget
pagecreate(page=tables) q !yrstart !yrend								' page to store the final tables

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
string ru_title = "Average Annual Civilian Unemployment Rate"
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
string wsd_to_gdp_ai = "N"
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
'string ahrs_gr_nt2 = "For CBO, 10-year averages are simple averages of the annual growth rates. "				' Special  note for CBO averages (we need this because we have no level series for ahrs for CBO). NO LONGER NEEDED
string nomintr_nt = "Note: For S&P Global, Moody's Analytics, CBO, and Blue Chip Ec. Ind., nominal interest rates for 10-year Treasury notes are presented."
string rintr_nt = "Note: For S&P Global, Moody's Analytics, CBO, and Blue Chip Economic Indicators, interest rates for 10-year Treasury notes are presented."
' SPECIAL FOR TR24 and subsequent TRs -- second note for the interest rates in SUMMARY table only, indicating longer transition path
string nomintr_nt2 = "For " + @str(!TRyr) + " TR, the interest rate continues to evolve past " + @str(!tableend) + ". The full transition path to the ultimate value is shown in Table 11."
string rintr_nt2 = "For " + @str(!TRyr) + " TR, the interest rate continues to evolve past " + @str(!tableend) + ". The full transition path to the ultimate value is shown in Table 12."
' end of SPECIAL
string cpiw_u_gr_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, percentage change in CPI-U (not seasonally adjusted) is presented."
string cpiw_gr_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, percentage change in CPI-U (seasonally adjusted) is presented."
string cpiw_u_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, CPI-U (not seasonally adjusted) is presented."
string pgdp_gr_nt = "N"
string price_diff_nt = "Note: For S&P Global, CBO, and Blue Chip Economic Indicators, percent change in CPI-U is used in place of percent change in CPI-W."
string lc_gr_nt = "N"
string prod_gr_nt = "Note: For S&P Global and Moody's Analytics, the computation assumes that the growth rate of average weekly hours is the same for " 
string prod_gr_nt2 = "total economy and for the private nonfarm sector. "
string lc_fex_gr_nt = "N"
string prod_fex_gr_nt = "N" 
string r_kgdp_nt = "N"
string rtp_nt = "N"
string pgdp_nt = "N"

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


' ******** Load ALL necessary series from the file of SR tables for internal deliberations
%msg = "Loading data from file with SR tables for internal deliberations -- " + %internal_tables
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect annual
smpl @all

wfopen %internal_tables_path

for %s {%global_list}
	for %e {%col_list}
		%ser = %s + "_" + %e		' name of the series with extension
		copy {%internal_tables}::annual\{%ser} {%thisfile}::annual\* 	' copy annual series
	next
next

for %s {%tables_list}
	for %e {%col_list}
		%ser = %s + "_" + %e		' name of the series with extension
		copy {%internal_tables}::quarterly\{%ser} {%thisfile}::quarterly\* 	' copy quarterly series
	next
next

wfclose %internal_tables

%msg = "DONE loading data"
logmsg {%msg}
logmsg

' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

' *************************************************************************************************************
' ******* SPECIAL MODIFICATIONS to be made to the data loaded from %internal_tables ***************
' In some cases we might want to modify the data loaded from %internal_tables
' For example, we might want to NOT display values for some series (like prod_fex_gr) -- make them NA's here even though they were not NAs in %internal_tables. 
' Any such modifications should be done in this section
' SPECIAL FOR TR

' Special modifications for TR21

'wfselect {%thisfile}
'pageselect annual
'smpl 2020 2020
'r_kgdp_gr_211 = 1.918 		' growth rate of potential GDP
'prod_fex_gr_211 = 1.42 		' growth rate of potential productivity
'prod_fex_gr_213 = -0.21		' growth rate of potential productivity
'smpl 2019 2019
'prod_fex_gr_211 = 1.17 		' growth rate of potential productivity
'prod_fex_gr_213 = 1.17 		' growth rate of potential productivity

' ************************************************************************



' ***********************************************************************
' ************************ MAKE THE TABLES ************************
' ***********************************************************************

'****** LONG TABLES******
%msg = "Creating Long tables"
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
		' SPECIAL FOR TR24 and subsequent TRs -- this has to do with the interest rate tables displaying 20 years instead of 10 years
		if %t = "nomintr" then
			 !nomintr_t = !n		' !nomintr_t is the NUMBER of the table containing nominal interest rate
		endif
		if %t = "rintr" then
			 !rintr_t = !n		' !rint_t is the NUMBER of the table containing real interest rate
		endif
		' End of SPECIAL
		' make a list of columns
		%tab_list = ""
		for %col {%col_list}
			%tab_list = %tab_list + %t + "_" + %col + " "
		next
		group tab{!n} {%tab_list}
		smpl !tablestart !tableend
		' SPECIAL FOR TR24 and subsequent TRs
		if %t = "nomintr" then
			smpl !tablestart !intrend
		endif
		if %t = "rintr" then
			smpl !tablestart !intrend
		endif
		'End of SPECIAL
		freeze(table{!n}) tab{!n}.sheet
		%title = "Table " + @str(!n) + " - " + %{%t}_tabtitle
		table{!n}.title {%title}
		smpl @all
		!n = !n+1
	next
next

!ntabs = !n - 1 	'!ntabs is the number of long tables we have; this number is determined by the number of components in the %tables_list

' Create special COLA table (annual only), it will be inserted into CPI-W (NSA) long table
wfselect {%thisfile}
pageselect annual
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
			!l = @length(%ser) - 3								' the name of the series is obtained it by cuting off _gr from the name of %ser
			%name = @left(%ser, !l) + "_" + %v ' and then adding the extension, such as _191, _192, _bgt, etc.
			
			!s1 = !tablestart-1
			!s2 = !tableend-1
			{%ser}_lavg(2,!cl) = 100*((@elem({%name},@str(!s2))/@elem({%name},@str(!s1)))^(1/(!s2 - !s1)) - 1)
			{%ser}_lavg(3,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name},@str(!tablestart)))^(1/(!tableend - !tablestart)) - 1)
			
			!cl = !cl+1
		next
	endif
	if {%ser}_ail = "N" then
		table(1,1) {%ser}_lavg  'declare empty 1x1 table
		{%ser}_lavg(1,1) = " "  ' need to give a value to the cell in the table; for some reason EViews13 does not want to work with completely empty tables and gives me an error in the loop below on line 782
	endif
next

' SPECIAL for TR24 and subsequent TRs -- additional avreage for interest rates
pageselect annual
smpl @all
for %ser nomintr rintr
	{%ser}_lavg(4,1) = @str(!tableend) + "-" + @str(!intrend)
	'compute values
		!cl = 2 	'first column for inserting averages
		for %v {%col_list} 
			!s1 = !tableend+1
			!s2 = !intrend
			smpl !s1 !s2
			{%ser}_lavg(4,!cl) = @mean({%ser}_{%v})
			' make sure we have NAs for the avg if ANY obs are missing
			if @elem({%ser}_{%v}, @str(!intrend)) = NA then
				{%ser}_lavg(4,!cl) = NA
			endif
			!cl = !cl+1
			smpl @all
		next
next
' ** END of Special

'' *** SPECIAL FOR TR23 -- in Long tables, for the averages -- eliminate the 2021-2031 average (replace the line with an empty line)
'for %ser {%tables_list}
'	if {%ser}_ail <> "N" then
'		for !cl = 1 to !table_cols
'			{%ser}_lavg(2,!cl) = " "
'		next
'	endif
'next
'' ** END of Special


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
copy annual\*_nt* tables\			' copy strings that indicate all Notes for long tables -- include _nt, _nt2, _ntl, _ntl2

'insert annual tables into quarterly to make full tables
!t = 1
for %atab {%tables_list}
	!last_row = table{!t}.@rows + 2
	%loc = "A" + @str(!last_row)
	table{!t}_an.deleterow(1) 2  					' delete first 2 rows of the annual table (series names and line)
	table{!t}_an.copytable table{!t} {%loc}	' insert annual table into long table
	delete table{!t}_an 
	!last_row = table{!t}.@rows + 2				' new last row
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
		!note_row = table{!t}.@rows + 1	' row where the second note would be inserted (below the first note)
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
			
			!cl = !cl+1
			smpl @all
		next
	endif
		if {%ser}_ai = "C" then
		table(3, !table_cols) {%ser}_avg  'declare table
		' fill in headings
		{%ser}_avg(1,1) = "10-Year Compound Annual Averages" 
		{%ser}_avg.setjust(1,1) top
		{%ser}_avg(2,1) = @str(!tablestart-1) + "-" + @str(!tableend-1)
		{%ser}_avg(3,1) = @str(!tablestart) + "-" + @str(!tableend)
		'compute values
		!cl = 2 	'first column for inserting averages
		for %v {%col_list} 
			'create series name (remember, we need to refer to the underlying LEVEL series)
			!l = @length(%ser) - 3									' the name of the series is obtained it by cuting off _gr from the name of %ser
			%name = @left(%ser, !l) + "_" + %v 	' and then adding the extension, such as _191, _192, _bgt, etc.
			
			!s1 = !tableend-11 		' Note: sometimes we change !tablestart to show more years, but we never change !tableend; so this sample must depend on !tableend only
			!s2 = !tableend-1
			{%ser}_avg(2,!cl) = 100*((@elem({%name},@str(!s2))/@elem({%name},@str(!s1)))^(1/(!s2 - !s1)) - 1)
			{%ser}_avg(3,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name},@str(!tablestart)))^(1/(!tableend - !tablestart)) - 1)
			
			!cl = !cl+1
		next
	endif
next

' SPECIAL for TR 
' Manually create 10-yr compound averages for certainf series
' (1) ahrs_gr for CBO (in Summary Table); We have CBO data for ahrs GROWTH, but no data for ahrs LEVEL, so can't compute the compound avg from levels.
' (2) prod_gr and prod_fex_gr for IHS, MDY, CBO -- for these prod_gr is computed by subtracting ahrs_gr from prod_gr, making the corresponding prod level no longer consistent with grpwth rates

' create appropriate samples -- these will be used for computations below
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
' find column number in avg tables that corresponds to "CBO"
!col = @wfind(%col_list, "cbo") + 1 	' need to add 1 b/c the first column lists row headings (years)
smpl s10a
series temp = 1 + ahrs_gr_cbo/100
series temp_prd = @cumprod(temp, s10a)
ahrs_gr_avg(2,!col) = 100*(@elem(temp_prd, %10aend)^(1/(!10ayrs + 1)) - 1)

smpl s10b
series temp = 1 + ahrs_gr_cbo/100
series temp_prd = @cumprod(temp, s10b)
ahrs_gr_avg(3,!col) = 100*(@elem(temp_prd, %10bend)^(1/(!10byrs + 1)) - 1)

smpl @all

' (2) prod_gr and prod_fex_gr for IHS, Moodys, CBO

for %src ihs mdy cbo
	
	!col = @wfind(%col_list, %src) + 1 	'column in the avg table where value should go, i.e. corresponding to %src 
	
	smpl s10a
	series temp = 1 + prod_gr_{%src}/100
	series temp_prd = @cumprod(temp, s10a)
	prod_gr_avg(2,!col) = 100*(@elem(temp_prd, %10aend)^(1/(!10ayrs + 1)) - 1)
	
	series temp = 1 + prod_fex_gr_{%src}/100
	series temp_prd = @cumprod(temp, s10a)
	prod_fex_gr_avg(2,!col) = 100*(@elem(temp_prd, %10aend)^(1/(!10ayrs + 1)) - 1)
	
	smpl s10b
	series temp = 1 + prod_gr_{%src}/100
	series temp_prd = @cumprod(temp, s10b)
	prod_gr_avg(3,!col) = 100*(@elem(temp_prd, %10bend)^(1/(!10byrs + 1)) - 1)
	
	series temp = 1 + prod_fex_gr_{%src}/100
	series temp_prd = @cumprod(temp, s10b)
	prod_fex_gr_avg(3,!col) = 100*(@elem(temp_prd, %10bend)^(1/(!10byrs + 1)) - 1)
	
next
' end of SPECIAL
smpl @all


'' *** SPECIAL FOR TR23 -- in the Summary Table, for the averages -- replace the line that shows the 2021-2031 average witht he one that shows the 2019-2032 average
'
'' load FROM THE INTERNAL FILE the average for 2019-2032; they are in the tables called XXXX_avgsp
'wfselect {%thisfile}
'pageselect annual
'smpl @all
'
'wfopen %internal_tables_path
'copy {%internal_tables}::annual\*_avgsp {%thisfile}::annual\
'wfclose %internal_tables
'
'wfselect {%thisfile}
'pageselect annual
'smpl @all
'
'' In all tables named XXXX_avg, replace the 2nd row with table XXXX_avgsp (it only has one row)
'' And add text "2019-2032" tp cell (2,1)
'for %ser {%summ_list}
'	if {%ser}_ai <> "N" then
'		{%ser}_avgsp.copytable {%ser}_avg A2
'		{%ser}_avg(2,1) = "2019-2032"
'	endif
'next
'' ** END of Special


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
	freeze(panel{!n}) pnl{!n}.sheet 			' at this point the table has 14 rows (series names, line, and 12 yrs of data)
	!tcols = panel{!n}.@cols
	for !c=1 to !tcols
		panel{!n}(1,!c) = ""							' remove series names
		panel{!n}.setlines(2,!c) -d 		' remove double line through second row
	next
	panel{!n}(2,1) = {%t}_title 	' Title of the panel
	panel{!n}.setjust(2,1) top
	panel{!n}.setfont(2) +b		' make the title text of each panel bold
	' insert rows with averages as appropriate
	if {%t}_ai<>"N" then
		{%t}_avg.copytable panel{!n} 16 1
	endif
	' insert a note at the bottom of panel, as appropriate
	if {%t}_nt<>"N" then
		!note_row = panel{!n}.@rows + 1	' row where the note would be inserted = last row +1
		panel{!n}(!note_row,1) = {%t}_nt
		panel{!n}.setjust(!note_row,1) top
	endif
	
	if %t = "prod_gr" then		' special two-line note for implied productivity growth
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt2
		panel{!n}.setjust(!note_row,1) top
	endif
	
	'SPECIAL FOR TR24 and subsequent TRs -- a note for interest rates indicating the longer transition path is shown in the long tables
	if %t = "nomintr" then		
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt2
		panel{!n}.setjust(!note_row,1) top
	endif
	
	if %t = "rintr" then		
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt2
		panel{!n}.setjust(!note_row,1) top
	endif
	' End of SPECIAL
	
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

' combine the panels into summary table broken into several pages
!spages = 5 		' number of pages to break the Summary table into
!ppg = !npanels / !spages	' 'panels per page = number of panels per page of summary table
for !pg=1 to !spages
	table summary_table_p{!pg}
	!first_pnl = !ppg * (!pg - 1) +1
	!last_pnl = !first_pnl + !ppg -1
	!last_row = 1
	for !p=!first_pnl to !last_pnl
		%loc = "A" + @str(!last_row)
		panel{!p}.copytable summary_table_p{!pg} {%loc}
		!last_row = !last_row + panel{!p}.@rows
	next
next

%msg = "Done with Summary Table."
logmsg {%msg}
logmsg

' ***** Formal all tables *****
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
for !pg=1 to !spages
	copy annual\summary_table_p{!pg} tables\
next

' format Summary table
summary_table.insertrow(1) 4 'insert 4 rows on top of table to hold column headings
head.copytable summary_table A1 ' copy column headings into summary table
'summary_table.setformat(@all) f.2
summary_table.setjust(@all) center
summary_table.setwidth(@all) 9
'summary_table.setwidth(E) 10 		' slightly wider col E to accomodate word 'Agreement' for TR21Update
summary_table.title {%summ_table_title}

' replace all NAs with '--'
for !i = 1 to summary_table.@rows
	for !j = 1 to summary_table.@cols
		if summary_table(!i,!j) = " NA" then
			summary_table(!i,!j) = "--"
		endif
	next
next
!note_row = summary_table.@rows + 2	' row where the "SSA/OACAT" note would be inserted = last row +2 (to leave one empty line)
summary_table(!note_row,1) = "SSA/OCACT " + @date
summary_table.setfont(!note_row,1) +b

' format Summary table broken into separate pages
for !pg=1 to !spages
	summary_table_p{!pg}.insertrow(1) 4 'insert 4 rows on top of table to hold column headings
	head.copytable summary_table_p{!pg} A1 ' copy column headings into summary table
	'summary_table_p{!pg}.setformat(@all) f.2
	summary_table_p{!pg}.setjust(@all) center
	summary_table_p{!pg}.setwidth(@all) 9
	'summary_table_p{!pg}.setwidth(E) 10 		' slightly wider col E to accomodate word 'Agreement' for TR21Update
	%stitle = %summ_table_title + ", page " + @str(!pg) + " of " + @str(!spages)
	summary_table_p{!pg}.title {%stitle}
	' replace all NAs with '--'
	for !i = 1 to summary_table_p{!pg}.@rows
		for !j = 1 to summary_table_p{!pg}.@cols
			if summary_table_p{!pg}(!i,!j) = " NA" then
				summary_table_p{!pg}(!i,!j) = "--"
			endif
		next
	next
	!note_row = summary_table_p{!pg}.@rows + 2	' row where the "SSA/OACAT" note would be inserted = last row +2 (to leave one empty line)
	summary_table_p{!pg}(!note_row,1) = "SSA/OCACT " + @date
	summary_table_p{!pg}.setfont(!note_row,1) +b
next

' format long tables
for !t = 1 to !ntabs
	for !c=1 to !table_cols
		table{!t}(1,!c) = ""							' remove series names
		table{!t}.setlines(2,!c) -d 		' remove double line through second row
	next
	table{!t}.insertrow(1) 3  				'insert 3 rows on top of table to hold column headings
	head.copytable table{!t} A1 ' copy column headings into each table
	'table{!t}.setformat(@all) f.2
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
	' create 'empty lines' between years in quarterly section of the table
	for !line = 10 to 49 step 4
		table{!t}.setheight(!line) 1.4
	next
next	

' SPECIAL FOR TR24 and subsequent TRs -- longer int rate tables
for !line = 50 to 89 step 4
		table{!nomintr_t}.setheight(!line) 1.4
		table{!rintr_t}.setheight(!line) 1.4
next
	
	' SPECIAL FOR TR -- every TR!!!
	' create 'empty lines' every 5 years in the annual section of the table -- NOTE: these need to be manually adjusted every year!
for !t = 1 to !ntabs
	if !t<>!nomintr_t then
		if !t<>!rintr_t then
			table{!t}.setheight(53) 1.4
			table{!t}.setheight(58) 1.4
		endif
	endif
next

' Longer int rate tables
	table{!nomintr_t}.setheight(93) 1.4
	table{!nomintr_t}.setheight(98) 1.4
	table{!nomintr_t}.setheight(103) 1.4
	table{!nomintr_t}.setheight(108) 1.4
	
	table{!rintr_t}.setheight(93) 1.4
	table{!rintr_t}.setheight(98) 1.4
	table{!rintr_t}.setheight(103) 1.4
	table{!rintr_t}.setheight(108) 1.4

' SPECIAL FOR TR -- every TR!!
' add a few more 'empty lines' to the table that contains COLA section; it is table # !cola_t (this was determines far above in the code)
' The row numbers here will need to be adjusted every year!!!!
table{!cola_t}.setheight(70) 1.4
table{!cola_t}.setheight(75) 1.4

'SPECIAL FOR TR24 and subseqyent TRs -- break interest rate tables in TWO pages each
' Nominal int rates -- table{!nomintr_t}
table table{!nomintr_t}_p1 = table{!nomintr_t}
table{!nomintr_t}_p1.deleterow(66) 51
table{!nomintr_t}_p1.insertrow(66) 2
table{!nomintr_t}_p1(67,6) = "Continues on the next page"
%title = "Table " + @str(!nomintr_t) + " - " + %nomintr_tabtitle + " (page 1 of 2)"
table{!nomintr_t}_p1.title {%title}

table table{!nomintr_t}_p2 = table{!nomintr_t}
table{!nomintr_t}_p2.deleterow(6) 60
%title = "Table " + @str(!nomintr_t) + " - " + %nomintr_tabtitle + " (page 2 of 2)"
table{!nomintr_t}_p2.title {%title}

' Real int rate
table table{!rintr_t}_p1 = table{!rintr_t}
table{!rintr_t}_p1.deleterow(66) 51
table{!rintr_t}_p1.insertrow(66) 2
table{!rintr_t}_p1(67,6) = "Continues on the next page"
%title = "Table " + @str(!rintr_t) + " - " + %rintr_tabtitle + " (page 1 of 2)"
table{!rintr_t}_p1.title {%title}

table table{!rintr_t}_p2 = table{!rintr_t}
table{!rintr_t}_p2.deleterow(6) 60
%title = "Table " + @str(!rintr_t) + " - " + %rintr_tabtitle + " (page 2 of 2)"
table{!rintr_t}_p2.title {%title}

' End of SPECIAL


delete panel* head 'col_list	' clean up the tables page

%msg = "Done with all tables."
logmsg {%msg}
logmsg

'		make summary spool
wfselect {%thisfile}
pageselect tables
smpl @all
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %usr
string line2 = "The tables in the file are made with data loaded from " + @chr(13) + %internal_tables_path + @chr(13) + "The data in that file come from the following sources:"
string line3 = " Data for TR" + @str(!TRyr) + " (alts " + %alt_cur + ") loaded from the following databanks:"
string line4 = "TR"+@str(!TRyr)+ " alt 2 file: " + @chr(13) + %abank_alt2
if @left(%alt_cur,5) = "1 2 3" then
	string line5 = "TR"+@str(!TRyr)+ " alt 1 file: " + @chr(13) + %abank_alt1 + @chr(13) + _
					"TR"+@str(!TRyr)+ " alt 3 file: " + @chr(13) + %abank_alt3
	else 
		string line5 = "Data for alt1 and alt3 not used in this run of the program."
endif
string line6 = "and data for TR" + @str(!TRpr) + " loaded from" + @chr(13) + _
				 "TR"+@str(!TRpr)+ " alt 2 file: " + @chr(13) + %abank_pr_alt2 + @chr(13) + _
				 "TR"+@str(!TRpr)+ " alt 1 file: " + @chr(13) + %abank_pr_alt1 + @chr(13) + _
				 "TR"+@str(!TRpr)+ " alt 3 file: " + @chr(13) + %abank_pr_alt3
string line7 = "Data from the outside forecasters is loaded from:"
string line8 = "FY"+ %FY + " budget data from " + %omb + " and " + %budget_path
string line9 = "S&P Global data from " + %ihs_source
string line10 = "Moody's Analytics data from " + %mdy_source
string line11 = "CBO data from " + %cbo_source 
string line12 = "Blue Chip data from " + %bch_source 
string line13 = "The final tables are in page ''tables''. "
if %sav = "Y" then
	string line14 = "The resulting tables are saved as PDF and CSV files in " + %tablespath
	else string line14 = " "
endif

_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12 line13 line14

delete line*

if %sav = "Y" then
	if %pdf = "Y" then
		' save finished tables into PDF files; scale appropriately so that things fit on a page how we intend.
		%msg = "Saving PDF tables to files in " + %tablespath
		logmsg {%msg}

		' long tables
		' determine which table contains COLA -- it will need a different scale factor
		!tcola = @wfind(%tables_list, "cpiw_u_gr")
		if %pdf = "Y" then
			table{!tcola}.save(t=pdf, s=75) {%tablespath}table{!tcola}.pdf		' scale table with COLA to 75%
			for !t = 1 to !ntabs
				if !t <> !tcola then
					table{!t}.save(t=pdf, s=75) {%tablespath}table{!t}.pdf			' scale all tables to 85% ; SPECIAL FOR TR24 -- scale to 75%; normally it is 85%
				endif
			next
			' summary tables broken into pages
			for !pg=1 to !spages
				summary_table_p{!pg}.save(t=pdf, s=85, n=) {%tablespath}summary_table_p{!pg}.pdf	' scale to 85%
			next
			' SPECIAL for TR24 -- 2-page tables for int rates
			for !pg = 1 to 2
				table{!nomintr_t}_p{!pg}.save(t=pdf, s=75, n=) {%tablespath}table{!nomintr_t}_p{!pg}.pdf	' scale to 85%; SPECIAL FOR TR24 -- scale to 75%; normally it is 85%
				table{!rintr_t}_p{!pg}.save(t=pdf, s=75, n=) {%tablespath}table{!rintr_t}_p{!pg}.pdf		' scale to 85%; SPECIAL FOR TR24 -- scale to 75%; normally it is 85%
			next
		endif
	endif
	
	' save finished tables into CSV files replacing NAs with '--'. The precision (full or rounded to the precision displayed in EViews) is comtrolled by option %full specified at the start of the program.
	' NOTE: table titles do not survive in CSV -- need to find a way to include them in the files!
	if %csv = "Y" then
		%msg = "Saving the CSV tables to files in " + %tablespath
		logmsg {%msg}
		for !t = 1 to !ntabs
			if %full = "N" then
				table{!t}.save(t=csv, n=--) {%tablespath}table{!t}.csv
			endif
			if %full = "Y" then
				table{!t}.save(f, t=csv, n=--) {%tablespath}table{!t}.csv 	' -- this one is FULL precision
			endif
		next
		if %full = "N" then
			summary_table.save(t=csv, n=--) {%tablespath}summary_table.csv
		endif
		if %full = "Y" then
			' add time stamp on the last row of Summary table to help identify numerous intermediate runs for internal discussion
			!time_row = summary_table.@rows + 1	
			%time_note = @time
			summary_table(!time_row,1) = %time_note
			summary_table.save(f, t=csv, n=--) {%tablespath}summary_table.csv	' -- this one is FULL precision
		endif		
	endif

	%wfpath=%outputpath + %thisfile + ".wf1"
	wfsave(2) %wfpath ' saves the workfile
	%msg = "Done. The workfile was saved to " + %wfpath
	logmsg {%msg}
	logmsg
endif

if %sav = "N" then
	%msg = "The program is finished. The workfile has not been saved. Make sure to save the file(s) you wish preserved."
	logmsg {%msg}
	logmsg
endif


'close {%thisfile} 'close the workfile; comment this out if need to keep the workfile open


