' This program is modifed to read data for the LATEST YAER ONLY directly from the CSV files downloaded from MDAT (such as mar2022-lc.csv and mar2022-pop.csv)
' The program assumes there already exists workfile named education.wf1 that holds data for the earlier years.
' The program appends new data to this existing file and saves the updated file with the same name.
' Make sure to preserve education.wf1 file every year as it will be needed as the starting point of each TR's update.
' 
' PV -- 07-28-2023

'Update information listed in ***UPDATE section below

'********* UPDATE here

' MAKE SURE that education.wf1 exists in the default location; this is the file to which we will append new data

!yr_last = 2024	' the year, data for which we are appending to the file

' folder where the CSV files with raw data are located
%path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Raw\MarchCPS\EducationalAttainment"
' NOTE1:	 	the program assumes that the folder named above contains two file named EXACTLY like this
'				mar2023-lc.csv
' 				mar2023-pop.csv [where '2023' is replaced by !yr_last above]
' 				These are the files loaded from Census MDAT
' 				If the filenames are different for some reason, adjust the code below

' NOTE2: 	this program assumes there exist education.wf1 in the DEFAULT location. 
' 			It will update it with data for year !yr_last and save the updated version with the same name.
' 			MAKE SURE the default location is what you intend it to be!!!
'			If education.wf1 already exists in the default location, it will be overwritten. 
'			If education.wf1 does not exist in the default location, the program will crash. 
' 				You must locate the version of education.wf1 used in the prior TR (try econ-budget repo) 
' 				and copy it to the default location before running this program.
' 				Make sure education.wf1 file is NOT read-only
' 				Then remember to copy the updated education.wf1 back into econ-budget once the program is run.

'********* END of update section

'exec .\setup2
wfopen education.wf1 	' education.wf1 file from the prior TR year; it must contain data up to but not including !yr_last
pageselect a
smpl @all

logmode logmsg

logmode l
%msg = "Running ededucattainment.prg" 
logmsg {%msg}
logmsg

tic

'loading data from Excel

%msg = "Loading raw data for year " + @str(!yr_last) + " ... this may take a few minutes" 
logmsg {%msg}
logmsg

' Load population data (and re-scale)

%msg = "Population data ..." 
logmsg {%msg}

%file = %path + "\" + "mar" + @str(!yr_last) + "-pop.csv"

importmat(name=pop) %file		' impoart ALL data in the CSV file as a matrix object

pageselect a
smpl !yr_last !yr_last 	' updating values only for the latest year

' set all 16+ series to zero; we will cumulatively add values to them below
for %ed nohsg hsgrad col1t3 col4 col5o
	for %s m f 
		n{%s}16oe{%ed} = 0
	next
next

for !a=16 to 79
	!row = !a - 14
	' No HS, men
	nm{!a}enohsg = pop(!row,4) / 1000000		' load value for each age
	nm16oenohsg = nm16oenohsg + nm{!a}enohsg	' cumulate for 16+
	' HS grad, men
	nm{!a}ehsgrad = pop(!row,5) / 1000000
	nm16oehsgrad = nm16oehsgrad + nm{!a}ehsgrad
	' some college, men
	nm{!a}ecol1t3 = pop(!row,6) / 1000000
	nm16oecol1t3 = nm16oecol1t3 + nm{!a}ecol1t3
	' college degree, men
	nm{!a}ecol4 = pop(!row,7) / 1000000
	nm16oecol4 = nm16oecol4 + nm{!a}ecol4
	' poast gradute, men
	nm{!a}ecol5o = pop(!row,8) / 1000000
	nm16oecol5o = nm16oecol5o + nm{!a}ecol5o
	
	' No HS, women
	nf{!a}enohsg = pop(!row,10) / 1000000		' load value for each age
	nf16oenohsg = nf16oenohsg + nf{!a}enohsg	' cumulate for 16+
	' HS grad, women
	nf{!a}ehsgrad = pop(!row,11) / 1000000
	nf16oehsgrad = nf16oehsgrad + nf{!a}ehsgrad
	' some college, women
	nf{!a}ecol1t3 = pop(!row,12) / 1000000
	nf16oecol1t3 = nf16oecol1t3 + nf{!a}ecol1t3
	' college degree, women
	nf{!a}ecol4 = pop(!row,13) / 1000000
	nf16oecol4 = nf16oecol4 + nf{!a}ecol4
	' poast gradute, women
	nf{!a}ecol5o = pop(!row,14) / 1000000
	nf16oecol5o = nf16oecol5o + nf{!a}ecol5o

