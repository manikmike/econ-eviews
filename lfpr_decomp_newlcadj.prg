'This program creates LFPR decomposition tables for ALL demographic groups (both the 153 primary groups **and the standard aggregated groups**) for BOTH unadjusted and adjusted LFPRs. 
' User defines which demographic groups are to be included in the final output (in %user_groups below); the program will produce decomposition tables for these groups. 
'Resulting tables are created within the EViews workfile. They can then be exported ot PDF or Excel, but this step is not currently included in the code.

' The full superset of demographic groups that the user can specify follows. Any (or all) groups from this list can be used in the %user_groups below. User groups MUST be a subset of the list below, using the EXACT mnemonics given. Groups not listed here CANNOT be used.
' "M1617	M1819	M2024NM	M2024MS	M2024MA	M2529NM	M2529MS	M2529MA	M3034NM	M3034MS	M3034MA	M3539NM	M3539MS	M3539MA	M4044NM	M4044MS	M4044MA	M4549NM	M4549MS	M4549MA	M5054NM	M5054MS	M5054MA M55	M56	M57	M58	M59 M60	M61	M62	M63	M64	M65	M66	M67	M68	M69	M70	M71	M72	M73	M74 M75	M76	M77	M78	M79	M80	M81	M82	M83	M84	M85	M86	M87	M88	M89	M90	M91	M92	M93	M94	M95	M96	M97	M98	M99	M100 F1617	F1819	F2024MAC6U	F2024MANC6	F2024MSC6U	F2024MSNC6	F2024NMC6U	F2024NMNC6	F2529MAC6U	F2529MANC6	F2529MSC6U	F2529MSNC6	F2529NMC6U	F2529NMNC6	F3034MAC6U	F3034MANC6	F3034MSC6U	F3034MSNC6	F3034NMC6U	F3034NMNC6	F3539MAC6U	F3539MANC6	F3539MSC6U	F3539MSNC6	F3539NMC6U	F3539NMNC6	F4044MAC6U	F4044MANC6	F4044MSC6U	F4044MSNC6	F4044NMC6U	F4044NMNC6	F4549MA	F4549MS	F4549NM	F5054MA	F5054MS	F5054NM F55	F56	F57	F58	F59	F60	F61	F62	F63	F64	F65	F66	F67	F68	F69	F70	F71	F72	F73	F74 F75	F76	F77	F78	F79	F80	F81	F82	F83	F84	F85	F86	F87	F88	F89	F90	F91	F92	F93	F94	F95	F96	F97	F98	F99	F100"
'  m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m7074 m7579 m8084 m8589 m9094 m9599 
'  m85o m80o m75o m70o m65o 
'  m16o 
'  f2024nm f2024ms f2024ma f2024 f2529nm f2529ms f2529ma f2529 f3034nm f3034ms f3034ma f3034 f3539nm f3539ms f3539ma f3539 f4044nm f4044ms f4044ma f4044 
'  f4549 f5054 f5559 f6064 f6569 f7074 f7579 f8084 f8589 f9094 f9599 
'  f85o f80o f75o f70o f65o 
'  f16o
'  16o 


'User should set the parameters listed under "****SET these parameters before running the program *****.
'****************** Polina Vlasenko 7-3-2017

'********** This version allows the user to  select the period to be used as the base for Adjusted LFPRs. 
'********** The base period can be a specific quarter or an annual average for a specific year. Instruction for entering the values are given in the "****SET these parameters before running the program *****" section.
'*********** Polina Vlasenko 12-5-2017

'***** This program requires the following databanks:
'***** a-bank (current TR)
'***** d-bank (current TR)
'***** addfactor bank, i.e. ad-bank (current TR)
'***** op-bank (previous TR)

'***** This new version (denoted by ..._newlcadj) uses the new method for the total labor force adjustment factor -- thus "new lc adj". 
' ***** The new adjustment factor for each PRIMARY demographic group is computed ina a separate file -- lfpr_add.wf1 (which is produced by lcadj_new.prg). Path to this file should be given below in %LCadj. This program uses the adjustment factors from that file to create LFPR decompostion here.  ************* Polina Vlasenko 02-02-2018

' *** Updated file locations to final TR2019 databanks for all 3alts. -- PV 01/18/2019

' *** Updated file locations to final TR2020 databanks for all 3 alts. -- PV 01/24/202

' *** 3-31-2020 PV
' Changed the code to accomodate the new way we do individual addfactors for TR2020.
' We now have individual addafactor series for all SYOA groups 55 to 74 (although many of the series are zeros).
' Changes have been made ot this program to incorporate this fact.
' Changes have also been made to the lfpr_coefs matrix (which is loaded into this program) to account for the addfactors for all these groups.
' Also (unralted to the above) I added a %sav option that guides whether the wrkfile is to be saved for each run.
' Also added a comparison betwee p.._final and -... from a-bank (for p16o, pf16o, pm16o) in page "comparison", which automatically reports a warning if discrepancies are found.

' This included several special one-tim commends for TR20 only -- these account for the fact that we have a special _add2 addfactor that exists to compensate for the RU assumption change.
' These special changes apply to TR20 ONLY. They should be removed for future TRs. 
' To find these special changes (and remove them for future TRs) search for 'SPECIAL TR20' (all caps) -- this should mark every instance of special adjustments have have to do with _add2 addfactor.All fo these need to be commented out for future TRs.
' ***


'**********SET these parameters before running the program **********
!TRyr = 2020 'the LFPR decomposition table will start from TRyr-1 Q4, i.e. Q4 of the last historical year. NOTE: this program assumes that TRyr is in the form 20XX. The program will NOT work for TRyr 1999 or earlier (nor will it work for TRyr 2100 and later, but this won't be a problem for a while).

!endyr=2100 'end year for the LFPR decomposition table, usually the last year of the TR projection period, i.e. the latest year in the TR databanks

%sav = "N" 	' enter "Y" or "N" (case sensitive); governs whether the workfile is saved

' Indicate location of the databanks to be used for the program run
'  IMPORTANT -- don't forget the "\" at the end of the folder path
'	!!!!!     MAKE SURE these files matche the ALT you will be indicating later!!!
' a-bank
%folder_a = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\"
' d-bank
%folder_d = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\"
'add-factor bank (ad-bank)
%folder_ad = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\dat\"
'op-bank (Note that this is op-bank from previous-year TR, i.e. op1162o.bnk when the current TR is 2017)
%folder_op = "E:\usr\econ\EcoDev\dat\"

'FULL path to the workfile that contains LFPR coefficient matrix (including the filename and extension)
%LFPRestimates="E:\usr\econ\EViews\lfpr_coefs.wf1" 
%lfpr_est_file = "lfpr_coefs"  'short filename from the path above

' FULL path (including filename) to the workfile that contains labor force adjustment factors for each of the primary groups (this file is produced by lcadj_new.prg)
'	!!!!!     MAKE SURE this file matches the ALT you will be indicating later!!!
%LCadj = "E:\usr\pvlasenk\LFPR Decomp Output\TR2020\lfpr_add_202.wf1"  
%lc_adj_file = "lfpr_add_202" 'short file name from the path above


