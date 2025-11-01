' This program produces several tables covering Short-Run period
'The program creates several workfiles, each computing the values needed for one or more tables. 
'The resulting tables are then outputed in PDF format
'The tables can also be viewed by going into the workfiles; this method is useful if user need to save the tables in Excel later, or to modify them in any way. 
'Polina Vlasenko 02-09-2017

' This version was changed to accomodate the change in real GDP variable due to BEA comprehensive revisions of 2018. The real GDP series are changed from gdo09 to gdp12; other related series similarly changed. ---- Polina Vlasenko 01/14/2019

' Updated to TR2020 input files -- PV 4/10/2020
' Updated to TR2021 input files -- SHS 8/24/2021
' Consult the commit history of the econ-eviews Git repository for additional update information

'This program requires the following databanks:
' a-bank
' d-bank

'*****UPDATE these variables before running the program to make sure it uses correct files****
!datestart = 2019 'the earliest year to be DISPLAYED in the tables; using the latest BC peak, but can be changed to anything
!dateend = 2034 'the last year to be displayed in the tables; this should be the end of SR period

%tr="25" 'two-digit TR year; this is a string
%alt="2" 'ALT for the TR noted above; this is a string

'location of the databanks (a-bank and d-bank) associated with the TR denoted above
%inputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\" 
'folder where the resulting checks, tables, and workfiles are to be stored; several workfiles and PDF files will be stored to this folder
%outputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\ShortRangeTables\" 'folder where the resulting checks, tables, and workfiles are to be stored

'%inputpath_special = "\\LRSERV1\usr\eco.18\bnk\2017-1215-1531 TR182\" 'one-time use location for some runs

'*****END of section that needs updating for each run*****
'******************************************************************

'Databank names and locations 
%abank_ref="atr"+%tr+%alt 'short reference to databank, i.e. atr172
%dbank_ref="dtr"+%tr+%alt 
%abank="atr"+%tr+%alt+".wf1" 'name of the databank file, i.e atr172.wf1
%dbank="dtr"+%tr+%alt+".wf1"
%abankpath=%inputpath+%abank 'full path to the databank file, i.e. \\lrserv1\usr\eco.17\bnk\2016-1230-1601 tr172\atr172.bnk
%dbankpath=%inputpath+%dbank

!earlystart=!datestart-1 'in several cases we have to start the sample a year before the table starts b/c of the need to compute percent changes

'********************
'Template for making a table

'dbopen dbopen(type=aremos) "\\lrserv1\usr\eco.17\bnk\2016-1230-1601 tr172\atr172.bnk"
'wfcreate wfcreate slecove172 a 2009 2026 

'fetch
 
'close databank close atr172

'compute whatever variables need computing

'make tablist

'assign labels to variables

'constract table

'replace mnemonic with labels

'format table

'displey/save/etc table

'save the workfile
'close the workfile
'END of template

'************************************** 
'Creating the first table --  Table 1A Base Assumptions 
'The first workfile created here (NIPA182) differs from the template because it makes several tables. Other workfiles below usually make just one table. 

%wfname="Tab61_NIPA"+%tr+%alt 'name for the workfile, i.e. NIPA172
wfcreate(wf={%wfname},page=a) a !earlystart !dateend 'have to start one year before !datestart so as to be able to compute percent changed starting at !datestart
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser kgdp17 gdp17 pgdp gdp ws y rtp lc ru e p16o edmil eprrb_f eprrb_m cmb cpiw_u te tceahi tcea tesl_n_n_hi tefc_n_n wswa seo ceso_m teph_n tep_n_n_s tesl_n_n_nhi tesl_n_n_nhi_e tesl_n_n_nhi_ns tesl_n_n_nhi_s wswahi
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfopen {%dbankpath}
pageselect a
for %ser n16o 
	copy {%dbank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%dbank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'Create variable lists for each table
%tab1list = "kgdp17 kgdp17pc gdp17 gdp17pc pgdp pgdppc gdp gdppc ws wspc y ypc rtp rtpdf wsgdp wsgdpdf"
%table1b = "n16o n16opc lc lcpc ru rudf e epc p16o p16odf edmil edmilpc cpiw_u cpiw_upc pricedf"
%tab61list= "lc ru e edmil e_edmil te nocov teph_n eprrb tep_n_n_s tesl_n_n_nhi tesl_n_n_nhi_s tesl_n_n_nhi_e tesl_n_n_nhi_ns tceahi mqge tesl_n_n_hi tefc_n_n tcea wswa cmb we_only ceso_m hi2te oasdi2te rtp"  

'Create labels for each table
 'make sure the text is assigned to the "description" field of the label; this is later used to create column/row headings in the tables
' Table 1.1A NIPA variables
  kgdp17.label(d) Potential GDP in 2017 dollars
  gdp17.label(d) GDP in 2017 dollars
  pgdp.label(d) GDP Price Index
  gdp.label(d) GDP in current dollars 
  ws.label(d) NIPA wages
  y.label(d) Proprietors Income
  rtp.label(d) Ratio of Real to Potential GDP

'Table 1.1A BLS variables
  n16o.label Noninst. Pop. 
  lc.label Labor Force
  ru.label Unemployment Rate (%)
  e.label Employment 
  p16o.label LF Part. Rate (%)
  edmil.label Military Pop. 
  cpiw_u.label Level (CPIW_U)

'Table 6.1 OASDI Program variables
genr eprrb=eprrb_f+eprrb_m
genr we_only=wswa-cmb

  te.label  Total Employed At Any Time 
      teph_n.label Private Household 
      eprrb.label Railroad
      tep_n_n_s.label Students
    tesl_n_n_nhi.label S&L 
      tesl_n_n_nhi_s.label Students
      tesl_n_n_nhi_e.label Election Workers 
      tesl_n_n_nhi_ns.label Resid. Closed Group 
 
  tceahi.label HI Covered
    tesl_n_n_hi.label S&L HI Only 
    tefc_n_n.label Fed. Civ HI Only 

  tcea.label OASDI Covered 
    wswa.label Some wages 
    cmb.label Wages and SE Income
    we_only.label Wages Only
    ceso_m.label SE Income Only

'Additional computations and formatting for each table

'Table 1.1A - BASE ASSUMPTIONS - NIPA variables
'Compute percent change values and produce labels
'Since the steps are the same for all variable, we do it in a loop
for %var kgdp17 gdp17 pgdp gdp ws y
	%varpc=%var+"pc"
	genr {%varpc}=@pc({%var})
	{%varpc}.label % change
	{%varpc}.setformat f.4
next

'Compute rtp and wage to gdp and produce labels
  genr rtpdf=@d(rtp)
  rtpdf.label % pt diff.
  rtpdf.setformat f.4
  genr wsgdp=ws/gdp
  wsgdp.label Ratio of Wages to GDP
  wsgdp.setformat f.4
  genr wsgdpdf=@d(wsgdp)
  wsgdpdf.label % pt. diff.
  wsgdpdf.setformat f.4

'Generate table
  smpl !datestart !dateend
  group bnipa {%tab1list}
  freeze(base1) bnipa.sheet(t) 'note that the table is a TRANSPOSED sheet view, with each COLUMN corresponding to a year and each row listing one variable
  smpl @all
  
'Replace mnemonic with label
!n=3
for %i {%tab1list}
	setcell(base1, !n, 1, {%i}.@description, "l") '@decsription is a string that contains text from the "decsription" field of the series' label view; here we plug in the string into row !n, col 1 of the table base1, and make it Left-justified..
 	!n=!n+1
next


'Table 1.1A(cont'd) BASE ASSUMPTIONS table - BLS variables