next

nm80oenohsg = (pop(!row+1,4) + pop(!row+2,4) + pop(!row+3,4) + pop(!row+4,4) + pop(!row+5,4) + pop(!row+6,4)) / 1000000
nm16oenohsg = nm16oenohsg + nm80oenohsg

nm80oehsgrad = (pop(!row+1,5) + pop(!row+2,5) + pop(!row+3,5) + pop(!row+4,5) + pop(!row+5,5) + pop(!row+6,5)) / 1000000
nm16oehsgrad = nm16oehsgrad + nm80oehsgrad

nm80oecol1t3 = (pop(!row+1,6) + pop(!row+2,6) + pop(!row+3,6) + pop(!row+4,6) + pop(!row+5,6) + pop(!row+6,6)) / 1000000
nm16oecol1t3 = nm16oecol1t3 + nm80oecol1t3

nm80oecol4 = (pop(!row+1,7) + pop(!row+2,7) + pop(!row+3,7) + pop(!row+4,7) + pop(!row+5,7) + pop(!row+6,7)) / 1000000
nm16oecol4 = nm16oecol4 + nm80oecol4

nm80oecol5o = (pop(!row+1,8) + pop(!row+2,8) + pop(!row+3,8) + pop(!row+4,8) + pop(!row+5,8) + pop(!row+6,8)) / 1000000
nm16oecol5o = nm16oecol5o + nm80oecol5o

nf80oenohsg = (pop(!row+1,10) + pop(!row+2,10) + pop(!row+3,10) + pop(!row+4,10) + pop(!row+5,10) + pop(!row+6,10)) / 1000000
nf16oenohsg = nf16oenohsg + nf80oenohsg

nf80oehsgrad = (pop(!row+1,11) + pop(!row+2,11) + pop(!row+3,11) + pop(!row+4,11) + pop(!row+5,11) + pop(!row+6,11)) / 1000000
nf16oehsgrad = nf16oehsgrad + nf80oehsgrad

nf80oecol1t3 = (pop(!row+1,12) + pop(!row+2,12) + pop(!row+3,12) + pop(!row+4,12) + pop(!row+5,12) + pop(!row+6,12)) / 1000000
nf16oecol1t3 = nf16oecol1t3 + nf80oecol1t3

nf80oecol4 = (pop(!row+1,13) + pop(!row+2,13) + pop(!row+3,13) + pop(!row+4,13) + pop(!row+5,13) + pop(!row+6,13)) / 1000000
nf16oecol4 = nf16oecol4 + nf80oecol4

nf80oecol5o = (pop(!row+1,14) + pop(!row+2,14) + pop(!row+3,14) + pop(!row+4,14) + pop(!row+5,14) + pop(!row+6,14)) / 1000000
nf16oecol5o = nf16oecol5o + nf80oecol5o

%msg = "done." 
logmsg {%msg}
logmsg



' Load labor force data (and re-scale)

%msg = "Labor force data ..." 
logmsg {%msg}

%file = %path + "\" + "mar" + @str(!yr_last) + "-lc.csv"

importmat(name=lc) %file		' impoart ALL data in the CSV file as a matrix object

pageselect a
smpl !yr_last !yr_last 	' updating values only for the latest year

' set all 16+ series to zero; we will cumulatively add values to them below
for %ed nohsg hsgrad col1t3 col4 col5o
	for %s m f 
		l{%s}16oe{%ed} = 0
	next
next

