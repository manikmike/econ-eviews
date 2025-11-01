'This program pulls data from various Aremos databanks into eViews and performs checks on TE employment and AWS wages.
' It saves the resulting tables in the workfile AND in PDF.
' This program reads in the following databanks:
' a-bank
' d-bank
' otl bank
' mef bank
' op bank

' For EACH run, the user should update parameters listed in the '**** UPDATE values here**** section

'Polina Vlasenko

'the program creates a lot of PDF tables -- check to verify if we need all of them still.   12-8-2017 Polina Vlasenko


'	11-20-2018 Polina Vlasenko
'	Changed the UPDATE section to simplify entering the databank locations and allow for use of databanks from budget runs (not only TR).	

'*** Updated to TR19 file locations -- PV 12-10-2018
'*** Updated to TR21 file locations -- SHS 08-24-2021
'*** Updated to TR22 file locations -- PV 05-27-2022
' !!! For subsequent cheanges/updates, see the log in econ-eviews Git repo. !!!


'*****UPDATE values here for every program run****
!datestart=1981 'start and end dates for the period to be checked
!dateend=2100
!tol=0.001 ' tolerance limit for performing the checks; check values should be zero, but in practice they are not not because of rounding etc; set here the max deviation from zero we would tolarate 

'	These string variables are used to create names for output tables and files:
%tr="2025" 'TR year; if doing checks on a budget run, put "OMBnn" (like OMB19) here. 
%alt="2" ' "1', "2" or "3" for a TR run; if doing checks on a budget run, put a space (like this " ").

'	Provide locations for databanks required for the check:
'	a-bank
%abankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\atr252.wf1"		' full path
%abank = "atr252"																																' filename only
'	d-bank
%dbankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\dtr252.wf1"
%dbank = "dtr252"
'	OTL-bank
%otlbankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\otl_tr252.wf1"
%otlbank = "otl_tr252"
'	MEF bank
%mefbankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\dat\mef.wf1"
%mefbank = "mef"
'	op-bank
%opbankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\dat\op1252o.wf1"
%opbank = "op1252o"

' Output of this program -- path to the location where the resulting checks are to be stored.
' NOTE: 19 PDF files with tables and one EViews workfile will be put into this location! If there are any files with identical bnamed in this location, they will be OVERWRITTEN with NO WARNING!!!
%outputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\TE_checks\" 	' don't forget the "\" at the end!

' Do you want to save the output file?
%sav = "Y" 	' enter "Y" or "N" (case sensitive)

' Do you want to save the tables in PDF?
%sav_pdf = "Y" 	' enter "Y" or "N" (case sensitive)


'*****END of the update section*****

%thisfile = "empl_ws_checks_TR"+%tr+%alt 	' name of the current workfile created by this program
wfcreate(wf={%thisfile}, page=a) a !datestart !dateend 'create workfile with annual data between the start date and the end date

'lists of series to download from databanks

%list1 = "NO_ASF1 NO_NASF1 NO_ASF2 NO_NASF2 NO_ASJ1 NO_NASJ1 NO_ASJ2 NO_NASJ2 NO_AWJ NO_NAWJ NO_AWJF NO_NAWJF NO_AWH NO_NAWH NO_AWT NO_NAWT NO_AWTFA NO_AWTFN NO_NAWTF no_a no_na no_no teo_asf1 teo_asf2 teo_asj1 teo_asj2 teo_awj teo_awjf teo_awh teo_awt teo_awtfa teo_awtfn teo_nasf1 teo_nasf2 teo_nasj1 teo_nasj2 teo_nawj teo_nawjf teo_nawh teo_nawt teo_nawtf teo_no_16o teo_nol_m_16o teo_nol_s_16o teo_nol_u_16o teo_noi_m_16o teo_noi_s_16o teo_noi_u_16o teo_mef_16o teo_mefc_16o teo_esf_16o teo_und_16o teo teo_a teo_na teo_no teo_mef teo_mefc teo_esf teo_und"  'list of employment series to be pulled from otl_tr172bnk

%list2 = "nil nild"  'list of employment series to be pulled from op1172o.bnk

%list3 = "te TCEAHI TCEA TEFC_N_N TESL_N_N_HI CE_M TE_SFO_LRP TEPH_N TEP_N_N_S TESL_N_N_NHI_S TESL_N_N_NHI_E TESL_N_N_NHI_NS SEO_HI SEO WSW_HIO_OTH tefc_n_n_se tesl_n_n_hi_se wsw_hio_oth_se te_mn te_ph_m heso_m he_wol_m he_wor_m he_wosl_m he_wosr_m ceso_m tel_so" 'list of employment series to be pulled from atr172.bnk

%list4 = "EPRRB TEPO_N te_sloe_m te_slos_m te_ps_m he_wof_m he_wosf_m" 'list of employment series to be pulled from dtr172.bnk

%list5 = "te_sloo_m te_rro_m" ' list of employment series to be pulled from mef.bnk

%listw1 = "ACWAHI ACWA AWS_MEF AIW WSD WSCAHI WSCA WS_MEF  WSWAHI WSWA WSW_MEF WE_SF WESL_N_NHI WSPRRB WESL_N_NHI_S WESL_N_NHI_E WESL_N_NHI_NS WSPH WSPH_O wefc_n wesl_n_hi wsca_hio_oth WSGFM WSGMLC TESL_N_S" 'list of Wage series to be pulled from atr172.bnk

%listw2 = "WS_EO_UND WS_EO_ESF WS_EO_MEF WS_EO_MEFC" 'list of wage series to be pulled from otl_tr172.bnk 

'load variables from corresponding databanks

wfopen %otlbankpath
pageselect a
for %ser {%list1}
	copy {%otlbank}::a\{%ser} {%thisfile}::a\*
next
for %ser {%listw2}
	copy {%otlbank}::a\{%ser} {%thisfile}::a\*
next
wfclose {%otlbank}


wfopen %opbankpath
pageselect a
for %ser {%list2}
	copy {%opbank}::a\{%ser} {%thisfile}::a\*
next
wfclose {%opbank}


wfopen %abankpath
pageselect a
for %ser {%list3}
	copy {%abank}::a\{%ser} {%thisfile}::a\*
next
for %ser {%listw1}
	copy {%abank}::a\{%ser} {%thisfile}::a\*
next
for %ser prod ahrs pgdp
	copy {%abank}::a\{%ser} {%thisfile}::a\*
next
wfclose {%abank}


wfopen %dbankpath
pageselect a
for %ser {%list4}
	copy {%dbank}::a\{%ser} {%thisfile}::a\*
next
wfclose {%dbank}


wfopen %mefbankpath
pageselect a
for %ser {%list5}
	copy {%mefbank}::a\{%ser} {%thisfile}::a\*
next
wfclose {%mefbank}

' *** Done loading data ***

wfselect {%thisfile}
pageselect a
smpl @all

'these series are later used in WS checks
series ws_ps_m=(wesl_n_nhi_s/tesl_n_s)*te_ps_m
series ws_ph_m = (0.5*1.8/44.32167)*aiw(-1)/1000*prod/prod(-1)*ahrs/ahrs(-1)*pgdp/pgdp(-1)*te_ph_m


