' This program checks ESF-related data agaist corresponding values in databanks.
' It uses esf_rpt_20XX.wf1 workfile that contains ESF-reletaed series.
'Polina Vlasenko 12-21-2017

' The check of data against values entered into EconOtl2Mod program is not automated yet! Right now the user should pull the numbers out of EconOtl2Mod by hand and save them in some form that EViews can read. Looking fr ways ot fix this....  12-22-2017  Polina Vlasenko



' Before running the program the user should update the necessary values in the UPDATE section marked with *****

'**** UPDATE these entries before runnign the program

!tol = 0.0001 'tolarenace parameter for checks (cjecks should be zero, but in practice they are not b/c of rounding)
!TR=2018 'TR year

'period over which the check needs to be performed
!yearfirst=1971 ' NOT likely to change
!yearlast=!TR-3 'esf data do not exist all the way up to the TR year

%file_esf="\\s1f906b\econ\Raw data\ESF\esf_rpt_2017.wf1" ' full path to the EViews workfile that contains the processed ESF data to be checked (this file is created by esf_update.prg)

%file_otl = "\\s1f906b\econ\Checks\TR2018\check_esf_otl.xls" 'file that contains CLEANED up data from EconOtl2Mod, unfortunately, in the current iteration of this code, this file must be created by hand.

%folder_mef="E:\usr\econ\EcoDev\dat\"  'folder that contains the MEF databank to be checked
%folder_abank="\\lrserv1\usr\eco.18\bnk\2017-1221-1403 TR182\"  'folder that contains the a-bank to be checked

'output produced by this program 
%file_output="check_esf_TR"+@str(!TR) 'filename only
%output_path="\\s1f906b\econ\Checks\TR2018\"  'full path

'**** END of the UPDATE section

%abank = "atr"+@str(!TR-2000)+"2.bnk"
%abankpath = %folder_abank+%abank
%mefbank = "mef.bnk"
%mefbankpath = %folder_mef+%mefbank

'create the new workfile with appropriare paramenter
wfcreate(wf={%file_output}, page=esf_data) a !yearfirst !yearlast '' see if it is OK to get it all the way to TR

'load series form the esf_rpt_20XX workfile
%list_esf = "te_sf_lrp te_sf_teo te_sfm_lrp te_sfo_lrp we_sf we_sf_lrp we_sf_teo we_sfm_lrp we_sfo_lrp" 'list of series in the ESF workfile to be checked
wfopen %file_esf
'copy and rename series from the list
for %ser {%list_esf}
	copy %file_esf::data\{%ser} %file_output::esf_data\{%ser}_esf
next
wfclose %file_esf

'fetch data from databanks
dbopen(type=aremos) %abankpath
for %ser {%list_esf}
	fetch {%ser}.a 
next
close @db

dbopen(type=aremos) %mefbankpath
fetch tel_so
close @db

'import data for EconOtl2Mod check -- this is not automated yet! It requires that the user pulls the data out of EconOtl2Mod and saves it in some form that EViews can read. The command below then reads it into the workfile here.
smpl 1964 !yearlast
import %file_otl @freq a 1964
smpl !yearfirst !yearlast


'compare databank data to ESF-file data
for %ser {%list_esf}
	genr ck_{%ser} = {%ser} - {%ser}_esf
next
genr ck_mef=tel_so-te_sfm_lrp_esf
' Check for EconOtl2Mod
genr ck_otl2 = econotl2mod - te_sf_teo_esf

group ck_p1 ck_mef ck_otl2 ck_te_sf_lrp ck_te_sf_teo ck_te_sfm_lrp
freeze(p1_checkstats) ck_p1.stats
p1_checkstats.setwidth(4) 16 
p1_checkstats.setwidth(5) 16 
p1_checkstats.setwidth(6) 16 
p1_checkstats.title ESF checks against data in MEF, EconOtl2Mod, and a-bank
p1_checkstats.deleterow(18) 1 'streamline the table by deleting info we don't need
p1_checkstats.deleterow(10) 7

group ck_p2 ck_te_sfo_lrp ck_we_sf ck_we_sf_lrp ck_we_sf_teo ck_we_sfm_lrp ck_we_sfo_lrp
freeze(p2_checkstats) ck_p2.stats
p2_checkstats.setwidth(2) 16 
p2_checkstats.setwidth(4) 15 
p2_checkstats.setwidth(5) 16 
p2_checkstats.setwidth(6) 16 
p2_checkstats.setwidth(7) 16 
p2_checkstats.title ESF checks against data in a-bank
p2_checkstats.deleterow(18) 1 'streamline the table by deleting info we don't need
p2_checkstats.deleterow(10) 7

'put results of all checks into one spool; easier to print it into a single pdf file later
spool summary

string heading1="OCACT -- EFS data check for TR"+@str(!TR)+". Date: "+@date+"  "+@time
summary.insert heading1
summary.append(name=mef_otl_checks) p1_checkstats 
summary.append(name=abank_checks) p2_checkstats 
string heading2="Check of EFS data against MEF bank, EconOtl2Mod, and A-bank. All checks should all be zero (except for rounding/precision errors). Values different from zero by more than "+@str(!tol)+" are listed below."
summary.append(name=description) heading2 

string none="None"
'string heading="Checks exceeding "+@str(!tol)+" (See table te_checktable in workfile checks_empl_ws.wf1 for the full series for these checks.)"
'checks.append heading1
'this FOR loop prints into the spool the values of the check series that exceed the tolerance limit set by !tol
!count=0
for %ch ck_mef ck_otl2 ck_te_sf_lrp ck_te_sf_teo ck_te_sfm_lrp ck_te_sfo_lrp ck_we_sf ck_we_sf_lrp ck_we_sf_teo ck_we_sfm_lrp ck_we_sfo_lrp
	smpl !yearfirst !yearlast if @abs({%ch})>!tol 
	if @obssmpl>0 then freeze(warning_{%ch}) {%ch}.sheet(nl) 
		warning_{%ch}.title {%ch}
		summary.append(name={%ch}) warning_{%ch}
		!count=!count+1
	endif
next
if !count=0 then summary.append none 'if we found no values exceeding !tol, print "None" into spool
endif
smpl !yearfirst !yearlast

summary.display

%summarypath=%output_path+"ESF_checks_TR"+@str(!TR)+".pdf"
summary.save(t=pdf) {%summarypath} 'save spool as pdf

%full_output_path=%output_path+%file_output+".wf1" 'file name and location to save the workfile

wfsave %full_output_path
'wfclose


