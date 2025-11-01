' EPOXY_PROCESS_AGESEX.PRG
''	This program uses ultimate Master Earnings File (MEF) estimates from a wprkfile named like epoxy_r2023.wf1 (created with program epoxy_process_update.prg)
'     It constructs age-sex specific values for the following concepts: (1) OASDI covered workers and earnings, (2) HI covered workers and earnings, and (3) All workers and earnings.
'	Another program (esf_update.prg) constructs the ultimate age-sex specific values for the Earnings Suspense File (ESF) concepts, and the sum of these two represents all "covered" concepts.
'
'	DOCUMENTATION:  See MEF Data from EPOXYQ.doc for more information on the data developed in this program. (Still under development)
'
'	DATA INPUTS:
'      It takes the ultimate values for each concept from the latest eviews workfile:  epoxy201704.wf1
'	 It takes the age-sex specific counts from the corresponding epoxy data output:  
'      It creates age-sex specific ratios based on the counts  (a-s specific value for a year/(sum of a-s specific values for the year):
'      It multiplies the ratios by the ultimate value, then rounds to the whole person for each a-s cell.
'      It randomly assigns the residual due to rounding to cells.
	
'	CSW_M for 1951 through 1977 is from the CWHS.  
'	     CURRENTLY: Bill loads this data into an Aremos databank called mefmmyyyy.bnk.  
'	     FUTURE: Bill loads this data into an Eviews wf called cwhsdatammyyy.wf1
'
'	DATA OUTPUTS:
'	The program estimates ultimate age-sex specific values for: (1) OASDI covered earnings and its components; (2) HI covered earnings and its components; and (3) No HI wages. 
'     It creates a-s specific groups for the purposes of easily comparing one year to the next.  
'
'    COVERAGE NOTES:
'      CE_M1 - The OASDI program began in 1937 and coverage has changed over time.   For example,
'         1) SE coverage began in 1951

'         2) Starting in January 1984, all newly hired federal civilian government employees were covered under OASDI.
            
'            Starting in January 1984, all employees of nonprofit organizations were covered under OASDI.
'           (Note that it is unclear who these people are.)

'         3) Effective July 2, 1991, all State and local civilian employees who's jobs were previously not covered under
'            a Section 218 aggreement and who were not covered under a S&L pension plan were covered under OASDHI.

'      HE_M1 - The HI program began in 1966 and coverage has changed over time. For example,

'         A) 1966 to 1982   - Values for HE_M1 and CE_M1 are identical because the OASDI and HI programs covered the same people
'         B) 1983 and later - Values for HE_M1 are greater than CE_M1 because HI covered some people not covered under OASDI

'         1) Starting in January 1983, all Federal civilian employees were covered under HI. (Starting in January 1984,
'               all newly hired federal civilian government employees were covered under OASDI.)

'         2) Starting in April 1986, all newly hired State and local civilian employees who were not covered under OASDI 
'            were covered under HI.(Effective July 2, 1991, all State and local civilian employees who's jobs were
'            previously not covered under a Section 218 aggreement and who were not covered under a S&L pension plan were
'            covered under OASDHI.)

'         In theory, the difference (in theory) between HE_M1 and CE_M1 should be 0.0 for those age 15 and under.
'         That is, we believe that the "HI Only" (i.e., CSRS and some S&L govt. workers) are all over the age of 15.

'      TE_M1 

'         In 1978, the SSA switched from posting worker's taxable wages from quarterly reported Forms 941 to annually reported
'         Forms W-2. At this time, the SSA began to post all workers wages to the MEF including workers with no OASDI or HI
'         taxable wages. However data for the earlier years (e.g., 1978 to 1988) are highly suspect.

'         To be included in the 1.0% CWHS, a worker must have had some OASDI taxable earnings at some point in their 
'         earnings history. Thus, the count of workers with no OASDI taxable earnings from the 1.0% CWHS is biased downward
'         because it does not include any workers who have no OASDI taxable earnings over their career.

'         Starting in January 1984, all employees of nonprofit organizations were covered under OASDI.
'         (Note that it is unclear who these people are.)
'
'     Bob Weathers, 7-17-2017
'        Updated to include all annual changes to the program as strings below, 8-3-2017
'        Updated to read in 100% MEF raw age-sex specific values generated for the EPOXY reports 
'
'	Polina Vlasenko 11-13-2018
'		Updated all input files to the latest needed for TR2019.
'		Added code that creates a spool with text describing the current run of the program -- useful when keeping track of various versions
'		Added log messages and runtime statistic to see how long it takes to run.


'  STEP 1: Identify parameters used in this program:

'************** UPDATE these entries every time before running the program
	%userid = @env("username")

	!dataend = 2022 	 																			' Update this to the last calendar year of **data** in the epoxy file given in %workfile_src 
	!projend = 2105 																					' Update this to the last calendar year of the **projection** period (this changes once in 5 years, not every TR)
	%tr= "25"																								' Trustees Report Release Year
	%workfile_src = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\epoxy_r2023.wf1"			' workfile that contains the new estimated Ultimates from Epoxy	
	%govtsect_src= "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\govtsector\govtsector202410.WF1"	' workfile that contains the new govtsector ultimates from CWHS
	%epoxy_agesex = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Raw\AnnualWageReporting\EPOXY\agesex\data\AGESEX.R240928"	' txt file that contains Age-Sex Specific values from Epoxy (usually use the latest available)
	%studentspath = "S:\LRECON\Data\Processed\US_Dept_of_Ed\Estimate_of_age-sex_employed_at_public_and_private_schools.xls"		' file with data on students; 
																																											' NOTE 10-11-21: this file has not been updated fpr several years. Should it be updated in some way?
	%rrb_data = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Raw\RRB\RRB employment - 20241008.xlsx"				' Excel file with RRB data
	%rrb_sheet = "ToMEF"																														' name of the sheet within the %rrb_data file that contains tables with data by age-sex group.
	%bkdr1 = "C:\Users\"+%userid+"\GitRepos\econ-budget\dat\bkdr1.wf1" 									' Update this to the locatipon of BKDR1 databank		
	%esf_src = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\ESF\TR2025\esf_rpt_2024.wf1" 					' Update to the location of the ESF workfile created by esf_update.prg
	%abank = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul\atr242.wf1"			'  a-bank (previous TR) to obtain private HH data (te_ph_m) data
	%afile = @left(@right(%abank, 10), 6)																									' short name of the file, i.e. atr222
	%op_bank = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\dat\op1242o.wf1"			' op-bank (previous TR) to get population data from.
	%opfile = @left(@right(%op_bank, 11), 7)																							' short name of the file, i.e. op1222o
	
	%output_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\" 					' Location to save the output file created by this program
	%sav = "Y" 																								' enter Y or N (case sensitive); indicates whether you want the workfile saved
	
	' Specify which part of the program should be run.
	' The program contains 10 steps. Steps 1 and 2 are mandatory -- they craete the workfile and load data.
	' For all other steps (3 though 10): 
	' If a step is to be run, set value to 1, if not -- set value to zero.
	!step3 = 1	'0 if skip		'	STEP 3: Control Age-Sex Specific Values to Estimated Final Totals
	!step4 = 1	'0 if skip		'	STEP 4: COMPUTE HI-ONLY AGE-SEX SPECIFIC VALUES. 
	!step5 = 1	'0 if skip		'	Step 5 -- State and local gov workers (including students and election workers)
	!step6 = 1	'0 if skip		'	Step 6 -- TE_PH_M - Workers in Private Households
	!step7 = 1	'0 if skip		' 	Step 7: RRB data
	!step8 = 1	'0 if skip		' 	STEP 8: Compute RRO
	!step9 = 1	'0 if skip		' 	'Step 9: LPR on ESF Only (TEL_SO) 
	!step10 = 1	'0 if skip		' 	STEP 10: Include Remaining Variables in MEF_finals
	
' NOTE:   there are many instances in this code when we compute ratios of series AND for some years those series are zero.
' 			To be able to run the program and avoid error messages, CHANGE EVIEWS SETTINGS prior to running this program, as follows
'			Options -> General Options... -> Advanced System Options -> make sure "Permissive error handling" box is checked

'************ END of the update section

'******** Define global variables and parameters:
	%workfile2 = "MEF_TR" + %tr																					'The name of the output workfile created by this program.
	'These are age and sex strings needed in the program, they do not change from year to year (but may change if a decision is made to change the concepts):
 		'Male and Female sex categories:
 		%sex = "m f"
		'OASDI covered worker groups:
		%cgroups="ce cew ces cesw ceso cewo"
		'HI covered worker groups:
     		%hgroups="he hew hes hesw heso hewo he_eo he_wo he_wos"
		'SYA groups:
		%age= "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 " + _
				"70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110"	

	'The MEF concept labels and age grouping intervals:
		 ' Lowest and highest ages within each grouping:
		   	%lo = " 0 0 5 10 16 18 16 20 25 30 35 40 45 50 55 60 60 62 65 70 75 80 85 90 95 16 65 70 75 80 85" 
	  		%hi = "15 4 9 14 17 19 19 24 29 34 39 44 49 54 59 64 61 64 69 74 79 84 89 94 99 100 100 100 100 100 100"	
	  	' Number of age groupings:
			!anum = @wcount(%lo)
			
'******* End of global parameters

logmode l
%msg = "Running epoxy_agesex_new.prg" 
logmsg {%msg}
logmsg

tic

' STEP 2: Read in data from age sex text file and from the workfile that contains the estimate ultimate values for the aggregates MEF concepts.

%msg = "Step 2 -- Loading agesex data from " + %epoxy_agesex
logmsg {%msg}

	'2a: Read in raw Age-Sex data from most recent Epoxy Run.