'the following creates the columns for the various tables with employment and wage data
'each series name indicates where it should go in the tables
'Example: te_col_h means "column H of the TE table"

'********* TE table
smpl 1988 !dateend 'table starts in 1988
series te_col_b = te
series te_col_c = teo_und
series te_col_d = te_col_b-te_col_c

series te_col_e = te_mn

series te_col_g = te_ph_m
series te_col_h = te_rro_m
series te_col_i = te_ps_m
series te_col_f = te_col_g+te_col_h+te_col_i

series te_col_k = te_slos_m
series te_col_l = te_sloe_m
series te_col_m = te_sloo_m
series te_col_j = te_col_k+te_col_l+te_col_m

series te_col_o = teo_asf1
series te_col_p= teo_asj1
series te_col_q = teo_awj
series te_col_r = teo_awh
series te_col_n = te_col_o+te_col_p+te_col_q+te_col_r

series te_col_s = te_col_d-te_col_e
series te_col_t= heso_m
series te_col_u = te_col_s-te_col_t

series te_col_w = he_wof_m
series te_col_x= he_wol_m
series te_col_y = he_wor_m
series te_col_v = te_col_w+te_col_x+te_col_y

series te_col_z = he_wosl_m+he_wosf_m+he_wosr_m

'cannot name these series te_col_aa because then EViews will put them after column A; to keep the order of column where I need it, have to name these creatively
series te_col_zaa= te_col_s-(te_col_v-te_col_z)
series te_col_zab= ceso_m
series te_col_zac= te_col_zaa-te_col_zab

series te_col_zae= tel_so
series te_col_zaf= teo_esf
series te_col_zad= te_col_zae+te_col_zaf

series te_col_zag= te_col_zac-te_col_zad
series te_col_zah= teo_mefc
series te_col_zai= te_col_zag-te_col_zah
series te_col_zaj= te_col_e+te_col_u-te_col_zad

'create the table
group te_table te_col* 
freeze(te_summary) te_table.sheet 

'********* TER table -- the TE table with ratios (TE_R in Excel)
series ter_col_b
series ter_col_c
'the rest can be done as a loop, because the formula are all the same
for %col d e f g h i j k l m n o p q r s t u v w x y z zaa zab zac zad zae zaf zag zah zai zaj
series ter_col_{%col}=te_col_{%col}/te_col_d
next

'create the table
group ter_table ter_col* 
freeze(ter) ter_table.sheet 


'TE check -- compute the "differences" in the check table; they should be zero (except for the rounding/precision errors)
series check_tceahi=tceahi-te_col_s
series check_wswahi=wswahi-te_col_u
series check_tcea=tcea-te_col_zaa
series check_seo=seo-te_col_zab
series check_wswa=wswa-te_col_zac
series check_wsw_mef=wsw_mef-te_col_zaj

'create a table of check series
group te_check check_tceahi check_wswahi check_tcea check_seo check_wswa check_wsw_mef 
freeze(te_checktable) te_check.sheet 
te_checktable.setwidth(@all) 17

'show table of descriptive stats for the check (easy to see the max and min values to see if there are any large deviations from zero)
freeze(te_checkstats) te_check.stats 
te_checkstats.setwidth(@all) 17 
te_checkstats.title TE checks
te_checkstats.deleterow(18) 1 'streamline the table by deleting info we don't need
te_checkstats.deleterow(10) 7
'te_checkstats.table 'displays the stats table on screen


'********* TEO table
smpl !datestart !dateend
series teo_col_c = teo_asf1
series teo_col_d = teo_asf2
series teo_col_e = teo_asj1
series teo_col_f = teo_asj2
series teo_col_g = teo_awj
series teo_col_h = teo_awh
series teo_col_i = teo_awt
series teo_col_j = teo_awjf
series teo_col_k = teo_awtfa
series teo_col_b = teo_col_c+teo_col_d+teo_col_e+teo_col_f+teo_col_g+teo_col_h+teo_col_i+teo_col_j+teo_col_k

series teo_col_n = teo_nasf1
series teo_col_o = teo_nasf2
series teo_col_p= teo_nasj1
series teo_col_q = teo_nasj2
series teo_col_r = teo_nawj
series teo_col_s = teo_nawh
series teo_col_t= teo_nawt
series teo_col_u = teo_nawjf
series teo_col_v 'creates the series teo_col_v filled with NAs; 
series teo_col_m = teo_col_n+teo_col_o+teo_col_p+teo_col_q+teo_col_r+teo_col_s+teo_col_t+teo_col_u '+teo_col_v ; we should also add col v, but I am commneting it out otherwise the entire sum will be NAs 

series teo_col_x= teo_awtfn
series teo_col_y = teo_nawtf
series teo_col_w = teo_col_x+teo_col_y

'cannot name these series te_col_aa because they EViews will put them after column A; to keep the order of column where I need it, naming these creatively
series teo_col_zaa= teo_nol_m_16o
series teo_col_zab= teo_nol_s_16o
series teo_col_zac= teo_nol_u_16o
series teo_col_z = teo_col_zaa+teo_col_zab+teo_col_zac

series teo_col_zae= teo_noi_m_16o
series teo_col_zaf= teo_noi_s_16o
series teo_col_zag= teo_noi_u_16o
series teo_col_zad= teo_col_zae+teo_col_zaf+teo_col_zag

series teo_col_l = teo_col_m+teo_col_w+teo_col_z+teo_col_zad

series teo_col_zah= teo_col_b+teo_col_m+teo_col_zaa+teo_col_zae
series teo_col_zai= teo_col_d+teo_col_f+teo_col_i+teo_col_k+teo_col_j+teo_col_n+teo_col_o+teo_col_p+teo_col_q+teo_col_r+teo_col_s+teo_col_t+teo_col_u+teo_col_zaa+teo_col_zae '+teo_col_v ; we should also add col v, but I am commenting it out otherwise the entire sum will be NAs
series teo_col_zaj= teo_col_zab+teo_col_zaf
series teo_col_zak= teo_col_x+teo_col_y+teo_col_zac+teo_col_zag
series teo_col_zal= teo_col_zah+teo_col_zaj+teo_col_zak

' create the table
group teo_table teo_col* 
freeze(teo_summary) teo_table.sheet  
teo_summary.setwidth(@all) 17 

'********* TEO_R table -- the TEO table with ratios to total in col AL(TEO_R in Excel)
'can be done as a loop, because the formula are all the same
for %col b c d e f g h i j k l m n o p q r s t u v w x y z zaa zab zac zad zae zaf zag zah zai zaj zak zal
series teo_r_col_{%col}=teo_col_{%col}/teo_col_zal
next

' create the table
group teo_r_table teo_r_col*  
freeze(teo_r) teo_r_table.sheet 

