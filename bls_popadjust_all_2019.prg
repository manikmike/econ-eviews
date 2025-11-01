'*****************************************************************************
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
'			This program updates the aremos command file:
'			edblsadj_2018.cmd
'		
'			The edblsadj_2018.cmd called the following aremos command file:
'			adjustcpsdata_2018.cmd
'
'	Bob Weathers, 5-3-2019  

'	Description of the resulting workfile (pages, contents, etc) Should I make a summary spool? ---PV


'**** This version has special path to BKDO1 to get data through 2019; see %bkdo1_path below. -- PV 6-13-2019

' ******* UPDATE entries here for each run ********
!yr_first = 2003 	' the first year for which we do CPS pop adjustment to MONTHLY data are done -- NOT likely to change!

' Enter LATEST year, for which we are implementing the CPS monthly pop controls released in this year, i.e. for pop controls released with Jan 2018 CPS, enter 2018
!yr_latest = 2019	' this should be 2010 or later (else program may not run correctly)

' workfile that contains the pop adjustment factors for all past years, up to and including the !yr_latest
%popadj_factors_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1\cps_popadj_2019.wf1"	' full path
%popadj_factors = "cps_popadj_2019"		' file name only

' BKDO1 bank that contains data for n, l, e, p, and r; need these for population shares when breaking longer age intervals into shorter ones
%bkdo1_path = "E:\usr\econ\Budget\dat\bkdo1.bnk"	' full path 
%bkdo1 = "bkdo1"		' short name

' cnipopdata databank; need it for single-year-of-age data
%cnipop_path = "E:\usr\econ\EcoDev\dat\cnipopdata.bnk"	' full path
%cnipop = "cnipopdata"		' short name

' D-bank for latest TR; need for computing population for single-year-of-age data  QQQQ -- what should this be in relation to !yr_latest ? If !yr_latest = 2-19, should this be dtr192? Or will we not have dtr192 yet at the time we are doing 209 BLS adjustments?
%dbank_path = "\\LRSERV1\usr\eco.18\bnk\2018-0112-1212 TR182\dtr182.bnk"	' full path
%dbank = "dtr182"		' short name

' OP-bank for latest TR; need for computing population for single-year-of-age data
%opbank_path = "E:\usr\econ\EcoDev\dat\op1182o.bnk"	' full path
%opbank = "op1182o"		' short name


' file to be created by this program
%this_file = "bls_adjust" 	' name only
%new_file_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1" + "\" + %new_file + ".wf1"	' full path

' Do you want the output file(s) to be saved on this run? 
' Enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "N" 		' enter "N" or "Y" (case sensitive)

' ******* END of update section **********


wfcreate(wf={%this_file},page=annual) a 1965 2199

'*****************************************************************************
'****	ANNUAL CPS methodology change adjustments:                   	****
'****   	for LFPRs and unemployment rates                          				****
'*****************************************************************************

'Initialize add factors to 0 and mult factors to 1:

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


'LFPRs;

'Additive:
SMPL 1965 1993
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


'**************************************************************************************************************
'**** Multiplicative:                                                                        													****
'****                                                                                        															****
'**** Set the LFPR adjustments equal to labor force adjustments, since all other adjustments 	****
'**** being made are for the labor force (not LFPRs) concept.                                						****
'****                                                                                        															****
'**** Multiplicative adjustment to the LFPR is equivalent to multiplicative adjustment to LC:		****
'****   LFPR = LC/cniPOP                                                                     											****
'****                                                                                        															****
'****   LFPR * adj = (LC * adj)/cniPOP                                                       										****
'**************************************************************************************************************
                
           
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






'**************************************************************
'**** CPS methodology change adjustments                *****
'****   ANNUAL to QUARTERLY:                            			*****
'**************************************************************
pagecreate(page=quarterly) q 1965 2199

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
'*****                            NON-MARCH DATA:    **************************
'*****                            (standard CPS)            **************************
'************************************************************************
'************************************************************************


'*************************************************************************************************************
'**** Multfactors for 1990 Census:                                                         										****
'****   This set of commands creates dummy variables that phase-in the 1990 Census change, 	****
'****       over a 10-year period;                                                         												****
'****  (1981 to 1989)                                                                      													****
'*************************************************************************************************************

pageselect annual
smpl 1965 2199

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

smpl 1965 1980
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_90c=1
	next
next

series n16o_90c   =  1 

smpl 1990 2199
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_90c=1
	next
next

series n16o_90c   =  1 



' Civilian Labor Force:
smpl 1965 2199
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

smpl 1965 1980
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_90c=1
	next
next

series l16o_90c   =  1 

smpl 1990 2199
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_90c=1
	next
next

series l16o_90c   =  1 

' Unemployment Rates:
smpl 1965 2199

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

smpl 1965 1980
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_90c=1
	next
next

series r16o_90c   =  1 

smpl 1990 2199
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_90c=1
	next
next

series r16o_90c   =  1 

' Employment:
smpl 1965 2199

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

smpl 1965 1980
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_90c=1
	next
next

series e16o_90c   =  1 

smpl 1990 2199
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_90c=1
	next
next

series e16o_90c   =  1 


'*************************************************************************************************************
'**** Multfactors for 2000 Census:                                                         										****
'****   This set of commands creates dummy variables that phase-in the 2000 Census change, 	****
'****       over a 10-year period;                                                         												****
'****       (1991 to 1999)                                                                 													****
'*************************************************************************************************************

' Civilian Noninstitutional Population:
smpl 1965 2199

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

smpl 1965 1990
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_00c=1
	next
next

series n16o_00c   =  1 

smpl 2000 2199
for %n nm nf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%n}{%a}_00c=1
	next
next

series n16o_00c   =  1 


' Civilian Labor Force:
smpl 1965 2199
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

smpl 1965 1990
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_00c=1
	next
next

series l16o_00c   =  1 

smpl 2000 2199
for %l lm lf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%l}{%a}_00c=1
	next
next

series l16o_00c   =  1 


' Unemployment Rates:
smpl 1965 2199
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

smpl 1965 1990
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_00c=1
	next
next

series r16o_00c   =  1 

smpl 2000 2199
for %r rm rf
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%r}{%a}_00c=1
	next
next

series r16o_00c   =  1 

' Employment:
smpl 1965 2199

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

smpl 1965 1990
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_00c=1
	next
next

series e16o_00c   =  1 

smpl 2000 2199
for %e em ef
	for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
		series {%e}{%a}_00c=1
	next
next

series e16o_00c   =  1 
    
smpl 1965 2199
'********************************************************************************
'****    Make ANNUAL adjustments QUARTERLY for standard CPS: 		****
'********************************************************************************

'SET FREQUENCY QUARTERLY;
pageselect quarterly 

for %c  n l r e
	copy(c=linearl) annual\{%c}16o_90c
	smpl 1965Q1 1965Q4
	{%c}16o_90c = 1
	smpl 1990Q1 1990Q4
	{%c}16o_90c = 1
	smpl @all
	
	copy(c=linearl) annual\{%c}16o_00c
	smpl 1965Q1 1965
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
			
   			'interpolate |#c|#s|#a|_90c = |#c|#s|#a|_90c.a linear average;
   			'interpolate |#c|#s|#a|_00c = |#c|#s|#a|_00c.a linear average;
		next
	next
next


   'interpolate n16o_90c = n16o_90c.a linear average;
   'interpolate l16o_90c = l16o_90c.a linear average;
   'interpolate r16o_90c = r16o_90c.a linear average;
   'interpolate e16o_90c = e16o_90c.a linear average;

   'interpolate n16o_00c = n16o_00c.a linear average;
   'interpolate l16o_00c = l16o_00c.a linear average;
   'interpolate r16o_00c = r16o_00c.a linear average;
   'interpolate e16o_00c = e16o_00c.a linear average;


'***************************************************************************************
'****    Get monthly interpolated values of annual population adjustments 		****
'***************************************************************************************

'***** HERE IS WHERE THE ADJUSTMENTS ARE UPDATED:
pagecreate(page=monthly) m 1965 2199
'obey 'adjustcpsdata_2018';

%sex_m = "m f"
%age_m = "16o 1617 1619 1819 2024 2554 2534 3544 4554 5564 65o" 

' create a list of yrs (pop adj for which we need to create)  to be used in series names, hence these are srtings
' NOTE: this list is used MANY times below to create/modify various series --------------------- Should this be moved on top of the program for ease of locating it?
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

' load the pop adjustment factors from a separate file, indicated at the start of the program (%popadj_factors_path)
' vectors in that file are stored in page 'monthly' and named popadjYEAR, such as popadj2016, popadj2017, popadj2018 etc
' also copy the string vector 'names' that contains the names of all concept-sex-age groups, such as n16o, nf1619, lm2024, rf65o, etc.

wfopen %popadj_factors_path
copy {%popadj_factors}::monthly\popadj* {%this_file}::monthly\
copy {%popadj_factors}::monthly\names {%this_file}::monthly\
wfclose {%popadj_factors}

!rows = @rows(names) 	' number of concept-sex-age groups; each year, we need to compute the adjustment factyor for all of them.

' compute the adjustment factors for each series and each year

for !yr=!yr_first to !yr_latest
	for !r = 1 to !rows
		%y = @right(@str(!yr),2)
		%ser = names(!r) + "_" + %y + "p"			' NAME of the series to be modified
		if !yr <2013 then									' determine start of the sample over which the series is to be modified; 2013 in the year when popadj from the 2010 decennial data became available
			!smpl_start = 2000
			else if !yr <2023 then						' 2023 is the date when popadj from the 2020 decennial census will be available (I assume), if not -- adjust the year here!!!
					!smpl_start = 2010				' ADD another *else if* statement here when we get past 2020 decennial census and need to change the sample period for the adjustment again!!!
					endif
		endif
		!smpl_end = !yr - 1								' determine end of the sample over which the series is to be modified
		%v = 	"popadj" + @str(!yr)						' NAME of the vector that holds the relevant popadj factors
		smpl {!smpl_start}m1 {!smpl_end}m12	' period over which to apply adjustments
		!m = @obssmpl									' number of months in the sample period (used in the adj formula below)
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
		{%ser} =  1/!m * {%v}(!r)/!d + {%ser}(-1)	' the main adjustment formula
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
				copy(c=a) monthly\{%ser}{%s}{%a}_{%p}p
			next
		next
	next
next



'******** Collapse monthly adjustments to quarterly *********
'pageselect quaterly
'smpl 1965 2099

'for t = n, l, e, r, p;
'for s = m, f;
'for a = 16o, 1619, 1617, 1819, 2024, 2554, 2534, 3544, 4554, 5564, 65o;
'for p = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;

'collapse |#t|#s|#a|_|#p|p.q = |#t|#s|#a|_|#p|p.m average;

'end;
'end;
'end;
'end;

'for t = n, l, e, r, p;
'for p = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;

'collapse |#t|16o_|#p|p.q = |#t|16o_|#p|p.m average;

'end;
'end;

' ***** split age groups 2534 3544 4554 5564 65o into smaller 5-yr groups.*****

' need soem series from BKDO1 to craete weightd
dbopen(type=aremos) %bkdo1_path

for %ser n l e
	for %p {%yrs}
		for %s m f
			series {%ser}{%s}2529_{%p}p = {%ser}{%s}2534_{%p}p * ({%bkdo1}::{%ser}{%s}2529 / {%bkdo1}::{%ser}{%s}2534)
			series {%ser}{%s}3034_{%p}p = {%ser}{%s}2534_{%p}p * ({%bkdo1}::{%ser}{%s}3034 / {%bkdo1}::{%ser}{%s}2534)
			
			series {%ser}{%s}3539_{%p}p = {%ser}{%s}3544_{%p}p * ({%bkdo1}::{%ser}{%s}3539 / {%bkdo1}::{%ser}{%s}3544)
			series {%ser}{%s}4044_{%p}p = {%ser}{%s}3544_{%p}p * ({%bkdo1}::{%ser}{%s}4044 / {%bkdo1}::{%ser}{%s}3544)
			
			series {%ser}{%s}4549_{%p}p = {%ser}{%s}4554_{%p}p * ({%bkdo1}::{%ser}{%s}4549 / {%bkdo1}::{%ser}{%s}4554)
			series {%ser}{%s}5054_{%p}p = {%ser}{%s}4554_{%p}p * ({%bkdo1}::{%ser}{%s}5054 / {%bkdo1}::{%ser}{%s}4554)
			
			series {%ser}{%s}5559_{%p}p = {%ser}{%s}5564_{%p}p * ({%bkdo1}::{%ser}{%s}5559 / {%bkdo1}::{%ser}{%s}5564)
			series {%ser}{%s}6064_{%p}p = {%ser}{%s}5564_{%p}p * ({%bkdo1}::{%ser}{%s}6064 / {%bkdo1}::{%ser}{%s}5564)
			
			series {%ser}{%s}6569_{%p}p = {%ser}{%s}65o_{%p}p * ({%bkdo1}::{%ser}{%s}6569 / {%bkdo1}::{%ser}{%s}65o)
			series {%ser}{%s}7074_{%p}p = {%ser}{%s}65o_{%p}p * ({%bkdo1}::{%ser}{%s}7074 / {%bkdo1}::{%ser}{%s}65o)
			series {%ser}{%s}75o_{%p}p = {%ser}{%s}65o_{%p}p * ({%bkdo1}::{%ser}{%s}75o / {%bkdo1}::{%ser}{%s}65o)
		next
	next
next