' Parameters that determine which output is to be produced

'group(s) for which the decomposition is to be done, space delimited
%user_groups=		"m1617 m1819 m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m70o " + _
						"f1617 f1819 f2024 f2529 f3034 f3539 f4044 f4549 f5054 f5559 f6064 f6569 f70o " + _
						"f16o m16o 16o"

'alt -- uncomment ONE option below; note that these are STRING variables
%alt="2" 'ALT for which  the decomposition is to be done
'%alt="1"
'%alt="3"

'LFPR type -- uncomment ONE option below
%lfpr="a" 
'%lfpr="u"

'BASE -- indicate the period that serves as base for age-sex-mar.startus-children adjustment fo LFPRs
	'if using a specific quarter, enter here OR comment out if not using
'%LFPR_adj_base = "2011Q4" 
	'if using annual values, select ONE option below -- enter year OR use ZERO if not applicable
'!annual = 0
!annual = 2011  '!!!!! IMPORTANT -- Set to ZERO if not using!!!!!

' Location where to save the resulting workfile
%folder_output = "E:\usr\pvlasenk\LFPR Decomp Output\TR2020\"
'name to be given to the workfile created by this program
%this_file = "lfpr_decomp_tr" + @str(!TRyr-2000) + %alt + "_" + %lfpr  'this should produce filename like "lfpr_decomp_tr182_u"

'*****END of section that needs updating for each run*****

!startyr=1995 ' need to start far enough in the past to catch all lagges values

'If using ANNUAL base period, create strings to denote quarters of the year
%base1=@str(!annual)+"q1"
%base2=@str(!annual)+"q2"
%base3=@str(!annual)+"q3"
%base4=@str(!annual)+"q4"

'define the sample period for which LFPR decomposition will  be done

%datestart=@str(!TRyr-1)+"q4" ' Q4 of year (TRyr-1), the FIRST period in LFPR decomposition table
%dateend=@str(!endyr)+"q4" 'Q4 of the last year of TR projection

%datelasthist=@str(!TRyr-1)+"q3" 'last historical date, i.e. Q3 of (TRyr-1), saved as a string

%trstr=@str(!TRyr-2000) 'string variable with two-digit TR year, i.e. "17" for 2017.
%tr_pr=@str(!TRyr-2000-1) 'string variable with previous TR year, i.e. "16" when the current TR is 2017; need this for the op-bank.

'string variables that denote databanks with corresponding filepaths 
%abank="atr"+%trstr+%alt 'name of the databank file without finelextemsion, such as atr172
%dbank="dtr"+%trstr+%alt
%opbank="op1"+%tr_pr+%alt+"o" 'Note that this is op-bank from previous-year TR, i.e. op1162o.bnk when the current TR is 2017
%addbank="adtr"+%trstr+%alt

%abankpath=%folder_a+%abank+".bnk" 
%dbankpath=%folder_d+%dbank+".bnk" 
%opbankpath=%folder_op+%opbank+".bnk" 
%addbankpath=%folder_ad+%addbank+".bnk" 


wfcreate(wf={%this_file}, page=Qdata) q !startyr !endyr 'create workfile with quarterly data between !startyr Q1 and !endyr Q4. 

'create new page called "results" which is annual from TRyr-1 to endyr -- this is where the final LFPR decomposition tables will be stored
!tablestart = !TRyr-1 
!tableend = !endyr
pagecreate(page=results) a !tablestart !tableend 

pageselect Qdata 'change the active page back to Qdata

'copy the LFPR coefficient matrix from EViews workfile LFPR_coefs 
wfopen %LFPRestimates
copy {%lfpr_est_file}::\lfprbetas {%this_file}::Qdata\  'lfprbetas is the matrix of estimated coefficients    
copy {%lfpr_est_file}::\lfprgroups {%this_file}::Qdata\  'lfprgroups is the string vector of group names, where the order of elements indicates the corresponding row in lfprbetas
wfclose {%lfpr_est_file}

'list of RHS variables that need to be kept constant when computing Adjusted LFPRs
%reset_list = "pm55_dm pm56_dm pm57_dm pm58_dm pm59_dm pm60_dm pm61_dm pm62_dm pm63_dm pm64_dm pm65_dm pm66_dm pm67_dm pm68_dm pm69_dm pm70_dm pm71_dm pm72_dm pm73_dm pm74_dm " + _
					"pf55_dm pf56_dm pf57_dm pf58_dm pf59_dm pf60_dm pf61_dm pf62_dm pf63_dm pf64_dm pf65_dm pf66_dm pf67_dm pf68_dm pf69_dm pf70_dm pf71_dm pf72_dm pf73_dm pf74_dm " + _
					"rf5054c6o rf1617cu6 rf1819cu6 rf5054cu6 rf4549mscu6 rf4549macu6 rf5054mscu6 rf5054macu6 " + _
					"if2024msc6u if2024mac6u if2529msc6u if2529mac6u if3034msc6u if3034mac6u if3539msc6u if3539mac6u if4044msc6u if4044mac6u" 

'list of 153 "primary" demographic groups -- the ones for which we have estimated LFPR equations
%groups_primary = "M1617	M1819	M2024NM	M2024MS	M2024MA	M2529NM	M2529MS	M2529MA	M3034NM	M3034MS	M3034MA	M3539NM	M3539MS	M3539MA	M4044NM	M4044MS	M4044MA	M4549NM	M4549MS	M4549MA	M5054NM	M5054MS	M5054MA M55	M56	M57	M58	M59 M60	M61	M62	M63	M64	M65	M66	M67	M68	M69	M70	M71	M72	M73	M74 M75	M76	M77	M78	M79	M80	M81	M82	M83	M84	M85	M86	M87	M88	M89	M90	M91	M92	M93	M94	M95	M96	M97	M98	M99	M100 F1617	F1819	F2024MAC6U	F2024MANC6	F2024MSC6U	F2024MSNC6	F2024NMC6U	F2024NMNC6	F2529MAC6U	F2529MANC6	F2529MSC6U	F2529MSNC6	F2529NMC6U	F2529NMNC6	F3034MAC6U	F3034MANC6	F3034MSC6U	F3034MSNC6	F3034NMC6U	F3034NMNC6	F3539MAC6U	F3539MANC6	F3539MSC6U	F3539MSNC6	F3539NMC6U	F3539NMNC6	F4044MAC6U	F4044MANC6	F4044MSC6U	F4044MSNC6	F4044NMC6U	F4044NMNC6	F4549MA	F4549MS	F4549NM	F5054MA	F5054MS	F5054NM F55	F56	F57	F58	F59	F60	F61	F62	F63	F64	F65	F66	F67	F68	F69	F70	F71	F72	F73	F74 F75	F76	F77	F78	F79	F80	F81	F82	F83	F84	F85	F86	F87	F88	F89	F90	F91	F92	F93	F94	F95	F96	F97	F98	F99	F100"

