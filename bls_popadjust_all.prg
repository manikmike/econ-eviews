
'	bls_popadjust_all.prg: 
'			smooths the labor force, employment, and 
'			unemployment rate to reduce influence of annual revisions/updates
'			to the civilian non-institutionalized population
'
'			See BLS paper: 
'			Creating Comparability in CPS Employment Series
'			Marisa L. DiNatale
' 
'			For annual changes to the population, see:
'			https://www.bls.gov/cps/documentation.htm#pop
'
'			For method to account for the annual changes 
'			see BLS paper by Di Natale "Creating Comparability in CPS Employment Series"
'			located at https://www.bls.gov/cps/cpscomp.pdf
'
'			For 1994 CPS methodology change and related adjustments
'			see BLS paper by Polivka and Miller "The CPS After the Redesign: Refocusing the Economic Lens"
'			located at https://www.bls.gov/osmr/research-papers/1995/pdf/ec950090.pdf
'
'			This program updates the aremos command file:
'			edblsadj_2018.cmd
'		
'			The edblsadj_2018.cmd called the following aremos command file:
'			adjustcpsdata_2018.cmd
'
'	Bob Weathers, 5-3-2019  

'			This program updates the aremos command file:
'			edblsadj_2018.cmd
' 			And makes a number of additions and changes, including:
'			- Creates _summary spool that describes the contents and structure of the file
' 			- Disaggregated adjustment to LFPRs and RU from larger groups to smaller ones by "uniform method" (see explanation on lines 1108-1143, 1879-1886).
'			- Automated data consistency checks and creates associated warnings (see lines 2155, 2369, 2657)
'			- Places adjusted annual data, quarterly data, and March CPS data in separate workfile pages
' 			- Creates an alternative adjusted series for aggregate groups (16o) by adding up the adjusted components (see lines 1379-1396, 1518-1525, 1780-1788)
'			- Creates labels for some series (but more work needed here)
'
' When time permits -- it would be helpful to add labels to the series in this file to explain what they are. Some labels have been added already, but ideally we would like to have labels for ALL series.
'
'	Polina Vlasenko, 6-12-2020

' The main loop that applies ALL annual adjustments to the data starts around line #1065. This loop needs to be modified every time a new Decennial Census data become available; see notes in the loop. 
' 
'!!!!! Once the program is run, please look at spool named _summary for description of what the file contains. !!!!!!


' ******* UPDATE entries here for each run ********

!yr_start = 1965 		' first year of the workfile
!yr_end = 2100 			' last year of the workfile

!yr_first = 2003 			' the first year for which we do CPS pop adjustment to MONTHLY data -- This should stay UNCHANGED!

' Enter LATEST year, for which we are implementing the CPS January pop controls released in this year, i.e. for pop controls released with Jan 2018 CPS, enter 2018; NOTE: these pop control apply to Jan data, but they come in the BLS release that is published early Feb every year,
!yr_latest = 2024		' this should be 2010 or later (else program will not run correctly)		

' workfile that contains the pop adjustment factors for all past years, up to and including the !yr_latest     
%popadj_factors_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Raw\CPS\PopAdjustments\CPS_PopAdj_Factors\cps_popadj_2024.wf1"	' full path 
%popadj_factors = "cps_popadj_2024"		' file name only

' D-bank for latest TR; need for computing population for single-year-of-age data. Typically this will be the D-bank from TRyear=!yr_latest. Example: we apply annual CPS adjustments released in Jan 2019 sometime after Jan 2019, at which point alt2 d-bank for TR19 already exists.
%dbank_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul\dtr242.wf1"		' full path 			 
%dbank = "dtr242"																			' short name

'The following databanks used to be stored in MKS and are now in Git.
'For the 2022 version, I decided to create copies on the econ server, because that makes the results reproducible.
'In the future, we may want to use Git files, but in that case, we should note the commits so we know which version was used.
'Since I am not well-versed in Git and would probably not come up with the best way to handle this,
'I prefer to just preserve a snapshot of the files on the econ server and use them from there.
'    -- SHS 08/03/2022
'  I am following the same method for 2023; see folder \\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\BLS\BLSadj\input23
' 	 -- PV 05/30/2023

' BKDO1 bank that contains data for n, l, e, p, and r
%bkdo1_path = "S:\LRECON\Data\Processed\BLS\BLSadj\input24\bkdo1.wf1" 	' Most recent BKDO1 bank (used for MSR)
%bkdo1 = "bkdo1"												' short name

' cnipopdata databank; need it for single-year-of-age data
%cnipop_path = "S:\LRECON\Data\Processed\BLS\BLSadj\input24\cnipopdata.wf1"	' full path 		
%cnipop = "cnipopdata"											' short name

' OP-bank for latest TR; need for computing population for single-year-of-age data. Typically this will be the op-bank from TRyear=!yr_latest. 
%opbank_path = "S:\LRECON\Data\Processed\BLS\BLSadj\input24\op1242o.wf1"	' full path		
%opbank = "op1242o"												' short name

' CPSO-bank for latest TR; need for March CPS data
%cpsobank_path = "S:\LRECON\Data\Processed\BLS\BLSadj\input24\cpso68123.wf1"	' full path		
%cpso = "cpso68123"													' short name

' ******
' file to be created by this program
%thisfile = "blsadj24" 																			' name only
%new_file_path = "S:\LRECON\Data\Processed\BLS\BLSadj" + "\" + %thisfile + ".wf1"	' full path 

' Save the output file(s) on this run? 
' Enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "Y" 		' enter "N" or "Y" (case sensitive)

' ******* END of update section **********


wfcreate(wf={%thisfile},page=annual) a !yr_start !yr_end
 		
logmode l			' this progtram will diplay log messages
%msg = "Running bls_popadjust_all.prg" 
logmsg {%msg}
logmsg

tic						' we will measure how long it takes for the program to run

'*****************************************************************************
'****	ANNUAL CPS methodology change adjustments:                   	****
'****   	for LFPRs and unemployment rates                          			****
'*****************************************************************************

'Initialize add factors to 0 and mult factors to 1:		' Create series for the adjustment factors (additing and multiplicative) and setting those series to zero for now.
																' These series are for some old population adjustment (some CPS methodology change) in year 1994.
smpl @all																
for %c r ep
 	for %s m f
   		for  %a 16o 1619 2024 2554 5564 65o
			series {%c}{%s}{%a}_94m = 0   
   			series {%c}{%s}{%a}_94m_m = 1
    		next
	next
next

for %c l e 
	for %s m f
   		for  %a 16o 1619 2024 2554 5564 65o
			series {%c}{%s}{%a}_94m_m = 1
    		next
	next
next

for %c p 
	for %s m f
   		for  %a 16o 1619 2024 2554 5564 65o
			series {%c}{%s}{%a}_94m = 0 
    		next
	next
next

series r16o_94m=0
series ep16o_94m=0
series r16o_94m_m=1
series ep16o_94m_m=1
series l16o_94m_m=1
series e16o_94m_m=1
series p16o_94m=0


%msg = "Creating adjustments to reflect 1994 methodology change" 
logmsg {%msg}
logmsg

'LFPRs;
'Additive:					' This is where the values for the 1994 adjustment are entered. Bob this this a long time ago. This is to stay unchanged.
SMPL @first 1993
series p16o_94m  =  0.0042

series pm16o_94m  = -0.0016 
series pm1619_94m =  0.0024
series pm2024_94m = -0.0130
series pm2554_94m = -0.0037
series pm5564_94m = -0.0025
series pm65o_94m  =  0.0125 

series pf16o_94m  =  0.0095 
series pf1619_94m =  0.0167 
series pf2024_94m =  0.0035 
series pf2554_94m =  0.0074 
series pf5564_94m =  0.0203 
series pf65o_94m  =  0.0085 


'**********************************************************************************************************
'**** Multiplicative:                                                                     				****
'****                                                                                      				****
'**** Set the LFPR adjustments equal to labor force adjustments, since all other adjustments 			****
'**** being made are for the labor force (not LFPRs) concept.                                			****
'****                                                                                        			****
'**** Multiplicative adjustment to the LFPR is equivalent to multiplicative adjustment to LC:			****
'****   LFPR = LC/cniPOP                                                                     			****
'****                                                                                        			****
'****   LFPR * adj = (LC * adj)/cniPOP                                                       			****
'**********************************************************************************************************
                
           
series l16o_94m_m   =  1.0064 

series lm16o_94m_m  =  0.9979 
series lm1619_94m_m =  1.0040 
series lm2024_94m_m =  0.9847 
series lm2554_94m_m =  0.9960 
series lm5564_94m_m =  0.9961 
series lm65o_94m_m  =  1.0840 

series lf16o_94m_m  =  1.0160 
series lf1619_94m_m =  1.0330 
series lf2024_94m_m =  1.0049 
series lf2554_94m_m =  1.0099 
series lf5564_94m_m =  1.0430 
series lf65o_94m_m  =  1.1060 


'Employment-Population Ratios;

'Additive:
series ep16o_94m   =  0.0033 

series epm16o_94m  = -0.0025 
series epm1619_94m = -0.0041 
series epm2024_94m = -0.0138 
series epm2554_94m = -0.0027 
series epm5564_94m = -0.0044 
series epm65o_94m  =  0.0088 

series epf16o_94m  =  0.0084 
series epf1619_94m =  0.0097 
series epf2024_94m =  0.0030 
series epf2554_94m =  0.0077 
series epf5564_94m =  0.0147 
series epf65o_94m  =  0.0077 

'Multiplicative:
series ep16o_94m_m   =  1.0053

series epm16o_94m_m  =  0.9964
series epm1619_94m_m =  0.9880
series epm2024_94m_m =  0.9815
series epm2554_94m_m =  0.9969
series epm5564_94m_m =  0.9927
series epm65o_94m_m  =  1.0620

series epf16o_94m_m  =  1.0156
series epf1619_94m_m =  1.0250
series epf2024_94m_m =  1.0047
series epf2554_94m_m =  1.0110
series epf5564_94m_m =  1.0320
series epf65o_94m_m  =  1.0980


'***************************************************************************************************************
'**** Multiplicative for employment (since CNI pop wasn't affected by CPS methodology change):	   ****
'***************************************************************************************************************

series e16o_94m_m   =  ep16o_94m_m

series em16o_94m_m  =  epm16o_94m_m 
series em1619_94m_m =  epm1619_94m_m
series em2024_94m_m =  epm2024_94m_m
series em2554_94m_m =  epm2554_94m_m
series em5564_94m_m =  epm5564_94m_m
series em65o_94m_m  =  epm65o_94m_m 

series ef16o_94m_m  =  epf16o_94m_m 
series ef1619_94m_m =  epf1619_94m_m 
series ef2024_94m_m =  epf2024_94m_m 
series ef2554_94m_m =  epf2554_94m_m
series ef5564_94m_m =  epf5564_94m_m
series ef65o_94m_m  =  epf65o_94m_m

' Unemployment Rates;

' Additive:
series r16o_94m   =  0.0790

series rm16o_94m  =  0.1000
series rm1619_94m =  0.7100
series rm2024_94m =  0.1600
series rm2554_94m = -0.0700
series rm5564_94m =  0.2900
series rm65o_94m  =  1.9300

series rf16o_94m  =  0.0700
series rf1619_94m =  0.5800
series rf2024_94m = -0.2300
series rf2554_94m = -0.0500
series rf5564_94m =  0.7600
series rf65o_94m  =  0.8500

' Multiplicative:

series r16o_94m_m   =  1.0090

series rm16o_94m_m  =  1.0120
series rm1619_94m_m =  1.0290
series rm2024_94m_m =  1.0240
series rm2554_94m_m =  0.9850
series rm5564_94m_m =  1.0600
series rm65o_94m_m  =  1.6900

series rf16o_94m_m  =  1.0070
series rf1619_94m_m =  1.0290
series rf2024_94m_m =  0.9800
series rf2554_94m_m =  0.9900
series rf5564_94m_m =  1.2320
series rf65o_94m_m  =  1.3300

' Done manually entering the values for adjustment for 1994. Note that all of the above series were ANNUAL.


'*************************************************************
'**** CPS methodology change adjustments       		      *****
'****   ANNUAL to QUARTERLY:                            	*****
'*************************************************************
pagecreate(page=quarterly) q !yr_start !yr_end		' Transform the annual adjustment values into quarterly ones by doing copy(c=r) -- this means "make quarterly values by repeating the annual value for each quarter".

for %c r ep
 	for %s m f
   		for  %a 16o 1619 2024 2554 5564 65o
			copy(c=r) annual\{%c}{%s}{%a}_94m   
   			copy(c=r) annual\{%c}{%s}{%a}_94m_m 
    		next
	next
next

for %c l e 
	for %s m f
   		for  %a 16o 1619 2024 2554 5564 65o
			copy(c=r) annual\{%c}{%s}{%a}_94m_m 
    		next
	next
next

for %c p 
	for %s m f
   		for  %a 16o 1619 2024 2554 5564 65o
			copy(c=r) annual\{%c}{%s}{%a}_94m
    		next
	next
next

   copy(c=r) annual\r16o_94m
   copy(c=r) annual\r16o_94m_m
   copy(c=r) annual\p16o_94m
   copy(c=r) annual\l16o_94m_m
   copy(c=r) annual\ep16o_94m
   copy(c=r) annual\ep16o_94m_m
   copy(c=r) annual\e16o_94m_m

'************************************************************************
'************************************************************************
'*****                            NON-MARCH DATA:    ***********************
'*****                            (standard CPS)            ***********************
'************************************************************************
'************************************************************************


'**********************************************************************************************************
'**** Multfactors for 1990 Census:                                                         				****
'****   This set of commands creates dummy variables that phase-in the 1990 Census change, 				****
'****       over a 10-year period;                                                         				****
'****  (1981 to 1989)                                                                      				****
'**********************************************************************************************************

%msg = "Creating adjustments to phase-in the 1990 Census" 
logmsg {%msg}
logmsg

pageselect annual			' Create adjustments to refect 1990 Census. The values below were manually entered (by Bob); this should stay unchanged.
smpl @all

' Civilian Noninstitutional Population:
for !t = 1981 to 1989
    smpl !t !t
    series n16o_90c   =  ((1.006108434 - 1.0) * (!t - 1980)/11) + 1

    series nm16o_90c  =  ((1.008017493 - 1.0) * (!t - 1980)/11) + 1
    series nm1619_90c =  ((1.057589683 - 1.0) * (!t - 1980)/11) + 1
    series nm1617_90c =  ((1.048438830 - 1.0) * (!t - 1980)/11) + 1
    series nm1819_90c =  ((1.066800416 - 1.0) * (!t - 1980)/11) + 1
    series nm2024_90c =  ((1.075126263 - 1.0) * (!t - 1980)/11) + 1
    series nm2534_90c =  ((1.005653051 - 1.0) * (!t - 1980)/11) + 1
    series nm2529_90c =  ((1.019550604 - 1.0) * (!t - 1980)/11) + 1
    series nm3034_90c =  ((0.993092416 - 1.0) * (!t - 1980)/11) + 1
    series nm3544_90c =  ((1.013446408 - 1.0) * (!t - 1980)/11) + 1
    series nm3539_90c =  ((1.004608865 - 1.0) * (!t - 1980)/11) + 1
    series nm4044_90c =  ((1.023347500 - 1.0) * (!t - 1980)/11) + 1
    series nm4554_90c =  ((0.991365948 - 1.0) * (!t - 1980)/11) + 1
    series nm4549_90c =  ((1.002823690 - 1.0) * (!t - 1980)/11) + 1
    series nm5054_90c =  ((0.977360477 - 1.0) * (!t - 1980)/11) + 1
    series nm5564_90c =  ((0.977176559 - 1.0) * (!t - 1980)/11) + 1
    series nm5559_90c =  ((0.978051920 - 1.0) * (!t - 1980)/11) + 1
    series nm6064_90c =  ((0.976293315 - 1.0) * (!t - 1980)/11) + 1
    series nm65o_90c  =  ((0.972147322 - 1.0) * (!t - 1980)/11) + 1
    series nm6569_90c =  ((0.961542670 - 1.0) * (!t - 1980)/11) + 1
    series nm7074_90c =  ((0.978108161 - 1.0) * (!t - 1980)/11) + 1
    series nm75o_90c  =  ((0.978235584 - 1.0) * (!t - 1980)/11) + 1
   
    series nf16o_90c  =  ((1.004355907 - 1.0) * (!t - 1980)/11) + 1
    series nf1619_90c =  ((1.046556109 - 1.0) * (!t - 1980)/11) + 1
    series nf1617_90c =  ((1.041174845 - 1.0) * (!t - 1980)/11) + 1
    series nf1819_90c =  ((1.051637243 - 1.0) * (!t - 1980)/11) + 1
    series nf2024_90c =  ((1.049407654 - 1.0) * (!t - 1980)/11) + 1
    series nf2534_90c =  ((1.008114320 - 1.0) * (!t - 1980)/11) + 1
    series nf2529_90c =  ((1.020129104 - 1.0) * (!t - 1980)/11) + 1
    series nf3034_90c =  ((0.997049059 - 1.0) * (!t - 1980)/11) + 1
    series nf3544_90c =  ((1.008823711 - 1.0) * (!t - 1980)/11) + 1
    series nf3539_90c =  ((1.004692196 - 1.0) * (!t - 1980)/11) + 1
    series nf4044_90c =  ((1.013494773 - 1.0) * (!t - 1980)/11) + 1
    series nf4554_90c =  ((0.980174130 - 1.0) * (!t - 1980)/11) + 1
    series nf4549_90c =  ((0.989877301 - 1.0) * (!t - 1980)/11) + 1
    series nf5054_90c =  ((0.968479625 - 1.0) * (!t - 1980)/11) + 1
    series nf5564_90c =  ((0.976824458 - 1.0) * (!t - 1980)/11) + 1
    series nf5559_90c =  ((0.971784004 - 1.0) * (!t - 1980)/11) + 1
    series nf6064_90c =  ((0.981752305 - 1.0) * (!t - 1980)/11) + 1
    series nf65o_90c  =  ((0.991330019 - 1.0) * (!t - 1980)/11) + 1
    series nf6569_90c =  ((0.982704912 - 1.0) * (!t - 1980)/11) + 1
    series nf7074_90c =  ((0.995302143 - 1.0) * (!t - 1980)/11) + 1
    series nf75o_90c  =  ((0.995247869 - 1.0) * (!t - 1880)/11) + 1
next

smpl @first 1980
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_90c=1
	next
next

series n16o_90c   =  1 

smpl 1990 @last
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_90c=1
	next
next

series n16o_90c   =  1 


' Civilian Labor Force:
smpl @all