'TEO check -- compute the "differences" in the check table; these differences should be zero (except for the rounding/precision errors)
series check_teo_a=teo_a-teo_col_b
series check_teo_na=teo_na-teo_col_m
series check_teo_no=teo_no-(teo_col_z+teo_col_zad)
series check_teo=teo-teo_col_zal
series check_teo_mef=teo_mef-teo_col_zah
series check_teo_mefc=teo_mefc-teo_col_zai
series check_teo_esf=teo_esf-teo_col_zaj
series check_teo_und=teo_und-teo_col_zak

' create the table
group teo_check check_teo*
freeze(teo_checktable) teo_check.sheet 
teo_checktable.setwidth(@all) 17 

' create a table of descriptive stats for the check (easy to see the max and min values to see if there are any large deviations from zero)
freeze(teo_checkstats) teo_check.stats 
teo_checkstats.setwidth(@all) 15 
teo_checkstats.setwidth(4) 17
teo_checkstats.setwidth(5) 17
teo_checkstats.setwidth(6) 17
teo_checkstats.setwidth(2) 14
teo_checkstats.setwidth(9) 17
teo_checkstats.title TEO checks
teo_checkstats.deleterow(18) 1 'streamline the table by deleting info we don't need
teo_checkstats.deleterow(10) 7
'teo_checkstats.table 'displays the stats table


'********* NO table
smpl !datestart !dateend

series no_col_c = no_asf1
series no_col_d = no_asf2
series no_col_e = no_asj1
series no_col_f = no_asj2
series no_col_g = no_awj
series no_col_h = no_awh
series no_col_i = no_awt
series no_col_j = no_awjf
series no_col_k = no_awtfa
series no_col_b = no_col_c+no_col_d+no_col_e+no_col_f+no_col_g+no_col_h+no_col_i+no_col_j+no_col_k

series no_col_n = no_nasf1
series no_col_o = no_nasf2
series no_col_p = no_nasj1
series no_col_q = no_nasj2
series no_col_r = no_nawj
series no_col_s = no_nawh
series no_col_t = no_nawt
series no_col_u = no_nawjf
series no_col_v 'this creates the series no_col_v filled with NAs; if we want to use values, uncomment the previous line and comment out this one
series no_col_m = no_col_n+no_col_o+no_col_p+no_col_q+no_col_r+no_col_s+no_col_t+no_col_u '+no_col_v ; we shoudl also add col v, but I am commneting it out otherwise the entire sum will be NAs 

series no_col_y = NO_AWTFN
series no_col_y2 = NO_NAWTF'columns are named weirdy in the Excel sheet (b/c it skips column L), so this strange notation is necessary
series no_col_x = no_col_y+no_col_y2

series no_col_z = no_no
series no_col_w = no_col_x+no_col_z

series no_col_zaa= no_col_b+no_col_m+no_col_w

'create a table
group no_table no_col*  
freeze(no_summary) no_table.sheet  

'NO check -- compute the "differences" in the check table; these differences should be zero (except for the rounding/precision errors)
series check_no_a=no_a-no_col_b
series check_no_na=no_na-no_col_m
series check_nil_nild=no_col_zaa-(nil-nild)

'create table of  the 3 checks (differences) for NO
group no_check check_n* 
freeze(no_checktable) no_check.sheet 
no_checktable.setwidth(@all) 17 

'create a table of descriptive stats for the NO checks (easy to see the max and min values to see if there are any large deviations from zero)
freeze(no_checkstats) no_check.stats 
no_checkstats.setwidth(@all) 17 
no_checkstats.title NO checks
no_checkstats.deleterow(18) 1 'streamline the table by deleting info we don't need
no_checkstats.deleterow(10) 7
'no_checkstats.table 'displays the stats table


'********* WS table
smpl 1990 !dateend 

series ws_col_c = WS_EO_UND

series ws_col_g = WS_PH_M
series ws_col_h = WSPRRB
series ws_col_i = WS_PS_M
series ws_col_f = ws_col_g+ws_col_h+ws_col_i

series ws_col_j = WESL_N_NHI
series ws_col_k = WESL_N_NHI_S
series ws_col_l = WESL_N_NHI_E
series ws_col_m = WESL_N_NHI_NS
series ws_col_n = WS_EO_MEF-WS_EO_MEFC

series ws_col_e = ws_col_f+ws_col_j+ws_col_n

series ws_col_o 'these columns are intentionally left empty in the WS table
series ws_col_p
series ws_col_q
series ws_col_r
series ws_col_s
series ws_col_t

series ws_col_w = wefc_n
series ws_col_x = wesl_n_hi
series ws_col_y = wsca_hio_oth
series ws_col_v = ws_col_w+ws_col_x+ws_col_y

series ws_col_z
'cannot name these series te_col_aa because then EViews will put them after column A; to keep the order of column where I need it, have to name these creatively
series ws_col_zaa
series ws_col_zab
series ws_col_zac= WSCA

series ws_col_u = ws_col_v+ws_col_zac
series ws_col_d = ws_col_e+ws_col_u
series ws_col_b = ws_col_c+ws_col_d

series ws_col_zad = WE_SF
series ws_col_zaf = WS_EO_ESF
series ws_col_zae= ws_col_zad -ws_col_zaf

series ws_col_zag= ws_col_zac-ws_col_zad
series ws_col_zah= WS_EO_MEFC
series ws_col_zai= ws_col_zag-ws_col_zah
series ws_col_zaj= ws_col_e+ws_col_u-ws_col_zad

'create the table
group ws_table ws_col* 
freeze(ws_levels) ws_table.sheet  


'********* AWS table -- compute the average wages using data from WS tabke and TE table
smpl 1990 !dateend 

series aws_col_b = ws_col_b/(te_col_b-te_col_t)
series aws_col_c = ws_col_c/te_col_c
series aws_col_d = ws_col_d/(te_col_d-te_col_t)

for %col e f g h i j k l m n o p q r s t u v w x y z zaa zab zac zad zae zaf zag zah zai zaj
series aws_col_{%col} = ws_col_{%col}/@recode(te_col_{%col}=0, na, te_col_{%col}) 'the @recode command is needed for the operation to return NA when the TE value is zero (which happens for several series in the table)
next

'create the table
group aws_table aws_col* 
freeze(aws_levels) aws_table.sheet  


'WS check -- compute the "differences" in the check table; these differences should be zero (except for the rounding/precision errors)
series check_wscahi=wscahi-ws_col_u
series check_ws_mef=ws_mef-ws_col_zaj
series check_wsd=wsd-ws_col_b
series military=wsgfm-wsgmlc
series residual=check_wsd-military
series residual_to_wsd=residual/wsd

'create the table for the check
group ws_check check_wscahi check_ws_mef check_wsd 
freeze(ws_checktable) ws_check.sheet 
ws_checktable.setwidth(@all) 17 

'table of descriptive stats for the checks (easy to see the max and min values to see if there are any large deviations from zero)
freeze(ws_checkstats) ws_check.stats 
ws_checkstats.setwidth(@all) 17
ws_checkstats.title WS checks
ws_checkstats.deleterow(18) 1 'streamline the table by deleting info we don't need
ws_checkstats.deleterow(10) 7