for %ser r p				' these are computed using proportion of LABOR FORCE, i.e. l{%s}2534 etc.
	for %p {%yrs}
		for %s m f
			series {%ser}{%s}2529_{%p}p = {%ser}{%s}2534_{%p}p * ({%bkdo1}::l{%s}2529 / {%bkdo1}::l{%s}2534)
			series {%ser}{%s}3034_{%p}p = {%ser}{%s}2534_{%p}p * ({%bkdo1}::l{%s}3034 / {%bkdo1}::l{%s}2534)
			
			series {%ser}{%s}3539_{%p}p = {%ser}{%s}3544_{%p}p * ({%bkdo1}::l{%s}3539 / {%bkdo1}::l{%s}3544)
			series {%ser}{%s}4044_{%p}p = {%ser}{%s}3544_{%p}p * ({%bkdo1}::l{%s}4044 / {%bkdo1}::l{%s}3544)
			
			series {%ser}{%s}4549_{%p}p = {%ser}{%s}4554_{%p}p * ({%bkdo1}::l{%s}4549 / {%bkdo1}::l{%s}4554)
			series {%ser}{%s}5054_{%p}p = {%ser}{%s}4554_{%p}p * ({%bkdo1}::l{%s}5054 / {%bkdo1}::l{%s}4554)
			
			series {%ser}{%s}5559_{%p}p = {%ser}{%s}5564_{%p}p * ({%bkdo1}::l{%s}5559 / {%bkdo1}::l{%s}5564)
			series {%ser}{%s}6064_{%p}p = {%ser}{%s}5564_{%p}p * ({%bkdo1}::l{%s}6064 / {%bkdo1}::l{%s}5564)
			
			series {%ser}{%s}6569_{%p}p = {%ser}{%s}65o_{%p}p * ({%bkdo1}::l{%s}6569 / {%bkdo1}::l{%s}65o)
			series {%ser}{%s}7074_{%p}p = {%ser}{%s}65o_{%p}p * ({%bkdo1}::l{%s}7074 / {%bkdo1}::l{%s}65o)
			series {%ser}{%s}75o_{%p}p = {%ser}{%s}65o_{%p}p * ({%bkdo1}::l{%s}75o / {%bkdo1}::l{%s}65o)
		next
	next
next

close @db

' NOTE:  BKDO1 has quarterly values for only a sub-sample (e.g. 1976 to 2018, end year changes as we get more data); outside this sub-sample the values are NAs, so they produce NAs for all the above series.
' Recode these NAs to zeros
for %ser n l e r p
	for %p {%yrs}
		for %s m f
			for %a 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
				{%ser}{%s}{%a}_{%p}p = @nan({%ser}{%s}{%a}_{%p}p, 0)
			next
		next
	next
next


'for t = n, l, e;
' for s = m, f;
'  for y = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;
'***************************************************************************
'**************SHOULD THE WORK BANK BE BKDO1?          **********
'***************************************************************************
'series |#t|#s|2529_|#y|p = |#t|#s|2534_|#y|p * (work:|#t|#s|2529/work:|#t|#s|2534);  
'series |#t|#s|3034_|#y|p = |#t|#s|2534_|#y|p * (work:|#t|#s|3034/work:|#t|#s|2534);

'series |#t|#s|3539_|#y|p = |#t|#s|3544_|#y|p * (work:|#t|#s|3539/work:|#t|#s|3544);
'series |#t|#s|4044_|#y|p = |#t|#s|3544_|#y|p * (work:|#t|#s|4044/work:|#t|#s|3544);

'series |#t|#s|4549_|#y|p = |#t|#s|4554_|#y|p * (work:|#t|#s|4549/work:|#t|#s|4554);
'series |#t|#s|5054_|#y|p = |#t|#s|4554_|#y|p * (work:|#t|#s|5054/work:|#t|#s|4554);

'series |#t|#s|5559_|#y|p = |#t|#s|5564_|#y|p * (work:|#t|#s|5559/work:|#t|#s|5564);
'series |#t|#s|6064_|#y|p = |#t|#s|5564_|#y|p * (work:|#t|#s|6064/work:|#t|#s|5564);

'series |#t|#s|6569_|#y|p = |#t|#s|65o_|#y|p  * (work:|#t|#s|6569/work:|#t|#s|65o);
'series |#t|#s|7074_|#y|p = |#t|#s|65o_|#y|p  * (work:|#t|#s|7074/work:|#t|#s|65o);
'series |#t|#s|75o_|#y|p  = |#t|#s|65o_|#y|p  * (work:|#t|#s|75o/work:|#t|#s|65o);

'  end;
' end;
'end;


'for t = p, r;
' for s = m, f;
 ' for y = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;
'*******************************************************
'**************SHOULD THE WORK BANK BE BKDO1? **********
'*******************************************************
'series |#t|#s|2529_|#y|p = |#t|#s|2534_|#y|p * (work:l|#s|2529/work:l|#s|2534); 
'series |#t|#s|3034_|#y|p = |#t|#s|2534_|#y|p * (work:l|#s|3034/work:l|#s|2534);

'series |#t|#s|3539_|#y|p = |#t|#s|3544_|#y|p * (work:l|#s|3539/work:l|#s|3544);
'series |#t|#s|4044_|#y|p = |#t|#s|3544_|#y|p * (work:l|#s|4044/work:l|#s|3544);

'series |#t|#s|4549_|#y|p = |#t|#s|4554_|#y|p * (work:l|#s|4549/work:l|#s|4554);
'series |#t|#s|5054_|#y|p = |#t|#s|4554_|#y|p * (work:l|#s|5054/work:l|#s|4554);

'series |#t|#s|5559_|#y|p = |#t|#s|5564_|#y|p * (work:l|#s|5559/work:l|#s|5564);
'series |#t|#s|6064_|#y|p = |#t|#s|5564_|#y|p * (work:l|#s|6064/work:l|#s|5564);

'series |#t|#s|6569_|#y|p = |#t|#s|65o_|#y|p  * (work:l|#s|6569/work:l|#s|65o);
'series |#t|#s|7074_|#y|p = |#t|#s|65o_|#y|p  * (work:l|#s|7074/work:l|#s|65o);
'series |#t|#s|75o_|#y|p  = |#t|#s|65o_|#y|p  * (work:l|#s|75o/work:l|#s|65o);

'  end;
' end;
'end;
     


'******** Collapse quarterly adjustments to annual *********

pageselect annual
smpl 1965 2099

for %ser n l e r p
	for %p {%yrs}
		copy(c=a) quarterly\{%ser}16o_{%p}p
		for %a 16o 1619 2024 2534 3544 4554 5564 65o 1617 1819 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
			for %s m f
				copy(c=a) quarterly\{%ser}{%s}{%a}_{%p}p
			next
		next
	next
next



'set freq a;

'for t = n, l, e, r, p;
'for s = m, f;
'for a = 16o, 1619, 2024, 2534, 3544, 4554, 5564, 65o,
 '       1617, 1819, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 75o;
'for p = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;

'collapse |#t|#s|#a|_|#p|p.a = |#t|#s|#a|_|#p|p.q average;

'end;
'end;
'end;
'end;
 

'for t = n, l, e, r, p;
'for p = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;

'collapse |#t|16o_|#p|p.a = |#t|16o_|#p|p.q average;

'end;
'end;




'******** Save adjustments in databank (monthly, quarterly, annual) *********

'****** Should I do this? Or would we instead simply keep the series in the workfile????? *************

'open adjustments18.bnk;
'copy series work:*_94m*.* as adjustments18:*.*;
'copy series work:*_94m_m*.* as adjustments18:*.*;
'copy series work:*_90c*.* as adjustments18:*.*;
'copy series work:*_00c*.* as adjustments18:*.*;
'copy series work:*_03p*.* as adjustments18:*.*;
'copy series work:*_04p*.* as adjustments18:*.*;
'copy series work:*_05p*.* as adjustments18:*.*;
'copy series work:*_06p*.* as adjustments18:*.*;
'copy series work:*_07p*.* as adjustments18:*.*;
'copy series work:*_08p*.* as adjustments18:*.*;
'copy series work:*_09p*.* as adjustments18:*.*;
'copy series work:*_10p*.* as adjustments18:*.*;
'copy series work:*_11p*.* as adjustments18:*.*;
'copy series work:*_12p*.* as adjustments18:*.*;
'copy series work:*_13p*.* as adjustments18:*.*;
'copy series work:*_14p*.* as adjustments18:*.*;
'copy series work:*_15p*.* as adjustments18:*.*;
'copy series work:*_16p*.* as adjustments18:*.*;
'copy series work:*_18p*.* as adjustments18:*.*;
'close adjustments18;

'!abort;
'set freq q;

'******** Create Quarterly AND Annual aggregate multiplicative adjustments by age & sex (1990 Census, 2000 Census, 1994 CPS methodological adjustments 		*********
'******** Create Quarterly AND Annual  aggregate additive adjustments by age & sex (2003 through 2017 population adjustments                            				*********

for %pages quarterly annual
	pageselect {%pages}
	smpl @all

	' modify the string list %yrs to remove first element (Put this on top of program for ease of reference????)
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

 
 
'******** Create quarterly adjusted values for labor force, cni population, unemployement rates, employment, *********
'******** by incorporating the multiplicative and additive adjustments for each age/sex group                *********

pageselect quarterly 
smpl @all

' created adjusted series, name_adj, by applying the adjustment to series pulled from BKDO1
' NOTE: series in BKDO1 have NAs after ther last historical observation. Since this loop uses these series, the resulting series name_adj will also have NSa after the last historical observation. This is appropriate, since we are constructing the adjusted HISTORICAL values.
dbopen(type=aremos) %bkdo1_path
for %ser n l e r 
	series  {%ser}16o_adj = ({%bkdo1}::{%ser}16o * {%ser}16o_adjm) + {%ser}16o_adja
	%text = "Computed by applying adjustment factors to series " +  %ser + "16o from BKDO1."
	{%ser}16o_adj.label(r) {%text}
	for %a 1617 1819 1619 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 16o
		for %s m f
			series {%ser}{%s}{%a}_adj = ({%bkdo1}::{%ser}{%s}{%a} * {%ser}{%s}{%a}_adjm) + {%ser}{%s}{%a}_adja
			%text = "Computed by applying adjustment factors to series " +  %ser + %s + %a + " from BKDO1."
			{%ser}{%s}{%a}_adj.label(r) {%text} 
		next
	next
next

close @db

' Check for consistency -- do 16o adjusted series (n16o_adj, l16o_adj, etc) equal to the sum of 16o serues by sex? 
'series test_n = nm16o_adj + nf16o_adj - n16o_adj
'series test_l = lm16o_adj + lf16o_adj - l16o_adj
'series test_e = em16o_adj + ef16o_adj - e16o_adj
'series test_r = rm16o_adj *(lm16o_adj/l16o_adj) + rf16o_adj*(lf16o_adj/l16o_adj) - r16o_adj

'group n_aggr n16o_adj nm16o_adj nf16o_adj test_n
'group l_aggr l16o_adj lm16o_adj lf16o_adj test_l
'group e_aggr e16o_adj em16o_adj ef16o_adj test_e
'group r_aggr r16o_adj rm16o_adj rf16o_adj test_r

' Conclusion: NO, the values are not consistent. Example: 2018Q3 un rates rm16o_adj = 3.8, rf_16o_adj = 3.8, but r16o_adj = 3.83333 . There are MANY other cases.
' Therefore, we will compute another version of all 16o series (n16o, nm16o, nf16o -- and thw same  for l, e, r, p) by summing up the age components parts. Names these series ..._adjs (*s* for 'sum')


' compute an alternative version for all 16o_adj series (*m16o, *f16o, *16o for *=n, l, e, r) by summing up components age groups. Name these series *16o_adjs (for 'adjusted sum').

smpl @all 
for %ser n l e
	for %s m f 
		smpl 1965q1 1976q2
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
		smpl 1981q1 2199q4
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
	smpl 1965q1 1976q2
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
	smpl 2000q1 2199q4
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

for %a 16o 1617 1819 1619 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o
	for %s m f 
		series p{%s}{%a}_adj = l{%s}{%a}_adj / n{%s}{%a}_adj
		%text = "Computed as the ratio of adjusted series l" + %s + %a + "_adj to n" + %s + %a+ "_adj."
		p{%s}{%a}_adj.label(r) {%text}
	next
next
series p16o_adj = l16o_adj / n16o_adj
%text = "Computed as the ratio of adjusted series l16o_adj to n16o_adj."
p16o_adj.label(r) {%text}
' based on the alternatoive series _adjs for 16o group
series pm16o_adjs = lm16o_adjs / nm16o_adjs
%text = "Computed as the ratio of alternative adjusted series lm16o_adjs to nm16o_adjs. (Note *s* in _adjS.)"
pm16o_adjs.label(r) {%text}

series pf16o_adjs = lf16o_adjs / nf16o_adjs
%text = "Computed as the ratio of alternative adjusted series lf16o_adjs to nf16o_adjs. (Note *s* in _adjS.)"
pf16o_adjs.label(r) {%text}

series p16o_adjs = l16o_adjs / n16o_adjs
%text = "Computed as the ratio of alternative adjusted series l16o_adjs to n16o_adjs. (Note *s* in _adjS.)"
p16o_adjs.label(r) {%text}


' Copy ..._adj and ..._adjs series into a separate page

pagecreate(page=data_q) q 1965 2199

copy quarterly\*_adj
copy quarterly\*_adjs

' Compare ...16o_adj and ...16o_adjs series
'for %ser n l e r p
'	series {%ser}16o_ck = {%ser}16o_adj - {%ser}16o_adjs
'	series {%ser}f16o_ck = {%ser}f16o_adj - {%ser}f16o_adjs
'	series {%ser}m16o_ck = {%ser}m16o_adj - {%ser}m16o_adjs
'next


'******** Create annual aggregate multiplicative adjustments by age & sex (1990 Census, 2000 Census, 1994 CPS methodological adjustments 
'******** Create annual aggregate additive adjustments by age & sex (2003 through 2018) population adjustments                   

' *** NOTE: I did this above in EViews by looping through quarterly and annual page in a single loop. I made an assumption that all these formulas are EXACTLY  identical to the same ones in quarterly frequency.  --- PV 5/21/2019
 pageselect annual

dbopen(type=aremos) %bkdo1_path