for !a=16 to 79
	!row = !a - 14
	' No HS, men
	lm{!a}enohsg = lc(!row,4) / 1000000		' load value for each age
	lm16oenohsg = lm16oenohsg + lm{!a}enohsg	' cumulate for 16+
	' HS grad, men
	lm{!a}ehsgrad = lc(!row,5) / 1000000
	lm16oehsgrad = lm16oehsgrad + lm{!a}ehsgrad
	' some college, men
	lm{!a}ecol1t3 = lc(!row,6) / 1000000
	lm16oecol1t3 = lm16oecol1t3 + lm{!a}ecol1t3
	' college degree, men
	lm{!a}ecol4 = lc(!row,7) / 1000000
	lm16oecol4 = lm16oecol4 + lm{!a}ecol4
	' poast gradute, men
	lm{!a}ecol5o = lc(!row,8) / 1000000
	lm16oecol5o = lm16oecol5o + lm{!a}ecol5o
	
	' No HS, women
	lf{!a}enohsg = lc(!row,10) / 1000000		' load value for each age
	lf16oenohsg = lf16oenohsg + lf{!a}enohsg	' cumulate for 16+
	' HS grad, women
	lf{!a}ehsgrad = lc(!row,11) / 1000000
	lf16oehsgrad = lf16oehsgrad + lf{!a}ehsgrad
	' some college, women
	lf{!a}ecol1t3 = lc(!row,12) / 1000000
	lf16oecol1t3 = lf16oecol1t3 + lf{!a}ecol1t3
	' college degree, women
	lf{!a}ecol4 = lc(!row,13) / 1000000
	lf16oecol4 = lf16oecol4 + lf{!a}ecol4
	' poast gradute, women
	lf{!a}ecol5o = lc(!row,14) / 1000000
	lf16oecol5o = lf16oecol5o + lf{!a}ecol5o

next

lm80oenohsg = (lc(!row+1,4) + lc(!row+2,4) + lc(!row+3,4) + lc(!row+4,4) + lc(!row+5,4) + lc(!row+6,4)) / 1000000
lm16oenohsg = lm16oenohsg + lm80oenohsg

lm80oehsgrad = (lc(!row+1,5) + lc(!row+2,5) + lc(!row+3,5) + lc(!row+4,5) + lc(!row+5,5) + lc(!row+6,5)) / 1000000
lm16oehsgrad = lm16oehsgrad + lm80oehsgrad

lm80oecol1t3 = (lc(!row+1,6) + lc(!row+2,6) + lc(!row+3,6) + lc(!row+4,6) + lc(!row+5,6) + lc(!row+6,6)) / 1000000
lm16oecol1t3 = lm16oecol1t3 + lm80oecol1t3

lm80oecol4 = (lc(!row+1,7) + lc(!row+2,7) + lc(!row+3,7) + lc(!row+4,7) + lc(!row+5,7) + lc(!row+6,7)) / 1000000
lm16oecol4 = lm16oecol4 + lm80oecol4

lm80oecol5o = (lc(!row+1,8) + lc(!row+2,8) + lc(!row+3,8) + lc(!row+4,8) + lc(!row+5,8) + lc(!row+6,8)) / 1000000
lm16oecol5o = lm16oecol5o + lm80oecol5o

lf80oenohsg = (lc(!row+1,10) + lc(!row+2,10) + lc(!row+3,10) + lc(!row+4,10) + lc(!row+5,10) + lc(!row+6,10)) / 1000000
lf16oenohsg = lf16oenohsg + lf80oenohsg

lf80oehsgrad = (lc(!row+1,11) + lc(!row+2,11) + lc(!row+3,11) + lc(!row+4,11) + lc(!row+5,11) + lc(!row+6,11)) / 1000000
lf16oehsgrad = lf16oehsgrad + lf80oehsgrad

lf80oecol1t3 = (lc(!row+1,12) + lc(!row+2,12) + lc(!row+3,12) + lc(!row+4,12) + lc(!row+5,12) + lc(!row+6,12)) / 1000000
lf16oecol1t3 = lf16oecol1t3 + lf80oecol1t3

lf80oecol4 = (lc(!row+1,13) + lc(!row+2,13) + lc(!row+3,13) + lc(!row+4,13) + lc(!row+5,13) + lc(!row+6,13)) / 1000000
lf16oecol4 = lf16oecol4 + lf80oecol4

lf80oecol5o = (lc(!row+1,14) + lc(!row+2,14) + lc(!row+3,14) + lc(!row+4,14) + lc(!row+5,14) + lc(!row+6,14)) / 1000000
lf16oecol5o = lf16oecol5o + lf80oecol5o

%msg = "done." 
logmsg {%msg}
logmsg

%msg = "Done loading raw data from CSV files." 
logmsg {%msg}
logmsg


' Compute various useful measures (aggregate etc.)