'now create another table that shows wsd differences and its possible components
group wsd_diff wsd check_wsd military residual residual_to_wsd 'ws_diff is the group that reporduces "check 2" table in Excel file, i.e. it contains wsd, check_wsd, military, residual, and ratio of residual to wsd
freeze(wsd_table) wsd_diff.sheet
wsd_table.title Difference between WSD and total built-up wages
wsd_table.setwidth(6) 22 

'table of descriptive stats for WSD_diff
freeze(wsd_stats) wsd_diff.stats 
wsd_stats.title WSD and components
wsd_stats.setwidth(6) 22 
wsd_stats.deleterow(18) 1 'streamline the table by deleting info we don't need
wsd_stats.deleterow(10) 7

'format TE table, TER table, WS_Levels table, and AWS_Levels table (they all have identical or nearly identical column headings)
'do this as a loop, looping through the table names.
for %tname te_summary ter ws_levels aws_levels
{%tname}.insertrow(1) 7 'insert enough rows to create all necessary column headings

setcell({%tname},3,1,"Calendar","c")
setcell({%tname},4,1,"Year","c")
setcell({%tname},1,2,"Total Employed At-any-time","c")
{%tname}.setmerge(b1:z1)
setcell({%tname},2,2,"Total","c")
setcell({%tname},2,3,"Not ","c") 'EViews does not wrap text within a cell automatically, so this is an ugly way to do it by hand
setcell({%tname},3,3,"Reported","c")
setcell({%tname},4,3,"(OIP in","c")
setcell({%tname},5,3,"Undergr.","c")
setcell({%tname},6,3,"Economy)","c")
setcell({%tname},2,4,"Reported","c")
{%tname}.setmerge(d2:ai2)
setcell({%tname},3,4,"Total","c")
setcell({%tname},3,5,"No HI Covered Earnings","c")
{%tname}.setmerge(e3:r3)
setcell({%tname},4,5,"Total","c")

setcell({%tname},4,6,"Private","c")
{%tname}.setmerge(f4:i4)
setcell({%tname},5,6,"Total","c")
setcell({%tname},5,7,"HH","c")
setcell({%tname},5,8,"RR","c")
setcell({%tname},5,9,"Students","c")

setcell({%tname},4,10,"State & Local","c")
{%tname}.setmerge(j4:m4)
setcell({%tname},5,10,"Total","c")
setcell({%tname},5,11,"Students","c")
setcell({%tname},5,12,"Elec.","c")
setcell({%tname},6,12,"Wrkr.","c")
setcell({%tname},5,13,"Other","c")

setcell({%tname},4,14,"Other Immigrants","c")
{%tname}.setmerge(n4:r4)
setcell({%tname},5,14,"Total","c")
setcell({%tname},5,15,"Students","c")
setcell({%tname},6,15,"F1-visa","c")
setcell({%tname},5,16,"Students","c")
setcell({%tname},6,16,"J1-visa","c")
setcell({%tname},5,17,"Workers","c")
setcell({%tname},6,17,"J1-visa","c")
setcell({%tname},5,18,"Workers","c")
setcell({%tname},6,18,"H-visa","c")

setcell({%tname},3,19,"HI Covered (includes ESF)","c")
{%tname}.setmerge(s3:z3)
setcell({%tname},4,19,"Total","c")
setcell({%tname},4,20,"Self-Emp.","c")
setcell({%tname},5,20,"Only","c")
setcell({%tname},4,21,"Wage Workers (includes ESF)","c")
{%tname}.setmerge(u4:z4)

setcell({%tname},5,21,"Total","c")
setcell({%tname},5,22,"With no OASDI WS (i.e., HI only)","c")
{%tname}.setmerge(v5:z5)

setcell({%tname},3,27,"OASDI Covered","c")
{%tname}.setmerge(aa3:ai3)

setcell({%tname},6,22,"Total","c")
setcell({%tname},6,23,"Fed. Civ.","c")
setcell({%tname},6,24,"S&L","c")
setcell({%tname},6,25,"Other","c")
setcell({%tname},6,26,"Tot. w/SE","c")

setcell({%tname},4,27,"Total","c")
setcell({%tname},4,28,"Self-Emp.","c")
setcell({%tname},5,28,"Only","c")
setcell({%tname},4,29,"Wage Workers","c")
{%tname}.setmerge(ac4:ai4)
setcell({%tname},5,29,"Total","c")
setcell({%tname},5,30,"Earnings Suspense File (ESF)","c")
{%tname}.setmerge(ad5:af5)
setcell({%tname},5,33,"Posted to MEF","c")
{%tname}.setmerge(ag5:ai5)
setcell({%tname},6,30,"Total","c")
setcell({%tname},6,31,"LRP","c")
setcell({%tname},6,32,"Other","c")
setcell({%tname},6,33,"Total","c")
setcell({%tname},6,34,"OIP","c")
setcell({%tname},6,35,"Residual","c")

setcell({%tname},2,36,"Total","c")
setcell({%tname},3,36,"AWI Wage","c")
setcell({%tname},4,36,"Workers","c")
setcell({%tname},5,36,"Posted to","c")
setcell({%tname},6,36,"MEF","c")

setcell({%tname},8,1,"(a)")
setcell({%tname},8,2,"(b)", "c")
setcell({%tname},8,3,"(c)", "c")
setcell({%tname},7,4,"(b-c)", "c")
setcell({%tname},8,4,"(d)", "c")
setcell({%tname},8,5,"(e)", "c")
setcell({%tname},7,6,"(g:i)", "c")
setcell({%tname},8,6,"(f)", "c")
setcell({%tname},8,7,"(g)", "c")
setcell({%tname},8,8,"(h)", "c")
setcell({%tname},8,9,"(i)", "c")
setcell({%tname},7,10,"(k:m)", "c")
setcell({%tname},8,10,"(j)", "c")
setcell({%tname},8,11,"(k)", "c")
setcell({%tname},8,12,"(l)", "c")
setcell({%tname},8,13,"(m)", "c")
setcell({%tname},7,14,"(o:r)", "c")
setcell({%tname},8,14,"(n)", "c")
setcell({%tname},8,15,"(o)", "c")
setcell({%tname},8,16,"(p)", "c")
setcell({%tname},8,17,"(q)", "c")
setcell({%tname},8,18,"(r)", "c")
setcell({%tname},7,19,"(d-e)", "c")
setcell({%tname},8,19,"(s)", "c")
setcell({%tname},8,20,"(t)", "c")
setcell({%tname},7,21,"(s-t)", "c")
setcell({%tname},8,21,"(u)", "c")
setcell({%tname},7,22,"(w:y)", "c")
setcell({%tname},8,22,"(v)", "c")
setcell({%tname},8,23,"(w)", "c")
setcell({%tname},8,24,"(x)", "c")
setcell({%tname},8,25,"(y)", "c")
setcell({%tname},8,26,"(z)", "c")
setcell({%tname},7,27,"(s-(v-z))", "c")
setcell({%tname},8,27,"(aa)", "c")
setcell({%tname},8,28,"(ab)", "c")
setcell({%tname},7,29,"(aa-ab)", "c")
setcell({%tname},8,29,"(ac)", "c")
setcell({%tname},7,30,"(ae+af)", "c")
setcell({%tname},8,30,"(ad)", "c")
setcell({%tname},8,31,"(ae)", "c")
setcell({%tname},8,32,"(af)", "c")
setcell({%tname},7,33,"(ac-ad)", "c")
setcell({%tname},8,33,"(ag)", "c")
setcell({%tname},8,34,"(ah)", "c")
setcell({%tname},7,35,"(ag-ah)", "c")
setcell({%tname},8,35,"(ai)", "c")
setcell({%tname},7,36,"(e+u-ad)", "c")
setcell({%tname},8,36,"(aj)", "c")
next

