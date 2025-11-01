' Polina Vlasenko 
' 12-06-2019

' !!!!!!!! Before running thisprogram for a new TR, seach for text 'SPECIAL FOR TR' -- it will mark any idiosyncratic fixes that were done for particular TRs. Check to make sure any of those still apply!!!!

' This program produces tables that are later included in the Short Range memo
'	The program loads data from various databanks as well as outside sources to produce the tables normally included with the Short-Range memo
'	This includes one long summary table and 12 detailed tables.
' 	The tables are saved in PDF format (to be included in the PDF version of the memo) and the CSV format (to be included in an Excel file we also provide with the memo).


' This program requires the following databanks:
' a-bank from current TR, alt2 only or all alts (depending on the kind fo tables desired)
' a-bank from previous-yr TR, all alts
' aombXX.bnk that contains data from the budget run
' EViews workfile containing the "Long-term Macro Forecast (baseline)" from IHS Markit
' Excel file that contains Moody's forecast
' Some file that contains CBO foracast (currently it is an Excel file made by hand; in the future we hope this will be an EViews workfile CBO sends us).

' FYI: Historical nominal interest rates on new issues https://mwww.ba.ssa.gov/OACT/ProgData/newIssueRates.html 

' ****** !!!!! Make sure the Excel source files referred to in here (Budget data. Moody's, etc) are NOT open by anyone, otherwise EViews will crash!!!! *****


' 12-04-2020  ---- Started updating the program for TR21.  PV

'***********************************************************************************************************************
'***** UPDATE these parameters before running the program to make sure it uses correct files****
'***** The Update section is LONG; make sure you check all of it -- all the way to '*****END of UPDATE section   
'***** !!! Pay special attention to %sav parameter to avoid overwriting output files !!!
' **********************************************************************************************************************

%usr = "Polina Vlasenko" 	' person running the program

!TRyr = 2021	' current TR year

'	Output created by this program
%thisfile = "SRtables_TR" + @str(!TRyr)
%outputpath = "\\S1F906B\econ\Assumptions\SR Tables\Latest TR\" 	' location where EViews workfile is to be saved

%tablespath = "\\S1F906B\econ\Assumptions\SR Tables\Latest TR\" 		' location where the PDF and CSV version of the finished tables are to be saved; can be the same as or different from %outputpath

' Do you want the output file(s) to be saved on this run? 
' Usually, enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location (%outputpath and %tablespath above) is correct because wfsave OVERWRITES any existing files with identical names without any warning!
' This setting also determines whether the tables will be saved to PDF and CSV files. Files are generated ONLY if %sav = "Y".
%sav = "N" 		' enter "N" or "Y" case sensitive

' Which tables to save? (these parameters matter only if %sav = "Y")
' For internal review we usually only need CSV tables, so it would be convenient NOT to make the numerous PDF files in such cases.
%pdf = "Y" 	' enter "Y" to save tables in PDF format, "N" to not save tables in PDF (case sensitive)
%csv = "Y" 	' enter "Y" to save tables in CSV format, "N" to not save tables in CSV (case sensitive)

' For CSV tables -- full precision or rounded. NOTE: PDF tables  display rounded values ONLY. 
' NOTE: typically, we use full precision only internally for review; when sending Excel copy of tables outside the office, we use rounded values (they also look better aesthetically).
%full = "N" 		' enter "Y" if full precision is desired, "N" if rounded values are OK (case sensitive). 

' *****

!yrstart = 2000 	' the earliest year for which to load data
!yrend=2035 		' the latest year for which to load data
!tablestart = 2020 	' the earliest year to be DISPLAYED in the LONG tables (summary table starts one year earlier)	
!tableend = 2030 	' the last year to be DISPLAYED in the tables														

' Previous_year TR
!TRpr = !TRyr-1

'*** current TR databanks ***
' ALTS -- current TR alts to be included; space-delimited list. 
' Normally we have either alt2 only, or all three alts.
' Make sure databank file locations are given (below) for ALL alts you list here. 
%alt_cur = "2" '"1 2 3" 
'	a-bank (comment out the alts that are not used)
%abank_alt2 = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\atr202.bnk" 	' alt2		
'%abank_alt1 = "\\LRSERV1\usr\eco.19\bnk\2018-1231-1609 TR191\atr191.bnk" 	' alt1
'%abank_alt3 = "\\LRSERV1\usr\eco.19\bnk\2019-0103-1436 TR193\atr193.bnk" 	' alt3

'*** previous TR databanks ***
' We always include all 3 alts
'	a-bank																												
%abank_pr_alt2 = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\atr202.bnk" 	' alt2	 
%abank_pr_alt1 = "\\LRSERV1\usr\eco.20\bnk\2020-0116-1635-TR201\atr201.bnk" 	' alt1
%abank_pr_alt3 = "\\LRSERV1\usr\eco.20\bnk\2020-0117-1744-TR203\atr203.bnk" 	' alt3 

'*** Outside forecasters data ***
'	Budget																															
%FY = "2022"					' Fiscal year applicable to the budget assumptions 								
%date_bgt = "11-2020" 	' Date when budget projections are released (to be displayed in table column headings)	
!yr_bgt = 2019					' First year of data in the OMB Excel file												
%budget_path = "\\s1f906b\econ\TrusteesReports\Assumptions\SR_Tables\TR2021\data\aomb22.bnk" ' EViews workfile or databank with Budget data, full path.	
%budget = "aomb22" 		' filename ONLY, no extension
%omb =  "\\s1f906b\econ\TrusteesReports\Assumptions\SR_Tables\TR2021\data\Economic Assumptions for 2022 Budget, 11-19-2020.xlsx" '  OMB's Excel file with budget assumption data, full path. 	' 

' IHS Markit		(In TR21 we are using the very latest IHS forecast, dated Dec 7 2020)																													
%ihs_source = "\\s1f906b\econ\TrusteesReports\Assumptions\SR_Tables\TR2021\data\ctl1220.wf1"	' EViews workfile downloaded from IHS that contains Baseline Long-term Macro Forecast
%ihs_file = "ctl1220"		' short filename only; this is ALSO the name of the page in the workfile!			
%date_ihs = "12-2020" 	' Date of corresponding to IHS forecast (to be displayed in table column headings)	

' Moody's																														 
%mdy_source = "\\s1f906b\econ\TrusteesReports\Assumptions\SR_Tables\TR2021\data\Moodys_SRtables_Nov2020.xlsx"	' Moody's Excel file (Karen S downloads it each year), full path. !!!!! MAKE SURE this file is NOT protected (click "Enable editing" if necessary; make a copy to be safe). Import command cannot read Excel files that are protected from editing.
%date_mdy = "11-2020" 		' Date of corresponding to Moody's forecast (to be displayed in table column headings)		
%mdy_startq = "2010Q1"		' The date for first observation in Moodys Quarterly data
%mdy_starta = "2010"			' The year for first observation in Moodys Annual data

' CBO 
' file
%cbo_source =  "\\s1f906b\econ\TrusteesReports\Assumptions\SR_Tables\TR2021\data\CBO_data_combined_2020.xlsx" 	' Excel file I make by hand that combined the CBO data from various (usually two) CBO publications
%date_cbo = "09-2020" 		' Date the CBO forecast was released (to be displayed in table column headings)
%cbo_startq = "2017Q1"		' The date for first observation in CBO's Quarterly data
%cbo_starta = "2017"			' The date for first observation in CBO's Annual data

' ****	BASE YEAR ****
' This section deals with the possibility that the BASE YEAR (used for real values) differs between current TR and previous TR.
' The variables below are needed to appropritely label the series and their units in the tables
' In most years, the base year will be the same -- if so, list the same value for !by_cur and !by_pr below.
' Occasionally, when BEA changes the base year in their real series (once in a few years, usually during a comprehensive revisions), the two base years will differ
!by_cur = 2012	' base year for the CURRENT TR			
!by_pr = 2012 	'2009		' base year for the previous TR				
' Series whose names are affected by base year changes. 
' Enter names in BOTH lists below. If the base year is the same, enter identical names for both lists, otherwise, enter the names as they appear in the a-banks.
%gdp_list = "gdp12 kgdp12" 			'	names of real GDP and real potential GDP in CURRENT TR		
%gdp_list_pr = "gdp12 kgdp12" 	' 	names of real GDP and real potential GDP in PREVIOUS TR		
'	DONE with base-year-related variables


' **** Long tables ****
' List the series to be shown in the long tables, IN THE ORDER the tables should appear. 
' To add/remove/change the order of tables, adjust this list -- the rest of code will adjust automatically.
' !!!! If you add a series -- remember to add a ..._tabtitle, average indicator (..._ail), decinal formal indicator (_dc), and any applicable notes (_nt) strings for the series in the code below !!!!
%tables_list =  "r_gdp_gr r_kgdp_gr r_gdp r_kgdp rtp cpiw_u_gr cpiw_gr pgdp_gr cpiw_u pgdp nomintr rintr"	