'all aggregated groups in a specific order (do NOT change the order they are listed in here)
%groups_aggr= 	"m2024 m2529 m3034 m3539 m4044 m4549 m5054 m5559 m6064 m6569 m7074 m7579 m8084 m8589 m9094 m9599 " + _
						"m85o m80o m75o m70o m65o " + _
						"m16o " + _
						"f2024nm f2024ms f2024ma f2024 f2529nm f2529ms f2529ma f2529 f3034nm f3034ms f3034ma f3034 f3539nm f3539ms f3539ma f3539 f4044nm f4044ms f4044ma f4044 " + _
						"f4549 f5054 f5559 f6064 f6569 f7074 f7579 f8084 f8589 f9094 f9599 " + _
						"f85o f80o f75o f70o f65o " + _
						"f16o "
					'	"16o" -- excludung 16o from the list because EViews does not allow series names that start with a number.

%list_col="ga le ia tb ag ge ms ch bc di ed rr et pf coh lc tr" 'columns of the LFPR decomposition table, in a specific order 

'**********************create "restricted" series pf58r..pf99r and pm74r..pm99r -- the LFPR series WITHOUT life expectancy or total labor force adjustments. 
'These will later be used in computing the "true" LFPRs in 'lagged cohort' cluster and 'female LFPR' cluster.  
'the order is important -- start with pf's, then do pm's.

'Females -- pf58 to pf74
for !age=58 to 74 'create names for the required series and initializes them all to -999
	%ia="pf"+@str(!age)+"_add"'individual addfactor
	series {%ia}=-999
	%ms_1="pf"+@str(!age)+"_dm" 'marital status
	series {%ms_1}=-999
	%bc="pf"+@str(!age)+"_bc" 'business cycle
	series {%bc}=-999
	%di_1="rf"+@str(!age)+"di"  'disability
	series {%di_1}=-999
	%ed_1="pf"+@str(!age)+"e_de" 'education
	series {%ed_1}=-999
	%rr_1="rradj_f"+@str(!age) 'replacement rate
	series {%rr_1}=-999
	%et_1="pot_et_txrt_"+@str(!age) 'earnings test
	series {%et_1}=-999
	%coh_1="pf"+@str(!age)+"coh48" '1948 cohort
	series {%coh_1}=-999
next

'fetch the required series from databanks
dbopen(type=aremos) %abankpath
fetch(d={%abank}) lc.q rf5559.q rf6064.q rf6569.q rf7074.q rm7074.q pf74.q pm74.q

dbopen(type=aremos) %dbankpath
fetch(d={%dbank}) pf*e_de.q pf*coh48.q pf*dm.q pm74e_de.q pm74_dm.q rradj*.q pot_et*.q

dbopen(type=aremos) %opbankpath
fetch(d={%opbank}) rf*di.q rm61di.q

dbopen(type=aremos) %addbankpath

fetch(d={%addbank}) lc.adj
for %s f m 
 for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
    fetch(d={%addbank}) p{%s}{%a}_add.q p{%s}{%a}_add2.q 	' SPECIAL TR20 (fetch p_add2 is needed ONLY for TR20, fetch p  _add needed for TR20 and all later TRs
  next
next

close @db

'for Adjusted LFPRs, reset certain series to a constant value equal to the "base period"; for unadjusted LFPRs this step is skipped
if %lfpr="a" then 
	for %ser pf55_dm pf56_dm pf57_dm pf58_dm pf59_dm pf60_dm pf61_dm pf62_dm pf63_dm pf64_dm pf65_dm pf66_dm pf67_dm pf68_dm pf69_dm pf70_dm pf71_dm pf72_dm pf73_dm pf74_dm pm74_dm  
	smpl %datestart %dateend
	if !annual>0 then 
		{%ser} = 0.25*@elem({%ser}, %base1) + 0.25*@elem({%ser}, %base2) + 0.25*@elem({%ser}, %base3) + 0.25*@elem({%ser}, %base4)  
		else {%ser} = @elem({%ser}, %LFPR_adj_base)
	endif
	next
	smpl @all
endif 

for !age=58 to 74 'this loop computes the values for pf58r--pf74r	
	%name="pf"+@str(!age)+"r" 'name of the "restricted" pf series
	'names of series used in computation
	%ia="pf"+@str(!age)+"_add"
	%ms_1="pf"+@str(!age)+"_dm" 
	%bc="pf"+@str(!age)+"_bc"
	%di_1="rf"+@str(!age)+"di"  
	if !age>61 then 'lag for rf61di
		!lag_di=-4*(!age-61) 
		else 
		!lag_di=-1
	endif
	
	%ed_1="pf"+@str(!age)+"e_de" 
	%rr_1="rradj_f"+@str(!age)
	%et_1="pot_et_txrt_"+@str(!age)
	%coh_1="pf"+@str(!age)+"coh48"
	
	%sp="pf"+@str(!age)+"_add2" 	' SPECIAL TR20 -- need to include the _add2 addfactor into the restricted series. Remove for future TRs.

	'some of the fetched sereis have NAs for part of the sample period; replace these NA's with -999 (so that they become zeros when multiplied by zero coefficicnts from lfprbetas)
	for %i  {%ia} {%ms_1} {%di_1} {%ed_1} {%rr_1} {%et_1} {%coh_1}   
		series {%i}=@nan({%i},-999)
	next

	!row=!age+53 'the corresponding row in the lfprbetas matrix
	series {%bc}=	lfprbetas(!row,9)+ lfprbetas(!row,16)*rf5559+lfprbetas(!row,17)*rf5559(-1)+lfprbetas(!row,18)*rf5559(-2)+lfprbetas(!row,19)*rf5559(-3)+lfprbetas(!row,20)*rf5559(-4)+lfprbetas(!row,21)*rf5559(-5)+ _
												lfprbetas(!row,22)*rf6064+lfprbetas(!row,23)*rf6064(-1)+lfprbetas(!row,24)*rf6064(-2)+lfprbetas(!row,25)*rf6064(-3)+lfprbetas(!row,26)*rf6064(-4)+lfprbetas(!row,27)*rf6064(-5)+ _
												lfprbetas(!row,28)*rf6569+lfprbetas(!row,29)*rf6569(-1)+lfprbetas(!row,30)*rf6569(-2)+lfprbetas(!row,31)*rf6569(-3)+lfprbetas(!row,32)*rf6569(-4)+lfprbetas(!row,33)*rf6569(-5)+ _
												lfprbetas(!row,34)*rf7074+lfprbetas(!row,35)*rf7074(-1)+lfprbetas(!row,36)*rf7074(-2)+lfprbetas(!row,37)*rf7074(-3)+lfprbetas(!row,38)*rf7074(-4)+lfprbetas(!row,39)*rf7074(-5) 
	'main lfpr formula
	series {%name}=lfprbetas(!row,2)*{%ia} _
							+ lfprbetas(!row,3)+lfprbetas(!row,4)*{%ms_1} _
							+{%bc} _
							+ lfprbetas(!row,41)+lfprbetas(!row,42)*{%di_1}+lfprbetas(!row,43)*rf61di(!lag_di)  _
							+ lfprbetas(!row,44)+lfprbetas(!row,45)*{%ed_1} _
							+ lfprbetas(!row,46)+lfprbetas(!row,47)*{%rr_1} _
							+ lfprbetas(!row,48)+lfprbetas(!row,49)*{%et_1} _
							+ lfprbetas(!row,52)+lfprbetas(!row,53)*{%coh_1} _
							+ lfprbetas(!row,63) _
							+ {%sp} 		' SPECIAL TR20 -- need to include the _add2 addfactor into the restricted series. Remove for future TRs.