'change bottom column heading for WS and ASW tables in a few columns 
for %tname ws_levels aws_levels
setcell({%tname},7,2,"(c+d)")
setcell({%tname},7,4,"(u+e)", "c")
setcell({%tname},7,5,"(f+j+n)", "c")
setcell({%tname},7,21,"(v+ac)", "c")
setcell({%tname},7,29," ", "c")
setcell({%tname},7,30," ", "c")
setcell({%tname},7,31,"(ad-af)", "c")
next

'set lines around cells in the header part of the table 
for %tname te_summary ter ws_levels aws_levels
{%tname}.setwidth(@all) 8 
{%tname}.setwidth(1) 9 
{%tname}.setlines(a1:aj8) +a 

{%tname}.setlines(a1:a6) +o -h 
{%tname}.setlines(b2:b6) -h 
{%tname}.setlines(c2:c6) -h  
{%tname}.setlines(d3:d6) -h 
{%tname}.setlines(e4:e6) -h 
{%tname}.setlines(f5:f6) -h 
{%tname}.setlines(g5:g6) -h 
{%tname}.setlines(h5:h6) -h 
{%tname}.setlines(i5:i6) -h 
{%tname}.setlines(j5:j6) -h 
{%tname}.setlines(k5:k6) -h 
{%tname}.setlines(l5:l6) -h 
{%tname}.setlines(m5:m6) -h 
{%tname}.setlines(n5:n6) -h 
{%tname}.setlines(o5:o6) -h 
{%tname}.setlines(p5:p6) -h 
{%tname}.setlines(q5:q6) -h 
{%tname}.setlines(r5:r6) -h 
{%tname}.setlines(s4:s6) -h 
{%tname}.setlines(t4:t6) -h 
{%tname}.setlines(u5:u6) -h 
{%tname}.setlines(aa4:aa6) -h
{%tname}.setlines(ab4:ab6) -h  
{%tname}.setlines(ac5:ac6) -h 
{%tname}.setlines(aj2:aj6) -h 

{%tname}.setlines(a7:a8) +o -h
{%tname}.setlines(b7:b8) +o -h
{%tname}.setlines(c7:c8) +o -h
{%tname}.setlines(d7:d8) +o -h
{%tname}.setlines(e7:e8) +o -h
{%tname}.setlines(f7:f8) +o -h
{%tname}.setlines(g7:g8) +o -h
{%tname}.setlines(h7:h8) +o -h
{%tname}.setlines(i7:i8) +o -h
{%tname}.setlines(j7:j8) +o -h
{%tname}.setlines(k7:k8) +o -h
{%tname}.setlines(l7:l8) +o -h
{%tname}.setlines(m7:m8) +o -h 
{%tname}.setlines(n7:n8) +o -h
{%tname}.setlines(o7:o8) +o -h
{%tname}.setlines(p7:p8) +o -h
{%tname}.setlines(q7:q8) +o -h
{%tname}.setlines(r7:r8) +o -h
{%tname}.setlines(s7:s8) +o -h
{%tname}.setlines(t7:t8) +o -h
{%tname}.setlines(u7:u8) +o -h
{%tname}.setlines(v7:v8) +o -h
{%tname}.setlines(w7:w8) +o -h
{%tname}.setlines(x7:x8) +o -h
{%tname}.setlines(y7:y8) +o -h
{%tname}.setlines(z7:z8) +o -h
{%tname}.setlines(aa7:aa8) +o -h
{%tname}.setlines(ab7:ab8) +o -h
{%tname}.setlines(ac7:ac8) +o -h
{%tname}.setlines(ad7:ad8) +o -h
{%tname}.setlines(ae7:ae8) +o -h
{%tname}.setlines(af7:af8) +o -h
{%tname}.setlines(ag7:ag8) +o -h
{%tname}.setlines(ah7:ah8) +o -h
{%tname}.setlines(ai7:ai8) +o -h
{%tname}.setlines(aj7:aj8) +o -h

{%tname}.setlines(a10:aj121) +o
{%tname}.setlines(b10:b121) +o
{%tname}.setlines(d10:r121) +o
{%tname}.setlines(s10:y121) +o
{%tname}.setlines(aa10:ai121) +o

{%tname}.setformat(@all) f.3 
next

'several special adjustment for the WS table
ws_levels.setformat(@all) f.1 
ws_levels.setwidth(21) 11
ws_levels.setwidth(29) 11
ws_levels.setwidth(33) 11
ws_levels.setwidth(35:36) 11

'format TEO and TEO_R tables, give them column heading and other trimmings
for %tname teo_summary teo_r 
{%tname}.insertrow(1) 7 'insert enough rows to create all necessary column headings

setcell({%tname},3,1,"Calendar","c")
setcell({%tname},4,1,"Year","c")
setcell(teo_summary,1,2,"Total At-any-time Employment for the Other Population (in millions)","c")
teo_summary.setmerge(b1:v1)
setcell(teo_r,1,2,"Total At-any-time Employment for the Other Population (ratio to the total in last column)","c")
teo_r.setmerge(b1:v1)

setcell({%tname},2,2,"Authorized to Work (i.e., Non-Immigrants)","c")
{%tname}.setmerge(b2:k2)
setcell({%tname},3,2,"Total","c")
setcell({%tname},3,3,"Students and Families","c")
{%tname}.setmerge(c3:f3)
setcell({%tname},4,3,"F1 and M1 Visas","c")
{%tname}.setmerge(c4:d4)
setcell({%tname},5,3,"Students","c")
setcell({%tname},5,4,"Families","c")
setcell({%tname},4,5,"J1 Visas","c")
{%tname}.setmerge(e4:f4)
setcell({%tname},5,5,"Students","c")
setcell({%tname},5,6,"Families","c")
setcell({%tname},3,7,"Workers and Families","c")
{%tname}.setmerge(g3:k3)
setcell({%tname},4,7,"Workers","c")
{%tname}.setmerge(g4:i4)
setcell({%tname},4,10,"Families","c")
{%tname}.setmerge(j4:k4)
setcell({%tname},5,7,"J1","c")
setcell({%tname},5,8,"H2A","c")
setcell({%tname},5,9,"Temp.","c")
setcell({%tname},5,10,"J1","c")
setcell({%tname},5,11,"Other","c")
setcell({%tname},6,11,"(L2 Only)","c")