series lm16o  = {%bkdo1}::lm1619 + {%bkdo1}::lm2024 + {%bkdo1}::lm2534 + {%bkdo1}::lm3544 + {%bkdo1}::lm4554 + {%bkdo1}::lm5564 + {%bkdo1}::lm65o
series lf16o  = {%bkdo1}::lf1619 + {%bkdo1}::lf2024 + {%bkdo1}::lf2534 + {%bkdo1}::lf3544 + {%bkdo1}::lf4554 + {%bkdo1}::lf5564 + {%bkdo1}::lf65o

series rm1619 = (({%bkdo1}::rm1617*{%bkdo1}::lm1617)+({%bkdo1}::rm1819*{%bkdo1}::lm1819))/{%bkdo1}::lm1619
series rf1619 = (({%bkdo1}::rf1617*{%bkdo1}::lf1617)+({%bkdo1}::rf1819*{%bkdo1}::lf1819))/{%bkdo1}::lf1619

series nm16o = {%bkdo1}::nm16o
series nf16o = {%bkdo1}::nf16o

series rm16o = {%bkdo1}::rum
series rf16o = {%bkdo1}::ruf

series r16o  = {%bkdo1}::ru
series n16o  = {%bkdo1}::n16o
series l16o  = {%bkdo1}::lc


'******** Create annual adjusted values for labor force, cni population, unemployement rates, employment, 
'******** by incorporating the multiplicative and additive adjustments for each age/sex group   

' I combined several formulas from Aremos code
' In the end, I pull all n l r **and e** series from bkdo1 (all annual) and compute the adjusted values in this loop. Conform that this is what I should be doing!!!

for %ser l n r e
	for %s m f 
		for %a 1617 1819 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 16o
			series {%ser}{%s}{%a}_aadj = ({%bkdo1}::{%ser}{%s}{%a} * {%ser}{%s}{%a}_adjm) + {%ser}{%s}{%a}_adja
			%text = "Computed by applying adjustment factors to series " +  %ser + %s + %a + " from BKDO1."
			{%ser}{%s}{%a}_aadj.label(r) {%text} 

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

series em16o_aadj = ({%bkdo1}::em16o * em16o_adjm) + em16o_adja
series ef16o_aadj = ({%bkdo1}::ef16o * ef16o_adjm) + ef16o_adja
series e16o_aadj  = ({%bkdo1}::e16o * e16o_adjm)  + e16o_adja

for %ser em16o ef16o e16o
	%text = "Computed by applying adjustment factors to series " +  %ser + "from BKDO1."
	{%ser}_aadj.label(r) {%text}
next

series r16o_aadj = (rm16o_aadj * lm16o_aadj + rf16o_aadj * lf16o_aadj) / l16o_aadj
%text1 = "Computed as weighted average of rm16o_aadj and rf16o_aadj."
%text2 = "The weights are the ratios of l{sex}16o_aadj to l16o_aadj."  
r16o_aadj.label(r) {%text1}
r16o_aadj.label(r) {%text2}

for %ser l n	e	' these require series from BKDO1 (I added e here, which was not in Aremos)
	for %s m f
		series {%ser}{%s}1619_aadj = ({%bkdo1}::{%ser}{%s}1619 * {%ser}{%s}1619_adjm) + {%ser}{%s}1619_adja
	next
next

for %ser r 		' these series already in the workfile (I moved e from here to above)
	for %s m f
		series {%ser}{%s}1619_aadj = ({%ser}{%s}1619 * {%ser}{%s}1619_adjm) + {%ser}{%s}1619_adja
	next
next


for %a 5559 6064 6569 7074			' need these series for later calculations
	for %s m f
		fetch l{%s}{%a}.a
	next
next

close @db


' compute an alternative version for all 16o_aadj series (*m16o, *f16o, *16o for *=n, l, e, r) by summing up components age groups. Name these series *16o_aadjs (for 'adjusted sum').

smpl @all 
for %ser n l e
	for %s m f 
		smpl 1965 1976
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
		smpl 1981 2199
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
	smpl 1965 1976
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
	smpl 2000 2199
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

for %a 1617 1819 2024 2529 3034 2534 3539 4044 3544 4549 5054 4554 5559 6064 5564 6569 7074 65o 75o 1619 16o
	for %s m f 
		series p{%s}{%a}_aadj = l{%s}{%a}_aadj / n{%s}{%a}_aadj
		%text = "Computed as the ratio of adjusted series l" + %s + %a + "_aadj to n" + %s + %a+ "_aadj."
		p{%s}{%a}_aadj.label(r) {%text}
	next
next
series p16o_aadj = l16o_aadj / n16o_aadj
%text = "Computed as the ratio of adjusted series l16o_aadj to n16o_aadj."
p16o_aadj.label(r) {%text}
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


' Copy ..._aadj and ..._aadjs series into a separate page
pagecreate(page=data_a) a 1965 2199

copy annual\*_aadj
copy annual\*_aadjs

' Compare ...16o_aadj and ...16o_aadjs series
'for %ser n l e r p
'	series {%ser}16o_ck = {%ser}16o_aadj - {%ser}16o_aadjs
'	series {%ser}f16o_ck = {%ser}f16o_aadj - {%ser}f16o_aadjs
'	series {%ser}m16o_ck = {%ser}m16o_aadj - {%ser}m16o_aadjs
'next

pageselect annual


dbopen(type=aremos) %cnipop_path

for %ser p l
	for %s m f
		for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
			fetch {%ser}{%s}{%a}.a
		next
	next
next

close @db


for %s m f
	for %a 5559 6064 6569 7074
		series p{%s}{%a}_90c = l{%s}{%a}_90c / n{%s}{%a}_90c
		series p{%s}{%a}_00c = l{%s}{%a}_00c / n{%s}{%a}_00c
	next
next

'for %a 5559 6064 6569 7074 75o		' this was in Aremos code, but it makes no sense to do this as the adjustment to p cannot be equal to the ratio of adjustments ot l and n. 
'	for %s m f 
'		for %y {%yrs}
'			series p{%s}{%a}_{%y}p = l{%s}{%a}_{%y}p / n{%s}{%a}_{%y}p
'		next
'	next
'next

'create p..._##p series for single-year-of-age groups. Note that since, at this point, l{s}{a} series have values only for 2004 onward, the p..._##p series will also have values for 2004 onward only.
for %s m f
	for %a 55 56 57 58 59
		for %y {%yrs}
			series p{%s}{%a}_{%y}p = p{%s}5564_{%y}p * (l{%s}{%a} / l{%s}5559)
		next
	next
next

for %s m f
	for %a 60 61 62 63 64
		for %y {%yrs}
			series p{%s}{%a}_{%y}p = p{%s}5564_{%y}p * (l{%s}{%a} / l{%s}6064)
		next
	next
next

for %s m f
	for %a 65 66 67 68 69
		for %y {%yrs}
			series p{%s}{%a}_{%y}p = p{%s}65o_{%y}p * (l{%s}{%a} / l{%s}6569)
		next
	next
next

for %s m f
	for %a 70 71 72 73 74
		for %y {%yrs}
			series p{%s}{%a}_{%y}p = p{%s}65o_{%y}p * (l{%s}{%a} / l{%s}7074)
		next
	next
next

dbopen(type=aremos) %dbank_path		' D-bank is used here to pull population data (n... series). Should this be BKDO1 instead? (b/c we used BKDO1 for this purpose above).

dbopen(type=aremos) %opbank_path

' NOTE: these loops REPLACE values for l{s}55 through l{s}74 that were loaded from cnipopdata earlier. Is this intentional? The values computed here differ from the values loaded from CNIPOPDATA (for 2004 onward, the period for which CPIPOPDATA has data for l... series).
' It seems that it would make sence ot do this computation earelier, BEFORE computing p..._##p series above -- then we would be able to have p..._##p series for the entore sample period, instead of 2004 onward only.
for %s m f 
	for %a 55 56 57 58 59
		l{%s}{%a} = p{%s}{%a} * {%dbank}::n{%s}5559 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}5559)
		series n{%s}{%a} = {%dbank}::n{%s}5559 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}5559)
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
 
	for %a 60 61 62 63 64
		l{%s}{%a} = p{%s}{%a} * {%dbank}::n{%s}6064 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}6064)
		series n{%s}{%a} = {%dbank}::n{%s}6064 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}6064)
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
	
	for %a 65 66 67 68 69
		l{%s}{%a} = p{%s}{%a} * {%dbank}::n{%s}6569 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}6569)
		series n{%s}{%a} = {%dbank}::n{%s}6569 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}6569)
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
	
	for %a 70 71 72 73 74
		l{%s}{%a} = p{%s}{%a} * {%dbank}::n{%s}7074 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}7074)
		series n{%s}{%a} = {%dbank}::n{%s}7074 * ({%opbank}::n{%s}{%a} / {%opbank}::n{%s}7074)
'		series l{%s}{%a}_ck = l{%s}{%a} - l{%s}{%a}_c
	next
next

close @db


' compare single year of age L... series loaded from cnipop data to computed above
'for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
'	group lm{%a}_gr lm{%a} lm{%a}_c
'	group lf{%a}_gr lf{%a} lf{%a}_c
'next

dbopen(type=aremos) %bkdo1_path	

for %ser l n
	for %s m f
		for %y {%yrs}			' Aremos does this only for %y 03 11 12. I did it for all %y. Both l..._..p and  n..._..p series have at leats some nonzero values for ALL %y's.
			for %a 65 66 67 68 69
				series {%ser}{%s}{%a}_{%y}p = {%ser}{%s}6569_{%y}p * ({%ser}{%s}{%a} / {%bkdo1}::{%ser}{%s}6569)
			next
			for %a 70 71 72 73 74
				series {%ser}{%s}{%a}_{%y}p = {%ser}{%s}7074_{%y}p * ({%ser}{%s}{%a} / {%bkdo1}::{%ser}{%s}7074)
			next
		next
	next
next

' This loop replaces p{%s}{%a}_{%y}p for ages 65 thought 74. Same series for all ages 55 to 74 were computed above (look for loops following the note -- 'create p..._##p series for single-year-of-age groups.--). That earlier computation produces p{%s}{%a}_{%y}p series with NAs up to 2003, and values for 2004 onward. The loop below REPLACES values for ages 65 to 74, and these values would exists for 1965 onward. 
' QQQQQ: Why aren't we also replacing values for  ages 55 yto 64? In other words, why do we treat ages 65 to 74 differently from ages 55 to 64?
for %s m f 			
	for %y {%yrs}		'Aremos had this only for %y 03 11 12 b/c those are the only years when these adjustment are non-zero. I ran it for all years -- easier to code. Most years produce zero series for p{%s}{%a}_{%y}p, which is not a problem, as these are additive adjustment in the later computations.
		for %a 65 66 67 68 69
			p{%s}{%a}_{%y}p = p{%s}6569_{%y}p * (l{%s}{%a} / {%bkdo1}::l{%s}6569)
		next
		for %a 70 71 72 73 74
			p{%s}{%a}_{%y}p = p{%s}7074_{%y}p * (l{%s}{%a} / {%bkdo1}::l{%s}7074)
		next
	next
next

'At this point some of the p{%s}{%a}_{%y}p series have many NAs in earlier years (up to 2004), but other have values. 
'QQQQQ: Should I replace thr NAs with zeros so that when we later compute p..._adj, we do not carry though al the NAs?

close @db


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


for %s m f 
	for %a {%a1}
		series p{%s}{%a}_adj =  (p{%s}{%a} * p{%s}{%a}_adjm) + p{%s}{%a}_adja
		'make groups for comparison
		group g_p{%s}{%a} p{%s}{%a}_adj p{%s}{%a}
	next
next

' copy p..._adj series into a separate page
pageselect data_a

copy annual\p*_adj

pageselect annual

stop   ' ****** EViews code ends here!!!!!!!






' ************************ AREMOS code below
       
 
' the below is done in the ANNUAL frequency 

'open bkdo1.BNK;

'series lm16o  = bkdo1:lm1619 + bkdo1:lm2024 + bkdo1:lm2534 + bkdo1:lm3544 + bkdo1:lm4554 + bkdo1:lm5564 + bkdo1:lm65o;
'series lf16o  = bkdo1:lf1619 + bkdo1:lf2024 + bkdo1:lf2534 + bkdo1:lf3544 + bkdo1:lf4554 + bkdo1:lf5564 + bkdo1:lf65o;

'series rm1619 = ((bkdo1:rm1617*bkdo1:lm1617)+(bkdo1:rm1819*bkdo1:lm1819))/bkdo1:lm1619;
'series rf1619 = ((bkdo1:rf1617*bkdo1:lf1617)+(bkdo1:rf1819*bkdo1:lf1819))/bkdo1:lf1619;

'series nm16o = bkdo1:nm16o;
'series nf16o = bkdo1:nf16o;

'series rm16o = bkdo1:rum;
'series rf16o = bkdo1:ruf;

'series r16o  = bkdo1:ru;
'series n16o  = bkdo1:n16o;
'series l16o  = bkdo1:lc;


'******** Create annual adjusted values for labor force, cni population, unemployement rates, employment, 
'******** by incorporating the multiplicative and additive adjustments for each age/sex group             


for c = l, n, r;
for s = m, f;
for a = 1617, 1819, 
        2024, 
        2529, 3034, 2534,
        3539, 4044, 3544,
        4549, 5054, 4554,
        5559, 6064, 5564,
        6569, 7074, 
        65o, 75o;
   series |#c|#s|#a|_aadj = (bkdo1:|#c|#s|#a| * |#c|#s|#a|_adjm) + |#c|#s|#a|_adja;
end;
end;
end;

series nm16o_aadj = (nm16o * nm16o_adjm) + nm16o_adja;
series nf16o_aadj = (nf16o * nf16o_adjm) + nf16o_adja;
series n16o_aadj  = (n16o  * n16o_adjm)  + n16o_adja;


series lm16o_aadj = (lm16o * lm16o_adjm) + lm16o_adja;
series lf16o_aadj = (lf16o * lf16o_adjm) + lf16o_adja;
series l16o_aadj  = (l16o  * l16o_adjm)  + l16o_adja;