next 'end of the loop for pf58-pf74

'pf74 and pm74 are special case, so do them here by hand
'set pf74 and pm74 equal to historical values up to the last historical value
smpl @first %datelasthist
series pf74r = pf74 'this REPLACES part fo pf74r series computed in the above loop; this completes the computation of pf74r
series pm74r = pm74 'the rest of pm74r is computed below

smpl %datestart %dateend
'lfprebetas for pm74 are  in row 43
'pm74r is the ONLY series whose computation is hard-coded here -- it pulls the coefficicnts from the lfprbetas matrix, but the series names in the expression are done by hand and the expression omits those components of the more general lfpr formula that have zero coefficicnts for pm74. 
series pm74r = lfprbetas(43,2)*pm74_add _'individual addfactor
							+ lfprbetas(43,3)+lfprbetas(43,4)*pm74_dm _'marital status
							+ lfprbetas(43,9)+ lfprbetas(43,34)*rm7074+lfprbetas(43,35)*rm7074(-1)+lfprbetas(43,36)*rm7074(-2)+lfprbetas(43,37)*rm7074(-3)+lfprbetas(43,38)*rm7074(-4)+lfprbetas(43,39)*rm7074(-5) _'business cycle
							+ lfprbetas(43,41)+lfprbetas(43,43)*rm61di(-52)  _'disability
							+ lfprbetas(43,44)+lfprbetas(43,45)*pm74e_de _'education
							+ lfprbetas(43,50)+lfprbetas(43,51)*pf72r _'female lfpr
							+ lfprbetas(43,63) _' constant
							+ pm74_add2 		' SPECIAL TR20 -- need to include the _add2 addfactor into the restricted series. Remove for future TRs

smpl @all 'reset sample to full workfile


'females and males 75 to 99
dbopen(type=aremos) %abankpath
fetch dpf75o_fe.q dpm75o_fe.q 
series pf79r=-999 'pf79r and pm79r are used in computing all other pf/pm 75-99, so need to initialize the series; once we reach !age=79 in the loop below these will be replaced
series pm79r=-999
for !age=75 to 99
	'create series names
	%namefr="pf"+@str(!age)+"r" 'name of the "restricted" pf series
	%namemr="pm"+@str(!age)+"r" 'name of the "restricted" pm series
	%namef="pf"+@str(!age) 'name of the historical pf series
	%namem="pm"+@str(!age) 'name of the historical pm series

	'set past values of pf..r and pm..r to last historical values
	fetch {%namef}.q {%namem}.q
	smpl @first %datelasthist
	series {%namefr} = {%namef} 
	series {%namemr} = {%namem}

	'compute values for the projection period
	smpl %datestart %dateend
	!rowf=!age+53 'the corresponding row for females in the lfprbetas matrix 
	!rowm=!age-31 'the corresponding row for males in the lfprbetas matrix 
	%lc_1f="pf"+@str(!age-1)+"r(-4)"
	%lc_1m="pm"+@str(!age-1)+"r(-4)"
	if !age>79 and !age<95 then 
		!lag_lc=-4*(!age-79) 
		else 
		!lag_lc=-1
	endif
	%lc_2f="pf"+@str(!age-1)+"r(-4)"
	%lc_2m="pm"+@str(!age-1)+"r(-4)"
	%lc_3f="pf"+@str(!age-1)+"r"
	%lc_3m="pm"+@str(!age-1)+"r"
	series {%namefr} =  lfprbetas(!rowf,40)*dpf75o_fe+lfprbetas(!rowf,54)+lfprbetas(!rowf,55)*{%lc_1f}+lfprbetas(!rowf,56)*pf79r(!lag_lc)+lfprbetas(!rowf,57)*@mav(pf79r(!lag_lc),8)+lfprbetas(!rowf,58)*{%lc_3f}
	series {%namemr} = lfprbetas(!rowm,40)*dpm75o_fe+lfprbetas(!rowm,54)+lfprbetas(!rowm,55)*{%lc_1m}+lfprbetas(!rowm,56)*pm79r(!lag_lc)+lfprbetas(!rowm,57)*@mav(pm79r(!lag_lc),8)+lfprbetas(!rowm,58)*{%lc_3m}
next 'end of loop for 'females and males 75 to 99
close %abank

smpl @all 'reset sample to the entire workfile

'clean up the workfile by deleting the series used in the above computation that we no longer need
delete dp* pf*dm pm*dm pf*de pm*de pf*coh48 pf*add pf*bc pm*add pot* rradj* rf* rm* p*1 p*2 p*3 p*4 p*5 p*6 p*7 p*8 p*9 p*0 'note that here I have deleted the adjusted pf*_dm's and pm*_dm's. If I need them later, adjust this delete ststemant.

'************************ all "restricted" series are now done

'************************loop through all PRIMARY demo groups*********
'load total labor force adjustment factors for all primary groups
wfopen %LCadj
copy {%lc_adj_file}::lfprs\adj_p* {%this_file}::Qdata\  
wfclose %lc_adj_file

'open the databanks we will need for this loop
dbopen(type=aremos) %abankpath
dbopen(type=aremos) %dbankpath
dbopen(type=aremos) %opbankpath
dbopen(type=aremos) %addbankpath


