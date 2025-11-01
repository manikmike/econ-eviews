' Program Name: GovtSector_v1r.prg
'
' DESCRIPTION:
'    This program uses the government sector data constructed by Bill to update the government sector data series
'      1.  Bill uses data from the CWHS E-E file to construct these data, the CWHS data is released in June
'      2.  There are two versions.  Version 1 is the first report for a given year, version 3 is the third report for a given year 
'	       which we consider final
'      3.  For the State and Local employment and wages, It creates estimates for the most recent two years by taking 
'            the two year average of the most recent V3/V1 ratios.
'      4.   The program produces a workfile with several "pages": (1) raw v1 (2) raw v3 (3) ratio v3/v1 (4) last two year average of v3/1 (5) final estimates for last two years v1*(v3/v1 average) (6) Final government sector
'         Created:        5-28-2015, Bob Weathers
'         Updated:       8-19-2016, Corrected early historical data, corrected v1 and v3 worksheets by removing _e, _ns, _s which do not come from e-e files, cosmetic changes to clarify program, added military.
'         Updated:      11-14-2017 Corrected early historical data by matching it up with tr172 values for 1983-1990.  For 1983-1985, match the EPOXY estimates for TEFC.

' 		Updated: 		11/07/2019 Polina Vlasenko
'						Updated all input files to refelct files for TR20. Also, changed the code to be more adaptable: 
'						(1) collected references to all input files at the start of code, 
'						(2)  replaced hard references to years with string variables, and similar changes.
'						Also, I commented out the first section of the code that loads historical data from MEF, as it appeasr to be needed only once (see lines 90-105)

'  GOVT SECTOR VARIABLES (from E-E file) :
' 	Federal Civilian (no adjustment as V1=V3 due to timely reporting)
'		tefc =				total employment, fed govt civ																			
'		tefc_o =			total employment, fed govt civ OASDI covered
'		tefc_n =			total employment, fed govt civ not OASDI covered (CSRS workers)
'		tefc_n_o =  		total employment, fed govt civ not OASDI covered but with other OASDI covered emp
'		tefc_n_n =		total employment, without fed civ OASDI covered and without other OASDI covered emp
'		wefc =			wages, fed govt civ
'		wefc_o =		wages, fed govt civ OASDI covered
'		wefc_n =		wages, fed govt civ not OASDI covered
'		wefc_n_hi =	wages, fed govt civ not OASDI covered but with HI (no longer used)
'		wefc_n_nhi =  wages, fed govt civ not OASDI covered and no HI (no longer used)
'          tefc_o_o_p =   																	(no longer used)

'     Military  (no adjustment as V1=V3 due to timely reporting)
'          teml = 			total employment, military
'		teml_o = 		total employment military, OASDI covered
'		teml_n =		total employment military, not OASDI covered
'		teml_n_o =		total employment military, not OASDI covered but with other OASDI covered
'		teml_n_n =		total employment military, not OASDI covered and no other OASDI covered
'		wesl =			total wages military
'		wesl_o =		total wages military, OASDI covered
'		wesl_n =		total wages military, not OASDI covered
'		wesl_n_hi =	total wages military, not OASDI covered with hi coverage
'		wesl_n_nhi =  total wages military, not OASDI covered with no hi coverage  
'          teml_o_o_p =   																	(no longer used)