setcell({%tname},2,12,"Not Authorized to Work (i.e., Undocumented)","c")
{%tname}.setmerge(l2:v2)
setcell({%tname},3,12,"Total","c")
setcell({%tname},3,13,"Previously Authorized to Work","c")
{%tname}.setmerge(m3:v3)
setcell({%tname},4,13,"Total","c")
setcell({%tname},4,14,"Students and Families","c")
{%tname}.setmerge(n4:q4)
setcell({%tname},5,14,"F1 and M1 Visas","c")
{%tname}.setmerge(n5:o5)
setcell({%tname},6,14,"Students","c")
setcell({%tname},6,15,"Families","c")
setcell({%tname},5,16,"J1 Visas","c")
{%tname}.setmerge(p5:q5)
setcell({%tname},6,16,"Students","c")
setcell({%tname},6,17,"Families","c")
setcell({%tname},4,18,"Workers and Families","c")
{%tname}.setmerge(r4:v4)
setcell({%tname},5,18,"Workers","c")
{%tname}.setmerge(r5:t5)
setcell({%tname},5,21,"Families","c")
{%tname}.setmerge(u5:v5)
setcell({%tname},6,18,"J1","c")
setcell({%tname},6,19,"H2A","c")
setcell({%tname},6,20,"Temp.","c")
setcell({%tname},6,21,"J1","c")
setcell({%tname},6,22,"Other","c")

setcell(teo_summary,1,23,"Total At-any-time Employment for the Other Population (in millions)","c")
teo_summary.setmerge(w1:al1)
setcell(teo_r,1,23,"Total At-any-time Employment for the Other Population (ratio to the total in last column)","c")
teo_r.setmerge(w1:al1)
setcell({%tname},2,23,"Not Authorized to Work (i.e., Undocumented)","c")
{%tname}.setmerge(w2:ag2)
setcell({%tname},3,23,"Never Authorized to Work","c")
{%tname}.setmerge(w3:ag3)
setcell({%tname},4,23,"Families of Wrks (Und. Econ.)","c")
{%tname}.setmerge(w4:y4)
setcell({%tname},5,23,"Total","c")
setcell({%tname},5,24,"Auth.","c")
setcell({%tname},6,24,"to enter","c")
setcell({%tname},5,25,"Over-","c")
setcell({%tname},6,25,"stayers","c")
setcell({%tname},4,26,"Entered Legally (ex. Tourists)","c")
{%tname}.setmerge(z4:ac4)
setcell({%tname},5,26,"Total","c")
setcell({%tname},5,27,"Posted to","c")
setcell({%tname},6,27,"MEF","c")
setcell({%tname},5,28,"Sent to","c")
setcell({%tname},6,28,"ESF","c")
setcell({%tname},5,29,"Undergr.","c")
setcell({%tname},6,29,"Economy","c")
setcell({%tname},4,30,"Entered Illegally","c")
{%tname}.setmerge(ad4:ag4)
setcell({%tname},5,30,"Total","c")
setcell({%tname},5,31,"Posted to","c")
setcell({%tname},6,31,"MEF","c")
setcell({%tname},5,32,"Sent to","c")
setcell({%tname},6,32,"ESF","c")
setcell({%tname},5,33,"Undergr.","c")
setcell({%tname},6,33,"Economy","c")

setcell({%tname},2,34,"Total Posted to MEF","c")
{%tname}.setmerge(ah2:ai2)
setcell({%tname},3,34,"Total","c")
setcell({%tname},3,35,"OASDI","c")
setcell({%tname},4,35,"Covered","c")

setcell({%tname},2,36,"Total","c")
setcell({%tname},3,36,"Sent to","c")
setcell({%tname},4,36,"ESF","c")
setcell({%tname},2,37,"Total in","c")
setcell({%tname},3,37,"Under.","c")
setcell({%tname},4,37,"Economy","c")
setcell({%tname},2,38,"Total","c")

	!n=1
	for %col (a) (b) (c) (d) (e) (f) (g) (h) (i) (j) (k) (l) (m) (n) (o) (p) (q) (r) (s) (t) (u) (v) (w) (x) (y) (z) (aa) (ab) (ac) (ad) (ae) (af) (ag) (ah) (ai) (aj) (ak) (al) 
	setcell({%tname},8,!n,%col,"c")
	!n=!n+1
	next

setcell({%tname},7,2,"sum(c:k)","c")
setcell({%tname},7,12,"(m+w+z+ad)","c")
setcell({%tname},7,13,"sum(n:v)","c")
setcell({%tname},7,23,"(x+y)","c")
setcell({%tname},7,26,"sum(aa:ac)","c")
setcell({%tname},7,30,"sum(ae:ag)","c")

{%tname}.setwidth(@all) 8 
{%tname}.setwidth(12) 11
{%tname}.setwidth(26) 11
{%tname}.setwidth(30) 11

'draw lines around certain cells
{%tname}.setlines(a1:al9) +a 
	for %col a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab ac ad ae af ag ah ai aj ak al 
	{%tname}.setlines({%col}7:{%col}8) -h   
	next
{%tname}.setlines(a2:a6) -h 
{%tname}.setlines(b3:b6) -h 
{%tname}.setlines(l3:l6) -h 
{%tname}.setlines(ah3:ah6) -h 
{%tname}.setlines(ai3:ai6) -h 
{%tname}.setlines(aj2:aj6) -h 
{%tname}.setlines(ak2:ak6) -h 
{%tname}.setlines(al2:al6) -h 
	for %col c d e f g h i j k w x y z aa ab ac ad ae af ag 
	{%tname}.setlines({%col}5:{%col}6) -h   
	next

{%tname}.setlines(a10:al129) +o
{%tname}.setlines(b10:b129) +o
{%tname}.setlines(l10:l129) +o
{%tname}.setlines(m10:v129) +o
{%tname}.setlines(w10:y129) +o
{%tname}.setlines(z10:ac129) +o
{%tname}.setlines(ad10:ag129) +o
{%tname}.setlines(al10:al129) +o

next 'the end of the loop that loops through two tables (TEO and TEO_R)

teo_summary.setformat(@all) f.5 'TEO table set to 6 decimals
teo_r.setformat(@all) f.3 'TEO_R table set to 3 decimals


'*******create "readable tables" by splitting the wide tables created above into smaller pieces that fit on one page (width-wise)
'Tables te_summary, ter, ws_levels, and aws_levels have identical structure of columns, so can use identical procedure to break them up into three sections. This is done in the loop below.

for %tname te_summary ter ws_levels aws_levels
'first section of table, "No HI covered earnings"
%tnocov=@left(%tname, 3)+"_nocov" 'name string for the new table
table {%tnocov}={%tname} 'create new table that will contain only columns 1-18 (or A-R) of the larger table
{%tnocov}.deletecol(S) 18 'delete all colums after S. Note that this automatically unmerges the merged cells that extended into the deleted columns
{%tnocov}.setmerge(B1:R1) 'merge top cells
{%tnocov}.setmerge(D2:R2)
{%tnocov}.setwidth(5:14) 7 