for %groups {%groups_primary} 

	'create strings from the group name that will be used to denote varaiables in the computation
	%groupfull=@lower(%groups) ' full name of the group, all letters are made to be lower-case
	%grg=@lower(@left(%groups, 1)) 'signle-character gender identifier
	%gr5=@lower(@left(%groups, 5)) ' first 5 characters of group name; if group name has fewer than 5 characters, this string holds them all.
	%gr2num=@mid(%groups, 2, 2) 'first two numerals in the group name, saved as a string
	!gr2num=@val(@mid(%groups, 2, 2)) 'first two numerals in the group name, saved as a number (not a string)

	'create string variables for the NAMES of all series in LFPR equations AND initialize each series with -999 values (this will be the indicator of missing values)
	'life expectancy
	%le="p"+%gr5+"adj" 'create string for the sereis name
	series {%le}=-999 'delcare series with that name and assign value -999 to each observation. If the code works correctly, none of the -999 values should enter the final LFPR value.
	'individual addfactor
	%ia="p"+%grg+%gr2num+"_add"
	series {%ia}=-999
	'marital status
	%ms_1="p"+%grg+%gr2num+"_dm"
	series {%ms_1}=-999
	'child presence
	%ch_1="r"+%groupfull+"cu6"
	%ch_2="i"+%groupfull
	series {%ch_1}=-999
	series {%ch_2}=-999
	series rf5054cu6=-999 'this series is used in one special expression
	series rf5054c6o=-999 'this series is used in one special expression
	'business cycle
	%bc_1="r"+%gr5
	%bc_2="r"+%gr5+"(-1)"
	%bc_3="r"+%gr5+"(-2)"
	%bc_4="r"+%gr5+"(-3)"
	%bc_5="r"+%gr5+"(-4)"
	%bc_6="r"+%gr5+"(-5)"
	series {%bc_1}=-999 'bc_2 through bc_6 are lags of bc_1, so no need to declare them as separate series.
	%bc_7="r"+%grg+"5559"
	%bc_8="r"+%grg+"5559(-1)"
	%bc_9="r"+%grg+"5559(-2)"
	%bc_10="r"+%grg+"5559(-3)"
	%bc_11="r"+%grg+"5559(-4)"
	%bc_12="r"+%grg+"5559(-5)"
	series {%bc_7}=-999
	%bc_13="r"+%grg+"6064"
	%bc_14="r"+%grg+"6064(-1)"
	%bc_15="r"+%grg+"6064(-2)"
	%bc_16="r"+%grg+"6064(-3)"
	%bc_17="r"+%grg+"6064(-4)"
	%bc_18="r"+%grg+"6064(-5)"
	series {%bc_13}=-999
	%bc_19="r"+%grg+"6569"
	%bc_20="r"+%grg+"6569(-1)"
	%bc_21="r"+%grg+"6569(-2)"
	%bc_22="r"+%grg+"6569(-3)"
	%bc_23="r"+%grg+"6569(-4)"
	%bc_24="r"+%grg+"6569(-5)"
	series {%bc_19}=-999
	%bc_25="r"+%grg+"7074"
	%bc_26="r"+%grg+"7074(-1)"
	%bc_27="r"+%grg+"7074(-2)"
	%bc_28="r"+%grg+"7074(-3)"
	%bc_29="r"+%grg+"7074(-4)"
	%bc_30="r"+%grg+"7074(-5)"
	series {%bc_25}=-999
	%bc_31="dp"+%grg+"75o_fe"
	series {%bc_31}=-999
	'disability
	%di_1="r"+%gr5+"di"
	series {%di_1}=-999
	if !gr2num>61 and !gr2num<75 then 
		!lag_di=4*(!gr2num-61) 
		else 
		!lag_di=1
	endif
	%di_2="r"+%grg+"61di(-"+@str(!lag_di)+")"
	%di61="r"+%grg+"61di"
	series {%di61}=-999
	'education
	%ed_1="p"+%gr5+"e_de"
	series {%ed_1}=-999
	'replacement rate
	%rr_1="rradj_"+%gr5
	series {%rr_1}=-999
	'earnings test
	%et_1="pot_et_txrt_"+%gr2num
	series {%et_1}=-999
	'female LFPR
	%pf_1="pf"+@str(!gr2num-2)+"r" 'note that this is one of the "restricted" series computed above, thus do NOT initialize it to -999
	'1948 cohort
	%coh_1="pf"+%gr2num+"coh48"
	series {%coh_1}=-999
	'lagged cohort -- note that all lagged LFPRs here are the "restricted" series pf..r and pm..r, thus no need to initialize them to -999
	if !gr2num=10 then %lc_1="p"+%grg+"99r" else %lc_1="p"+%grg+@str(!gr2num-1)+"r(-4)" 'need this "If" to take care of m100 and f100 groups -- their gr2num=10, but there is no such thing as pm9 of pf9
	endif
	if !gr2num>79 and !gr2num<95 then 
		!lag_lc=4*(!gr2num-79) 
		else 
		!lag_lc=1
	endif
	%lc_2="p"+%grg+"79r(-"+@str(!lag_lc)+")"
	if !gr2num=10 then %lc_3="p"+%grg+"99r" else %lc_3="p"+%grg+@str(!gr2num-1)+"r" 'need this "If" to take care of m100 and f100 groups -- their gr2num=10, but we need to use pm99 and pf99 as %lc_3
	endif
	%lc79="p"+%grg+"79r"
	'trend
	%tr_1="tr_p"+%gr5
	series {%tr_1}=-999
	%tr_2="tr_p"+%groupfull
	series {%tr_2}=-999
	series tr_pm3034=-999 'this series is used in ONE special trend expression

	'at this point we have created all the series that will be used in LFPR computation for a given demo group. Right now all the series have values -999, which will be an indicator of missing values.

	'Load the existing series from databanks; EViews will replace -999 with the fetched values of the existing series. The nonexistent series will remain with -999 values. 
	if %grg="f" then
		%list_a="rf*.q dpf75o_fe.q "+"p"+%groupfull 'series to be fetched from A-bank 
		%list_a_delete="rf*_p rf*_fe" ' series to be deleted; the above list fetched "too many" series from A-bank, this list kills off those that are not needed

		%list_d="pf*de.q pf*dm.q pf*48.q pf*adj.q rradj*.q pot*.q tr_pf*.q if*.q rf*6.q"   'series to be fetched from D-bank
	
		%list_op="rf*di.q"   'series to be fetched from op-bank(previous TRyr)
		
		%list_add = "pf55_add.q pf56_add.q pf57_add.q pf58_add.q pf59_add.q pf60_add.q pf61_add.q pf62_add.q pf63_add.q pf64_add.q pf65_add.q pf66_add.q pf67_add.q pf68_add.q pf69_add.q pf70_add.q pf71_add.q pf72_add.q pf73_add.q pf74_add.q" ' individual addfactors
		else
		%list_a="rm*.q dpm75o_fe.q "+"p"+%groupfull 'series to be fetched from A-bank 
		%list_a_delete="rm*_p rm*_fe" ' series to be deleted; the above list fetched "too many" series from A-bank, this list kills off those that are not needed

		%list_d="pm*de.q pm*dm.q pm*adj.q rradj*.q pot*.q tr_pm*.q rf5054cu6.q rf5054c6o.q"   'series to be fetched from D-bank
	
		%list_op="rm*di.q"   'series to be fetched from O-bank(previous TRyr)
		
		%list_add = "pm55_add.q pm56_add.q pm57_add.q pm58_add.q pm59_add.q pm60_add.q pm61_add.q pm62_add.q pm63_add.q pm64_add.q pm65_add.q pm66_add.q pm67_add.q pm68_add.q pm69_add.q pm70_add.q pm71_add.q pm72_add.q pm73_add.q pm74_add.q"  ' individual addfactors
	endif
	'%list_add="pf65.add pf67.add pm67.add pm72.add pm74.add" 'this is a complete set of individual addfactors we have, so no need to differentiate by gender -- No longer applicable in TR20 and later.


	'fetch series from databanks
	fetch(d={%abank}) {%list_a}
	fetch(d={%dbank}){%list_d}
	fetch(d={%opbank}){%list_op}
	fetch(d={%addbank}){%list_add}

