 '	This program updates a set of vectors that each store the adjustment values for CPS population controls released Jan of every year.
' 	These values are the used in the bls_popadjust_all.prg to adjust the monthly CPS population data to take account of the population controls. 
'	--- Polina Vlasenko 05-09-2019

' This version of the program -- cps_popadj_factors.prg -- adds the pop adjustment values released by BLS in Jan 2024 -- JA 06-21-2024

' 	***** Follow these steps EVERY YEAR, once the Jan CPS data are released *****
'	(1) Save a copy of this program, changing the year in its name to reflect the year of adjustment factors you are adding.
'		For example: when adding the pop adj released with Jan 2019 CPS, save a copy of this program and name it cps_popadj_factors_2019.prg. Note that in the BLS file these adjustment may be called "Dec 2018 population controls", but we name them by the time they are released (Jan 2019), not by the month being adjusted (Dec 2018).
'	(2) Enter the year from step (1) into !yr_latest below. (Optional: enter the location of the BLS file with raw data into the comment following !yr_latest.)
'	(3) Locate the workfile created by this program last year (it will be named cps_popadj_YEAR.wf1; for example cps_popadj_2018.wf1). Enter its name and location into %old_file_path and %old_file below.
'	(4) Enter the name of the workfile you intend to create, reflecting the year from step (2) into %new_file_path and %new_file.
'	(5) MANUALLY enter values for each BLS pop adjustment into the lines following the line ' ENTER NEW VALUES HERE.
'		The elements of the vector in these line are ordered in the order described by the string vector called 'names'. The series corresponding to each vector element is also listed in a comment on the line where the value of that vector element is assigned.
'		!!!!! Make sure you enter the adjustment factors corresponding to the concepts and sex-age groups in the order they are given in vector  'names' !!!!!
'	(6) Once the values are entered in the code below for all 115 vector elements, check that all entries under ' ***** UPDATE this section before running the program ***** are what you intend, and run the program. 
'		The program will run several simple checks to make sure that
'			(1) your vector has the correct length (115 elements), and it will display a warning if it does not. 
'			(2) male + female16o  totals add up to total 16o values.
'			(3) certain age groups add up to correspionding totals.
'			Results of the checks will be displayed on the screen. 
' 			However, these checks are not totally comprehensive, so they may not catch all typos.
'	DONE.


'	The workfile produced by this program contains a number of vectors.
'	Each vector represents a collection of population controls released in one year. That year of release in is the name of the vector, such as popadj2016, popadj2017, etc.
'	The ORDER of vector elements is the same for all vectors. It corresponds to the concept-age-sex list contained in the string vector 'names'. 

logmode logmsg

' ***** UPDATE this section before running the program *****
!yr_latest = 2024		' latest year, pop controls for which are being added to the workfile
' BLS file containing the raw numbers for 2024:  S:\LRECON\Data\Raw\CPS\PopAdjustments\2024_Pop_effects_based_on_Dec2023.pdf


' file that holds the existing popadj factors
%old_file = "cps_popadj_2023" 	' name only
%old_file_path = "S:\LRECON\Data\Raw\CPS\PopAdjustments\CPS_PopAdj_Factors" + "\" + %old_file + ".wf1"	' full path

' file to be created by this program, with the popadj factors updated throught the !yr_latest
%new_file = "cps_popadj_" + @str(!yr_latest) 	' name only
%new_file_path = "S:\LRECON\Data\Raw\CPS\PopAdjustments\CPS_PopAdj_Factors" + "\" + %new_file + ".wf1"	' full path

' Do you want the output file(s) to be saved on this run? 
' Enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "Y" 		' enter "N" or "Y" (case sensitive)
' ***** END of update section *****
logmsg end update


' open the existing file from previous year
wfopen %old_file_path

logmsg opened old file

' delete the earlier _summary spool and spools for checks
delete _summary
delete _check_1619 
delete _check_16o 
delete _check_2554 
delete _check_total 

' number of elements in each vector = number of concept-sex-age groups.
!rows = @rows(names)

' create the new vector for year !yr_latest
%vname = "popadj" + @str(!yr_latest)
vector(!rows) {%vname}

logmsg created new vector for latest year

' populate the vector with values
' for now this is done manually; copying from the latest PDF file received from BLS ("20xx_Pop_effects_based_on_Dec20xx.pdf") ; in the future we may be able to automate it.
' ENTER NEW VALUES HERE (Notes in parentheses indicate the Table in the BLS file containing the data, although the format of these is not necessarily constant from year to year.)