'	open(type=raw,page=rawdata) %epoxy_agesex  ftype=ascii rectype=crlf rformat="taxy 1-4 sex 5-7 age 8-10 WorkersOASDItwages 11-19 OASDItwages 20-36 WorkersHItwages 37-45 HItwages 46-62 WorkersOASDItSE 63-71 	OASDItSE 72-86 HItSE 87-101 WorkersHIonlytSE 102-110 HIonlytSE 111-125 WorkersOASDItearn 126-134 OASDItearn 135-151 WorkersHItearn 152-160 HItearn 161-177 WorkerswithComp 178-186 TotComp 187-203 	DefCompcontr 204-218 DefCompDist 219-231" colhead=0 eoltype=pad badfield=NA @smpl @all  ------- These definitions were used untill the end of 2017

	open(type=raw,page=rawdata) %epoxy_agesex  ftype=ascii rectype=crlf rformat="taxy 1-4 sex 5-7 age 8-10 WorkersOASDItwages 11-19 OASDItwages 20-36 OASDItwages_undrTMAX 37-53 WorkersHItwages 54-62 HItwages 63-79 WorkersOASDItSE 80-88 OASDItSE 89-103 OASDItSE_undrTMAX 104-118 HItSE 119-133 WorkersHIonlytSE 134-142 HIonlytSE 143-157 WorkersOASDItearn 158-166 OASDItearn 167-183 OASDItearn_undrTMAX 184-200 WorkersHItearn 201-209 HItearn 210-226 WorkerswithComp 227-235 TotComp 236-252 DefCompcontr 253-267 DefCompDist 268-280" colhead=0 eoltype=pad badfield=NA @smpl @all  'new definitions starting in 2018
	pagecreate(page=CE_RAW) a 1951 !dataend
	pagecreate(page=est_finals) a 1951 !dataend
   pagecreate(page=govtsector) a 1983 !dataend
	pagecreate(page=bkdr1) a 1951 !projend
	pagecreate(page=students) a 1951 !projend
	pagecreate(page=privatehh) a 1951 !projend
	pagecreate(page=RRB) a 1951 !projend
	pagecreate(page=esf) a 1951 !projend
	pagecreate(page=MEF_finals) a 1951 !projend
	wfsave %workfile2 

' Create a summary note with the list of the files used in this run -- simplifies keeping track of different versions.
pageselect MEF_finals
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " using the following input files:"
string line2 = "Epoxy aggregate data from " + %workfile_src
string line3 = "Gov sector data from " + %govtsect_src
string line4 = "Age-sex data from " + %epoxy_agesex
string line5 = "BKDR1 data from " + %bkdr1
string line6 = "ESF data from " + %esf_src
string line7 = "Student data from " + %studentspath
string line8 = "Private HH data from " + %abank
string line9 = "RRB data from " + %rrb_data
string line10 = "OP data from " + %op_bank
string line11 = "The last year of data is " + @str(!dataend)
if !step10=1 then
	string line12 = "This is a complete run of the program; all 10 steps have been run."
endif
if !step10=0 then
	string line_p = "This is a PARTIAL run of the program. Only the following steps were run: step1, step2, "
	for %s step3 step4 step5 step6 step7 step8 step9 step10
		if !{%s} = 1 then 
			line_p = line_p + %s + ", "
		endif
	next
	string line12 = line_p
endif

if %sav = "Y" then
	string line13 = "The resulting output file, " + %workfile2 + ", is saved in " + %output_path
else if %sav = "N" then
	string line13 = "The workfile has NOT been saved!!! Save manually if desired"
	endif
endif 

_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12 line13
_summary.display

delete line*
' end of summary note

	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
	for !s= 1 to 2
		 for !a=0 to 110
			if !s=1 then 
				%s="m"
     			endif
			if !s=2 then 
				%s="f"
			endif
			pageselect rawdata
			pagecopy(smpl=if sex=!s and age=!a) taxy WorkersOASDItwages WorkersOASDItSE WorkersOASDItearn WorkersHIonlytSE WorkersHItearn WorkersHItwages 
			genr hs_100_{%s}_{!a}=WorkersHIonlytSE+WorkersOASDItSE
			rename WorkersOASDItwages cw_100_{%s}_{!a}
                rename WorkersOASDItSE cs_100_{%s}_{!a}
		     rename WorkersOASDItearn ce_100_{%s}_{!a}
			rename WorkersHItwages hw_100_{%s}_{!a}
                rename WorkersHItearn he_100_{%s}_{!a}		          
			copy untitled\* CE_RAW\*
			pagedelete untitled
  		next
	next

	'2b: Read in the estimated ultimate totals for each concept from the EPOXY tables that is contained in the epoxy finals workfile.
	wfopen %workfile_src
	copy {%workfile_src}::est_finals\* {%workfile2}::est_finals\*
	wfclose %workfile_src
	pageselect est_finals
	delete _summary		' removes old _summary spool copied from epoxy workfile
	rename mqge he_wo_m 
	rename mqge_wose he_eo_m
	rename mqge_wse he_wos_m
	

	'2c: Read in the estimated ultimate govtsector totals
	%msg = "Loading govsector data from " + %govtsect_src
	logmsg {%msg}
	
	wfopen %govtsect_src
	copy {%govtsect_src}::govtsectormef\* {%workfile2}::govtsector\*
	wfclose %govtsect_src

	for %j tefc_n_n tesl_n_n_hi
		copy {%workfile2}::govtsector\{%j} {%workfile2}::MEF_finals\
	next
	pageselect MEF_finals
	genr he_wof_m=tefc_n_n
	genr he_wol_m=tesl_n_n_hi

     '2d: Read in age-sex specific CSRS data from bkdr1	
   %msg = "Loading age-sex specific CSRS data from bkdr1."
	logmsg {%msg}

	pageselect bkdr1
	smpl @all
	wfopen %bkdr1
	for %ser csrsm csrsf csrs
		copy bkdr1::a\{%ser} {%workfile2}::bkdr1\*
	next
	copy bkdr1::a\csrs??? {%workfile2}::bkdr1\csrs???
	wfclose bkdr1
	
	wfselect {%workfile2}
	pageselect bkdr1
	smpl @all
	copy {%workfile2}::MEF_Finals\he_wof_m {%workfile2}::bkdr1\
     
     	'2e: Read in Student Data
     	%msg = "Loading student data from " + %studentspath
	logmsg {%msg}
	
	pageselect students
	import(page=students) %studentspath range="Export"!$B$11:$X$22 byrow namepos=discard na="#N/A" @freq a 1988 @smpl @all
	smpl 1988 2010
	%rne = "rnf1819e rnf2021e rnf2224e rnf2529e rnf3034e rnm1819e rnm2021e rnm2224e rnm2529e rnm3034e rn1834e_p rn1624e_e"
	rename  series01 rnf1819e
	rename  series02 rnf2021e
	rename  series03 rnf2224e
	rename  series04 rnf2529e
	rename  series05 rnf3034e

	rename  series06 rnm1819e
	rename  series07 rnm2021e
	rename  series08 rnm2224e
	rename  series09 rnm2529e
	rename  series10 rnm3034e

	rename  series11 rn1834e_p
	rename  series12 rn1624e_e
	smpl 1951 !projend
	
	'2f: Read in Data needed for Private HHs.
	%msg = "Loading private HH data from " + %abank
	logmsg {%msg}
	
	pageselect govtsector
		smpl 1978 !dataend
		wfopen %abank
		copy {%afile}::a\te_ph_m {%workfile2}::govtsector\*
		wfclose {%afile}
 		
 		wfopen %bkdr1
		for %ser em1819nawph em2024nawph em2534nawph em3544nawph em4554nawph em5559nawph em6064nawph em5564nawph em65onawph em6569nawph em7074nawph em75onawph
			copy bkdr1::a\{%ser} {%workfile2}::govtsector\*
		next
		for %ser ef1819nawph ef2024nawph ef2534nawph ef3544nawph ef4554nawph ef5559nawph ef6064nawph ef5564nawph ef65onawph ef6569nawph ef7074nawph ef75onawph
			copy bkdr1::a\{%ser} {%workfile2}::govtsector\*
		next
		wfclose bkdr1
     
	'2g: Read in OP data into RRB
	wfselect {%workfile2}
	pageselect RRB
	smpl @all
	wfopen %op_bank
		for %ser nf1819 nf2024 nf2529 nf3034 nf3539 nf4044 nf4549 nf5054 nf5559 nf6064 nf6569 nf7074 nm1819 nm2024 nm2529 nm3034 nm3539 nm4044 nm4549 nm5054 nm5559 nm6064 nm6569 nm7074
			copy {%opfile}::a\{%ser} {%workfile2}::RRB\*
		next
		copy {%opfile}::a\nf?? {%workfile2}::RRB\nf??
		copy {%opfile}::a\nm?? {%workfile2}::RRB\nm??
	wfclose {%opfile}
		
'	STEP 3: Control Age-Sex Specific Values to Estimated Final Totals
'	Construct WS only, SE only, and combination workers.  We use the a-s data associated with Table 7A C1 of the Epoxy reports that contains the number of workers with wages posted to the MEF, 
'																			    Table 7B C1 on the number of workers with SE posted to the MEF, and Table 7C C1 on the number with Wages and/or SE posted to the MEF.
'																			    Note that 7A C1 + 7B C1 > 7C C1, because workers can show up in both 7A C1 and 7B C1 (those who have both wages and se income).  
'																			    They are double counted in 7A C1 + 7B C1, but not in Table 7C C1.   The difference between (7A C1 + 7B C1) minus 7C C1 are the combination workers.
'																			    We begin by identifying combination workers as 7A C1 + 7B C1 - 7C C1 for each a-s group, then using that to idenfity wage and salary only workers, and 
'																			    then SE only workers.  We construct ratio of each a-s specific number to the total number within that specific worker category.  Finally we multiply the ratio by
'																			    the ultimate rate to obtain a-s specific numbers that add up to our ultimate numbers constructed from the EPOXY.  
'																			   The ultimate numbers are larger than the reported numbers because of delays in reporting.
' 	Construct age-sex "rates" from 100 percent data or 1 percent CWHS data, select one;