'	for %s f m 
'	 for %a 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
'	    fetch p{%s}{%a}_add.q 
'	  next
'	next

	'done loading series from databanks
	' close @db
	delete {%list_a_delete}


	'Some series exists in the databank but have NA values for part of the sample (example: rf66di is NA till 2021, but has valid values thereafter)
	'replace NA's with -999, leave other values unchanged; if NAs appear anywhere, they would be in the series that are irrelevant (have coef of zero) for a particular group; but in eViews multipliyinh NA by zero produces NA, not zero; thus, need to replace NAs with a number.  
	for %i  {%le} {%ia} {%ms_1} {%ch_1} {%ch_2} rf5054cu6 rf5054c6o {%bc_1} {%bc_7} {%bc_13} {%bc_19} {%bc_25} {%bc_31} {%di_1} {%di61} {%ed_1} {%rr_1} {%et_1} {%pf_1} {%coh_1} {%lc_3} {%lc79} {%tr_1} {%tr_2} tr_pm3034 
		series {%i}=@nan({%i},-999)
	next

	smpl %datestart %dateend 'sample period for which LFPR is replicated

	'for Adjusted LFPRs, reset marital status and child presence series to a constant value equal to value in base year; for unadjusted LFPRs this step is skipped
	if %lfpr="a" then 
		for %ser {%ms_1} {%ch_1} {%ch_2} rf5054cu6 rf5054c6o
			if !annual>0 then 
				{%ser} = 0.25*@elem({%ser}, %base1) + 0.25*@elem({%ser}, %base2) + 0.25*@elem({%ser}, %base3) + 0.25*@elem({%ser}, %base4)  
				else {%ser} = @elem({%ser}, %LFPR_adj_base)
			endif
		next
	endif 

	'get the corresponding coefficients from LFPRbetas matrix; i.e. find which row of lfprbetas matrix we need to use. 
	scalar row=0 'row is the indicator of which row of lfprbetas matrix to use
	for !i=1 to 153
		%vrow=LFPRgroups(!i)
		if %groupfull=@lower(%vrow) then row=!i 
		endif 
	next

	'create clusters of LFPR computation -- bc, di, etc.

	series {%groupfull}_ga=adj_p{%groupfull} 'global addfactor, same as "total LF adjustment"
	series {%groupfull}_le=lfprbetas(row,1)*{%le} 'life expectancy adjustment
	series {%groupfull}_ia=lfprbetas(row,2)*{%ia}'individual addfactor
	series {%groupfull}_ag=0'age adjustment -- does NOT exist for primary groups
	series {%groupfull}_ge=0'gender adjustment -- does NOT exist for primary groups
	series {%groupfull}_ms=lfprbetas(row,62)*(lfprbetas(row,3)+lfprbetas(row,4)*{%ms_1}) 'marital status
	series {%groupfull}_ch=lfprbetas(row,62)*(lfprbetas(row,5)+lfprbetas(row,6)*{%ch_1}+lfprbetas(row,7)*{%ch_2}+lfprbetas(row,8)*(rf5054cu6+rf5054c6o)) 'child presence
	series {%groupfull}_bc=	lfprbetas(row,62)*(lfprbetas(row,9)+ _
															lfprbetas(row,10)*{%bc_1}+lfprbetas(row,11)*{%bc_2}+lfprbetas(row,12)*{%bc_3}+lfprbetas(row,13)*{%bc_4}+lfprbetas(row,14)*{%bc_5}+lfprbetas(row,15)*{%bc_6}+ _
															lfprbetas(row,16)*{%bc_7}+lfprbetas(row,17)*{%bc_8}+lfprbetas(row,18)*{%bc_9}+lfprbetas(row,19)*{%bc_10}+lfprbetas(row,20)*{%bc_11}+lfprbetas(row,21)*{%bc_12}+ _
															lfprbetas(row,22)*{%bc_13}+lfprbetas(row,23)*{%bc_14}+lfprbetas(row,24)*{%bc_15}+lfprbetas(row,25)*{%bc_16}+lfprbetas(row,26)*{%bc_17}+lfprbetas(row,27)*{%bc_18}+ _
															lfprbetas(row,28)*{%bc_19}+lfprbetas(row,29)*{%bc_20}+lfprbetas(row,30)*{%bc_21}+lfprbetas(row,31)*{%bc_22}+lfprbetas(row,32)*{%bc_23}+lfprbetas(row,33)*{%bc_24}+ _
															lfprbetas(row,34)*{%bc_25}+lfprbetas(row,35)*{%bc_26}+lfprbetas(row,36)*{%bc_27}+lfprbetas(row,37)*{%bc_28}+lfprbetas(row,38)*{%bc_29}+lfprbetas(row,39)*{%bc_30}+ _
															lfprbetas(row,40)*{%bc_31}) 'business cycle
	series {%groupfull}_di=lfprbetas(row,62)*(lfprbetas(row,41)+lfprbetas(row,42)*{%di_1}+lfprbetas(row,43)*{%di_2}) 'disability prevalence
	series {%groupfull}_ed=lfprbetas(row,62)*(lfprbetas(row,44)+lfprbetas(row,45)*{%ed_1}) 'education
	series {%groupfull}_rr=lfprbetas(row,62)*(lfprbetas(row,46)+lfprbetas(row,47)*{%rr_1}) 'replacement rate
	series {%groupfull}_et=lfprbetas(row,62)*(lfprbetas(row,48)+lfprbetas(row,49)*{%et_1}) 'earnings test
	series {%groupfull}_pf=lfprbetas(row,62)*(lfprbetas(row,50)+lfprbetas(row,51)*{%pf_1}) 'female lfpr
	series {%groupfull}_coh=lfprbetas(row,62)*(lfprbetas(row,52)+lfprbetas(row,53)*{%coh_1}) '1948 cohort
	series {%groupfull}_lc=lfprbetas(row,62)*(lfprbetas(row,54)+lfprbetas(row,55)*{%lc_1}+lfprbetas(row,56)*{%lc_2}+lfprbetas(row,57)*@mav({%lc_2},8)+lfprbetas(row,58)*{%lc_3}) 'lagged cohort
	series {%groupfull}_tr=lfprbetas(row,62)*(lfprbetas(row,59)*{%tr_1}+lfprbetas(row,60)*{%tr_2})+lfprbetas(row,61)*(1/(tr_pm3034-85))'trend
	series {%groupfull}_in=lfprbetas(row,62)*lfprbetas(row,63) 'global intercept

	'create LFPR decomposition
	smpl %datestart %dateend 'sample period for the decomposition tables

	'compute total base (tb)
	series {%groupfull}_tb={%groupfull}_ag+{%groupfull}_ge+{%groupfull}_ms+{%groupfull}_ch+{%groupfull}_bc+{%groupfull}_di+{%groupfull}_ed+{%groupfull}_rr+{%groupfull}_et+{%groupfull}_pf+{%groupfull}_coh+{%groupfull}_lc+{%groupfull}_tr+{%groupfull}_in

	'compute cumulative change for each column in the table
	for %i {%list_col}
		series {%groupfull}_{%i}_c={%groupfull}_{%i}-@elem({%groupfull}_{%i}, %datestart) 
	next

	smpl @all 'reset the sample range to entire workfile before we move to the next group in the loop