pageselect a
smpl 1992 !yr_last

%msg = "Computing aggregates..." 
logmsg {%msg}

for %s m f
   for !a = 16 to 79
      genr l{%s}{!a}e = l{%s}{!a}enohsg  _
                      + l{%s}{!a}ehsgrad _
                      + l{%s}{!a}ecol1t3 _
                      + l{%s}{!a}ecol4   _
                      + l{%s}{!a}ecol5o

 	  genr n{%s}{!a}e = n{%s}{!a}enohsg  _
                      + n{%s}{!a}ehsgrad _
                      + n{%s}{!a}ecol1t3 _
                      + n{%s}{!a}ecol4   _
                      + n{%s}{!a}ecol5o
   next
next

for %s m f
   for %a 80o 16o
      genr l{%s}{%a}e = l{%s}{%a}enohsg  _
                      + l{%s}{%a}ehsgrad _
                      + l{%s}{%a}ecol1t3 _
                      + l{%s}{%a}ecol4   _
                      + l{%s}{%a}ecol5o

 	 genr n{%s}{%a}e = n{%s}{%a}enohsg  _
                      + n{%s}{%a}ehsgrad _
                      + n{%s}{%a}ecol1t3 _
                      + n{%s}{%a}ecol4   _
                      + n{%s}{%a}ecol5o
   next
next


' Create participation series p.....
%msg = "Computing participation rates..." 
logmsg {%msg}

for %s m f
   for !a = 16 to 79
      for %e nohsg hsgrad col1t3 col4 col5o
         genr denom = @recode(n{%s}{!a}e{%e}<>0, n{%s}{!a}e{%e},na)
         genr p{%s}{!a}e{%e} = l{%s}{!a}e{%e} / denom
      next
   next
next

for %s m f
   for %a 80o 16o
      for %e nohsg hsgrad col1t3 col4 col5o
         genr p{%s}{%a}e{%e} = l{%s}{%a}e{%e} / n{%s}{%a}e{%e}
      next
   next
next


for %s m f
   for !a = 16 to 79
      genr p{%s}{!a}e = l{%s}{!a}e / n{%s}{!a}e
   next
next

for %s m f
   for %a 80o 16o
      genr p{%s}{%a}e = l{%s}{%a}e / n{%s}{%a}e
   next
next

%msg = "Done" 
logmsg {%msg}
logmsg


' Create 5y age groups
%msg = "Creating 5yr age groups..." 
logmsg {%msg}