'    State and Local (adjust V1 in most recent two years for reporting lags)
'		tesl =				total employment, state and local govt		(adjustment to v1 for reporting lags)
'		tesl_o =			total employment, state and local govt OASDI covered	(adjustment to v1 for reporting lags)
'		tesl_n =			total employment, state and local govt not OASDI covered  (residual: tesl - tesl_o)
'		tesl_n_o =  	total employment, state and local govt not OASDI covered but with other 		
'  							OASDI covered emp (adjustment to v1 for reporting lags)
'		tesl_n_o_hi =	total employment, state and local govt, with other OASDI coverage and with HI	
'							(adjustment to v1 for reporting lags)
'		tesl_n_o_nhi=total employment, state and local govt, with other OASDI coverage and without HI 	
'							(residual: tesl_n_o - tesl_n_o_hi)
'		tesl_n_n	=	total employment, state and local govt, not OASDI or other OASDI covered emp 	
'							(residual: tesl_n - tesl_n_o)
'		tesl_n_n_hi =	total employment, state and local govt, without other OASDI coverage but with HI	
'							(adjustment to v1 for reporting lags)
'		tesl_n_n_nhi=	total employment, state and local govt, without other OASDI coverage and without HI 	
'							(residual: tesl_n_n - tesl_n_n_hi)
'		wesl	=			wages, state and local govt 																	
'							(adjustment to v1 for reporting lags)
'		wesl_o =		wages, state and local govt, with OASDI coverage										
'							(adjustment to v1 for reporting lags)
'		wesl_n =		wages, state and local govt, without OASDI coverage									
'							(residual: wesl - wesl_o)
'		wesl_n_hi =	wages, state and local govt, without OASDI coverage but with HI					
'							(adjustment to v1 for reporting lags)
'		wesl_n_nhi =	wages, state and local govt, without OASDI coverage and without HI				
'							(residual: wesl_n - wesl_n_hi)
'		tesl_o_o_p =(no longer used)


'  CREATION OF BASE WORKFILE
'  We created the base workfile that contains three pages-GovtSector201407, GovtSector201407_v1, GovtSector2014_v3
'  The original base was created from the following excel spreadsheets, which I have also stored in the Eviews\govtsector\excel folder on the econ directory
'  This program starts with the base workfile and updates it with the most recent data.
'   Below are the Eviews commands to load in the initial baseline data, I then drag and dropped v1 and v3 into the GovtSector201407 workfile (the base).
'     wfopen "\\s1f906b\econ\Processed data\Covdata\GovtSector201407.xlsx" range='DatatoAremos' byrow colhead=2 namepos=last na="#N/A" @freq U 1990 @smpl @all
'     wfopen "\\s1f906b\econ\Processed data\Covdata\GovtSector201407_ckv1.xlsx" range='V1 Raw(97-111) ' byrow colhead=2 namepos=last na="#N/A" @freq U 1997 @smpl @all
'     wfopen "\\s1f906b\econ\Processed data\Covdata\GovtSector201407_ckv3.xlsx" range='V3 Raw(97-109) ' byrow colhead=2 namepos=last na="#N/A" @freq U 1997 @smpl @all

'1983-1990 Data are from MEF.bnk used for TR17.  This provides consistency in early years across TRs.  Need to check to make sure values for 1983--1985 continue to match up with EPOXY.
'  This period is challenging because of the quality of the Fed Civ and State and Local Government data in the EE-ER during the period.
'  For details on the decisions, see spreadsheet "Derivation of 1% EE-ER HI Only wage workers - 20161116PAT-Excel.xls, located here: \\s1f906b\econ\Processed data\Covdata\TR17

' *** This section appears to be something that was needed only once. In all future years, the new govtsector file is based on the previous-year govtsectors file, which would already contain these series. Thus, I am commenting out this section for TR20. -- PV
'dbopen(d=aremos) \\s1f906b\econ\Aremos\TR2018Banks\MKS\mef.bnk
'wfcreate(wf=temp, page=temp) a 1983 1990
'fetch tefc tefc_n tefc_n_n tefc_n_o tefc_o wefc wefc_n wefc_o tesl tesl_o tesl_n  tesl_n_o tesl_n_o_hi tesl_n_o_nhi tesl_n_n tesl_n_n_hi tesl_n_n_nhi wesl wesl_o wesl_n wesl_n_hi wesl_n_nhi
'wfopen \\s1f906b\econ\EViews\TR18_Programs_Data\govtsector201710.wf1

'for %j tefc tefc_n tefc_n_n tefc_n_o tefc_o wefc wefc_n wefc_o tesl tesl_o tesl_n  tesl_n_o tesl_n_o_hi tesl_n_o_nhi tesl_n_n tesl_n_n_hi tesl_n_n_nhi wesl wesl_o wesl_n wesl_n_hi wesl_n_nhi 
'	copy(smpl="1983 1990",m) temp::temp\{%j} govtsector201710::govtsector201710\
'next