if !step3 = 1 then
	
	%msg = "Step 3 -- Generating age-sex series (SYOA and groups) from aggregate ones..."
	logmsg {%msg}

	'3a. Load in HI and OASDI Covered A-S numbers
	wfselect {%workfile2}
	pageselect CE_RAW
	smpl @all
		for %s {%sex}
   			for %a {%age}
				'    	Any OASDI combined SE income and wage &salary workers:
  				genr csw_100_{%s}_{%a} = cw_100_{%s}_{%a} + cs_100_{%s}_{%a} - ce_100_{%s}_{%a}
				' 	Any OASDI covered se income only:
				genr cso_100_{%s}_{%a} = cs_100_{%s}_{%a} - csw_100_{%s}_{%a} 
				'	Any OASDI covered wages only:
				genr cwo_100_{%s}_{%a} = cw_100_{%s}_{%a} - csw_100_{%s}_{%a}  

				smpl 1978 !dataend
				'  Any HI combined SE and Wage and salary
	          		genr hsw_100_{%s}_{%a} = hw_100_{%s}_{%a} + hs_100_{%s}_{%a} - he_100_{%s}_{%a}
				' HI covered se income only:
				genr hso_100_{%s}_{%a} = hs_100_{%s}_{%a} - hsw_100_{%s}_{%a} 
				'HI covered wages only: 
				genr hwo_100_{%s}_{%a} = hw_100_{%s}_{%a} - hsw_100_{%s}_{%a}  

				'MQGE wages only
				genr he_eo_{%s}_{%a}=he_100_{%s}_{%a}-ce_100_{%s}_{%a}			
			
				'MQGE wages and se
				genr he_wos_{%s}_{%a}=hw_100_{%s}_{%a}-cw_100_{%s}_{%a}-he_eo_{%s}_{%a}

		     		smpl 1951 !dataend
   			next
		next	

	'3b. Create groups for each relevant age-sex.  Can choose ages to  drop here. The * is used to grab all variables that begin with "csw_100_m_"
	'The groups are a simple way of identifying the variables that must be summed @rsum to construct the denominator.

	group gcsw 	csw_100_m_* csw_100_f_*
    	group gcwo 	cwo_100_m_* cwo_100_f_*
     	group gcso 	cso_100_m_* cso_100_f_*

	smpl 1978 !dataend
	group ghsw 	hsw_100_m_* hsw_100_f_*
    	group ghwo 	hwo_100_m_* hwo_100_f_*
     	group ghso 	hso_100_m_* hso_100_f_*
 
	smpl 1984 !dataend
	group ghe_eo		he_eo_m_* he_eo_f_*
     group ghe_wos 	he_wos_m_* he_wos_f_*
     
	smpl 1951 !dataend
	for %s {%sex}
   		for %a {%age}
			'    	Any OASDI covered wage and salary workers:
  			genr cworate_100_{%s}_{%a} = cwo_100_{%s}_{%a}/@rsum(gcwo)
			' 	Any OASDI covered se:
			genr csorate_100_{%s}_{%a} = cso_100_{%s}_{%a}/@rsum(gcso)
			'	Any OASDI covered employment:
			genr cswrate_100_{%s}_{%a} = csw_100_{%s}_{%a}/@rsum(gcsw)
			
			smpl 1978 !dataend
			'    	Any HI covered wage and salary workers:
  			genr hworate_100_{%s}_{%a} = hwo_100_{%s}_{%a}/@rsum(ghwo)
			' 	Any HI covered se:
			genr hsorate_100_{%s}_{%a} = hso_100_{%s}_{%a}/@rsum(ghso)
			'	Any HI covered employment:
			genr hswrate_100_{%s}_{%a} = hsw_100_{%s}_{%a}/@rsum(ghsw)

			smpl 1983 !dataend
			'	HI-only wages only
			genr heorate_100_{%s}_{%a} = he_eo_{%s}_{%a}/@rsum(ghe_eo)

			'    HI-only wages and SE income
			genr hwosrate_100_{%s}_{%a} = he_wos_{%s}_{%a}/@rsum(ghe_wos)

		     smpl 1951 !dataend
   		next
	next

	'3c.  Use rates multiplied by ultimate value to construct historical age-sex specific ultimate values:

	pageselect MEF_finals

  	for %s {%sex}
   		for %a {%age}
			'    	Any OASDI covered wage and salary workers:
  			genr cewo_m_{%s}{%a} = CE_RAW\cworate_100_{%s}_{%a}*est_finals\cewo_m
			' 	Any OASDI covered se:
			genr ceso_m_{%s}{%a} = CE_RAW\csorate_100_{%s}_{%a}*est_finals\ceso_m
			'    	OASDI covered wage and salary workers only:
  			genr cesw_m_{%s}{%a} = CE_RAW\cswrate_100_{%s}_{%a}*est_finals\cesw_m

			smpl 1978 !dataend
			'    	Any HI covered wage and salary workers:
  			genr hewo_m_{%s}{%a} = CE_RAW\hworate_100_{%s}_{%a}*est_finals\hewo_m
			' 	Any OASDI covered se:
			genr heso_m_{%s}{%a} = CE_RAW\hsorate_100_{%s}_{%a}*est_finals\heso_m
			'    	OASDI covered wage and salary workers only:
  			genr hesw_m_{%s}{%a} = CE_RAW\hswrate_100_{%s}_{%a}*est_finals\hesw_m

			smpl 1983 !dataend
			'    HI-only wages only
			genr he_eo_m_{%s}{%a}=CE_RAW\heorate_100_{%s}_{%a}*est_finals\he_eo_m
		
			'   HI-only wages and se
			genr he_wos_m_{%s}{%a}=CE_RAW\hwosrate_100_{%s}_{%a}*est_finals\he_wos_m

		     smpl 1951 !dataend
   		next
	next

	'3d. Compute sum to get wage workers, se workers, and wage and/or se workers:
	for %s {%sex}
   		for %a {%age}

			'    	OASDI wage workers :
  			genr cew_m_{%s}{%a} = cewo_m_{%s}{%a} + cesw_m_{%s}{%a}  
   			'    	OASDI se workers :
  			genr ces_m_{%s}{%a} = ceso_m_{%s}{%a} + cesw_m_{%s}{%a}
			'	OASDI any wage and/or se workers (se only + any wage):
   			genr ce_m_{%s}{%a} = ceso_m_{%s}{%a} + cew_m_{%s}{%a}
			
			smpl 1978 !dataend
			'    	HI wage workers :
  			genr hew_m_{%s}{%a} = hewo_m_{%s}{%a} + hesw_m_{%s}{%a}  
   			'    	HI se workers :
  			genr hes_m_{%s}{%a} = heso_m_{%s}{%a} + hesw_m_{%s}{%a}
			'	HI any wage and/or se workers (se only + any wage):
   			genr he_m_{%s}{%a} = heso_m_{%s}{%a} + hew_m_{%s}{%a}

			smpl 1983 !dataend
			'  HI-only any wages 
			genr he_wo_m_{%s}{%a} = he_eo_m_{%s}{%a} + he_wos_m_{%s}{%a}

		     smpl 1951 !dataend
   		next
	next

	'3e. Convert ages over 100 to 100o.
	for %c {%cgroups} {%hgroups}       ' loops over each MEF concept
   		for %s m f                      ' loops over each sex    
      	genr {%c}_m_{%s}100o= 0  ' initialize series for each grouping
      		for !n = 100 to 110          ' loops over each age grouping
			genr	{%c}_m_{%s}100o = {%c}_m_{%s}{!n} + {%c}_m_{%s}100o
        		next
      	next
  	 next
	
	'3f. delete series contained in the 100o group
	for %c {%cgroups} {%hgroups}       ' loops over each MEF concept
   		for %s m f            	
			for %a 100 101 102 103 104 105 106 107 108 109 110
				delete {%c}_m_{%s}{%a} 
			next
            next
      next


	'3h. Construct  aggregate Age groups
	copy %workfile2::est_finals\* %workfile2::MEF_finals\*    'we just copied ALL series in the est_finals into MEF_finals. WHY? if we need them there, why didn't we put them there in the first place?

'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).   
	' Construct each mef concept-sex-age grouping:
	for %c {%cgroups} {%hgroups}       ' loops over each MEF concept
	   for %s m f                      ' loops over each sex    
     	 	for !n = 1 to !anum          ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))  	'content of %lo string is defined above in global parameters
         		!hiAge  = @val(@word(%hi,!n))	'content of %hi string is defined above in global parameters
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 5 to 9
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

	     		if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif

       		if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif

			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif

			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif

			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            		else
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' when we get to age 100, add series "100 and over" (called 100o in mef databank)
            		endif
      	   	next
      	next
   	  next
	next

	%msg = "Done."
	logmsg {%msg}
endif

'STEP 4: COMPUTE HI-ONLY AGE-SEX SPECIFIC VALUES. 