for !t=1981 to 1989
    smpl !t !t

    series l16o_90c   =  ((1.008468808 - 1.0) * (!t - 1980)/11) + 1

    series lm16o_90c  =  ((1.011321279 - 1.0) * (!t - 1980)/11) + 1
    series lm1619_90c =  ((1.057320792 - 1.0) * (!t - 1980)/11) + 1
    series lm1617_90c =  ((1.042055276 - 1.0) * (!t - 1980)/11) + 1
    series lm1819_90c =  ((1.067008200 - 1.0) * (!t - 1980)/11) + 1
    series lm2024_90c =  ((1.076260935 - 1.0) * (!t - 1980)/11) + 1
    series lm2534_90c =  ((1.005085789 - 1.0) * (!t - 1980)/11) + 1
    series lm2529_90c =  ((1.018663148 - 1.0) * (!t - 1980)/11) + 1
    series lm3034_90c =  ((0.992807306 - 1.0) * (!t - 1980)/11) + 1
    series lm3544_90c =  ((1.012667581 - 1.0) * (!t - 1980)/11) + 1
    series lm3539_90c =  ((1.003611352 - 1.0) * (!t - 1980)/11) + 1
    series lm4044_90c =  ((1.022876206 - 1.0) * (!t - 1980)/11) + 1
    series lm4554_90c =  ((0.991492889 - 1.0) * (!t - 1980)/11) + 1
    series lm4549_90c =  ((1.002321712 - 1.0) * (!t - 1980)/11) + 1
    series lm5054_90c =  ((0.977871500 - 1.0) * (!t - 1980)/11) + 1
    series lm5564_90c =  ((0.978205702 - 1.0) * (!t - 1980)/11) + 1
    series lm5559_90c =  ((0.979019889 - 1.0) * (!t - 1980)/11) + 1
    series lm6064_90c =  ((0.977019802 - 1.0) * (!t - 1980)/11) + 1
    series lm65o_90c  =  ((0.966498995 - 1.0) * (!t - 1980)/11) + 1
    series lm6569_90c =  ((0.962736245 - 1.0) * (!t - 1980)/11) + 1
    series lm7074_90c =  ((0.973884250 - 1.0) * (!t - 1980)/11) + 1
    series lm75o_90c  =  ((0.970861199 - 1.0) * (!t - 1980)/11) + 1
   
    series lf16o_90c  =  ((1.005021127 - 1.0) * (!t - 1980)/11) + 1
    series lf1619_90c =  ((1.041391291 - 1.0) * (!t - 1980)/11) + 1
    series lf1617_90c =  ((1.034055728 - 1.0) * (!t - 1980)/11) + 1
    series lf1819_90c =  ((1.046555228 - 1.0) * (!t - 1980)/11) + 1
    series lf2024_90c =  ((1.044811025 - 1.0) * (!t - 1980)/11) + 1
    series lf2534_90c =  ((1.005317260 - 1.0) * (!t - 1980)/11) + 1
    series lf2529_90c =  ((1.016299855 - 1.0) * (!t - 1980)/11) + 1
    series lf3034_90c =  ((0.995149481 - 1.0) * (!t - 1980)/11) + 1
    series lf3544_90c =  ((1.007566761 - 1.0) * (!t - 1980)/11) + 1
    series lf3539_90c =  ((1.003361374 - 1.0) * (!t - 1980)/11) + 1
    series lf4044_90c =  ((1.012087690 - 1.0) * (!t - 1980)/11) + 1
    series lf4554_90c =  ((0.980359635 - 1.0) * (!t - 1980)/11) + 1
    series lf4549_90c =  ((0.988988250 - 1.0) * (!t - 1980)/11) + 1
    series lf5054_90c =  ((0.968787879 - 1.0) * (!t - 1980)/11) + 1
    series lf5564_90c =  ((0.975108868 - 1.0) * (!t - 1980)/11) + 1
    series lf5559_90c =  ((0.971317812 - 1.0) * (!t - 1980)/11) + 1
    series lf6064_90c =  ((0.980985866 - 1.0) * (!t - 1980)/11) + 1
    series lf65o_90c  =  ((0.984723362 - 1.0) * (!t - 1980)/11) + 1
    series lf6569_90c =  ((0.980967983 - 1.0) * (!t - 1980)/11) + 1
    series lf7074_90c =  ((0.993046575 - 1.0) * (!t - 1980)/11) + 1
    series lf75o_90c  =  ((0.987023923 - 1.0) * (!t - 1980)/11) + 1
next

smpl @first 1980
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_90c=1
	next
next

series l16o_90c   =  1 

smpl 1990 @last
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_90c=1
	next
next

series l16o_90c   =  1 

' Unemployment Rates:
smpl @all

for !t = 1981 to 1989
    smpl !t !t

    series r16o_90c   =  ((1.018663126 - 1.0) * (!t - 1980)/11) + 1

    series rm16o_90c  =  ((1.018992994 - 1.0) * (!t - 1980)/11) + 1
    series rm1619_90c =  ((1.000000000 - 1.0) * (!t - 1980)/11) + 1
    series rm1617_90c =  ((1.013969467 - 1.0) * (!t - 1980)/11) + 1
    series rm1819_90c =  ((0.994293575 - 1.0) * (!t - 1980)/11) + 1
    series rm2024_90c =  ((1.001159150 - 1.0) * (!t - 1980)/11) + 1
    series rm2534_90c =  ((1.006147059 - 1.0) * (!t - 1980)/11) + 1
    series rm2529_90c =  ((1.005547346 - 1.0) * (!t - 1980)/11) + 1
    series rm3034_90c =  ((1.007662719 - 1.0) * (!t - 1980)/11) + 1
    series rm3544_90c =  ((1.011297631 - 1.0) * (!t - 1980)/11) + 1
    series rm3539_90c =  ((1.007655526 - 1.0) * (!t - 1980)/11) + 1
    series rm4044_90c =  ((1.011595393 - 1.0) * (!t - 1980)/11) + 1
    series rm4554_90c =  ((1.006990036 - 1.0) * (!t - 1980)/11) + 1
    series rm4549_90c =  ((1.010187363 - 1.0) * (!t - 1980)/11) + 1
    series rm5054_90c =  ((1.001474554 - 1.0) * (!t - 1980)/11) + 1
    series rm5564_90c =  ((1.008451469 - 1.0) * (!t - 1980)/11) + 1
    series rm5559_90c =  ((0.999619934 - 1.0) * (!t - 1980)/11) + 1
    series rm6064_90c =  ((1.003175594 - 1.0) * (!t - 1980)/11) + 1
    series rm65o_90c  =  ((1.010075758 - 1.0) * (!t - 1980)/11) + 1
    series rm6569_90c =  ((1.004146735 - 1.0) * (!t - 1980)/11) + 1
    series rm7074_90c =  ((1.012666460 - 1.0) * (!t - 1980)/11) + 1
    series rm75o_90c  =  ((1.034023659 - 1.0) * (!t - 1980)/11) + 1
   
    series rf16o_90c  =  ((1.015477151 - 1.0) * (!t - 1980)/11) + 1
    series rf1619_90c =  ((1.000000000 - 1.0) * (!t - 1980)/11) + 1
    series rf1617_90c =  ((1.006911221 - 1.0) * (!t - 1980)/11) + 1
    series rf1819_90c =  ((1.002004602 - 1.0) * (!t - 1980)/11) + 1
    series rf2024_90c =  ((1.010095541 - 1.0) * (!t - 1980)/11) + 1
    series rf2534_90c =  ((1.011570956 - 1.0) * (!t - 1980)/11) + 1
    series rf2529_90c =  ((1.008369479 - 1.0) * (!t - 1980)/11) + 1
    series rf3034_90c =  ((1.006262279 - 1.0) * (!t - 1980)/11) + 1
    series rf3544_90c =  ((1.005609469 - 1.0) * (!t - 1980)/11) + 1
    series rf3539_90c =  ((1.009218841 - 1.0) * (!t - 1980)/11) + 1
    series rf4044_90c =  ((1.002444367 - 1.0) * (!t - 1980)/11) + 1
    series rf4554_90c =  ((1.002934701 - 1.0) * (!t - 1980)/11) + 1
    series rf4549_90c =  ((1.001141710 - 1.0) * (!t - 1980)/11) + 1
    series rf5054_90c =  ((1.000919118 - 1.0) * (!t - 1980)/11) + 1
    series rf5564_90c =  ((1.002612619 - 1.0) * (!t - 1980)/11) + 1
    series rf5559_90c =  ((1.006274272 - 1.0) * (!t - 1980)/11) + 1
    series rf6064_90c =  ((1.002462656 - 1.0) * (!t - 1980)/11) + 1
    series rf65o_90c  =  ((0.994741465 - 1.0) * (!t - 1980)/11) + 1
    series rf6569_90c =  ((0.993787879 - 1.0) * (!t - 1980)/11) + 1
    series rf7074_90c =  ((1.031401405 - 1.0) * (!t - 1980)/11) + 1
    series rf75o_90c  =  ((1.125116388 - 1.0) * (!t - 1980)/11) + 1
next

smpl @first 1980
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_90c=1
	next
next

series r16o_90c   =  1 

smpl 1990 @last
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_90c=1
	next
next

series r16o_90c   =  1 

' Employment:
smpl @all

for !t = 1981 to 1989
    
    smpl !t !t    

    series e16o_90c   =  ((1.007111934 - 1.0) * (!t - 1980)/11) + 1

    series em16o_90c  =  ((1.009882226 - 1.0) * (!t - 1980)/11) + 1
    series em1619_90c =  ((1.000000000 - 1.0) * (!t - 1980)/11) + 1
    series em1617_90c =  ((1.038042782 - 1.0) * (!t - 1980)/11) + 1
    series em1819_90c =  ((1.068398369 - 1.0) * (!t - 1980)/11) + 1
    series em2024_90c =  ((1.076095982 - 1.0) * (!t - 1980)/11) + 1
    series em2534_90c =  ((1.004623807 - 1.0) * (!t - 1980)/11) + 1
    series em2529_90c =  ((1.018204417 - 1.0) * (!t - 1980)/11) + 1
    series em3034_90c =  ((0.992282016 - 1.0) * (!t - 1980)/11) + 1
    series em3544_90c =  ((1.012009584 - 1.0) * (!t - 1980)/11) + 1
    series em3539_90c =  ((1.003127053 - 1.0) * (!t - 1980)/11) + 1
    series em4044_90c =  ((1.022267053 - 1.0) * (!t - 1980)/11) + 1
    series em4554_90c =  ((0.991142199 - 1.0) * (!t - 1980)/11) + 1
    series em4549_90c =  ((1.001642045 - 1.0) * (!t - 1980)/11) + 1
    series em5054_90c =  ((0.977798380 - 1.0) * (!t - 1980)/11) + 1
    series em5564_90c =  ((0.977804567 - 1.0) * (!t - 1980)/11) + 1
    series em5559_90c =  ((0.978780133 - 1.0) * (!t - 1980)/11) + 1
    series em6064_90c =  ((0.976888154 - 1.0) * (!t - 1980)/11) + 1
    series em65o_90c  =  ((0.966667366 - 1.0) * (!t - 1980)/11) + 1
    series em6569_90c =  ((0.962584229 - 1.0) * (!t - 1980)/11) + 1
    series em7074_90c =  ((0.973473062 - 1.0) * (!t - 1980)/11) + 1
    series em75o_90c  =  ((0.970115309 - 1.0) * (!t - 1980)/11) + 1
   
    series ef16o_90c  =  ((1.003967575 - 1.0) * (!t - 1980)/11) + 1
    series ef1619_90c =  ((1.000000000 - 1.0) * (!t - 1980)/11) + 1
    series ef1617_90c =  ((1.032263892 - 1.0) * (!t - 1980)/11) + 1
    series ef1819_90c =  ((1.045551681 - 1.0) * (!t - 1980)/11) + 1
    series ef2024_90c =  ((1.043671296 - 1.0) * (!t - 1980)/11) + 1
    series ef2534_90c =  ((1.004414038 - 1.0) * (!t - 1980)/11) + 1
    series ef2529_90c =  ((1.015493387 - 1.0) * (!t - 1980)/11) + 1
    series ef3034_90c =  ((0.994736778 - 1.0) * (!t - 1980)/11) + 1
    series ef3544_90c =  ((1.007354950 - 1.0) * (!t - 1980)/11) + 1
    series ef3539_90c =  ((1.002859734 - 1.0) * (!t - 1980)/11) + 1
    series ef4044_90c =  ((1.011975917 - 1.0) * (!t - 1980)/11) + 1
    series ef4554_90c =  ((0.980234667 - 1.0) * (!t - 1980)/11) + 1
    series ef4549_90c =  ((0.988938601 - 1.0) * (!t - 1980)/11) + 1
    series ef5054_90c =  ((0.968749605 - 1.0) * (!t - 1980)/11) + 1
    series ef5564_90c =  ((0.975018535 - 1.0) * (!t - 1980)/11) + 1
    series ef5559_90c =  ((0.971433620 - 1.0) * (!t - 1980)/11) + 1
    series ef6064_90c =  ((0.980898684 - 1.0) * (!t - 1980)/11) + 1
    series ef65o_90c  =  ((0.984900576 - 1.0) * (!t - 1980)/11) + 1
    series ef6569_90c =  ((0.981190437 - 1.0) * (!t - 1980)/11) + 1
    series ef7074_90c =  ((0.992077610 - 1.0) * (!t - 1980)/11) + 1
    series ef75o_90c  =  ((0.988844414 - 1.0) * (!t - 1980)/11) + 1

next

smpl @first 1980
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_90c=1
	next
next

series e16o_90c   =  1 

smpl 1990 @last
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_90c=1
	next
next

series e16o_90c   =  1 

' Done creating adjustments due to the 1990 Cnesus.

'**********************************************************************************************************
'**** Multfactors for 2000 Census:                                                         				****
'****   This set of commands creates dummy variables that phase-in the 2000 Census change, 				****
'****       over a 10-year period;                                                         				****
'****       (1991 to 1999)                                                                 				****
'**********************************************************************************************************

%msg = "Creating adjustments to phase-in the 2000 Census" 
logmsg {%msg}
logmsg

' Civilian Noninstitutional Population:		' Create adjustments for 2000 Census; enetered by Bob, should stay unchanged.
smpl @all

for !t = 1991 to 1999
    smpl !t !t

    series n16o_00c   =  ((1.012652263 - 1.0) * (!t - 1990)/10) + 1

    series nm16o_00c  =  ((1.012241346 - 1.0) * (!t - 1990)/10) + 1
    series nm1619_00c =  ((0.992444731 - 1.0) * (!t - 1990)/10) + 1
    series nm1617_00c =  ((0.997119523 - 1.0) * (!t - 1990)/10) + 1
    series nm1819_00c =  ((0.987694781 - 1.0) * (!t - 1990)/10) + 1
    series nm2024_00c =  ((0.994173804 - 1.0) * (!t - 1990)/10) + 1
    series nm2534_00c =  ((1.044648860 - 1.0) * (!t - 1990)/10) + 1
    series nm2529_00c =  ((1.054262863 - 1.0) * (!t - 1990)/10) + 1
    series nm3034_00c =  ((1.035837787 - 1.0) * (!t - 1990)/10) + 1
    series nm3544_00c =  ((0.987806159 - 1.0) * (!t - 1990)/10) + 1
    series nm3539_00c =  ((0.996459589 - 1.0) * (!t - 1990)/10) + 1
    series nm4044_00c =  ((0.979346847 - 1.0) * (!t - 1990)/10) + 1
    series nm4554_00c =  ((1.020060375 - 1.0) * (!t - 1990)/10) + 1
    series nm4549_00c =  ((1.005408468 - 1.0) * (!t - 1990)/10) + 1
    series nm5054_00c =  ((1.037202242 - 1.0) * (!t - 1990)/10) + 1
    series nm5564_00c =  ((1.028967132 - 1.0) * (!t - 1990)/10) + 1
    series nm5559_00c =  ((1.028090981 - 1.0) * (!t - 1990)/10) + 1
    series nm6064_00c =  ((1.030080056 - 1.0) * (!t - 1990)/10) + 1
    series nm65o_00c  =  ((1.008031095 - 1.0) * (!t - 1990)/10) + 1
    series nm6569_00c =  ((1.021408517 - 1.0) * (!t - 1990)/10) + 1
    series nm7074_00c =  ((1.013264141 - 1.0) * (!t - 1990)/10) + 1
    series nm75o_00c  =  ((0.994857607 - 1.0) * (!t - 1990)/10) + 1
   
    series nf16o_00c  =  ((1.013032110 - 1.0) * (!t - 1990)/10) + 1
    series nf1619_00c =  ((0.991497719 - 1.0) * (!t - 1990)/10) + 1
    series nf1617_00c =  ((0.996641078 - 1.0) * (!t - 1990)/10) + 1
    series nf1819_00c =  ((0.986483104 - 1.0) * (!t - 1990)/10) + 1
    series nf2024_00c =  ((0.994958734 - 1.0) * (!t - 1990)/10) + 1
    series nf2534_00c =  ((1.012830249 - 1.0) * (!t - 1990)/10) + 1
    series nf2529_00c =  ((1.026636679 - 1.0) * (!t - 1990)/10) + 1
    series nf3034_00c =  ((0.999966370 - 1.0) * (!t - 1990)/10) + 1
    series nf3544_00c =  ((0.998830280 - 1.0) * (!t - 1990)/10) + 1
    series nf3539_00c =  ((1.006015615 - 1.0) * (!t - 1990)/10) + 1
    series nf4044_00c =  ((0.991882851 - 1.0) * (!t - 1990)/10) + 1
    series nf4554_00c =  ((1.019853447 - 1.0) * (!t - 1990)/10) + 1
    series nf4549_00c =  ((1.010461834 - 1.0) * (!t - 1990)/10) + 1
    series nf5054_00c =  ((1.030723319 - 1.0) * (!t - 1990)/10) + 1
    series nf5564_00c =  ((1.023399175 - 1.0) * (!t - 1990)/10) + 1
    series nf5559_00c =  ((1.020955331 - 1.0) * (!t - 1990)/10) + 1
    series nf6064_00c =  ((1.026416456 - 1.0) * (!t - 1990)/10) + 1
    series nf65o_00c  =  ((1.034584665 - 1.0) * (!t - 1990)/10) + 1
    series nf6569_00c =  ((1.024959904 - 1.0) * (!t - 1990)/10) + 1
    series nf7074_00c =  ((1.028620523 - 1.0) * (!t - 1990)/10) + 1
    series nf75o_00c  =  ((1.043136208 - 1.0) * (!t - 1990)/10) + 1

next

smpl @first 1990
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_00c=1
	next
next

series n16o_00c   =  1 

smpl 2000 @last
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_00c=1
	next
next

series n16o_00c   =  1 


' Civilian Labor Force:
smpl @all

for !t = 1991 to 1999
    smpl !t !t

    series l16o_00c   =  ((1.012243577 - 1.0) * (!t - 1990)/10) + 1

    series lm16o_00c  =  ((1.013745837 - 1.0) * (!t - 1990)/10) + 1
    series lm1619_00c =  ((0.989749826 - 1.0) * (!t - 1990)/10) + 1
    series lm1617_00c =  ((0.994964455 - 1.0) * (!t - 1990)/10) + 1
    series lm1819_00c =  ((0.986401674 - 1.0) * (!t - 1990)/10) + 1
    series lm2024_00c =  ((0.995082429 - 1.0) * (!t - 1990)/10) + 1
    series lm2534_00c =  ((1.045041879 - 1.0) * (!t - 1990)/10) + 1
    series lm2529_00c =  ((1.055277304 - 1.0) * (!t - 1990)/10) + 1
    series lm3034_00c =  ((1.035834780 - 1.0) * (!t - 1990)/10) + 1
    series lm3544_00c =  ((0.988139717 - 1.0) * (!t - 1990)/10) + 1
    series lm3539_00c =  ((0.996851958 - 1.0) * (!t - 1990)/10) + 1
    series lm4044_00c =  ((0.979521327 - 1.0) * (!t - 1990)/10) + 1
    series lm4554_00c =  ((1.019925585 - 1.0) * (!t - 1990)/10) + 1
    series lm4549_00c =  ((1.005886387 - 1.0) * (!t - 1990)/10) + 1
    series lm5054_00c =  ((1.036980422 - 1.0) * (!t - 1990)/10) + 1
    series lm5564_00c =  ((1.029257988 - 1.0) * (!t - 1990)/10) + 1
    series lm5559_00c =  ((1.027354407 - 1.0) * (!t - 1990)/10) + 1
    series lm6064_00c =  ((1.032658572 - 1.0) * (!t - 1990)/10) + 1
    series lm65o_00c  =  ((1.020288643 - 1.0) * (!t - 1990)/10) + 1
    series lm6569_00c =  ((1.027950311 - 1.0) * (!t - 1990)/10) + 1
    series lm7074_00c =  ((1.017107038 - 1.0) * (!t - 1990)/10) + 1
    series lm75o_00c  =  ((1.003874200 - 1.0) * (!t - 1990)/10) + 1
   
    series lf16o_00c  =  ((1.010520803 - 1.0) * (!t - 1990)/10) + 1
    series lf1619_00c =  ((0.988130585 - 1.0) * (!t - 1990)/10) + 1
    series lf1617_00c =  ((0.994256266 - 1.0) * (!t - 1990)/10) + 1
    series lf1819_00c =  ((0.983747150 - 1.0) * (!t - 1990)/10) + 1
    series lf2024_00c =  ((0.991136270 - 1.0) * (!t - 1990)/10) + 1
    series lf2534_00c =  ((1.021678337 - 1.0) * (!t - 1990)/10) + 1
    series lf2529_00c =  ((1.022148784 - 1.0) * (!t - 1990)/10) + 1
    series lf3034_00c =  ((1.021231396 - 1.0) * (!t - 1990)/10) + 1
    series lf3544_00c =  ((0.998314671 - 1.0) * (!t - 1990)/10) + 1
    series lf3539_00c =  ((1.004343687 - 1.0) * (!t - 1990)/10) + 1
    series lf4044_00c =  ((0.992624431 - 1.0) * (!t - 1990)/10) + 1
    series lf4554_00c =  ((1.019830038 - 1.0) * (!t - 1990)/10) + 1
    series lf4549_00c =  ((1.010585515 - 1.0) * (!t - 1990)/10) + 1
    series lf5054_00c =  ((1.031251656 - 1.0) * (!t - 1990)/10) + 1
    series lf5564_00c =  ((1.025249531 - 1.0) * (!t - 1990)/10) + 1
    series lf5559_00c =  ((1.023240134 - 1.0) * (!t - 1990)/10) + 1
    series lf6064_00c =  ((1.029035602 - 1.0) * (!t - 1990)/10) + 1
    series lf65o_00c  =  ((1.035321793 - 1.0) * (!t - 1990)/10) + 1
    series lf6569_00c =  ((1.030013416 - 1.0) * (!t - 1990)/10) + 1
    series lf7074_00c =  ((1.036722458 - 1.0) * (!t - 1990)/10) + 1
    series lf75o_00c  =  ((1.049283489 - 1.0) * (!t - 1990)/10) + 1