' ****  Summary table ****
' List of series as they appear in the Summary Table, IN THE ORDER we want them to appear.  
' To add/remove/change the order of panels in the summary table, adjust this list.
' !!!!! If you add a series -- remember to add ..._title, average indicator (..._ai), decinal formal indicator (_dc), and any applicable notes (_nt) strings for the series in the code below !!!!
%summ_list = "r_gdp_gr r_gdp gdp r_kgdp_gr wsd wsd_to_gdp r_avg_earn_gr acwa_gr r_wage_diff ru lc ahrs_gr nomintr cpiw_u_gr pgdp_gr price_diff lc_gr prod_gr lc_fex_gr prod_fex_gr"		

' List of ALL series we need for the tables. -- should be unchanged UNLESS you ADD growth rate series to %tables_list or %summ_list above that require additional level series for average computation.
' Right now this is a combination of %summ_list and %tables_list with repetitions removed PLUS some level variables that are not included in tables but needed to compute compounded growth rates PLUS COLA we need for one long table
' If you removed series from %tables_list or %summ_list -- leave %global_list unchnaged
%global_list = @wunion(%tables_list, %summ_list) + " r_kgdp rtp cpiw_gr cpiw_u pgdp rintr" + " acwa ahrs cpiw lc_fex prod prod_fex r_avg_earn" + " cola"	

' Columns in the tables; it lists the 'extension' to the series names indicating the source; this list detrermines the order of columns in ALL tables (the order of columns is assumed to be the same in the summary table and all long tables); 
' To adjust the order of columns -- change this list.
%col_list = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 ihs mdy bgt cbo "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3"
!table_cols =1+ @wcount(%col_list) 	' number of columns in tables (both Summary table and Long tables have the same number of column, one listing yrs, the rest listing data).


' ****** !!!!! Make sure the Excel source files referred to in here (Budget data, Moodys) are NOT open by anyone, otherwise EViews will crash!!!! *****

' **************************************************************
'*****END of UPDATE section that needs updating for each run*****
' ********************************************************************************
' ********************************************************************************

' **** Several section of the program below can be changed to address formatting issues for the tables:

' 	*** Summary Table attributes *** provides
' 		titles for all panels within the Summary Table
' 		Average Indicator (ai) variable denoting whether and what kind of average to create for each series (simple, compounded, or no average)
' 		Note (_nt) to be included at the botton of each panel (also accomodates no note); same notes are used for Long Tables where applicable

' 	**** Long Tables attributes **** provides
' 		titles for all Long Tables
' 		Average Indicator (ail) variable denoting whether and what kind of average to create in ***Long*** tables (simple. compounded, or no average)

' 	Section named "Decimal places (_dc) to be displayed for each series" specifies the precision to be displayes for each series
' 	These are the same whether the series is shown in Long tables or Summary table; thus every series is listed here ONLY ONCE.

' 	Section ' ******** Parameters needed to properly load data from various source files **********
' 	specifies parameters for importing data from external files (Excel sheet names, column references, etc)
' 	These would need to be changed only if the format of the input files changes (but good idea to double-check every year). 

' 	Section   ' ***** Formal all tables (close to the end of the program)
' 	formats all tables. To alter format -- look into code in this section.

' 	Section '		make summary spool
' 	makes the summary spool that is diaplyed once the program is run. To add to the spool or alter its contents -- edit this section.

' 	Section that starts with   if %sav = "Y" then (very end fo the program)
' 	specifies which files are to be saved, including PDF and CSV copies of the tables. To alter which files are saved (or which formats they are saved in) -- edit this section.
' ************************************************


wfcreate(wf={%thisfile}, page=annual) a !yrstart !yrend		' page with annual data
pagecreate(page=quarterly) q !yrstart !yrend					' page with quarterly data
pagecreate(page=monthly) m !yrstart !yrend 					' This page will be used for CPIW data (SA and NSA) from Budget
pagecreate(page=tables) q !yrstart !yrend						' page to store the final tables

' Display log messages as the program runs
logmode l
%msg = "Running SR_tables.prg" 
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect tables
smpl @all
'	table object that hold column headings for all tables (they depend on the elements in %col_list)
'	Here I assume that whenever TR alternative are listed, ALL 3 of them are listed in ajacent colmns -- i.e. we can have TR18 alt 1, alt 2, alt 3 in this order in 3 ajacent columns, but we cannot have, for example, TR18 alt2, then Budget, then TR18 alt3.
table(4,!table_cols) head
for !t=1 to !table_cols
	head.setlines(4,!t) +d 		' insert double line through last row of the heading
next
head(3,1) = "Year"
for !t=1 to @wcount(%col_list)
	!cl = !t+1
	'IHS Markit
	if @wordq(%col_list,!t) = "ihs" then
		head(1,!cl) = "IHS"
		head(2,!cl) = "Markit"
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
	string r_kgdp_gr_title = "Annual Percentage Change in Potential GDP in " + @str(!by_cur) + " Dollars"
	string r_kgdp_title = "Potential GDP in " + @str(!by_cur) + " Dollars (in billions)"
	else 
	string r_gdp_gr_title = "Annual Percentage Change in GDP in " + @str(!by_cur) + " Dollars" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars"
	string r_gdp_title = "GDP in " + @str(!by_cur) + " Dollars (in billions)" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars (in billions) "
	string r_kgdp_gr_title = "Annual Percentage Change in Potential GDP in " + @str(!by_cur) + " Dollars" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars" 
	string r_kgdp_title = "Potential GDP in " + @str(!by_cur) + " Dollars (in billions)" + ", CBO and " + @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars (in billions) "
endif

string gdp_title = "GDP in Current Dollars (in billions)"
string wsd_title = "U. S. Wage and Salary Disbursements in Current Dollars (in billions)"
string wsd_to_gdp_title = "U. S. Wage and Salary Disbursement as a Percentage of GDP"
string  r_avg_earn_gr_title = "Annual Percent Change in Average Real Earnings  (U.S. earnings)"
string acwa_gr_title = "Annual Percentage Change in Average OASDI Covered Wage"
string r_wage_diff_title = "Real Wage Differential (OASDI Covered Wages) "
string ru_title = "Average Annual Civilian Unemployment Rate"
string lc_title = "Average Annual Civilian Labor Force (millions)"
string ahrs_gr_title = "Annual Percentage Change in Average Weekly Hours Worked (Total Economy)"
string nomintr_title = "Nominal Interest Rate"
string cpiw_u_gr_title = "Average Percentage Change in CPI-W (not seasonally adjusted)"
string pgdp_gr_title = "Annual Percentage Change in GDP Deflator"
string price_diff_title = "Difference Between Annual Percent Change in GDP Deflator and Change in CPI-W"
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