if !step4=1 then
	
	%msg = "Step 4 -- Compute HI-only series."
	logmsg {%msg}
	
	pageselect bkdr1
	smpl 1951 !projend		'here we are creating the series not only for the past (data) but also the future (projections). Is this because these are "closed groups" and we do not expect any additions to them?

	'4a. Initialize values
  	for %g he_wof_m_ he_wol_m_ he_wor_m_ he_wosf_m_ he_wosl_m_ he_wosr_m_
     		for %s {%sex}
       		for %a {%age}
         			series {%g}{%s}{%a}=0
       		next
	  		series {%g}{%s}100o=0	
     		next
   	next

	'4b. Federal Civilian A-S Specific
	smpl 1983 1985
	for %s m f
   		for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
  			genr he_wof_m_{%s}{%a}=MEF_Finals\he_wo_m_{%s}{%a}
          next
     next

	pageselect bkdr1
	smpl !dataend !dataend
 	genr csrswt = he_wof_m/csrs

	smpl !dataend+1 !projend 
 	genr csrswt=csrswt(-1)
 	genr he_wof_m=csrs*csrswt

	smpl 1986 !projend
  	for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 
    		for %s m f
      		genr he_wof_m_{%s}{%a}=0
    		next
    		genr he_wof_m_{%s}100o=0
    		genr he_wol_m_{%s}100o=0
    		genr he_wor_m_{%s}100o=0
  	next

  	for %a 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 
    		for %s m f
         		smpl if csrs>0	' at sone point (in 2039 and later) csrs =0, and it gives error in the formula below
         		genr he_wof_m_{%s}{%a}=he_wof_m*(csrs{%s}{%a}/csrs)
         		smpl if csrs=0
         		genr he_wof_m_{%s}{%a}=0
         		smpl 1986 !projend
    		next
  	next

	'4c: State and local govt age-sex specific values.
	' Different sample periods below reflect the changes in law that affected who is covered
	smpl 1983 1990
	for %a  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
   		for %s m f
         		genr he_wol_m_{%s}{%a}=MEF_Finals\he_wo_m_{%s}{%a} - he_wof_m_{%s}{%a}
    		next
   		genr he_wol_m_{%s}100o=MEF_Finals\he_wo_m_{%s}100o
  	next

	smpl 1991 1994 
	for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 
	for %s m f
         		genr he_wol_m_{%s}{%a}=MEF_Finals\he_wo_m_{%s}{%a} - he_wof_m_{%s}{%a}
    		next
   		genr he_wol_m_{%s}100o=MEF_Finals\he_wo_m_{%s}100o
  	next

	smpl 1995 !dataend
  	for %a  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
   		for %s m f
         		genr he_wol_m_{%s}{%a}=MEF_Finals\he_wo_m_{%s}{%a} - he_wof_m_{%s}{%a}
    		next
   		genr he_wol_m_{%s}100o=MEF_Finals\he_wo_m_{%s}100o
  	next

	smpl 1983 !projend
  	for %a  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100
   		for %s m f
         		genr he_wor_m_{%s}{%a}=0
    		next
		genr he_wor_m_{%s}100o=0
  	next

	' 4d) Decomposition of HE_WOS_M
	'      1) Federal Civilian (HE_WOSF_M)
	'      2) State and Local  (HE_WOSL_M)
	'      3) Residual         (HE_WOSR_M)

	' 4d1) Definitions
	'      MNEMONIC - Definition in ABANK                               MNEMONIC in MEF Bank
	'      TEFC_N_N_SE    - Total FC wage workers with                      HE_WOSF_M 
	'                       1) no OASDI covered wages in their FC job
	'                       2) no OASDI covered wages in any other job
	'                       3) with OASDI SENE
	'      TESL_N_N_HI_SE - Total SL wage workers with                      HE_WOSL_M 
	'                       1) no OASDI covered wages in their SL job
	'                       2) no OASDI covered wages in any other job
	'                       3) with OASDI SENE
	'      WSW_HIO_OTH_SE - Total Other (Residual) wage workes with         HE_WOSR_M

	' 4d2) Age-Sex Distribution of HE_WOSF_M, HE_WOSL_M, and HE_WOSR_M
	'      1) I have the age-sex distribution of HE_WO_M and HE_WOS_M.
	'         Therefore, I have the ratio of HE_WOS_M to HE_WO_M by age-sex
	'      2) I assume that the age-sex ratios in (1) are the same as the age-sex ratios for
	'         each component (i.e., HE_WOSF_M, HE_WOSL_M, and HE_WOSR_M)

	smpl 1983 1985
	series he_wosf_m = (MEF_Finals\he_wos_m) / (MEF_Finals\he_wo_m) * he_wof_m
	series he_wosl_m = 0
	series he_wosr_m = 0

'	smpl 1986 !dataend
'	series he_wosf_m = (MEF_Finals\he_wos_m) / (MEF_Finals\he_wo_m) * (MEF_Finals\he_wof_m)
'	series he_wosl_m = (MEF_Finals\he_wos_m) / (MEF_Finals\he_wo_m) * (MEF_Finals\he_wol_m)
'	series he_wosr_m = 0


	smpl 1983 !dataend
	for %s m f 
  		for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99	      
     		series he_wosf_m_{%s}{%a} =  @recode(MEF_Finals\he_wos_m_{%s}{%a}=0,0,((MEF_Finals\he_wos_m_{%s}{%a}) / (MEF_Finals\he_wo_m_{%s}{%a}))  * he_wof_m_{%s}{%a})
         	series he_wosl_m_{%s}{%a} =  @recode(MEF_Finals\he_wos_m_{%s}{%a}=0,0,((MEF_Finals\he_wos_m_{%s}{%a}) / (MEF_Finals\he_wo_m_{%s}{%a}))  * he_wol_m_{%s}{%a})
        	series he_wosr_m_{%s}{%a} = 0
           next
   		series   he_wosf_m_{%s}100o = 0
   		series   he_wosl_m_{%s}100o = 0
   		series   he_wosr_m_{%s}100o = 0
	next    
  