next

smpl @first 1990
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_00c=1
	next
next

series l16o_00c   =  1 

smpl 2000 @last
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_00c=1
	next
next

series l16o_00c   =  1 


' Unemployment Rates:
smpl @all

for !t = 1991 to 1999
    smpl !t !t

    series r16o_00c   =  ((0.988075356 - 1.0) * (!t - 1990)/10) + 1

    series rm16o_00c  =  ((0.991321147 - 1.0) * (!t - 1990)/10) + 1
    series rm1619_00c =  ((1.000000000 - 1.0) * (!t - 1990)/10) + 1
    series rm1617_00c =  ((0.999720088 - 1.0) * (!t - 1990)/10) + 1
    series rm1819_00c =  ((1.000323362 - 1.0) * (!t - 1990)/10) + 1
    series rm2024_00c =  ((0.999243731 - 1.0) * (!t - 1990)/10) + 1
    series rm2534_00c =  ((0.995187824 - 1.0) * (!t - 1990)/10) + 1
    series rm2529_00c =  ((1.002150242 - 1.0) * (!t - 1990)/10) + 1
    series rm3034_00c =  ((1.005388346 - 1.0) * (!t - 1990)/10) + 1
    series rm3544_00c =  ((0.991462766 - 1.0) * (!t - 1990)/10) + 1
    series rm3539_00c =  ((0.997204152 - 1.0) * (!t - 1990)/10) + 1
    series rm4044_00c =  ((1.003614545 - 1.0) * (!t - 1990)/10) + 1
    series rm4554_00c =  ((0.999487212 - 1.0) * (!t - 1990)/10) + 1
    series rm4549_00c =  ((0.996414028 - 1.0) * (!t - 1990)/10) + 1
    series rm5054_00c =  ((1.001383190 - 1.0) * (!t - 1990)/10) + 1
    series rm5564_00c =  ((1.006454818 - 1.0) * (!t - 1990)/10) + 1
    series rm5559_00c =  ((0.988389381 - 1.0) * (!t - 1990)/10) + 1
    series rm6064_00c =  ((1.000375000 - 1.0) * (!t - 1990)/10) + 1
    series rm65o_00c  =  ((0.949083608 - 1.0) * (!t - 1990)/10) + 1
    series rm6569_00c =  ((0.993457464 - 1.0) * (!t - 1990)/10) + 1
    series rm7074_00c =  ((0.989321072 - 1.0) * (!t - 1990)/10) + 1
    series rm75o_00c  =  ((0.980089864 - 1.0) * (!t - 1990)/10) + 1
   
    series rf16o_00c  =  ((0.991973262 - 1.0) * (!t - 1990)/10) + 1
    series rf1619_00c =  ((1.000000000 - 1.0) * (!t - 1990)/10) + 1
    series rf1617_00c =  ((1.000262583 - 1.0) * (!t - 1990)/10) + 1
    series rf1819_00c =  ((1.001531778 - 1.0) * (!t - 1990)/10) + 1
    series rf2024_00c =  ((1.001800420 - 1.0) * (!t - 1990)/10) + 1
    series rf2534_00c =  ((0.989559322 - 1.0) * (!t - 1990)/10) + 1
    series rf2529_00c =  ((1.001793974 - 1.0) * (!t - 1990)/10) + 1
    series rf3034_00c =  ((0.999769592 - 1.0) * (!t - 1990)/10) + 1
    series rf3544_00c =  ((1.001095321 - 1.0) * (!t - 1990)/10) + 1
    series rf3539_00c =  ((0.999740550 - 1.0) * (!t - 1990)/10) + 1
    series rf4044_00c =  ((0.999671779 - 1.0) * (!t - 1990)/10) + 1
    series rf4554_00c =  ((0.990577994 - 1.0) * (!t - 1990)/10) + 1
    series rf4549_00c =  ((0.999566794 - 1.0) * (!t - 1990)/10) + 1
    series rf5054_00c =  ((0.995012159 - 1.0) * (!t - 1990)/10) + 1
    series rf5564_00c =  ((0.997530864 - 1.0) * (!t - 1990)/10) + 1
    series rf5559_00c =  ((1.001698051 - 1.0) * (!t - 1990)/10) + 1
    series rf6064_00c =  ((0.996669492 - 1.0) * (!t - 1990)/10) + 1
    series rf65o_00c  =  ((0.980442965 - 1.0) * (!t - 1990)/10) + 1
    series rf6569_00c =  ((1.013551613 - 1.0) * (!t - 1990)/10) + 1
    series rf7074_00c =  ((0.999722353 - 1.0) * (!t - 1990)/10) + 1
    series rf75o_00c  =  ((1.054714286 - 1.0) * (!t - 1990)/10) + 1
next

smpl @first 1990
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_00c=1
	next
next

series r16o_00c   =  1 

smpl 2000 @last
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_00c=1
	next
next

series r16o_00c   =  1 

' Employment:
smpl @all

for !t = 1991 to 1999
    smpl !t !t

    series e16o_00c   =  ((1.012748425 - 1.0) * (!t - 1990)/10) + 1

    series em16o_00c  =  ((1.014105343 - 1.0) * (!t - 1990)/10) + 1
    series em1619_00c =  ((1.000000000 - 1.0) * (!t - 1990)/10) + 1
    series em1617_00c =  ((0.995020552 - 1.0) * (!t - 1990)/10) + 1
    series em1819_00c =  ((0.986357312 - 1.0) * (!t - 1990)/10) + 1
    series em2024_00c =  ((0.995141375 - 1.0) * (!t - 1990)/10) + 1
    series em2534_00c =  ((1.045218413 - 1.0) * (!t - 1990)/10) + 1
    series em2529_00c =  ((1.055320273 - 1.0) * (!t - 1990)/10) + 1
    series em3034_00c =  ((1.035668513 - 1.0) * (!t - 1990)/10) + 1
    series em3544_00c =  ((0.988380379 - 1.0) * (!t - 1990)/10) + 1
    series em3539_00c =  ((0.996832476 - 1.0) * (!t - 1990)/10) + 1
    series em4044_00c =  ((0.979521917 - 1.0) * (!t - 1990)/10) + 1
    series em4554_00c =  ((1.019873182 - 1.0) * (!t - 1990)/10) + 1
    series em4549_00c =  ((1.005975096 - 1.0) * (!t - 1990)/10) + 1
    series em5054_00c =  ((1.036795774 - 1.0) * (!t - 1990)/10) + 1
    series em5564_00c =  ((1.029091649 - 1.0) * (!t - 1990)/10) + 1
    series em5559_00c =  ((1.027421973 - 1.0) * (!t - 1990)/10) + 1
    series em6064_00c =  ((1.032648035 - 1.0) * (!t - 1990)/10) + 1
    series em65o_00c  =  ((1.022095962 - 1.0) * (!t - 1990)/10) + 1
    series em6569_00c =  ((1.027357407 - 1.0) * (!t - 1990)/10) + 1
    series em7074_00c =  ((1.017554769 - 1.0) * (!t - 1990)/10) + 1
    series em75o_00c  =  ((1.004444013 - 1.0) * (!t - 1990)/10) + 1
   
    series ef16o_00c  =  ((1.010869024 - 1.0) * (!t - 1990)/10) + 1
    series ef1619_00c =  ((1.000000000 - 1.0) * (!t - 1990)/10) + 1
    series ef1617_00c =  ((0.994213862 - 1.0) * (!t - 1990)/10) + 1
    series ef1819_00c =  ((0.983564122 - 1.0) * (!t - 1990)/10) + 1
    series ef2024_00c =  ((0.991001700 - 1.0) * (!t - 1990)/10) + 1
    series ef2534_00c =  ((1.022127682 - 1.0) * (!t - 1990)/10) + 1
    series ef2529_00c =  ((1.022066046 - 1.0) * (!t - 1990)/10) + 1
    series ef3034_00c =  ((1.021382408 - 1.0) * (!t - 1990)/10) + 1
    series ef3544_00c =  ((0.998277397 - 1.0) * (!t - 1990)/10) + 1
    series ef3539_00c =  ((1.004230632 - 1.0) * (!t - 1990)/10) + 1
    series ef4044_00c =  ((0.992635002 - 1.0) * (!t - 1990)/10) + 1
    series ef4554_00c =  ((1.020073721 - 1.0) * (!t - 1990)/10) + 1
    series ef4549_00c =  ((1.010597283 - 1.0) * (!t - 1990)/10) + 1
    series ef5054_00c =  ((1.031372465 - 1.0) * (!t - 1990)/10) + 1
    series ef5564_00c =  ((1.025315273 - 1.0) * (!t - 1990)/10) + 1
    series ef5559_00c =  ((1.023195812 - 1.0) * (!t - 1990)/10) + 1
    series ef6064_00c =  ((1.029129215 - 1.0) * (!t - 1990)/10) + 1
    series ef65o_00c  =  ((1.035900978 - 1.0) * (!t - 1990)/10) + 1
    series ef6569_00c =  ((1.029582786 - 1.0) * (!t - 1990)/10) + 1
    series ef7074_00c =  ((1.036729967 - 1.0) * (!t - 1990)/10) + 1
    series ef75o_00c  =  ((1.048003631 - 1.0) * (!t - 1990)/10) + 1
next

smpl @first 1990
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_00c=1
	next
next

series e16o_00c   =  1 

smpl 2000 @last
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_00c=1
	next
next

series e16o_00c   =  1 

' Done creating ANNUAL adjustment for 2000 Census
    

'********************************************************************************
'****    Make ANNUAL adjustments QUARTERLY for standard CPS: 		****
'********************************************************************************

'Transform the annaul adjustments into quarterly. 
' The transformation is done by copy(c=linearl), linearl means linear interpolation matching the last value, i.e Q4 values is equal to the annual values, Q1 through Q3 are linearly interpolated.
smpl @all
pageselect quarterly 

for %c  n l r e
	copy(c=linearl) annual\{%c}16o_90c
	smpl 1965Q1 1965Q4
	{%c}16o_90c = 1
	smpl 1990Q1 1990Q4
	{%c}16o_90c = 1
	smpl @all
	
	copy(c=linearl) annual\{%c}16o_00c
	smpl 1965Q1 1965Q4
	{%c}16o_00c = 1
	smpl 2000Q1 2000Q4
	{%c}16o_00c = 1
	smpl @all
	
	for %s  m f
		for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
						
			copy(c=linearl) annual\{%c}{%s}{%a}_90c
			smpl 1965Q1 1965Q4
			{%c}{%s}{%a}_90c = 1
			smpl 1990Q1 1990Q4
			{%c}{%s}{%a}_90c = 1
			smpl @all
			
			copy(c=linearl) annual\{%c}{%s}{%a}_00c
			smpl 1965Q1 1965Q4
			{%c}{%s}{%a}_00c = 1
			smpl 2000Q1 2000Q4
			{%c}{%s}{%a}_00c = 1
			smpl @all
			
		next
	next
next


' Everything above dealt with adjustment due to decennial Census. Now we move to the adjustment to account for the annaul BLS population controls.

'***************************************************************************************
'****    Get monthly interpolated values of the BLS annual population adjustments 		****
'***************************************************************************************
%msg = "Load values for the BLS annual population adjustments from " + %popadj_factors_path
logmsg {%msg}
logmsg

'***** HERE IS WHERE THE ADJUSTMENTS ARE UPDATED:
wfselect {%thisfile}
pagecreate(page=monthly) m !yr_start !yr_end
smpl @all

' Here we are creating the series (named like nf1617_12p, lm1819_09p, etc) that will hold the population adjustment for each AS group, and setting them all to zero for now. 

%sex_m = "m f"
%age_m = "16o 1617 1619 1819 2024 2554 2534 3544 4554 5564 65o" 

' create a list of yrs (pop adj for which we need to create)  to be used in series names, hence these are srtings
' NOTE: this list is used MANY times below to create/modify various series 
%yrs = "03 04 05 06 07 08 09" 
!yr_last = !yr_latest - 2000
for !y = 10 to !yr_last
	%yrs = %yrs + " " + @str(!y)
next

' initialize all series to zero. NOTE: this is LOTS of series -- 115 series for each pop adj year; for example, for pop adj through 2018, this is 1840 series (115 series x 16 yrs)
for %ser n l e r p
	for %p {%yrs}
		series  {%ser}16o_{%p}p = 0
		for %a {%age_m}
			for %s {%sex_m}
				series {%ser}{%s}{%a}_{%p}p = 0
			next
		next
	next
next
' All the pop adjustment series have been created and set to zero

' load the pop adjustment factors from a separate file, indicated at the start of the program (%popadj_factors_path)
' vectors in that file are stored in page 'monthly' and named popadjYEAR, such as popadj2016, popadj2017, popadj2018 etc
' also copy the string vector 'names' that contains the names of all concept-sex-age groups, such as n16o, nf1619, lm2024, rf65o, etc.

wfopen %popadj_factors_path				' Copy the raw BLS pop ajdustments from the file indicated in %popadj_factors_path (it was created with cps_popadj_factors_YEAR.prg) These are just verctors of numbers, they are not "assigned" to any series yet.
copy {%popadj_factors}::monthly\popadj* {%thisfile}::monthly\
copy {%popadj_factors}::monthly\names {%thisfile}::monthly\
wfclose {%popadj_factors}

wfselect {%thisfile}
pageselect monthly
smpl @all

!rows = @rows(names) 	' number of concept-sex-age groups; each year, we need to compute the adjustment factor for all of them.

' compute the adjustment factors for each series and each year 		
' this is where the vectors of numbers loaded from %popadj_factors_path are assigned to the corresponding series over the appropriate sample period.

%msg = "Compute the adjustment factors for each of the BLS annual population adjustments" 
logmsg {%msg}
logmsg

' This loop "wedges out" the BLS  pop adjustments over an appripriate time period.
' This applies BOTH to the annual Jan pop controls AND the decennial-Census pop controls for 2010 and 2020 Census. The early decennial Census adjustments (for 2000 and 1990 Census) are applied separately above.
'      According to BLS, the annual and decennial adjustments are not separable.  
'      Jan pop controls in special years (2012 and 2022 so far) also include the switch to the new decennial-Census base.
'      This is why, below, there are distinct loops for years starting in 2013 and 2023. Future loops should be added for future decenial census years. 
for !yr=!yr_first to !yr_latest
	for !r = 1 to !rows
		%y = @right(@str(!yr),2)
		%ser = names(!r) + "_" + %y + "p"			' NAME of the series to be modified
		if !yr < 2013 then									' determine start of the sample over which the series is to be modified; 2013 in the year when popadj from the 2010 decennial data became available
			!smpl_start = 2000
			else if !yr < 2023 then							' 2023 is the date when popadj from the 2020 decennial census are available 
					!smpl_start = 2010							
					else if !yr < 2033 then					' this assumes that the data from the next (2030) decennial census becomes available in 2032, and we need to re-base the adjustments to it first for year 2033
							!smpl_start = 2020 				' If not -- ADJUST THIS YEAR!
							endif									' ADD another *else if* statement here when we get past 2030 decennial census and need to change the sample period for the adjustment again!!!
					endif
		endif
		!smpl_end = !yr - 1									' determine end of the sample over which the series is to be modified
		%v = 	"popadj" + @str(!yr)						' NAME of the vector that holds the relevant popadj factors
		smpl {!smpl_start}m1 {!smpl_end}m12			' period over which to apply adjustments
		!m = @obssmpl										' number of months in the sample period (used in the adj formula below)
		If @left(%ser,1) = "n" then						' determine the scaling constant to be used in the adj formula below
			!d = 1000
		endif
		If @left(%ser,1) = "l" then				
			!d = 1000
		endif
		If @left(%ser,1) = "e" then				
			!d = 1000
		endif
		If @left(%ser,1) = "r" then				
			!d = 100
		endif
		If @left(%ser,1) = "p" then				
			!d = 100
		endif
		{%ser} =  1/!m * {%v}(!r)/!d + {%ser}(-1)	' the main adjustment formula. Distribute the total adjustment across time of the earlier historical data. 
																' The period over which to distsribute each adjustment varies by the kind of adjustment (annual, Census, etc.) 
																' The methodology for doing this follows the paper references at the start of the program.  
																' Note that this was done to the MONTHLY data.
		smpl @all
	next
next
' at this point can delete the vectors popadj2003 through popadjNNNN, if want to clean up the workfile (althought the vectors do not take up all that much space).


'******** Collapse monthly adjustments to quarterly *********
pageselect quarterly			
smpl @all

for %ser n l e r p
	for %p {%yrs}
		copy(c=a) monthly\{%ser}16o_{%p}p
		for %a {%age_m}
			for %s {%sex_m}
				copy(c=a) monthly\{%ser}{%s}{%a}_{%p}p  		' we convert monthly series to quarterly by averaging them (governed by c=a option for the copy command)
			next
		next
	next
next


'******************************************************************************
'****     NEW for 2022: Fetch all needed series from databanks here       *****
'******************************************************************************
%msg = "Start loading data from databanks"
logmsg {%msg}
logmsg

wfselect {%thisfile}

pagecreate(page="in_bka") a !yr_start !yr_end 		'bkdo1 annual data go here
pagecreate(page="in_bkq") q !yr_start !yr_end 		'bkdo1 quarterly data go here
pagecreate(page="in_dba") a !yr_start !yr_end 		'd bank annual data go here
pagecreate(page="in_cni") a !yr_start !yr_end 		'cnipopdata data go here
pagecreate(page="in_opb") a !yr_start !yr_end 		'op bank data go here
pagecreate(page="in_cps") a !yr_start !yr_end 		'cpso68... data go here

%msg = "Loading data from " + %bkdo1_path
logmsg {%msg}
logmsg

wfopen %bkdo1_path 'dbopen(type=aremos) %bkdo1_path	

wfselect {%thisfile}
pageselect in_bkq			
smpl @all

''AREA 1 - REDUNDANT (these are loaded in AREA 2)
'for %ser n l e													 
'	for %s m f
'		for %a 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 5564 6064 6569 65o 7074 75o
'			fetch {%ser}{%s}2529 {%ser}{%s}2534 {%ser}{%s}3034 {%ser}{%s}3539 {%ser}{%s}3544 {%ser}{%s}4044 {%ser}{%s}4549 {%ser}{%s}4554 {%ser}{%s}5054 {%ser}{%s}5559 {%ser}{%s}5564 {%ser}{%s}6064 {%ser}{%s}6569 {%ser}{%s}65o {%ser}{%s}7074 {%ser}{%s}75o
'		next
'	next
'next

'AREA 2
for %ser n l e r 
	copy {%bkdo1}::q\{%ser}16o {%thisfile}::in_bkq\*
	for %a 1617 1819 1619 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 16o
		for %s m f
			copy {%bkdo1}::q\{%ser}{%s}{%a} {%thisfile}::in_bkq\*
		next
	next
next

'AREA 7 - REDUNDANT
'for %ser l n r e 
'	fetch {%ser}16o.q
'	for %s m f
'		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 2534 3544 4554 5564 16o 1619			
'			fetch {%ser}{%s}{%a}.q
'		next
'	next
'next

'AREA 3
wfselect {%thisfile}
pageselect in_bka
smpl @all

for %ser rum ruf ru n16o lc e16o
	copy {%bkdo1}::a\{%ser} {%thisfile}::in_bka\*
next

for %ser l n e
	for %s m f
		copy {%bkdo1}::a\{%ser}{%s}1619 {%thisfile}::in_bka\*
	next
next

for %ser l n r e
	for %s m f 
		for %a 1617 1819 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 16o
			copy {%bkdo1}::a\{%ser}{%s}{%a} {%thisfile}::in_bka\*
		next
	next
next

'AREA 6 -- REDUNDANT (PV -- this loop loads series that have already been loaded in the loop immediatey above; plus %yrs is irrelevant here, not used in the series names)
'for %ser l n						
'	for %s m f
'		for %y {%yrs}			
'			fetch {%ser}{%s}5559 {%ser}{%s}6064 {%ser}{%s}6569 {%ser}{%s}7074
'		next
'	next
'next

wfclose %bkdo1