next '**********end of the main loop through all PRIMARY demo groups (the loop started on line 338)********************

'close all open databases
close @db 

'clean up the workfile by deleting the series used in the above computation that we no longer need
delete dp* i* pf*dm pm*dm pf*de pm*de pf*coh48 pf*add pm*add pot* rradj* tr* rf* rm* pf*adj pm*adj 'might need ot keep pm* and pf* to compute residuals for aggregated groups



'********** LFPR decomposition for the aggregated groups

'create a master list of ALL population series needed in the computation that follows
%pop_list = "n16o"

for %name {%groups_primary}
	%pop_list=%pop_list+" n"+@lower(%name)
next

for %name {%groups_aggr}
	%pop_list=%pop_list+" n"+@lower(%name)
next

'fetch ALL population series from D-bank
dbopen(type=aremos) %dbankpath
fetch {%pop_list} 
close %dbank
'all population series have now been loaded


smpl %datestart %dateend 

'for Adjusted LFPRs, reset population to a constant value equat to that in th abse year; for unadjusted LFPRs this step is skipped
if %lfpr="a" then 
	for %ser {%pop_list}
	if !annual>0 then 
		{%ser} = 0.25*@elem({%ser}, %base1) + 0.25*@elem({%ser}, %base2) + 0.25*@elem({%ser}, %base3) + 0.25*@elem({%ser}, %base4)  
		else {%ser} = @elem({%ser}, %LFPR_adj_base)
	endif
	next
endif 

%levels="le ia tb in ga" 'columns for which we compute weighted average of LEVELs
%clusters="ag ge ms ch bc di ed rr et pf coh lc tr" 'list of clusters for which we compute weighted average of CHANGES, and the demo effects

'declare series for level and change for the aggregate groups and initialize them to zero
for %name {%groups_aggr}
	for %col {%clusters}	
		series {%name}_{%col}_c=0
		series _16o_{%col}_c=0
	next
next



'************** loop through all aggregated groups
for %gr {%groups_aggr}

	'create strings from the group name that will be used to denote varaiables in the computation
	%groupfull=@lower(%gr) ' full name of the group, all letters are made to be lower-case
	%grg=@lower(@left(%gr, 1)) 'signle-character gender identifier
	%gr5=@lower(@left(%gr, 5)) ' first 5 characters of group name; if group name has fewer than 5 characters, this string holds them all.
	!gr2num=@val(@mid(%gr, 2, 2)) 'first two numerals in the group name, saved as a number (not a string)
	%o=@mid(%gr, 4, 1) 'returns "o" for m16o, m65o, m70o, m75o, m80o, m85o (same for female groups), but not for other groups; it does NOT return "o" for 16o. 

	'compute LFPR decomposition values for the aggregate groups; computation differs for different kinds of groups, so several if's below to account for that
	if !gr2num<55 and @len(%groupfull)>4 then 'for all male and female 5yr groups up to age 5054
		if %gr5=%groupfull then 'male and female five-yr groups up to 5054 (f2024, F4044, M4549 etc)
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

next 'end of aggr groups loop (it started on line 605)

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
'****************************ALL groups are now done -- both primary and aggregated

delete n* 'no longer need population series


'compute "final LFPR"  and residuals for ALL groups (primary and aggregated) and create a list of all residual series
%list_resids = ""
for %gr {%groups_primary} {%groups_aggr} _16o 
	series p{%gr}_final = {%gr}_ga + {%gr}_le + {%gr}_ia + {%gr}_tb ' final LFPR
	series p{%gr}_final_c = p{%gr}_final - @elem(p{%gr}_final, %datestart) 'cumulative change in final LFPR
	series {%gr}_res_c = {%gr}_tb_c - ({%gr}_ag_c + {%gr}_ge_c + {%gr}_ms_c + {%gr}_ch_c + {%gr}_bc_c + {%gr}_di_c + {%gr}_ed_c + {%gr}_rr_c + {%gr}_et_c + {%gr}_pf_c + {%gr}_coh_c + {%gr}_lc_c + {%gr}_tr_c)
	%list_resids=%list_resids + %gr + "_res_c "
next


'check that ALL residual are zero and display a message to that effect
spool report 'spool to display messages
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
	

'********** loop that creates the output tables for groups requested by the user
smpl %datestart %dateend 'period for which LFPR decomposition is to be done

!last_row=!endyr - !TRyr + 9 'this is the row number fo the lat year in the decomposition table