'group tef tefc tefc_o tefc_n tefc_n_o tefc_n_n wefc wefc_o wefc_n
'group tes tesl tesl_o tesl_n tesl_n_o tesl_n_n tesl_n_n_hi tesl_n_n_nhi wesl wesl_o wesl_n wesl_n_hi wesl_n_nhi 
'close mef.bnk
'close temp 



'5/25/2023
'updated by SL to load data from workfiles instead of databanks - lines 327 through 340 and 346 through 357
'input file paths still need to be changed

' ******

' Update the following strings to account for new data.  
'  These two strings and the value must chage each year to account for new data.  
'  NOTE: next year will only need 14 for v1 and 12 for v3, this year had to catch up.

%v1_yr = "22" 	
%v3_yr = "20" 	
!TAX_YR = 2022 	' usually mirrors the v1_yr
!V3_YR = 2020 	' mirrors the v3_yr

' *** UPDATE input files ***
' Update these strings to reflect the filenames for the current and prior-year govtsector file.
' Example: if prior-year fille was named 'govtsector201710.wf1' -- enter "201710" into %gfile_old and "201810" into %gfile_new
%gfile_old = "202310"		
%gfile_new = "202410"		

%govtsector_prior = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR24_ProgramsData\govtsector\workfile_prg\govtsector202310.wf1" 	' FULL PATH to the govtsector workfile from prior year; filename must be consistent with %gfile_old above
%raw_data = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\CWHS"							' RAW govtsector data (i.e. files GovtSectorXXXX.out) are assumed to be located in this folder
%epoxy = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\epoxy_r2023.wf1"		' EPOXY (aggregate MEF) file created for the current TR. Example: for TR25 this program was run in Oct 2024 and the file was epoxy_r2013.wf1
%epoxy_f = "epoxy_r2023"	' filename only
%bkdo1 = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\govtsector\bkdo1.wf1"  	'BKDO1 bank for current TR; for TR22 this is Budget\dat\bkdo1.bnk rev 2022.1
%bkdo1_f = "bkdo1"		' filename only
%abank = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\govtsector\atr242.wf1" 	' a-bank for prior TR
%abank_f = "atr242" 	' filename only
	
%this_file = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\govtsector" + %gfile_new + ".WF1"		' location to save the file created by this program;
																																		' NOTE: this program will save the file to this location and OVERWRITE any files with the same name already there!!!

' This defines the averaging period for estimating the completion rates.   
'  We use the most recent two years of the v3 data, but that could changed by simply changing the range below.
%yr_avg= "2019 2020" 		

' *** END of Update ***


' This string can remain the same each year.  Might need to re-include weml_n_hi if we need it in the future for the model.
%govtsector = "tefc tefc_n tefc_n_n tefc_n_o tefc_o teml teml_n teml_n_n teml_n_o teml_o teml_o_o_p tesl  tesl_n   tesl_n_n   tesl_n_n_hi   tesl_n_n_nhi tesl_n_o tesl_n_o_hi tesl_n_o_nhi tesl_o tesl_o_o wefc wefc_n wefc_n_hi wefc_n_nhi wefc_o weml weml_n weml_n_nhi weml_o  wesl wesl_n wesl_n_hi wesl_n_nhi wesl_o"  

' This string identifies data where we assume v3=v1, which is the federal civilian sector.  
%fcgsector = "tefc tefc_n tefc_n_n tefc_n_o tefc_o  wefc wefc_n wefc_n_hi wefc_n_nhi wefc_o"

' This string identifies data where we estimate final totals for last two year reports, based on the historical ratios for v3/v1.  These are the State and Local numbers.
%slgsector = "tesl  tesl_n   tesl_n_n   tesl_n_n_hi   tesl_n_n_nhi tesl_n_o tesl_n_o_hi tesl_n_o_nhi tesl_o wesl wesl_n wesl_n_hi wesl_n_nhi wesl_o"

' This string identies data for the military government sector.
%mgsector ="teml teml_n teml_n_n teml_n_o teml_o teml_o_o_p weml weml_n weml_n_nhi weml_o"