'second section of table, "HI covered (includes ESF)
%thi=@left(%tname, 3)+"_hi"
table {%thi}={%tname} 'create new table that will contain only columns 1 and 19-26(or A and S-Z) of the larger table
{%thi}.deletecol(aa) 10 'delete colums AA and after.
{%thi}.deletecol(b) 17 'delete colums B-R. Note that this removed the contens on the merges cells in row 1 and 2.
{%thi}(1,2)="Total Employed At-any-time"
{%thi}(2,2)="Reported"
{%thi}.setmerge(B1:I1) 'merge top cells
{%thi}.setmerge(B2:I2)

'third section of table, "OASDI covered" and AWI wage workers
%toasdi=@left(%tname, 3)+"_oasdi"
table {%toasdi}={%tname} 'create new table that will contain only columns 1 and 27-36(or A and AA-AJ) of the larger table
{%toasdi}.deletecol(b) 25 'delete colums B-R. Note that this removed the contens on the merges cells in row 1 and 2.
{%toasdi}(1,2)="Total Employed At-any-time"
{%toasdi}(2,2)="Reported"
{%toasdi}.setmerge(B1:K1) 'merge top cells
{%toasdi}.setmerge(B2:J2)
next

'adjust top cell of each table to have more informative title
for %tabname ter ter_nocov ter_hi ter_oasdi
{%tabname}(1,2)="Total Employed At-any-time (ratio to total reported)"
next

for %tabname ws_levels ws__nocov ws__hi ws__oasdi
{%tabname}(1,2)="Total Employed At-any-time (wages for TE levels)"
next

for %tabname aws_levels aws_nocov aws_hi aws_oasdi
{%tabname}(1,2)="Total Employed At-any-time (Average wages for TE levels, $thous.)"
next

'readable tables for TEO and TEO_R
'first section -- "authorized to work"
table teo_auth=teo_summary
table teo_r_auth=teo_r
teo_auth.deletecol(L) 27 'delete all colums after L. Note that this automatically unmerges the merged cells that extended into the deleted columns
teo_auth.setmerge(B1:K1) 'merge top cells
teo_r_auth.deletecol(L) 27 
teo_r_auth.setmerge(B1:K1)

'secoind section -- "unauthorised, but previously authorozed"
table teo_prev=teo_summary
table teo_r_prev=teo_r
teo_prev.deletecol(w) 16 
teo_prev.deletecol(b) 10 
teo_prev(1,1)="Total At-any-time Employment for the Other Population (in millions)"
teo_prev.setmerge(a1:l1) 'merge top cells
teo_r_prev.deletecol(w) 16 
teo_r_prev.deletecol(b) 10 
teo_r_prev(1,1)="Total At-any-time Employment for the Other Population (ratio to the total in last column)"
teo_r_prev.setmerge(a1:l1) 'merge top cells

'third section -- "never authorized to work"
table teo_never=teo_summary
table teo_r_never=teo_r
teo_never.deletecol(b) 21 
teo_r_never.deletecol(b) 21 

if %sav_pdf = "Y" then
	'save all "readable tables" as PDF
	for %tname te_summary ter ws_levels aws_levels
		%tnocov=@left(%tname, 3)+"_nocov"
		%filepdf = %outputpath+@left(%tname, 3)+" table"+" No HI TR"+%tr+%alt+".pdf"
		{%tnocov}.save(t=pdf, landscape) %filepdf

		%thi=@left(%tname, 3)+"_hi"
		%filepdf = %outputpath+@left(%tname, 3)+" table"+" HI TR"+%tr+%alt+".pdf"
		{%thi}.save(t=pdf) %filepdf

		%toasdi=@left(%tname, 3)+"_oasdi"
		%filepdf = %outputpath+@left(%tname, 3)+" table"+" OASDI TR"+%tr+%alt+".pdf"
		{%toasdi}.save(t=pdf) %filepdf
	next

	%filepdf=%outputpath+"TEO authorized TR"+%tr+%alt+".pdf"
	teo_auth.save(t=pdf) %filepdf
	%filepdf=%outputpath+"TEO_R authorized TR"+%tr+%alt+".pdf"
	teo_r_auth.save(t=pdf) %filepdf
	%filepdf=%outputpath+"TEO previously authorized TR"+%tr+%alt+".pdf"
	teo_prev.save(t=pdf) %filepdf
	%filepdf=%outputpath+"TEO_R previously authorized TR"+%tr+%alt+".pdf"
	teo_r_prev.save(t=pdf) %filepdf
	%filepdf=%outputpath+"TEO never authorized TR"+%tr+%alt+".pdf"
	teo_never.save(t=pdf, landscape) %filepdf
	%filepdf=%outputpath+"TEO_R never authorized TR"+%tr+%alt+".pdf"
	teo_r_never.save(t=pdf, landscape) %filepdf
endif

'****** end of "readable tables" section

'can save tables as CSV files, if desired

'save the tables in CSV (which can then be loaded into Excel) -- UNCOMMENT this section is we want the CSV files
'TE table
'%tefilecsv =%outputpath+"TE table "+%tr+%alt+".csv"
'te_summary.save(t=csv, landscape) {%tefilecsv}
'TER table
'%terfilecsv =%outputpath+"TER table "+%tr+%alt+".csv"
'ter.save(t=csv, landscape) {%terfilecsv}
'WS table
'%wsfilecsv =%outputpath+"WS Levels "+%tr+%alt+".csv"
'ws_levels.save(t=csv, landscape) {%wsfilecsv}
'AWS table
'%awsfilecsv =%outputpath+"AWS Levels "+%tr+%alt+".csv"
'aws_levels.save(t=csv, landscape) {%awsfilecsv}


'put all check_tables into one spool; easier to print it into a single pdf file later
spool __checks

string line1 = "This file was created on " + @date + " at " + @time + " using the following input files:"
string line2 = "A-bank " + %abankpath 
string line3 = "D-bank " + %dbankpath 
string line4 = "OTL bank " + %otlbankpath
string line5 = "MEF bank " + %mefbankpath 
string line6 = "op-bank " + %opbankpath

__checks.insert line1 line2 line3 line4 line5 line6

'include various tables of checks, their values and descriptive stats
__checks.append(name=TEchecks) te_checkstats 
__checks.append(name=TEOchecks) teo_checkstats 
__checks.append(name=NOchecks) no_checkstats
string heading="TE checks, TEO checks, and NO checks should all be zero (except for rounding/precision errors). Values significantly different from zero are listed below."
__checks.append heading 

string none="None"
string heading1="TE checks exceeding "+@str(!tol)+" (See table te_checktable in workfile " + %thisfile + ".wf1 for the full series for these checks.)"
__checks.append heading1
'this FOR loop prints out into the spool the values of the check series that exceed the tolerance limit set by !tol
!count1=0
for %ch check_tceahi check_wswahi check_tcea check_seo check_wswa check_wsw_mef 
smpl !datestart !dateend if @abs({%ch})>!tol 
if @obssmpl>0 then freeze(warning_{%ch}) {%ch}.sheet(nl) 
warning_{%ch}.title {%ch}
__checks.append(name={%ch}) warning_{%ch}
!count1=!count1+1
endif 
next
if !count1=0 then __checks.append none 'if we found no values exceeding !tol, print "None" into spool
endif