'Adjustment factors for CNIPop...
{%vname}(1) = -625		'	n16o		(Table 1; also Table 2)
				
{%vname}(2) = -634		'	nm16o		(Table 1; also Table 2, total men)
{%vname}(3) = 93		'	nm1619		(Table 2, total men)
{%vname}(4) = 46		'	nm1617		(Table 2, total men)
{%vname}(5) = 46		'	nm1819		(Table 2, total men)
{%vname}(6) = -417		'	nm2024		(Table 2, total men)
{%vname}(7) = -303		'	nm2554		(Table 2, total men)
{%vname}(8) = -219		'	nm2534		(Table 2, total men)
{%vname}(9) = -10		'	nm3544		(Table 2, total men)
{%vname}(10) = -74		'	nm4554		(Table 2, total men)
{%vname}(11) = 22		'	nm5564		(Table 2, total men)
{%vname}(12) = -28		'	nm65o		(Table 2, total men)
				
{%vname}(13) = 9		'	nf16o		(Table 1; also Table 2, total women)
{%vname}(14) = 102		'	nf1619		(Table 2, total women)
{%vname}(15) = 57		'	nf1617		(Table 2, total women)
{%vname}(16) = 46		'	nf1819		(Table 2, total women)
{%vname}(17) = -399	'	nf2024		(Table 2, total women)
{%vname}(18) = 466		'	nf2554		(Table 2, total women)
{%vname}(19) = 96		'	nf2534		(Table 2, total women)
{%vname}(20) = 213		'	nf3544		(Table 2, total women)
{%vname}(21) = 158		'	nf4554		(Table 2, total women)
{%vname}(22) = 174		'	nf5564		(Table 2, total women)
{%vname}(23) = -334	'	nf65o		(Table 2, total women)
				
				
'Adjustment factors for Labor force...
{%vname}(24) = -298	'	l16o		(Table 1)
				
{%vname}(25) = -503	'	lm16o		(Table 1; also Table 2, total men)
{%vname}(26) = 33		'	lm1619		(Table 2, total men)
{%vname}(27) = 11		'	lm1617		(Table 2, total men)
{%vname}(28) = 23		'	lm1819		(Table 2, total men)
{%vname}(29) = -294	'	lm2024		(Table 2, total men)
{%vname}(30) = -265	'	lm2554		(Table 2, total men)
{%vname}(31) = 190		'	lm2534		(Table 2, total men)
{%vname}(32) = -8	   '	lm3544		(Table 2, total men)
{%vname}(33) = -66		'	lm4554		(Table 2, total men)
{%vname}(34) = 14	   '	lm5564		(Table 2, total men)
{%vname}(35) = 9		'	lm65o		(Table 2, total men)
				
{%vname}(36) = 205		'	lf16o		(Table 1; also Table 2, total women)
{%vname}(37) = 35		'	lf1619		(Table 2, total women)
{%vname}(38) = 16		'	lf1617		(Table 2, total women)
{%vname}(39) = 20		'	lf1819		(Table 2, total women)
{%vname}(40) = -282	'	lf2024		(Table 2, total women)
{%vname}(41) = 356		'	lf2554		(Table 2, total women)
{%vname}(42) = 72		'	lf2534		(Table 2, total women)
{%vname}(43) = 164		'	lf3544		(Table 2, total women)
{%vname}(44) = 120		'	lf4554		(Table 2, total women)
{%vname}(45) = 105		'	lf5564		(Table 2, total women)
{%vname}(46) = -10	   '	lf65o		(Table 2, total women)
				
				
'Adjustment factors for Employed...
{%vname}(47) = -270	'	e16o		(Table 1)
				
{%vname}(48) = -477	'	em16o		(Table 1; also Table 2, total men)
{%vname}(49) = 30		'	em1619		(Table 2, total men)
{%vname}(50) = 9		'	em1617		(Table 2, total men)
{%vname}(51) = 21		'	em1819		(Table 2, total men)
{%vname}(52) = -276	'	em2024		(Table 2, total men)
{%vname}(53) = -253	'	em2554		(Table 2, total men)
{%vname}(54) = -178	'	em2534		(Table 2, total men)
{%vname}(55) = -9	   '	em3544		(Table 2, total men)
{%vname}(56) = -65		'	em4554		(Table 2, total men)
{%vname}(57) = 13		'	em5564		(Table 2, total men)
{%vname}(58) = 8	   '	em65o		(Table 2, total men)
				