'     1) Because I have values to 2099 for the age-sex distribution of HE_WOF_M (but not for HE_WOL_M and HE_WOR_M),
'     	I calculate values for endyr+1 to 2099 for HE_WOSF_M.

	smpl !dataend+1 !projend
	series   he_wosf_m =  (@elem((MEF_Finals\he_wos_m),!dataend)) / (@elem((MEF_Finals\he_wo_m),!dataend))  *   he_wof_m
	for %s m f
  		for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 
         		series   he_wosf_m_{%s}{%a} =  (@elem((MEF_Finals\he_wos_m_{%s}{%a}),!dataend)) / (@elem((MEF_Finals\he_wo_m_{%s}{%a}),!dataend))  *   he_wof_m_{%s}{%a}
     		next
		series   he_wosf_m_{%s}100o = 0
		series  he_wosl_m_{%s}100o=0
		series  he_wosr_m_{%s}100o=0
	next 


	smpl 2039 !projend
  	for %g he_wof_m_ he_wol_m_ he_wor_m_ he_wosf_m_ he_wosl_m_ he_wosr_m_
     		for %s {%sex}
       		for %a {%age}
         			series {%g}{%s}{%a}=0
       		next
		next
   	next
	
	'Manually correct issue with he_wo_m_m98 and he_wo_m_m99 being equal to zero.
	smpl 2016 2038
	series he_wosf_m_m98=0
	series he_wosf_m_m99=0


	'	4e: Construct Aggregate A-S groups for each concept
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).   
	
	smpl 1951 !projend
		' Construct each mef concept-sex-age grouping:
		for %c he_wof he_wol he_wor he_wosf he_wosl he_wosr           ' loops over each MEF concept
	   		for %s m f                      ' loops over each sex    
     	 			for !n = 1 to !anum          ' loops over each age grouping
         				!loAge = @val(@word(%lo,!n))		'content of %lo string is defined above in global parameters
         				!hiAge  = @val(@word(%hi,!n))		'content of %hi string is defined above in global parameters
	         			' Create age grouping label
		     			%ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           		if (!loAge = 0 and !hiAge <> 4) then
           			%ag = @str(!hiAge) + "u"       ' 15u
         			endif

  	         		if (!loAge = 0 and !hiAge = 4) then
           			%ag = @str(!loAge) + "t4"       ' 0 to 4
         			endif

	         		if (!loAge = 5 and !hiAge = 9) then
           			%ag = @str(!loAge) + "t9"       ' 5 to 9
         			endif

       			if (!hiAge = 100 and !loAge=16) then
           			%ag = @str(!loAge) + "o"       ' 16o
         			endif
     			
				if (!hiAge = 100 and !loAge=65) then
           			%ag = @str(!loAge) + "o"       ' 65o
         			endif

	     			if (!hiAge = 100 and !loAge=70) then
           			%ag = @str(!loAge) + "o"       ' 70o
         			endif

				if (!hiAge = 100 and !loAge=75) then
           			%ag = @str(!loAge) + "o"       ' 75o
         			endif

				if (!hiAge = 100 and !loAge=80) then
           			%ag = @str(!loAge) + "o"       ' 80o
         			endif

				if (!hiAge = 100 and !loAge=85) then
           			%ag = @str(!loAge) + "o"       ' 85o
         			endif

         			genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         			for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            			if (!a <> 100) then
               				{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            			else
               				{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' when we get to age 100, add series "100 and over" (called 100o in mef databank)
            			endif
      	   		next
      		next
   	  	next
	next

'Need to redefine the aggregate:
	'series he_wol_m=he_wol_m_f15u+he_wol_m_f16o+he_wol_m_m15u+he_wol_m_m16o
	series he_wosf_m=he_wosf_m_f16o+he_wosf_m_m16o
	series he_wosl_m=he_wosl_m_f15u+he_wosl_m_f16o+he_wosl_m_m15u+he_wosl_m_m16o

copy bkdr1\he_* MEF_finals\

endif


if !step5=1 then
	
	%msg = "Step 5 -- State and local gov workers (including students and election workers)."
	logmsg {%msg}

'    5a) TE_SLOO_M - Total SL wage workers (non-students and non-elect wrkrs.) with 
'                       1) no OASDI covered wages in their SL job
'                       2) no OASDI covered wages in any other job
'                       3) no    HI covered wages in their SL job
'                       4) no       covered SENE

'         (Note: This is the 'Closed Group' from April 1986, but with no SENE)
'         1983-1986 - I assume that the age-sex distribution for TESL_N_N_NHI_NS for 1983-1986 is the same as the age-sex
'                     distribution for HE_WOF_M in 1983.
'                     Level for TE_SLOO = TESL_N_N_NHI_NS * (1- he_wosf_m[83A1]/he_wof_m[83A1]);
'         1987-2013 - I assume that the age-sex distribution for TESL_N_N_NHI_NS in year (t)is the same as the age-sex
'                     distribution for HE_WOF_M in year (t-3).
'                     Level for TE_SLOO = TESL_N_N_NHI_NS * (1- he_wosf_m[t-3]/he_wof_m[t-3]);
'         2014-2099 - I assume that the age-sex distribution for TESL_N_N_NHI_NS in year (t)is the same as the age-sex
'                     distribution for HE_WOF_M in year (t-3).
'                     Level for TE_SLOO = TE_SLOO.1  * he_wof_m[t-3] / he_wof_m[t-4];

	copy govtsector\TESL_N_N_NHI_NS bkdr1\

	smpl 1983 1986
	series te_sloo_m = (TESL_N_N_NHI_NS) * (1- (@elem(he_wosf_m,1983)/@elem(he_wof_m,1983)))

	smpl 1987 !dataend
	series te_sloo_m = (TESL_N_N_NHI_NS) * (1- (he_wosf_m(-3)/he_wof_m(-3)))

	smpl !dataend+1 !projend
	series te_sloo_m       = te_sloo_m(-1) * he_wof_m(-3) / he_wof_m(-4)
	series tesl_n_n_nhi_ns = tesl_n_n_nhi_ns(-1) * he_wof_m(-3) / he_wof_m(-4)


	smpl 1983 1986
	for %s m f 
  		for %a  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
      		series te_sloo_m_{%s}{%a} = ((@elem(he_wosf_m_{%s}{%a},1983))/(@elem(he_wosf_m,1983))) * te_sloo_m
  		next
  		series te_sloo_m_{%s}100o=0
	next

	smpl 1987 !projend
  	for %s m f 
    		for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
      		series te_sloo_m_{%s}{%a}  = (he_wosf_m_{%s}{%a}(-3)/he_wosf_m(-3)) * te_sloo_m
     		next
     		series te_sloo_m_{%s}100o=0
  	next 

	' 	Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
		for %c te_sloo		             	' loops over each MEF concept
	   		for %s m f                      	' loops over each sex    
     	 			for !n = 1 to !anum          ' loops over each age grouping
         				!loAge = @val(@word(%lo,!n))
         				!hiAge  = @val(@word(%hi,!n))
	         			' Create age grouping label
		     			%ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           			if (!loAge = 0 and !hiAge <> 4) then
           		 		%ag = @str(!hiAge) + "u"       ' 15u
         				endif

  	         			if (!loAge = 0 and !hiAge = 4) then
           		 		%ag = @str(!loAge) + "t4"       ' 0 to 4
         				endif

	         			if (!loAge = 5 and !hiAge = 9) then
           		 		%ag = @str(!loAge) + "t9"       ' 0 to 4
         				endif

       				if (!hiAge = 100 and !loAge=16) then
           				%ag = @str(!loAge) + "o"       ' 16o
         				endif

     					if (!hiAge = 100 and !loAge=65) then
           				%ag = @str(!loAge) + "o"       ' 65o
         				endif

       				if (!hiAge = 100 and !loAge=70) then
           				%ag = @str(!loAge) + "o"       ' 70o
         				endif

					if (!hiAge = 100 and !loAge=75) then
           				%ag = @str(!loAge) + "o"       ' 75o
         				endif

					if (!hiAge = 100 and !loAge=80) then
           				%ag = @str(!loAge) + "o"       ' 80o
         				endif

					if (!hiAge = 100 and !loAge=85) then
           				%ag = @str(!loAge) + "o"       ' 85o
         				endif

         				genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		
					for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            				if (!a <> 100) then
               					{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            				else
               					{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' series is called 100o in mef databank
            				endif
      	   			next
      			next
   	  		next
	next
	series te_sloo_m=te_sloo_m_f16o+te_sloo_m_m16o

pageselect MEF_finals
smpl 1951 !projend

copy bkdr1\te* MEF_finals\


	'    5b) TE_SLOS_M - Students 
	'         Definition - Total SL wage workers (Students Only) with 
	'                       1) no OASDI covered wages in their SL job
	'                       2) no OASDI covered wages in any other job
	'                       3) no    HI covered wages in their SL job
	'                       4) no       covered SENE

	'    5b1) Estimate Aggregate Values for TE_SLOS_M for 1988
	'         TE_SLOS_M = TESL_N_N_NHI_S * 0.99;
	'              where, TESL_N_N_NHI_S = Total SL wage workers (Students Only) with            
	'                                        1) no OASDI covered wages in their SL job
	'                                        2) no OASDI covered wages in any other job
	'                                        3) no    HI covered wages in their SL job
	'              And, 0.99 factor       = by assumption (i.e., we assume that only 1% of students report SE income)

	pageselect students
	smpl 1951 !projend

	series TE_SLOS_M = govtsector\TESL_N_N_NHI_S * 0.99
	series TE_PS_M   = govtsector\TEP_N_N_S      * 0.99


	'    5b3) Import and Extend Values for Age-Sex School Enrollment and Employment Ratios for 1988 and later
 	'        (see Excel file in excelimport command below)
	' Extends values past 2010; 2010 is the last year of data in file under %studentspath
	smpl 2011 !projend
	for %j {%rne}
  		series {%j} = @elem({%j},"2010") 
	next

	smpl 1983 1987
	for %j {%rne}
  		series {%j} = @elem({%j},1988)
	next

	'    5b4) Initialize each age/sex group to zero values

	smpl 1983 !projend
	for %s {%sex}
  		for %a {%age}
    			series   te_slos_m_{%s}{%a} =  0 
    			series     te_ps_m_{%s}{%a} =  0 
  		next
  		series te_slos_m_{%s}100o=0
  		series te_ps_m_{%s}100o=0
	next

	'    5b5) Estimate each age/sex S&L group value as the product of:

	'          1) SSA area population
	'          2) Ratio of total college enrolled to SSA Area Population
	'          3) Ratio of S&L enrollment to total college enrolled
	'          3) Ratio of total with any employment to total enrolled
	'          4) Ratio of total with school employment only to total with any employment
	'             (assumed to be .333)


	smpl 1983 !dataend

	for %s {%sex}
  		for %a 18 19
    			series te_slos_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}1819e * (1 - rn1834e_p) * rn1624e_e * 0.333
    			series   te_ps_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}1819e * (    rn1834e_p) * rn1624e_e * 0.333
  		next

  		for %a 20 21
		    	series te_slos_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}2021e * (1 - rn1834e_p) * rn1624e_e * 0.333
    			series   te_ps_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}2021e * (    rn1834e_p) * rn1624e_e * 0.333
  		next

		for %a 22 23 24
    			series te_slos_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}2224e * (1 - rn1834e_p) * rn1624e_e * 0.333
    			series   te_ps_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}2224e * (    rn1834e_p) * rn1624e_e * 0.333
  		next
 
		for %a 25 26 27 28 29
    			series te_slos_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}2529e * (1 - rn1834e_p) * rn1624e_e * 0.333
    			series   te_ps_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}2529e * (    rn1834e_p) * rn1624e_e * 0.333
  		next
  
		for %a 30 31 32 33 34
		    	series te_slos_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}3034e * (1 - rn1834e_p) * rn1624e_e * 0.333
    			series   te_ps_m_{%s}{%a} = RRB\n{%s}{%a} * rn{%s}3034e * (    rn1834e_p) * rn1624e_e * 0.333
  		next
	next


	group te_slos_mraw_g te_slos_m_*
	group te_ps_mraw_g te_ps_m_*

	'    5b6) Compare to TE_SLOS_M
 	genr te_slos_mraw=@rsum(te_slos_mraw_g)
 	genr te_ps_mraw=@rsum(te_ps_mraw_g)

	group check_slos te_slos_mraw te_slos_m te_slos_m/te_slos_mraw te_ps_m/te_ps_mraw

	'    5b7) Control TE_SLOS_M
	for %s {%sex} 
  		for %a 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34
    			series te_slos_m_{%s}{%a} = te_slos_m_{%s}{%a} * te_slos_m / te_slos_mraw 
    			series   te_ps_m_{%s}{%a} =   te_ps_m_{%s}{%a} *   te_ps_m / te_ps_mraw 
  		next
	next


	' Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
	for %c te_slos  te_ps          ' loops over each MEF concept
	   for %s m f                      	' loops over each sex    
     	 	for !n = 1 to !anum          ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 0 to 4
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

	     		if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif

       		if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif
			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif
			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif
			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            		else
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' series is called 100o in mef databank
            		endif
      	   	next
      	next
   	  next
	next

copy students\te* MEF_finals\