'Compute percentage change variables 
 for %var n16o lc e edmil cpiw_u
	%varpc=%var+"pc"
	genr {%varpc}=@pc({%var})
	{%varpc}.label % change
	{%varpc}.setformat f.4
next

'Compute  percentage point difference
  genr rudf=@d(ru)
  rudf.label % pt diff.
  rudf.setformat f.4
  genr p16odf=@d(p16o)
  p16odf.label % pt diff.
  p16odf.setformat f.4
  genr pricedf=pgdppc-cpiw_upc
  pricedf.label Price Differential (% Chg PGDP- %Chg CPIW_U)  
  pricedf.setformat f.4

'Construct Table
  smpl !datestart !dateend
  group bemppop {%table1b}
  freeze(base2) bemppop.sheet(t)
  smpl @all

'Replace mnemonic with label
!n=3
for %j {%table1b}
	setcell(base2, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'Format Table 1.1A - BASE ASSUMPTIONS
base1.table
base1.title TABLE 1.1A - BASE ASSUMPTIONS
base1(1,1) = "Calendar Year"
base1.insertrow(3) 1
setcell(base1, 3,1, "NIPA Output and Earnings ($Bill.)", "l")
base1.setwidth(A) 30
base1.setindent(A4:A19) 8
base1(20,1)= "Civ. Employment and Pop."
base1(21,1)="Age 16 and Over, HH Survey (mil.)"
' copy base2 table into base1 table 
	' determine the range for base2 table
	!ncols = !dateend - !datestart +2 ' number of columns in base2 table
	base2.copyrange 3 1 17 !ncols base1 22 1 	
' done copying base2
base1.setjust(20,1) left
base1.setjust(21,1) left
base1.setindent(A22:A38) 8
base1.insertrow(34) 2
base1(34,1)="CPI, Urban Wage and Clerical Workers"
base1(35,1)="Not Seas. Adj. (1982-84 = 1.0)" 
base1.setjust(34,1) left
base1.setjust(35,1) left


'Table 6.1 BLS Employment and Covered Wages:  NOTE THIS IS EXACTLY THE SAME AS 6.2, hence we are not creating table 6.2
genr e_edmil=e+edmil
e_edmil.label Employment Plus Military 
genr nocov=te-tceahi
nocov.label OASDI and HI Noncovered
'genr hionly=tceahi-tcea
'hionly.label OASDI Noncovered & HI Covered
genr mqge=wswahi-wswa
mqge.label OASDI Noncovered & HI Covered
genr wswa_o=wswa-seo
wswa_o.label Wages Only
genr hi2te=tceahi/te
hi2te.label HI Covered Ratio
genr oasdi2te=tcea/te
oasdi2te.label OASDI Covered Ratio

'Construct Table
  smpl !datestart !dateend
  group emcove {%tab61list}
  freeze(tab61) emcove.sheet(t)
  smpl @all

'Replace mnemonic with label
!n=3
for %j {%tab61list}
	setcell(tab61, !n, 1, {%j}.@description, "l") ' here we plug in the string that contains text from "description" field of the sereis' label into row !n, col 1 of the table tab61.
 	!n=!n+1
next


'Format table 61
tab61.table
tab61.title TABLE 6.1 - BLS EMPLOYMENT AND COVERED EMPLOYMENT (in millions)
tab61(1,1) = "Calendar Year"
tab61.insertrow(3) 1
setcell(tab61, 3,1, "BLS Civilian Household Survey", "l")
tab61.setwidth(A) 30
tab61.setindent(A4:A8) 8
tab61.insertrow(9) 1
tab61.setindent(A11) 8
tab61.insertrow(12) 1
setcell(tab61, 12,1, "Private", "l")
tab61.setindent(A12) 16
tab61.setindent(A13:A15) 24
tab61.setindent(A16) 16
tab61.setindent(A17:A19) 24
tab61.setindent(A20:A21) 8
tab61.setindent(A22:A23) 16
tab61.setindent(A24) 8
tab61.setindent(A25) 16
tab61.setindent(A26:A27) 24
tab61.setindent(A28) 16
tab61.insertrow(29) 1
tab61.setformat(@all) f.3


'display tables on screen; can use it to copy them to Excel
show base1 
show base2
show tab61

'save the tables in PDF
%tab11filepdf = %outputpath+"tab11_"+"TR20"+%tr+"_"+%alt+".pdf"
%tab61filepdf = %outputpath+"tab61_"+"TR20"+%tr+"_"+%alt+".pdf"

base1.save(t=pdf, landscape) {%tab11filepdf} 
tab61.save(t=pdf, landscape) {%tab61filepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open


'*********************************************
'Table 6.2A - Covered Wages and Employment, Federal Civilian Govt Sector

%wfname="Tab62a_fcecove"+%tr+%alt 'name for the workfile, i.e. fcecove172
wfcreate(wf={%wfname},page=a) a !datestart !dateend 'no need to compute percent changes here, so starting with !datestart
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser wsgfc wsggefc egfc eggefc wefc wefc_o wefc_n tefc tefc_o tefc_n tefc_n_o tefc_n_n
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

%tab62alist= "wsggefc eggefc awsggefc wefc wefc_o wefc_n tefc tefc_o tefc_n tefc_n_o tefc_n_n wefc_n tefc_n awsefc_n rctows rhitows rcwtote rctote"  

'create the necessary ratio variables
genr awsggefc=wsggefc/eggefc 
genr awsefc_n=wefc_n/tefc_n
genr rctows=wefc_o/wefc
genr rhitows=(wefc_o+wefc_n)/wefc
genr rcwtote=tefc_o/tefc
genr rctote=(tefc_o+tefc_n_o)/tefc
genr rhitote=(tefc_o+tefc_n)/tefc

'Assign labels to each variable
wsggefc.label NIPA Wages (bil. $) 
eggefc.label BLS Est. Emp. (mil.) 
awsggefc.label Average Wage (thous. $)
wefc.label Total Wages (bil. $) 
wefc_o.label w/Fed. Civ. OASDI wages
wefc_n.label wo/Fed. Civ. OASDI wages  
tefc.label Total Employment (mil.)
tefc_o.label w/Fed. Civ. OASDI wages
tefc_n.label wo/Fed. Civ. OASDI wages
tefc_n_o.label w/other OASDI wages
tefc_n_n.label wo/other OASDI wages 
'wefc_n.label
'tefc_n.label
awsefc_n.label Average (thous. $)
rctows.label OASDI Covered
rhitows.label HI Covered
rcwtote.label Fed. Civ. OASDI Covered
rctote.label Any OASDI Covered wages

'Construct table
smpl !datestart !dateend
group ewsgfc {%tab62alist} 
freeze(tab62a) ewsgfc.sheet(t)
smpl @all

'Replace mnemonic with label
!n=3
for %j {%tab62alist}
	setcell(tab62a, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next


'Format table 6.2A
tab62a.table
tab62a.title TABLE 6.2A - COVERED WAGES AND EMPLOYMENT, FEDERAL CIVILIAN GOVT. SECTOR
tab62a(1,1) = "Calendar Year"
tab62a.insertrow(3) 1
setcell(tab62a, 3,1, "Non-Program Data", "l")
tab62a.setwidth(A) 30
tab62a.setindent(A4:A6) 8
tab62a.insertrow(7) 2
setcell(tab62a, 8,1, "Program Data (At-any-time Concept)", "l")
tab62a.setindent(A9) 8
tab62a.setindent(A10:A11) 16 
tab62a.insertrow(12) 1
tab62a.setindent(A13) 8
tab62a.setindent(A14:A15) 16
tab62a.setindent(A16:A17) 24
tab62a.insertrow(18) 2
setcell(tab62a, 19,1, "Est. Total MQGE Posting", "l")
tab62a.setindent(A19) 8
setcell(tab62a, 20,1, "Taxable Wages (bil. $)", "l")
setcell(tab62a, 21,1, "Employment (mil.)", "l")
tab62a.setindent(A20:A22) 16
tab62a.insertrow(23) 3
setcell(tab62a, 24,1, "Ratio of Covered to Total", "l")
tab62a.setindent(A24) 8
setcell(tab62a, 25,1, "Fed. Civ. Wages", "l")
tab62a.setindent(A25) 16
tab62a.setindent(A26:A27) 24
tab62a.insertrow(28) 1
setcell(tab62a, 28,1, "Fed. Civ. Emp.", "l")
tab62a.setindent(A28) 16
tab62a.setindent(A29:A30) 24

tab62a.setformat(B4:S30) f.3

show tab62a 'disply table on screen

%tab62afilepdf = %outputpath+"tab62a_"+"TR20"+%tr+"_"+%alt+".pdf"
tab62a.save(t=pdf, landscape) {%tab62afilepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open

'****************************************
'Table 6.2B Covered Wages and Employment, State and Local Govt. Sector
%wfname="Tab62b_slecove"+%tr+%alt 'name for the workfile, i.e. slecove172
wfcreate(wf={%wfname},page=a) a !datestart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser wsggesl eggesl wesl wesl_o wesl_n wesl_n_hi wesl_n_nhi wesl_n_nhi_s wesl_n_nhi_e wesl_n_nhi_ns tesl tesl_o tesl_n tesl_n_o tesl_n_o_hi tesl_n_o_nhi tesl_n_o_nhi_s tesl_n_o_nhi_e tesl_n_o_nhi_ns tesl_n_n tesl_n_n_hi tesl_n_n_nhi tesl_n_n_nhi_s tesl_n_n_nhi_e tesl_n_n_nhi_ns
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
pageselect q
copy(c=x) {%abank_ref}::q\eggesl {%wfname}::a\eggesl_q 'this copies eggesl quarterly employment data and saves as annual value the MAX quarterly value for the year; the resulting workfile variable name is eggesl_q
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute whetever variables need computing
genr awsggesl=wsggesl/eggesl 'average wages
'ratios of covered to total -- wages
genr rctowssl_o=wesl_o/wesl
genr rctowssl_hi=(wesl_o+wesl_n_hi)/wesl
'ratios of covered to total -- employment
genr rctotesl_o=tesl_o/tesl
genr rctotesl_n_o=(tesl_o+tesl_n_o)/tesl
genr rctotesl_hi=(tesl_o+tesl_n_n_hi)/tesl
genr rctotesl_n_hi=(tesl_o+tesl_n_o_hi+tesl_n_n_hi)/tesl

'make tablist -- the list of all variables in the order I need them
%tab62blist= "wsggesl eggesl eggesl_q awsggesl wesl wesl_o wesl_n wesl_n_hi wesl_n_nhi wesl_n_nhi_s wesl_n_nhi_e wesl_n_nhi_ns tesl tesl_o tesl_n tesl_n_o  tesl_n_o_hi  tesl_n_o_nhi  tesl_n_o_nhi_s  tesl_n_o_nhi_e  tesl_n_o_nhi_ns tesl_n_n tesl_n_n_hi tesl_n_n_nhi tesl_n_n_nhi_s tesl_n_n_nhi_e tesl_n_n_nhi_ns rctowssl_o rctowssl_hi rctotesl_o rctotesl_n_o rctotesl_hi rctotesl_n_hi"  

'assign labels to variables
wsggesl.label NIPA Wages (bil. $)
eggesl.label BLS Est. Emp. (mil.)
    eggesl_q.label Qtr. max.
awsggesl.label Average Wage (thous. $)

wesl.label Total Wages (bil. $)
   wesl_o.label w/S&L OASDI WS
   wesl_n.label wo/S&L OASDI WS
      wesl_n_hi.label w/S&L HI
      wesl_n_nhi.label wo/S&L HI
         wesl_n_nhi_s.label students  
         wesl_n_nhi_e.label election workers
         wesl_n_nhi_ns.label nonstudents  

tesl.label Total Employment (mil.)
   tesl_o.label w/S&L OASDI WS
   tesl_n.label wo/S&L OASDI WS
      tesl_n_o.label w/other OASDI WS
         tesl_n_o_hi.label w/S&L HI
         tesl_n_o_nhi.label wo/S&L HI
            tesl_n_o_nhi_s.label students  
            tesl_n_o_nhi_e.label election workers
            tesl_n_o_nhi_ns.label nonstudents  
      tesl_n_n.label wo/other OASDI WS
         tesl_n_n_hi.label w/S&L HI
         tesl_n_n_nhi.label wo/S&L HI
            tesl_n_n_nhi_s.label students  
            tesl_n_n_nhi_e.label election workers
            tesl_n_n_nhi_ns.label nonstudents  

'Ratios of covered to total computed above
rctowssl_o.label OASDI Covered
rctowssl_hi.label HI Covered
rctotesl_o.label w/S&L OASDI Covered Wages
rctotesl_n_o.label w/Any OASDI Covered Wages
rctotesl_hi.label w/S&L HI Covered Wages
rctotesl_n_hi.label w/Any HI Covered Wages

'constract table
smpl !datestart !dateend
group ewsgsl {%tab62blist} 
freeze(tab62b) ewsgsl.sheet(t)
smpl @all

'replace mnemonic with labels
!n=3
for %j {%tab62blist}
	setcell(tab62b, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format table
tab62b.table
tab62b.title TABLE 6.2B - COVERED WAGES AND EMPLOYMENT, STATE AND LOCAL GOVT. SECTOR
tab62b(1,1) = "Calendar Year"
tab62b.insertrow(3) 1
setcell(tab62b, 3,1, "Non-Program Data", "l")
tab62b.setwidth(A) 30
tab62b.setindent(A4:A5) 8
tab62b.setindent(A6) 16
tab62b.setindent(A7) 8
tab62b.insertrow(8) 2
setcell(tab62b, 9,1, "Program Data (At-any-time Concept)", "l")
tab62b.setindent(A10) 8
tab62b.setindent(A11:A12) 16
tab62b.setindent(A13:A14) 24
tab62b.setindent(A15:A17) 28
tab62b.setindent(A18) 8
tab62b.setindent(A19:A20) 16
tab62b.setindent(A21) 24
tab62b.setindent(A22:A23) 28
tab62b.setindent(A24:A26) 30
tab62b.setindent(A27) 24
tab62b.setindent(A28:A29) 28
tab62b.setindent(A30:A32) 30

tab62b.insertrow(33) 3
setcell(tab62b, 34,1, "Ratios of Covered to Total", "l")
setcell(tab62b, 35,1, "State & Local Govt. Wages", "l")
tab62b.setindent(A35) 8
tab62b.setindent(A36:A37) 16
tab62b.insertrow(38) 1
setcell(tab62b, 38,1, "State & Local Govt Emp.", "l")
tab62b.setindent(A38) 8
tab62b.setindent(A39:A42) 16

tab62b.setformat(@all) f.3

'display/save/etc table
show tab62b

%tab62bfilepdf = %outputpath+"tab62b_"+"TR20"+%tr+"_"+%alt+".pdf"
tab62b.save(t=pdf, landscape) {%tab62bfilepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open

'********************************
'Table 6.3 NIPA Wages and Covered Wages (in billions)
%wfname="Tab63_nipacov"+%tr+%alt 'name for the workfile, i.e. nipacov172
wfcreate(wf={%wfname},page=a) a !datestart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser ws ws_n_nhi wsp_n_nhi wsph wsph_o wsprrb wspo_n_nhi wesl_n_nhi wsgfm wsgmlc wscahi wspc wesl_o wesl_n_hi wefc wesl wefc_n wsca wspc wsgca wsgfca wsgslca wefc_o 'these are for table6.3
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
for %ser wsp wsgge wsggesl wsggefc oasdi_tw oasdip_tw oasdigge_tw oasdisl_tw oasdifc_tw oasdifm_tw 'these are for table 6.4
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute additional variables for table 6.3
genr wsgfm_nhi=wsgfm-wsgmlc
genr wsph_n=wsph-wsph_o
genr wsgge_hi=wesl_o+wesl_n_hi+wefc+wsgmlc
genr wesl_hi=wesl_o+wesl_n_hi
genr ws_n_hi=wesl_n_hi+wefc_n
'genr wepb=wscahi-wefc-wesl-wsgmlc
'genr hionly=wscahi-wsca
'genr wepb_o=wsca-wefc_o-wesl_o-wsgmlc
'ratios to total NIPA wages
genr otows=wsca/ws
genr hitows=wscahi/ws

%tab63list= "ws ws_n_nhi wsp_n_nhi wsprrb wsph_n wspo_n_nhi wesl_n_nhi wsgfm_nhi wscahi wspc wsgge_hi wesl_hi wefc wsgmlc ws_n_hi wesl_n_hi wefc_n wsca wspc wsgca wsgslca wsgfca wsgmlc hitows otows"

'assign labels to variables
ws.label Total NIPA Wages (Disb.)
ws_n_nhi.label OASDI and HI Noncov.
    wsp_n_nhi.label Private
         wsprrb.label Railroad
         wsph_n.label Private Household
	    wspo_n_nhi.label Other Private
	wesl_n_nhi.label S&L
	wsgfm_nhi.label Military

wscahi.label HI Covered
	wspc.label Private
	wsgge_hi.label Govt. & Govt. Ent.
		wesl_hi.label S&L
		wefc.label Fed. Civ.
		wsgmlc.label Military

ws_n_hi.label OASDI Noncov. & Hi Cov.
	wesl_n_hi.label S&L HI Only
	wefc_n.label Fed. Civ. HI Only

wsca.label OASDI Covered
	wspc.label Private
	wsgca.label Govt. & Govt. Ent.
		wsgslca.label S&L
		wsgfca.label Fed. Civ.

hitows.label HI Covered
otows.label OASDI Covered

'constract table
smpl !datestart !dateend
group nipacov {%tab63list} 
freeze(tab63) nipacov.sheet(t)
smpl @all

'replace mnemonic with labels
!n=3
for %j {%tab63list}
	setcell(tab63, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format table
tab63.table
tab63.title TABLE 6.3 - NIPA WAGES AND COVERED WAGES (in $billions)
tab63(1,1) = "Calendar Year"
tab63.setwidth(A) 30
tab63.insertrow(3) 1
tab63.insertrow(5) 1
tab63.setindent(A6) 8
tab63.setindent(A7) 16
tab63.setindent(A8:A10) 24
tab63.setindent(A11:A12) 16
tab63.insertrow(13) 1
tab63.setindent(A14) 8
tab63.setindent(A15:A16) 16
tab63.setindent(A17:A19) 24
tab63.insertrow(20) 1
tab63.setindent(A21) 8
tab63.setindent(A22:A23) 16
tab63.insertrow(24) 1
tab63.setindent(A25) 8
tab63.setindent(A26:A27) 16
tab63.setindent(A28:A30) 24
tab63.insertrow(31) 2
setcell(tab63, 32,1, "Ratios to Total NIPA Wages (Disb.)", "l")
tab63.setindent(A33:A34) 8

tab63.setformat(@all) f.3

show tab63

%tab63filepdf = %outputpath+"tab63_"+"TR20"+%tr+"_"+%alt+".pdf"
tab63.save(t=pdf, landscape) {%tab63filepdf}

'TABLE 6.4 - NIPA WAGES, OASDI COVERED AND TAXABLE WAGES (in billions)
'compute additional variables for table 6.4
genr wsgge_o=wesl_o+wefc_o+wsgmlc
'ratios of OASDI covered to total NIPA wages in each category
'otows -- total, already computed above
genr otowspc=wspc/wsp
genr otowsgge=wsgge_o/wsgge
genr otowssl=wesl_o/wsggesl
genr otowsfc=wefc_o/wsggefc
genr otowsml=wsgmlc/wsgfm
'ratios of OASDI taxable to covered wages
genr txtoc=oasdi_tw/wsca
genr txtopc=oasdip_tw/wspc
genr txtocgge=oasdigge_tw/wsgge_o
genr txtocsl=oasdisl_tw/wesl_o
genr txtocfc=oasdifc_tw/wefc_o
genr txtocml=oasdifm_tw/wsgmlc

%tab64list= "ws wsp wsgge wsggesl wsggefc wsgfm wsca wspc wsgge_o wesl_o wefc_o wsgmlc otows otowspc otowsgge otowssl otowsfc otowsml oasdi_tw txtoc " 
'oasdip_tw oasdigge_tw oasdisl_tw oasdifc_tw oasdifm_tw *txtoc* txtopc txtocgge txtocsl txtocfc txtocml -- we decided not to include these lines in the table (they are still fully described below, so can be easily added if we so decide, *txtoc* IS included int he list.


'assign labels to variables
wsp.label Private Wages (Disb.)
wsgge.label Govt. & Govt. Ent. Wages
wsggesl.label State & Local 
wsggefc.label Federal Civilian 
wsgfm.label Military
wsgge_o.label Govt. & Govt. Ent. 
wesl_o.label State & Local
wefc_o.label Federal Civilian
wsgmlc.label Military
otowspc.label Private 
otowsgge.label Govt. & Govt. Ent. 
otowssl.label State & Local
otowsfc.label Federal Civilian
otowsml.label Military
oasdi_tw.label OASDI Taxable Wages
oasdip_tw.label Private 
oasdigge_tw.label Govt. & Govt. Ent. 
oasdisl_tw.label State & Local
oasdifc_tw.label Federal Civilian
oasdifm_tw.label Military
txtoc.label Ratio of OASDI Taxable to Covered Wages
txtopc.label Private 
txtocgge.label Govt. & Govt. Ent. 
txtocsl.label State & Local
txtocfc.label Federal Civilian
txtocml.label Military


'constract table
smpl !datestart !dateend
group nipatax {%tab64list} 
freeze(tab64) nipatax.sheet(t)
smpl @all

'replace mnemonic with labels
!n=3
for %j {%tab64list}
	setcell(tab64, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format table
tab64.table
tab64.title TABLE 6.4 - NIPA WAGES, OASDI COVERED AND TAXABLE WAGES (in $billions)
tab64(1,1) = "Calendar Year"
tab64.setwidth(A) 34
tab64.insertrow(3) 1
tab64.insertrow(5) 1
tab64.setindent(A6:A7) 8
tab64.setindent(A8:A10) 16
tab64.insertrow(11) 1
tab64(12,1) = "OASDI Covered Wages"
tab64.insertrow(13) 1
tab64.setindent(A14:A15) 8
tab64.setindent(A16:A18) 16
tab64.insertrow(19) 1
tab64(20,1) = "Ratio of OASDI Cov. to Total NIPA Wages"
tab64.insertrow(21) 1
tab64.setindent(A22:A23) 8
tab64.setindent(A24:A26) 16
tab64.insertrow(27) 1
tab64.insertrow(29) 1
'tab64.setindent(A30:A31) 8 -- There became redundant when we removed several lines with ratios from the ta
'tab64.setindent(A32:A34) 16
'tab64.insertrow(35) 1
'tab64.insertrow(37) 1
'tab64.setindent(A38:A39) 8
'tab64.setindent(A40:A42) 16

tab64.setformat(@all) f.3
tab64.setformat(B20:S26) f.5
'tab64.setformat(B36:S42) f.5
tab64.setformat(B30:S30) f.5

show tab64

%tab64filepdf = %outputpath+"tab64_"+"TR20"+%tr+"_"+%alt+".pdf"
tab64.save(t=pdf, landscape) {%tab64filepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open

'********************************
'Table 6.5B NIPA AND OASDI COVERED SELF-EMPLOYED NET INCOME

%wfname="Tab65_nipacovse"+%tr+%alt 'name for the workfile, i.e. nipacovse172
wfcreate(wf={%wfname},page=a) a !datestart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser y cse_seo seo cse_cmb cmb cse_cmb_tot cmb_tot oasdise_ti cse_tot
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute additional variables for table 6.5b
genr acse_seo=cse_seo/seo
genr acse_cmb=cse_cmb/cmb
genr cse=cse_seo+cse_cmb
genr emp_cse=seo+cmb
genr acse=cse/emp_cse
genr acse_cmb_tot=cse_cmb_tot/cmb_tot
genr cse_hi=cse_seo+cse_cmb_tot
genr emp_cse_hi=seo+cmb_tot
genr acse_hi=cse_hi/emp_cse_hi
'genr chg_seo=cse_seo-cse_seo
genr chg_cse_cmb=cse_cmb_tot-cse_cmb
genr chg_cmb=cmb_tot-cmb
genr achg_cse_cmb=chg_cse_cmb/chg_cmb
'genr chg_cse=cse_hi-cse_cmb
'genr chg_emp_cse=emp_cse_hi-emp_cse
'genr achg_cse=chg_cse/chg_emp_cse
genr txtocse=oasdise_ti/(cse_seo+cse_cmb)
genr txtohise=oasdise_ti/cse_tot


%tab65blist= "y cse_seo seo acse_seo cse_cmb cmb acse_cmb cse emp_cse acse cse_seo seo acse_seo cse_cmb_tot cmb_tot acse_cmb_tot cse_hi emp_cse_hi acse_hi  chg_cse_cmb chg_cmb achg_cse_cmb  oasdise_ti txtocse txtohise"  'chg_seo chg_cse chg_emp_cse achg_cse

'assign labels to variables
y.label NIPA Proprietor Income w/IVA and CCA
cse_seo.label Covered SENE ($bil.)
seo.label Employment (mil.)
acse_seo.label Average ($thous.)
cse_cmb.label Covered SENE ($bil.)
cmb.label Employment (mil.)
acse_cmb.label Average ($thous.)
cse.label Covered SENE ($bil.)
emp_cse.label Employment (mil.)
acse.label Average ($thous.)

cse_cmb_tot.label Covered SENE ($bil.)
cmb_tot.label Employment (mil.)
acse_cmb_tot.label Average ($thous.)
cse_hi.label Covered SENE ($bil.)
emp_cse_hi.label Employment (mil.)
acse_hi.label Average ($thous.)

chg_cse_cmb.label Covered SENE ($bil.)
chg_cmb.label Employment (mil.)
achg_cse_cmb.label Average ($thous.)

oasdise_ti.label OASDI Taxable SE earnings
txtocse.label Ratio: OASDI Taxable to CSE
txtohise.label Ratio: OASDI Taxable to CSE_TOT


'constract table
smpl !datestart !dateend
group nipacovse {%tab65blist} 
freeze(tab65b) nipacovse.sheet(t)
smpl @all

'replace mnemonic with labels
!n=3
for %j {%tab65blist}
	setcell(tab65b, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next


'format table
tab65b.table
tab65b.title TABLE 6.5B - NIPA AND OASDI COVERED SELF-EMPLOYED NET INCOME
tab65b(1,1) = "Calendar Year"
tab65b.setwidth(A) 32
tab65b.insertrow(3) 1
tab65b.insertrow(5) 3
setcell(tab65b, 6,1, "OASDI Coverage", "l")
setcell(tab65b, 7,1, "Self-employed Only", "l")
tab65b.setindent(A7) 8
tab65b.setindent(A8:A10) 16
tab65b.insertrow(11) 1
setcell(tab65b, 11,1, "Combination Workers", "l")
tab65b.setindent(A11) 8
tab65b.setindent(A12:A14) 16
tab65b.insertrow(15) 1
setcell(tab65b, 15,1, "Total", "l")
tab65b.setindent(A15) 8
tab65b.setindent(A16:A18) 16

tab65b.insertrow(19) 3
setcell(tab65b, 20,1, "HI Coverage (i.e., OASDI Coverage - IF NO OASDI TAXMAX)", "l")
setcell(tab65b, 21,1, "Self-employed Only", "l")
tab65b.setindent(A21) 8
tab65b.setindent(A22:A24) 16
tab65b.insertrow(25) 1
setcell(tab65b, 25,1, "Combination Workers", "l")
tab65b.setindent(A25) 8
tab65b.setindent(A26:A28) 16
tab65b.insertrow(29) 1
setcell(tab65b, 29,1, "Total", "l")
tab65b.setindent(A29) 8
tab65b.setindent(A30:A32) 16

tab65b.insertrow(33) 5
setcell(tab65b, 34,1, "Change in OASDI Coverage Due to Removing OASDI TAXMAX", "l")
setcell(tab65b, 35,1, "No change for Self-Employed Only", "l")
setcell(tab65b, 36,1, "Total Change = Change for Combination Workers", "l")
setcell(tab65b, 37,1, "Combination Workers", "l")
tab65b.setindent(A37) 8
tab65b.setindent(A38:A40) 16
tab65b.insertrow(41) 1

tab65b.setformat(@all) f.3
tab65b.setformat(B43:S44) f.5

'displey/save/etc table
show tab65b

%tab65bfilepdf = %outputpath+"tab65b_"+"TR20"+%tr+"_"+%alt+".pdf"
tab65b.save(t=pdf, landscape) {%tab65bfilepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open


'********************************
'Table 6.6 TABLE 6.6 - BENEFIT INCREASE AND TAXABLE MAXIMUMS

%wfname="Tab66_beninc"+%tr+%alt 'name for the workfile, i.e. beninc172
wfcreate(wf={%wfname},page=a) a !earlystart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser beninc cpiwq3 taxmax aiw acwa cpiw_u acwadiff
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute whetever variables need computing
genr racwa=acwa/cpiw_u
'Compute percentage change variables 
 for %var cpiwq3 aiw racwa acwa cpiw_u
	%varpc=%var+"pc"
	genr {%varpc}=@pc({%var})
	{%varpc}.label % Change
	{%varpc}.setformat f.3
next

%tab66list= "beninc cpiwq3 cpiwq3pc taxmax aiw aiwpc racwa racwapc acwa acwapc cpiw_u cpiw_upc acwadiff"

'assign labels to variables
beninc.label OASDI Benefit Increase (%)
cpiwq3.label CPIW 3rd Qtr., nsa
taxmax.label OASDI Taxable Maximum ($thous.)
aiw.label OASDI Average Indexing Wage ($)
racwa.label OASDI Real Avg.Wage ($thous., 1982-84 base)
acwa.label OASDI Average Wage ($thous.)
cpiw_u.label CPIW (1982-84=1)
acwadiff.label %ch(OASDI Avg Wage)-%ch(CPIW)

'constract table
smpl !datestart !dateend 
group bentax {%tab66list} 
freeze(tab66) bentax.sheet(t)
smpl @all

'replace mnemonic with labels
!n=3
for %j {%tab66list}
	setcell(tab66, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format table
tab66.table
tab66.title TABLE 6.6 - BENEFIT INCREASE AND TAXABLE MAXIMUMS
tab66(1,1) = "Calendar Year"
tab66.setwidth(A) 38
tab66.insertrow(3) 1
tab66.insertrow(5) 1
tab66.setindent(A6) 8
tab66.setindent(A7) 16
tab66.insertrow(8) 1
tab66.setindent(A10) 8
tab66.setindent(A11) 16
tab66.insertrow(12) 1
tab66.setindent(A14) 8
tab66.insertrow(15) 1
tab66.setindent(A16) 8
tab66.setindent(A17) 16
tab66.setindent(A18) 8
tab66.setindent(A19) 16
tab66.insertrow(20) 2
setcell(tab66, 21,1, "Wage Differential (% pts.)", "l")
tab66.setindent(A22) 8

tab66.setwidth(B:O) 10
tab66.setformat(B6:S6) f.4
tab66.setformat(B13:S13) f.3
tab66.setformat(B16:S16) f.3
tab66.setformat(B18:S18) f.4
tab66.setformat(B22:S22) f.4

'displey/save/etc table
show tab66

%tab66filepdf = %outputpath+"tab66_"+"TR20"+%tr+"_"+%alt+".pdf"
tab66.save(t=pdf, landscape) {%tab66filepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open


'********************************
'Table 6.7 TABLE 6.7 - OASDI COVERED AGGREGATES AND AVERAGES

%wfname="Tab67_covagg"+%tr+%alt 'name for the workfile, i.e. covagg172
wfcreate(wf={%wfname},page=a) a !datestart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser wsca wswa cse seo cmb wesl_o wefc_o wsgmlc tefc_o tesl_o taxmax edmilt
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute variables that need computing
genr emp_cse=seo+cmb 'total SE copvered employment
'totals
genr ce=wsca+cse 'total covered earnings
genr tece=wswa+seo 'total covered employment
'averages
genr acwa=wsca/wswa 'average covered wages
genr acse=cse/emp_cse 'average covered SENE
genr ace=ce/tece 'average TOTAL covered earnings
'average covered wages
genr awesl=wesl_o/tesl_o 'state and local
genr awefc=wefc_o/tefc_o 'fed civ
genr awsmil=wsgmlc/edmilt 'military

%tab67list= "wsca wswa acwa cse emp_cse seo acse ce tece ace awesl awefc awsmil taxmax"

'assign labels to variables
wsca.label Total      ($ Bil.) 
wswa.label Employment (Mil.)
acwa.label Average    ($ Thous.) 
cse.label Total      ($ Bil.) 
emp_cse.label Self-employed (Mil.)
seo.label SE Only (Mil.)
acse.label Average    ($ Thous.) 
ce.label Total      ($ Bil.) 
tece.label Employment (Mil.)
ace.label Average    ($ Thous.) 
awesl.label State and Local 
awefc.label Federal Civilian 
awsmil.label Military
taxmax.label Taxmax ($ Thous.)

'constract table
smpl !datestart !dateend
group covagg {%tab67list} 
freeze(tab67) covagg.sheet(t)
smpl @all

'replace mnemonic with labels
!n=3
for %j {%tab67list}
	setcell(tab67, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format table
tab67.table
tab67.title TABLE 6.7 - OASDI COVERED AGGREGATES AND AVERAGES
tab67(1,1) = "Calendar Year"
tab67.setwidth(A) 24
tab67.insertrow(3) 2
setcell(tab67, 4,1, "Covered Wages", "l")
tab67.setindent(A5:A7) 8

tab67.insertrow(8) 2
setcell(tab67, 9,1, "Covered SENE", "l")
tab67.setindent(A10:A11) 8
tab67.setindent(A12) 16
tab67.setindent(A13) 8

tab67.insertrow(14) 2
setcell(tab67, 15,1, "Covered Earnings", "l")
tab67.setindent(A16:A18) 8

tab67.insertrow(19) 2
setcell(tab67, 20,1, "Average Covered Wages ($ Thous.)", "l")
tab67.setindent(A21:A23) 8

tab67.insertrow(24) 1

tab67.setformat(@all) f.3

'displey/save/etc table
show tab67

%tab67filepdf = %outputpath+"tab67_"+"TR20"+%tr+"_"+%alt+".pdf"
tab67.save(t=pdf, landscape) {%tab67filepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open

'********************************
'Table 6.7A TABLE 6.7A - OASDI AVERAGE COVERED WAGE COMPONENTS, LEVELS

%wfname="Tab67a_avgcov"+%tr+%alt 'name for the workfile, i.e. avgcov172
wfcreate(wf={%wfname},page=a) a !earlystart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser wsca wsd gdp pgdp gdp17 kgdp17 wswa tcea te e edmil ru lc p16o cpiw_u cpiwdec3_u acwa
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
pageselect q
copy(c=x) {%abank_ref}::q\e {%wfname}::a\e_q 'this copies e quarterly employment data (BLS employment comcept) and saves as annual value the MAX quarterly value for the year; the resulting workfile variable name is e_q
wfclose {%abank_ref}

wfopen {%dbankpath}
pageselect a
for %ser n16o 
	copy {%dbank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%dbank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute additional variables
genr emaxmil=e_q+edmil ' max quarter employment plus military
genr emil=e+edmil ' civ employment plus military
genr racw=acwa/cpiw_u 'real average covered wage
'ratios
genr wctowsd=wsca/wsd 'covered wages to NIPA wages
genr wstogdp=wsd/gdp 'wsd to nominal GDP
genr rtp=gdp17/kgdp17 'real to potential GDP
genr watotc=wswa/tcea 'covered wage workers to covered employment (this one includes SE)
genr tctote=tcea/te ' covered employment to total employment
genr tetomaxq=te/emaxmil 'ratio of TE ot max qtr empl.


'make tablist
%tab67alist="wsca wctowsd wsd wstogdp gdp pgdp gdp17 rtp kgdp17 wswa watotc tcea tctote te tetomaxq emaxmil emil ru lc p16o n16o cpiw_u cpiwdec3_u acwa racw"

'assign labels to variables; these MUST be assigned to the 'description' files for them to show up correctly in the tables
wsca.label(d) OASDI Covered Wages
wctowsd.label(d) OASDI Covered Wage Ratio
wsd.label(d) NIPA Wages Disb. 
wstogdp.label(d) Ratio of NIPA Wages to Nominal GDP
gdp.label(d) Nominal GDP 
pgdp.label(d) GDP Chain Wt. Price Index
gdp17.label(d) Actual Real GDP (2017 dollars)
rtp.label(d) Ratio of Real to Potential GDP 
kgdp17.label(d) Potential Real GDP (2017 dollars)

wswa.label OASDI Covered Wage Emp. 
watotc.label Ratio: OASDI Cov. Wage Emp. to Cov. Emp.
tcea.label OASDI Covered Emp. 
tctote.label Ratio of Covered Emp. to Total Emp.
te.label Total Employed 
tetomaxq.label Ratio of Total Emp. to Max. Qtr. Emp.
emaxmil.label Max. Qtr. Emp. + Military
emil.label Civ. Emp. + Military
ru.label Civ. Unemployment Rate (%)
lc.label Civ. Labor Force
p16o.label Civ. LF Part. Rate 
n16o.label Civ. Noninst. Pop.

cpiw_u.label Level (CPIW)
cpiwdec3_u.label Rounded to 3rd decimal

acwa.label Nominal (ACW)
racw.label Real (ACW/CPIW_U)

'For Table 6.7B -- compute percent change and %pt changes, and assign labels in the same loop

'Compute percentage change 
for %var wsca wsd gdp pgdp gdp17 kgdp17 wswa tcea te emaxmil emil lc n16o cpiw_u cpiwdec3_u acwa racw
	%varpc=%var+"pc"
	genr {%varpc}=@pc({%var})
	%varpclabel={%var}.@description+", % chg." 'new label
	{%varpc}.label {%varpclabel} 'adds words '% change' to the earlier desciption of the var-ble
next

'Compute  percentage point difference
for %var wctowsd wstogdp rtp watotc tctote tetomaxq ru p16o
	%vardf=%var+"df"
	genr {%vardf}=@d({%var})
	%vardflabel={%var}.@description+", chg." 'new label
	{%vardf}.label {%vardflabel} 
next

'constract table
smpl !datestart !dateend 
group avgcov {%tab67alist} 
freeze(tab67a) avgcov.sheet(t)
smpl @all

'replace mnemonic with labels for table 6.7A
!n=3
for %j {%tab67alist}
	setcell(tab67a, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next


'Table 6.7B -- TABLE 6.7B - OASDI AVERAGE COVERED WAGE COMPONENTS, PERCENT CHANGE
genr rwdiff=acwapc-cpiwdec3_upc
rwdiff.label Real Wage Differential %chg(ACW) - %chg(CPIW3)
%tab67blist="wscapc wctowsddf wsdpc wstogdpdf gdppc pgdppc gdp17pc rtpdf kgdp17pc wswapc watotcdf tceapc tctotedf tepc tetomaxqdf emaxmilpc emilpc rudf lcpc p16odf n16opc cpiw_upc cpiwdec3_upc acwapc racwpc rwdiff"

smpl !datestart !dateend
group avgcovpc {%tab67blist} 
freeze(tab67b) avgcovpc.sheet(t)
smpl @all

'replace mnemonic with labels for table 6.7B
!n=3
for %j {%tab67blist}
	setcell(tab67b, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format both tables
tab67a.title TABLE 6.7A - OASDI AVERAGE COVERED WAGE COMPONENTS, LEVELS
tab67b.title TABLE 6.7B - OASDI AVERAGE COVERED WAGE COMPONENTS, PERCENT CHANGE
tab67a.setwidth(A) 34
tab67b.setwidth(A) 42

for %tb tab67a tab67b
{%tb}(1,1) = "Calendar Year"
{%tb}.insertrow(3) 1
{%tb}.insertrow(5) 1
{%tb}.setindent(A6:A7) 8
{%tb}.insertrow(8) 1
{%tb}.setindent(A9:A10) 16
{%tb}.insertrow(11) 1
{%tb}.setindent(A12:A13) 24
{%tb}.insertrow(14) 1
{%tb}.setindent(A15:A16) 30
{%tb}.insertrow(17) 1

{%tb}.insertrow(19) 1
{%tb}.setindent(A20:A21) 6
{%tb}.insertrow(22) 1
{%tb}.setindent(A23:A24) 10
{%tb}.insertrow(25) 1
{%tb}.setindent(A26:A27) 18
{%tb}.insertrow(28) 1
{%tb}.setindent(A29) 22
{%tb}.insertrow(30) 1
{%tb}.setindent(A31:A32) 26
{%tb}.insertrow(33) 1
{%tb}.setindent(A34:A35) 30

{%tb}.insertrow(36) 3
setcell({%tb}, 37,1, "CPI, Urban Wage Earners and Clerical Workers, Not Seas. Adj. (Index 1982-1984 = 1.0)", "l")
{%tb}.setindent(A39:A40) 8

{%tb}.insertrow(41) 3
setcell({%tb}, 42,1, "OASDI Average Covered Wage", "l")
{%tb}.setindent(A44:A45) 8
next

setcell(tab67a, 5,1, "($Bil.)", "l")
setcell(tab67a, 19,1, "(Mil.)", "l")
setcell(tab67a, 43,1, "($Thous.)", "l")
setcell(tab67b, 31,1, "Civ. Unemployment Rate, % pt. diff.", "l") 

tab67b.setindent(A46) 8
tab67a.setformat(@all) f.4
tab67b.setformat(@all) f.4
tab67b.setwidth(B:O) 10

'displey/save/etc table
show tab67a
show tab67b

%tab67afilepdf = %outputpath+"tab67a_"+"TR20"+%tr+"_"+%alt+".pdf"
%tab67bfilepdf = %outputpath+"tab67b_"+"TR20"+%tr+"_"+%alt+".pdf"
tab67a.save(t=pdf, landscape) {%tab67afilepdf}
tab67b.save(t=pdf, landscape) {%tab67bfilepdf}

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open

'********************************
'TABLE 6.8 - LINKAGES, PERCENT CHANGE

%wfname="Tab68_linkages"+%tr+%alt 'name for the workfile, i.e. linkages172
wfcreate(wf={%wfname},page=a) a !earlystart !dateend
smpl @all

'Read in data 
wfopen {%abankpath}
pageselect a
for %ser cpiw_u pgdp kgdp17 ee_fe prod_fe ahrs_fe gdp17 ee e edmil prod ahrs wsd y gdp wss acea acwa ase wsca cse_tot wswa seo cmb
	copy {%abank_ref}::a\{%ser} {%wfname}::a\*
next
wfclose {%abank_ref}

wfselect {%wfname}
pageselect a
smpl @all

'compute variables that need computing
genr avgearn=(wsd+y)/((e+edmil)*cpiw_u) 'average real earnings, level
genr covearn_all=(wsca+cse_tot)/(wswa+seo) 'oasdi avg earnings all workers
genr covearn_wage=wsca/wswa 'oasdi avg earnings wage workers
genr covearn_se=cse_tot/(seo+cmb) 'oasdi avg eraning self-employed
genr rcovearn_all= covearn_all/cpiw_u
genr rcovearn_wage= covearn_wage/cpiw_u
genr rcovearn_se= covearn_se/cpiw_u

genr earntogdp=(y+wsd)/gdp ' earnings to GDP, level
genr comptogdp=(y+wss)/gdp ' comp. to gdp, level
genr earntocomp=(y+wsd)/(y+wss) ' earnings to comp., level
genr covearnr=(wsca+cse_tot)/(y+wsd) 'covered earnings ratio
genr covempr=(wswa+seo)/(e+edmil) 'covered empl. ratio

'genr racea=acea/cpiw_u 'real avg covere dearnings all workers
'genr racwa=acwa/cpiw_u ' real avg covered wages
'genr rase=ase/cpiw_u 'real avg covered SE earnings

'compute percent changes
for %var cpiw_u pgdp kgdp17 ee_fe prod_fe ahrs_fe gdp17 ee prod ahrs avgearn earntogdp comptogdp earntocomp covearnr covempr covearn_all covearn_wage covearn_se rcovearn_all rcovearn_wage rcovearn_se
	%varpc=%var+"pc"
	genr {%varpc}=@pc({%var})
next
'a few more vars
genr pdiff=pgdppc-cpiw_upc 'price differential
'avg real earnings (minus cpi-w)
genr rdcovearn_all=covearn_allpc-cpiw_upc
genr rdcovearn_wage=covearn_wagepc-cpiw_upc
genr rdcovearn_se=covearn_sepc-cpiw_upc

'genr rdacea=aceapc-cpiw_upc
'genr rdacwa=acwapc-cpiw_upc
'genr rdase=asepc-cpiw_upc
genr earndiff=rcovearn_allpc-avgearnpc ' earnings growth differential = OASDI Avg. Real Earnings Less Avg. Real US Earnings Growth Rate    

%tab68list="cpiw_upc pgdppc pdiff kgdp17pc ee_fepc prod_fepc ahrs_fepc gdp17pc eepc prodpc ahrspc avgearnpc prodpc ahrspc pdiff earntogdppc comptogdppc earntocomppc rcovearn_allpc rcovearn_wagepc rcovearn_sepc rdcovearn_all rdcovearn_wage rdcovearn_se earndiff covearnrpc covemprpc"

'assign labels to variables
cpiw_upc.label CPI-Wage and Cler. Wkrs. 
pgdppc.label GDP Ch. Wt. Price Index 
pdiff.label Price Differential 
kgdp17pc.label Potential GDP 
ee_fepc.label Full-Empl. Empl.
prod_fepc.label Productivity
ahrs_fepc.label Avg. Hours
gdp17pc.label Real GDP
eepc.label Employed
prodpc.label Productivity
ahrspc.label Avg. Hours
avgearnpc.label Avg. Real US Earnings
earntogdppc.label Earnings to GDP
comptogdppc.label Tot. Comp. to GDP 
earntocomppc.label Earnings to Tot. Comp.
rcovearn_allpc.label All Workers
rcovearn_wagepc.label Wage Workers
rcovearn_sepc.label Self-Employed
rdcovearn_all.label All Workers
rdcovearn_wage.label Wage Workers
rdcovearn_se.label Self-Employed
earndiff.label Avg. Real Earnings Growth Differential ' OASDI Avg. Real Earnings Growth Less Avg. Real US Earnings Growth Rate
covearnrpc.label Due to % Chg in Cov. Earn. Ratio
covemprpc.label Due to % Chg in Cov. Emp. Ratio

'constract table
smpl !datestart !dateend 
group links {%tab68list} 
freeze(tab68) links.sheet(t)
smpl @all

'replace mnemonic with labels for table 6.7B
!n=3
for %j {%tab68list}
	setcell(tab68, !n, 1, {%j}.@description, "l") 
 	!n=!n+1
next

'format table
tab68.table
tab68.title TABLE 6.8 - LINKAGES, PERCENT CHANGE
tab68(1,1) = "Calendar Year"
tab68.setwidth(A) 34
tab68.insertrow(3) 2
setcell(tab68, 4,1, "Inflation", "l")
tab68.setindent(A5:A7) 8
tab68.insertrow(8) 1
tab68.setindent(A10:A12) 8
tab68.insertrow(13) 1
tab68.setindent(A15:A17) 8
tab68.insertrow(18) 1
tab68.insertrow(20) 1
tab68.setindent(A21:A26) 8
tab68.insertrow(27) 3
setcell(tab68, 28,1, "OASDI Average Real Earnings", "l")
setcell(tab68, 29,1, "Divided by CPI", "l")
tab68.setindent(A29) 8
tab68.setindent(A30:A32) 16
tab68.insertrow(33) 1
setcell(tab68, 33,1, "Minus CPI Growth Rate", "l")
tab68.setindent(A33) 8
tab68.setindent(A34:A36) 16
tab68.insertrow(37) 1
tab68.insertrow(39) 1
setcell(tab68, 39,1, "(OASDI Avg. Real Earnings Growth Less Avg. Real US Earnings Growth Rate)", "l")
tab68.setindent(A40:A41) 8

tab68.setformat(@all) f.4

show tab68

%tab68filepdf = %outputpath+"tab68_"+"TR20"+%tr+"_"+%alt+".pdf"
tab68.save(t=pdf, landscape) {%tab68filepdf}
tab68.save(t=rtf, s=75) tab68

' Rename the PDF files into lowercase
%files = @wdir(%outputpath)
for %f {%files}
   if (@left(%f,3) = "TAB") then
      %current = %outputpath + %f
      %new = @lower(%f)
      shell rename {%current} {%new}
   endif
next

%wfpath=%outputpath+%wfname
wfsave %wfpath ' saves the workfile
close {%wfname} 'close the workfile; comment this out if need to keep the workfile open