{%vname}(59) = 207		'	ef16o		(Table 1; also Table 2, total women)
{%vname}(60) = 32		'	ef1619		(Table 2, total women)
{%vname}(61) = 14	   '	ef1617		(Table 2, total women)
{%vname}(62) = 18		'	ef1819		(Table 2, total women)
{%vname}(63) = -264	'	ef2024		(Table 2, total women)
{%vname}(64) = 347		'	ef2554		(Table 2, total women)
{%vname}(65) = 70		'	ef2534		(Table 2, total women)
{%vname}(66) = 159		'	ef3544		(Table 2, total women)
{%vname}(67) = 118		'	ef4554		(Table 2, total women)
{%vname}(68) = 102		'	ef5564		(Table 2, total women)
{%vname}(69) = -10		'	ef65o		(Table 2, total women)
				

'Adjustment factors for Unemployment rate...				
{%vname}(70) = -0		'	r16o
				
{%vname}(71) = -0		'	rm16o		(The values for r* series and p*series are also in coresponding pages on Table 2 in columns labeled ' percent of labor force' and 'percent of population'. population"
{%vname}(72) = -0		'	rm1619
{%vname}(73) = 0		'	rm1617
{%vname}(74) = -0		'	rm1819
{%vname}(75) = -0		'	rm2024
{%vname}(76) = -0		'	rm2554
{%vname}(77) = -0		'	rm2534
{%vname}(78) = 0		'	rm3544
{%vname}(79) = 0		'	rm4554
{%vname}(80) = -0		'	rm5564
{%vname}(81) = 0		'	rm65o
				
{%vname}(82) = -0		'	rf16o
{%vname}(83) = -0		'	rf1619
{%vname}(84) = -0		'	rf1617
{%vname}(85) = 0		'	rf1819
{%vname}(86) = -0		'	rf2024
{%vname}(87) = -0		'	rf2554
{%vname}(88) = -0		'	rf2534
{%vname}(89) = 0		'	rf3544
{%vname}(90) = -0		'	rf4554
{%vname}(91) = 0		'	rf5564
{%vname}(92) = 0		'	rf65o
				
					
'Adjustment factors for Labor force participation rate...	
{%vname}(93) = 0.0		'	p16o
				
{%vname}(94) = -0.1	'	pm16o
{%vname}(95) =  0	   '	pm1619
{%vname}(96) = -0	   '	pm1617
{%vname}(97) =  0	   '	pm1819
{%vname}(98) = -0		'	pm2024
{%vname}(99) =  0		'	pm2554
{%vname}(100) = 0		'	pm2534
{%vname}(101) = 0		'	pm3544
{%vname}(102) = -0		'	pm4554
{%vname}(103) = -0		'	pm5564
{%vname}(104) = 0.1	'	pm65o
				
{%vname}(105) = 0.1	'	pf16o
{%vname}(106) = -0		'	pf1619
{%vname}(107) =  0		'	pf1617
{%vname}(108) = -0	   '	pf1819
{%vname}(109) = -0		'	pf2024
{%vname}(110) = -0		'	pf2554
{%vname}(111) = -0		'	pf2534
{%vname}(112) = -0		'	pf3544
{%vname}(113) =  0		'	pf4554
{%vname}(114) =  0		'	pf5564
{%vname}(115) = 0.1	'	pf65o

logmsg populated new vector for latest year

' 	some consistency checks
' (1) make sure that the NUMBER OF ELEMENTS is the same across all popadjYEAR vectors
!rows_ck = @rows(names)
for !i = 2003 to !yr_latest
	%y = @str(!i)
	if @rows(popadj{%y})<>!rows_ck then
		string _warning = "WARNING!!! Incorrect vector length for popadj" + %y + "! Please check the assignment statements in the program."
		show _warning
	endif
next

logmsg ended consistency check 1