for c = e;
for s = m, f;
for a = 1617, 1819, 1619,
        2024, 
        2529, 3034, 2534,
        3539, 4044, 3544,
        4549, 5054, 4554,
        5559, 6064, 5564,
        6569, 7074, 
        65o, 75o, 16o;
   collapse |#c|#s|#a|.a = |#c|#s|#a|.q average;			' This seems to be creating annual values by averaging quaterly ones. HOWEVER, there are no quarterly values for e>>> series in the page 'quaterly'. Should I get them from BKDO1? But then, why get quarterly values from BKDO1 when it also has annual ones? Wouldn't it be simpler to get the annual valeus from BKDO1?
end;
end;
end;

   collapse e16o.a = e16o.q average;

'***

for c = e;
for s = m, f;
for a = 1617, 1819, 
        2024, 
        2529, 3034, 2534,
        3539, 4044, 3544,
        4549, 5054, 4554,
        5559, 6064, 5564,
        6569, 7074, 
        65o, 75o, 16o;
   series |#c|#s|#a|_aadj = (work:|#c|#s|#a| * |#c|#s|#a|_adjm) + |#c|#s|#a|_adja;
end;
end;
end;

'***


for c = l, n;
for s = m, f;
for a = 1619;
   series |#c|#s|#a|_aadj = (bkdo1:|#c|#s|#a| * |#c|#s|#a|_adjm) + |#c|#s|#a|_adja;
end;
end;
end;

for c = r, e;
for s = m, f;
for a = 1619;
   series |#c|#s|#a|_aadj = (work:|#c|#s|#a| * |#c|#s|#a|_adjm) + |#c|#s|#a|_adja;
end;
end;
end;

'***


for c = l, n;
for s = m, f;
   series <77 80> |#c|#s|16o|_aadj = |#c|#s|1617|_aadj 
                                   + |#c|#s|1819|_aadj 
                                   + |#c|#s|2024|_aadj 
                                   + |#c|#s|2529|_aadj
                                   + |#c|#s|3034|_aadj 
                                   + |#c|#s|3539|_aadj 
                                   + |#c|#s|4044|_aadj 
                                   + |#c|#s|4549|_aadj 
                                   + |#c|#s|5054|_aadj
                                   + |#c|#s|5559|_aadj 
                                   + |#c|#s|6064|_aadj 
                                   + |#c|#s|65o|_aadj;
end;
end;

for c = l, n, e;
for s = m, f;
   series <81 199> |#c|#s|16o|_aadj = |#c|#s|1617|_aadj 
                                    + |#c|#s|1819|_aadj 
                                    + |#c|#s|2024|_aadj 
                                    + |#c|#s|2529|_aadj
                                    + |#c|#s|3034|_aadj 
                                    + |#c|#s|3539|_aadj 
                                    + |#c|#s|4044|_aadj
                                    + |#c|#s|4549|_aadj 
                                    + |#c|#s|5054|_aadj
                                    + |#c|#s|5559|_aadj 
                                    + |#c|#s|6064|_aadj 
                                    + |#c|#s|6569|_aadj 
                                    + |#c|#s|7074|_aadj
                                    + |#c|#s|75o|_aadj;
end;
end;


for s = m, f;
series r|#s|16o_aadj = (r|#s|1617_aadj * l|#s|1617_aadj 
                     +  r|#s|1819_aadj * l|#s|1819_aadj 
                     +  r|#s|2024_aadj * l|#s|2024_aadj 
                     +  r|#s|2529_aadj * l|#s|2529_aadj
                     +  r|#s|3034_aadj * l|#s|3034_aadj 
                     +  r|#s|3539_aadj * l|#s|3539_aadj
                     +  r|#s|4044_aadj * l|#s|4044_aadj 
                     +  r|#s|4549_aadj * l|#s|4549_aadj
                     +  r|#s|5054_aadj * l|#s|5054_aadj 
                     +  r|#s|5559_aadj * l|#s|5559_aadj
                     +  r|#s|6064_aadj * l|#s|6064_aadj 
                     +  r|#s|6569_aadj * l|#s|6569_aadj
                     +  r|#s|7074_aadj * l|#s|7074_aadj 
                     +  r|#s|75o_aadj  * l|#s|75o_aadj)/l|#s|16o_aadj;
end;





for c = l, n, e;
'   series |#c|16o|_aadj = (|#c|16o * |#c|16o_aadjm) + |#c|16o_aadja;
   series |#c|16o|_aadj = |#c|m16o_aadj + |#c|f16o_aadj;
end;

series r16o_aadj = ((rm16o_aadj*lm16o_aadj) + (rf16o_aadj*lf16o_aadj))/l16o_aadj;




index nm16o_aadj;
index nf16o_aadj;
index n16o_aadj;

index lm16o_aadj;
index lf16o_aadj;
index l16o_aadj;

index em16o_aadj;
index ef16o_aadj;
index e16o_aadj;

index rm16o_aadj;
index rf16o_aadj;
index r16o_aadj;


'abort;

'close bkdo1;

for s = m, f;
for a = 16o,
        1617, 1819, 1619,
        2024,
        2529, 3034, 2534,
        3539, 4044, 3544,
        4549, 5054, 4554,
        5559, 6064, 5564,
        6569, 7074, 
        65o, 75o, 16o;
   series p|#s|#a|_aadj = l|#s|#a|_aadj/n|#s|#a|_aadj;
'   series e|#s|#a|_aadj = l|#s|#a|_aadj * (1 - (r|#s|#a|_aadj/100));
end;
end;

   series p16o_aadj = l16o_aadj/n16o_aadj;

'***********************************
'open bkdr1;
 open cnipopdata;

     copy series pm55 as work:*;
     copy series pm56 as work:*;
     copy series pm57 as work:*;
     copy series pm58 as work:*;
     copy series pm59 as work:*;
     copy series pm60 as work:*;
     copy series pm61 as work:*;
     copy series pm62 as work:*;
     copy series pm63 as work:*;
     copy series pm64 as work:*;
     copy series pm65 as work:*;
     copy series pm66 as work:*;
     copy series pm67 as work:*;
     copy series pm68 as work:*;
     copy series pm69 as work:*;
     copy series pm70 as work:*;
     copy series pm71 as work:*;
     copy series pm72 as work:*;
     copy series pm73 as work:*;
     copy series pm74 as work:*;
     
     copy series pf55 as work:*;
     copy series pf56 as work:*;
     copy series pf57 as work:*;
     copy series pf58 as work:*;
     copy series pf59 as work:*;
     copy series pf60 as work:*;
     copy series pf61 as work:*;
     copy series pf62 as work:*;
     copy series pf63 as work:*;
     copy series pf64 as work:*;
     copy series pf65 as work:*;
     copy series pf66 as work:*;
     copy series pf67 as work:*;
     copy series pf68 as work:*;
     copy series pf69 as work:*;
     copy series pf70 as work:*;
     copy series pf71 as work:*;
     copy series pf72 as work:*;
     copy series pf73 as work:*;
     copy series pf74 as work:*;


     copy series lm55 as work:*;
     copy series lm56 as work:*;
     copy series lm57 as work:*;
     copy series lm58 as work:*;
     copy series lm59 as work:*;
     copy series lm60 as work:*;
     copy series lm61 as work:*;
     copy series lm62 as work:*;
     copy series lm63 as work:*;
     copy series lm64 as work:*;
     copy series lm65 as work:*;
     copy series lm66 as work:*;
     copy series lm67 as work:*;
     copy series lm68 as work:*;
     copy series lm69 as work:*;
     copy series lm70 as work:*;
     copy series lm71 as work:*;
     copy series lm72 as work:*;
     copy series lm73 as work:*;
     copy series lm74 as work:*;
     
     copy series lf55 as work:*;
     copy series lf56 as work:*;
     copy series lf57 as work:*;
     copy series lf58 as work:*;
     copy series lf59 as work:*;
     copy series lf60 as work:*;
     copy series lf61 as work:*;
     copy series lf62 as work:*;
     copy series lf63 as work:*;
     copy series lf64 as work:*;
     copy series lf65 as work:*;
     copy series lf66 as work:*;
     copy series lf67 as work:*;
     copy series lf68 as work:*;
     copy series lf69 as work:*;
     copy series lf70 as work:*;
     copy series lf71 as work:*;
     copy series lf72 as work:*;
     copy series lf73 as work:*;
     copy series lf74 as work:*;

close cnipopdata;


set freq a;


for s = m, f;

series p|#s|5559_90c = l|#s|5559_90c/n|#s|5559_90c;
series p|#s|6064_90c = l|#s|6064_90c/n|#s|6064_90c;
series p|#s|6569_90c = l|#s|6569_90c/n|#s|6569_90c;
series p|#s|7074_90c = l|#s|7074_90c/n|#s|7074_90c;

series p|#s|5559_00c = l|#s|5559_00c/n|#s|5559_00c;
series p|#s|6064_00c = l|#s|6064_00c/n|#s|6064_00c;
series p|#s|6569_00c = l|#s|6569_00c/n|#s|6569_00c;
series p|#s|7074_00c = l|#s|7074_00c/n|#s|7074_00c;

series p|#s|5559_04p = l|#s|5559_04p/n|#s|5559_04p;
series p|#s|5559_05p = l|#s|5559_05p/n|#s|5559_05p;
series p|#s|5559_06p = l|#s|5559_06p/n|#s|5559_06p;
series p|#s|5559_07p = l|#s|5559_07p/n|#s|5559_07p;
series p|#s|5559_08p = l|#s|5559_08p/n|#s|5559_08p;
series p|#s|5559_09p = l|#s|5559_09p/n|#s|5559_09p;
series p|#s|5559_10p = l|#s|5559_10p/n|#s|5559_10p;
series p|#s|5559_11p = l|#s|5559_11p/n|#s|5559_11p;
series p|#s|5559_12p = l|#s|5559_12p/n|#s|5559_12p;
series p|#s|5559_13p = l|#s|5559_13p/n|#s|5559_13p;
series p|#s|5559_14p = l|#s|5559_14p/n|#s|5559_14p;
series p|#s|5559_15p = l|#s|5559_15p/n|#s|5559_15p;

series p|#s|6064_03p = l|#s|6064_03p/n|#s|6064_03p;
series p|#s|6064_04p = l|#s|6064_04p/n|#s|6064_04p;
series p|#s|6064_05p = l|#s|6064_05p/n|#s|6064_05p;
series p|#s|6064_06p = l|#s|6064_06p/n|#s|6064_06p;
series p|#s|6064_07p = l|#s|6064_07p/n|#s|6064_07p;
series p|#s|6064_08p = l|#s|6064_08p/n|#s|6064_08p;
series p|#s|6064_09p = l|#s|6064_09p/n|#s|6064_09p;
series p|#s|6064_10p = l|#s|6064_10p/n|#s|6064_10p;
series p|#s|6064_11p = l|#s|6064_11p/n|#s|6064_11p;
series p|#s|6064_12p = l|#s|6064_12p/n|#s|6064_12p;
series p|#s|6064_13p = l|#s|6064_13p/n|#s|6064_13p;
series p|#s|6064_14p = l|#s|6064_14p/n|#s|6064_14p;
series p|#s|6064_15p = l|#s|6064_15p/n|#s|6064_15p;

series p|#s|6569_04p = l|#s|6569_04p/n|#s|6569_04p;
series p|#s|6569_05p = l|#s|6569_05p/n|#s|6569_05p;
series p|#s|6569_06p = l|#s|6569_06p/n|#s|6569_06p;
series p|#s|6569_07p = l|#s|6569_07p/n|#s|6569_07p;
series p|#s|6569_08p = l|#s|6569_08p/n|#s|6569_08p;
series p|#s|6569_09p = l|#s|6569_09p/n|#s|6569_09p;
series p|#s|6569_10p = l|#s|6569_10p/n|#s|6569_10p;
series p|#s|6569_11p = l|#s|6569_11p/n|#s|6569_11p;
series p|#s|6569_12p = l|#s|6569_12p/n|#s|6569_12p;
series p|#s|6569_13p = l|#s|6569_13p/n|#s|6569_13p;
series p|#s|6569_14p = l|#s|6569_14p/n|#s|6569_14p;
series p|#s|6569_15p = l|#s|6569_15p/n|#s|6569_15p;

series p|#s|7074_03p = l|#s|7074_03p/n|#s|7074_03p;
series p|#s|7074_04p = l|#s|7074_04p/n|#s|7074_04p;
series p|#s|7074_05p = l|#s|7074_05p/n|#s|7074_05p;
series p|#s|7074_06p = l|#s|7074_06p/n|#s|7074_06p;
series p|#s|7074_07p = l|#s|7074_07p/n|#s|7074_07p;
series p|#s|7074_08p = l|#s|7074_08p/n|#s|7074_08p;
series p|#s|7074_09p = l|#s|7074_09p/n|#s|7074_09p;
series p|#s|7074_10p = l|#s|7074_10p/n|#s|7074_10p;
series p|#s|7074_11p = l|#s|7074_11p/n|#s|7074_11p;
series p|#s|7074_12p = l|#s|7074_12p/n|#s|7074_12p;
series p|#s|7074_13p = l|#s|7074_13p/n|#s|7074_13p;
series p|#s|7074_14p = l|#s|7074_14p/n|#s|7074_14p;
series p|#s|7074_15p = l|#s|7074_15p/n|#s|7074_15p;