'    5c) TE_SLOE_M - Election Workers 
'         Definition - Total SL wage workers (Election Workers Only) with 
'                       1) no OASDI covered wages in their SL job
'                       2) no OASDI covered wages in any other job
'                       3) no    HI covered wages in their SL job
'                       4) no       covered SENE

	'    5c1) Estimate Aggregate Values for TE_SLOE_M for 1988 to 2011

	'         TE_SLOE_M = TESL_N_N_NHI_E * 1.00;

	'              where, TESL_N_N_NHI_E = Total SL wage workers (Election Workers Only) with            
	'                                        1) no OASDI covered wages in their SL job
	'                                        2) no OASDI covered wages in any other job
	'                                        3) no    HI covered wages in their SL job

	'              And, 1.00 factor       = by assumption (i.e., we assume that TESL_N_N_NHI_E have no SENE)

	pageselect govtsector
	series    TE_SLOE_M = TESL_N_N_NHI_E * 1.00

	'    5c3) Initialize each age/sex group to zero values

	smpl 1983 !projend
	for %s {%sex} 
  		for %a {%age}
    			series   te_sloe_m_{%s}{%a} =  0
  		next
   		series te_sloe_m_{%s}100o=0
	next

	'    5c4) Distribute TE_SLOE_M (i.e., TESL_N_N_NHI_E) to each age-sex S&L group based on the
	'         age-sex distribution of the SSA area population age 60 to 79;

	series n6079= RRB\nm6064 + RRB\nm6569 + RRB\nm7074 + RRB\nm75 + RRB\nm76 + RRB\nm77 + RRB\nm78 + RRB\nm79 + RRB\nf6064 + RRB\nf6569 + RRB\nf7074 + RRB\nf75 + RRB\nf76 + RRB\nf77 + RRB\nf78 + RRB\nf79 

	smpl 1983 !dataend

	for %s {%sex}
  		for %a 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
    			series te_sloe_m_{%s}{%a} = (RRB\n{%s}{%a} / n6079) * tesl_n_n_nhi_e
  		next
	next


	' Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
	for %c te_sloe			      ' loops over each MEF concept
	   for %s m f                      ' loops over each sex    
     	 	for !n = 1 to !anum      ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 0 to 4
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

     			if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif
       		
			if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif

			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif

			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif

			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            		else
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' series is called 100o in mef databank
            		endif
      	   	next
      	next
   	  next
	next

	copy govtsector\te_sloe* MEF_finals\
endif

' 6) TE_PH_M - Workers in Private Households

if !step6 = 1 then
	
	%msg = "Step 6 -- Private HH workers."
	logmsg {%msg}
	
	'    6a) Import Aggregate Estimated Value for TE_PH_M for 1988 to endyr from 
	'        Excel File Named 'WorkersWithNetCompOnly2012.xlsx'
	'        Pulled from atr172.bnk for TR18.  Update for TR19

    	'    6b) Initialize each age/sex group to zero values
	smpl 1983 !projend
	for %s m f
  		for %a {%age}
    			series   te_ph_m_{%s}{%a} =  0
  		next
		series te_ph_m_{%s}100o=0
	next
	smpl 1978 1987
  	te_ph_m.adjust = 0.0032  0.0039 0.0038 0.0074 0.0082 0.0093 0.0077 0.0115 0.0105 0.0105

	'    6c) Distribute TE_PH_M to age-sex components age 18 and over using the age-sex distribution of
	'        nonfarm PH wage workers age 18 and over in HH Survey

	'    6c1) Calculate the total number of nonfarm PH wage workers age 18 and over in the HH Survey

	smpl 1983 !dataend
	series e18onawph = em1819nawph+em2024nawph+em2534nawph+em3544nawph+em4554nawph+em5564nawph+em65onawph+ ef1819nawph+ef2024nawph+ef2534nawph+ef3544nawph+ef4554nawph+ef5564nawph+ef65onawph 

	series e18onawph = em1819nawph+em2024nawph+em2534nawph+em3544nawph+em4554nawph+em5564nawph+em65onawph+ ef1819nawph+ef2024nawph+ef2534nawph+ef3544nawph+ef4554nawph+ef5564nawph+ef65onawph

	series nm7579=RRB\nm75 + RRB\nm76 + RRB\nm77 + RRB\nm78 + RRB\nm79 
	series nf7579=RRB\nf75 + RRB\nf76 + RRB\nf77 + RRB\nf78 + RRB\nf79

	'    6c2) Calculate single-year-of-age values for nonfarm PH wage workers age 18 and over in the HH Survey
	'         Note: we have values for 1819, 2024, 2534, 3544, 4554, 5559, 6064, 6569, 7074, 75o. I get 
	'         single-year-of-age values by distribution the aggregated value using the SSA population data.

	for %s m f 
	  	for %a 18 19
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  RRB\n{%s}1819) * e{%s}1819nawph 
  		next
	next 

	for %s m f 
  		for %a 20 21 22 23 24
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  RRB\n{%s}2024) * e{%s}2024nawph 
  		next
	next

	for %s m f 
		for %a 25 26 27 28 29 30 31 32 33 34
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} / (RRB\n{%s}2529 + RRB\n{%s}3034)) * e{%s}2534nawph 
  		next
	next

	for %s m f 
		for %a 35 36 37 38 39 40 41 42 43 44
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} / (RRB\n{%s}3539 + RRB\n{%s}4044)) * e{%s}3544nawph 
  		next
	next

	for %s m f 
		for %a 45 46 47 48 49 50 51 52 53 54
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} / (RRB\n{%s}4549 + RRB\n{%s}5054)) * e{%s}4554nawph 
  		next
	next

	smpl 1983 1995
	for %s m f 
		for %a 55 56 57 58 59
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  RRB\n{%s}5559) * e{%s}5559nawph 
  		next
	next

	for %s m f 
  		for %a 60 61 62 63 64
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  RRB\n{%s}6064) * e{%s}6064nawph 
  		next
	next

	smpl 1996 !dataend
	for %s m f   
		for %a 55 56 57 58 59 60 61 62 63 64
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} / (RRB\n{%s}5559 + RRB\n{%s}6064)) * e{%s}5564nawph 
  		next
	next

	smpl 1983 1999
	for %s m f 
  		for %a 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} / (RRB\n{%s}6569 + RRB\n{%s}7074 + n{%s}7579)) * e{%s}65onawph 
  		next
	next

 	smpl 2000 !dataend
	for %s m f 
	  	for %a 65 66 67 68 69
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  RRB\n{%s}6569) * e{%s}6569nawph 
  		next
	next

	for %s m f 
  		for %a 70 71 72 73 74
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  RRB\n{%s}7074) * e{%s}7074nawph 
  		next
	next

	for %s m f 
  		for %a 75 76 77 78 79
    			series e{%s}{%a}nawph = (RRB\n{%s}{%a} /  n{%s}7579) * e{%s}75onawph 
  		next
	next

	'    6c3) Calculate single-year-of-age (18 to 79) values for nonfarm PH wage workers who are posted to MEF with
	'         no OASDI or HI covered earnings

	smpl 1983 !dataend
	for %s m f
  		for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
    			series  te_ph_m_{%s}{%a} = 0 
  		next
	next

	for %s m f
  		for %a 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
    			series  te_ph_m_{%s}{%a} = (e{%s}{%a}nawph / e18onawph) * te_ph_m 
  		next
	next

	for %s m f
  		for %a 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
    			series  te_ph_m_{%s}{%a} = 0 
  		next
    		series  te_ph_m_100o = 0 
	next


	' Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
	for %c te_ph             		' loops over each MEF concept
	   for %s m f                      ' loops over each sex    
     	 	for !n = 1 to !anum      ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 0 to 4
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

     			if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif

       		if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif
			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif
			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif
			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            		else
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' series is called 100o in mef databank
            		endif
      	   	next
      	next
   	  next
	next

copy govtsector\te_ph* MEF_finals\
endif

' 7a:  RRB Data

if !step7 =1 then
	