' (2) Both sexes add up to totals
spool _check_total
%ln1 = "CHECK: " + names(2) + " + " + names(13) + " = " + names(1) ' nm16o + nf16o = n16o"
%ln2 = @str({%vname}(2)) + " + " + @str({%vname}(13)) + " =? " + @str({%vname}(1))
if {%vname}(2) + {%vname}(13)  - {%vname}(1) = 0 then %ln3 = "OK"
	else 		
		!temp = {%vname}(2) + {%vname}(13)
		%ln3 = "FAILED!!! " + names(2) + " + " + names(13) + " = " + @str(!temp) + " vs " + @str({%vname}(1)) + " for " + names(1) +". Please check values for " + names(2) + ", " + names(13) + ", " + names(1) + " (small differences may be due to rounding)."
endif

string line1 = %ln1 + @chr(13) + %ln2 + @chr(13) + %ln3 

%ln1 = "CHECK: " + names(25) + " + " + names(36) + " = " + names(24) 'lm16o + lf16o = l16o"
%ln2 = @str({%vname}(25)) + " + " + @str({%vname}(36)) + " =? " + @str({%vname}(24))
if {%vname}(25) + {%vname}(36)  - {%vname}(24) = 0 then %ln3 = "OK"
	else 
		!temp = {%vname}(25) + {%vname}(36)
		%ln3 = "FAILED!!! " + names(25) + " + " + names(36) + " = " + @str(!temp) + " vs " + @str({%vname}(24)) + " for " + names(24) + ". Please check values for " + names(25) + ", " + names(36) + ", " + names(24) + " (small differences may be due to rounding)."
endif

string line2 = %ln1 + @chr(13) + %ln2 + @chr(13) + %ln3 

%ln1 = "CHECK: " + names(48) + " + " + names(59) + " = " + names(47) ' em16o + ef16o = e16o"
%ln2 = @str({%vname}(48)) + " + " + @str({%vname}(59)) + " =? " + @str({%vname}(47))
if {%vname}(48) + {%vname}(59)  - {%vname}(47) = 0 then %ln3 = "OK"
	else 
		!temp = {%vname}(48) + {%vname}(59)
		%ln3 = "FAILED!!! " + names(48) + " + " + names(59) + " = " + @str(!temp) + " vs " + @str({%vname}(47)) + " for " + names(47) + ". Please check values for " + names(48) + ", " + names(59) + ", " + names(47) + " (small differences may be due to rounding)."
endif

string line3 = %ln1 + @chr(13) + %ln2 + @chr(13) + %ln3 

_check_total.insert line1 line2 line3 'line4 line5 line6 line7 line8 line9 'line10 line11 line12 'line13
_check_total.display
delete line*

logmsg ended consistency check 2

' (3) Age groups add up to totals
' this loop checks that *1617+*1819 = *1619 for *=nm, nf, lm, lf, em, ef.
spool _check_1619
!i = 1
for %t  3 14 26 37 49 60
	!t1 = @val(%t)
	!t2 = !t1 +1
	!t3 = !t1+2
	%ln1 = "CHECK: " +@chr(13) + names(!t2) + " + " + names(!t3) + " = " + names(!t1)
	%ln2 = @str({%vname}(!t2)) + " + " + @str({%vname}(!t3)) + " =? " + @str({%vname}(!t1))
	if {%vname}(!t2) + {%vname}(!t3)  - {%vname}(!t1) = 0 then %ln3 = "OK"
	else 
		!temp = {%vname}(!t2) + {%vname}(!t3)
		%ln3 = "FAILED!!! " + names(!t2) + " + " + names(!t3) + " = " + @str(!temp) + " vs " + @str({%vname}(!t1)) + " for " + names(!t1) + ". Please check values for " + names(!t2) + ", " + names(!t3) + ", " + names(!t1) + " (small differences may be due to rounding)."
	endif
	string line{!i} = %ln1 + @chr(13) + %ln2 + @chr(13) + %ln3 
	!i = !i +1
next
_check_1619.insert line1 line2 line3 line4 line5 line6 'line7 line8 line9 line10 line11 line12 'line13 line14 line15 line16 line17 line18
_check_1619.display
delete line*

logmsg ended consistency check 3a

