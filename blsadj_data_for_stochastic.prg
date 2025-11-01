' This program creates several series that are needed for the stochastic model.
' It uses inputs from the TR databanks and the blsadjYR.wf1 file created separately.

' 03-25-2021
' Polina Vlasenko

' Modified to use workfiles instead of databanks - SHS 06/20/23

' ***** Inputs -- enter here every time the program is run

!TRyr = 2025 	

!startyr=1965 		' first year of data in this file
!endyr=2100 		' last year of data in this file

%sav = "N" 	' enter "Y" or "N" (case sensitive); governs whether the output workfile is saved

' BKDO1 bank 
%bkdo1path = "S:\LRECON\ModelRuns\TR2025\2025-0106-1433-TR252\dat\bkdo1.wf1"		' full path of most recent BKDO1 file
%bkdo1 = "bkdo1"		' file name only, no extension

' BLSadj file -- enter the file with the adjusted BLS data you intend to use; it is normally called blsadjYR.wf1, like blsadj24.wf1. It MUST be an EViews workfile. 
%blsadjpath = "S:\LRECON\Data\Processed\BLS\BLSadj\blsadj24.wf1"  	' full path
%blsadj = "blsadj24"		' file name only, no extension
%BLDadj_month = "Jan2025" 	' indicate the month for which the population adjustment is being incorporated


' Output created by this program:
%folder_output = "S:\LRECON\Data\Processed\BLS\BLSadj\"
'name to be given to the workfile created by this program
%thisfile = "unadj_adj_for_stochastic_" + %BLDadj_month 	

' ******* END of the update section *******

wfcreate(wf={%thisfile}, page=a) a !startyr !endyr

' Step 1 -- Load data from BKDO1

wfopen %bkdo1path

wfselect {%thisfile}
pageselect a
smpl @all

	copy {%bkdo1}::a\lcf {%thisfile}::a\*		' labor force, females 16o
	copy {%bkdo1}::a\lcm {%thisfile}::a\* 		' labor force, males 16o
	copy {%bkdo1}::a\ruf {%thisfile}::a\* 		' un rate, females 16o
	copy {%bkdo1}::a\rum {%thisfile}::a\*	 	' un rate, males 16o
	
wfclose %bkdo1

' Step 2 -- Load data from BLSadj

wfselect {%thisfile}
pageselect a
smpl @all

wfopen {%blsadjpath}
pageselect data_a
' copy the "adjusted" series for employment (males 16o and females 16o)
copy {%blsadj}::data_a\em16o_aadj {%thisfile}::a\
copy {%blsadj}::data_a\ef16o_aadj {%thisfile}::a\
wfclose {%blsadjpath}


' Step 3 -- Now compute the ratios we need
 
wfselect {%thisfile}
pageselect a
smpl @all

' ADJUSTED employment
series e16o_aadj = ef16o_aadj+em16o_aadj

' UNADJUSTED employment
series ef16o = lcf*(1-ruf/100)
series em16o = lcm*(1-rum/100)
series e16o = ef16o+em16o

' RATIO of Adjusted to Unadjusted
for %ser em16o ef16o e16o
	series {%ser}_ratio={%ser}_aadj / {%ser}
next

if %sav = "Y" then 
	'save the workfile
	%save_file = %folder_output + %thisfile  
	wfsave %save_file
endif


' wfclose


