' This program created the lc addfactor for age-sex specific groups based on the new (2017) method first used for TR2018. 
'The program loads from final databanks (a-bank, d-bank, add-bank), for each age-sex-sepecific group, LFPRs before and after the adjustment and backs out the adjustment factor for each group. 
' The user should indicate the locations of the relevant databanks prior to running the program.

'Polina Vlasneko 
'  02-01-2018

'Updated to final TR2019 file locations.
' Added a _summary spool that saves summary infor for the run.
'  -- PV 01/18/2019

'Updated to final TR2020 file locations
'  -- PV 01/24/2020

' Updated the code iteself to acoutn for the new way the addfactors were doen for TR2020. 
' -- PV 03/24/2020
' Changes:
' - individuakl addafcators now exist for ages 55-74 (both genders). Thats age3 and PART of age4 as defined below.
' - special add2 addfactor.(accounts for LFPR adjustment to counteract the change in RU assumption)
' (unralted to addfactor changes) also added %sav option that governs saving of the file


'******** UPDATE this section *************

%sav = "Y" 	' enter "Y" or "N" (case sensitive); governs whether the workfile is saved

'location of the databanks to be used (uncomment ONE group of files)
'alt2
%abank = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\atr202.bnk"
%dbank = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\dtr202.bnk"
%adbank = "\\LRSERV1\usr\eco.20\bnk\2019-1220-1350-TR202\dat\adtr202.bnk"

'alt1
'%abank = "\\LRSERV1\usr\eco.20\bnk\2020-0116-1635-TR201\atr201.bnk"
'%dbank = "\\LRSERV1\usr\eco.20\bnk\2020-0116-1635-TR201\dtr201.bnk"
'%adbank = "\\LRSERV1\usr\eco.20\bnk\2020-0116-1635-TR201\dat\adtr201.bnk"

'alt3
'%abank = "\\LRSERV1\usr\eco.20\bnk\2020-0117-1744-TR203\atr203.bnk"
'%dbank = "\\LRSERV1\usr\eco.20\bnk\2020-0117-1744-TR203\dtr203.bnk"
'%adbank = "\\LRSERV1\usr\eco.20\bnk\2020-0117-1744-TR203\dat\adtr203.bnk"

'period covered in this file
!yearstart = 1995
!yearend=2100 	' was 2099

'location to save the resulting file into (uncomment ONE)
%file_output = "lfpr_add_202"
'%file_output = "lfpr_add_201"
'%file_output = "lfpr_add_203"

%output_path = "E:\usr\pvlasenk\LFPR Decomp Output\TR2020\"+%file_output+".wf1"

' ********* END of update section *********

'these will be used to construct names of the age-sex groups
%sex="f m"
%age1="1617 1819" 
%age2="2024 2529 3034 3539 4044 4549 5054" 
%age3="55 56 57 58 59 60 61 62 63 64 65 66 67 68 69" 
%age4="70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100"
%ms="ma ms nm"

wfcreate(wf={%file_output}, page=lfprs) q !yearstart !yearend

'fetch relevant variables from the databanks
dbopen(type=aremos) %abank 

for %s {%sex}
	for %a {%age1} {%age2} {%age3} {%age4}
   		fetch p{%s}{%a}.q p{%s}{%a}_p.q
	next
next

for %a {%age2}
    for %m {%ms}
        fetch pm{%a}{%m}.q pm{%a}{%m}_p.q
     next
next

for %a 2024 2529 3034 3539 4044
	for %m {%ms}
		fetch pf{%a}{%m}c6u.q pf{%a}{%m}c6u_p.q
		fetch pf{%a}{%m}nc6.q pf{%a}{%m}nc6_p.q
     next
next

for %a 4549 5054
    for %m {%ms}
        fetch pf{%a}{%m}.q pf{%a}{%m}_p.q
     next
next
close @db

'life-expectancy adjustment
dbopen(type=aremos) %dbank 
for %s {%sex}
 for %a {%age2} {%age3} {%age4}
    fetch p{%s}{%a}adj.q 
  next
next
close @db

'individual addfactors
dbopen(type=aremos) %adbank 
   ' fetch pf65.add pf67.add pm67.add pm72.add pm74.add  'individual add-factors OLD method TR19 and before
for %s {%sex}
 for %a {%age3} 70 71 72 73 74
    fetch p{%s}{%a}_add.q 
  next
next
close @db

'Compute the lc adjustment for each of the lc equations.  

for %s {%sex}
 for %a {%age1} 
   series adj_p{%s}{%a}=(p{%s}{%a}-p{%s}{%a}_p)
 next
next

for %a {%age2}
	for %m {%ms}
     		series adj_pm{%a}{%m}=pm{%a}{%m}-pm{%a}{%m}_p-0.4*pm{%a}adj
	next
next

for %a 2024 2529 3034 3539 4044
	for %m {%ms}
     		series adj_pf{%a}{%m}c6u=pf{%a}{%m}c6u-pf{%a}{%m}c6u_p-0.4*pf{%a}adj
     		series adj_pf{%a}{%m}nc6=pf{%a}{%m}nc6-pf{%a}{%m}nc6_p-0.4*pf{%a}adj
  	next
next

for %a 4549 5054
	for %m {%ms}
     		series adj_pf{%a}{%m}=pf{%a}{%m}-pf{%a}{%m}_p-0.4*pf{%a}adj
	next
next

for %s {%sex}
 	for %a {%age3} {%age4}
   		series adj_p{%s}{%a}=p{%s}{%a}-p{%s}{%a}_p-0.4*p{%s}{%a}adj
 	next
next

' Remove individual addfactors. New method starting TR2020.
for %s {%sex}
	for %a {%age3} 70 71 72 73 74
   		adj_p{%s}{%a} = adj_p{%s}{%a} - p{%s}{%a}_add 
	next
next

'Five series have individual adjustment factors that need to be removed: -- OLD method TR2019 and earlier.
'adj_pf65=adj_pf65 - pf65_add
'adj_pf67=adj_pf67 - pf67_add
'adj_pm67=adj_pm67 - pm67_add
'adj_pm72=adj_pm72 - pm72_add
'adj_pm74=adj_pm74 - pm74_add

'Series named adj_p{sex}{age}{etc} are the adjustment factor for each age-sex-mar. status-child group, based on the new methodology of distributing the labor force adjutsment proportional to the model error.

'create a spool that would contain summary info for the run
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "This file contains the adjustment factor for each age-sex-mar. status-child group, based on the new methodology implemented for TR2020 (individual addfactoes exist for all ages 55 to 74)."
string line3 = "Series named adj_p{sex}{age}{etc} are the adjustment factor for each age-sex-mar. status-child group."
string line4 = "This run uses the following inputs:"
string line5 = " a-bank: " + %abank
string line6 = " d-bank: " + %dbank
string line7 = " ad-bank: " + %adbank
if %sav = "Y" then
	string line8 = "The resulting workfile -- " + %file_output + " -- has been saved to " +%output_path
endif
if %sav = "N" then
	string line8 = "The resulting workfile -- " + %file_output + " -- has NOT been saved. Please save the file manually if desired."
endif
string line9 = "Polina Vlasenko"

_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9
_summary.display

delete line*

if %sav = "Y" then 
	'save the workfile
	wfsave %output_path  
endif

'wfclose