'create the list of series that comprise the columns of LFPR decomposition table, in the desired order
for %g {%user_groups}  
	if  @lower(%g)="16o" then %g="_16o" 'need this because EViews does not allow series name to start from a number
	endif
		%list_table = "p"+@lower(%g)+"_final" +" p"+@lower(%g)+"_final_c " 'start building a list of series that make up the decomposition table, IN THE DESIRED ORDER 
		for %i {%list_col} 
			%list_table = %list_table + @lower(%g)+"_"+%i+"_c "  'add all cumulative change series to the list
		next
	%list_table = %list_table + @lower(%g)+"_res_c " 'add the residuals column
	
	group table_{%g} {%list_table} 'collect all columns in a group (this will be in Qdata page, and it is quarterly)

	pageselect results 'switch to the "results" page in the workfile (it is annual)
	for %i {%list_table}  'copy all relevant series to the "results" workfile page and convert them from Q to A by taking Q4 value
		copy(c=l) Qdata\{%i}  
	next

	group results_{%g} {%list_table} 'group the annual series in the desired order
	freeze(lfpr_{%g}) results_{%g}.sheet 'freeze the table and name it lfpr_group

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
	lfpr_{%g}.setjust(A6:U6) center
	'clear line 6 of the series names
	for !i=1 to 21
	lfpr_{%g}(6,!i)=" "
	next

	'create borders for cells in the table heading
	lfpr_{%g}.setlines(A1:U7) +a
	lfpr_{%g}.setlines(A1) +a
	lfpr_{%g}.setlines(D1) +a
	lfpr_{%g}.setlines(A1:A6) -i
	lfpr_{%g}.setlines(B1:B3) -i

	lfpr_{%g}.setlines(B4:B6) -i
	lfpr_{%g}.setlines(C4:C6) -i
	lfpr_{%g}.setlines(D3:D6) -i
	lfpr_{%g}.setlines(E3:E6) -i
	lfpr_{%g}.setlines(F3:F6) -i
	lfpr_{%g}.setlines(G3:G6) -i

	lfpr_{%g}.setlines(H5:H6) -i
	lfpr_{%g}.setlines(I5:I6) -i
	lfpr_{%g}.setlines(J5:J6) -i
	lfpr_{%g}.setlines(K5:K6) -i

	lfpr_{%g}.setlines(L4:L6) -i
	lfpr_{%g}.setlines(M4:M6) -i
	lfpr_{%g}.setlines(N4:N6) -i
	lfpr_{%g}.setlines(O4:O6) -i
	lfpr_{%g}.setlines(P4:P6) -i
	lfpr_{%g}.setlines(Q4:Q6) -i
	lfpr_{%g}.setlines(R4:R6) -i
	lfpr_{%g}.setlines(S4:S6) -i
	lfpr_{%g}.setlines(T4:T6) -i
	lfpr_{%g}.setlines(U4:U6) -i

	lfpr_{%g}.setlines(A8:U{!last_row}) +o
	lfpr_{%g}.setlines(A8:A{!last_row}) +r
	lfpr_{%g}.setlines(C8:C{!last_row}) +o
	lfpr_{%g}.setlines(G8:G{!last_row}) +o
	lfpr_{%g}.setlines(U8:U{!last_row}) +l

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
	lfpr_{%g}.setmerge(d1:u1)
	lfpr_{%g}(1,4)="Decomposition of Cumulative Change from 4th Qtr. of "+@str(!TRyr-1)
	lfpr_{%g}.setmerge(d2:f2)
	lfpr_{%g}(2,4)="Adjustments"
	lfpr_{%g}(3,4)="Total"
	lfpr_{%g}(4,4)="Labor"
	lfpr_{%g}(5,4)="Force"
	lfpr_{%g}(3,5)="Life"
	lfpr_{%g}(4,5)="Expect."
	lfpr_{%g}(3,6)="Individual"
	lfpr_{%g}.setmerge(g2:u2)
	lfpr_{%g}(2,7)="Base"
	lfpr_{%g}(3,7)="Total"
	lfpr_{%g}.setmerge(h3:u3)
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
	lfpr_{%g}(4,17)="Female"
	lfpr_{%g}(5,17)="LFPR"
	lfpr_{%g}(4,18)="1948"
	lfpr_{%g}(5,18)="Cohort"
	lfpr_{%g}(4,19)="Lagged"
	lfpr_{%g}(5,19)="Cohort"
	lfpr_{%g}(6,19)="(75o)"
	lfpr_{%g}(4,20)="Trend"
	lfpr_{%g}(4,21)="Residual"


	pageselect Qdata 'go back to Qdata page for the next group in the loop

next ' (end of loop that started on line 888)

'********** end of loop that creates the output tables

delete p*r 'tot_lf_adj 'pf?? pm?? 'delete series we no longer need

'delete statements below are added for LFPR_Actuarial study run (8-14-2017)
delete *_wt *_ag *_bc *_ch *_coh *_di *_ed *_et *_ga *_ge *_ia *_in *_lc *_le *_ms *_pf *_rr *_tb *_tr 
delete *_c 
'delete pf* pm*  table_* -- I need LFPRs to compare to ASA2011

'display message that the process is finished
string summary = "LFPR decomposition is complete. Resulting tables are in the ""results"" page."
report.append summary
report.display 'display on screen the spool that would indicate if we found any non-zero residuals

pageselect results

'compare LFPRs produced by this program to those in the databank -- for now this is done only for all160, f160, and m16o. This should be sufficicnts to detect problems in other groups, if they exist.
pagecreate(page=comparison) q %datestart %dateend

pageselect comparison

copy Qdata\p_16o_final comparison\ 
copy Qdata\pf16o_final comparison\ 
copy Qdata\pm16o_final comparison\ 

dbopen(type=aremos) %abankpath
fetch p16o_asa.q pf16o_asa.q pm16o_asa.q
fetch p16o.q pf16o.q pm16o.q
close @db 

' do the comparison and report results on screen
if %lfpr="a" then 
	group all16o p_16o_final p16o_asa
	series p16o_ck = p16o_asa - p_16o_final
	group f16o pf16o_final  pf16o_asa
	series pf16o_ck = pf16o_asa - pf16o_final
	group m16o pm16o_final  pm16o_asa
	series pm16o_ck = pm16o_asa - pm16o_final
endif

if %lfpr="u" then 
	group all16o p_16o_final p16o
	series p16o_ck = p16o - p_16o_final
	group f16o pf16o_final  pf16o
	series pf16o_ck = pf16o - pf16o_final
	group m16o pm16o_final  pm16o
	series pm16o_ck = pm16o - pm16o_final
endif

' Check to see if any of the p.._ck series are nonzero and display a warning to that effect
spool compare 'spool to display messages
!count=0
for %ser p16o_ck pf16o_ck pm16o_ck
	smpl %datestart %dateend if @abs({%ser})>0.00001
	if @obssmpl>0 then 
		freeze(nz_{%ser}) {%ser}.sheet
		string warn = "!!! Non-zero differences found for " + %ser + ". Please see the relevant group comparison in page ""comparison""! If this is decomposition for ADJUSTED LFPRs, the discrepancy may be due to adjustment for marital status and presence of children. "
		compare.append warn
		'compare.append nz_{%ser}
		!count=!count+1
	endif
	smpl %datestart %dateend
next

string match = "Final LFPRs match those in the a-bank."
if !count=0 then compare.append match
endif

compare.display
 
smpl %datestart %dateend


pageselect results
copy comparison\compare results\ 

'create a spool that would contain summary info for the run
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The run represents TR" + @str(!TRyr) + ", alt " + %alt + ", and LFPRs that are " + %lfpr + " { [a]=adjusted, [u]=unadjusted }"
string line3 = "and uses the following parameters and inputs:"
string line4 = "a-bank: " + %abankpath
string line5 = "d-bank: " + %dbankpath
string line6 = "op-bank: " + %opbankpath
string line7 = "add-bank: " + %addbankpath
string line8 = "LFPR equation coefficients from " + %LFPRestimates
string line9 = "Labor force addfactors from " + %LCadj
string line10 = "If LFPR is adjusted, the base used for the adjustment is " + @str(!annual) + %LFPR_adj_base 
if %sav = "Y" then
	string line11 = "The resulting workfile -- " + %this_file + " -- has been saved to " +%folder_output
endif
if %sav = "N" then
	string line11 = "The resulting workfile -- " + %this_file + " -- has NOT been saved. Please save the file manually if desired."
endif
string line12 = "Polina Vlasenko"

_summary.insert line1 
_summary.append compare
_summary.insert line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12
_summary.display

delete line*

if %sav = "Y" then 
	'save the workfile
	%save_file = %folder_output + %this_file  
	wfsave %save_file
endif
 

'wfclose