series p|#s|75o_03p = l|#s|75o_03p/n|#s|75o_03p;
series p|#s|75o_04p = l|#s|75o_04p/n|#s|75o_04p;
series p|#s|75o_05p = l|#s|75o_05p/n|#s|75o_05p;
series p|#s|75o_06p = l|#s|75o_06p/n|#s|75o_06p;
series p|#s|75o_07p = l|#s|75o_07p/n|#s|75o_07p;
series p|#s|75o_08p = l|#s|75o_08p/n|#s|75o_08p;
series p|#s|75o_09p = l|#s|75o_09p/n|#s|75o_09p;
series p|#s|75o_10p = l|#s|75o_10p/n|#s|75o_10p;
series p|#s|75o_11p = l|#s|75o_11p/n|#s|75o_11p;
series p|#s|75o_12p = l|#s|75o_12p/n|#s|75o_12p;
series p|#s|75o_13p = l|#s|75o_13p/n|#s|75o_13p;
series p|#s|75o_14p = l|#s|75o_14p/n|#s|75o_14p;
series p|#s|75o_15p = l|#s|75o_15p/n|#s|75o_15p;



  
  for a = 55, 56, 57, 58, 59;
  for t = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;
     series p|#s|#a|_|#t|p = p|#s|5564_|#t|p * (work:l|#s|#a|/l|#s|5559);
  end;
  end;

  for a = 60, 61, 62, 63, 64;
  for t = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13,  14, 15, 16, 17, 18;
     series p|#s|#a|_|#t|p = p|#s|5564_|#t|p * (work:l|#s|#a|/l|#s|6064);
  end;
  end;

  for a = 65, 66, 67, 68, 69;
  for t = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;
     series p|#s|#a|_|#t|p = p|#s|65o_|#t|p * (work:l|#s|#a|/l|#s|6569);
  end;
  end;

  for a = 70, 71, 72, 73, 74;
  for t = 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18;
     series p|#s|#a|_|#t|p = p|#s|65o_|#t|p * (work:l|#s|#a|/l|#s|7074);
  end;
  end;



end;




tell '08-26-2013 stopping point for checking';
'abort;


open op1182o, dtr182;

for s = m, f;
  for a = 55, 56, 57, 58, 59;
    series l|#s|#a| = p|#s|#a| * dtr182:n|#s|5559 * (op1182o:n|#s|#a|/op1182o:n|#s|5559);
    series n|#s|#a| =            dtr182:n|#s|5559 * (op1182o:n|#s|#a|/op1182o:n|#s|5559);
  end;
  
  for a = 60, 61, 62, 63, 64;
    series l|#s|#a| = p|#s|#a| * dtr182:n|#s|6064 * (op1182o:n|#s|#a|/op1182o:n|#s|6064);
    series n|#s|#a| =            dtr182:n|#s|6064 * (op1182o:n|#s|#a|/op1182o:n|#s|6064);
  end;

  for a = 65, 66, 67, 68, 69;
    series l|#s|#a| = p|#s|#a| * dtr182:n|#s|6569 * (op1182o:n|#s|#a|/op1182o:n|#s|6569);
    series n|#s|#a| =            dtr182:n|#s|6569 * (op1182o:n|#s|#a|/op1182o:n|#s|6569);
  end;

  for a = 70, 71, 72, 73, 74;
    series l|#s|#a| = p|#s|#a| * dtr182:n|#s|7074 * (op1182o:n|#s|#a|/op1182o:n|#s|7074);
    series n|#s|#a| =            dtr182:n|#s|7074 * (op1182o:n|#s|#a|/op1182o:n|#s|7074);
  end;
end;
 
close op1182o;
close dtr182;


open bkdo1;
for t = n, l;
 for s = m, f;
   for y = 03, 11, 12;
series |#t|#s|65_|#y|p = |#t|#s|6569_|#y|p * (work:|#t|#s|65/bkdo1:|#t|#s|6569);
series |#t|#s|66_|#y|p = |#t|#s|6569_|#y|p * (work:|#t|#s|66/bkdo1:|#t|#s|6569);
series |#t|#s|67_|#y|p = |#t|#s|6569_|#y|p * (work:|#t|#s|67/bkdo1:|#t|#s|6569);
series |#t|#s|68_|#y|p = |#t|#s|6569_|#y|p * (work:|#t|#s|68/bkdo1:|#t|#s|6569);
series |#t|#s|69_|#y|p = |#t|#s|6569_|#y|p * (work:|#t|#s|69/bkdo1:|#t|#s|6569);

series |#t|#s|70_|#y|p = |#t|#s|7074_|#y|p * (work:|#t|#s|70/bkdo1:|#t|#s|7074);
series |#t|#s|71_|#y|p = |#t|#s|7074_|#y|p * (work:|#t|#s|71/bkdo1:|#t|#s|7074);
series |#t|#s|72_|#y|p = |#t|#s|7074_|#y|p * (work:|#t|#s|72/bkdo1:|#t|#s|7074);
series |#t|#s|73_|#y|p = |#t|#s|7074_|#y|p * (work:|#t|#s|73/bkdo1:|#t|#s|7074);
series |#t|#s|74_|#y|p = |#t|#s|7074_|#y|p * (work:|#t|#s|74/bkdo1:|#t|#s|7074);

  end;
 end;
end;

 for s = m, f;
  for a = 65, 66, 67, 68, 69;
      series p|#s|#a|_03p = p|#s|6569_03p * (work:l|#s|#a|/bkdo1:l|#s|6569);
      series p|#s|#a|_11p = p|#s|6569_11p * (work:l|#s|#a|/bkdo1:l|#s|6569);
      series p|#s|#a|_12p = p|#s|6569_12p * (work:l|#s|#a|/bkdo1:l|#s|6569);
  end;
  for a = 70, 71, 72, 73, 74;
      series p|#s|#a|_03p = p|#s|6569_03p * (work:l|#s|#a|/bkdo1:l|#s|6569);
      series p|#s|#a|_11p = p|#s|6569_11p * (work:l|#s|#a|/bkdo1:l|#s|6569);
      series p|#s|#a|_12p = p|#s|6569_12p * (work:l|#s|#a|/bkdo1:l|#s|6569);
  end;
 end;
close bkdo1;


list a1 = 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74;
list a2 = 55, 56, 57, 58, 59;
list a3 = 60, 61, 62, 63, 64;
list a4 = 65, 66, 67, 68, 69;
list a5 = 70, 71, 72, 73, 74;
list a6 = 55, 56, 57, 58, 59, 60, 61, 62, 63, 64;
list a7 = 65, 66, 67, 68, 69, 70, 71, 72, 73, 74;


for s = m, f;
   for a = #a2;
     series p|#s|#a|_adjm = (l|#s|5564_94m_m * p|#s|5559_90c * p|#s|5559_00c);
     series p|#s|#a|_adja =  p|#s|#a|_03p   
                           + p|#s|#a|_04p 
                           + p|#s|#a|_05p 
                           + p|#s|#a|_06p 
                           + p|#s|#a|_07p 
                           + p|#s|#a|_08p 
                           + p|#s|#a|_09p
                           + p|#s|#a|_10p 
                           + p|#s|#a|_11p
                           + p|#s|#a|_12p 
                           + p|#s|#a|_13p 
                           + p|#s|#a|_14p
                           + p|#s|#a|_15p
                           + p|#s|#a|_16p
                           + p|#s|#a|_17p
                           + p|#s|#a|_18p
                           ;
   end;
   for a = #a3;
     series p|#s|#a|_adjm = (l|#s|5564_94m_m * p|#s|6064_90c * p|#s|6064_00c);
     series p|#s|#a|_adja =  p|#s|#a|_03p   
                           + p|#s|#a|_04p 
                           + p|#s|#a|_05p 
                           + p|#s|#a|_06p 
                           + p|#s|#a|_07p 
                           + p|#s|#a|_08p 
                           + p|#s|#a|_09p
                           + p|#s|#a|_10p 
                           + p|#s|#a|_11p 
                           + p|#s|#a|_12p
                           + p|#s|#a|_13p
                           + p|#s|#a|_14p
                           + p|#s|#a|_15p
                           + p|#s|#a|_16p
                           + p|#s|#a|_17p
                           + p|#s|#a|_18p
                           ;
   end;
   for a = #a4;
     series p|#s|#a|_adjm = (l|#s|65o_94m_m  * p|#s|6569_90c * p|#s|6569_00c);
     series p|#s|#a|_adja =  p|#s|#a|_03p   
                           + p|#s|#a|_04p 
                           + p|#s|#a|_05p 
                           + p|#s|#a|_06p 
                           + p|#s|#a|_07p 
                           + p|#s|#a|_08p 
                           + p|#s|#a|_09p
                           + p|#s|#a|_10p 
                           + p|#s|#a|_11p 
                           + p|#s|#a|_12p
                           + p|#s|#a|_13p
                           + p|#s|#a|_14p
                           + p|#s|#a|_15p
                           + p|#s|#a|_16p
                           + p|#s|#a|_17p
                           + p|#s|#a|_18p
                           ;
   end;
   for a = #a5;
     series p|#s|#a|_adjm = (l|#s|65o_94m_m  * p|#s|7074_90c * p|#s|7074_00c);
     series p|#s|#a|_adja =  p|#s|#a|_03p   
                           + p|#s|#a|_04p 
                           + p|#s|#a|_05p 
                           + p|#s|#a|_06p 
                           + p|#s|#a|_07p 
                           + p|#s|#a|_08p 
                           + p|#s|#a|_09p
                           + p|#s|#a|_10p 
                           + p|#s|#a|_11p 
                           + p|#s|#a|_12p
                           + p|#s|#a|_13p
                           + p|#s|#a|_14p
                           + p|#s|#a|_15p
                           + p|#s|#a|_16p
                           + p|#s|#a|_17p
                           + p|#s|#a|_18p
                           ;
   end;
end;

for s = m, f;
   for a = #a1;
     series p|#s|#a|_adj = (p|#s|#a| * p|#s|#a|_adjm) + p|#s|#a|_adja;
   end;
end;

'abort;


'*****print <100 107> pm56_adj;


'****************************************************
' Set the FIRST QUARTER observation as the annual observation:

set freq a;

for c = l, n, r, p, e;
for s = m, f;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044,
        4549, 5054, 5559, 6064, 6569, 7074, 
        75o,  65o,
        2534, 3544, 4554, 5564,
        16o,
        1619;
     collapse |#c|#s|#a|_1q     = |#c|#s|#a|.q first;
     collapse |#c|#s|#a|_1q_adj = |#c|#s|#a|_adj.q first;

'     collapse |#c|#s|#a|_2q     = |#c|#s|#a|.q first;
'     collapse |#c|#s|#a|_2q_adj = |#c|#s|#a|_adj.q first;

'     collapse |#c|#s|#a|_3q     = |#c|#s|#a|.q first;
'     collapse |#c|#s|#a|_3q_adj = |#c|#s|#a|_adj.q first;

     collapse |#c|#s|#a|_4q     = |#c|#s|#a|.q last;
     collapse |#c|#s|#a|_4q_adj = |#c|#s|#a|_adj.q last;



    
end;
end;
     collapse |#c|16o_1q     = |#c|16o.q first;

'     collapse |#c|16o_2q     = |#c|16o.q first;
'     collapse |#c|16o_3q     = |#c|16o.q first;
     collapse |#c|16o_4q     = |#c|16o.q last;



end;


'for s = m, f;
'for a = #a1;
'     collapse p|#s|#a|_1q     = p|#s|#a|.q first;
'     collapse p|#s|#a|_1q_adj = p|#s|#a|_adj.q first;
'
'     collapse p|#s|#a|_2q     = p|#s|#a|.q first;
'     collapse p|#s|#a|_2q_adj = p|#s|#a|_adj.q first;
'
'     collapse p|#s|#a|_3q     = p|#s|#a|.q first;
'     collapse p|#s|#a|_3q_adj = p|#s|#a|_adj.q first;
'
'     collapse p|#s|#a|_4q     = p|#s|#a|.q last;
'     collapse p|#s|#a|_4q_adj = p|#s|#a|_adj.q last;
'
'
'
'*****     collapse p|#s|#a|_adj    = p|#s|#a|_adj.q average;
'     
'end;
'end;


'abort;


'*********************************************
'*********************************************
'***********ADJUST MARCH CPS DATA*************
'*********************************************
'*********************************************
'*********************************************

open cpso68117;


set freq a;

copy series cpso68117:n* as work:*_mr.*;
copy series cpso68117:l* as work:*_mr.*;


copy series cpso68117:nf*nmnc18 as nf*nmn18_mr;
copy series cpso68117:lf*nmnc18 as lf*nmn18_mr;
copy series cpso68117:nf*msnc18 as nf*msn18_mr;
copy series cpso68117:lf*msnc18 as lf*msn18_mr;
copy series cpso68117:nf*manc18 as nf*man18_mr;
copy series cpso68117:lf*manc18 as lf*man18_mr;


copy SERIES   cpso68117:LF1415NMNC18   as   LF1415NMN18_mr;
copy SERIES   cpso68117:LF1617NMNC18   as   LF1617NMN18_mr;
copy SERIES   cpso68117:LF1619NMNC18   as   LF1619NMN18_mr;
copy SERIES   cpso68117:LF1819NMNC18   as   LF1819NMN18_mr;
copy SERIES   cpso68117:LF2024NMNC18   as   LF2024NMN18_mr;
copy SERIES   cpso68117:LF2529NMNC18   as   LF2529NMN18_mr;
copy SERIES   cpso68117:LF2534NMNC18   as   LF2534NMN18_mr;
copy SERIES   cpso68117:LF3034NMNC18   as   LF3034NMN18_mr;
copy SERIES   cpso68117:LF3539NMNC18   as   LF3539NMN18_mr;
copy SERIES   cpso68117:LF3544NMNC18   as   LF3544NMN18_mr;
copy SERIES   cpso68117:LF4044NMNC18   as   LF4044NMN18_mr;
copy SERIES   cpso68117:LF4549NMNC18   as   LF4549NMN18_mr;
copy SERIES   cpso68117:LF4554NMNC18   as   LF4554NMN18_mr;
copy SERIES   cpso68117:LF5054NMNC18   as   LF5054NMN18_mr;
copy SERIES   cpso68117:LF5559NMNC18   as   LF5559NMN18_mr;
copy SERIES   cpso68117:LF6061NMNC18   as   LF6061NMN18_mr;
copy SERIES   cpso68117:LF6264NMNC18   as   LF6264NMN18_mr;
copy SERIES   cpso68117:LF6569NMNC18   as   LF6569NMN18_mr;
copy SERIES   cpso68117:LF7074NMNC18   as   LF7074NMN18_mr;
copy SERIES   cpso68117:LF7579NMNC18   as   LF7579NMN18_mr;
copy SERIES   cpso68117:LF8084NMNC18   as   LF8084NMN18_mr;
copy SERIES   cpso68117:LF85ONMNC18    as   LF85ONMN18_mr;
             