' 	Note (_nt) to be included at the botton of each panel in the ***Summary*** table
' 	Generally, these would not change from year to year, but can be adjusted if needed
'	"N" = no note 
string r_gdp_gr_nt = "N"
string r_gdp_nt = "N"
string gdp_nt = "N"
string r_kgdp_gr_nt = "N"
string wsd_nt = "N"
string wsd_to_gdp_nt = "N"
string r_avg_earn_gr_nt = "N"
string acwa_gr_nt = "Note: For FY " + %FY + " Budget and CBO, the annual percentage change in average *earnings* for the U.S. is presented."
string r_wage_diff_nt = "N"
string ru_nt = "N"
string lc_nt = "N"
string ahrs_gr_nt = "Note: For IHS Markit and Moody's Analytics, percentage change is for average weekly hours in the private nonfarm sector."
string ahrs_gr_nt2 = "For CBO, growth of average hours worked from Sep. 2020 report ''The 2020 Long-Term Budget Outlook'' is presented. "	' SPECIAL FOR TR20 and TR21 -- Special second note for CBO numbers for avg hrs. May not be needed or may be differemt for future TRs. 
string ahrs_gr_nt3 = "For CBO, 10-year averages are simple averages of the rounded annual growth rates. "					' SPECIAL FOR TR20 and TR21 -- Special  note for CBO averages (we need this because we have no level series for ahrs for CBO this year). May not be needed or may be differemt for future TRs. 
string nomintr_nt = "Note: For IHS Markit, Moody's Analytics, and CBO, nominal interest rates for 10-year Treasury notes are presented."
string rintr_nt = "Note: For IHS Markit, Moody's Analytics, and CBO, interest rates for 10-year Treasury notes are presented."
string cpiw_u_gr_nt = "Note: For IHS Markit and CBO, percentage change in CPI-U (not seasonally adjusted) is presented."
string cpiw_gr_nt = "Note: For IHS Markit and CBO, percentage change in CPI-U (seasonally adjusted) is presented."
string cpiw_u_nt = "Note: For IHS Markit and CBO, CPI-U (not seasonally adjusted) is presented."
string pgdp_gr_nt = "N"
string price_diff_nt = "Note: For IHS Markit and CBO, percent change in CPI-U is used in place of percent change in CPI-W."
string lc_gr_nt = "N"
string prod_gr_nt = "Note: For IHS Markit and Moody's Analytics, the computation assumes that the growth rate of average weekly hours is " 
string prod_gr_nt2 = "the same for total economy and for the private nonfarm sector. "
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
	%r_kgdp_gr_tabtitle = "Percentage Change in Potential GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report"
	%r_kgdp_tabtitle = "Potential GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report"
	else 
	%r_gdp_gr_tabtitle = "Percentage Change in GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (" +  @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	%r_gdp_tabtitle = "GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (" +  @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	%r_kgdp_gr_tabtitle = "Percentage Change in Potential GDP (" + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (" +  @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
	%r_kgdp_tabtitle = "Potential GDP (billions of " + @str(!by_cur) + " Dollars, SAAR) for " + @str(!TRyr) + " Trustees Report" + " (" +  @str(!TRpr) + " TR in " + @str(!by_pr) + " Dollars)"
endif

%rtp_tabtitle = "Ratio of Actual to Potential GDP for " + @str(!TRyr) + " Trustees Report"
%cpiw_u_gr_tabtitle = "Percentage Change (annualized) in CPI-W (not seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%cpiw_gr_tabtitle = "Annual Percentage Change in CPI-W (seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%pgdp_gr_tabtitle = "Annual Percentage Change in GDP Deflator (seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%cpiw_u_tabtitle = "CPI-W (not seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
%pgdp_tabtitle = "GDP Deflator (seasonally adjusted) for " + @str(!TRyr) + " Trustees Report"
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


' ******** Parameters needed to properly load data from various source files **********
' This should change infrequently, if at all. If the source files come in in the same format every year, no need to change any of this. 
' Still, it is a good idea to look through the source files to confirm the format corresponds to what's here -- especially for the Excel files!

'list of series to be loaded from TR a-bank:
' %gdp_list and %gdp_list_pr (to be loaded in both quarterly and annual frequency) were defined above to handle the possibility of series name changing with change in base year
%q_list = "pgdp rtp cpiw_u cpiw"		' quarterly series to be loaded from a-bank (current TR and previous TR)
%an_list = "gdp pgdp rtp cpiw_u wsd y e edmil acwa ru ahrs lc lc_fex prod prod_fex beninc"		' annual series to be loaded from a-bank (current TR and previous TR)
' Note: we also load monthly nomintr.m series and transform it to both quarterly and annual frequency; this is entered manually in the code below.

' *** Budegt data *** -- locations withing Excel file
' These SHOULD NOT change from year to year, if OMB does not change the format of the file they send us.
'  Still -- it is a good idea to double-check every year that the format is still the same. If not, adjust the cell references here.
!gdp_qtr_ch = 4 			' parameter that goes into colhead= option for 'GDP_Qtr' sheet; number of rows that contain column headings (the last row of which contains the invisible series names)
!trust_rates_ch = 4 		' parameter that goes into colhead= option for 'Trust_Rates' sheet; number of rows that contain column headings (the last row of which contains the invisible series names)
%gdp_ann = "B9:K22" 	' range in 'GDP_Annual' sheet; this includes the first row with invisible names
%pi_ann = "H9:I22" 		' range in 'Pers_Inc_Annual' sheet; wages and salaries section; this includes the first row with invisible names
%cola_ann = "B8:B19" 	' range in 'COLAs' sheet, does NOT include any rows with names
%cpi_nsa_cols = "B C D E F G H I J K L M N"  ' columns in 'CPIW_NSA' sheet that contain monthly data
!cpi_nsa_r1 = 7 			'  starting row for monthly data in 'CPIW_NSA' sheet 
!cpi_nsa_r2 = 18 			'  last row for monthly data in 'CPIW_NSA' sheet 
%cpi_sa_cols = "B C D E F G H I J K L M N"  ' columns in 'CPIW_SA' sheet that contain monthly data
!cpi_sa_r1 = 7 			'  starting row for monthly data in 'CPIW_SA' sheet 
!cpi_sa_r2 = 18 			'  last row for monthly data in 'CPIW_SA' sheet 

' *** Moodys data *** -- locations within Excel file
' These SHOULD NOT change from year to year, if Moodys sends the file in the same format
'  Still -- it is a good idea to double-check every year that the format is still the same. If not, adjust the cell references here.
!mdy_head = 7 		' parameter that goes into colhead= option for Moodys' Excel file; number of rows that contain column headings
%mdy_names = "first"	' parameter that indicates that the FIRST row of column heading in Moodys Excel file contains the series names
%mdy_range_q = "Sheet1!B:AB"	' Columns in Moody's Excel file that contain LEVELS for Quarterly data (there are also growth rates for quarterly data -- ignore those columns).
%mdy_range_a = "Sheet1!AE:BE" ' Columns in Moody's Excel file that contain LEVELS for Annual data (there are also growth rates for annual data -- ignore those columns).

' *** CBO data *** -- locations within Excel file
' This refers to Excel file I temporarily maode for TR20. We are working on receiving the data from CBO in EViews file in the form we can use. I am creating this as a backup in case CBO does not send us the data in time.
!cbo_head = 3 		' parameter that goes into colhead= option; number of rows that contain column headings
%cbo_names = "last"	' parameter that indicates that the LAST row of column heading contains the series names
%cbo_range_q = "q_tables"	' Sheet within CBO's Excel file that contain quarterly data. Range of columns is not required -- we will read the entire sheet.
%cbo_range_a = "a_tables"	' Sheet within CBO's Excel file that contain annual data. Range of columns is not required -- we will read the entire sheet

' *** Done with parameters describing the input files ***

wfselect {%thisfile}
' Placeholders for current TR alt1 and alt3. 
' Need these to exists even when we make tables for alt2 only. If making tables for all alts, this should not be run (hence the if statement).
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
	dbopen(type=aremos) %abank_alt{%alt}
	for %ser {%q_list} {%gdp_list} 	
		fetch {%ser}.q
	next
	fetch(c=an) nomintr.m

	close @db
	
	'rename series to indicate TR and alt
	%tralt = @str(!TRyr-2000) + %alt
	for %s {%q_list} 				
		rename {%s} {%s}_{%tralt}	
	next
	for %s {%gdp_list} 
		%test = @left(%s, 1)
		if %test = "g" then
			rename {%s} r_gdp_{%tralt}
		endif
		if %test = "k" then
			rename {%s} r_kgdp_{%tralt}
		endif
	next
	rename nomintr_m nomintr_{%tralt}
next
	%msg = "Done."
	logmsg {%msg}
	logmsg
	
	'Previous-year TR
	'loop through alts
	%msg = "Loading quarterly data for TR" + @str(!TRpr) + "..."
	logmsg {%msg}
	
for %alt 1 2 3	
	dbopen(type=aremos) %abank_pr_alt{%alt}
	for %ser {%q_list} {%gdp_list_pr} 
		fetch {%ser}.q
	next
	fetch(c=an) nomintr.m
	
	close @db
	
	'rename series to indicate TR and alt
	%tralt = @str(!TRpr-2000) + %alt
	for %s {%q_list} 		
		rename {%s} {%s}_{%tralt}
	next
	for %s {%gdp_list_pr} 
		%test = @left(%s, 1)
		if %test = "g" then
			rename {%s} r_gdp_{%tralt}
		endif
		if %test = "k" then
			rename {%s} r_kgdp_{%tralt}
		endif
	next
	rename nomintr_m nomintr_{%tralt}
next
	%msg = "Done."
	logmsg {%msg}
	logmsg

'Outside forecasters
' creating placeholder series for now
wfselect {%thisfile}
pageselect quarterly
smpl @all
for %s {%tables_list}
	series {%s}_ihs			'IHS Markit
	'series {%s}_mdy			'Moody's
	series {%s}_bgt			'Budget
	series {%s}_cbo			'CBO
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
delete gdp_re* gdp_no* gdp_pr* unempl_* 'delete remaning unnecessary series

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
   import(mode="u") %omb range="CPIW_NSA"!{%col}{!cpi_nsa_r1}:{%col}{!cpi_nsa_r2} names="cpiw_u_bgt_index" @freq m !yr ' cell reference to data loaction {%col}{!cpi_nsa_r1}:{%col}{!cpi_nsa_r2} is specified at start of this program
   !yr = !yr + 1
next

' CPIW_SA worksheet. Same approach as for CPIW_NSA above. 
!yr = !yr_bgt
for %col {%cpi_sa_cols}
   import(mode="u") %omb range="CPIW_SA"!{%col}{!cpi_sa_r1}:{%col}{!cpi_sa_r2} names="cpiw_bgt_index" @freq m !yr ' cell reference to data loaction {%col}{!cpi_sa_r1}:{%col}{!cpi_sa_r2} is specified at start of this program
   !yr = !yr + 1
next


'divide both by 100 for comparability to TR data
genr cpiw_u_bgt = cpiw_u_bgt_index/100
genr cpiw_bgt = cpiw_bgt_index/100

' copy monthly CPIW NSA and SA series into quarterly page to convert
wfselect {%thisfile}
pageselect quarterly
smpl @all
copy(o, c=an) monthly\cpiw_u_bgt quarterly\
copy(o, c=an) monthly\cpiw_bgt quarterly\

'	Compute the seasonal adjustment factor for CPIW (equivalent to 'CPIW & CPIW_U worksheet' in SR tables Excel file)
genr CPIW_seas = cpiw_u_bgt/cpiw_bgt	' the seasonal adjustmetn factor is based on Budget data, but used for several other forecasters

' load  series from aombXX databank; raname accordingly
wfselect {%thisfile}
pageselect quarterly
smpl @all

dbopen(type=aremos) %budget_path
fetch rtp.q
genr rtp_bgt = rtp
delete rtp

wfselect {%thisfile}
pageselect monthly
smpl @all

fetch nomintr.m
rename nomintr nomintr_bgt
close @db

wfselect {%thisfile}
pageselect quarterly
smpl @all
genr r_kgdp_bgt = r_gdp_bgt/rtp_bgt	' generate potential GDP from real GDP and rtp
copy(o, c=an) monthly\nomintr_bgt quarterly\

%msg = "Done."
logmsg {%msg}
logmsg

' *** Load Moody's Analytics data  -- Quarterly***
%msg = "Loading quarterly data for Moody's ..." 
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all

import %mdy_source range=%mdy_range_q colhead=!mdy_head namepos={%mdy_names} @freq q {%mdy_startq}  

' NOTE1: all series names in Moody's Excel files start with "F". AT THIS POINT in the workfile, there are NO other series (or any objects) whose name starts with F. Once we rename the Moody's series we need, can delete the rest by doing simply: delete f*.
' NOTE2: when importing series from Moody's Excel file, EViews has populated some of the fields in Label. Specifically, in 'Description' field it put in a very useful descritpion combining rows 2 through 7 of Excel. Here is an example from CPIW:
'  "Baseline Scenario (November 2018): CPI: Urban Wage Earner - All Items, (Index 1982-84=100, SA) U.S. Bureau of Labor Statistics (BLS); Moody's Analytics Forecasted None AVERAGED IUSA 11/05/2018"

' rename series

rename fcpiw cpiw_mdy
cpiw_mdy = cpiw_mdy / 100 		' CPIW SA level

rename fpdpgdp pgdp_mdy
pgdp_mdy = pgdp_mdy / 100 		' PGDP level

rename fgdp gdp_mdy					' nominal GDP
rename fgdp$ r_gdp_mdy				' real GDP
rename fgdp$_pot r_kgdp_mdy		' real potential GDP

rename frgt10y nomintr_mdy			' nominal interest rate, 10yr Treasurys

rename flbf lc_mdy				' civ LF
rename flbe e_mdy				' employment
rename flbr ru_mdy			' un. rate
rename fnairu ru_fe_mdy 		' FE un. rate (for Moody's we use NAIRU)
rename fypewsq wsd_mdy	' wages and salaries
rename flbf_pot lc_fex_mdy	' potential labor force
rename fypeppfrq yf_mdy		' farm prop. income
rename fypeppnfq ynf_mdy	' nonfarm prop. income
rename fpcnbawh ahrs_mdy 	' avg. weekly hrs --- NOT SURE about this one

genr rtp_mdy = r_gdp_mdy / r_kgdp_mdy	' compute RTP
genr cpiw_u_mdy = cpiw_mdy * CPIW_seas	' create CPIW NSA level by using the seasonal adjustment factor (CPIW_seas) derived from budget data
' create special series cpiwq3_ihs that contains Q3 values of cpiw_u_ihs and NAs everywhere else; need this for COLA values in long table 6
genr cpiwq3_mdy = cpiw_u_mdy
smpl @all if @quarter <>3
cpiwq3_mdy = NA
smpl @all

delete f* 		' deleting remaining series loaded from Moodys Excel.

%msg = "Done."
logmsg {%msg}
logmsg


' *** Load IHS Global (IHS Markit) data ***
%msg = "Loading quarterly data for IHS ..." 
logmsg {%msg}

wfselect {%thisfile}
pageselect quarterly
smpl @all

wfopen %ihs_source ' %ihs_source is an EViews workfile
' these series we need in quarterly frequency
copy {%ihs_file}::\gdp_0 {%thisfile}::quarterly\gdp_ihs	' nominal GDP
copy {%ihs_file}::\gdpr_0 {%thisfile}::quarterly\r_gdp_ihs	' real GDP
copy {%ihs_file}::\gdpfer_0 {%thisfile}::quarterly\r_kgdp_ihs	' real potential GDP
copy {%ihs_file}::\jpgdp_0 {%thisfile}::quarterly\pgdp_ihs	' GDP deflator
copy {%ihs_file}::\cpi_0 {%thisfile}::quarterly\cpiw_ihs	' CPI-U, seasonally adjusted
copy {%ihs_file}::\rmtcm10y_0 {%thisfile}::quarterly\nomintr_ihs	' 10yr Treasury rates, nominal

' these series we need in annual frequency, but IHS EViews file has only quarterly frequency for everything; thus we load them quarterly and then will transform to annual
copy {%ihs_file}::\ypcompwsd_0 {%thisfile}::quarterly\wsd_ihs	' wsd
copy {%ihs_file}::\hrnfpri_0 {%thisfile}::quarterly\ahrs_ihs			' avg wkly hrs
copy {%ihs_file}::\nlfc_0 {%thisfile}::quarterly\lc_ihs					' civ LF
copy {%ihs_file}::\ruc_0 {%thisfile}::quarterly\ru_ihs					' un rate
copy {%ihs_file}::\ehhc_0 {%thisfile}::quarterly\e_ihs					' employment
copy {%ihs_file}::\yppropadjf_0 {%thisfile}::quarterly\yf_ihs			' prop. income farm
copy {%ihs_file}::\yppropadjnf_0 {%thisfile}::quarterly\ynf_ihs		' prop. income nonfarm
copy {%ihs_file}::\nlfcfe {%thisfile}::quarterly\lc_fex_ihs				' FE labor force
copy {%ihs_file}::\rufe {%thisfile}::quarterly\ru_fe_ihs					' FE un rate

wfclose %ihs_source

wfselect {%thisfile}
pageselect quarterly
smpl @all
rtp_ihs = r_gdp_ihs / r_kgdp_ihs		' compute rtp
pgdp_ihs = pgdp_ihs/100				' re-scale PGDP 

cpiw_u_ihs = cpiw_ihs * CPIW_seas	' create non-SA CPI by using the seasonal adjustment factor (CPIW_seas) derived from budget data
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

import %cbo_source range=%cbo_range_q colhead=!cbo_head namepos={%cbo_names} @freq q {%cbo_startq}  ' this imports ALL series in the Excel file with CBO data.
' The series in the Excel files are named by me, so most of them already have the names we need.

genr cpiw_cbo = cpiu_cbo / 100 	' set series cpiw_cbo equal to the CPIU data from CBO re-scaled (CBO has no CPIW data, same as IHS and Moody's)
'genr lc_fex_cbo = pop_cbo * lfpr_fex_cbo / 100		' FE labor force. SPECIAL FOR TR21 -- CBO source file already has "potential labor force", so I simply load it (in the above 'import' command); thus no need to compute it.

r_gdp_cbo = gdp12_cbo
r_kgdp_cbo = kgdp12_cbo
rtp_cbo = r_gdp_cbo / r_kgdp_cbo			' RTP
pgdp_cbo = pgdp_cbo/100					' re-scale PGDP

genr prod2_cbo = r_gdp_cbo / e_cbo

cpiw_u_cbo = cpiw_cbo * CPIW_seas	' create non-SA CPI by using the seasonal adjustment factor (CPIW_seas) derived from budget data
' create special series cpiwq3_cbo that contains Q3 values of cpiw_u_cbo and NAs everywhere else; need this for COLA values in long table 6
genr cpiwq3_cbo = cpiw_u_cbo
smpl @all if @quarter <>3
cpiwq3_cbo = NA
smpl @all

%msg = "Done."
logmsg {%msg}
logmsg
' *** Done with CBO quarterly data



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
	dbopen(type=aremos) %abank_alt{%alt}
	for %ser {%an_list} {%gdp_list} 
		fetch {%ser}.a
	next
	fetch(c=an) nomintr.m
	
	close @db
	
	'rename series to indicate TR and alt
	%tralt = @str(!TRyr-2000) + %alt
	for %s {%an_list} 
		rename {%s} {%s}_{%tralt}
	next
	rename beninc_{%tralt} cola_{%tralt}
	for %s {%gdp_list}
		%test = @left(%s, 1)
		if %test = "g" then
			rename {%s} r_gdp_{%tralt}
		endif
		if %test = "k" then
			rename {%s} r_kgdp_{%tralt}
		endif
	next
	rename nomintr_m nomintr_{%tralt}
next
%msg = "Done."
logmsg {%msg}
logmsg

	'Previous-year TR
	'loop through alts
	%msg = "Loading/creating annual data for TR" + @str(!TRpr) + "..."
	logmsg {%msg}
	
for %alt 1 2 3	
	dbopen(type=aremos) %abank_pr_alt{%alt}
	for %ser {%an_list} {%gdp_list_pr} 		
		fetch {%ser}.a
	next
	fetch(c=an) nomintr.m
	
	close @db
	
	'rename series to indicate TR and alt
	%tralt = @str(!TRpr-2000) + %alt
	for %s {%an_list}  
		rename {%s} {%s}_{%tralt}
	next
	rename beninc_{%tralt} cola_{%tralt}
	for %s {%gdp_list_pr} 
		%test = @left(%s, 3)
		if %test = "gdp" then
			rename {%s} r_gdp_{%tralt}
		endif
		if %test = "kgd" then
			rename {%s} r_kgdp_{%tralt}
		endif
	next
	rename nomintr_m nomintr_{%tralt}

next
%msg = "Done."
logmsg {%msg}
logmsg

'Outside forecasters
' creating placeholder series for now
pageselect annual
for %s {%global_list}
	series {%s}_ihs			'IHS Markit
	'series {%s}_mdy		'Moody's			11-25-2019 I don't remember why I commented this one out, but there was a reason. It is not just a typo!
	series {%s}_bgt			'Budget
	series {%s}_cbo		'CBO
next

' Budget
%msg = "Loading/creating annual data for Budget ..."
logmsg {%msg}
	
wfselect {%thisfile}	
pageselect annual
smpl @all
import %omb range="GDP_Annual"!{%gdp_ann} colhead=1 namepos=first @freq a !yr_bgt 'the cell range {%gdp_ann} is specified above at the start of ptogram; this command relies on the "invisible" variable names located in row 9 in the budget assumption Excel file ('namepos=first' reads these as the variables names for the workfile). 
' rename to indicate sourse as bgt (budget)
genr r_gdp_bgt = gdp_real 
genr ru_bgt = unempl_rate
delete gdp_nom* gdp_re* gdp_price* unem* 'deleting remaning unnecessary series

import %omb range="Pers_Inc_Annual"!{%pi_ann} colhead=1 namepos=first @freq a !yr_bgt 'the cell range {%pi_ann} is specified above at the start of ptogram; this command relies on the "invisible" variable names located in row 9 in the budget assumption Excel file
genr wsd_bgt = wages_salaries 
genr wsd_to_gdp_bgt = wages_salaries_pct
delete wages_* 'deleting remaning unnecessary series

'projected COLAs
import %omb range="COLAs"!{%cola_ann} colhead=0 names="cola_bgt" @freq a !yr_bgt 'the cell range {%cola_ann} is specified above at the start of program. Note that B8 is labeled in Budget file as 'cola for Jan 2018' but here I call it COLA for 2017, and similarly for all later years.

' load some series from aombXX.bnk
dbopen(type=aremos) %budget_path
fetch prod.a lc.a ahrs.a e.a edmil.a yf.a ynf.a
close @db
genr prod_bgt = prod
genr prod_fex_bgt = prod ' for budget, we show prod_fex (full-empl productivity) only for yrs where rtp=1, at which point prod_fex=prod
genr lc_bgt = lc
genr lc_fex_bgt = lc  ' for budget, we show lc_fex (full-empl labor force) only for yrs where rtp=1, at which point lc_fex=lc
genr ahrs_bgt = ahrs
genr e_bgt = e
genr edmil_bgt = edmil
genr yf_bgt = yf
genr ynf_bgt = ynf

delete prod lc ahrs e edmil yf ynf

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

import %mdy_source range=%mdy_range_a colhead=!mdy_head namepos={%mdy_names} @freq a {%mdy_starta}  

' NOTE1: all series names in Moody's Excel files start with "F". AT THIS POINT in the workfile, there are NO other series (or any objects) whose name starts with F. Once we rename the Moody's series we need, can delete the rest by doing simply: delete f*.
' NOTE2: when importing series from Moody's Excel file, EViews has populated some of the fields in Label. Specifically, it 'Description' field it put in a very useful descritpion combining rows 2 through 7 of Excel. Here is an example from CPIW:
'  "Baseline Scenario (November 2018): CPI: Urban Wage Earner - All Items, (Index 1982-84=100, SA) U.S. Bureau of Labor Statistics (BLS); Moody's Analytics Forecasted None AVERAGED IUSA 11/05/2018"

' rename series

rename fcpiw cpiw_mdy
cpiw_mdy = cpiw_mdy / 100 		' CPIW SA level

rename fpdpgdp pgdp_mdy
pgdp_mdy = pgdp_mdy / 100 		' PGDP level

rename fgdp gdp_mdy					' nominal GDP
rename fgdp$ r_gdp_mdy				' real GDP
rename fgdp$_pot r_kgdp_mdy		' real potential GDP

rename frgt10y nomintr_mdy			' nominal interest rate, 10yr Treasurys

rename flbf lc_mdy			' civ LF
rename flbe e_mdy			' employment
rename flbr ru_mdy		' un. rate
rename fnairu ru_fe_mdy		' FE un. rate (for Moody's we use NAIRU)
rename fypewsq wsd_mdy	' wages and salaries
rename flbf_pot lc_fex_mdy	' potential labor force
rename fypeppfrq yf_mdy		' farm prop. income
rename fypeppnfq ynf_mdy	' nonfarm prop. income
rename fpcnbawh ahrs_mdy 	' avg. weekly hrs --- NOT SURE about this one

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

