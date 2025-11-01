' This program estimates regression coefficients for RU business cycle equations.
' the estimated equations are later used in MODSOL1 to create projected values.

'********** Polina Vlasenko 
'********** 5/31/2019



' ******** UPDATE inputs here *******

%bkdo1 = "bkdo1.bnk" ' "bkdo1_20090917"
%bkdo1_path = "E:\usr\econ\EcoDev\dat\bkdo1.bnk" '"\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1\bkdo1_20090917.bnk" 	' bkdo1 bank from  09/17/2009. This should remain UNCHANGED.

' Relevant time periods
%hist_start = "1976Q1"		' first period of historical data used to estimate equations
%hist_end = "2018Q3" '"2008Q4"		' last period of historical data used to estimate equations

' output created by this program
%this_file = "ru_eqns" 	' name of the file 
%output_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1" + "\" + %this_file + ".wf1"

'save option
' Do you want the output file(s) to be saved on this run? 
' Enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "N" 		' enter "N" or "Y" 

' ******* END of update section

'%TRyr = @str(!TRyr) 	' string version of TRyr

wfcreate(wf={%this_file}, page=q) q 1900Q2 2099Q4
pageselect q

' Retrieve the historical data from the BKDO1 bank
smpl {%hist_start} {%hist_end}
dbopen(type=aremos) {%bkdo1_path} 
fetch rtp.q minw.q ru.q

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      fetch r{%s}{%a}.q 
   next
next

close @db

' Estimate regression coefficients for aggregate and A/S groups:
' d(RU) = k0 * d(RTP) + k1 * d(RTP(-1)) + k2 * d(RTP(-2)) + k3 * d(RTP(-3))

equation eq_dru.ls d(ru) d(rtp) d(rtp(-1)) d(rtp(-2)) d(rtp(-3)) 'c

' Teenage groups include minimum wage and its 3 lags
for %a 1617 1819
   for %s m f
      equation eq_dr{%s}{%a}.ls d(r{%s}{%a}) d(rtp) d(rtp(-1)) d(rtp(-2)) d(rtp(-3)) '_
        ' minw minw(-1) minw(-2) minw(-3) c
        ' equation eq_dr{%s}{%a}_nc.ls d(r{%s}{%a}) d(rtp) d(rtp(-1)) d(rtp(-2)) d(rtp(-3)) 
   next
next

for %a 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      equation eq_dr{%s}{%a}.ls d(r{%s}{%a}) d(rtp) d(rtp(-1)) d(rtp(-2)) d(rtp(-3)) 'c
      'equation eq_dr{%s}{%a}_nc.ls d(r{%s}{%a}) d(rtp) d(rtp(-1)) d(rtp(-2)) d(rtp(-3))
   next
next
'rename rtp rtp_bkdo1 'rtp2009

'all dru**** equations are now estimated


'		make summary spool
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The file contains estimated equations for dRUs by age and sex."
string line3 = "The estimation uses the data from " + %bkdo1_path
string line4 = "Polina Vlasenko"

_summary.insert line1 line2 line3 line4 'line5 'line6 line7 line8 line9 line10 line11 line12 line13

if %sav = "Y" then
	wfsave(2) %output_path ' saves the workfile
endif

delete line*

'close {%thisfile} 'close the workfile; comment this out if need to keep the workfile open




stop
' the code below is the remnant from the predicted RUs I did for LFPR paper







'Create fitted (predicted) values for ALL dru**** series. 

'load data for independent variables
dbopen(type=aremos) {%dbank}  
smpl 1947 2099
fetch minw {%rgdp} k{%rgdp}
close @db
genr rtp = {%rgdp}/k{%rgdp}


'compute the predicted values (remember different functional form for 1617 and 1819 groups)
'NO need to do this; instead use .forecast function in EViews
'for %a 1617 1819
'   for %s m f
'      genr dr{%s}{%a}_p = 	d(rtp)*dr{%s}{%a}.@coefs(1) + _
'      								d(rtp(-1))*dr{%s}{%a}.@coefs(2) + _
'      								d(rtp(-2))*dr{%s}{%a}.@coefs(3) + _
'      								d(rtp(-3))*dr{%s}{%a}.@coefs(4) + _
'      								minw*dr{%s}{%a}.@coefs(5) + _
'      								minw(-1)*dr{%s}{%a}.@coefs(6) + _
'      								minw(-2)*dr{%s}{%a}.@coefs(7) + _
'      								minw(-3)*dr{%s}{%a}.@coefs(8) + _
'      								dr{%s}{%a}.@coefs(9)
'   next
'next

'for %a 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'   for %s m f
'   	   genr dr{%s}{%a}_p = 	d(rtp)*dr{%s}{%a}.@coefs(1) + _
'      								d(rtp(-1))*dr{%s}{%a}.@coefs(2) + _
'      								d(rtp(-2))*dr{%s}{%a}.@coefs(3) + _
'      								d(rtp(-3))*dr{%s}{%a}.@coefs(4) + _
'      								dr{%s}{%a}.@coefs(5)
'   next
'next

'predicted values will use different value for RUs -- from the latest databank. Thus need to remove the rf**** and rm*** series currently in the workfile. 
'Can delete them or rename them
'for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'   	for %s m f
'	 	rename r{%s}{%a} r{%s}{%a}_2009
'	next
'next



'download the latest ru**** series
delete rf* rm*	' delete the old ones from 2009 databanks that we used for above estimation

dbopen(type=aremos) {%dbank}  
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      fetch r{%s}{%a} 	
   next
next
close @db

'create empty series where the predicted value will be stored
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   	for %s m f
	 	series r{%s}{%a}_p 
	next
next

'extend minw series 
smpl 2017Q1 {%TRyr}Q4 
minw=7.25
smpl @all

'create forecasted values
for !yr=1999 to !TRyr-2 
	%start = @str(!yr)+"Q4"
	%start2 = @str(!yr+1)+"Q1"
	%end = @str(!yr+1)+"Q4"
	smpl {%start} {%end}
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
	   	for %s m f
     		 	dr{%s}{%a}.forecast(f=na) r{%s}{%a}_for	 'create predicted values
     		next
	next
	
	smpl {%start2} {%end}
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
	   	for %s m f
     		 	r{%s}{%a}_p = r{%s}{%a}_for 'copy predicted values to separate series before moving to the next sample period
     		next
	next
next

smpl @all
delete *_for

'copy predicted values to annual frequency in the new workfile page
pagecreate(page=annual) a 1999 !TRyr		
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   	for %s m f
	 	copy q\r{%s}{%a}_p * 
	next
next

pageselect annual

'create a spool that contains summary info for the run
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "This file contains model-predicted unemployment rates by age and sex (series ending in ..._p in page annual)."
string line3 = "Estimated equations for the unemployment rates (RUs) are loacted in page q."
string line4 = "In this run the model-predicted RUs are based on TR" + %TRyr
string line5 = "The program uses the following inputs:"
string line6 = "To estimate RU equations -- BKDO1 bank from 9/17/2009 located at " + %bkdo1
string line7 = "To projecte predicted values using RU equation -- data from d-bank located at " + %dbank
string line8 = "Polina Vlasenko"

_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 
_summary.display

delete line*

'wfsave(2) %output_path