copy SERIES   cpso68117:LF1415msNC18   as   LF1415msN18_mr;
copy SERIES   cpso68117:LF1617msNC18   as   LF1617msN18_mr;
copy SERIES   cpso68117:LF1619msNC18   as   LF1619msN18_mr;
copy SERIES   cpso68117:LF1819msNC18   as   LF1819msN18_mr;
copy SERIES   cpso68117:LF2024msNC18   as   LF2024msN18_mr;
copy SERIES   cpso68117:LF2529msNC18   as   LF2529msN18_mr;
copy SERIES   cpso68117:LF2534msNC18   as   LF2534msN18_mr;
copy SERIES   cpso68117:LF3034msNC18   as   LF3034msN18_mr;
copy SERIES   cpso68117:LF3539msNC18   as   LF3539msN18_mr;
copy SERIES   cpso68117:LF3544msNC18   as   LF3544msN18_mr;
copy SERIES   cpso68117:LF4044msNC18   as   LF4044msN18_mr;
copy SERIES   cpso68117:LF4549msNC18   as   LF4549msN18_mr;
copy SERIES   cpso68117:LF4554msNC18   as   LF4554msN18_mr;
copy SERIES   cpso68117:LF5054msNC18   as   LF5054msN18_mr;
copy SERIES   cpso68117:LF5559msNC18   as   LF5559msN18_mr;
copy SERIES   cpso68117:LF6061msNC18   as   LF6061msN18_mr;
copy SERIES   cpso68117:LF6264msNC18   as   LF6264msN18_mr;
copy SERIES   cpso68117:LF6569msNC18   as   LF6569msN18_mr;
copy SERIES   cpso68117:LF7074msNC18   as   LF7074msN18_mr;
copy SERIES   cpso68117:LF7579msNC18   as   LF7579msN18_mr;
copy SERIES   cpso68117:LF8084msNC18   as   LF8084msN18_mr;
copy SERIES   cpso68117:LF85OmsNC18    as   LF85OmsN18_mr;
             
copy SERIES   cpso68117:LF1415maNC18   as   LF1415maN18_mr;
copy SERIES   cpso68117:LF1617maNC18   as   LF1617maN18_mr;
copy SERIES   cpso68117:LF1619maNC18   as   LF1619maN18_mr;
copy SERIES   cpso68117:LF1819maNC18   as   LF1819maN18_mr;
copy SERIES   cpso68117:LF2024maNC18   as   LF2024maN18_mr;
copy SERIES   cpso68117:LF2529maNC18   as   LF2529maN18_mr;
copy SERIES   cpso68117:LF2534maNC18   as   LF2534maN18_mr;
copy SERIES   cpso68117:LF3034maNC18   as   LF3034maN18_mr;
copy SERIES   cpso68117:LF3539maNC18   as   LF3539maN18_mr;
copy SERIES   cpso68117:LF3544maNC18   as   LF3544maN18_mr;
copy SERIES   cpso68117:LF4044maNC18   as   LF4044maN18_mr;
copy SERIES   cpso68117:LF4549maNC18   as   LF4549maN18_mr;
copy SERIES   cpso68117:LF4554maNC18   as   LF4554maN18_mr;
copy SERIES   cpso68117:LF5054maNC18   as   LF5054maN18_mr;
copy SERIES   cpso68117:LF5559maNC18   as   LF5559maN18_mr;
copy SERIES   cpso68117:LF6061maNC18   as   LF6061maN18_mr;
copy SERIES   cpso68117:LF6264maNC18   as   LF6264maN18_mr;
copy SERIES   cpso68117:LF6569maNC18   as   LF6569maN18_mr;
copy SERIES   cpso68117:LF7074maNC18   as   LF7074maN18_mr;
copy SERIES   cpso68117:LF7579maNC18   as   LF7579maN18_mr;
copy SERIES   cpso68117:LF8084maNC18   as   LF8084maN18_mr;
copy SERIES   cpso68117:LF85OmaNC18    as   LF85OmaN18_mr;

copy SERIES   cpso68117:nf1415NMNC18   as   nf1415NMN18_mr;
copy SERIES   cpso68117:nf1617NMNC18   as   nf1617NMN18_mr;
copy SERIES   cpso68117:nf1619NMNC18   as   nf1619NMN18_mr;
copy SERIES   cpso68117:nf1819NMNC18   as   nf1819NMN18_mr;
copy SERIES   cpso68117:nf2024NMNC18   as   nf2024NMN18_mr;
copy SERIES   cpso68117:nf2529NMNC18   as   nf2529NMN18_mr;
copy SERIES   cpso68117:nf2534NMNC18   as   nf2534NMN18_mr;
copy SERIES   cpso68117:nf3034NMNC18   as   nf3034NMN18_mr;
copy SERIES   cpso68117:nf3539NMNC18   as   nf3539NMN18_mr;
copy SERIES   cpso68117:nf3544NMNC18   as   nf3544NMN18_mr;
copy SERIES   cpso68117:nf4044NMNC18   as   nf4044NMN18_mr;
copy SERIES   cpso68117:nf4549NMNC18   as   nf4549NMN18_mr;
copy SERIES   cpso68117:nf4554NMNC18   as   nf4554NMN18_mr;
copy SERIES   cpso68117:nf5054NMNC18   as   nf5054NMN18_mr;
copy SERIES   cpso68117:nf5559NMNC18   as   nf5559NMN18_mr;
copy SERIES   cpso68117:nf6061NMNC18   as   nf6061NMN18_mr;
copy SERIES   cpso68117:nf6264NMNC18   as   nf6264NMN18_mr;
copy SERIES   cpso68117:nf6569NMNC18   as   nf6569NMN18_mr;
copy SERIES   cpso68117:nf7074NMNC18   as   nf7074NMN18_mr;
copy SERIES   cpso68117:nf7579NMNC18   as   nf7579NMN18_mr;
copy SERIES   cpso68117:nf8084NMNC18   as   nf8084NMN18_mr;
copy SERIES   cpso68117:nf85ONMNC18    as   nf85ONMN18_mr;
             
copy SERIES   cpso68117:nf1415msNC18   as   nf1415msN18_mr;
copy SERIES   cpso68117:nf1617msNC18   as   nf1617msN18_mr;
copy SERIES   cpso68117:nf1619msNC18   as   nf1619msN18_mr;
copy SERIES   cpso68117:nf1819msNC18   as   nf1819msN18_mr;
copy SERIES   cpso68117:nf2024msNC18   as   nf2024msN18_mr;
copy SERIES   cpso68117:nf2529msNC18   as   nf2529msN18_mr;
copy SERIES   cpso68117:nf2534msNC18   as   nf2534msN18_mr;
copy SERIES   cpso68117:nf3034msNC18   as   nf3034msN18_mr;
copy SERIES   cpso68117:nf3539msNC18   as   nf3539msN18_mr;
copy SERIES   cpso68117:nf3544msNC18   as   nf3544msN18_mr;
copy SERIES   cpso68117:nf4044msNC18   as   nf4044msN18_mr;
copy SERIES   cpso68117:nf4549msNC18   as   nf4549msN18_mr;
copy SERIES   cpso68117:nf4554msNC18   as   nf4554msN18_mr;
copy SERIES   cpso68117:nf5054msNC18   as   nf5054msN18_mr;
copy SERIES   cpso68117:nf5559msNC18   as   nf5559msN18_mr;
copy SERIES   cpso68117:nf6061msNC18   as   nf6061msN18_mr;
copy SERIES   cpso68117:nf6264msNC18   as   nf6264msN18_mr;
copy SERIES   cpso68117:nf6569msNC18   as   nf6569msN18_mr;
copy SERIES   cpso68117:nf7074msNC18   as   nf7074msN18_mr;
copy SERIES   cpso68117:nf7579msNC18   as   nf7579msN18_mr;
copy SERIES   cpso68117:nf8084msNC18   as   nf8084msN18_mr;
copy SERIES   cpso68117:nf85OmsNC18    as   nf85OmsN18_mr;
             
copy SERIES   cpso68117:nf1415maNC18   as   nf1415maN18_mr;
copy SERIES   cpso68117:nf1617maNC18   as   nf1617maN18_mr;
copy SERIES   cpso68117:nf1619maNC18   as   nf1619maN18_mr;
copy SERIES   cpso68117:nf1819maNC18   as   nf1819maN18_mr;
copy SERIES   cpso68117:nf2024maNC18   as   nf2024maN18_mr;
copy SERIES   cpso68117:nf2529maNC18   as   nf2529maN18_mr;
copy SERIES   cpso68117:nf2534maNC18   as   nf2534maN18_mr;
copy SERIES   cpso68117:nf3034maNC18   as   nf3034maN18_mr;
copy SERIES   cpso68117:nf3539maNC18   as   nf3539maN18_mr;
copy SERIES   cpso68117:nf3544maNC18   as   nf3544maN18_mr;
copy SERIES   cpso68117:nf4044maNC18   as   nf4044maN18_mr;
copy SERIES   cpso68117:nf4549maNC18   as   nf4549maN18_mr;
copy SERIES   cpso68117:nf4554maNC18   as   nf4554maN18_mr;
copy SERIES   cpso68117:nf5054maNC18   as   nf5054maN18_mr;
copy SERIES   cpso68117:nf5559maNC18   as   nf5559maN18_mr;
copy SERIES   cpso68117:nf6061maNC18   as   nf6061maN18_mr;
copy SERIES   cpso68117:nf6264maNC18   as   nf6264maN18_mr;
copy SERIES   cpso68117:nf6569maNC18   as   nf6569maN18_mr;
copy SERIES   cpso68117:nf7074maNC18   as   nf7074maN18_mr;
copy SERIES   cpso68117:nf7579maNC18   as   nf7579maN18_mr;
copy SERIES   cpso68117:nf8084maNC18   as   nf8084maN18_mr;
copy SERIES   cpso68117:nf85OmaNC18    as   nf85OmaN18_mr;

series lm6064nm_mr = lm6061nm_mr + lm6264nm_mr;
series lm6064ms_mr = lm6061ms_mr + lm6264ms_mr;
series lm6064ma_mr = lm6061ma_mr + lm6264ma_mr;

series lf6064nm_mr = lf6061nm_mr + lf6264nm_mr;
  series lf6064nmc6u_mr = lf6061nmc6u_mr + lf6264nmc6u_mr;
  series lf6064nmnc6_mr = lf6061nmnc6_mr + lf6264nmnc6_mr;
  series lf6064nmc6o_mr = lf6061nmc6o_mr + lf6264nmc6o_mr;
  series lf6064nmn18_mr = lf6061nmn18_mr + lf6264nmn18_mr;
series lf6064ms_mr = lf6061ms_mr + lf6264ms_mr;
  series lf6064msc6u_mr = lf6061msc6u_mr + lf6264msc6u_mr;
  series lf6064msnc6_mr = lf6061msnc6_mr + lf6264msnc6_mr;
  series lf6064msc6o_mr = lf6061msc6o_mr + lf6264msc6o_mr;
  series lf6064msn18_mr = lf6061msn18_mr + lf6264msn18_mr;
series lf6064ma_mr = lf6061ma_mr + lf6264ma_mr;
  series lf6064mac6u_mr = lf6061mac6u_mr + lf6264mac6u_mr;
  series lf6064manc6_mr = lf6061manc6_mr + lf6264manc6_mr;
  series lf6064mac6o_mr = lf6061mac6o_mr + lf6264mac6o_mr;
  series lf6064man18_mr = lf6061man18_mr + lf6264man18_mr;

  series lf65onmc6u_mr = lf6569nmc6u_mr + lf7074nmc6u_mr + lf7579nmc6u_mr + lf8084nmc6u_mr + lf85onmc6u_mr;
  series lf65onmnc6_mr = lf6569nmnc6_mr + lf7074nmnc6_mr + lf7579nmnc6_mr + lf8084nmnc6_mr + lf85onmnc6_mr;
  series lf65omsc6u_mr = lf6569msc6u_mr + lf7074msc6u_mr + lf7579msc6u_mr + lf8084msc6u_mr + lf85omsc6u_mr;
  series lf65omsnc6_mr = lf6569msnc6_mr + lf7074msnc6_mr + lf7579msnc6_mr + lf8084msnc6_mr + lf85omsnc6_mr;
  series lf65omac6u_mr = lf6569mac6u_mr + lf7074mac6u_mr + lf7579mac6u_mr + lf8084mac6u_mr + lf85omac6u_mr;
  series lf65omanc6_mr = lf6569manc6_mr + lf7074manc6_mr + lf7579manc6_mr + lf8084manc6_mr + lf85omanc6_mr;
  series lf65onmc6o_mr = lf6569nmc6o_mr + lf7074nmc6o_mr + lf7579nmc6o_mr + lf8084nmc6o_mr + lf85onmc6o_mr;
  series lf65onmn18_mr = lf6569nmn18_mr + lf7074nmn18_mr + lf7579nmn18_mr + lf8084nmn18_mr + lf85onmn18_mr;
  series lf65omsc6o_mr = lf6569msc6o_mr + lf7074msc6o_mr + lf7579msc6o_mr + lf8084msc6o_mr + lf85omsc6o_mr;
  series lf65omsn18_mr = lf6569msn18_mr + lf7074msn18_mr + lf7579msn18_mr + lf8084msn18_mr + lf85omsn18_mr;
  series lf65omac6o_mr = lf6569mac6o_mr + lf7074mac6o_mr + lf7579mac6o_mr + lf8084mac6o_mr + lf85omac6o_mr;
  series lf65oman18_mr = lf6569man18_mr + lf7074man18_mr + lf7579man18_mr + lf8084man18_mr + lf85oman18_mr;