delete f* 		' deleting remaining series loaded from Moodys Excel.

%msg = "Done."
logmsg {%msg}
logmsg

' *** Load IHS Global (IHS Markit) data -- Annual ***
%msg = "Loading/creating annual data for IHS ..."
logmsg {%msg}

wfselect {%thisfile}
pageselect annual
smpl @all

'copy series from quarterly into annual
copy(o, c=an) quarterly\gdp_ihs annual\
copy(o, c=an) quarterly\r_gdp_ihs annual\
copy(o, c=an) quarterly\r_kgdp_ihs annual\
copy(o, c=an) quarterly\pgdp_ihs annual\
copy(o, c=an) quarterly\nomintr_ihs annual\
copy(o, c=an) quarterly\cpiw_u_ihs annual\
copy(o, c=an) quarterly\cpiw_ihs annual\

copy(o, c=an) quarterly\wsd_ihs annual\
copy(o, c=an) quarterly\ahrs_ihs annual\
copy(o, c=an) quarterly\lc_ihs annual\
copy(o, c=an) quarterly\ru_ihs annual\
copy(o, c=an) quarterly\e_ihs annual\
copy(o, c=an) quarterly\yf_ihs annual\
copy(o, c=an) quarterly\ynf_ihs annual\
copy(o, c=an) quarterly\lc_fex_ihs annual\
copy(o, c=an) quarterly\ru_fe_ihs annual\