'STEP 1:  READ IN THE WORKFILE FROM PREVIOUS TR AND SAVE IT WITH UPDATED DATE. 

    'a. Previous govtsector workfiles renamed for current year and month.
	wfopen {%govtsector_prior}       '\\s1f906b\econ\EViews\govtsector\govtsector201910.wf1 . NOTE: if we are loading things from MEF above -- comment out this line!
   	pageselect Govtsector{%gfile_old}
	pagerename Govtsector{%gfile_old} Govtsector{%gfile_new}
	pageselect Govtsector{%gfile_old}_v1
	pagerename Govtsector{%gfile_old}_v1 Govtsector{%gfile_new}_v1
	pageselect Govtsector{%gfile_old}_v3
	pagerename Govtsector{%gfile_old}_v3 Govtsector{%gfile_new}_v3
	pageselect govtsectormef
	pagerename govtsectormef govtsectormef{%gfile_old} 
	wfsave(2) {%this_file}		'\\s1f906b\econ\Code\EViews\TR21_Programs_Data\govtsector\govtsector{%gfile_new}.WF1
     pagedelete govtsector_f
	
	
'STEP 2: READ IN NEW V3 AND V1 FILES

	'a. Read in the V3 govtsector files from Bill's output files and create Eviews workfile, store in double precision
		for %j {%v3_yr}
			wfopen {%raw_data}\GovtSector{%j}v3.out ftype=ascii rectype=crlf skip=1 fieldtype=delimited delim=space byrow colhead=1 eoltype=pad badfield=NA @freq U 1
			wfselect govtsector{%gfile_new}
			pageselect govtsector{%gfile_new}_v3
			pageappend GOVTSECTOR{%j}V3\Govtsector{%j}v3
			close GOVTSECTOR{%j}V3
		next
	pageselect govtsector{%gfile_new}_v3
	pagestruct(freq=a,start=1997,end=!V3_YR)

	'b. Read in the V1 govtsector files from Bill's output files and create Eviews workfile, store in double precision
		for %j {%v1_yr}
			wfopen {%raw_data}\GovtSector{%j}v1.out ftype=ascii rectype=crlf skip=1 fieldtype=delimited delim=space byrow colhead=1 eoltype=pad badfield=NA @freq U 1
			wfselect govtsector{%gfile_new}
			pageselect govtsector{%gfile_new}_v1
			pageappend GOVTSECTOR{%j}V1\Govtsector{%j}v1
			close GOVTSECTOR{%j}V1
    	      next
	pageselect govtsector{%gfile_new}_v1
	pagestruct(freq=a,start=1997,end=!TAX_YR)