for %t n l
   for %s m f
      for %e nohsg hsgrad col1t3 col4 col5o
         genr {%t}{%s}1617e{%e} = {%t}{%s}16e{%e} + {%t}{%s}17e{%e}
         genr {%t}{%s}1819e{%e} = {%t}{%s}18e{%e} + {%t}{%s}19e{%e}
         genr {%t}{%s}2024e{%e} = {%t}{%s}20e{%e} + {%t}{%s}21e{%e} + {%t}{%s}22e{%e} + {%t}{%s}23e{%e} + {%t}{%s}24e{%e}
         genr {%t}{%s}2529e{%e} = {%t}{%s}25e{%e} + {%t}{%s}26e{%e} + {%t}{%s}27e{%e} + {%t}{%s}28e{%e} + {%t}{%s}29e{%e}
         genr {%t}{%s}3034e{%e} = {%t}{%s}30e{%e} + {%t}{%s}31e{%e} + {%t}{%s}32e{%e} + {%t}{%s}33e{%e} + {%t}{%s}34e{%e}
         
         genr {%t}{%s}3539e{%e} = {%t}{%s}35e{%e} + {%t}{%s}36e{%e} + {%t}{%s}37e{%e} + {%t}{%s}38e{%e} + {%t}{%s}39e{%e}
         genr {%t}{%s}4044e{%e} = {%t}{%s}40e{%e} + {%t}{%s}41e{%e} + {%t}{%s}42e{%e} + {%t}{%s}43e{%e} + {%t}{%s}44e{%e}
         genr {%t}{%s}4549e{%e} = {%t}{%s}45e{%e} + {%t}{%s}46e{%e} + {%t}{%s}47e{%e} + {%t}{%s}48e{%e} + {%t}{%s}49e{%e}
         genr {%t}{%s}5054e{%e} = {%t}{%s}50e{%e} + {%t}{%s}51e{%e} + {%t}{%s}52e{%e} + {%t}{%s}53e{%e} + {%t}{%s}54e{%e}
         genr {%t}{%s}5559e{%e} = {%t}{%s}55e{%e} + {%t}{%s}56e{%e} + {%t}{%s}57e{%e} + {%t}{%s}58e{%e} + {%t}{%s}59e{%e}
         genr {%t}{%s}6061e{%e} = {%t}{%s}60e{%e} + {%t}{%s}61e{%e}
         genr {%t}{%s}6264e{%e} = {%t}{%s}62e{%e} + {%t}{%s}63e{%e} + {%t}{%s}64e{%e}
         genr {%t}{%s}6064e{%e} = {%t}{%s}60e{%e} + {%t}{%s}61e{%e} + {%t}{%s}62e{%e} + {%t}{%s}63e{%e} + {%t}{%s}64e{%e}
         genr {%t}{%s}6569e{%e} = {%t}{%s}65e{%e} + {%t}{%s}66e{%e} + {%t}{%s}67e{%e} + {%t}{%s}68e{%e} + {%t}{%s}69e{%e}
         genr {%t}{%s}7074e{%e} = {%t}{%s}70e{%e} + {%t}{%s}71e{%e} + {%t}{%s}72e{%e} + {%t}{%s}73e{%e} + {%t}{%s}74e{%e}
         genr {%t}{%s}7579e{%e} = {%t}{%s}75e{%e} + {%t}{%s}76e{%e} + {%t}{%s}77e{%e} + {%t}{%s}78e{%e} + {%t}{%s}79e{%e}
         
         genr {%t}{%s}1824e{%e} = {%t}{%s}1819e{%e} + {%t}{%s}2024e{%e}
         genr {%t}{%s}2534e{%e} = {%t}{%s}2529e{%e} + {%t}{%s}3034e{%e}
         genr {%t}{%s}3544e{%e} = {%t}{%s}3539e{%e} + {%t}{%s}4044e{%e}
         genr {%t}{%s}4554e{%e} = {%t}{%s}4549e{%e} + {%t}{%s}5054e{%e}
         genr {%t}{%s}5564e{%e} = {%t}{%s}5559e{%e} + {%t}{%s}6064e{%e}
         genr {%t}{%s}6574e{%e} = {%t}{%s}6569e{%e} + {%t}{%s}7074e{%e}
         genr {%t}{%s}75oe{%e}  = {%t}{%s}7579e{%e} + {%t}{%s}80oe{%e}
      next
   next
next

for %s m f
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6064 6569 7074 7579 _
          1824 2534 3544 4554 5564 6574 75o
      genr l{%s}{%a}e = l{%s}{%a}enohsg  _
                      + l{%s}{%a}ehsgrad _
                      + l{%s}{%a}ecol1t3 _
                      + l{%s}{%a}ecol4   _
                      + l{%s}{%a}ecol5o

      genr n{%s}{%a}e = n{%s}{%a}enohsg  _
                      + n{%s}{%a}ehsgrad _
                      + n{%s}{%a}ecol1t3 _
                      + n{%s}{%a}ecol4   _
                      + n{%s}{%a}ecol5o
   next
next


' participation sereis for 5yr age groups
for %s m f
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6064 6569 7074 7579 _
          1824 2534 3544 4554 5564 6574 75o
      for %e nohsg hsgrad col1t3 col4 col5o
         genr denom = @recode(n{%s}{%a}e{%e}<>0, n{%s}{%a}e{%e},na)
         genr p{%s}{%a}e{%e} = l{%s}{%a}e{%e} / denom
      next
   next
next


for %s m f
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6064 6569 7074 7579 _
          1824 2534 3544 4554 5564 6574 75o
      genr p{%s}{%a}e = l{%s}{%a}e / n{%s}{%a}e
   next
next

%msg = "Done with 5yr age groups." 
logmsg {%msg}
logmsg

smpl @all

delete denom pop lc

%msg = "Saving the updated education.wf1." 
logmsg {%msg}
logmsg

wfsave(2) education.wf1

!runtime = @toc
%msg = "Runtime " + @str(!runtime) + " sec" 
logmsg {%msg}

logmsg FINISHED

wfclose education