copy(o, c=l) quarterly\cpiwq3_ihs annual\cpiwq3_ihs	' copy Qtr3 value of CPI(NSA) as annual; this is used to compute COLA below 

wfselect {%thisfile}
pageselect annual
smpl @all
rtp_ihs = r_gdp_ihs / r_kgdp_ihs
prod_ihs = r_gdp_ihs / e_ihs
'prod_fex_ihs = r_kgdp_ihs / lc_fex_ihs/(1 - ru_fe_ihs/100)			' We've decided to keep these series NAs doe TR20
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

import %cbo_source range=%cbo_range_a colhead=!cbo_head namepos={%cbo_names} @freq a {%cbo_starta} 	' For Aug 2019 release this loads only lc_fex and ahrs_gr
' The series in the Excel files are named by me, so most of them already have the names we need.

'copy series from quarterly into annual
copy(o, c=an) quarterly\gdp_cbo annual\
copy(o, c=an) quarterly\r_gdp_cbo annual\
copy(o, c=an) quarterly\r_kgdp_cbo annual\
copy(o, c=an) quarterly\pgdp_cbo annual\
copy(o, c=an) quarterly\nomintr_cbo annual\
copy(o, c=an) quarterly\cpiw_u_cbo annual\
copy(o, c=an) quarterly\cpiw_cbo annual\