'STEP 3: CREATE FACTORS USED FOR ESTIMATING FINAL S & L NUMBERS

	'a. Create new workpage in the work file to construct the factor used to estimate the final report
		pageselect govtsector{%gfile_new}_v1
		pagecopy(page=govtsector_f) 

  		for %j {%slgsector} {%fcgsector} {%mgsector}
    		  genr {%j}_v1={%j}
     		  delete {%j}
  		next

		copy(m) govtsector{%gfile_new}_v3\* govtsector_f\*   
		
		' define a sample with starting point at 1997 and the endpoint that moves every year to be one year EARLIER than %v3_yr
		!yr2 = 2000 + @val(%v3_yr) -1
		%yr2 = @str(!yr2)
		%smpl2 = "1997 " + %yr2

	      for %j tesl_n_n_nhi_ns tesl_n_o_nhi_ns wesl_n_nhi_s tesl_n_n_nhi_s  tesl_n_o_nhi_s wesl_n_nhi_ns 
	  		copy(smpl=%smpl2) govtsector{%gfile_new}\{%j}  *	' copy(smpl="1997 2013") govtsector{%gfile_new}{%j}  * 	For TR20, this sample should be 1997 2014.
			' This loop is no longer needed. These values get overwritten below. -- PV 11/08/2019
		next

  		for %j {%slgsector} {%fcgsector} {%mgsector}
      		genr {%j}_v3={%j}
     		     delete {%j}
   		next 

   		for %j {%slgsector}
      		smpl {%yr_avg}
      		genr {%j}_ratio={%j}_v3/{%j}_v1
   		next

   		for %j {%slgsector}
     			smpl {%yr_avg}
     			genr {%j}_fct=@mean({%j}_ratio)
   		next

	'b.  Estimate S&L completion rates using historical average of v3/v1 factor
  		for %j  tesl  tesl_n_n_hi  tesl_n_o tesl_n_o_hi tesl_o  
    			smpl !TAX_YR-1 !TAX_YR
    			genr {%j} = ({%j}_fct(-2)*{%j}_v1)/10000  
  		next

		for %j  wesl wesl_n_hi wesl_o 
    			smpl !TAX_YR-1 !TAX_YR
    			genr {%j} = ({%j}_fct(-2)*{%j}_v1)/10000000  
  		next

	'c. Estimate S&L completion rates using residuals	
   		genr tesl_n				=	(tesl				-	tesl_o) 			
   		genr tesl_n_o_nhi 	= 	(tesl_n_o 		- 	tesl_n_o_hi)	
   		genr tesl_n_n 			=	(tesl_n 			- 	tesl_n_o)		
   		genr tesl_n_n_nhi 	= 	(tesl_n_n 		- 	tesl_n_n_hi)	
   		genr wesl_n           	=	(wesl      		- 	wesl_o)		
   		genr wesl_n_nhi  	=	(wesl_n  		- 	wesl_n_hi)	

	'e. For fc and ml sector estimated final is v1 version
  		for %j {%fcgsector} {%mgsector}
    			genr {%j} = {%j}_v1
  		next

	'f. Scale fcgsector
  		for %j tefc tefc_n tefc_n_n tefc_n_o tefc_o teml teml_n teml_n_n teml_n_o teml_o
    			smpl !TAX_YR-1 !TAX_YR
    			genr {%j} = {%j}_v1/10000  
  		next

  		for %j wefc wefc_n wefc_o weml weml_n weml_o
    			smpl !TAX_YR-1 !TAX_YR
    			genr {%j} = {%j}_v1/10000000  
  		next

	'f.  For TAXYR-2 use v3 versions for all variables.
		smpl !TAX_YR-2 !TAX_YR-2
		for %j tefc tefc_n tefc_n_n tefc_n_o tefc_o tesl  tesl_n   tesl_n_n   tesl_n_n_hi   tesl_n_n_nhi tesl_n_o tesl_n_o_hi tesl_n_o_nhi tesl_o  teml teml_n teml_n_n teml_n_o teml_o
		   {%j}={%j}_v3/10000
          next			
  		
		for %j wefc wefc_n wefc_o wesl wesl_n_nhi wesl_n_hi wesl_o wesl_n weml weml_n weml_o
     		   {%j} = {%j}_v3/10000000  
  		next

   
'STEP 4: REPLACE TAX_YR-2 with the new v3 values or with other TAX_YR-2 data.

	'a. Drop last year (which we will replace with the new v3) from Govtsectoryyymm worksheet.
		pageselect Govtsector{%gfile_new}
		pagestruct(freq=a,start=1983, end=!TAX_YR-3)
		pageappend(smpl = !TAX_YR-2 !TAX_YR-2) govtsector{%gfile_new}\govtsector_f  tefc tefc_n tefc_n_n tefc_n_o tefc_o  wefc wefc_n wefc_o {%slgsector}  teml teml_n teml_n_n teml_n_o teml_o weml weml_n weml_o
		pagestruct(freq=a,start=1983)
	
		
' STEP 5: REPLACE TAXYR-1 and TAX_YR variables with new estimates.

	'a.  Append two most recent years to Govtsectoryyymm worksheet.
		pageselect Govtsector{%gfile_new}
  	     pageappend(smpl = !TAX_YR-1 !TAX_YR) govtsector{%gfile_new}\Govtsector_f tefc tefc_n tefc_n_n tefc_n_o tefc_o  wefc wefc_n wefc_o {%slgsector} teml teml_n teml_n_n teml_n_o teml_o weml weml_n weml_o
		pagestruct(freq=a,start=1983)

	wfsave(2) {%this_file}		' \\s1f906b\econ\Code\EViews\TR21_Programs_Data\govtsector\govtsector{%gfile_new}.WF1


' Create ultimate values for Fed Civ, state and Local, and military used for TR:
'  THIS NEEDS TO BE UPDATED WHEN WE IMPROVE ASSIGNMENTS IN CHWS!