%msg = "Loading data from " + %cnipop_path
logmsg {%msg}
logmsg

'AREA 4
wfopen %cnipop_path 	

wfselect {%thisfile}
pageselect in_cni			
smpl @all

for %ser p l			' load raw CNI pop data from databank. These data are for l... and p... only, and exist for 2004 onwards.
	for %s m f
		for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
			copy {%cnipop}::a\{%ser}{%s}{%a} {%thisfile}::in_cni\* 		' Prior to this command NO series with these names (pm55, lf58 etc) existed in the file		
		next
	next
next

wfclose %cnipop 	

%msg = "Loading data from " + %dbank_path
logmsg {%msg}
logmsg

'AREA 5
wfopen %dbank_path				' D-bank is used here to pull population data (n... series). 

wfselect {%thisfile}
pageselect in_dba			
smpl @all

for %s m f 
	copy {%dbank}::a\n{%s}5559 {%thisfile}::in_dba\*
	copy {%dbank}::a\n{%s}6064 {%thisfile}::in_dba\*
	copy {%dbank}::a\n{%s}6569 {%thisfile}::in_dba\*
	copy {%dbank}::a\n{%s}7074 {%thisfile}::in_dba\*
next

wfclose %dbank 	

%msg = "Loading data from " + %opbank_path
logmsg {%msg}
logmsg

wfopen %opbank_path 	

wfselect {%thisfile}
pageselect in_opb
smpl @all

for %s m f 
	for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 5559 6064 6569 7074
		copy {%opbank}::a\n{%s}{%a} {%thisfile}::in_opb\*
	next
next

wfclose %opbank 	

%msg = "Loading data from " + %cpsobank_path
logmsg {%msg}
logmsg

'AREA 8
wfopen %cpsobank_path 		

wfselect {%thisfile}
pageselect in_cps
smpl @all

' *** load series from CPSO bank, renaming in the process.
%msg = "Load March CPS data from " + %cpsobank_path
logmsg {%msg}
logmsg

for %ser l n			
	for %a 1415 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 6061 6264 6569 7074 7579 8084 85o
		copy {%cpso}::a\{%ser}f{%a}nmnc18 {%thisfile}::in_cps\*
		copy {%cpso}::a\{%ser}f{%a}msnc18 {%thisfile}::in_cps\*
		copy {%cpso}::a\{%ser}f{%a}manc18 {%thisfile}::in_cps\*	
	next
next

for %ser l n			
	for %s m f 
		for %a 1415 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 6061 6264 6569 7074 7579 8084 85o 5564 6064 16o 55o 65o
			copy {%cpso}::a\{%ser}{%s}{%a} {%thisfile}::in_cps\*
			copy {%cpso}::a\{%ser}{%s}{%a}nm {%thisfile}::in_cps\*
			copy {%cpso}::a\{%ser}{%s}{%a}ms {%thisfile}::in_cps\*
			copy {%cpso}::a\{%ser}{%s}{%a}ma {%thisfile}::in_cps\*
		next
	next
	for %a 1415 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 6061 6264 6569 7074 7579 8084 85o
		for %m nm ms ma
			copy {%cpso}::a\{%ser}f{%a}{%m}c6u {%thisfile}::in_cps\*
			copy {%cpso}::a\{%ser}f{%a}{%m}nc6 {%thisfile}::in_cps\*
			copy {%cpso}::a\{%ser}f{%a}{%m}c6o {%thisfile}::in_cps\*		
		next
	next
next

' load the series later used for child presence indexes. 				
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054
	for %m nm ms ma
		copy {%cpso}::a\nf{%a}{%m}c6u3_ {%thisfile}::in_cps\*
		copy {%cpso}::a\nf{%a}{%m}c6u1 {%thisfile}::in_cps\*
		copy {%cpso}::a\nf{%a}{%m}c6u2 {%thisfile}::in_cps\*
	next
next

wfclose %cpso 	

%msg = "End loading data from databanks"
logmsg {%msg}
logmsg

wfselect {%thisfile}
pageselect quarterly 'back to the page that was selected before the inserted section
smpl @all
'******************************************************************************
'*****                   End of fetching from databanks                   *****
'******************************************************************************


' ***** split age groups 2534 3544 4554 5564 65o into smaller 5-yr groups.*****

' This split is done for population (n), labor force (l), employment (e), LFPRs (p), and un rates (r)  for each group.
' METHOD
' Note that, by definition, the following holds for LEVELs:
' n2534 = n2529 + n3034
' l2534 = l2529 + l3034
' e2534 = e2529 + e3034
' p2534 = p2529 * (n2529/n2534) + p3034 * (n3034/n3539)
' r2534 = r2529 * (l2529/l2534) + r3034 * (l3034/l2534)
' Therefore, for additive adjustment (for example, <name>_03p) the following must hold:
' (1) n2534_03p = n2529_03p + n3034_03p
' (2) l2534_03p = l2529_03p + l3034_03p
' (3) e2534_03p = e2529_03p + e3034_03p
' (4) p2534_03p = p2529_03p * (n2529/n2534) + p3034_03p * (n3034/n3539)
' (5) r2534_03p = r2529_03p * (l2529/l2534) + r3034_03p * (l3034/l2534)
' We know the values for n2534_03p, l2534_03p, e2534_03p, p2534_03p, r2534_03p.
' We need to find values for n2529_03p and n3034_03p -- and same for l, e, p, r.
' From the above equations, these cannot be determined exactly without additional assumptions.
' We assume: 
' (a) For n, l, e -- the additive adjustment for the group (e.g. n2534_03p) is distributed among the 5yr groups proportional to the share of each age.
' 	  That is:  n2534_03p = n2534_03p * (n2529/n2534) + n2534_03p * (n2529/n2534) = n2529_03p + n3034_03p
'				l2534_03p = l2534_03p * (l2529/l2534) + l2534_03p * (l2529/l2534) = l2529_03p + l3034_03p
' 				e2534_03p = e2534_03p * (e2529/e2534) + e2534_03p * (e2529/e2534) = e2529_03p + e3034_03p
' 	This assumption ensures that equations (1), (2), (3) above hold.
' (b) For p and r -- the additive adjustment for the group (e.g. p2534_03p) is eaxctly equal to the additive adjustment for each 5yr groups, i.e. LFPRs for all groups within the larger group change by the same amount.
' 	  That is:  p2534_03p = p2529_03p = p3034_03p
' 				r2534_03p = r2529_03p = r3034_03p
' 	 This asumption ensures that equations (4) and (5) above hold.
' NOTE:   both of these assumptions are likely to be contrary to reality. There is no reason why adjustments to components groups have to follow these assumed relationship to the adjustment for the larger group. 
' 			But without additional infromation, we can't know what the adjustments to component groups look like. 
' 			The assumptions abive are aimed at being as simple as possible while imposing the least amount of judgement.

' NOTE2 -- for LFPRs and RUs this method is different from what was used in Aremos code!!!


%msg = "For the BLS annual population adjustments, split age groups 2534 3544 4554 5564 65o into smaller 5-yr groups " 
logmsg {%msg}
logmsg

'AREA 1
for %ser n l e													 
	for %p {%yrs}
		for %s m f
			series {%ser}{%s}2529_{%p}p = {%ser}{%s}2534_{%p}p * (in_bkq\{%ser}{%s}2529 / in_bkq\{%ser}{%s}2534)
			series {%ser}{%s}3034_{%p}p = {%ser}{%s}2534_{%p}p * (in_bkq\{%ser}{%s}3034 / in_bkq\{%ser}{%s}2534)
			
			series {%ser}{%s}3539_{%p}p = {%ser}{%s}3544_{%p}p * (in_bkq\{%ser}{%s}3539 / in_bkq\{%ser}{%s}3544)
			series {%ser}{%s}4044_{%p}p = {%ser}{%s}3544_{%p}p * (in_bkq\{%ser}{%s}4044 / in_bkq\{%ser}{%s}3544)
			
			series {%ser}{%s}4549_{%p}p = {%ser}{%s}4554_{%p}p * (in_bkq\{%ser}{%s}4549 / in_bkq\{%ser}{%s}4554)
			series {%ser}{%s}5054_{%p}p = {%ser}{%s}4554_{%p}p * (in_bkq\{%ser}{%s}5054 / in_bkq\{%ser}{%s}4554)
			
			series {%ser}{%s}5559_{%p}p = {%ser}{%s}5564_{%p}p * (in_bkq\{%ser}{%s}5559 / in_bkq\{%ser}{%s}5564)
			series {%ser}{%s}6064_{%p}p = {%ser}{%s}5564_{%p}p * (in_bkq\{%ser}{%s}6064 / in_bkq\{%ser}{%s}5564)
			
			series {%ser}{%s}6569_{%p}p = {%ser}{%s}65o_{%p}p * (in_bkq\{%ser}{%s}6569 / in_bkq\{%ser}{%s}65o)
			series {%ser}{%s}7074_{%p}p = {%ser}{%s}65o_{%p}p * (in_bkq\{%ser}{%s}7074 / in_bkq\{%ser}{%s}65o)
			series {%ser}{%s}75o_{%p}p = {%ser}{%s}65o_{%p}p * (in_bkq\{%ser}{%s}75o / in_bkq\{%ser}{%s}65o)
		next
	next
next

for %ser r p				
	for %p {%yrs}
		for %s m f
			series {%ser}{%s}2529_{%p}p = {%ser}{%s}2534_{%p}p
			series {%ser}{%s}3034_{%p}p = {%ser}{%s}2534_{%p}p 
			
			series {%ser}{%s}3539_{%p}p = {%ser}{%s}3544_{%p}p
			series {%ser}{%s}4044_{%p}p = {%ser}{%s}3544_{%p}p
			
			series {%ser}{%s}4549_{%p}p = {%ser}{%s}4554_{%p}p 
			series {%ser}{%s}5054_{%p}p = {%ser}{%s}4554_{%p}p
			
			series {%ser}{%s}5559_{%p}p = {%ser}{%s}5564_{%p}p
			series {%ser}{%s}6064_{%p}p = {%ser}{%s}5564_{%p}p
			
			series {%ser}{%s}6569_{%p}p = {%ser}{%s}65o_{%p}p
			series {%ser}{%s}7074_{%p}p = {%ser}{%s}65o_{%p}p
			series {%ser}{%s}75o_{%p}p = {%ser}{%s}65o_{%p}p 
		next
	next
next

' NOTE:  BKDO1 has quarterly values for only a sub-sample (e.g. 1976 to 2018, the end year changes as we get more data); outside this sub-sample the values are NAs, so they produce NAs for all the above series.
' Recode these NAs to zeros -- this assumes the adjustments we know nothing about are zero. This assumption may not be exactly correct, but it ensures we have the longest possible series for adjusted data.
for %ser n l e r p
	for %p {%yrs}
		for %s m f
			for %a 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
				{%ser}{%s}{%a}_{%p}p = @nan({%ser}{%s}{%a}_{%p}p, 0)
			next
		next
	next
next


'******** Collapse quarterly adjustments to annual *********

pageselect annual
smpl @all

for %ser n l e r p						' Transforming quarterly adjustment series into annual ones, by taking an average (governed by c=a option in the copy command)
	for %p {%yrs}
		copy(c=a) quarterly\{%ser}16o_{%p}p
		for %a 16o 1619 2024 2534 3544 4554 5564 65o 1617 1819 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
			for %s m f
				copy(c=a) quarterly\{%ser}{%s}{%a}_{%p}p
			next
		next
	next
next



'******** Create Quarterly AND Annual aggregate multiplicative adjustments by age & sex (1990 Census, 2000 Census, 1994 CPS methodological adjustments) 		*********
'******** Create Quarterly AND Annual  aggregate additive adjustments by age & sex (2003 through the latest annual population adjustments)            				*********
'**** In everything above we created the adjustment series to be applied -- separate adjustment series for each adjustment (one adjustment series for each Census, and one for each yeae of the annaul pop adjustment from 2003 to the latest year).
'**** Here we combine these various asjustmetn series into a simple multiplicative adjustment and a single additive adjustment for each concept series. 
'**** There are additive adjustment series for the annual pop adjustment -- they have names ending  in ..._YRp, such as nm2024_04p. 
'**** There are also additive and multiplicative adjustment series for 1990 Census, 2000 census, and 1994 method changes -- they have names ending in ..._00c, ..._90c, ..._94m_m
'**** Once all adjustment series are combined, for each concept series, there will be only two adjustment series -- one multiplicative, one additive. Example: for n16o series, we make two adjustment series -- n16o_adjm (the multiplicative adjustment) and n16o_adja (the additive adjustment). 
'**** Later in the code these adjustment are actually applied to the raw series from BLS.
'**** Note that, to make quaretrely AND annual adjustment series, we simply loop through the 'quarterly' and 'annual' pages. This method assumes  that all these formulas are EXACTLY  identical to the quarterly and annual frequencies.

%msg = "Combine all multiplicative adjustments for each series into a single multiplicative adjustmsent for the series." 
logmsg {%msg}
%msg = "Combine all additive adjustments for each series into a single additive adjustmsent for the series." 
logmsg {%msg}
logmsg