%msg = "Step 7 -- RRB data."
logmsg {%msg}

	'Read in RRB age-sex specific historical data and projections from Spreadsheet \\s1f906b\econ\Raw data\RRB\RRB employment - 20181017.xlsx 
	pageselect RRB
	!lastr = !projend - 1951 + 4 'last row that contains data in sheet %rrb_sheet
	%rng = %rrb_sheet + "!$B$4:$AB$"+@str(!lastr) ' range in the sheet %rrb_sheet
	import(page=RRB) %rrb_data range=%rng na="#N/A" @freq a 1951 @smpl @all
	   	rename series01 te_rr_m
 		rename series02 te_rr_m_f
           rename series03 te_rr_m_f1819
		rename series04 te_rr_m_f2024
		rename series05 te_rr_m_f2529
		rename series06 te_rr_m_f3034
		rename series07 te_rr_m_f3539
		rename series08 te_rr_m_f4044
		rename series09 te_rr_m_f4549
		rename series10 te_rr_m_f5054
		rename series11 te_rr_m_f5559
		rename series12 te_rr_m_f6064
		rename series13 te_rr_m_f6569
		rename series14 te_rr_m_f7074
		rename series15 te_rr_m_m
           rename series16 te_rr_m_m1819
		rename series17 te_rr_m_m2024
		rename series18 te_rr_m_m2529
		rename series19 te_rr_m_m3034
		rename series20 te_rr_m_m3539
		rename series21 te_rr_m_m4044
		rename series22 te_rr_m_m4549
		rename series23 te_rr_m_m5054
		rename series24 te_rr_m_m5559
		rename series25 te_rr_m_m6064
		rename series26 te_rr_m_m6569
		rename series27 te_rr_m_m7074

	smpl 1951 !projend 
	for %s m f 
  		for %a {%age}
    			series te_rr_m_{%s}{%a}  = 0
  		next
  		series te_rr_M_{%s}100o=0
	next

	'SYOA for RRB
	for %s m f
  		genr te_rr_m_{%s}18 = (MEF_Finals\ce_m_{%s}18)/(MEF_Finals\ce_m_{%s}1819) * te_rr_m_{%s}1819
  		genr te_rr_m_{%s}19 = te_rr_m_{%s}1819 - te_rr_m_{%s}18
  		
		for %a 20 21 22 23
    			genr te_rr_m_{%s}{%a}  = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}2024) * te_rr_m_{%s}2024
  		next
  		genr te_rr_m_{%s}24 = te_rr_m_{%s}2024 - (te_rr_m_{%s}20 + te_rr_m_{%s}21 + te_rr_m_{%s}22 + te_rr_m_{%s}23)

  		for %a 25 26 27 28
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}2529) * te_rr_m_{%s}2529
  		next
		series te_rr_m_{%s}29 = te_rr_m_{%s}2529 - (te_rr_m_{%s}25 + te_rr_m_{%s}26 + te_rr_m_{%s}27 + te_rr_m_{%s}28)

  		for %a 30 31 32 33
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}3034) * te_rr_m_{%s}3034
  		next
  		series te_rr_m_{%s}34 = te_rr_m_{%s}3034 - (te_rr_m_{%s}30 + te_rr_m_{%s}31 + te_rr_m_{%s}32 + te_rr_m_{%s}33)

  		for %a 35 36 37 38
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}3539) * te_rr_m_{%s}3539
  		next
  		series te_rr_m_{%s}39 = te_rr_m_{%s}3539 - (te_rr_m_{%s}35 + te_rr_m_{%s}36 + te_rr_m_{%s}37 + te_rr_m_{%s}38)

  		for %a 40 41 42 43
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a}) / (MEF_Finals\ce_m_{%s}4044) * te_rr_m_{%s}4044
  		next
  		series te_rr_m_{%s}44 = te_rr_m_{%s}4044 - (te_rr_m_{%s}40 + te_rr_m_{%s}41 + te_rr_m_{%s}42 + te_rr_m_{%s}43)

  		for %a 45 46 47 48
    			series te_rr_m_{%s}{%a}  = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}4549) * te_rr_m_{%s}4549
  		next
  		series te_rr_m_{%s}49 = te_rr_m_{%s}4549 - (te_rr_m_{%s}45 + te_rr_m_{%s}46 + te_rr_m_{%s}47 + te_rr_m_{%s}48)

  		for %a 50 51 52 53
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}5054) * te_rr_m_{%s}5054
  		next
  		series te_rr_m_{%s}54 = te_rr_m_{%s}5054 - (te_rr_m_{%s}50 + te_rr_m_{%s}51 + te_rr_m_{%s}52 + te_rr_m_{%s}53)

  		for %a 55 56 57 58
    			series te_rr_m_{%s}{%a} =  (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}5559) * te_rr_m_{%s}5559
  		next
  		series te_rr_m_{%s}59 = te_rr_m_{%s}5559 - (te_rr_m_{%s}55 + te_rr_m_{%s}56 + te_rr_m_{%s}57 + te_rr_m_{%s}58)

  		for %a 60 61 62 63
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}6064) * te_rr_m_{%s}6064
  		next
  		series te_rr_m_{%s}64 =  te_rr_m_{%s}6064 - (te_rr_m_{%s}60 + te_rr_m_{%s}61 + te_rr_m_{%s}62 + te_rr_m_{%s}63)

  		for %a 65 66 67 68
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}6569) * te_rr_m_{%s}6569
  		next
  		series te_rr_m_{%s}69 = te_rr_m_{%s}6569 - (te_rr_m_{%s}65 + te_rr_m_{%s}66 + te_rr_m_{%s}67 + te_rr_m_{%s}68) 

  		for %a 70 71 72 73
    			series te_rr_m_{%s}{%a} = (MEF_Finals\ce_m_{%s}{%a})/(MEF_Finals\ce_m_{%s}7074) * te_rr_m_{%s}7074
  		next
  		series te_rr_m_{%s}74 = te_rr_m_{%s}7074 - (te_rr_m_{%s}70 + te_rr_m_{%s}71 + te_rr_m_{%s}72 + te_rr_m_{%s}73)
	next

	smpl !dataend+1 !projend 

	for %s m f
  		genr te_rr_m_{%s}18 = n{%s}18/ n{%s}1819 * te_rr_m_{%s}1819
  		genr te_rr_m_{%s}19 = te_rr_m_{%s}1819 - te_rr_m_{%s}18
 
  		for %a 20 21 22 23
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}2024 * te_rr_m_{%s}2024
  		next
  		series te_rr_m_{%s}24 = te_rr_m_{%s}2024 - (te_rr_m_{%s}20 + te_rr_m_{%s}21 + te_rr_m_{%s}22 + te_rr_m_{%s}23)

  		for %a 30 31 32 33
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}3034 * te_rr_m_{%s}3034
  		next
  		series te_rr_m_{%s}34 = te_rr_m_{%s}3034 - (te_rr_m_{%s}30 + te_rr_m_{%s}31 + te_rr_m_{%s}32 + te_rr_m_{%s}33)

  		for %a 40 41 42 43
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}4044 * te_rr_m_{%s}4044
  		next
  		series te_rr_m_{%s}44 = te_rr_m_{%s}4044- (te_rr_m_{%s}40 + te_rr_m_{%s}41 + te_rr_m_{%s}42 + te_rr_m_{%s}43)

  		for %a 50 51 52 53
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}5054 * te_rr_m_{%s}5054
  		next
  		series te_rr_m_{%s}54 = te_rr_m_{%s}5054 - (te_rr_m_{%s}50 + te_rr_m_{%s}51 + te_rr_m_{%s}52 + te_rr_m_{%s}53)

  		for %a 60 61 62 63
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}6064 * te_rr_m_{%s}6064
  		next
  		series te_rr_m_{%s}64 = te_rr_m_{%s}6064 - (te_rr_m_{%s}60 + te_rr_m_{%s}61 + te_rr_m_{%s}62 + te_rr_m_{%s}63)
 
  		for %a 70 71 72 73
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}7074 * te_rr_m_{%s}7074
  		next
  		series te_rr_m_{%s}74 = te_rr_m_{%s}7074 - (te_rr_m_{%s}70 + te_rr_m_{%s}71 + te_rr_m_{%s}72 + te_rr_m_{%s}73)

  		for %a 25 26 27 28
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}2529 * te_rr_m_{%s}2529
  		next
  		series te_rr_m_{%s}29 = te_rr_m_{%s}2529 - (te_rr_m_{%s}25 + te_rr_m_{%s}26 + te_rr_m_{%s}27 + te_rr_m_{%s}28)

  		for %a 35 36 37 38
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}3539 * te_rr_m_{%s}3539
  		next
  		series te_rr_m_{%s}39 = te_rr_m_{%s}3539 - (te_rr_m_{%s}35 + te_rr_m_{%s}36 + te_rr_m_{%s}37 + te_rr_m_{%s}38)

  		for %a 45 46 47 48
    			series te_rr_m_{%s}{%a} = n{%s}{%a}/ n{%s}4549 * te_rr_m_{%s}4549
  		next
  		series te_rr_m_{%s}49 = te_rr_m_{%s}4549 - (te_rr_m_{%s}45 + te_rr_m_{%s}46 + te_rr_m_{%s}47 + te_rr_m_{%s}48)

  		for %a 55 56 57 58
    			series te_rr_m_{%s}{%a} = n{%s}{%a} / n{%s}5559 * te_rr_m_{%s}5559
  		next
  		series te_rr_m_{%s}59 = te_rr_m_{%s}5559 - (te_rr_m_{%s}55 + te_rr_m_{%s}56 + te_rr_m_{%s}57 + te_rr_m_{%s}58)

  		for %a 65 66 67 68
    			series te_rr_m_{%s}{%a} = n{%s}{%a} / n{%s}6569 * te_rr_m_{%s}6569
  		next
  		series te_rr_m_{%s}69 = te_rr_m_{%s}6569 - (te_rr_m_{%s}65 + te_rr_m_{%s}66 + te_rr_m_{%s}67 + te_rr_m_{%s}68)
	next

	' Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
	for %c te_rr			           ' loops over each MEF concept
	   for %s m f                      ' loops over each sex    
     	 	for !n = 1 to !anum          ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 0 to 4
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

     			if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif
       		
			if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif
			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif
			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif
			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            		else
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' series is called 100o in mef databank
            		endif
      	   	next
      	next
   	  next
	next

endif

'STEP 8: Now compute RRO.

if !step8 = 1 then
	