pageselect Govtsector{%gfile_new}
genr tesl_n_hi=tesl_n_n_hi+tesl_n_o_hi

pagecreate(page=govtsectormef) a 1983 !TAX_YR
'Federal civilian series are assumed to be completely assigned in the CWHS data. 
for %j tefc tefc_o tefc_n tefc_n_n tefc_n_o wefc wefc_o wefc_n teml_o
 	copy govtsector{%gfile_new}\{%j} govtsectormef\{%j}
next

'MQGE variable and tefc_n_n are used to construct tesl_n_n_hi
wfopen {%epoxy}		
copy est_finals\mqge govtsector{%gfile_new}::govtsectormef\
close {%epoxy_f} 

smpl 1983 1985
genr tefc_n_n=mqge
genr tefc_n_o=tefc_n-tefc_n_n

smpl 1983 !TAX_YR
wfopen {%bkdo1}		
wfselect govtsector{%gfile_new}
pageselect govtsectormef
copy BKDO1::a\EGGEFC govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\EGGESL govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\NF1819 govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\NF2024 govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\NM1819 govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\NM2024 govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\WSGGEFC govtsector{%gfile_new}::govtsectormef\
copy BKDO1::a\WSGGESL govtsector{%gfile_new}::govtsectormef\
close {%bkdo1_f} 
wfselect govtsector{%gfile_new}
pageselect govtsectormef
genr tesl_n_n_hi=mqge-tefc_n_n
genr tesl_n_o_hi=(tesl_n_n_hi*(govtsector{%gfile_new}\tesl_n_hi)/(govtsector{%gfile_new}\tesl_n_n_hi))-tesl_n_n_hi
genr n1824=nm1819+nm2024+nf1819+nf2024


wfopen %abank		'"\\s1f906b\econ\Aremos\TR2018Banks\secret place\atr182.bnk"
wfselect govtsector{%gfile_new}
pageselect govtsectormef
copy {%abank_f}::a\tesl_n_n_nhi_e govtsector{%gfile_new}::govtsectormef\
copy {%abank_f}::a\tesl_n_o_nhi_e govtsector{%gfile_new}::govtsectormef\
copy {%abank_f}::a\tesl_n_n_nhi_s govtsector{%gfile_new}::govtsectormef\
copy {%abank_f}::a\tesl_n_o_nhi_s govtsector{%gfile_new}::govtsectormef\
copy {%abank_f}::a\wesl_n_nhi_e govtsector{%gfile_new}::govtsectormef\
copy {%abank_f}::a\wesl_n_nhi_s govtsector{%gfile_new}::govtsectormef\
close {%abank_f}
wfselect govtsector{%gfile_new}
pageselect govtsectormef

smpl 1995 !TAX_YR
genr tesl=1.33412155866056*eggesl    'Factor is average of TESL/eggesl over 1991 to 1995 period.  Need to improve upon this method for next year's TR!!
genr tesl_o=tesl*(govtsector{%gfile_new}\tesl_o)/(govtsector{%gfile_new}\tesl)
genr tesl_n=tesl-tesl_o
genr tesl_n_o=tesl_n*(govtsector{%gfile_new}\tesl_n_o)/(govtsector{%gfile_new}\tesl_n)
genr tesl_n_o_nhi=tesl_n_o-tesl_n_o_hi
genr tesl_n_n=tesl_n-tesl_n_o
genr tesl_n_n_nhi=tesl_n_n-tesl_n_n_hi


genr wesl=wsggesl*0.99
genr wesl_n_hi=(tesl_n_n_hi+tesl_n_o_hi)*((govtsector{%gfile_new}\wesl_n_hi)/((govtsector{%gfile_new}\tesl_n_n_hi)+(govtsector{%gfile_new}\tesl_n_o_hi)))
genr wesl_n_nhi=(tesl_n_n_nhi+tesl_n_o_nhi)*((govtsector{%gfile_new}\wesl_n_nhi)/((govtsector{%gfile_new}\tesl_n_n_nhi)+(govtsector{%gfile_new}\tesl_n_o_nhi)))

delete tesl_n_n_nhi
delete tesl_n_o_nhi