for %pages quarterly annual
	pageselect {%pages}
	smpl @all

	' modify the string list %yrs to remove first element 
	%yrs2 = @wdrop(%yrs, "03")

	' **separate loop for n **
	' 16o
	series n16o_adjm = n16o_90c * n16o_00c
	series n16o_adja = n16o_03p
	for %p {%yrs2} 
		n16o_adja = n16o_adja + n16o_{%p}p
	next
	' n for all other ages
	for %s m f 
		for %a 1617 1819 1619 2024 2529 3034 3539 4044 4549 5054 2534 3544 4554 5559 6064 5564 6569 7074 65o 75o 16o 
			series n{%s}{%a}_adjm = n{%s}{%a}_90c * n{%s}{%a}_00c
			series n{%s}{%a}_adja = n{%s}{%a}_03p
			for %p {%yrs2} 
				n{%s}{%a}_adja = n{%s}{%a}_adja + n{%s}{%a}_{%p}p
			next
		next
	next

	' ** loops for l, r, e; formulas differ somewhat by age **
	for %ser l r e  
		for %s m f 
			for %a 1617 1819 1619  
				series {%ser}{%s}{%a}_adjm = {%ser}{%s}1619_94m_m * {%ser}{%s}{%a}_90c * {%ser}{%s}{%a}_00c
				series {%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_03p
				for %p {%yrs2} 
					{%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_adja + {%ser}{%s}{%a}_{%p}p
				next
			next
		next
	next
 
	for %ser l r e  
		for %s m f 
			for %a 2024 16o  
				series {%ser}{%s}{%a}_adjm = {%ser}{%s}{%a}_94m_m * {%ser}{%s}{%a}_90c * {%ser}{%s}{%a}_00c
				series {%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_03p
				for %p {%yrs2} 
					{%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_adja + {%ser}{%s}{%a}_{%p}p
				next
			next
		next
	next

	for %ser l r e  
		for %s m f 
			for %a 2529 3034 3539 4044 4549 5054 2534 3544 4554  
				series {%ser}{%s}{%a}_adjm = {%ser}{%s}2554_94m_m * {%ser}{%s}{%a}_90c * {%ser}{%s}{%a}_00c
				series {%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_03p
				for %p {%yrs2} 
					{%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_adja + {%ser}{%s}{%a}_{%p}p
				next
			next
		next
	next

	for %ser l r e  
		for %s m f 
			for %a 5559 6064 5564   
				series {%ser}{%s}{%a}_adjm = {%ser}{%s}5564_94m_m * {%ser}{%s}{%a}_90c * {%ser}{%s}{%a}_00c
				series {%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_03p
				for %p {%yrs2} 
					{%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_adja + {%ser}{%s}{%a}_{%p}p
				next
			next
		next
	next

	for %ser l r e  
		for %s m f 
			for %a 6569 7074 65o 75o   
				series {%ser}{%s}{%a}_adjm = {%ser}{%s}65o_94m_m * {%ser}{%s}{%a}_90c * {%ser}{%s}{%a}_00c
				series {%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_03p
				for %p {%yrs2} 
					{%ser}{%s}{%a}_adja = {%ser}{%s}{%a}_adja + {%ser}{%s}{%a}_{%p}p
				next
			next
		next
	next

	for %ser l r e  
		series {%ser}16o_adjm = {%ser}16o_94m_m * {%ser}16o_90c * {%ser}16o_00c
		series {%ser}16o_adja = {%ser}16o_03p
		for %p {%yrs2} 
			{%ser}16o_adja = {%ser}16o_adja + {%ser}16o_{%p}p
		next
	next
next

'**** At this point we have created the adjustment series -- ..._adja (additive) and ..._adjm (multiplicative) -- for each concept series and for all frequencies (m, q, a). 
'**** Now it is time to apply the adjustments to the underlying data.
 
 
'******** Create QUARTERLY adjusted values for labor force, cni population, unemployement rates, employment, *********
'******** by incorporating the multiplicative and additive adjustments for each age/sex group                *********

%msg = "Create QUARTERLY adjusted values for labor force, cni population, unemployement rates, employment by incorporating the multiplicative and additive adjustments for each age/sex group." 
logmsg {%msg}
logmsg

pageselect quarterly 
smpl @all

' created adjusted series, name_adj, by applying the adjustment to series pulled from BKDO1
' NOTE: series in BKDO1 have NAs after ther last historical observation. Since this loop uses these series, the resulting series name_adj will also have NAs after the last historical observation. This is appropriate, since we are constructing the adjusted HISTORICAL values.
'AREA 2
for %ser n l e r 
	copy in_bkq\{%ser}16o quarterly\{%ser}16o
	series  {%ser}16o_adj = ({%ser}16o * {%ser}16o_adjm) + {%ser}16o_adja
	%text = "Computed by applying adjustment factors to series " +  %ser + "16o from BKDO1."
	{%ser}16o_adj.label(r) {%text}
	'make groups for comparison, and check series that holds the difference
	group g_{%ser}16o {%ser}16o_adj {%ser}16o
	series ck_{%ser}16o = {%ser}16o_adj - {%ser}16o
	for %a 1617 1819 1619 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 16o
		for %s m f
			copy in_bkq\{%ser}{%s}{%a} quarterly\{%ser}{%s}{%a}
			series {%ser}{%s}{%a}_adj = ({%ser}{%s}{%a} * {%ser}{%s}{%a}_adjm) + {%ser}{%s}{%a}_adja
			%text = "Computed by applying adjustment factors to series " +  %ser + %s + %a + " from BKDO1."
			{%ser}{%s}{%a}_adj.label(r) {%text} 
			'make groups for comparison, and check series that holds the difference
			group g_{%ser}{%s}{%a} {%ser}{%s}{%a}_adj {%ser}{%s}{%a}
			series ck_{%ser}{%s}{%a} = {%ser}{%s}{%a}_adj - {%ser}{%s}{%a}
		next
	next
next

' Check for consistency -- do 16o adjusted series (n16o_adj, l16o_adj, etc) equal to the sum of 16o series by sex? 
' !!!!! KEEP this in the code (even though it is commented out). In some cases we might want to run these tests again in future years. !!!!!

'series test_n = nm16o_adj + nf16o_adj - n16o_adj
'series test_l = lm16o_adj + lf16o_adj - l16o_adj
'series test_e = em16o_adj + ef16o_adj - e16o_adj
'series test_r = rm16o_adj *(lm16o_adj/l16o_adj) + rf16o_adj*(lf16o_adj/l16o_adj) - r16o_adj

'group n_aggr n16o_adj nm16o_adj nf16o_adj test_n
'group l_aggr l16o_adj lm16o_adj lf16o_adj test_l
'group e_aggr e16o_adj em16o_adj ef16o_adj test_e
'group r_aggr r16o_adj rm16o_adj rf16o_adj test_r

' Ran for TR19 data on 6-12-2020
' Conclusion: NO, the values are not consistent. Example: 2018Q3 un rates rm16o_adj = 3.8, rf_16o_adj = 3.8, but r16o_adj = 3.83333 . There are MANY other cases.
' Therefore, we will compute another version of all 16o series (n16o, nm16o, nf16o -- and the same  for l, e, r, p) by summing up the age components parts. Names these series ..._adjs (*s* for 'sum')

' compute an alternative version for all 16o_adj series (*m16o, *f16o, *16o for *=n, l, e, r) by summing up components age groups. Name these series *16o_adjs (for 'adjusted sum'). Include explanation in the Label.

smpl @all 
for %ser n l e
	for %s m f 
		smpl @first 1976q2
		series {%ser}{%s}16o_adjs = {%ser}{%s}16o_adj
		smpl 1976q3 1980q4
		series {%ser}{%s}16o_adjs = {%ser}{%s}1617_adj _
													+ {%ser}{%s}1819_adj _
													+ {%ser}{%s}2024_adj _
													+ {%ser}{%s}2529_adj _
													+ {%ser}{%s}3034_adj _
													+ {%ser}{%s}3539_adj _
													+ {%ser}{%s}4044_adj _
													+ {%ser}{%s}4549_adj _
													+ {%ser}{%s}5054_adj _
													+ {%ser}{%s}5559_adj _
													+ {%ser}{%s}6064_adj _
													+ {%ser}{%s}65o_adj
		smpl 1981q1 @last
		series {%ser}{%s}16o_adjs = {%ser}{%s}1617_adj _
													+ {%ser}{%s}1819_adj _
													+ {%ser}{%s}2024_adj _
													+ {%ser}{%s}2529_adj _
													+ {%ser}{%s}3034_adj _
													+ {%ser}{%s}3539_adj _
													+ {%ser}{%s}4044_adj _
													+ {%ser}{%s}4549_adj _
													+ {%ser}{%s}5054_adj _
													+ {%ser}{%s}5559_adj _
													+ {%ser}{%s}6064_adj _
													+ {%ser}{%s}6569_adj _
													+ {%ser}{%s}7074_adj _
													+ {%ser}{%s}75o_adj 
		%text = "Computed by summing up the adjusted series " + %ser + %s + "1617_adj through " + %ser + %s+ "75o_adj."
		{%ser}{%s}16o_adjs.label(r) {%text}
		
	next
	smpl @all
	series {%ser}16o_adjs = {%ser}m16o_adjs + {%ser}f16o_adjs
	%text = "Computed by summing up the adjusted series " + %ser + "m16o_adjs and " + %ser + "f16o_adjs."
	{%ser}16o_adjs.label(r) {%text}
next

smpl @all
for %s m f 
	smpl @first 1976q2
	series r{%s}16o_adjs = r{%s}16o_adj
	smpl 1976q3 1999q4		' using sum through 65o b/c rf75o in BKDO1 has several NA obs in the 1980s and 1990s.
	series r{%s}16o_adjs = (r{%s}1617_adj * l{%s}1617_adj _
										+ r{%s}1819_adj * l{%s}1819_adj _
										+ r{%s}2024_adj * l{%s}2024_adj _
										+ r{%s}2529_adj * l{%s}2529_adj _
										+ r{%s}3034_adj * l{%s}3034_adj _
										+ r{%s}3539_adj * l{%s}3539_adj _
										+ r{%s}4044_adj * l{%s}4044_adj _
										+ r{%s}4549_adj * l{%s}4549_adj _
										+ r{%s}5054_adj * l{%s}5054_adj _
										+ r{%s}5559_adj * l{%s}5559_adj _
										+ r{%s}6064_adj * l{%s}6064_adj _
										+ r{%s}65o_adj * l{%s}65o_adj) / l{%s}16o_adjs
	smpl 2000q1 @last		' using sum through 75o here
	series r{%s}16o_adjs = (r{%s}1617_adj * l{%s}1617_adj _
										+ r{%s}1819_adj * l{%s}1819_adj _
										+ r{%s}2024_adj * l{%s}2024_adj _
										+ r{%s}2529_adj * l{%s}2529_adj _
										+ r{%s}3034_adj * l{%s}3034_adj _
										+ r{%s}3539_adj * l{%s}3539_adj _
										+ r{%s}4044_adj * l{%s}4044_adj _
										+ r{%s}4549_adj * l{%s}4549_adj _
										+ r{%s}5054_adj * l{%s}5054_adj _
										+ r{%s}5559_adj * l{%s}5559_adj _
										+ r{%s}6064_adj * l{%s}6064_adj _
										+ r{%s}6569_adj * l{%s}6569_adj _
										+ r{%s}7074_adj * l{%s}7074_adj _
										+ r{%s}75o_adj * l{%s}75o_adj) / l{%s}16o_adjs
	smpl @all
	%text1 = "Computed as weighted average of series r" + %s + "1617_adj through r" + %s + "75o_adj."
	%text2 = "The weights are the ratios of l" + %s + "{age}_adj to l" + %s + "16o_adjs (note _adjS for l" + %s + "16o)."
	r{%s}16o_adjs.label(r) {%text1}
	r{%s}16o_adjs.label(r) {%text2}
next

series r16o_adjs = (rm16o_adjs * lm16o_adjs + rf16o_adjs * lf16o_adjs) / l16o_adjs
%text1 = "Computed as weighted average of rm16o_adjs and rf16o_adjs."
%text2 = "The weights are the ratios of l{sex}16o_adjs to l16o_adjs."  
r16o_adjs.label(r) {%text1}
r16o_adjs.label(r) {%text2}

' Here we create adjusted LFPR series by COMPUTING them as a ratio of adjusted l... to adjusted n..., and NOT by applying adjustments to underlyign series.
for %a 16o 1617 1819 1619 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o
	for %s m f 
		series p{%s}{%a}_adj = l{%s}{%a}_adj / n{%s}{%a}_adj
		%text = "Computed as the ratio of adjusted series l" + %s + %a + "_adj to n" + %s + %a+ "_adj."
		p{%s}{%a}_adj.label(r) {%text}
		'make groups for comparison and the check series to hold the difference
		'group g_p{%s}{%a} p{%s}{%a}_adj p{%s}{%a}
		'series ck_p{%s}{%a} = p{%s}{%a}_adj - p{%s}{%a}
	next
next
series p16o_adj = l16o_adj / n16o_adj
%text = "Computed as the ratio of adjusted series l16o_adj to n16o_adj."
p16o_adj.label(r) {%text}
'make groups for comparison and the check series to hold the difference
'group g_p16o p16o_adj p16o
'series ck_p16o = p16o_adj - p16o

' based on the alternative series _adjs for 16o group
series pm16o_adjs = lm16o_adjs / nm16o_adjs
%text = "Computed as the ratio of alternative adjusted series lm16o_adjs to nm16o_adjs. (Note *s* in _adjS.)"
pm16o_adjs.label(r) {%text}

series pf16o_adjs = lf16o_adjs / nf16o_adjs
%text = "Computed as the ratio of alternative adjusted series lf16o_adjs to nf16o_adjs. (Note *s* in _adjS.)"
pf16o_adjs.label(r) {%text}

series p16o_adjs = l16o_adjs / n16o_adjs
%text = "Computed as the ratio of alternative adjusted series l16o_adjs to n16o_adjs. (Note *s* in _adjS.)"
p16o_adjs.label(r) {%text}


' !!! KEEP this in the code even though it is commented out. We might want to use it as diagnostic in the future.
' Compare ...16o_adj and ...16o_adjs series
'for %ser n l e r p
'	series {%ser}16o_ck = {%ser}16o_adj - {%ser}16o_adjs
'	series {%ser}f16o_ck = {%ser}f16o_adj - {%ser}f16o_adjs
'	series {%ser}m16o_ck = {%ser}m16o_adj - {%ser}m16o_adjs
'next
' Ran for TR19 data on 6-12-2020. Conclusion: the checks are NOT zero. 


'******** Create ANNUAL adjusted values for labor force, cni population, unemployement rates, employment, 
'******** by incorporating the multiplicative and additive adjustments for each age/sex group   
'***** Here we are applying the annaul adjustment series to the underlying annual data (NOT aggregating up the quarterly adjusted series computed above). 

%msg = "Create ANNUAL adjusted values for labor force, cni population, unemployement rates, employment by incorporating the multiplicative and additive adjustments for each age/sex group." 
logmsg {%msg}
logmsg

pageselect annual

'AREA 3

' first we need to create some annual series from components

series lm16o  = in_bka\lm1619 + in_bka\lm2024 + in_bka\lm2534 + in_bka\lm3544 + in_bka\lm4554 + in_bka\lm5564 + in_bka\lm65o
series lf16o  = in_bka\lf1619 + in_bka\lf2024 + in_bka\lf2534 + in_bka\lf3544 + in_bka\lf4554 + in_bka\lf5564 + in_bka\lf65o

series rm1619 = ((in_bka\rm1617*in_bka\lm1617)+(in_bka\rm1819*in_bka\lm1819))/in_bka\lm1619
series rf1619 = ((in_bka\rf1617*in_bka\lf1617)+(in_bka\rf1819*in_bka\lf1819))/in_bka\lf1619

series nm16o = in_bka\nm16o
series nf16o = in_bka\nf16o

series rm16o = in_bka\rum
series rf16o = in_bka\ruf

series r16o  = in_bka\ru
series n16o  = in_bka\n16o
series l16o  = in_bka\lc

' Now we actually apply the adjustments

for %ser l n r e
	for %s m f 
		for %a 1617 1819 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 16o
			series {%ser}{%s}{%a}_aadj = (in_bka\{%ser}{%s}{%a} * {%ser}{%s}{%a}_adjm) + {%ser}{%s}{%a}_adja
			%text = "Computed by applying adjustment factors to series " +  %ser + %s + %a + " from BKDO1."
			{%ser}{%s}{%a}_aadj.label(r) {%text} 
			'make groups for comparison and the check series that holds the difference
			group g_{%ser}{%s}{%a} {%ser}{%s}{%a}_aadj in_bka\{%ser}{%s}{%a}
			series ck_{%ser}{%s}{%a} = {%ser}{%s}{%a}_aadj - in_bka\{%ser}{%s}{%a}
		next
	next
next

series nm16o_aadj = (nm16o * nm16o_adjm) + nm16o_adja
series nf16o_aadj = (nf16o * nf16o_adjm) + nf16o_adja
series n16o_aadj  = (n16o  * n16o_adjm)  + n16o_adja

series lm16o_aadj = (lm16o * lm16o_adjm) + lm16o_adja
series lf16o_aadj = (lf16o * lf16o_adjm) + lf16o_adja
series l16o_aadj  = (l16o * l16o_adjm)  + l16o_adja


for %ser nm16o nf16o n16o lm16o lf16o l16o
	%text = "Computed by applying adjustment factors to series " +  %ser + "."
	{%ser}_aadj.label(r) {%text}
next

series em16o_aadj = (in_bka\em16o * em16o_adjm) + em16o_adja
series ef16o_aadj = (in_bka\ef16o * ef16o_adjm) + ef16o_adja
series e16o_aadj  = (in_bka\e16o * e16o_adjm)  + e16o_adja

for %ser em16o ef16o e16o
	%text = "Computed by applying adjustment factors to series " +  %ser + "from BKDO1."
	{%ser}_aadj.label(r) {%text}
next

series r16o_aadj = (rm16o_aadj * lm16o_aadj + rf16o_aadj * lf16o_aadj) / l16o_aadj
%text1 = "Computed as weighted average of rm16o_aadj and rf16o_aadj."
%text2 = "The weights are the ratios of l{sex}16o_aadj to l16o_aadj."  
r16o_aadj.label(r) {%text1}
r16o_aadj.label(r) {%text2}

for %ser l n e	' these require series from BKDO1 (I added e here, which was not in Aremos)
	for %s m f
		series {%ser}{%s}1619_aadj = (in_bka\{%ser}{%s}1619 * {%ser}{%s}1619_adjm) + {%ser}{%s}1619_adja
	next
next

for %ser r 		' these series already in the workfile (I moved e from here to above)
	for %s m f
		series {%ser}{%s}1619_aadj = ({%ser}{%s}1619 * {%ser}{%s}1619_adjm) + {%ser}{%s}1619_adja
	next
next

'make groups for comparison and the check series to hold the difference
for %ser n l r
	group g_{%ser}16o {%ser}16o_aadj {%ser}16o
	series ck_{%ser}16o = {%ser}16o_aadj - {%ser}16o
	for %s m f
		group g_{%ser}{%s}16o {%ser}{%s}16o_aadj {%ser}{%s}16o
		series ck_{%ser}{%s}16o = {%ser}{%s}16o_aadj - {%ser}{%s}16o
	next
next
group g_e16o e16o_aadj in_bka\e16o
group g_em16o em16o_aadj in_bka\em16o
group g_ef16o ef16o_aadj in_bka\ef16o

series ck_e16o = e16o_aadj - in_bka\e16o
series ck_em16o = em16o_aadj  -in_bka\em16o
series ck_ef16o = ef16o_aadj - in_bka\ef16o

for %s m f
	group g_r{%s}1619 r{%s}1619_aadj r{%s}1619
	series ck_r{%s}1619 = r{%s}1619_aadj - r{%s}1619
next

for %ser n l e 
	for %s m f
		group g_{%ser}{%s}1619 {%ser}{%s}1619_aadj in_bka\{%ser}{%s}1619
		series ck_{%ser}{%s}1619 = {%ser}{%s}1619_aadj - in_bka\{%ser}{%s}1619
	next
next
group g_rm1619 rm1619_aadj rm1619
series ck_rm1619 = rm1619_aadj - rm1619

group g_rf1619 rf1619_aadj rf1619
series ck_rf1619 = rf1619_aadj - rf1619

' NOT clear what thos loop is supposed to do. It is fetching series, but NO BANK is open at this point in the program; still, EViews runs this without an error.
' I tested it -- EViews pulls these series from cpso68122 bank; don't know why, possibly because this is the last databank that I opened (even though i opened it days ago).
' I checked the original program (dates 3/16/2021, long before Sven moved all fetching commands into one place) -- in that version, this command  was fetching values FROM BKDO1
' I am changing this loop to copy the series from page 'in_bka' (i.e. equivalent to loading them from BKDO1)
' It is likely that when this program was run last year to create blsadj22.wf1 these series were erroneously fetched from CPSO68** bank instead of BKDO1 bank. 
' PV 5-30-2023
'for %a 5559 6064 6569 7074			' need these series for later calculations
'	for %s m f
'		fetch l{%s}{%a}.a
'	next
'next
for %a 5559 6064 6569 7074			' need these series for later calculations
	for %s m f
		copy in_bka\l{%s}{%a} annual\*
	next
next
pageselect annual

' compute an alternative version for all 16o_aadj series (*m16o, *f16o, *16o for *=n, l, e, r) by summing up components age groups. Name these series *16o_aadjs (for 'adjusted sum').
smpl @all 
for %ser n l e
	for %s m f 
		smpl @first 1976
		series {%ser}{%s}16o_aadjs = {%ser}{%s}16o_aadj
		smpl 1977 1980
		series {%ser}{%s}16o_aadjs = {%ser}{%s}1617_aadj _
													+ {%ser}{%s}1819_aadj _
													+ {%ser}{%s}2024_aadj _
													+ {%ser}{%s}2529_aadj _
													+ {%ser}{%s}3034_aadj _
													+ {%ser}{%s}3539_aadj _
													+ {%ser}{%s}4044_aadj _
													+ {%ser}{%s}4549_aadj _
													+ {%ser}{%s}5054_aadj _
													+ {%ser}{%s}5559_aadj _
													+ {%ser}{%s}6064_aadj _
													+ {%ser}{%s}65o_aadj
		smpl 1981 @last
		series {%ser}{%s}16o_aadjs = {%ser}{%s}1617_aadj _
													+ {%ser}{%s}1819_aadj _
													+ {%ser}{%s}2024_aadj _
													+ {%ser}{%s}2529_aadj _
													+ {%ser}{%s}3034_aadj _
													+ {%ser}{%s}3539_aadj _
													+ {%ser}{%s}4044_aadj _
													+ {%ser}{%s}4549_aadj _
													+ {%ser}{%s}5054_aadj _
													+ {%ser}{%s}5559_aadj _
													+ {%ser}{%s}6064_aadj _
													+ {%ser}{%s}6569_aadj _
													+ {%ser}{%s}7074_aadj _
													+ {%ser}{%s}75o_aadj 
		%text = "Computed by summing up the adjusted series " + %ser + %s + "1617_aadj through " + %ser + %s+ "75o_aadj."
		{%ser}{%s}16o_aadjs.label(r) {%text}
		
	next
	smpl @all
	series {%ser}16o_aadjs = {%ser}m16o_aadjs + {%ser}f16o_aadjs
	%text = "Computed by summing up the adjusted series " + %ser + "m16o_aadjs and " + %ser + "f16o_aadjs."
	{%ser}16o_aadjs.label(r) {%text}
next

smpl @all
for %s m f 
	smpl @first 1976
	series r{%s}16o_aadjs = r{%s}16o_aadj
	smpl 1977 1999		' using sum through 65o b/c rf75o in BKDO1 has several NA obs in the 1980s and 1990s.
	series r{%s}16o_aadjs = (r{%s}1617_aadj * l{%s}1617_aadj _
										+ r{%s}1819_aadj * l{%s}1819_aadj _
										+ r{%s}2024_aadj * l{%s}2024_aadj _
										+ r{%s}2529_aadj * l{%s}2529_aadj _
										+ r{%s}3034_aadj * l{%s}3034_aadj _
										+ r{%s}3539_aadj * l{%s}3539_aadj _
										+ r{%s}4044_aadj * l{%s}4044_aadj _
										+ r{%s}4549_aadj * l{%s}4549_aadj _
										+ r{%s}5054_aadj * l{%s}5054_aadj _
										+ r{%s}5559_aadj * l{%s}5559_aadj _
										+ r{%s}6064_aadj * l{%s}6064_aadj _
										+ r{%s}65o_aadj * l{%s}65o_aadj) / l{%s}16o_aadjs
	smpl 2000 @last		' using sum though 75o here
	series r{%s}16o_aadjs = (r{%s}1617_aadj * l{%s}1617_aadj _
										+ r{%s}1819_aadj * l{%s}1819_aadj _
										+ r{%s}2024_aadj * l{%s}2024_aadj _
										+ r{%s}2529_aadj * l{%s}2529_aadj _
										+ r{%s}3034_aadj * l{%s}3034_aadj _
										+ r{%s}3539_aadj * l{%s}3539_aadj _
										+ r{%s}4044_aadj * l{%s}4044_aadj _
										+ r{%s}4549_aadj * l{%s}4549_aadj _
										+ r{%s}5054_aadj * l{%s}5054_aadj _
										+ r{%s}5559_aadj * l{%s}5559_aadj _
										+ r{%s}6064_aadj * l{%s}6064_aadj _
										+ r{%s}6569_aadj * l{%s}6569_aadj _
										+ r{%s}7074_aadj * l{%s}7074_aadj _
										+ r{%s}75o_aadj * l{%s}75o_aadj) / l{%s}16o_aadjs
	smpl @all
	%text1 = "Computed as weighted average of series r" + %s + "1617_aadj through r" + %s + "75o_aadj."
	%text2 = "The weights are the ratios of l" + %s + "{age}_aadj to l" + %s + "16o_aadjs (note _adjS for l" + %s + "16o)."
	r{%s}16o_aadjs.label(r) {%text1}
	r{%s}16o_aadjs.label(r) {%text2}
next

series r16o_aadjs = (rm16o_aadjs * lm16o_aadjs + rf16o_aadjs * lf16o_aadjs) / l16o_aadjs
%text1 = "Computed as weighted average of rm16o_aadjs and rf16o_aadjs."
%text2 = "The weights are the ratios of l{sex}16o_aadjs to l16o_aadjs."  
r16o_aadjs.label(r) {%text1}
r16o_aadjs.label(r) {%text2}

' Here we create the adjusted LFPR series. These are COMPUTED as the ratio of adjusted l... to adjusted n..., and NOT by applying adjustments to the underlying series.
for %a 1617 1819 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 1619 16o
	for %s m f 
		series p{%s}{%a}_aadj = l{%s}{%a}_aadj / n{%s}{%a}_aadj
		%text = "Computed as the ratio of adjusted series l" + %s + %a + "_aadj to n" + %s + %a+ "_aadj."
		p{%s}{%a}_aadj.label(r) {%text}
		'make groups for comparison and the check series to hold the difference
		'group g_p{%s}{%a} p{%s}{%a}_adj p{%s}{%a}
		'series ck_p{%s}{%a} = p{%s}{%a}_adj - p{%s}{%a}
	next
next
series p16o_aadj = l16o_aadj / n16o_aadj
%text = "Computed as the ratio of adjusted series l16o_aadj to n16o_aadj."
p16o_aadj.label(r) {%text}
'make groups for comparison and the check series to hold the difference
'group g_p16o p16o_adj p16o
'series ck_p16o = p16o_adj - p16o

' based on the alternatoive series _aadjs for 16o group
series pm16o_aadjs = lm16o_aadjs / nm16o_aadjs
%text = "Computed as the ratio of alternative adjusted series lm16o_aadjs to nm16o_aadjs. (Note *s* in _aadjS.)"
pm16o_aadjs.label(r) {%text}

series pf16o_aadjs = lf16o_aadjs / nf16o_aadjs
%text = "Computed as the ratio of alternative adjusted series lf16o_aadjs to nf16o_aadjs. (Note *s* in _aadjS.)"
pf16o_aadjs.label(r) {%text}

series p16o_aadjs = l16o_aadjs / n16o_aadjs
%text = "Computed as the ratio of alternative adjusted series l16o_aadjs to n16o_aadjs. (Note *s* in _aadjS.)"
p16o_aadjs.label(r) {%text}


' KEEP this in the code even though it is commented out; we might need it for diagnotic in future years.
' Compare ...16o_aadj and ...16o_aadjs series
'for %ser n l e r p
'	series {%ser}16o_ck = {%ser}16o_aadj - {%ser}16o_aadjs
'	series {%ser}f16o_ck = {%ser}f16o_aadj - {%ser}f16o_aadjs
'	series {%ser}m16o_ck = {%ser}m16o_aadj - {%ser}m16o_aadjs
'next

' Ran for TR19 data on 6-12-2020. Conclusion: the checks are not zero. 


' ***** Create adjustment series for n and l for SYOA the adjustment for 5yr age groups 								*****			
' ***** Then use them to craete the adjustments for LFPRs SYOA and the adjusted series for LFPRs SYOA 		*****
' Note that this is done for ANNUAL frequency  because we use data from CNIPIPDATA bank, which is annual only

%msg = "Create adjustments for SYOA series from adjustment series for age group (annual only, since SYOA data is annual)." 
logmsg {%msg}
logmsg

pageselect annual

'AREA 4
for %ser p l			' load raw CNI pop data from databank. These data are for l... and p... only, and exist for 2004 onwards.
	for %s m f
		for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
			copy in_cni\{%ser}{%s}{%a} annual\{%ser}{%s}{%a} ' Prior to this command NO series with these names (pm55, lf58 etc) existed in the file
		next
	next
next

' Create SYOA population (n...)  series and extend SYOA l.. series further into the past beyong 2004.
' Compute as follows:
' example:  nm55 = nm55(from op-bank) * [nm5559(from d-bank) / nm559(from op-bank)] 		-- this basically transaltes nm55 from op-bank (SSA area pop concept) into nm55 CPS concept by adjusting by the ratio of nm5559 CPS concept (d-bank) to SSA-area-pop concept (op-bank).
' 		then lm55 = pm55(CNIpop) * nm55 from above formula
' Note: prior to this computation, no SYOA series for pop (nm55, nf56, etc) existed in the file
' These are used below, when computing SYOA additive adjustments for l... and n... .

'AREA 5
' NOTE: these loops REPLACE values for l{s}55 through l{s}74 that were loaded from cnipopdata earlier. It extends the l... series further into the past than the period covered by cnipopdata. 
for %s m f 
	for %a 55 56 57 58 59
		series n{%s}{%a} = in_dba\n{%s}5559 * (in_opb\n{%s}{%a} / in_opb\n{%s}5559)
		l{%s}{%a} = p{%s}{%a} * n{%s}{%a}
'		series l{%s}{%a}_c = p{%s}{%a} * n{%s}{%a} 
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
 
	for %a 60 61 62 63 64
		series n{%s}{%a} = in_dba\n{%s}6064 * (in_opb\n{%s}{%a} / in_opb\n{%s}6064)
		l{%s}{%a} = p{%s}{%a} * n{%s}{%a}
'		series l{%s}{%a}_c = p{%s}{%a} * n{%s}{%a} 
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
	
	for %a 65 66 67 68 69
		series n{%s}{%a} = in_dba\n{%s}6569 * (in_opb\n{%s}{%a} / in_opb\n{%s}6569)
		l{%s}{%a} = p{%s}{%a} * n{%s}{%a}
'		series l{%s}{%a}_c = p{%s}{%a} * n{%s}{%a} 
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
	
	for %a 70 71 72 73 74
		series n{%s}{%a} = in_dba\n{%s}7074 * (in_opb\n{%s}{%a} / in_opb\n{%s}7074)
		l{%s}{%a} = p{%s}{%a} * n{%s}{%a}
'		series l{%s}{%a}_c = p{%s}{%a} * n{%s}{%a} 
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
next

' compare single year of age L... series loaded from cnipop data to computed above
'for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
'	group lm{%a}_gr lm{%a} lm{%a}_c
'	group lf{%a}_gr lf{%a} lf{%a}_c
'next

' Conclusion (6-8-2020): 
' SYOA labor force computed in the loop above differs from those loaded from CNIpop
' l... from CNIpop exists only for 2004 onwards; l... computed above exist for 1965 onward
' For the period when two series both exist (2004+) their values differ, sometimes significantly.
' 		Example: in 2014 lm67 = 0.55600 in CNIpop vs 0.528319 as computed
'					 in 2011 lf64 = 0.72125 in CNIpop vs 0.690372 as computed


for %s m f																		' Create multiplicative adjustment to LFPR and as a ratio of adjustment to L and adjustment to N.
	for %a 5559 6064 6569 7074
		series p{%s}{%a}_90c = l{%s}{%a}_90c / n{%s}{%a}_90c		' The adjustment factor <name>_90c is a multiplicative adjustment, thus computing p..._90c and ratio of l..._90c and n..._90c is appropriate
		series p{%s}{%a}_00c = l{%s}{%a}_00c / n{%s}{%a}_00c		' The adjustment factor <name>_00c is a multiplicative adjustment, thus computing p..._00c and ratio of l..._00c and n..._00c is appropriate
	next
next


' **** create additive adjustments p..._YRp series for single-year-of-age groups. 
' ***** NEW METHOD***** (same method as described above for 5yr groups, see lines 1100 (approx.)
' *** By definitioan, LFPR level for a group (e.g. pm5564) is equal to the weighted average of LFPR levels for SYOA (pm55, pm56, .. pm64), weighted by the population shares (nm55/nm5564, ... nm64/mn5564).
' *** Therefore, for ADDITIVE adjustments to LFPRs (e.g. pm5564_03p, and pm55_03p, ..., pm65_03p) the same relationship holds, i.e. the additive adjustment for the group (pm5564_03p) equals to the weighted average of adjustments for SYOA (pm55_03p, pm56_03p, .., pm64_03p).
' *** In the absence of data for SYOA adjustments to L or N, we will make a simplifying assumption:
' *** ASSUME: additive adjustments to LFPRs for each SYOA are EQUAL to the additive adjustment to LFPR for the group, i.e. pm5564_03p = pm55_03p = pm56_03p =...= pm64_03p.
' *** This assumption implies: the adjustment to LFPR for the group is uniformly distributed among the individual ages within the group. 
' *** Note: this assumption is likely to be contrary to reality, but in the absence of data on the adjustments to L and N for SYOA, we can't know how the adjustments to LFPRs are distrbuted across the singe years of age.

' create additive adjustment for LFPRs
for %s m f
	for %a 55 56 57 58 59 60 61 62 63 64
		for %y {%yrs}
			series p{%s}{%a}_{%y}p = p{%s}5564_{%y}p
		next
	next
next

for %s m f
	for %a 65 66 67 68 69 70 71 72 73 74
		for %y {%yrs}
			series p{%s}{%a}_{%y}p = p{%s}65o_{%y}p			' The assumption of equality here is especially likely to be violated, since LFPRs are MUCH higher at 65 than they are at 74. 
		next
	next
next

'AREA 6
' create additive adjustments for labor force (l) and population (n)

for %ser l n						
	for %s m f
		for %y {%yrs}			
			for %a 55 56 57 58 59 
				series {%ser}{%s}{%a}_{%y}p = {%ser}{%s}5559_{%y}p * ({%ser}{%s}{%a} / in_bka\{%ser}{%s}5559)
			next
			for %a 60 61 62 63 64 
				series {%ser}{%s}{%a}_{%y}p = {%ser}{%s}6064_{%y}p * ({%ser}{%s}{%a} / in_bka\{%ser}{%s}6064)
			next
			for %a 65 66 67 68 69
				series {%ser}{%s}{%a}_{%y}p = {%ser}{%s}6569_{%y}p * ({%ser}{%s}{%a} / in_bka\{%ser}{%s}6569)
			next
			for %a 70 71 72 73 74
				series {%ser}{%s}{%a}_{%y}p = {%ser}{%s}7074_{%y}p * ({%ser}{%s}{%a} / in_bka\{%ser}{%s}7074)
			next
		next
	next
next

' At this point some of the p{%s}{%a}_{%y}p series may have  NAs in earlier years. 
' Here we replace NAs with zeros so that when we later compute the adjusted series (by adding in these additive adjustments), we do not carry though all the NAs.
' This implicitly assumes that in the years for which -..._YRp adjustmnt series had NAs, the "true" adjustment was zero. (i.e. we assume that the adjustments we know nothing about were all zeros.)
' This is a reasonable assumption, given that we want to have the longest possible series for the resulting adjusted series.

smpl @all
for %s m f 				
	for %y {%yrs}		
		for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
			p{%s}{%a}_{%y}p = @nan(p{%s}{%a}_{%y}p, 0)			 
		next
	next
next


' ****** Compute the cumulative multiplicative adjustment (p..._adjm) and the cumulative additive adjustment (p..._adja) for all SYOA LFPR series 55 to 74.
' ******

%msg = "Create a single multiplicative adjustment and a single additive adjustment for each SYOA series by combining multiple adjustment computed previously" 
logmsg {%msg}
logmsg

%a1 = "55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74"			
%a2 = "55 56 57 58 59"
%a3 = "60 61 62 63 64"
%a4 = "65 66 67 68 69"
%a5 = "70 71 72 73 74"
%a6 = "55 56 57 58 59 60 61 62 63 64"
%a7 = "65 66 67 68 69 70 71 72 73 74"

for %s m f 						
	for %a {%a1}				
		series p{%s}{%a}_adja = p{%s}{%a}_03p
		for %y {%yrs2}
			p{%s}{%a}_adja = p{%s}{%a}_adja + p{%s}{%a}_{%y}p
		next
	next
next

for %s m f 						
	for %a {%a2}
		series p{%s}{%a}_adjm = l{%s}5564_94m_m * p{%s}5559_90c * p{%s}5559_00c
	next
	for %a {%a3}
		series p{%s}{%a}_adjm = l{%s}5564_94m_m * p{%s}6064_90c * p{%s}6064_00c
	next
	for %a {%a4}
		series p{%s}{%a}_adjm = l{%s}65o_94m_m * p{%s}6569_90c * p{%s}6569_00c
	next
	for %a {%a5}
		series p{%s}{%a}_adjm = l{%s}65o_94m_m * p{%s}7074_90c * p{%s}7074_00c
	next
next

' ******* Now APPLY the  multiplicative adjustment (p..._adjm) and the  additive adjustment (p..._adja) to the initial level data  for all SYOA LFPRS series 55 to 74.
' *******

%msg = "Apply the single multiplicative adjustment and the single additive adjustment to each SYOA series to obtain adjusted series " 
logmsg {%msg}
logmsg


for %s m f 				
	for %a {%a1}
		series p{%s}{%a}_adj =  (p{%s}{%a} * p{%s}{%a}_adjm) + p{%s}{%a}_adja
		'make groups for comparison and the check series to hold the differences
		group g_p{%s}{%a} p{%s}{%a}_adj p{%s}{%a}
		series ck_p{%s}{%a} = p{%s}{%a}_adj - p{%s}{%a}
	next
next

'****** Done with SYOA adjustmments ********

%msg = " Done with SYOA adjustmments. " 
logmsg {%msg}
logmsg


'****************************************************
' Save FIRST QUARTER observation into annual series <name>_1q 		
' Save LAST QUARTER observation into annual series <name>_4q 
' for l, n, r, p, e, both raw data and adjusted
%msg = "Save FIRST QUARTER observation into annual series <name>_1q and LAST QUARTER observation into annual series <name>_4q " 
logmsg {%msg}
logmsg

smpl @all

'AREA 7
pageselect quarterly

'Copy raw (unadjusted)  level series for l, n, r, e into the workfile from BKDO1. I will need to use these series in the next loop, which saves Q1 and Q4 values as separate series.
for %ser l n r e 'p							' there are NO quarterly series for p... in BKDO1. 
	copy in_bkq\{%ser}16o quarterly\{%ser}16o
	for %s m f
		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 2534 3544 4554 5564 16o 1619			
			copy in_bkq\{%ser}{%s}{%a} quarterly\{%ser}{%s}{%a}
		next
	next
next

' separate loop for p... b/c we compute it from l... and n...
' p..._adj series already exists in quarterly page, but p... (unadjusted) does not

for %s m f
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 2534 3544 4554 5564 16o 1619			
		series p{%s}{%a} = l{%s}{%a} / n{%s}{%a}
	next
next
series p16o = l16o / n16o

pageselect annual

for %ser l n r e p 						
	' aggregate16o series
	copy(c=fn) quarterly\{%ser}16o annual\{%ser}16o_1q 			' copy from quarterly to annual keeping Q1 observation as annual; governed by option c=fn (set annual value to First, propagate NAs)
	copy(c=fn) quarterly\{%ser}16o_adj annual\{%ser}16o_1q_adj
			
	copy(c=ln) quarterly\{%ser}16o annual\{%ser}16o_4q 			' copy from quarterly to annual keeping Q4 observation as annual; governed by option c=ln (set annual value to Last, propagate NAs)
	copy(c=ln) quarterly\{%ser}16o_adj annual\{%ser}16o_4q_adj
	
	' all other age groups
	for %s m f
		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 2534 3544 4554 5564 16o 1619			
			
			copy(c=fn) quarterly\{%ser}{%s}{%a} annual\{%ser}{%s}{%a}_1q 			' copy from quarterly to annual keeping Q1 observation as annual; governed by option c=fn (set annual value to First, propagate NAs)
			copy(c=fn) quarterly\{%ser}{%s}{%a}_adj annual\{%ser}{%s}{%a}_1q_adj
			
			copy(c=ln) quarterly\{%ser}{%s}{%a} annual\{%ser}{%s}{%a}_4q 			' copy from quarterly to annual keeping Q4 observation as annual; governed by option c=ln (set annual value to Last, propagate NAs)
			copy(c=ln) quarterly\{%ser}{%s}{%a}_adj annual\{%ser}{%s}{%a}_4q_adj
			
		next
	next
next


'*******************************************************
'*******************************************************
'***********ADJUST MARCH CPS DATA*************			
'*******************************************************
'*******************************************************
'*******************************************************
%msg = "Starting to process March CPS data..." 
logmsg {%msg}
logmsg

'AREA 8
pageselect annual			' March CPS data comes in ANNUAL frequency only

' *** load series from CPSO bank, renaming in the process.

for %ser l n			
	for %a 1415 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 6061 6264 6569 7074 7579 8084 85o
		series {%ser}f{%a}nmn18_mr = in_cps\{%ser}f{%a}nmnc18
		series {%ser}f{%a}msn18_mr = in_cps\{%ser}f{%a}msnc18
		series {%ser}f{%a}man18_mr = in_cps\{%ser}f{%a}manc18
	next
next

for %ser l n			
	for %s m f 
		for %a 1415 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 6061 6264 6569 7074 7579 8084 85o 5564 6064 16o 55o 65o
			series {%ser}{%s}{%a}_mr = in_cps\{%ser}{%s}{%a}
			
			series {%ser}{%s}{%a}nm_mr = in_cps\{%ser}{%s}{%a}nm
			series {%ser}{%s}{%a}ms_mr = in_cps\{%ser}{%s}{%a}ms
			series {%ser}{%s}{%a}ma_mr = in_cps\{%ser}{%s}{%a}ma
		next
	next
	for %a 1415 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 6061 6264 6569 7074 7579 8084 85o
		for %m nm ms ma
			series {%ser}f{%a}{%m}c6u_mr = in_cps\{%ser}{%s}{%a}{%m}c6u
			series {%ser}f{%a}{%m}nc6_mr = in_cps\{%ser}{%s}{%a}{%m}nc6
			series {%ser}f{%a}{%m}c6o_mr = in_cps\{%ser}{%s}{%a}{%m}c6o
		next
	next
next

' load the series later used for child presence indexes. 				
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054
	for %m nm ms ma
		copy in_cps\nf{%a}{%m}c6u3_ annual\nf{%a}{%m}c6u3	' rename to remove the _ at the end of series name
		
		copy in_cps\nf{%a}{%m}c6u1 annual\nf{%a}{%m}c6u1
		copy in_cps\nf{%a}{%m}c6u2 annual\nf{%a}{%m}c6u2
	next
next

%msg = "Create data for age groups 6064, 65o 75o, and check for consistency "
logmsg {%msg}
logmsg

' *** combine age groups to create 6064 group
for %ser l n
	for %m nm ms ma		 
		for %s m f 
			series {%ser}{%s}6064{%m}_mr = {%ser}{%s}6061{%m}_mr + {%ser}{%s}6264{%m}_mr
		next
		series {%ser}f6064{%m}c6u_mr = {%ser}f6061{%m}c6u_mr + {%ser}f6264{%m}c6u_mr
		series {%ser}f6064{%m}nc6_mr = {%ser}f6061{%m}nc6_mr + {%ser}f6264{%m}nc6_mr
		series {%ser}f6064{%m}c6o_mr = {%ser}f6061{%m}c6o_mr + {%ser}f6264{%m}c6o_mr
		series {%ser}f6064{%m}n18_mr = {%ser}f6061{%m}n18_mr + {%ser}f6264{%m}n18_mr
	next
next

' *** combine age groups to create f65o group (females only)
for %ser l n
	for %m nm ms ma		 
		series {%ser}f65o{%m}c6u_mr = {%ser}f6569{%m}c6u_mr + {%ser}f7074{%m}c6u_mr + {%ser}f7579{%m}c6u_mr + {%ser}f8084{%m}c6u_mr + {%ser}f85o{%m}c6u_mr
		series {%ser}f65o{%m}nc6_mr = {%ser}f6569{%m}nc6_mr + {%ser}f7074{%m}nc6_mr + {%ser}f7579{%m}nc6_mr + {%ser}f8084{%m}nc6_mr + {%ser}f85o{%m}nc6_mr
		series {%ser}f65o{%m}c6o_mr = {%ser}f6569{%m}c6o_mr + {%ser}f7074{%m}c6o_mr + {%ser}f7579{%m}c6o_mr + {%ser}f8084{%m}c6o_mr + {%ser}f85o{%m}c6o_mr
		series {%ser}f65o{%m}n18_mr = {%ser}f6569{%m}n18_mr + {%ser}f7074{%m}n18_mr + {%ser}f7579{%m}n18_mr + {%ser}f8084{%m}n18_mr + {%ser}f85o{%m}n18_mr
	next
next

' *** combine age groups to create 75o group (males and females) 
' Note: 75o group is constructed as 75o = 65o - 6569 - 7074. 
' For some series (because of EViews' level of precision) in some years this results in negative numbers, very close to zero, such as -4.34E-12 for lf75omsc6u_mr in 1986. 
' I am replacing such very small negative values with zero. 
' If there are large negative values ( -0.00001 or more negative), the program is stopped and a warning displayed.

for %ser l n
	for %m nm ms ma		 
		for %s m f 
			series {%ser}{%s}75o{%m}_mr = {%ser}{%s}65o{%m}_mr - {%ser}{%s}6569{%m}_mr - {%ser}{%s}7074{%m}_mr
		next
		series {%ser}f75o{%m}c6u_mr = {%ser}f65o{%m}c6u_mr - {%ser}f6569{%m}c6u_mr - {%ser}f7074{%m}c6u_mr
		series {%ser}f75o{%m}nc6_mr = {%ser}f65o{%m}nc6_mr - {%ser}f6569{%m}nc6_mr - {%ser}f7074{%m}nc6_mr
		series {%ser}f75o{%m}c6o_mr = {%ser}f65o{%m}c6o_mr - {%ser}f6569{%m}c6o_mr - {%ser}f7074{%m}c6o_mr
		series {%ser}f75o{%m}n18_mr = {%ser}f65o{%m}n18_mr - {%ser}f6569{%m}n18_mr - {%ser}f7074{%m}n18_mr
	next
	series {%ser}m75o_mr = {%ser}m75onm_mr + {%ser}m75oms_mr + {%ser}m75oma_mr
	series {%ser}f75o_mr = {%ser}f75onm_mr + {%ser}f75oms_mr + {%ser}f75oma_mr
next

' check fro negative values; differentiate between tiny negative values ( such as -4.34E-12) and larger negative values (more negative than -0.00001)
!err = - 0.00001 	' the tolerance level for the error

' define samples over which the values are negative
for %ser l n
	for %m nm ms ma		 
		for %s m f 
			sample sng_{%ser}{%s}75o{%m} @all if {%ser}{%s}75o{%m}_mr < 0		' create sample (call it  sng_{%ser}{%s}75o{%m} for 'negative') containing years where {%ser}{%s}75o{%m}_mr < 0
			sample snger_{%ser}{%s}75o{%m} @all if {%ser}{%s}75o{%m}_mr < !err	' create sample (call it  snger_{%ser}{%s}75o{%m} for 'negative and error') containing years where {%ser}{%s}75o{%m}_mr < -0.00001
		next
		sample sng_{%ser}f75o{%m}c6u @all if {%ser}f75o{%m}c6u_mr < 0	
		sample snger_{%ser}f75o{%m}c6u @all if {%ser}f75o{%m}c6u_mr < !err
		
		sample sng_{%ser}f75o{%m}nc6 @all if {%ser}f75o{%m}nc6_mr < 0	
		sample snger_{%ser}f75o{%m}nc6 @all if {%ser}f75o{%m}nc6_mr < !err
		
		sample sng_{%ser}f75o{%m}c6o @all if {%ser}f75o{%m}c6o_mr < 0	
		sample snger_{%ser}f75o{%m}c6o @all if {%ser}f75o{%m}c6o_mr < !err
		
		sample sng_{%ser}f75o{%m}n18 @all if {%ser}f75o{%m}n18_mr < 0	
		sample snger_{%ser}f75o{%m}n18 @all if {%ser}f75o{%m}n18_mr < !err
		
	next
next

' check for any observations with large negative  l.. or n... (more negative than !err). Abort program if any are found.
smpl @all
for %ser l n
	for %m nm ms ma		 
		for %s m f 
			smpl snger_{%ser}{%s}75o{%m}
			if @obssmpl>0 then
				string warning = "Warning! Negative values for " +%ser + %s + "75o" + %m +"_mr. Please check the computation. The program has been aborted."
				freeze(warn_{%ser}{%s}75o{%m}) {%ser}{%s}75o{%m}_mr.sheet
				warning.display
				show warn_{%ser}{%s}75o{%m}
				stop			' the program is stopped here!
			endif
			smpl @all
		next
		
		smpl snger_{%ser}f75o{%m}c6u 
		if @obssmpl>0 then
			string warning = "Warning! Negative values for " +%ser + "f75o" + %m +"c6u_mr. Please check the computation. The program has been aborted."
			freeze(warn_{%ser}f75o{%m}c6u) {%ser}f75o{%m}c6u_mr.sheet
			warning.display 
			show warn_{%ser}f75o{%m}c6u
			stop			' the program is stopped here!
		endif
		smpl @all
		
		smpl snger_{%ser}f75o{%m}nc6 
		if @obssmpl>0 then
			string warning = "Warning! Negative values for " +%ser + "f75o" + %m +"nc6_mr. Please check the computation. The program has been aborted."
			freeze(warn_{%ser}f75o{%m}nc6) {%ser}f75o{%m}nc6_mr.sheet
			warning.display
			show warn_{%ser}f75o{%m}nc6
			stop			' the program is stopped here!
		endif
		smpl @all
		
		smpl snger_{%ser}f75o{%m}c6o 
		if @obssmpl>0 then
			string warning = "Warning! Negative values for " +%ser + "f75o" + %m +"c6o_mr. Please check the computation. The program has been aborted."
			freeze(warn_{%ser}f75o{%m}c6o) {%ser}f75o{%m}c6o_mr.sheet
			warning.display
			show warn_{%ser}f75o{%m}c6o
			stop			' the program is stopped here!
		endif
		smpl @all
		
		smpl snger_{%ser}f75o{%m}n18 
		if @obssmpl>0 then
			string warning = "Warning! Negative values for " +%ser + "f75o" + %m +"n18_mr. Please check the computation. The program has been aborted."
			freeze(warn_{%ser}f75o{%m}n18) {%ser}f75o{%m}n18_mr.sheet
			warning.display
			show warn_{%ser}f75o{%m}n18
			stop			' the program is stopped here!
		endif
		smpl @all
		
	next
next

' replace observations with very small negative values (less negative than !err) with zeros.
smpl @all
!w = 0 			' counter for how many warnings I get below
spool _neg75o 	' spool where to store the warnings.
for %ser l n
	for %m nm ms ma		 
		for %s m f 
			smpl sng_{%ser}{%s}75o{%m} and not snger_{%ser}{%s}75o{%m}
			if @obssmpl>0 then
				!w = !w+1
				string warning_{!w} = "Some very small negative values for " +%ser + %s + "75o" + %m +"_mr were replaced by zeros."
				_neg75o.append warning_{!w}
				{%ser}{%s}75o{%m}_mr = 0
			endif
			smpl @all
		next
		
		smpl sng_{%ser}f75o{%m}c6u and not snger_{%ser}f75o{%m}c6u
		if @obssmpl>0 then
			!w = !w+1
			string warning_{!w} = "Some very small negative values for  " +%ser + "f75o" + %m +"c6u_mr were replaced by zeros."
			_neg75o.append warning_{!w}
			{%ser}f75o{%m}c6u_mr = 0
		endif
		smpl @all
		
		smpl sng_{%ser}f75o{%m}nc6 and not snger_{%ser}f75o{%m}nc6 
		if @obssmpl>0 then
			!w = !w+1
			string warning_{!w} = "Some very small negative values for  " +%ser + "f75o" + %m +"nc6_mr were replaced by zeros."
			_neg75o.append warning_{!w}
			{%ser}f75o{%m}nc6_mr = 0
		endif
		smpl @all
		
		smpl sng_{%ser}f75o{%m}c6o and not snger_{%ser}f75o{%m}c6o
		if @obssmpl>0 then
			!w = !w+1
			string warning_{!w} = "Some very small negative values for  " +%ser + "f75o" + %m +"c6o_mr were replaced by zeros."
			_neg75o.append warning_{!w}
			{%ser}f75o{%m}c6o_mr = 0
		endif
		smpl @all
		
		smpl sng_{%ser}f75o{%m}n18 and not snger_{%ser}f75o{%m}n18
		if @obssmpl>0 then
			!w = !w+1
			string warning_{!w} = "Some very small negative values for  " +%ser + "f75o" + %m +"n18_mr were replaced by zeros."
			_neg75o.append warning_{!w}
			{%ser}f75o{%m}n18_mr = 0
		endif
		smpl @all
		
	next
next

_neg75o.display 	' show the spool to let user know which series had negative values.

delete sng* warning_*		' delete all specialty defined samples and warning strings

smpl @all

' ***** Scale the March CPS series (series <name>_mr) so that the totals equal to the Q1 values in "normal" CPS (series <name>_1q and <name>_1q_adj)
' Some series in March CPS measure the same concept as the "normal" CPS does -- for example nm1617 or lf2024. 
' In the workfile, these values from March CPS are called nm1617_mr and lf2024_mr, etc.
' The same values from "normal" CPS are called nm1617_1q and lf2024_1q (Q1 values, NOT adjusted for BLS pop controls) AND nm1617_1q_adj and lf2024_1q_adj (Q1 values, ADJUSTED for BLS pop controls)
' Other series in March CPS are unique to March CPS, such as nm2529nm_mr, or lf1819msc6u_mr. These are disaggregated by marital status and presence of children.
' We compare the series that exist in both March CPS and "normal" CPS to compute the factors by which they differ -- name these factors <name>_adjf (when using ..._1q_adj series from "normal" CPS) and <name>_f (when using ..._1q series from "normal" CPS) 
' We then apply these factors to scale the March CPS series up(or down) to the "normal" CPS Q1 series -- call the resulting series <name>_maj (when using ..._1q_adj) and <name>_m (when using ..._1q).
' For those series that exist in BOTH March CPS and "normal" CPS (these are aggregate series, like nm2024) this amounts to setting them to the value equal to the "normal" CPS Q1.
' For those series that exists in March CPS ONLY (these are disaggregated by marital status and presence of children), we basically inflate(or deflate) them by the same fraction as the aggregate series were inflated (or deflated) by.

%msg = "Scale the March CPS series so that the totals equal to the Q1 values in ""normal"" CPS "
logmsg {%msg}
logmsg

for %ser n l 				
	for %s m f 
		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
			
			series {%ser}{%s}{%a}_adjf = {%ser}{%s}{%a}_1q_adj / {%ser}{%s}{%a}_mr		
			series {%ser}{%s}{%a}_f = {%ser}{%s}{%a}_1q / {%ser}{%s}{%a}_mr
			
			series {%ser}{%s}{%a}_maj = {%ser}{%s}{%a}_mr * {%ser}{%s}{%a}_adjf			
			series {%ser}{%s}{%a}_m = {%ser}{%s}{%a}_mr * {%ser}{%s}{%a}_f				' Together, these 4 lines simply set {%ser}{%s}{%a}_maj = {%ser}{%s}{%a}_1q_adj  and  {%ser}{%s}{%a}_m = {%ser}{%s}{%a}_1q. 
																												' We do it in two steps simply to make it clear that the process is the same here as it will be for the series with nm/ms/ms below.
			
			for %m nm ms ma
				series {%ser}{%s}{%a}{%m}_maj = {%ser}{%s}{%a}{%m}_mr * {%ser}{%s}{%a}_adjf
				series {%ser}{%s}{%a}{%m}_m = {%ser}{%s}{%a}{%m}_mr * {%ser}{%s}{%a}_f
			next
		next
	next
next

for %ser n l			' separate loop b/c this is only for females and the list fo ages differs from the loop above
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o
		for %m nm ms ma
			for %k nc6 c6u c6o n18
				series {%ser}f{%a}{%m}{%k}_maj = {%ser}f{%a}{%m}{%k}_mr * {%ser}f{%a}_adjf
				series {%ser}f{%a}{%m}{%k}_m = {%ser}f{%a}{%m}{%k}_mr * {%ser}f{%a}_f
			next
		next
	next
next

' *** Compute LFPRs and e/pop ratios by using l... and n... series computed immediately above and r..._1q series computed earlier.
' This can be problematic when denominator (n..._maj or n...._m) is zero. 
' This is the case for some fo the smaller groups -- such as f1617nmc6u_maj. For this group, both L and N are zero in some years (so the data are consistent), but this creates a problem for EViews when it needs to divide zero by zero.
' Need a way to deal with this situation. 
' What should LFPR be if both L and N are zero?  BLSADJ18.BNK has zero in such cases. This is what I do here. (an alternative would be to put NA for such cases).
' Below I  also check for cases when L is nonzero but N is zero. This would suggest that there is some problem with data or an error in earlier computations.


' Check for consistency in the data:
' if n..... = 0, then l... should also be zero. In this case, set p... and e... to zero as well.
' if n... = 0, but l... is not zero -- display an error message and stop the program. This is an indication of either incosistency in data or some error in earlier computations. This needs to be checked manually.
' In all cases, labor force must be equal to or smaller than population. If l.... > n..., display an error message and stop the program. This is an indication of either incosistency in data or some error in earlier computations. This needs to be checked manually.

%msg = " Compute LFPRs and e/pop ratios by using l... , n..., and r....  series computed earlier "
logmsg {%msg}
logmsg

' ** For females by Age, MS, and presence of chidren
' create samples that mark where n.... or l... series are zero.
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o		' for females only
	for %m nm ms ma
		for %k nc6 c6u c6o n18
			sample snf{%a}{%m}{%k}_maj @all if nf{%a}{%m}{%k}_maj = 0		' sample named 'snf2024nmnc6_maj' (sn... = 'sample for n..") holds years where nf2024nmnc6_maj=0
			sample slf{%a}{%m}{%k}_maj @all if lf{%a}{%m}{%k}_maj = 0		' sample named 'slf2024nmnc6_maj' (sl... = 'sample for l..") holds years where lf2024nmnc6_maj=0
																								' these samples are saved to the file and can be used later, if needed
			sample swf{%a}{%m}{%k}_maj if snf{%a}{%m}{%k}_maj and not slf{%a}{%m}{%k}_maj 	' sample named  'swf2024nmnc6_maj' (sw... = 'sample for warning") shows years where nf2024nmnc6_maj=0 but lf2024nmnc6_maj is NOT zero. This is evidence of some error.
			
			sample snf{%a}{%m}{%k}_m @all if nf{%a}{%m}{%k}_m = 0		
			sample slf{%a}{%m}{%k}_m @all if lf{%a}{%m}{%k}_m = 0		
																								
			sample swf{%a}{%m}{%k}_m if snf{%a}{%m}{%k}_m and not slf{%a}{%m}{%k}_m
		next
	next
next

' now check if any of the 'warning samples' have observation 
' If data are consistent, they should all be empty, with no observations
' If any of them have observations, it means n.. = 0, but l is nonzero -- this would be a problem! In such cases, dysplay a warning and abort the program.
smpl @all

!warn = 0 	' indicator for how many warning samples are non-empty
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o		
	for %m nm ms ma
		for %k nc6 c6u c6o n18
			smpl swf{%a}{%m}{%k}_maj
			if @obssmpl>0 then 
				!warn = !warn +1
				%wn = @str(!warn)
				string warning_{%wn} = "WARNING! Inconsistent data. nf" + %a + %m+ %k +"_maj is zero, but lf" + %a + %m+ %k +"_maj is positive in some years"
			endif
			smpl @all
			smpl swf{%a}{%m}{%k}_m
			if @obssmpl>0 then 
				!warn = !warn +1
				%wn = @str(!warn)
				string warning_{%wn} = "WARNING! Inconsistent data. nf" + %a + %m+ %k +"_m is zero, but lf" + %a + %m+ %k +"_m is positive in some years"
			endif
			smpl @all
		next
	next
next

'scalar test = !warn

'** For both sexes, by age and MS
' create samples that mark where n.... or l... series are zero.
for %s m f			
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
		for %m nm ms ma
			sample sn{%s}{%a}{%m}_maj @all if n{%s}{%a}{%m}_maj = 0					' sample named 'snm1819ms_maj' (sn... = 'sample for n..") holds years where nm1819ms_maj=0
			sample sl{%s}{%a}{%m}_maj @all if l{%s}{%a}{%m}_maj = 0						' sample named 'slm1819ms_maj' (sl... = 'sample for l..") holds years where 'slm1819ms_maj=0
			sample sw{%s}{%a}{%m}_maj if sn{%s}{%a}{%m}_maj and not sl{%s}{%a}{%m}_maj	' sample named  'swm1819ms_maj' (sw... = 'sample for warning") shows years where nm1819ms_maj=0 but lm1819ms_maj is NOT zero. This is evidence of some error.
			
			sample sn{%s}{%a}{%m}_m @all if n{%s}{%a}{%m}_m = 0					
			sample sl{%s}{%a}{%m}_m @all if l{%s}{%a}{%m}_m = 0						
			sample sw{%s}{%a}{%m}_m if sn{%s}{%a}{%m}_m and not sl{%s}{%a}{%m}_m
		next
	next
next

' now check if any of the 'warning samples' have observation 
' If data are consistent, they should all be empty, with no observations
' If any of them have observations, it means n.. = 0, but l.. is nonzero -- this would be a problem! In such cases, display a warning and abort the program.
smpl @all
' remember: !warn holds the number of warnings from the earlier loop for females only. We will add to it here.

for %s m f			
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
		for %m nm ms ma
			smpl sw{%s}{%a}{%m}_maj
			if @obssmpl>0 then 
				!warn = !warn +1
				%wn = @str(!warn)
				string warning_{%wn} = "WARNING! Inconsistent data. n" + %s + %a + %m +"_maj is zero, but l" + %s + %a + %m +"_maj is nonzero in some years."
			endif
			smpl @all
			smpl sw{%s}{%a}{%m}_m
			if @obssmpl>0 then 
				!warn = !warn +1
				%wn = @str(!warn)
				string warning_{%wn} = "WARNING! Inconsistent data. n" + %s + %a + %m +"_m is zero, but l" + %s + %a + %m +"_m is nonzero in some years."
			endif
			smpl @all
		next
	next
next

' scalar test = !warn 

' Now check if there are any warnings about inconsustent data and, if so, abort the program. 
if !warn >0 then
	spool warn_nl
	for !i=1 to !warn
		warn_nl.append warning_{!i}
	next
	warn_nl.append The program has been aborted
	warn_nl.display  ' show the spool with warning (if there are any)
	stop		' The program is stopped here
endif


' ** Now that the data is consistent, compute LFPRs and e/pop
' Rememeber that there are cases when BOTH n... and l... series have zero values. These instances are marked with samples sn.. an sl....
' This is internally consistent, but precludes computing the LFPR by the usual formula.
' In instances where BOTH n... and l... series have zero values, set LFPRs and e/pop ratios for those cases to zero

smpl @all

for %s m f			
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o		' I assume that for these age groups (which are fairly large) there aren't any cases of n... =0, so I am not checking for this possibility. 
		
		series p{%s}{%a}_maj = l{%s}{%a}_maj / n{%s}{%a}_maj 
		series p{%s}{%a}_m = l{%s}{%a}_m / n{%s}{%a}_m
		
		series p{%s}{%a}_1q = l{%s}{%a}_1q / n{%s}{%a}_1q
		series p{%s}{%a}_1q_adj = l{%s}{%a}_1q_adj / n{%s}{%a}_1q_adj
		
		series e{%s}{%a}_1q = l{%s}{%a}_1q *(1 - r{%s}{%a}_1q / 100)
		series e{%s}{%a}_1q_adj = l{%s}{%a}_1q_adj *(1 - r{%s}{%a}_1q_adj / 100)
		
		for %m nm ms ma				' these age groups can be small, so I am allowing for the possibility that in some years some fo them may have n... = 0.
			
			smpl sn{%s}{%a}{%m}_maj		' when n... = 0, set p... = 0
			series p{%s}{%a}{%m}_maj =0
			
			sample spn{%s}{%a}{%m}_maj @all if not sn{%s}{%a}{%m}_maj	' when n.. is not zero, set p.. = l.../n...
			smpl spn{%s}{%a}{%m}_maj 
			series p{%s}{%a}{%m}_maj = l{%s}{%a}{%m}_maj / n{%s}{%a}{%m}_maj 
			
			smpl sn{%s}{%a}{%m}_m
			series p{%s}{%a}{%m}_m =0
			
			sample spn{%s}{%a}{%m}_m @all if not sn{%s}{%a}{%m}_m
			smpl spn{%s}{%a}{%m}_m
			series p{%s}{%a}{%m}_m = l{%s}{%a}{%m}_m / n{%s}{%a}{%m}_m
			
			smpl @all
		next
	next
next

' females only, by presence of children; we do not compute e/pop ratio for this group (Aremos code had it this way).
smpl @all
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o		
	for %m nm ms ma
		for %k nc6 c6u c6o n18						' these age groups can be small, so I am allowing for the possibility that in some years some fo them may have n... = 0
			
			smpl snf{%a}{%m}{%k}_maj		' when n... = 0, set p... = 0
			series pf{%a}{%m}{%k}_maj = 0
			
			sample spnf{%a}{%m}{%k}_maj @all if not snf{%a}{%m}{%k}_maj 	' when n.. is not zero, set p.. = l.../n...
			smpl spnf{%a}{%m}{%k}_maj
			series pf{%a}{%m}{%k}_maj = lf{%a}{%m}{%k}_maj / nf{%a}{%m}{%k}_maj 
			
			smpl snf{%a}{%m}{%k}_m
			series pf{%a}{%m}{%k}_m = 0
			
			sample spnf{%a}{%m}{%k}_m @all if not snf{%a}{%m}{%k}_m
			smpl spnf{%a}{%m}{%k}_m
			series pf{%a}{%m}{%k}_m = lf{%a}{%m}{%k}_m / nf{%a}{%m}{%k}_m
			
			smpl @all
		next
	next
next
smpl @all


'**************************************************
'**************************************************
'******** Create child present indexes ********				
'**************************************************

%msg = "Creating child presence indexes "
logmsg {%msg}
logmsg


' scale all N series with child presence (...c6u1, ...c6u2, ...c6u3) by the ..._adjf factor (which scales March CPS to "normal" CPS Q1_adj measure).
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054
	for %m nm ms ma
		for %k c6u1 c6u2 c6u3
			series nf{%a}{%m}{%k}maj = nf{%a}{%m}{%k} * nf{%a}_adjf
		next
	next
next

' this is where the child presence indexes are computed
' The index series (if...._maj) shows the average number of children under 6yo per woman, among the women who DO have chilren under 6yo. 
' For example: 
' for group f1617nmc6u (females, never married, with children under 6) in 1974
' nf1617nmc6u_maj = 0.001458  -- this many women in this age group had ANY children under 6
' nf1617nmc6u1_maj = 0   -- no women in this group had exactly 1 child under 6
' nf1617nmc6u2_maj = 0   -- no women in this group had exactly 2 children under 6
' nf1617nmc6u3_maj = 0.001458  --  this many women in this age group had 3 or more children under 6
' Result: the formular below would assign if1617nmc6u3_maj = 3
' This means "In 1974, among females ages 16-17, never married, if they had any children under 6, it was 3 or more children."
' This does NOT mean that "In 1974, among females ages 16-17, never married, the average number of chilren under 6 was 3." The average number of children under 6 for females 1617 never married was smaller, because many of them had NO children under 6.

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054			' these age groups are small, so some of then have nf... = 0 insome years. In such cases, set if... = 0.
	for %m nm ms ma 
		
		smpl snf{%a}{%m}c6u_maj    		' if nf{%a}{%m}c6u_maj = 0, set if{%a}{%m}c6u_maj = 0
		series if{%a}{%m}c6u_maj = 0
		
		smpl @all if not snf{%a}{%m}c6u_maj		' ' if nf{%a}{%m}c6u_maj is nonzero, compute if{%a}{%m}c6u_maj according to formula
		series if{%a}{%m}c6u_maj = (nf{%a}{%m}c6u1maj + 2 * nf{%a}{%m}c6u2maj + 3 * nf{%a}{%m}c6u3maj) / nf{%a}{%m}c6u_maj
		' add label to the series
		if %m = "nm" then
			%txt = "Child presence index for females age " + %a + ", never married"
		endif
		if %m = "ms" then
			%txt = "Child presence index for females age " + %a + ", married spouse present"
		endif
		if %m = "ma" then
			%txt = "Child presence index for females age " + %a + ", married spouse absent"
		endif 
		if{%a}{%m}c6u_maj.label(d) {%txt} 
		if{%a}{%m}c6u_maj.label(r) Average number of children under 6 years of age per woman, among all women who have ANY children under 6.
		if{%a}{%m}c6u_maj.label(r) Value should be between 1 (1 child per woman) and 3 (3 or more children per woman).
		if{%a}{%m}c6u_maj.label(r) Zero value indicates that NO women in this age group have children under 6.
		
		smpl @all
	next
next

delete sn* sl* sp* sw*' delete all specialty defined samples

' *** Make various plots (these were included in Aremos code)
smpl @first 2020

for %ser n p
	for %a 2024 2529 3034 3539 4044 4549
		for %m nm ms ma
			group g_{%ser}f{%a}{%m}c6 {%ser}f{%a}{%m}c6u_maj {%ser}f{%a}{%m}c6o_maj
			freeze(gr_{%ser}f{%a}{%m}c6) g_{%ser}f{%a}{%m}c6.line
			
			group g_{%ser}f{%a}{%m}nc {%ser}f{%a}{%m}nc6_maj {%ser}f{%a}{%m}n18_maj
			freeze(gr_{%ser}f{%a}{%m}nc) g_{%ser}f{%a}{%m}nc.line
			
			delete g_{%ser}f{%a}{%m}c6 g_{%ser}f{%a}{%m}nc
		next
	next
next

smpl @all 

%msg = "Done with March CPS data."
logmsg {%msg}
logmsg

'**************************************************************************************
'**************************************************************************************
'******** Copy all relevant series into separate data_a and data_q pages *********				
'**************************************************************************************

%msg = "Copy relevant series to pages data_a (annual), data_q (quarterly), data_mar (March CPS, annual)."
logmsg {%msg}
logmsg

pagecreate(page=data_a) a !yr_start !yr_end			' page to hold annual adjusted series
copy annual\*_aadj
'copy annual\*_aadjs
copy annual\p*_adj

pagecreate(page=data_q) q !yr_start !yr_end				' page to hold quarterly adjusted series
copy quarterly\*_adj
'copy quarterly\*_adjs

pagecreate(page=data_mar) a !yr_start !yr_end			' page to hold March CPS data
copy annual\*_maj
copy annual\*_m
pageselect data_mar
delete *_94m_m  	' don't need these series in data_mar

'**************************************
'**** Consistency and sanity checks -- checking that the series in data_a, data_q, and data_mar have values that do not violate obvious math constraints
'**************************************

smpl @all

%msg = "Checking for data consistency"
logmsg {%msg}
logmsg

' check data in data_a and data_q
for %pg a q
	pageselect data_{%pg}
	'adjustment name
	if %pg = "a" then %adj = "aadj"
		else %adj = "adj"
	endif
	'creatre spool for warning messages
	spool _warnings_{%pg}
	string warn = "Checking data (in data_" + %pg + ") for consistency..."
	_warnings_{%pg}.append warn
	!w = 0 	' counter for how many warnings we get
	
	' 16o group
	' population is not negative
	smpl @all if n16o_{%adj} <0
	if @obssmpl >0 then
		warn = "Negative values found in some years for population series n16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		freeze(warn_t) n16o_{%adj}.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t
	endif
	smpl @all
	' labor force is not negative
	smpl @all if l16o_{%adj} <0
	if @obssmpl >0 then
		warn = "Negative values found in some years for labor force series l16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		freeze(warn_t) l16o_{%adj}.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		deleteele warn_t
	endif
	smpl @all
	' employment is not negative
	smpl @all if e16o_{%adj} <0
	if @obssmpl >0 then
		warn = "Negative values found in some years for employment series e16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		freeze(warn_t) e16o_{%adj}.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t
	endif
	smpl @all
	' labor force does not exceed population
	smpl @all if l16o_{%adj} > n16o_{%adj}
	if @obssmpl >0 then
		warn = "Labor force exceeds population in some years for series l16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		group warn_g l16o_{%adj} n16o_{%adj}
		freeze(warn_t) warn_g.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t warn_g
	endif
	smpl @all
	' employment does not exceed labor force
	smpl @all if e16o_{%adj} > l16o_{%adj}
	if @obssmpl >0 then
		warn = "Employment exceeds labor force in some years for series e16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		group warn_g e16o_{%adj} l16o_{%adj}
		freeze(warn_t) warn_g.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t warn_g
	endif
	smpl @all
	' LFPRs are between zero and one
	smpl @all if p16o_{%adj} > 1 or p16o_{%adj} < 0
	if @obssmpl >0 then
		warn = "LFPR values fall outside [0,1] interval in some years for series p16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		freeze(warn_t) p16o_{%adj}.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t
	endif
	smpl @all
	' RUs are between zero and 100%
	smpl @all if r16o_{%adj} > 100 or r16o_{%adj} < 0
	if @obssmpl >0 then
		warn = "Un. rate falls outside [0,100%] interval in some years for series r16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		freeze(warn_t) r16o_{%adj}.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t
	endif
	smpl @all
	' RUs are "too large"; here I consider RU above 50% to be too large to be plausible.
	smpl @all if r16o_{%adj} > 50
	if @obssmpl >0 then
		warn = "Un. rate is unusually large (above 50%) in some years for series r16o_" + %adj + ". Please check data and computations for errors."
		_warnings_{%pg}.append warn
		freeze(warn_t) r16o_{%adj}.sheet(nl)
		_warnings_{%pg}.append warn_t
		!w = !w +1
		delete warn_t
	endif
	smpl @all
	
	
	' all other AS groups
	for %s m f
		for %a 1617 1619 1819 2024 2529 2534 3034 3539 3544 4044 4549 4554 5054 5559 5564 6064 6569 65o 7074 75o 16o
			' population is not negative
			smpl @all if n{%s}{%a}_{%adj} <0
			if @obssmpl >0 then
				warn = "Negative values found in some years for population series n" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) n{%s}{%a}_{%adj}.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
		
			' labor force is not negative
			smpl @all if l{%s}{%a}_{%adj} <0
			if @obssmpl >0 then
				warn = "Negative values found in some years for labor force series l" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) l{%s}{%a}_{%adj}.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
			
			' employment is not negative
			smpl @all if e{%s}{%a}_{%adj} <0
			if @obssmpl >0 then
				warn = "Negative values found in some years for employment series e" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) e{%s}{%a}_{%adj}.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
		
			' labor force does not exceed population
			smpl @all if l{%s}{%a}_{%adj} > n{%s}{%a}_{%adj}
			if @obssmpl >0 then
				warn = "Labor force exceeds population in some years for series l" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				group warn_g l{%s}{%a}_{%adj} n{%s}{%a}_{%adj}
				freeze(warn_t) warn_g.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t warn_g
			endif
			smpl @all
		
			' employment does not exceed labor force
			smpl @all if e{%s}{%a}_{%adj} > l{%s}{%a}_{%adj}
			if @obssmpl >0 then
				warn = "Employment exceeds labor force in some years for series e" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				group warn_g e{%s}{%a}_{%adj} l{%s}{%a}_{%adj}
				freeze(warn_t) warn_g.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t warn_g
			endif
			smpl @all
			
			' LFPRs are between zero and one
			smpl @all if p{%s}{%a}_{%adj} > 1 or p{%s}{%a}_{%adj} < 0
			if @obssmpl >0 then
				warn = "LFPR values fall outside [0,1] interval in some years for series p" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) p{%s}{%a}_{%adj}.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
			
			' RUs are between zero and 100%
			smpl @all if r{%s}{%a}_{%adj} > 100 or r{%s}{%a}_{%adj} < 0
			if @obssmpl >0 then
				warn = "Un. rate falls outside [0,1] interval in some years for series r" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) r{%s}{%a}_{%adj}.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
		
			' RUs are "too large"; here I consider RU above 50% to be too large to be plausible.
			smpl @all if r{%s}{%a}_{%adj} > 50
			if @obssmpl >0 then
				warn = "Un. rate is unusually large (above 50%) in some years for series r" + %s + %a + "_" + %adj + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) r{%s}{%a}_{%adj}.sheet(nl)
				_warnings_{%pg}.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
		
		next
	next

	'if !w >0 then
	'	_warnings_{%pg}.display
	'endif

	if !w = 0 then
		warn = "No warnings to display."
		_warnings_{%pg}.append warn
	endif

next
'scalar testc = !w

' check SYOA data in data_a 
pageselect data_a
for %s m f 
	for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
		' LFPRs are between zero and one
			smpl @all if p{%s}{%a}_adj > 1 or p{%s}{%a}_adj < 0
			if @obssmpl >0 then
				warn = "LFPR values fall outside [0,1] interval in some years for series p" + %s + %a + "_adj. Please check data and computations for errors."
				_warnings_a.append warn
				freeze(warn_t) p{%s}{%a}_adj.sheet(nl)
				_warnings_a.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
	next
next


' check data in data_mar
smpl @all
pageselect data_mar

'creatre spool for warning messages
spool _warnings_mar
string warn = "Checking data (in data_mar) for consistency..."
_warnings_mar.append warn
!w = 0 	' counter for how many warnings we get

' child presence indexes -- values 1 to 3.
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054
	for %m ma ms nm
		smpl @all if if{%a}{%m}c6u_maj > 3 or if{%a}{%m}c6u_maj < 0
		if @obssmpl >0 then
			warn = "Child presence index has values outside [0,3] interval for some years for series if" + %a + %m + "_maj. Please check data and computations for errors."
			_warnings_mar.append warn
			freeze(warn_t) if{%a}{%m}c6u_maj.sheet(nl)
			_warnings_mar.append warn_t
			!w = !w +1
			delete warn_t
		endif
		smpl @all
	next
next

' all other series -- n, l. p
' by age and sex
for %s m f
	for %a 16o 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 65o 7074 75o
		for %x _m _maj 
			' population is not negative
			smpl @all if n{%s}{%a}{%x} < 0
			if @obssmpl >0 then
				warn = "Negative values found in some years for population series n" + %s + %a +  %x + ". Please check data and computations for errors."
				_warnings_mar.append warn
				freeze(warn_t) n{%s}{%a}{%x}.sheet(nl)
				_warnings_mar.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
				
			' labor force is not negative
			smpl @all if l{%s}{%a}{%x} < 0
			if @obssmpl >0 then
				warn = "Negative values found in some years for labor force series l" + %s + %a + %x + ". Please check data and computations for errors."
				_warnings_mar.append warn
				freeze(warn_t) l{%s}{%a}{%x}.sheet(nl)
				_warnings_mar.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
				
			' labor force does not exceed population
			smpl @all if l{%s}{%a}{%x} > n{%s}{%a}{%x}
			if @obssmpl >0 then
				warn = "Labor force exceeds population in some years for series l" + %s + %a + %x + ". Please check data and computations for errors."
				_warnings_mar.append warn
				group warn_g l{%s}{%a}{%x} n{%s}{%a}{%x}
				freeze(warn_t) warn_g.sheet(nl)
				_warnings_mar.append warn_t
				!w = !w +1
				delete warn_t warn_g
			endif
			smpl @all
				
			' LFPRs are between zero and 1
			smpl @all if p{%s}{%a}{%x} > 1 or p{%s}{%a}{%x} < 0
			if @obssmpl >0 then
				warn = "LFPR values fall outside [0,1] interval in some years for series p" + %s + %a + %x + ". Please check data and computations for errors."
				_warnings_{%pg}.append warn
				freeze(warn_t) p{%s}{%a}{%x}.sheet(nl)
				_warnings_mar.append warn_t
				!w = !w +1
				delete warn_t
			endif
			smpl @all
				
		next
	next
next

' by age, sex, mar. status
for %s m f
	for %a 16o 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 65o 7074 75o
		for %x _m _maj 
			for %m ma ms nm
				' population is not negative
				smpl @all if n{%s}{%a}{%m}{%x} < 0
				if @obssmpl >0 then
					warn = "Negative values found in some years for population series n" + %s + %a + %m + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					freeze(warn_n{%s}{%a}{%m}{%x}) n{%s}{%a}{%m}{%x}.sheet(nl)
					_warnings_mar.append warn_n{%s}{%a}{%m}{%x}
					!w = !w +1
					delete warn_n{%s}{%a}{%m}{%x}
				endif
				smpl @all
				
				' labor force is not negative
				smpl @all if l{%s}{%a}{%m}{%x} < 0
				if @obssmpl >0 then
					warn = "Negative values found in some years for labor force series l" + %s + %a + %m + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					freeze(warn_l{%s}{%a}{%m}{%x}) l{%s}{%a}{%m}{%x}.sheet(nl)
					_warnings_mar.append warn_l{%s}{%a}{%m}{%x}
					!w = !w +1
					delete warn_l{%s}{%a}{%m}{%x}
				endif
				smpl @all
				
				' labor force does not exceed population
				smpl @all if l{%s}{%a}{%m}{%x} > n{%s}{%a}{%m}{%x}
				if @obssmpl >0 then
					warn = "Labor force exceeds population in some years for series l" + %s + %a + %m + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					group gln{%s}{%a}{%m}{%x} l{%s}{%a}{%m}{%x} n{%s}{%a}{%m}{%x}
					freeze(warn_l{%s}{%a}{%m}{%x}) gln{%s}{%a}{%m}{%x}.sheet
					_warnings_mar.append warn_l{%s}{%a}{%m}{%x}
					!w = !w +1
					delete gln{%s}{%a}{%m}{%x} warn_l{%s}{%a}{%m}{%x}
				endif
				smpl @all
				
				' LFPRs are between zero and 1
				smpl @all if p{%s}{%a}{%m}{%x} > 1 or p{%s}{%a}{%m}{%x} < 0
				if @obssmpl >0 then
					warn = "LFPR values fall outside [0,1] interval in some years for series p" + %s + %a + %m + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					freeze(warn_p{%s}{%a}{%m}{%x}) p{%s}{%a}{%m}{%x}.sheet(nl)
					_warnings_mar.append warn_p{%s}{%a}{%m}{%x}
					!w = !w +1
					delete warn_p{%s}{%a}{%m}{%x}
				endif
				smpl @all
				
			next
		next
	next
next

' females by age, mar. status, and presence of children
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 65o 7074 75o
	for %m ma ms nm
		for %k c6o c6u nc6 n18 
			for %x _m _maj
				' population is not negative
				smpl @all if nf{%a}{%m}{%k}{%x} < 0
				if @obssmpl >0 then
					warn = "Negative values found in some years for population series nf" + %a + %m + %k + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					freeze(warn_nf{%a}{%m}{%k}{%x}) nf{%a}{%m}{%k}{%x}.sheet(nl)
					_warnings_mar.append warn_nf{%a}{%m}{%k}{%x}
					!w = !w +1
					delete warn_nf{%a}{%m}{%k}{%x}
				endif
				smpl @all
				
				' labor force is not negative
				smpl @all if lf{%a}{%m}{%k}{%x} < 0
				if @obssmpl >0 then
					warn = "Negative values found in some years for labor force series lf" + %a + %m + %k + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					freeze(warn_lf{%a}{%m}{%k}{%x}) lf{%a}{%m}{%k}{%x}.sheet(nl)
					_warnings_mar.append warn_lf{%a}{%m}{%k}{%x}
					!w = !w +1
					delete warn_lf{%a}{%m}{%k}{%x}
				endif
				smpl @all
				
				' labor force does not exceed population
				smpl @all if lf{%a}{%m}{%k}{%x} > nf{%a}{%m}{%k}{%x}
				if @obssmpl >0 then
					warn = "Labor force exceeds population in some years for series lf" + %a + %m + %k + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					group glnf{%a}{%m}{%k}{%x} lf{%a}{%m}{%k}{%x} nf{%a}{%m}{%k}{%x}
					freeze(warn_lf{%a}{%m}{%k}{%x}) glnf{%a}{%m}{%k}{%x}.sheet(nl)
					_warnings_mar.append warn_lf{%a}{%m}{%k}{%x}
					!w = !w +1
					delete glnf{%a}{%m}{%k}{%x} warn_lf{%a}{%m}{%k}{%x}
				endif
				smpl @all
				
				' LFPRs are between zero and 1
				smpl @all if pf{%a}{%m}{%k}{%x} > 1 or pf{%a}{%m}{%k}{%x} < 0
				if @obssmpl >0 then
					warn = "LFPR values fall outside [0,1] interval in some years for series pf" + %a + %m + %k + %x + ". Please check data and computations for errors."
					_warnings_mar.append warn
					freeze(warn_pf{%a}{%m}{%k}{%x}) pf{%a}{%m}{%k}{%x}.sheet(nl)
					_warnings_mar.append warn_pf{%a}{%m}{%k}{%x}
					!w = !w +1
					delete warn_pf{%a}{%m}{%k}{%x}
				endif
				smpl @all
				
			next
		next
	next
next


if !w = 0 then
	warn = "No warnings to display."
	_warnings_mar.append warn
endif

' show all warning spools

pageselect data_a
_warnings_a.display
delete warn 			' delete the string object

pageselect data_q
_warnings_q.display
delete warn 			' delete the string object

pageselect data_mar
_warnings_mar.display
delete warn 			' delete the string object

' *** Done with consistency checks and displayinh coresponding warnings.

pageselect annual
'		make summary spool
%userpin = @env("USERNAME")

spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %userpin
string line2 = "The file contains ADJUSTED BLS data created using BKDO1 bank (" + %bkdo1_path + ")." ' created on 6-15-2020 specifically so that the data in it cover 2019Q4, the new BC peak."
string line3 = "The adjusted data are located in pages 'data_a' (annual), 'data_q' (quarterly), and 'data_mar' (March CPS, annual)." + @chr(13) +  "!!! In each of these pages, please check the spool _warnings for any warnings that need attention!!!"
string line4 = "The adjustments applied reflect: 1994 methodology change, 1990 Census, 2000 Census, and the annual BLS population adjustments published in January for each year from 2003 to " + @str(!yr_latest) + ". These annual adjustments also include the decennial Census adjustments in certain years (for 2010 and 2020 decennial Census)."
string line5 = "In pages 'annual' and 'quarterly', the group objects g_<series> show the comparison between the 'raw' series and the adjusted one. "
string line6 = "In pages 'annual' and 'quarterly', series named ck_<series> show the difference between the adjusted series and the 'raw' one. "
string line7 = "The file also contains processed March CPS data and the resulting child presence indexes. The adjusted series for these are in page 'data_mar'. Full data and computation for these are in 'annual' page."
string line8 = "Page 'annual' includes a number of useful charts for March CPS data; these are named gr_<name>.  "
string line9 = " "


_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 
_summary.display

delete line*

' copy _summary to every page in the file to make it easy to find
copy annual\_summary quarterly\*
copy annual\_summary data_a\*
copy annual\_summary data_q\*
copy annual\_summary data_mar\*


if %sav = "Y" then
	%wfpath=%new_file_path
	wfsave(2) %wfpath ' saves the workfile
endif

!runtime = @toc
%msg = "Runtime " + @str(!runtime) + " sec" 
logmsg {%msg}

logmsg FINISHED