%msg = "Step 8 -- Compute RRO."
logmsg {%msg}
	'  Convert TE_RR_M to TE_RRO_M by syoa
	'      TE_RRO_M = TE_RR_M * (1.00 - 0.1465) * (1.00 - 0.05)
	'           (1.00 - 0.1465) = roughly adjust for the fact that some workers have a second wage job with OASDI coverage.
	'                             Factor (0.1465) is an approximate average of the the ratio TEFC_N_O / TEFC_N over the last
	'                             twenty years (1993 to 2012)in the ATR152.MAS
	'           (1.00 - 0.05)   = roughly adjust for the fact that some wage workers have some OASDI covered SE income.
	'                             Factor (0.05) is an approximate average of the the ratio CMB_TOT / WSWA over the last
	'                             twenty years (1993 to 2012) in the ATR152.MAS
	'         We apply these weights on each age-sex component of TERR_M

	smpl 1951 !projend 
	for %s m f 
  		for %a {%age}
    			series te_rro_m_{%s}{%a}  = 0
  		next
  		series te_rro_M_{%s}100o=0
	next

	for %s m f 
  		for %a 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74      
    			series te_rro_m_{%s}{%a}  = te_rr_m_{%s}{%a} * (1.00 - 0.1465) * (1.00 - 0.05)
  		next
	next

   
	' Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
	for %c te_rro		             	' loops over each MEF concept
	   for %s m f                      	' loops over each sex    
     	 	for !n = 1 to !anum          ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 0 to 4
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

     			if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif

       		if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif
			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif
			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif
			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}_m_{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}
            		else
               			{%c}_m_{%s}{%ag} = {%c}_m_{%s}{%ag} + {%c}_m_{%s}{!a}o ' series is called 100o in mef databank
            		endif
      	   	next
      	next
   	  next
	next

	copy RRB\te_rr* MEF_finals\
endif

'Step 9: LPR on ESF Only (TEL_SO) 

if !step9 = 1 then
	
%msg = "Step 9 -- LPR on ESF only."
logmsg {%msg}

	'    9a)  Import Aggregate Data from EViews workfile %esfe_src (ESF aggregate data). For TR19 it is \\s1f906b\econ\Raw data\ESF\esf_rpt_2018.wf1 

	'                          Mnemonic
	'          Modeem/esf_rpt_                           MEF Bank
	'          te_sfo_lrp             				         tel_so

	pageselect esf
	smpl 1951 !dataend
	
	wfopen %esf_src
	copy %esf_src::data\te_sfo_lrp %workfile2::esf\tel_so		'copy from ESF file and rename in the process
	wfclose %esf_src
	
	pageselect esf
	smpl !dataend+1 !projend
	genr tel_so = 0									' set to zero for the remainder of projection period
	smpl @all
	
		
	' 9b) Age-Sex Distribution by SYOA
	'     All are assumed to be age 16 to 62

	smpl 1951 !dataend
	series cew_m_m16o=MEF_finals\cew_m_m1619 + MEF_finals\cew_m_m2024 +MEF_finals\cew_m_m2529 + MEF_finals\cew_m_m3034 +MEF_finals\cew_m_m3539 + MEF_finals\cew_m_m4044 _
								+ MEF_finals\cew_m_m4549 + MEF_finals\cew_m_m5054 + MEF_finals\cew_m_m5559 +  MEF_finals\cew_m_m6064 + MEF_finals\cew_m_m6569+ MEF_finals\cew_m_m70o 

	series cew_m_f16o=MEF_finals\cew_m_f1619 + MEF_finals\cew_m_f2024 +MEF_finals\cew_m_f2529 + MEF_finals\cew_m_f3034 +MEF_finals\cew_m_f3539 + MEF_finals\cew_m_f4044 _
								+ MEF_finals\cew_m_f4549 + MEF_finals\cew_m_f5054 + MEF_finals\cew_m_f5559 +  MEF_finals\cew_m_f6064 + MEF_finals\cew_m_f6569+ MEF_finals\cew_m_f70o 

	series cewm1662 = cew_m_m16o - MEF_finals\cew_m_m70o- MEF_finals\cew_m_m6569 - MEF_finals\cew_m_m64 - MEF_finals\cew_m_m63
	series cewf1662 = cew_m_f16o - MEF_finals\cew_m_f70o - MEF_finals\cew_m_f6569 - MEF_finals\cew_m_f64 - MEF_finals\cew_m_f63

	series  cew1662 = cewm1662 + cewf1662

	for %s m f 
		for %a 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
    			series tel_so_{%s}{%a} = 0 
  		next
	next

	for %s m f 
  		for %a 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62
    			series   tel_so_{%s}{%a} =  tel_so *  ((MEF_finals\cew_m_{%s}{%a})/cew1662)
  		next
	next

	for %s m f 
  		for %a 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
    			series   tel_so_{%s}{%a} = 0 
  		next
  		series tel_so_{%s}100o = 0 
	next

   
	' Construct each mef concept-sex-age grouping:
	'	%lo and %hi lists are defined as global parameters at start of program; !anum is the number fo elelments in the lists (also defined in global parameters).
	for %c tel_so_                 ' loops over each MEF concept
	   for %s m f                      ' loops over each sex    
     	 	for !n = 1 to !anum          ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

           	if (!loAge = 0 and !hiAge <> 4) then
           		 %ag = @str(!hiAge) + "u"       ' 15u
         		endif

  	         	if (!loAge = 0 and !hiAge = 4) then
           		 %ag = @str(!loAge) + "t4"       ' 0 to 4
         		endif

	         	if (!loAge = 5 and !hiAge = 9) then
           		 %ag = @str(!loAge) + "t9"       ' 0 to 4
         		endif

       		if (!hiAge = 100 and !loAge=16) then
           		%ag = @str(!loAge) + "o"       ' 16o
         		endif

      		if (!hiAge = 100 and !loAge=65) then
           		%ag = @str(!loAge) + "o"       ' 65o
         		endif

       		if (!hiAge = 100 and !loAge=70) then
           		%ag = @str(!loAge) + "o"       ' 70o
         		endif
			if (!hiAge = 100 and !loAge=75) then
           		%ag = @str(!loAge) + "o"       ' 75o
         		endif
			if (!hiAge = 100 and !loAge=80) then
           		%ag = @str(!loAge) + "o"       ' 80o
         		endif
			if (!hiAge = 100 and !loAge=85) then
           		%ag = @str(!loAge) + "o"       ' 85o
         		endif

         		genr {%c}{%s}{%ag} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            		if (!a <> 100) then
               			{%c}{%s}{%ag} = {%c}{%s}{%ag} + {%c}{%s}{!a}
            		else
               			{%c}{%s}{%ag} = {%c}{%s}{%ag} + {%c}{%s}{!a}o ' series is called 100o in mef databank
            		endif
      	   	next
      	next
   	  next
	next

copy ESF\TEL_SO* MEF_finals\
endif

'STEP 10: Include Remaining Variables in MEF_finals

if !step10 = 1 then
	
%msg = "Step 10 -- Include Remaining Variables in MEF_finals."
logmsg {%msg}

	pageselect MEF_Finals

	smpl 1983 !projend 
	series awr_ns = 1
	series tefc_n_sw=0

	smpl 1983 2040
	series esr_ns=1
	
	smpl 2041 !projend 
	series esr_ns=0

	smpl 1983 !dataend
	series wsca_hio_oth=0
	series wscahi_add=0
	series wsw_hio_oth=0
	series wsw_hio_oth_se=0
	copy govtsector\tefc* MEF_finals\
	copy govtsector\tesl* MEF_finals\
	copy govtsector\teml_o MEF_finals\
	copy govtsector\wesl* MEF_finals\
	copy govtsector\wefc* MEF_finals\
	copy govtsector\tep_n_n_s MEF_finals\
	copy students\rn* MEF_finals\
	series tefc_n_n_se = he_wosf_m
	series tesl_n_n_hi_se=he_wosl_m
	series cer_mqge_o=tesl_n_o_hi/(tesl_n_o_hi+tesl_n_n_hi)	'CER_MQGE_O = Proportion of all hi new entrants with OASDI coverage in second job.
	series tesl_n_s=tesl_n_n_nhi_s+tesl_n_o_nhi_s
	series tesl_n_e=tesl_n_n_nhi_e+tesl_n_o_nhi_e

	smpl !dataend+1 !projend 
	series cer_mqge_o=@elem(cer_mqge_o,!dataend)

	smpl 1951 !dataend
	series wsw_mef_o=cew_m
	series seo=ceso_m
	series seo_hi=heso_m
	series csw=ces_m
	series csw_hi=hes_m
	series cmb=cesw_m
	series cmb_hi=hesw_m
	series cmb_tot=cmb+cmb_over
	series wsgfca=wefc_o
	series wsgslca=wesl_o

	smpl 1951 !projend 
	'create male and female specific series
	for %g ceso_m_ cesw_m_ ces_m_ cewo_m_ cew_m_ ce_m_ heso_m_ hesw_m_ hes_m_ hewo_m_ hew_m_ he_eo_m_ he_m_ he_wof_m_ 
  		for %s m f
    			series {%g}{%s} = {%g}{%s}15u +  {%g}{%s}16o
  		next
	next

	for %g he_wol_m_ he_wor_m_ he_wosl_m_ he_wosr_m_ he_wos_m_ he_wo_m_ tel_so_ te_ph_m_ te_ps_m_ te_rro_m_ te_sloe_m_ te_slos_m_  
  		for %s m f
    			series {%g}{%s} = {%g}{%s}15u +  {%g}{%s}16o
  		next
	next
	
	series he_wosf_m_f=he_wosf_m_f16o
	series he_wosf_m_m=he_wosf_m_m16o
	series te_sloo_m_f=te_sloo_m_f16o
	series te_sloo_m_m=te_sloo_m_m16o
	series he_wor_m=he_wor_m_f+he_wor_m_m
	series te_rro_m=te_rro_m_f+te_rro_m_m

endif


if %sav = "Y" then
	%msg = "Saving the resulting workfile." 
	logmsg {%msg}

	'save the resulting workfile
	pageselect MEF_finals
	%file_loc = %output_path + %workfile2
	wfsave(2) %file_loc
	
endif

if %sav = "N" then
	%msg = "The workfile has NOT been saved!!! Save manually if desired." 
	logmsg {%msg}
endif


!runtime = @toc
%msg = "FINISHED. Runtime " + @str(!runtime) + " sec" 
logmsg {%msg}

'wfclose