copy(o, c=an) quarterly\wsd_cbo annual\
'copy(o, c=an) quarterly\ahrs_cbo annual\	' For Tr20 and TR21 we do not have LEVEL of ahrs from CBO. Handling it differently  -- see import command above.
copy(o, c=an) quarterly\lc_cbo annual\
copy(o, c=an) quarterly\ru_cbo annual\
copy(o, c=an) quarterly\e_cbo annual\
copy(o, c=an) quarterly\yf_cbo annual\
copy(o, c=an) quarterly\ynf_cbo annual\
copy(o, c=an) quarterly\lc_fex_cbo annual\ 
copy(o, c=an) quarterly\ru_fe_cbo annual\

copy(o, c=l) quarterly\cpiwq3_cbo annual\cpiwq3_cbo	' copy Qtr3 value of CPI(NSA) as annual; this is used to compute COLA below. 


wfselect {%thisfile}
pageselect annual
smpl @all
rtp_cbo = r_gdp_cbo / r_kgdp_cbo
prod_cbo = r_gdp_cbo / e_cbo
prod_fex_cbo = r_kgdp_cbo / lc_fex_cbo/(1 - ru_fe_cbo/100)			
wsd_to_gdp_cbo = 100* (wsd_cbo / gdp_cbo)
cola_cbo = ((cpiwq3_cbo / cpiwq3_cbo(-1)) -1) *100

%msg = "Done."
logmsg {%msg}
logmsg
'	***** DONE loading and renaming ALL data

%msg = "Done loading and renaming all data."
logmsg {%msg}
logmsg

'generate necessary series
%msg = "Generating necessary quarterly series ..."
logmsg {%msg}

'quarterly			
wfselect {%thisfile}	
pageselect quarterly	
smpl @all			
' Current TR
%msg = "for TR" + @str(!TRyr) + "..."
logmsg {%msg}

for %alt {%alt_cur}
	%tralt = @str(!TRyr-2000) + %alt
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})	
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr rintr_{%tralt} = ((nomintr_{%tralt}(-4)/100/2+1)^2/(cpiw_{%tralt}/cpiw_{%tralt}(-4))-1)*100
next
' Previous-yr TR
%msg = "for TR" + @str(!TRpr) + "..."
logmsg {%msg}

for %alt 1 2 3
	%tralt = @str(!TRpr-2000) + %alt
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})	
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr rintr_{%tralt} = ((nomintr_{%tralt}(-4)/100/2+1)^2/(cpiw_{%tralt}/cpiw_{%tralt}(-4))-1)*100
next	
' Outside forecasters
%msg = "for outside forecasters ..."
logmsg {%msg}

for %src bgt ihs mdy cbo 
	genr r_gdp_gr_{%src} = @pca(r_gdp_{%src})
	genr r_kgdp_gr_{%src} = @pca(r_kgdp_{%src})	
	genr cpiw_u_gr_{%src} = @pca(cpiw_u_{%src})
	genr cpiw_gr_{%src} = @pca(cpiw_{%src})	
	genr pgdp_gr_{%src} = @pca(pgdp_{%src})
	genr rintr_{%src} = ((nomintr_{%src}(-4)/100/2+1)^2/(cpiw_{%src}/cpiw_{%src}(-4))-1)*100
next	

%msg = "Done."
logmsg {%msg}
logmsg

' *** Create labels for all quarterly series ***
%msg = "Creating labels for quarterly series ..."
logmsg {%msg}

%col_list_lim = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3" ' +ihs mdy bgt cbo
' only create labels for TR and Budget, the rest have labels loaded from their respective source files
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

next	
cpiw_seas.label(d) Seasonal adjustment factor for CPIW (derived from Budget forecast)

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
	%ihs_txt = "IHS Markit Projections, released " + %date_ihs
	%cbo_txt = "CBO Projections, released " + %date_cbo
	%mdy_txt = "Moody's Analytics Projections, released " + %date_mdy
	{%ser}_bgt.label(s) {%bgt_txt}
	{%ser}_ihs.label(s) {%ihs_txt}
	{%ser}_cbo.label(s) {%cbo_txt}
	{%ser}_mdy.label(s) {%mdy_txt}
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
	 			
	 			
'annual 
wfselect {%thisfile}
pageselect annual
smpl @all
%msg = "Generating necessary annual series ..."
logmsg {%msg}