series nm6064nm_mr = nm6061nm_mr + nm6264nm_mr;
series nm6064ms_mr = nm6061ms_mr + nm6264ms_mr;
series nm6064ma_mr = nm6061ma_mr + nm6264ma_mr;

series nf6064nm_mr = nf6061nm_mr + nf6264nm_mr;
  series nf6064nmc6u_mr = nf6061nmc6u_mr + nf6264nmc6u_mr;
  series nf6064nmnc6_mr = nf6061nmnc6_mr + nf6264nmnc6_mr;
  series nf6064nmc6o_mr = nf6061nmc6o_mr + nf6264nmc6o_mr;
  series nf6064nmn18_mr = nf6061nmn18_mr + nf6264nmn18_mr;
series nf6064ms_mr = nf6061ms_mr + nf6264ms_mr;
  series nf6064msc6u_mr = nf6061msc6u_mr + nf6264msc6u_mr;
  series nf6064msnc6_mr = nf6061msnc6_mr + nf6264msnc6_mr;
  series nf6064msc6o_mr = nf6061msc6o_mr + nf6264msc6o_mr;
  series nf6064msn18_mr = nf6061msn18_mr + nf6264msn18_mr;
series nf6064ma_mr = nf6061ma_mr + nf6264ma_mr;
  series nf6064mac6u_mr = nf6061mac6u_mr + nf6264mac6u_mr;
  series nf6064manc6_mr = nf6061manc6_mr + nf6264manc6_mr;
  series nf6064mac6o_mr = nf6061mac6o_mr + nf6264mac6o_mr;
  series nf6064man18_mr = nf6061man18_mr + nf6264man18_mr;

  series nf65onmc6u_mr = nf6569nmc6u_mr + nf7074nmc6u_mr + nf7579nmc6u_mr + nf8084nmc6u_mr + nf85onmc6u_mr;
  series nf65onmnc6_mr = nf6569nmnc6_mr + nf7074nmnc6_mr + nf7579nmnc6_mr + nf8084nmnc6_mr + nf85onmnc6_mr;
  series nf65omsc6u_mr = nf6569msc6u_mr + nf7074msc6u_mr + nf7579msc6u_mr + nf8084msc6u_mr + nf85omsc6u_mr;
  series nf65omsnc6_mr = nf6569msnc6_mr + nf7074msnc6_mr + nf7579msnc6_mr + nf8084msnc6_mr + nf85omsnc6_mr;
  series nf65omac6u_mr = nf6569mac6u_mr + nf7074mac6u_mr + nf7579mac6u_mr + nf8084mac6u_mr + nf85omac6u_mr;
  series nf65omanc6_mr = nf6569manc6_mr + nf7074manc6_mr + nf7579manc6_mr + nf8084manc6_mr + nf85omanc6_mr;
  series nf65onmc6o_mr = nf6569nmc6o_mr + nf7074nmc6o_mr + nf7579nmc6o_mr + nf8084nmc6o_mr + nf85onmc6o_mr;
  series nf65onmn18_mr = nf6569nmn18_mr + nf7074nmn18_mr + nf7579nmn18_mr + nf8084nmn18_mr + nf85onmn18_mr;
  series nf65omsc6o_mr = nf6569msc6o_mr + nf7074msc6o_mr + nf7579msc6o_mr + nf8084msc6o_mr + nf85omsc6o_mr;
  series nf65omsn18_mr = nf6569msn18_mr + nf7074msn18_mr + nf7579msn18_mr + nf8084msn18_mr + nf85omsn18_mr;
  series nf65omac6o_mr = nf6569mac6o_mr + nf7074mac6o_mr + nf7579mac6o_mr + nf8084mac6o_mr + nf85omac6o_mr;
  series nf65oman18_mr = nf6569man18_mr + nf7074man18_mr + nf7579man18_mr + nf8084man18_mr + nf85oman18_mr;


series lm75onm_mr = lm65onm_mr - lm6569nm_mr - lm7074nm_mr;
series lm75oms_mr = lm65oms_mr - lm6569ms_mr - lm7074ms_mr;
series lm75oma_mr = lm65oma_mr - lm6569ma_mr - lm7074ma_mr;
series lf75onm_mr = lf65onm_mr - lf6569nm_mr - lf7074nm_mr;
  series lf75onmc6u_mr = lf65onmc6u_mr - lf6569nmc6u_mr - lf7074nmc6u_mr;
  series lf75onmnc6_mr = lf65onmnc6_mr - lf6569nmnc6_mr - lf7074nmnc6_mr;
  series lf75onmc6o_mr = lf65onmc6o_mr - lf6569nmc6o_mr - lf7074nmc6o_mr;
  series lf75onmn18_mr = lf65onmn18_mr - lf6569nmn18_mr - lf7074nmn18_mr;
series lf75oms_mr = lf65oms_mr - lf6569ms_mr - lf7074ms_mr;
  series lf75omsc6u_mr = lf65omsc6u_mr - lf6569msc6u_mr - lf7074msc6u_mr;
  series lf75omsnc6_mr = lf65omsnc6_mr - lf6569msnc6_mr - lf7074msnc6_mr;
  series lf75omsc6o_mr = lf65omsc6o_mr - lf6569msc6o_mr - lf7074msc6o_mr;
  series lf75omsn18_mr = lf65omsn18_mr - lf6569msn18_mr - lf7074msn18_mr;
series lf75oma_mr = lf65oma_mr - lf6569ma_mr - lf7074ma_mr;
  series lf75omac6u_mr = lf65omac6u_mr - lf6569mac6u_mr - lf7074mac6u_mr;
  series lf75omanc6_mr = lf65omanc6_mr - lf6569manc6_mr - lf7074manc6_mr;
  series lf75omac6o_mr = lf65omac6o_mr - lf6569mac6o_mr - lf7074mac6o_mr;
  series lf75oman18_mr = lf65oman18_mr - lf6569man18_mr - lf7074man18_mr;

series lm75o_mr   = lm75onm_mr + lm75oms_mr  + lm75oma_mr;
series lf75o_mr   = lf75onm_mr + lf75oms_mr  + lf75oma_mr;

series nm75onm_mr = nm65onm_mr - nm6569nm_mr - nm7074nm_mr;
series nm75oms_mr = nm65oms_mr - nm6569ms_mr - nm7074ms_mr;
series nm75oma_mr = nm65oma_mr - nm6569ma_mr - nm7074ma_mr;
series nf75onm_mr = nf65onm_mr - nf6569nm_mr - nf7074nm_mr;
  series nf75onmc6u_mr = nf65onmc6u_mr - nf6569nmc6u_mr - nf7074nmc6u_mr;
  series nf75onmnc6_mr = nf65onmnc6_mr - nf6569nmnc6_mr - nf7074nmnc6_mr;
  series nf75onmc6o_mr = nf65onmc6o_mr - nf6569nmc6o_mr - nf7074nmc6o_mr;
  series nf75onmn18_mr = nf65onmn18_mr - nf6569nmn18_mr - nf7074nmn18_mr;
series nf75oms_mr = nf65oms_mr - nf6569ms_mr - nf7074ms_mr;
  series nf75omsc6u_mr = nf65omsc6u_mr - nf6569msc6u_mr - nf7074msc6u_mr;
  series nf75omsnc6_mr = nf65omsnc6_mr - nf6569msnc6_mr - nf7074msnc6_mr;
  series nf75omsc6o_mr = nf65omsc6o_mr - nf6569msc6o_mr - nf7074msc6o_mr;
  series nf75omsn18_mr = nf65omsn18_mr - nf6569msn18_mr - nf7074msn18_mr;
series nf75oma_mr = nf65oma_mr - nf6569ma_mr - nf7074ma_mr;
  series nf75omac6u_mr = nf65omac6u_mr - nf6569mac6u_mr - nf7074mac6u_mr;
  series nf75omanc6_mr = nf65omanc6_mr - nf6569manc6_mr - nf7074manc6_mr;
  series nf75omac6o_mr = nf65omac6o_mr - nf6569mac6o_mr - nf7074mac6o_mr;
  series nf75oman18_mr = nf65oman18_mr - nf6569man18_mr - nf7074man18_mr;

series nm75o_mr   = nm75onm_mr + nm75oms_mr  + nm75oma_mr;
series nf75o_mr   = nf75onm_mr + nf75oms_mr  + nf75oma_mr;

for c = n, l;
for s = m, f;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 65o, 75o, 16o;
   series |#c|#s|#a|_adjf = |#c|#s|#a|_1q_adj/|#c|#s|#a|_mr;
   series |#c|#s|#a|_f    = |#c|#s|#a|_1q    /|#c|#s|#a|_mr;
end;
end;
end;

close *;

for c = n, l;
for s = m, f;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 65o, 75o, 16o;
   series |#c|#s|#a|_maj = |#c|#s|#a|_mr * |#c|#s|#a|_adjf;
   series |#c|#s|#a|_m = |#c|#s|#a|_mr * |#c|#s|#a|_f;
end;
end;
end;

for c = n, l;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 65o, 75o, 16o;
for m = nm, ms, ma;
   series |#c|m|#a|#m|_maj = |#c|m|#a|#m|_mr * |#c|m|#a|_adjf;
   series |#c|m|#a|#m|_m = |#c|m|#a|#m|_mr * |#c|m|#a|_f;
end;
end;
end;

for c = n, l;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 65o, 75o, 16o;
for m = nm, ms, ma;
   series |#c|f|#a|#m|_maj = |#c|f|#a|#m|_mr * |#c|f|#a|_adjf;
   series |#c|f|#a|#m|_m = |#c|f|#a|#m|_mr * |#c|f|#a|_f;
end;
end;
end;

for c = n, l;
!for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 75o, 65o;
for m = nm, ms, ma;
for k = nc6, c6u, c6o, n18;
   series |#c|f|#a|#m|#k|_maj = |#c|f|#a|#m|#k|_mr * |#c|f|#a|_adjf;
   series |#c|f|#a|#m|#k|_m = |#c|f|#a|#m|#k|_mr * |#c|f|#a|_f;
end;
end;
end;
end;





'**************************************
'**************************************
'**************************************
'**************************************
'**************************************
for s = m, f;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 65o, 75o, 16o;
   series p|#s|#a|_maj     = l|#s|#a|_maj   /n|#s|#a|_maj;
   series p|#s|#a|_m       = l|#s|#a|_m     /n|#s|#a|_m;
   series p|#s|#a|_1q      = l|#s|#a|_1q    /n|#s|#a|_1q;
   series p|#s|#a|_1q_adj  = l|#s|#a|_1q_adj/n|#s|#a|_1q_adj;

'   series e|#s|#a|_maj     = l|#s|#a|_maj    * (1 - (r|#s|#a|_maj/100));
'   series e|#s|#a|_m       = l|#s|#a|_m      * (1 - (r|#s|#a|_m/100));
   series e|#s|#a|_1q      = l|#s|#a|_1q     * (1 - (r|#s|#a|_1q/100));
   series e|#s|#a|_1q_adj  = l|#s|#a|_1q_adj * (1 - (r|#s|#a|_1q_adj/100));
end;
end;



for s = m, f;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 65o, 75o, 16o;
for m = nm, ms, ma;
   series p|#s|#a|#m|_maj     = l|#s|#a|#m|_maj   /n|#s|#a|#m|_maj;
   series p|#s|#a|#m|_m       = l|#s|#a|#m|_m     /n|#s|#a|#m|_m;
end;
end;
end;



for s = f;
'for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054;
for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 75o, 65o;
for m = nm, ms, ma;
for k = nc6, c6u, c6o, n18;
   series p|#s|#a|#m|#k|_maj     = l|#s|#a|#m|#k|_maj   /n|#s|#a|#m|#k|_maj;
   series p|#s|#a|#m|#k|_m       = l|#s|#a|#m|#k|_m     /n|#s|#a|#m|#k|_m;
end;
end;
end;
end;




'**************************************************
'**************************************************
'**************************************************
'**************************************************
'**************************************************
'   Next section creates child present indexes

open cpso68117.BNK;
copy series cpso68117:nf2024nmc6u3& as work:nf2024nmc6u3;
copy series cpso68117:nf2529nmc6u3& as work:nf2529nmc6u3;
copy series cpso68117:nf3034nmc6u3& as work:nf3034nmc6u3;
copy series cpso68117:nf3539nmc6u3& as work:nf3539nmc6u3;
copy series cpso68117:nf4044nmc6u3& as work:nf4044nmc6u3;
copy series cpso68117:nf4549nmc6u3& as work:nf4549nmc6u3;
copy series cpso68117:nf5054nmc6u3& as work:nf5054nmc6u3;

copy series cpso68117:nf2024msc6u3& as work:nf2024msc6u3;
copy series cpso68117:nf2529msc6u3& as work:nf2529msc6u3;
copy series cpso68117:nf3034msc6u3& as work:nf3034msc6u3;
copy series cpso68117:nf3539msc6u3& as work:nf3539msc6u3;
copy series cpso68117:nf4044msc6u3& as work:nf4044msc6u3;
copy series cpso68117:nf4549msc6u3& as work:nf4549msc6u3;
copy series cpso68117:nf5054msc6u3& as work:nf5054msc6u3;

copy series cpso68117:nf2024mac6u3& as work:nf2024mac6u3;
copy series cpso68117:nf2529mac6u3& as work:nf2529mac6u3;
copy series cpso68117:nf3034mac6u3& as work:nf3034mac6u3;
copy series cpso68117:nf3539mac6u3& as work:nf3539mac6u3;
copy series cpso68117:nf4044mac6u3& as work:nf4044mac6u3;
copy series cpso68117:nf4549mac6u3& as work:nf4549mac6u3;
copy series cpso68117:nf5054mac6u3& as work:nf5054mac6u3;

copy series cpso68117:nf1617nmc6u3& as work:nf1617nmc6u3;
copy series cpso68117:nf1819nmc6u3& as work:nf1819nmc6u3;