' this loop checks that *2534+*3544 + *4554 = *2554 for *=nm, nf, lm, lf, em, ef.
spool _check_2554
!i = 1
for %t  7 18 30 41 53 64
	!t1 = @val(%t)
	!t2 = !t1 +1
	!t3 = !t1+2
	!t4 = !t1+3
	%ln1 = "CHECK: " +@chr(13) + names(!t2) + " + " + names(!t3) + " + " + names(!t4) + " = " + names(!t1)
	%ln2 = @str({%vname}(!t2)) + " + " + @str({%vname}(!t3)) + " + " + @str({%vname}(!t4)) + " =? " + @str({%vname}(!t1))
	if {%vname}(!t2) + {%vname}(!t3) + {%vname}(!t4)  - {%vname}(!t1) = 0 then %ln3 = "OK"
	else 
		!temp = {%vname}(!t2) + {%vname}(!t3) + {%vname}(!t4)
		%ln3 = "FAILED!!! " + names(!t2) + " + " + names(!t3) + " + " + names(!t4) + " = " + @str(!temp) + " vs " + @str({%vname}(!t1)) + " for " + names(!t1) + ". Please check values for " + names(!t2) + ", " + names(!t3) + ", " + names(!t4)+ ", " + names(!t1) + " (small differences may be due to rounding)."
	endif
	string line{!i} = %ln1 + @chr(13) + %ln2 + @chr(13) + %ln3 
	!i = !i +1
next
_check_2554.insert line1 line2 line3 line4 line5 line6 'line7 line8 line9 line10 line11 line12 'line13 line14 line15 line16 line17 line18
_check_2554.display
delete line*

logmsg ended consistency check 3b

' this loop checks that *1619+*2024 + *2554 + *5564 + *65o = *16o for *=nm, nf, lm, lf, em, ef.
spool _check_16o
!i = 1
for %t  2 13 25 36 48 59
	!t1 = @val(%t)
	!t2 = !t1 +1
	!t3 = !t1+4
	!t4 = !t1+5
	!t5 = !t1+9
	!t6 = !t1+10
	%ln1 = "CHECK: " +@chr(13) + names(!t2) + " + " + names(!t3) + " + " + names(!t4) + " + " + names(!t5) + " + " + names(!t6) + " = " + names(!t1)
	%ln2 = @str({%vname}(!t2)) + " + " + @str({%vname}(!t3)) + " + " + @str({%vname}(!t4)) + " + " + @str({%vname}(!t5)) + " + " + @str({%vname}(!t6)) + " =? " + @str({%vname}(!t1))
	if {%vname}(!t2) + {%vname}(!t3) + {%vname}(!t4) + {%vname}(!t5) + {%vname}(!t6)  - {%vname}(!t1) = 0 then %ln3 = "OK"
	else 
		!temp = {%vname}(!t2) + {%vname}(!t3) + {%vname}(!t4) + {%vname}(!t5) + {%vname}(!t6)
		%ln3 = "FAILED!!! " + names(!t2) + " + " + names(!t3) + " + " + names(!t4) + " + " + names(!t5) + " + " + names(!t6) + " = " + @str(!temp) + " vs " + @str({%vname}(!t1)) + " for " + names(!t1) + ". Please check values for " + names(!t2) + ", " + names(!t3) + ", " + names(!t4) + " , " + names(!t5) + " , " + names(!t6) + ", " + names(!t1) + " (small differences may be due to rounding)."
	endif
	string line{!i} = %ln1 + @chr(13) + %ln2 + @chr(13) + %ln3 
	!i = !i +1
next
_check_16o.insert line1 line2 line3 line4 line5 line6 'line7 line8 line9 line10 line11 line12 'line13 line14 line15 line16 line17 line18
_check_16o.display
delete line*

logmsg ended consistency check 3c

'		make summary spool
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The file contains CPS population adjustment factors, which BLS publishes each January."
string line3 = "The file contains a vector of population adjustment factors for each year from 2003 to " + @str(!yr_latest) + "."
string line4 = "The vector names indicate the year the adjustment factors contained in them were published -- e.g. popadj2004 contains population controls published by BLS in Jan 2004."
string line5 = "The order of elements in all vectors is the same and corresponds to the concept-sex-age groups listed in the string vector called 'names'."
string line6 = "Several checks are performed on the values in the vectors. Please see the spools named _check_****."
string line7 = "In the future years, population adjustment factors should be entered into a vector named with the appropriate year IN THE SAME ORDER (indicated by 'names')."
string line8 = "These vectors are used by program bls_popadjust_all.prg to create population series that are adjusted for BLS population controls and thus compatible across time."

%userpin = @env("USERNAME")

_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 'line9 'line10 line11 line12 'line13
_summary.display

delete line*

'	save the workfile
if %sav = "Y" then
	wfsave(2) %new_file_path 
endif