' Current TR
for %alt {%alt_cur}
	%tralt = @str(!TRyr-2000) + %alt
	'copy some series from quarterly (as annual averages) 
	copy(c=an) quarterly\rintr_{%tralt} annual\  	' quarterly rintr series, tranform to annual as average
	copy(c=an) quarterly\cpiw_{%tralt} annual\  	' cpiw series, tranform to annual as average
	
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})	
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr wsd_to_gdp_{%tralt} = 100*wsd_{%tralt}/gdp_{%tralt}
	genr r_avg_earn_{%tralt} = (wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt}
	genr r_avg_earn_gr_{%tralt} = @pca(r_avg_earn_{%tralt}) '(wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt})
	genr acwa_gr_{%tralt} = @pca(acwa_{%tralt})
	genr r_wage_diff_{%tralt} = @pca(acwa_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr ahrs_gr_{%tralt} = @pca(ahrs_{%tralt})
	genr price_diff_{%tralt} = @pca(pgdp_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr lc_gr_{%tralt} = @pca(lc_{%tralt})
	genr prod_gr_{%tralt} = @pca(prod_{%tralt})
	genr lc_fex_gr_{%tralt} = @pca(lc_fex_{%tralt})
	genr prod_fex_gr_{%tralt} = @pca(prod_fex_{%tralt})

next
' Previous-yr TR
for %alt 1 2 3
	%tralt = @str(!TRpr-2000) + %alt
	'copy some series from quarterly (as annual averages) 
	copy(c=an) quarterly\rintr_{%tralt} annual\  	' quarterly rintr series, tranform to annual as average
	copy(c=an) quarterly\cpiw_{%tralt} annual\  	' cpiw series, tranform to annual as average
	
	genr r_gdp_gr_{%tralt} = @pca(r_gdp_{%tralt})
	genr r_kgdp_gr_{%tralt} = @pca(r_kgdp_{%tralt})	
	genr cpiw_u_gr_{%tralt} = @pca(cpiw_u_{%tralt})	
	genr cpiw_gr_{%tralt} = @pca(cpiw_{%tralt})
	genr pgdp_gr_{%tralt} = @pca(pgdp_{%tralt})
	genr wsd_to_gdp_{%tralt} = 100*wsd_{%tralt}/gdp_{%tralt}
	genr r_avg_earn_{%tralt} = (wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt}
	genr r_avg_earn_gr_{%tralt} = @pca(r_avg_earn_{%tralt}) '(wsd_{%tralt} + y_{%tralt})/(e_{%tralt} + edmil_{%tralt})/cpiw_u_{%tralt})
	genr acwa_gr_{%tralt} = @pca(acwa_{%tralt})
	genr r_wage_diff_{%tralt} = @pca(acwa_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr ahrs_gr_{%tralt} = @pca(ahrs_{%tralt})
	genr price_diff_{%tralt} = @pca(pgdp_{%tralt}) - @pca(cpiw_u_{%tralt})
	genr lc_gr_{%tralt} = @pca(lc_{%tralt})
	genr prod_gr_{%tralt} = @pca(prod_{%tralt})
	genr lc_fex_gr_{%tralt} = @pca(lc_fex_{%tralt})
	genr prod_fex_gr_{%tralt} = @pca(prod_fex_{%tralt})
	
next	


' Outside forecasters
pageselect annual

' copy from quarterly as annual average
copy(o, c=an) quarterly\rintr_bgt annual\
copy(o, c=an) quarterly\rintr_ihs annual\
copy(o, c=an) quarterly\rintr_mdy annual\
copy(o, c=an) quarterly\rintr_cbo annual\

' Some special computations that vary by source:
' Budget
genr acwa_bgt = (wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt)		' note that we use avg earnings for acwa in Budget
genr acwa_gr_bgt = @pca((wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt))
genr r_avg_earn_bgt = (wsd_bgt + yf_bgt + ynf_bgt)/(e_bgt+edmil_bgt)/cpiw_u_bgt

'Moodys
genr r_avg_earn_mdy = (wsd_mdy + yf_mdy + ynf_mdy)/(e_mdy)/cpiw_u_mdy
genr prod_fex_mdy = r_kgdp_mdy / lc_fex_mdy/(1 - ru_fe_mdy/100)
series acwa_mdy			' series filled with NAs
series acwa_gr_mdy		' series filled with NAs
series r_wage_diff_mdy	' series filled with NAs

' IHS
genr r_avg_earn_ihs = (wsd_ihs + yf_ihs + ynf_ihs)/(e_ihs)/cpiw_u_ihs
genr acwa_ihs = (wsd_ihs + yf_ihs + ynf_ihs)/(e_ihs)			
genr acwa_gr_ihs = @pca(acwa_ihs)

' CBO
genr r_avg_earn_cbo = (wsd_cbo + yf_cbo + ynf_cbo)/(e_cbo)/cpiw_u_cbo
series acwa_cbo = (wsd_cbo + yf_cbo + ynf_cbo)/(e_cbo)			
series acwa_gr_cbo = @pca(acwa_cbo)		
series ahrs_gr_cbo_keep = ahrs_gr_cbo	' save ahrs_gr series loaded from Excel so that they are not replaces in the loop that follows.
prod_fex_cbo = r_kgdp_cbo / lc_fex_cbo/(1 - ru_fe_cbo/100) 	
series r_wage_diff_cbo	' series filled with NAs

for %src bgt ihs mdy cbo 
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
	
next	

' special for Budget -- remove values for r_kgdp_gr_bgt, r_kgdp_bgt, rtp_bgt, lc_fex, lc_fex_gr, prod_fex, prod_fex_gr when rtp is not euqal to 1. 
for %p quarterly annual
	pageselect {%p} 
	genr r_kgdp_bgt = @recode(rtp_bgt=1, r_kgdp_bgt, NA)
	genr r_kgdp_gr_bgt = @recode(rtp_bgt=1, r_kgdp_gr_bgt, NA)
	genr lc_fex_bgt = @recode(rtp_bgt=1, lc_fex_bgt, NA)
	genr prod_fex_bgt = @recode(rtp_bgt=1, prod_fex_bgt, NA)
	genr lc_fex_gr_bgt = @recode(rtp_bgt=1, lc_fex_gr_bgt, NA)
	genr prod_fex_gr_bgt = @recode(rtp_bgt=1, prod_fex_gr_bgt, NA)
	genr rtp_bgt = @recode(rtp_bgt=1, rtp_bgt, NA)
next

'Special for IHS -- set ahrs_gr in the first year of the table to the value from current TR alt 2. Example: for TR19, set 2018 value of ahrs_gr_ihs = ahrs_gr_192
'%s = @str(!TRyr-1)
'%tralt = @str(!TRyr-2000) + "2"
'smpl %s %s
'ahrs_gr_ihs = ahrs_gr_{%tralt}
'smpl @all

wfselect {%thisfile}
pageselect annual
smpl @all
' Special for CBO in 2019
' restore ahrs_gr series that just got replaced by NAs in the loop above
ahrs_gr_cbo = ahrs_gr_cbo_keep
delete ahrs_gr_cbo_keep

' Special for Implied growth of total-economy productivity
prod_gr_ihs = prod_gr_ihs - ahrs_gr_ihs
prod_fex_gr_ihs = prod_fex_gr_ihs - ahrs_gr_ihs

prod_gr_mdy = prod_gr_mdy - ahrs_gr_mdy
prod_fex_gr_mdy = prod_fex_gr_mdy - ahrs_gr_mdy

prod_gr_cbo = prod_gr_cbo - ahrs_gr_cbo
prod_fex_gr_cbo = prod_fex_gr_cbo - ahrs_gr_cbo

%msg = "Done."
logmsg {%msg}
logmsg

' *** Create labels for all annual series ***
%msg = "Creating labels for annual series ..."
logmsg {%msg}

' create this similar to how it was done for quarterly series, but use %summ_list or %global_list as the  master list of names
	%col_list_lim = @str(!TRpr-2000)+"1 " + @str(!TRpr-2000)+"2 "+ @str(!TRpr-2000)+"3 bgt "+@str(!TRyr-2000)+"1 "+@str(!TRyr-2000)+"2 "+ @str(!TRyr-2000)+"3" ' +ihs mdy bgt cbo

' only create labels for TR and Budget, the rest have labels loaded from their respective source files
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
	
	r_wage_diff_{%src}.label(d) Real wage differential (OASDI Covered Wage)
	
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
	%ihs_txt = "IHS Markit Projections, released " + %date_ihs
	%cbo_txt = "CBO Projections, released " + %date_cbo
	%mdy_txt = "Moody's Analytics Projections, released " + %date_mdy
	{%ser}_bgt.label(s) {%bgt_txt}
	{%ser}_ihs.label(s) {%ihs_txt}
	{%ser}_cbo.label(s) {%cbo_txt}
	{%ser}_mdy.label(s) {%mdy_txt}
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
' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



'****** LONG TABLES******
%msg = "Creating Long tables."
logmsg {%msg}
logmsg

' *****Create quarterly and annual sections of the tables in the coresponding workfile pages 
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

!ntabs = !n -1 	'!ntabs is the number of long tables we have (might need it in the future for formatting); this number is determined by the number of componenets in the %tables_list

' Create special COLA table (annual only), it will be inserted into CPI-W (NSA) long table
pageselect annual
' make a list of columns
%tab_list = ""
for %col {%col_list}
	%tab_list = %tab_list + "cola_" + %col + " "
next
group colas {%tab_list}
smpl !tablestart !tableend
freeze(cola_table) colas.sheet
cola_table.title OASDI Cost of Living Adjustment
cola_table.setformat(@all) f.1	' COLAs should be displayed with 1 decimal (always!)
smpl @all


' Create appropriate averages for series in the long tables; these tables will be called {series}_lavg (i.e. long avg)
pageselect annual
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
			!l = @length(%ser) - 3	' the name of the series is obtained it by cuting off _gr from the name of %ser
			%name = @left(%ser, !l) + "_" + %v ' andf then adding the extension, such as _191, _192, _bgt, etc.
			
			!s1 = !tablestart-1
			!s2 = !tableend-1
			{%ser}_lavg(2,!cl) = 100*((@elem({%name},@str(!s2))/@elem({%name},@str(!s1)))^(1/(!s2 - !s1)) - 1)
			{%ser}_lavg(3,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name},@str(!tablestart)))^(1/(!tableend - !tablestart)) - 1)
			
			!cl = !cl+1
		next
	endif
	if {%ser}_ail = "N" then
		table(1,1) {%ser}_lavg  'declare empty 1x1 table
	endif
next

' Combine quarterly, annual, and average long tables into one full long table
%msg = "Combining quarterly, annual, and average sections into long tables."
logmsg {%msg}
logmsg

' and put the resulting tables into page 'tables'
pageselect tables
'copy relevant tables to page 'tables'
for !t = 1 to !ntabs
	copy quarterly\table{!t} tables\
	copy annual\table{!t} tables\table{!t}_an
next
copy annual\cola_table tables\
copy annual\*_lavg tables\		' copy strings that indicate lavg
copy annual\*_nt tables\		' copy strings that indicate Notes for long tables

'insert annual tables into quarterly to make full tables
!t = 1
for %atab {%tables_list}
	!last_row = table{!t}.@rows + 2
	%loc = "A" + @str(!last_row)
	table{!t}_an.deleterow(1) 2  ' delete first 2 rows of the annual table (series names and line)
	table{!t}_an.copytable table{!t} {%loc}	' insert annual table into long table
	delete table{!t}_an 
	!last_row = table{!t}.@rows + 2	' new last row
	%loc = "A" + @str(!last_row)
	{%atab}_lavg.copytable table{!t} {%loc}	' insert average table into long table
	delete {%atab}_lavg
	table{!t}.setformat(@all) ft.{!{%atab}_dc}	' set decimal places for each table (determined by paramaters !<ser name>_dc defined early in the program), and use comma to separate thousands
	!t = !t + 1
next
' insert cola table into the appropriate long table (this is long table number !cola_t)
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
	!t = !t + 1
next
delete *_nt


%msg = "Done with Long tables."
logmsg {%msg}
logmsg

' DONE with all LONG tables. 



' ***** Create Summary Table ******
%msg = "Creating Summary Table."
logmsg {%msg}
logmsg