string heading2="TEO checks exceeding "+@str(!tol)+" (See table teo_checktable in workfile " + %thisfile + ".wf1 for the full series for these checks.)"
__checks.append heading2
'this FOR loop prints out into the spool the values of the check series that exceed the tolerance limit set by !tol
!count2=0
for %ch check_teo_a check_teo_na check_teo_no check_teo check_teo_mef check_teo_mefc check_teo_esf check_teo_und 
smpl !datestart !dateend if @abs({%ch})>!tol 
if @obssmpl>0 then freeze(warning_{%ch}) {%ch}.sheet(nl) 
warning_{%ch}.title {%ch}
__checks.append(name={%ch}) warning_{%ch}
!count2=!count2+1
endif 
next
if !count2=0 then __checks.append none 'if we found no values exceeding !tol, print "None" into spool
endif

string heading3="NO checks exceeding "+@str(!tol)+" (See table no_checktable in workfile " + %thisfile + ".wf1 for the full series for these checks.)"
__checks.append heading3
'this FOR loop prints out into the spool the values of the check series that exceed the tolerance limit set by !tol
!count3=0
for %ch check_no_a check_no_na check_nil_nild 
smpl !datestart !dateend if @abs({%ch})>!tol 
if @obssmpl>0 then freeze(warning_{%ch}) {%ch}.sheet(nl) 
warning_{%ch}.title {%ch}
__checks.append(name={%ch}) warning_{%ch}
!count3=!count3+1
endif 
next
if !count3=0 then __checks.append none 'if we found no values exceeding !tol, print "None" into spool
endif


__checks.append(name=WSchecks) ws_checkstats 
string heading4="CHECK_WSCAHI and CHECK_WS_MEF should be zero (except for rounding/precision errors). Values significantly different from zero are listed below. CHECK_WSD is never zero. Table wsd_table in workfile " + %thisfile + ".wf1 provides full check_wsd series and its components."
__checks.append heading4 
'loop to find nonzero values of ws_checks

string heading5="WS checks exceeding "+@str(!tol)+" (See table ws_checktable in workfile " + %thisfile + ".wf1 for the full series for these checks.)"
__checks.append heading5
'this FOR loop prints out into the spool the values of the check series that exceed the tolerance limit set by !tol
!count4=0
for %ch check_wscahi check_ws_mef
smpl !datestart !dateend if @abs({%ch})>!tol 
if @obssmpl>0 then freeze(warning_{%ch}) {%ch}.sheet(nl) 
warning_{%ch}.title {%ch}
__checks.append(name={%ch}) warning_{%ch}
!count4=!count4+1
endif 
next
if !count4=0 then __checks.append none 'if we found no values exceeding !tol, print "None" into spool
endif
smpl !datestart !dateend

__checks.append(name=WSDcheck) wsd_stats 'print into spool the table that shows descriptive stats on WSD check
'__checks.append(name=WSDdetail) wsd_table 'print into spool the table that includes WSD check and its components for all years

'add text that lists useful objects in the workfile
svector (29) wflist
wflist(1) = "Output files produced by empl_ws_checks.prg:"
wflist(2) = "All output files are stored in "+%outputpath 
wflist(3) = %thisfile +".pdf"+" -- this document (summary of checks for TE and WS)."
wflist(4) = "TE_ table No HI "+%tr+%alt+".pdf"+" -- ''No HI Covered earnings'' portion of TE table, in PDF"
wflist(5) = "TE_ table HI "+%tr+%alt+".pdf"+" -- ''HI Covered'' portion of TE table, in PDF"
wflist(6) = "TE_ table OASDI "+%tr+%alt+".pdf"+" -- ''OASDI Covered'' portion of TE table, in PDF"
wflist(7) = "TER table No HI <...>.pdf, TER table HI <...>.pdf, TER table OASDI <...>.pdf -- same for TER table"
wflist(8) = "WS_ table No HI <...>.pdf, WS_ table HI <...>.pdf, WS_ table OASDI <...>.pdf -- same for WS_Levels "
wflist(9) = "AWS table No HI <...>.pdf, AWS table HI <...>.pdf, AWS table OASDI <...>.pdf -- same for AWS_Levels"
wflist(10) = "TEO authorized "+%tr+%alt+".pdf"+" -- ''Authorized'' portion of TEO table, in PDF"
wflist(11) = "TEO previously authorized "+%tr+%alt+".pdf"+" -- ''Previously Authorized'' portion of TEO table, in PDF"
wflist(12) = "TEO never authorized "+%tr+%alt+".pdf"+" -- ''Never Authorized'' and Totals portions of TEO table, in PDF"
wflist(13) = "TEO_R authorized "+%tr+%alt+".pdf"+", TEO_R previously authorized "+%tr+%alt+".pdf and "
wflist(14) = "TEO_R never authorized "+%tr+%alt+".pdf -- same for TEO_R table"
wflist(15) = "**********"
wflist(16) = "Useful objects in workfile " + %thisfile + ".wf1:" 
wflist(17) = "Table te_checktable -- full series for all TE checks (6 sereis)"
wflist(18) = "Table teo_checktable -- full series for all TEO checks (8 series)"
wflist(19) = "Table no_checktable -- full series for all NO checks (3 series)"
wflist(20) = "Table te_summary -- wide table with TE data with full column headings"
wflist(21) = "Table ter -- wide table showing TE data as ratios to total reported"
wflist(22) = "Table teo_summary -- wide table with TEO data with full column headings"
wflist(23) = "Table teo_r -- wide table with TEO data as Ratios to total"
wflist(24) = "Table no_summary -- wide table with NO data (limited column headings)"
wflist(25) = "Table ws_levels -- wide table showing WS Levels data"
wflist(26) = "Table aws_levels -- wide table showing AWS levels, i.e. average wages for each group"
wflist(27) = "Table ws_checktable -- full series for WS checks (3 series)"
wflist(28) = "Table wsd_table -- full series for check_WSD and related components"
wflist(29) = "The workfile "+ %thisfile + ".wf1' is stored in "+%outputpath 

__checks.append(name=summary) wflist
__checks.display 'displays the spool with all the summary check tables on screen

if %sav = "Y" then
	%summarypath=%outputpath+ %thisfile +".pdf" 'location and filename where the PDF version of the spool will be saved
	__checks.save(t=pdf, landscape) {%summarypath} 'saves the content sof the spool to \\s1f906b\econ\Checks\TR2017\Econ Model\
endif

delete heading heading1 heading2 heading3 heading4 heading5 none warning* 'delete temporary objects no longer needed
delete line*

'delete aws_col_* no_col_* te_col_* teo_col_* teo_r_col_* ter_col_* ws_col_* 'delete the "column" series used to build the tables; uncomment this is need to see series for individual columns in the tables


if %sav = "Y" then 
	%workfilepath=%outputpath+%thisfile 'filename and path to store the workfile
	wfsave(2) %workfilepath 
endif

'wfclose