'Removed tesl_n_n_hi and tesl_n_o_hi from below to accomodate update of mqge and shift so that we have internal consistentcy:
for %j tesl tesl_o tesl_n tesl_n_o tesl_n_o_nhi tesl_n_n wesl wesl_o wesl_n wesl_n_hi wesl_n_nhi
 copy(smpl="1983 1994",m) govtsector{%gfile_new}\{%j} govtsectormef\{%j}
next

'This next block of code shifts the distribution such that tesl_n_n_hi +tefc_n_n=mqge.  Need to refine this in the future.
' This is needed because he_wo_m changed from tr172 to tr182 due to reporting updates.
smpl 1983 !TAX_YR
genr tesl_n_hi=tesl_n_n_hi+tesl_n_o_hi
genr tesl_n_n_hi=mqge-tefc_n_n
genr tesl_n_o_hi=tesl_n_hi-tesl_n_n_hi
genr tesl_n_n_nhi=tesl_n_n-tesl_n_n_hi
genr tesl_n_o_nhi=tesl_n_o-tesl_n_o_hi

'copy(smpl="1983 1994",m) govtsector201710\tesl_n_n_hi govtsectormef\
'copy(smpl="1983 1994",m) govtsector201710\tesl_n_o_hi govtsectormef\

smpl 1995 !TAX_YR
genr wesl_n=wesl_n_hi+wesl_n_nhi
genr wesl_o=wesl-wesl_n

smpl 1983 !TAX_YR
genr tesl_n_n_nhi_ns=tesl_n_n_nhi-tesl_n_n_nhi_e-tesl_n_n_nhi_s
genr tesl_n_o_nhi_ns=tesl_n_o_nhi-tesl_n_o_nhi_e-tesl_n_o_nhi_s
genr wesl_n_nhi_ns=wesl_n_nhi-wesl_n_nhi_e-wesl_n_nhi_s

'TEML_O Historical from Cov141125.xls
smpl 1982 1996
teml_o.adj = 3.325 3.385 3.394 3.443 3.493 3.493 3.512 3.510 3.416 3.365 3.208 2.795 2.790 2.627 2.522


'TEP_N_N_S: 
smpl @all 
genr tep_n_n_s=0

' Data through 2011 is from \\s1f906b\econ\TrusteesReports\TR2017\CWHS\Derivation of 1% EE-ER HI Only wage workers - 20161116 PAT.xlsx tab S&L column CB; manually copied below
' Same files appears in \\s1f906b\econ\Data\Processed\Covdata\TR17\
smpl 1983 2012
tep_n_n_s.adjust = 0.257018402 0.252872716 0.245209945 0.239017924 0.233597847 0.230041202 0.227303535 0.237660665 0.234147318 0.238294236 0.239292569 0.241519618 0.243362693 0.249352686 0.253883579 0.258721651 0.267399462 0.26448126 0.270701638 0.274925352 0.280377782 0.285215854 0.289439567 0.293893665 0.298040584 0.302801861 0.307332754 0.311402877 0.316010565 

' For year 2012 and later, evolve the values by the growth rate of n1824; this is the same method used by Pat in his file (Derivation of 1% EE-ER HI Only wage workers - 20161116 PAT.xlsx) for years after 2011.
smpl 2012 !TAX_YR
genr tep_n_n_s=tep_n_n_s(-1)*n1824/n1824(-1)

smpl @all 

wfsave(2) {%this_file}


'''STEP 6:  OUTPUT INTO EXCEL SPREADSHEET FOR CHECKS.  FC=V1 values, S&L=Estimates
'''  Compare to the Skirvin Template Spreadsheet. 
''   smpl 1983 2021
''    delete awr_ns cer_mqge_o esr_ns weml_n_nhi weml_n_hi wesl_n_nhi_e wesl_n_nhi_ns wesl_n_nhi_s wesl_o___wesl_n_hi tesl_n_n_nhi_e tesl_n_n_nhi_ns tesl_n_n_nhi_s tesl_n_s tesl_n_o_nhi_e tesl_n_o_nhi_ns tesl_n_o_nhi_s tesl_n_e tony_s_941
''    wfsave(type=excelxml) S:\LRECON\Data\Processed\TR23_ProgramsData\govtsector\workfile_prg\govtsector202210.xlsx