' %summ_list gives the list and order of series to be included in the Summary table
wfselect {%thisfile}
pageselect annual
smpl @all
!sum_tablestart = !tablestart -1 ' the first year to dipaly in each panel of the summary table.

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
			!s1 = !tablestart			' NOTE: We are computing simple average over **10** years. Even though the row label will say something like '2018 - 2028' we are NOT averaging values for years 2018 through 2028 -- because that would be 11 years, not 10. Instead for 2018-2028 period we are averageing value for 2019 through 2028, and for 2019-2029 period we are averaging values 2020-2029. 
			!s2 = !tableend-1
			smpl !s1 !s2
			{%ser}_avg(2,!cl) = @mean({%ser}_{%v})
			!s1 = !tablestart+1
			!s2 = !tableend
			smpl !s1 !s2
			{%ser}_avg(3,!cl) = @mean({%ser}_{%v})
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
			!l = @length(%ser) - 3	' the name of the series is obtained it by cuting off _gr from the name of %ser
			%name = @left(%ser, !l) + "_" + %v ' and then adding the extension, such as _191, _192, _bgt, etc.
			
			!s1 = !tablestart-1
			!s2 = !tableend-1
			{%ser}_avg(2,!cl) = 100*((@elem({%name},@str(!s2))/@elem({%name},@str(!s1)))^(1/(!s2 - !s1)) - 1)
			{%ser}_avg(3,!cl) = 100*((@elem({%name},@str(!tableend))/@elem({%name},@str(!tablestart)))^(1/(!tableend - !tablestart)) - 1)
			
			!cl = !cl+1
		next
	endif
next

' SPECIAL FOR TR2020
' Manually create 10-yr average for ahrs_gr for CBO (in Summary Table). For Tr20 we have CBO data for ahrs GROWTH, but no data for ahrs LEVEL. In Summary table we report Compound annual average for ahrs_gr, which is normally computed from the level series. Since we do nto have th elevel series for CBO, the avareg somes otu to be NA. This looks strange -- values are present for every year, but 10-yr average is NA. Thus, instead here I will com,pute simple 10yr average of ahrs_gr for CBO 
!s1 = !tablestart
!s2 = !tableend-1
smpl !s1 !s2
ahrs_gr_avg(2,8) = @mean(ahrs_gr_cbo)
!s1 = !tablestart+1
!s2 = !tableend
smpl !s1 !s2
ahrs_gr_avg(3,8) = @mean(ahrs_gr_cbo)
smpl @all
' end of SPECIAL


' Create each panel within the Summary table as separate table
!n = 1
for %t {%summ_list}		
	' make a list of columns for each panel
	%panel_list = ""
	for %col {%col_list}
		%panel_list = %panel_list + %t + "_" + %col + " "
	next
	group pnl{!n} {%panel_list}
	smpl !sum_tablestart !tableend ' each panel will covers same range of years (e.g. 2017-2028 for TR19)
	freeze(panel{!n}) pnl{!n}.sheet ' at this point the table has 14 rows (series names, line, and 12 yrs of data)
	!tcols = panel{!n}.@cols
	for !c=1 to !tcols
		panel{!n}(1,!c) = ""				' remove series names
		panel{!n}.setlines(2,!c) -d 		' remove double line through second row
	next
	panel{!n}(2,1) = {%t}_title 'Title of the panel
	panel{!n}.setjust(2,1) top
	panel{!n}.setfont(2) +b	' make the title text of each panel bold
	' insert rows with averages as appropriate
	if {%t}_ai<>"N" then
		{%t}_avg.copytable panel{!n} 16 1
	endif
	' insert a note at the botton of panel, as appropriate
	if {%t}_nt<>"N" then
		!note_row = panel{!n}.@rows + 1	' row where the note would be inserted = last row +1
		panel{!n}(!note_row,1) = {%t}_nt
		panel{!n}.setjust(!note_row,1) top
	endif
	
	if %t = "ahrs_gr" then		' SPECIAL FOR TR20 for avg hrs -- three lines for note. May not need for future TRs.
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt2
		panel{!n}.setjust(!note_row,1) top
		
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt3
		panel{!n}.setjust(!note_row,1) top
	endif
	
	if %t = "prod_gr" then		' special two-line note for implied productivity growth; need this every TR.
		!note_row = panel{!n}.@rows + 1	
		panel{!n}(!note_row,1) = {%t}_nt2
		panel{!n}.setjust(!note_row,1) top
	endif
	
	panel{!n}.setformat(@all) ft.{!{%t}_dc} 	' set decimal places for each panel (determined by paramaters !<ser name>_dc defined early in the program), and use comma to separate thousands
	smpl @all
	!n = !n+1
next

!npanels = !n - 1 ' number of panels in the Summary table; this number is determined by the number of componenets in the %summ_list


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
for !pg=1 to !spages
	copy annual\summary_table_p{!pg} tables\
next

' format Summary table
summary_table.insertrow(1) 4 'insert 4 rows on top of table to hold column headings
head.copytable summary_table A1 ' copy column headings into summary table
'summary_table.setformat(@all) f.2
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
		table{!t}(1,!c) = ""				' remove series names
		table{!t}.setlines(2,!c) -d 		' remove double line through second row
	next
	table{!t}.insertrow(1) 3  'insert 3 rows on top of table to hold column headings
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
	' SPECIAL FOR TR -- every TR!!!
	' create 'empty lines' every 5 years in the annual section of the table -- NOTE -- these need to be manually adjusted every year!
	table{!t}.setheight(52) 1.4
	table{!t}.setheight(57) 1.4
next

' SPECIAL FOR TR -- every TR!!
' add a few more 'empty lines' to the table that contains COLA section; it is table # !cola_t (this was determines far above in the code)
' The row numbers here will need to be adjusted every year!!!!
table{!cola_t}.setheight(69) 1.4
table{!cola_t}.setheight(74) 1.4


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
string line2 = "The file contains data for TR" + @str(!TRyr) + " (alts " + %alt_cur + ") loaded from the following databanks:"
string line3 = "TR"+@str(!TRyr)+ " alt 2 banks: " + @chr(13) + %abank_alt2
if %alt_cur <> "2" then
	string line4 = "TR"+@str(!TRyr)+ " alt 1 banks: " + @chr(13) + %abank_alt1
	string line5 = "TR"+@str(!TRyr)+ " alt 3 banks: " + @chr(13) + %abank_alt3
	else 
		string line4 = "Data for alt1 and alt3 not used in this run of the program."
		string line5 = " "
endif
string line6 = "and data for TR" + @str(!TRpr) + " loaded from"
string line7 = "TR"+@str(!TRpr)+ " alt 2 banks: " + @chr(13) + %abank_pr_alt2
string line8 = "TR"+@str(!TRpr)+ " alt 1 banks: " + @chr(13) + %abank_pr_alt1
string line9 = "TR"+@str(!TRpr)+ " alt 3 banks: " + @chr(13) + %abank_pr_alt3
string line10 = "Data from the outside forecasters is loaded from:"
string line11 = "FY"+ %FY + " budget data from " + %omb + " and " + %budget_path
string line12 = "IHS Markit data from " + %ihs_source
string line13 = "Moody's Analytics data from " + %mdy_source
string line14 = "CBO data from " + %cbo_source 
string line15 = "The final tables are in page ''tables''. "
if %sav = "Y" then
	string line16 = "The resulting tables are saved as PDF and CSV files in " + %tablespath
	else string line16 = " "
endif


_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12 line13 line14 line15 line16
'_summary.display

delete line*

if %sav = "Y" then
	' save finished tables into PDF files; scale appropriately so that things fit on a page how we intend.
	%msg = "Saving the tables to files in " + %tablespath
	logmsg {%msg}

	' long tables
	' determine which table contains COLA -- it will need a different scale factor
	!tcola = @wfind(%tables_list, "cpiw_u_gr")
	if %pdf = "Y" then
		table{!tcola}.save(t=pdf, s=75) {%tablespath}table{!tcola}.pdf		' scale table with COLA to 75%
		for !t = 1 to !ntabs
			if !t <> !tcola then
				table{!t}.save(t=pdf, s=88) {%tablespath}table{!t}.pdf			' scale all tables to 88% 
			endif
		next
		' summary tables broken into pages
		for !pg=1 to !spages
			summary_table_p{!pg}.save(t=pdf, s=85, n=) {%tablespath}summary_table_p{!pg}.pdf	' scale to 85%
		next
	endif

	
	' save finished tables into CSV files replacing NAs with '--'. The precision (full or rounded to the precision displayed in EViews) is comtrolled by option %full specified at the start of the program.
	' NOTE: table titles do not survive in CSV -- need to find a way to include them in the files!
	if %csv = "Y" then
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
			' add time stand on the last row of Summary table only to help identify numerous intermediate runs for internal discussion
			!time_row = summary_table.@rows + 1	
			%time_note = @time
			summary_table(!time_row,1) = %time_note
			summary_table.save(f, t=csv, n=--) {%tablespath}summary_table.csv	' -- this one is FULL precision
		endif		
	endif

	%wfpath=%outputpath + %thisfile + ".wf1"
	wfsave(2) %wfpath ' saves the workfile
	%msg = "Done"
	logmsg {%msg}
	logmsg
endif

%msg = "The program is finished. Make sure to save the file(s) you wish preserved."
logmsg {%msg}
logmsg

'close {%thisfile} 'close the workfile; comment this out if need to keep the workfile open