copy series cpso68117:nf1617msc6u3& as work:nf1617msc6u3;
copy series cpso68117:nf1819msc6u3& as work:nf1819msc6u3;

copy series cpso68117:nf1617mac6u3& as work:nf1617mac6u3;
copy series cpso68117:nf1819mac6u3& as work:nf1819mac6u3;


for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054;
for m = nm, ms, ma;
for c = c6u1, c6u2, c6u3;
    series nf|#a|#m|#c|maj = nf|#a|#m|#c|  * nf|#a|_adjf;
end;
end;
end;

close cpso68117;



tell'\\\\\Creating child present indexes for females by marital status';
for d = nm, ms, ma;
  for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054;
  
    series if|#a|#d|c6u_maj = ( nf|#a|#d|c6u1maj
                              + nf|#a|#d|c6u2maj * 2
                              + nf|#a|#d|c6u3maj * 3)/nf|#a|#d|c6u_maj;
  end;
end;

open blsadj18.BNK;
 copy series work:*1q.* as blsadj18:*.*;
 copy series work:*_m.* as blsadj18:*.*;
 copy series work:*_f.* as blsadj18:*.*;
 copy series work:*_aadj as blsadj18:*.*;
 copy series work:p*_adj as blsadj18:*.*;
 copy series work:*1q_adj.* as blsadj18:*.*;
 copy series work:*_maj.* as blsadj18:*.*;
 copy series work:*_adjf.* as blsadj18:*.*;
 copy series work:*_adjm.* as blsadj18:*.*;
 copy series work:*_adja.* as blsadj18:*.*;
 copy series work:*_94m.* as blsadj18:*.*;
 copy series work:*_94m_m.* as blsadj18:*.*;
 copy series work:*_90c.* as blsadj18:*.*;
 copy series work:*_00c.* as blsadj18:*.*;
 copy series work:*_03p.* as blsadj18:*.*;
 copy series work:*_04p.* as blsadj18:*.*;
 copy series work:*_05p.* as blsadj18:*.*;
 copy series work:*_06p.* as blsadj18:*.*;
 copy series work:*_07p.* as blsadj18:*.*;
 copy series work:*_08p.* as blsadj18:*.*;
 copy series work:*_09p.* as blsadj18:*.*;
 copy series work:*_10p.* as blsadj18:*.*;
 copy series work:*_11p.* as blsadj18:*.*;
 copy series work:*_12p.* as blsadj18:*.*;
 copy series work:*_13p.* as blsadj18:*.*;
 copy series work:*_14p.* as blsadj18:*.*;
 copy series work:*_15p.* as blsadj18:*.*;
 copy series work:*_16p.* as blsadj18:*.*;
 copy series work:*_17p.* as blsadj18:*.*;
 copy series work:*_adj.q as blsadj18:*.*;
 copy series work:*_4q*.* as blsadj18:*.*;
close blsadj18;

 
 
close *;
clear;



open blsadj18.BNK;

plot blsadj18:nf2024nmc6u_maj;
plot blsadj18:nf2024nmc6o_maj;

plot blsadj18:nf2529nmc6u_maj;
plot blsadj18:nf2529nmc6o_maj;

plot blsadj18:nf3034nmc6u_maj;
plot blsadj18:nf3034nmc6o_maj;

plot blsadj18:nf3539nmc6u_maj;
plot blsadj18:nf3539nmc6o_maj;

plot blsadj18:nf4044nmc6u_maj;
plot blsadj18:nf4044nmc6o_maj;

plot blsadj18:nf4549nmc6u_maj;
plot blsadj18:nf4549nmc6o_maj;



plot blsadj18:nf2024msc6u_maj;
plot blsadj18:nf2024msc6o_maj;

plot blsadj18:nf2529msc6u_maj;
plot blsadj18:nf2529msc6o_maj;

plot blsadj18:nf3034msc6u_maj;
plot blsadj18:nf3034msc6o_maj;

plot blsadj18:nf3539msc6u_maj;
plot blsadj18:nf3539msc6o_maj;

plot blsadj18:nf4044msc6u_maj;
plot blsadj18:nf4044msc6o_maj;

plot blsadj18:nf4549msc6u_maj;
plot blsadj18:nf4549msc6o_maj;




plot blsadj18:nf2024mac6u_maj;
plot blsadj18:nf2024mac6o_maj;

plot blsadj18:nf2529mac6u_maj;
plot blsadj18:nf2529mac6o_maj;

plot blsadj18:nf3034mac6u_maj;
plot blsadj18:nf3034mac6o_maj;

plot blsadj18:nf3539mac6u_maj;
plot blsadj18:nf3539mac6o_maj;

plot blsadj18:nf4044mac6u_maj;
plot blsadj18:nf4044mac6o_maj;

plot blsadj18:nf4549mac6u_maj;
plot blsadj18:nf4549mac6o_maj;





plot blsadj18:nf2024nmnc6_maj;
plot blsadj18:nf2024nmn18_maj;

plot blsadj18:nf2529nmnc6_maj;
plot blsadj18:nf2529nmn18_maj;

plot blsadj18:nf3034nmnc6_maj;
plot blsadj18:nf3034nmn18_maj;

plot blsadj18:nf3539nmnc6_maj;
plot blsadj18:nf3539nmn18_maj;

plot blsadj18:nf4044nmnc6_maj;
plot blsadj18:nf4044nmn18_maj;

plot blsadj18:nf4549nmnc6_maj;
plot blsadj18:nf4549nmn18_maj;



plot blsadj18:nf2024msnc6_maj;
plot blsadj18:nf2024msn18_maj;

plot blsadj18:nf2529msnc6_maj;
plot blsadj18:nf2529msn18_maj;

plot blsadj18:nf3034msnc6_maj;
plot blsadj18:nf3034msn18_maj;

plot blsadj18:nf3539msnc6_maj;
plot blsadj18:nf3539msn18_maj;

plot blsadj18:nf4044msnc6_maj;
plot blsadj18:nf4044msn18_maj;

plot blsadj18:nf4549msnc6_maj;
plot blsadj18:nf4549msn18_maj;



plot blsadj18:nf2024manc6_maj;
plot blsadj18:nf2024man18_maj;

plot blsadj18:nf2529manc6_maj;
plot blsadj18:nf2529man18_maj;

plot blsadj18:nf3034manc6_maj;
plot blsadj18:nf3034man18_maj;

plot blsadj18:nf3539manc6_maj;
plot blsadj18:nf3539man18_maj;

plot blsadj18:nf4044manc6_maj;
plot blsadj18:nf4044man18_maj;

plot blsadj18:nf4549manc6_maj;
plot blsadj18:nf4549man18_maj;





plot blsadj18:pf2024nmc6u_maj;
plot blsadj18:pf2024nmc6o_maj;

plot blsadj18:pf2529nmc6u_maj;
plot blsadj18:pf2529nmc6o_maj;

plot blsadj18:pf3034nmc6u_maj;
plot blsadj18:pf3034nmc6o_maj;

plot blsadj18:pf3539nmc6u_maj;
plot blsadj18:pf3539nmc6o_maj;

plot blsadj18:pf4044nmc6u_maj;
plot blsadj18:pf4044nmc6o_maj;



plot blsadj18:pf2024msc6u_maj;
plot blsadj18:pf2024msc6o_maj;

plot blsadj18:pf2529msc6u_maj;
plot blsadj18:pf2529msc6o_maj;

plot blsadj18:pf3034msc6u_maj;
plot blsadj18:pf3034msc6o_maj;

plot blsadj18:pf3539msc6u_maj;
plot blsadj18:pf3539msc6o_maj;

plot blsadj18:pf4044msc6u_maj;
plot blsadj18:pf4044msc6o_maj;




plot blsadj18:pf2024mac6u_maj;
plot blsadj18:pf2024mac6o_maj;

plot blsadj18:pf2529mac6u_maj;
plot blsadj18:pf2529mac6o_maj;

plot blsadj18:pf3034mac6u_maj;
plot blsadj18:pf3034mac6o_maj;

plot blsadj18:pf3539mac6u_maj;
plot blsadj18:pf3539mac6o_maj;

plot blsadj18:pf4044mac6u_maj;
plot blsadj18:pf4044mac6o_maj;





plot blsadj18:pf2024nmnc6_maj;
plot blsadj18:pf2024nmn18_maj;

plot blsadj18:pf2529nmnc6_maj;
plot blsadj18:pf2529nmn18_maj;

plot blsadj18:pf3034nmnc6_maj;
plot blsadj18:pf3034nmn18_maj;

plot blsadj18:pf3539nmnc6_maj;
plot blsadj18:pf3539nmn18_maj;

plot blsadj18:pf4044nmnc6_maj;
plot blsadj18:pf4044nmn18_maj;



plot blsadj18:pf2024msnc6_maj;
plot blsadj18:pf2024msn18_maj;

plot blsadj18:pf2529msnc6_maj;
plot blsadj18:pf2529msn18_maj;

plot blsadj18:pf3034msnc6_maj;
plot blsadj18:pf3034msn18_maj;

plot blsadj18:pf3539msnc6_maj;
plot blsadj18:pf3539msn18_maj;

plot blsadj18:pf4044msnc6_maj;
plot blsadj18:pf4044msn18_maj;




plot blsadj18:pf2024manc6_maj;
plot blsadj18:pf2024man18_maj;

plot blsadj18:pf2529manc6_maj;
plot blsadj18:pf2529man18_maj;

plot blsadj18:pf3034manc6_maj;
plot blsadj18:pf3034man18_maj;

plot blsadj18:pf3539manc6_maj;
plot blsadj18:pf3539man18_maj;

plot blsadj18:pf4044manc6_maj;
plot blsadj18:pf4044man18_maj;

abort;




 
'I BELIEVE THIS IS OBSOLETE

'target rename_variable;

'open blsadj18;
'open lc_model.bnk;

'copy blsadj18:*_1q_adj as lc_model:*.*;

'copy blsadj18:*_maj as lc_model:*.*;

'copy blsadj18:p*55_adj.a as lc_model:*.*;
'copy blsadj18:p*56_adj.a as lc_model:*.*;
'copy blsadj18:p*57_adj.a as lc_model:*.*;
'copy blsadj18:p*58_adj.a as lc_model:*.*;
'copy blsadj18:p*59_adj.a as lc_model:*.*;
'copy blsadj18:p*60_adj.a as lc_model:*.*; 
'copy blsadj18:p*61_adj.a as lc_model:*.*;
'copy blsadj18:p*62_adj.a as lc_model:*.*;
'copy blsadj18:p*63_adj.a as lc_model:*.*;
'copy blsadj18:p*64_adj.a as lc_model:*.*;
'copy blsadj18:p*65_adj.a as lc_model:*.*;
'copy blsadj18:p*66_adj.a as lc_model:*.*;
'copy blsadj18:p*67_adj.a as lc_model:*.*;
'copy blsadj18:p*68_adj.a as lc_model:*.*;
'copy blsadj18:p*69_adj.a as lc_model:*.*;
'copy blsadj18:p*70_adj.a as lc_model:*.*;
'copy blsadj18:p*71_adj.a as lc_model:*.*;
'copy blsadj18:p*72_adj.a as lc_model:*.*;
'copy blsadj18:p*73_adj.a as lc_model:*.*;
'copy blsadj18:p*74_adj.a as lc_model:*.*;
'
'copy blsadj18:*1617_aadj.a as lc_model:*.*;
'copy blsadj18:*1819_aadj.a as lc_model:*.*;
'copy blsadj18:*1619_aadj.a as lc_model:*.*;

'copy blsadj18:*16o_aadj.a as lc_model:*.*;

'close blsadj18;



'rename lc_model:em1617_1q_adj as em1617_est;
'rename lc_model:em1619_1q_adj as em1619_est;

 



for c = e, l, n, r, p;
  for s = m, f;
    for a = 1617, 1619, 16O, 1819, 2024, 2529, 2534, 3034, 3539, 3544, 4044, 
            4549, 4554, 5054, 5559, 5564, 6064, 6569, 65O, 7074, 75O;   
     rename series lc_model:|#c|#s|#a|_1q_adj as |#c|#s|#a|_est;
    end;
  end;
end;


for c = l, n, p;
  for s = m, f;
    for a = 1617, 16o, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 75o, 65o;
      for m = nm, ms, ma;
        rename lc_model:|#c|#s|#a|#m|_maj as |#c|#s|#a|#m|_est;
      end;
    end;
  end;
end;

for c = l, n, p;
  for s = f;
    for a = 1617, 1819, 2024, 2529, 3034, 3539, 4044, 4549, 5054, 5559, 6064, 6569, 7074, 75o, 65o;
      for m = nm, ms, ma;
        rename lc_model:|#c|#s|#a|#m|c6u_maj as |#c|#s|#a|#m|cu6_est;
        rename lc_model:|#c|#s|#a|#m|nc6_maj as |#c|#s|#a|#m|nc6_est;
        rename lc_model:|#c|#s|#a|#m|c6o_maj as |#c|#s|#a|#m|c6o_est;
        rename lc_model:|#c|#s|#a|#m|n18_maj as |#c|#s|#a|#m|n18_est;
      end;
    end;
  end;
end;





for c = e, l, n, r, p;
     rename series lc_model:|#c|m16o_aadj as |#c|m16o_esta;
     rename series lc_model:|#c|f16o_aadj as |#c|f16o_esta;
     rename series lc_model:|#c|16o_aadj as |#c|16o_esta;
end;



for c = e, l, n, r, p;
  for s = m, f;
    for a = 1617, 1619, 1819;   
     rename series lc_model:|#c|#s|#a|_aadj as |#c|#s|#a|_esta;
    end;
  end;
end;



for c = p;
  for s = m, f;
    for a = 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74;
     rename lc_model:|#c|#s|#a|_adj as |#c|#s|#a|_esta;
    end;
  end;
end;

close *;
clear;


open lc_model.bnk;
backup lc_model: lc_modelbk;

close *;
clear;


