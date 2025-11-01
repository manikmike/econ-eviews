' This program estimated various specifications of LFPR equations.
'	Polina Vlasenko

' In this version: eliminate the no-constant equations -- PV 

' In this version (_03): create the "deviation from peak" (_dpk) series, replicating the method currenbtly used int he model. -- PV

' This version (09) uses data through 2019 and assumes a new business-cycle peak in 2019Q1. It also loads data from blsadj19_pv.wf1 (note that this is a workfile, not databank).

' This version (11) allows the user to request adjustment to LFPR data for disability PRIOR to running the regressions. Uses data from  blsadj19_pv.wf1 and assumed 2019Q1 to be a peak. This version (11) estimates only one specification -- 5 lags, PDL degree 3. 


'******* UPDATE the entries below for each run
%data =  "blsadj19_pv" ' blsadj19_pv.wf1
'%data_path			' full path

!yrstart = 1960	' first year of data
!yrend = 2020 	' last yr of data

' Should the LFPRs be adjusted for DI prior to the estimation?
%di_adj = "Y" 		' enter Y or N (case sensitive)

%di_data = "op1182o.bnk" 	' databank that contgaisn the DI data needed for adjustments to LFPRs
'%di_data_path			' full path

'	Output created by this program
%thisfile = "LFPR_estimation"
%outputpath = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1\"
' Do you want the output file(s) to be saved on this run? 
' Enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "N" 		' enter "N" or "Y" 

' ****** END of Update section

wfcreate(wf={%thisfile}, page=q) q !yrstart !yrend
pagecreate(page=a) a !yrstart !yrend
pagecreate(page=estimation) q !yrstart !yrend

pageselect q

%sex = "f m"
%age = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 16o 65o 75o"
%age_fetch = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 16o" ' 6964 6569 7074  Ages, data which is to be loaded from op-bank. Data for other ages we create from SYOA series
%age_lim = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 16o" '6064 6569 16o" 'limited age groups -- only up to 59 y.o.

%nber_peaks = "1969q4 1975q4 1980q1 1990q3 2001q1 2007q4 2019q1"		' Treating the double-dip recession in 1980s as a single recession, thus ni peak in 1981q3.

'get data from databank  --  old code when blsadj data was in Aremos databank
'dbopen(type=aremos) %data
'fetch *_adj.q
'close @db

' get data from workfile
wfopen {%data}
pageselect data_q

copy {%data}::data_q\* {%thisfile}::q\*			' this pulls in all ..._adj and ..._adjs series (e, l, n, p, and r).

wfclose {%data}

if %di_adj = "Y" then
	' Get disability data
	pageselect q
	dbopen(type=aremos) %di_data
	for %s {%sex}
		for %a {%age_fetch}		' we want to fecth only certain ages, for other age groups we create values from SYOA series
			fetch r{%s}{%a}di.q
		next
		fetch r{%s}60di.q r{%s}61di.q r{%s}62di.q r{%s}63di.q r{%s}64di.q		' SOYA data for 6064group
		fetch n{%s}60.q n{%s}61.q n{%s}62.q n{%s}63.q n{%s}64.q
		
		fetch r{%s}65di.q r{%s}66di.q 'r{%s}67di.q r{%s}68di.q r{%s}69di.q		' SOYA data for 6569 group
		fetch n{%s}65.q n{%s}66.q n{%s}67.q n{%s}68.q n{%s}69.q
		
		'fetch r{%s}70di.q r{%s}71di.q r{%s}72di.q r{%s}73di.q r{%s}74di.q		' SOYA data for 7074 group
		fetch n{%s}70.q n{%s}71.q n{%s}72.q n{%s}73.q n{%s}74.q
	next
	fetch r16odi.q

'	pageselect a
'	for %s {%sex}
'		for %a {%age_lim}
'			fetch n{%s}{%a}di.a
'		next
'	next
'	fetch n16odi.a

	close @db

	'pageselect q
	'copy(c=i) a\n* q\		' transforms annual n{s}{a}di series into quarterly by setting Q4 value equal to annual value and linearly interpolating in between.
	'testing various freq conversion methods
	'copy(c=i) a\nm5054di q\nm5054di_li
	'copy(c=linearf) a\nm5054di q\nm5054di_lf
	'copy(c=r) a\nm5054di q\nm5054di_const
	'copy(c=q) a\nm5054di q\nm5054di_quad
	'copy(c=cubicf) a\nm5054di q\nm5054di_cf
	'copy(c=cubicl) a\nm5054di q\nm5054di_cl
	'copy(c=pointl) a\nm5054di q\nm5054di_pl
endif


' create LFPR and RU series to be used in estimation
' NOTE: series ending in ..._adj are the ones loaded directly from databank. Series created here have no ..._adj in their name.
' NOTE: there are _adj and _adjs series for f16o, m16o, and 16o. I am not sure at this point which ones are used in the old blsadj18 databank. Need to check and make sure the same ones are used here!
pageselect q
smpl @all

' create DI rates for groups 6064 and older
if %di_adj = "Y" then
	for %s m f 
		' 6064 group
		series n{%s}6064 = n{%s}60 + n{%s}61 + n{%s}62 + n{%s}63 + n{%s}64		' total pop in this age group
		' keep DI rate at what it was at age 61
		series r{%s}62di_c =  r{%s}61di(-4)			
		series r{%s}63di_c =  r{%s}61di(-8)
		series r{%s}64di_c =  r{%s}61di(-12)
		
		' 6569 group
		series n{%s}6569 = n{%s}65 + n{%s}66 + n{%s}67 + n{%s}68 + n{%s}69		' total pop in this age group
		series r{%s}65di_c =  r{%s}61di(-16)			' keep DI rate at what it was at age 61.
		series r{%s}66di_c =  r{%s}61di(-20)			
		series r{%s}67di_c =  r{%s}61di(-24)			
		series r{%s}68di_c =  r{%s}61di(-28)
		series r{%s}69di_c =  r{%s}61di(-32)
		
		
		' 7074 group
		series n{%s}7074 = n{%s}70 + n{%s}71 + n{%s}72 + n{%s}73 + n{%s}74		' total pop in this age group
		series r{%s}70di_c =  r{%s}61di(-36)			' keep DI rate at what it was at age 61.
		series r{%s}71di_c =  r{%s}61di(-40)			
		series r{%s}72di_c =  r{%s}61di(-44)			
		series r{%s}73di_c =  r{%s}61di(-48)
		series r{%s}74di_c =  r{%s}61di(-52)
		
		' fill in missing lagged values with earliest value of r61di
		for %a 62 63 64 65 66 67 68 69 70 71 72 73 74
			smpl if  r{%s}61di<>na and r{%s}{%a}di_c=na
			%f_r61 = @otods(1) 	' DATE of the first non-missing obs in r61di
			r{%s}{%a}di_c = @elem(r{%s}61di, %f_r61)
			smpl @all
		next
		
		' Compute r6064di, r6569di, r7074di as weighted average
		series r{%s}6064di = (r{%s}60di * n{%s}60 + r{%s}61di * n{%s}61 +r{%s}62di_c * n{%s}62 +r{%s}63di_c * n{%s}63 + r{%s}64di_c * n{%s}64) / n{%s}6064	' note that r60di and r61di are used as is (no r60di_c or r61di_c)
		series r{%s}6569di = (r{%s}65di_c * n{%s}65 + r{%s}66di_c * n{%s}66 +r{%s}67di_c * n{%s}67 +r{%s}68di_c * n{%s}68 + r{%s}69di_c * n{%s}69) / n{%s}6569
		series r{%s}7074di = (r{%s}70di_c * n{%s}70 + r{%s}71di_c * n{%s}71 +r{%s}72di_c * n{%s}72 +r{%s}73di_c * n{%s}73 + r{%s}74di_c * n{%s}74) / n{%s}7074
	next
endif

if %di_adj = "Y" then
	' Adjust LFPRs for disability
	' (1) compute preliminary LFPRs
	' (2) create trends LFPRs from the preliminary ones	
	' (3) computed di-adjusted lfprs using the trend from (2)
	for %s {%sex}
		for %a {%age_lim} 
			series p{%s}{%a}_prelim = l{%s}{%a}_adj/n{%s}{%a}_adj
			freeze(hp_p{%s}{%a}) p{%s}{%a}_prelim.hpf p{%s}{%a}_hpt @ p{%s}{%a}_hpc	' H-P filter; we treat p{%s}{%a}_hpt as 'trend LFPR'; this line also makes the charts showing the original series (p{%s}{%a}_prelim), the trend (p{%s}{%a}_hpt), and cycle component (p{%s}{%a}_hpc)
			series p{%s}{%a} = p{%s}{%a}_prelim + p{%s}{%a}_hpt * r{%s}{%a}di '					' this adjusts LFPRs for DI incidence ('simple method', does not include ratio of n...di/n...
			group ck_p{%s}{%a} p{%s}{%a}_prelim p{%s}{%a}
			freeze(g_p{%s}{%a}) ck_p{%s}{%a}.line
			
			series r{%s}{%a} = (1- e{%s}{%a}_adj/l{%s}{%a}_adj)			' unempl. rates (no DI adjustment needed)
		next
	next
	' 16o group
	series p16o_prelim = l16o_adj/n16o_adj 
	freeze(hp_p16o) p16o_prelim.hpf p16o_hpt @ p16o_hpc
	series p16o = p16o_prelim + p16o_hpt * r16odi
	group ck_p16o p16o_prelim p16o
	freeze(g_p16o) ck_p16o.line
	series r16o = (1- e16o_adj/l16o_adj)
endif

if %di_adj = "N" then
	' Do NOT adjust LFPRs for disability
	for %s {%sex}
		for %a {%age}
			series p{%s}{%a} = l{%s}{%a}_adj/n{%s}{%a}_adj
			series r{%s}{%a} = (1- e{%s}{%a}_adj/l{%s}{%a}_adj)
		next
	next
	series p16o = l16o_adj/n16o_adj
	series r16o = (1-e16o_adj/l16o_adj)
endif
' At this point there exist series p{%s}{%a} and r{%s}{%a} that can be used for estimation below. The program creates only ONE version of the series -- either adjusted for DI or not (depending on the value of %di_adj), but not both. 


' create "peak" series (name_pk), and "devation from peak" series (name_dpk)
' 16o group
for %s {%nber_peaks}
	smpl {%s} {%s}
	series p16o_pkd = p16o
	series r16o_pkd = r16o
next
smpl @all

p16o_pkd.ipolate p16o_pk
r16o_pkd.ipolate r16o_pk

series p16o_dpk = p16o - p16o_pk
series r16o_dpk = r16o - r16o_pk

' all other age-sex groups
for %s f m
	for %a {%age_lim}		'1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
		for %per {%nber_peaks}
			smpl {%per} {%per}
			series p{%s}{%a}_pkd = p{%s}{%a}
			series r{%s}{%a}_pkd = r{%s}{%a}
		next
		smpl @all
		
		p{%s}{%a}_pkd.ipolate p{%s}{%a}_pk
		r{%s}{%a}_pkd.ipolate r{%s}{%a}_pk
		
		series p{%s}{%a}_dpk = p{%s}{%a} - p{%s}{%a}_pk
		series r{%s}{%a}_dpk = r{%s}{%a} - r{%s}{%a}_pk
	next
next

' copy only data needed for estimation to separate page
pageselect estimation
'copy q\p????? estimation\
'copy q\r????? estimation\
'copy q\*o estimation\
copy q\p*_dpk estimation\
copy q\r*_dpk estimation\

' estimated equations
pageselect estimation
smpl @all 

' create useful charts -- charts named g_f(age), g_m(age), and g_16o plot, for every age group, p..._dpk and r..._dpk (inverted) as an illustration of how closely (or not) the two follow each other
for %a {%age_lim} 		'1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
	group f{%a} pf{%a}_dpk rf{%a}_dpk
	group m{%a} pm{%a}_dpk rm{%a}_dpk
	freeze(g_f{%a}) f{%a}.line(x)
	g_f{%a}.axis(right) invert
	freeze(g_m{%a}) m{%a}.line(x)
	g_m{%a}.axis(right) invert
next
group all16o p16o_dpk r16o_dpk
freeze(g_16o) all16o.line(x)
g_16o.axis(right) invert

' create a table summarizing the run
table(67,11) tab_stat_pdl
tab_stat_pdl(1,1) = "{s}{a} group"
tab_stat_pdl(1,2) = "sample"
tab_stat_pdl(1,3) = "r..._dpk"
tab_stat_pdl(1,4) = "r..._dpk(-1)"
tab_stat_pdl(1,5) = "r..._dpk(-2)"
tab_stat_pdl(1,6) = "r..._dpk(-3)"
tab_stat_pdl(1,7) = "r..._dpk(-4)"
tab_stat_pdl(1,8) = "r..._dpk(-5)"
tab_stat_pdl(1,9) = "Sum of Lags"
tab_stat_pdl(1,10) = "Adj. R-sq."
tab_stat_pdl(1,11) = "DW"

tab_stat_pdl(2,1) = "16o"

!row = 4
for %s f m 
   for %a {%age_lim}	'1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
      tab_stat_pdl(!row,1) = %s + %a
      !row=!row + 2
   next
next

for !row = 2 to 66 step 2
	tab_stat_pdl(!row,3) = "1971-2007"
	tab_stat_pdl(!row+1,3) = "1965-2019"
next
tab_stat_pdl.setjust(B) right
tab_stat_pdl.setwidth(@all) 12
tab_stat_pdl.setwidth(B) 30
if %di_adj = "Y" then
	tab_stat_pdl.title Diagnostic statistics and coefficients for each equation. Regression of the form p.._dpk = r.._dpk and 5 lags, PDL degree 3. LFPRs adjusted for disability.
	else tab_stat_pdl.title Diagnostic statistics and coefficients for each equation. Regression of the form p.._dpk = r.._dpk and 5 lags, PDL degree 3. (No disability adjustment)
endif


' ***** PDL equations *****
pageselect estimation

smpl 1971q1 2007q4	' sample similar to what was used for existing model
' 16o equation
equation p16odpk_pdl.ls p16o_dpk pdl(r16o_dpk,5,3,3)
freeze(t_tmp) p16odpk_pdl.results
%s1 = t_tmp(4,1)
%s2 = t_tmp(4,2)
%s3 = t_tmp(4,3)
%sl = %s1 + %s2 + %s3		' capture the text describing the actual sample used for estimation
delete t_tmp

' all other equations
for %a {%age_lim}		'1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
   for %s f m
      equation p{%s}{%a}dpk_pdl.ls p{%s}{%a}_dpk pdl(r{%s}{%a}_dpk,5,3,3)
      freeze(t_tmp) p{%s}{%a}dpk_pdl.results
	%s1 = t_tmp(4,1)
	%s2 = t_tmp(4,2)
	%s3 = t_tmp(4,3)
	%sl_{%s}{%a} = %s1 + %s2 + %s3 		' capture the text describing the actual sample used for estimation
	delete t_tmp
   next
next

smpl 1965q1 2019q1	' full sample
' 16o equation
equation p16odpk_pdl_full.ls p16o_dpk pdl(r16o_dpk,5,3,3)
freeze(t_tmp) p16odpk_pdl_full.results
%s1 = t_tmp(4,1)
%s2 = t_tmp(4,2)
%s3 = t_tmp(4,3)
%sf = %s1 + %s2 + %s3 		' capture the text descriv=bing the actual sample used for estimation
delete t_tmp

' all other equations
for %a {%age_lim}		'1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
   for %s f m
      equation p{%s}{%a}dpk_pdl_full.ls p{%s}{%a}_dpk pdl(r{%s}{%a}_dpk,5,3,3)
      freeze(t_tmp) p{%s}{%a}dpk_pdl_full.results
	%s1 = t_tmp(4,1)
	%s2 = t_tmp(4,2)
	%s3 = t_tmp(4,3)
	%sf_{%s}{%a} = %s1 + %s2 + %s3 		' capture the text descriv=bing the actual sample used for estimation
	delete t_tmp
   next
next

' save coefficients into a table
' note that PDL estimation results include both coefficicnts on PDL terms and the implied regression coefficents
' In the case with no constant: coef(1) is the first PDL term, coef(2) is the second PDL term, coef(3) is for r.._dpk, coef(4) is for r.._dpk(-1), etc, coef(8) is for r..._dpk(-5).

' 16o equation in first two rows after heading, i.e. row 2 and 3
!suml = 0		' sum of lags fo 2007 eqn
!suml_full = 0	' sum of lags for full sample eqn
 for !cl = 3 to 8
	tab_stat_pdl(2,!cl) = p16odpk_pdl.@coef(!cl)
	tab_stat_pdl(3,!cl) = p16odpk_pdl_full.@coef(!cl)
	!suml = !suml + p16odpk_pdl.@coef(!cl)
	!suml_full = !suml_full + p16odpk_pdl_full.@coef(!cl)
next
	tab_stat_pdl(2,2) = %sl	' describes sample used for estimation
	tab_stat_pdl(3,2) = %sf	' describes sample used for estimation _full eqn
	tab_stat_pdl(2,9) = !suml
	tab_stat_pdl(3,9) = !suml_full
	tab_stat_pdl(2,10) = p16odpk_pdl.@rbar2
	tab_stat_pdl(3,10) = p16odpk_pdl_full.@rbar2
	tab_stat_pdl(2,11) = p16odpk_pdl.@dw
	tab_stat_pdl(3,11) = p16odpk_pdl_full.@dw
	

' all other equations start in row 4
!row = 4
for %s f m 
   for %a {%age_lim}	'1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
      'save coefs and statistics into the  table
     !suml = 0		' sum of lags fo 2007 eqn
	!suml_full = 0	' sum of lags for full sample eqn
      for !cl = 3 to 8
		tab_stat_pdl(!row,!cl) = p{%s}{%a}dpk_pdl.@coef(!cl)
		tab_stat_pdl(!row+1,!cl) = p{%s}{%a}dpk_pdl_full.@coef(!cl)
		!suml = !suml + p{%s}{%a}dpk_pdl.@coef(!cl)
		!suml_full = !suml_full + p{%s}{%a}dpk_pdl_full.@coef(!cl)
	next
	tab_stat_pdl(!row,2) = %sl_{%s}{%a}	' describes sample used for estimation
	tab_stat_pdl(!row+1,2) = %sf_{%s}{%a}	' describes sample used for estimation _full eqn
	tab_stat_pdl(!row,9) = !suml
	tab_stat_pdl(!row+1,9) = !suml_full
	tab_stat_pdl(!row,10) = p{%s}{%a}dpk_pdl.@rbar2
	tab_stat_pdl(!row+1,10) = p{%s}{%a}dpk_pdl_full.@rbar2
	tab_stat_pdl(!row,11) = p{%s}{%a}dpk_pdl.@dw
	tab_stat_pdl(!row+1,11) = p{%s}{%a}dpk_pdl_full.@dw
      
      !row = !row +2
   next
next


' format ALL tables

for %tab tab_stat_pdl 'byage tab_stat_bysex tab_dpk_stat tab_pdl_stat
	for !row = 1 to 67 step 2
		{%tab}.setlines(!row) +b
	next
	{%tab}.setfont(A) +b
	{%tab}.setfont(1) +b
next


'		make summary spool
pageselect estimation
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The file contains estimated equations for LFPRs by age and sex. Please see table tab_stat_pdl in page 'estimation'. "
string line3 = "The raw data for LFPRs and unempl. rates came from " + %data
if %di_adj = "Y" then 
	string line4 = "The LFPRs were adjusted for disability incidence. Disability data came from " + %di_data
	string line5 = "In page q: Series named p{s}{a}_prelim are LFPRs computed as ratio of l{s}{a}_adj and n{s}{a}_adj from " + %data
	string line6 = "In page q: Charts named hp_p{s}{a} show H-P trend for LFPRs p{s}{a}_prelim." 
	string line7 = "In page q: Series named p{s}{a} are LFPRs adjusted for disability, i.e. p{s}{a}_prelim + DIratio * trend_p). Charts named g_p{s}{a} compare the original LFPRs (p{s}{a}_prelim) to the disability-adjusted ones (p{s}{a}). "
	else string line4 = "The LFPRs were NOT adjusted for disability incidence. "
			string line5 = "The estimated equations (and the data series used for the estimation) can be found in page 'estimation'. "
			string line6 = " " 
			string line7 = " "
endif
string line8 = "In page 'estimation': Graphs named g_f(age), g_m(age), and g_16o plot, for every age group, p..._dpk and r..._dpk (inverted) as an illustration of how closely (or not) the two follow each other."
string line9 = "Table tab_stat_pdl shows coefficients and relevant statistics for the equations estimated as 'deviations from peak', with 5 lags, and PDL coefficients with polynomial of degree 3, no constant term. Two versions are estimated -- using the original sample period (1971-2007, named pf1617dpk_pld) and full sample peripod (1965-2019, named pf1617dpk_pdl_full, and similarly for other a-s groups). The ACTUAL sample used for each estimation (adjusted for any missing values) is listed in column 2 of table tab_stat_pdl."

string line10 = "Polina Vlasenko"


_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 'line11 line12 line13
_summary.display

delete line*


if %sav = "Y" then
	%wfpath=%outputpath + %thisfile + ".wf1"
	wfsave(2) %wfpath ' saves the workfile
endif



stop 	' STOP STOP STOP STOP STOP  here. Everythign below is a remnant of earlier versions of the code.




stop

for %s {%sex}
	for %a {%age}
		series p{%s}{%a} = l{%s}{%a}_adj/n{%s}{%a}_adj
		series r{%s}{%a} = (1- e{%s}{%a}_adj/l{%s}{%a}_adj)
	next
next
series p16o = l16o_adj/n16o_adj
series r16o = (1-e16o_adj/l16o_adj)

'START here


' create "peak" series, name_pk, and "devation from peak" series, name_dpk
' 16o group
for %s {%nber_peaks}
	smpl {%s} {%s}
	series p16o_pkd = p16o
	series r16o_pkd = r16o
next
smpl @all

p16o_pkd.ipolate p16o_pk
r16o_pkd.ipolate r16o_pk

series p16o_dpk = p16o - p16o_pk
series r16o_dpk = r16o - r16o_pk

' all other age-sex groups
for %s f m
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
		for %per {%nber_peaks}
			smpl {%per} {%per}
			series p{%s}{%a}_pkd = p{%s}{%a}
			series r{%s}{%a}_pkd = r{%s}{%a}
		next
		smpl @all
		
		p{%s}{%a}_pkd.ipolate p{%s}{%a}_pk
		r{%s}{%a}_pkd.ipolate r{%s}{%a}_pk
		
		series p{%s}{%a}_dpk = p{%s}{%a} - p{%s}{%a}_pk
		series r{%s}{%a}_dpk = r{%s}{%a} - r{%s}{%a}_pk
	next
next

' copy only data needed for estimation to separate page
pageselect estimation
copy q\p????? estimation\
copy q\r????? estimation\
copy q\*o estimation\
copy q\p*_dpk estimation\
copy q\r*_dpk estimation\

' estimated equations
pageselect estimation

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
	group f{%a} pf{%a}_dpk rf{%a}_dpk
	group m{%a} pm{%a}_dpk rm{%a}_dpk
	freeze(g_f{%a}) f{%a}.line(x)
	g_f{%a}.axis(right) invert
	freeze(g_m{%a}) m{%a}.line(x)
	g_m{%a}.axis(right) invert
next
group all16o p16o_dpk r16o_dpk
freeze(g_16o) all16o.line(x)
g_16o.axis(right) invert

' graphs named g_f(age), g_m(age), and g_16o plot, for every age group, p..._dpk and r..._dpk (inverted) as an illustration of how closely (or not) the two follow each other.


'create table with relevant statistics
' adj R-sq and F-stat p-value
table(67,11) tab_stat
tab_stat(1,1) = "{s}{a} group"
tab_stat(1,2) = "sample"
tab_stat(1,3) = "dr"
tab_stat(1,4) = "dr(-1)"
tab_stat(1,5) = "dr(-2)"
tab_stat(1,6) = "dr(-3)"
tab_stat(1,7) = "dr(-4)"
tab_stat(1,8) = "dr(-5)"
tab_stat(1,9) = "const"
tab_stat(1,10) = "Fstat p-value"
tab_stat(1,11) = "DW"


for !row=2 to 66 step 2
	tab_stat(!row,2) = "full"
	tab_stat(!row+1,2) = "ends 2007Q4"
next
tab_stat.setjust(B) right
tab_stat.title Diagnostic statistics and coefficients for each equation
tab_stat.setwidth(@all) 12

' 16o equation
smpl 1965q1 2018q2	' full sample of available data
equation dp16o.ls d(p16o) d(r16o) d(r16o(-1)) d(r16o(-2)) d(r16o(-3)) d(r16o(-4)) d(r16o(-5)) c		' include constant term

smpl 1971q1 2007q4	' sample similar to what was used for existing model
equation dp16o_2007.ls d(p16o) d(r16o) d(r16o(-1)) d(r16o(-2)) d(r16o(-3)) d(r16o(-4)) d(r16o(-5)) c	' include constant term

tab_stat(2,1) = "16o"

for !cl = 3 to 9
	tab_stat(2,!cl) = dp16o.@coef(!cl-2)
	tab_stat(3,!cl) = dp16o_2007.@coef(!cl-2)
next
tab_stat(2,10) = dp16o.@fprob
tab_stat(3,10) = dp16o_2007.@fprob
tab_stat(2,11) = dp16o.@dw
tab_stat(3,11) = dp16o_2007.@dw

' all other equations
!row = 4
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
   for %s f m
      smpl 1965q1 2018q2	' full sample
      equation dp{%s}{%a}.ls d(p{%s}{%a}) d(r{%s}{%a}) d(r{%s}{%a}(-1)) d(r{%s}{%a}(-2)) d(r{%s}{%a}(-3)) d(r{%s}{%a}(-4)) d(r{%s}{%a}(-5)) c
      smpl 1965q1 2007q4	' original sample
      equation dp{%s}{%a}_2007.ls d(p{%s}{%a}) d(r{%s}{%a}) d(r{%s}{%a}(-1)) d(r{%s}{%a}(-2)) d(r{%s}{%a}(-3)) d(r{%s}{%a}(-4)) d(r{%s}{%a}(-5)) c
      
      'save coefs and statistics into the  table
      tab_stat(!row,1) = %s + %a
      
      for !cl = 3 to 9
		tab_stat(!row,!cl) = dp{%s}{%a}.@coef(!cl-2)
		tab_stat(!row+1,!cl) = dp{%s}{%a}_2007.@coef(!cl-2)
	next
	tab_stat(!row,10) = dp{%s}{%a}.@fprob
	tab_stat(!row+1,10) = dp{%s}{%a}_2007.@fprob
	tab_stat(!row,11) = dp{%s}{%a}.@dw
	tab_stat(!row+1,11) = dp{%s}{%a}_2007.@dw
      
      !row = !row +2
   next
next

smpl @all

'create same table, but arrange equations by sex -- first all females, then all males
table tab_stat_bysex = tab_stat

!row = 4
for %s f m 
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
      'save coefs and statistics into the  table
      tab_stat_bysex(!row,1) = %s + %a
      
      for !cl = 3 to 9
		tab_stat_bysex(!row,!cl) = dp{%s}{%a}.@coef(!cl-2)
		tab_stat_bysex(!row+1,!cl) = dp{%s}{%a}_2007.@coef(!cl-2)
	next
	tab_stat_bysex(!row,10) = dp{%s}{%a}.@fprob
	tab_stat_bysex(!row+1,10) = dp{%s}{%a}_2007.@fprob
	tab_stat_bysex(!row,11) = dp{%s}{%a}.@dw
	tab_stat_bysex(!row+1,11) = dp{%s}{%a}_2007.@dw
      
      !row = !row +2
   next
next

rename tab_stat tab_stat_byage


' ****** equations for ..._dpk series
smpl 1965q1 2007q4	
' 16o equation
equation p16odpk.ls p16o_dpk r16o_dpk r16o_dpk(-1) r16o_dpk(-2) r16o_dpk(-3) r16o_dpk(-4) r16o_dpk(-5) c	' include constant term
equation p16odpk_nc.ls p16o_dpk r16o_dpk r16o_dpk(-1) r16o_dpk(-2) r16o_dpk(-3) r16o_dpk(-4) r16o_dpk(-5) 	' NO constant term

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
   for %s f m
      equation p{%s}{%a}dpk.ls p{%s}{%a}_dpk r{%s}{%a}_dpk r{%s}{%a}_dpk(-1) r{%s}{%a}_dpk(-2) r{%s}{%a}_dpk(-3) r{%s}{%a}_dpk(-4) r{%s}{%a}_dpk(-5) c	' include constant term
      equation p{%s}{%a}dpk_nc.ls p{%s}{%a}_dpk r{%s}{%a}_dpk r{%s}{%a}_dpk(-1) r{%s}{%a}_dpk(-2) r{%s}{%a}_dpk(-3) r{%s}{%a}_dpk(-4) r{%s}{%a}_dpk(-5) 	' NO constant term
   next
next

' create a table summarizing the run

table tab_dpk_stat = tab_stat_bysex
tab_dpk_stat(1,2) = " "
tab_dpk_stat(1,3) = "r..._dpk"
tab_dpk_stat(1,4) = "r..._dpk(-1)"
tab_dpk_stat(1,5) = "r..._dpk(-2)"
tab_dpk_stat(1,6) = "r..._dpk(-3)"
tab_dpk_stat(1,7) = "r..._dpk(-4)"
tab_dpk_stat(1,8) = "r..._dpk(-5)"
tab_dpk_stat(1,10) = "Adj. R-sq."

for !row = 2 to 66 step 2
	tab_dpk_stat(!row,2) = "with const."
	tab_dpk_stat(!row+1,2) = "no const."
next

' 16o equation in first two rows after heading, i.e. row 2 and 3
 for !cl = 3 to 9
	tab_dpk_stat(2,!cl) = p16odpk.@coef(!cl-2)
	if !cl<9 then 
		tab_dpk_stat(3,!cl) = p16odpk_nc.@coef(!cl-2)
		else tab_dpk_stat(3,!cl) = "."
	endif
next
	tab_dpk_stat(2,10) = p16odpk.@rbar2
	tab_dpk_stat(3,10) = p16odpk_nc.@rbar2
	tab_dpk_stat(2,11) = p16odpk.@dw
	tab_dpk_stat(3,11) = p16odpk_nc.@dw

' all other equations start in row 4
!row = 4
for %s f m 
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
      'save coefs and statistics into the  table
      for !cl = 3 to 9
		tab_dpk_stat(!row,!cl) = p{%s}{%a}dpk.@coef(!cl-2)
		if !cl<9 then 
			tab_dpk_stat(!row+1,!cl) = p{%s}{%a}dpk_nc.@coef(!cl-2)
			else tab_dpk_stat(!row+1,!cl) = "."
		endif
	next
	tab_dpk_stat(!row,10) = p{%s}{%a}dpk.@rbar2
	tab_dpk_stat(!row+1,10) = p{%s}{%a}dpk_nc.@rbar2
	tab_dpk_stat(!row,11) = p{%s}{%a}dpk.@dw
	tab_dpk_stat(!row+1,11) = p{%s}{%a}dpk_nc.@dw
      
      !row = !row +2
   next
next

'***** done with ..._dpk equations


' ***** PDL equations *****
smpl @all


smpl 1971q1 2007q4	' sample similar to what was used for existing model
' 16o equation
equation p16odpk_pdl.ls p16o_dpk pdl(r16o_dpk,5,3,3)

' all other equations
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
   for %s f m
      equation p{%s}{%a}dpk_pdl.ls p{%s}{%a}_dpk pdl(r{%s}{%a}_dpk,5,3,3)
   next
next

smpl 1965q1 2019q1	' full sample
' 16o equation
equation p16odpk_pdl_full.ls p16o_dpk pdl(r16o_dpk,5,3,3)

' all other equations
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
   for %s f m
      equation p{%s}{%a}dpk_pdl_full.ls p{%s}{%a}_dpk pdl(r{%s}{%a}_dpk,5,3,3)
   next
next


' save coefficients into a table
' note that PDL estimation results include both coefficicnts on PDL terms and the implied regression coefficents
' In the case with no constant: coef(1) is the first PDL term, coef(2) is the second PDL term, coef(3) is for r.._dpk, coef(4) is for r.._dpk(-1), etc, coef(8) is for r..._dpk(-5).


' create a table summarizing the run
table tab_pdl_stat = tab_dpk_stat

for !row = 2 to 66 step 2
	tab_pdl_stat(!row,2) = "1971-2007"
	tab_pdl_stat(!row+1,2) = "1965-2019"
next
tab_pdl_stat(1,9) = "Sum of Lags"

' 16o equation in first two rows after heading, i.e. row 2 and 3
!suml = 0		' sum of lags fo 2007 eqn
!suml_full = 0	' sum of lags for full sample eqn
 for !cl = 3 to 8
	tab_pdl_stat(2,!cl) = p16odpk_pdl.@coef(!cl)
	tab_pdl_stat(3,!cl) = p16odpk_pdl_full.@coef(!cl)
	!suml = !suml + p16odpk_pdl.@coef(!cl)
	!suml_full = !suml_full + p16odpk_pdl_full.@coef(!cl)
next
	tab_pdl_stat(2,9) = !suml
	tab_pdl_stat(3,9) = !suml_full
	tab_pdl_stat(2,10) = p16odpk_pdl.@rbar2
	tab_pdl_stat(3,10) = p16odpk_pdl_full.@rbar2
	tab_pdl_stat(2,11) = p16odpk_pdl.@dw
	tab_pdl_stat(3,11) = p16odpk_pdl_full.@dw


' all other equations start in row 4
!row = 4
for %s f m 
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 65o 75o 16o
      'save coefs and statistics into the  table
      !suml = 0		' sum of lags fo 2007 eqn
	!suml_full = 0	' sum of lags for full sample eqn
      for !cl = 3 to 8
		tab_pdl_stat(!row,!cl) = p{%s}{%a}dpk_pdl.@coef(!cl)
		tab_pdl_stat(!row+1,!cl) = p{%s}{%a}dpk_pdl_full.@coef(!cl)
		!suml = !suml + p{%s}{%a}dpk_pdl.@coef(!cl)
		!suml_full = !suml_full + p{%s}{%a}dpk_pdl_full.@coef(!cl)
	next
	tab_pdl_stat(!row,9) = !suml
	tab_pdl_stat(!row+1,9) = !suml_full
	tab_pdl_stat(!row,10) = p{%s}{%a}dpk_pdl.@rbar2
	tab_pdl_stat(!row+1,10) = p{%s}{%a}dpk_pdl_full.@rbar2
	tab_pdl_stat(!row,11) = p{%s}{%a}dpk_pdl.@dw
	tab_pdl_stat(!row+1,11) = p{%s}{%a}dpk_pdl_full.@dw
      
      !row = !row +2
   next
next

' empty rows for no-consatnt specification
'for !row = 3 to 67 step 2
'	for !cl = 3 to 11
'		tab_pdl_stat(!row,!cl) = "."
'	next
'next



'equation pm1617dpk_pdlu.ls pm1617_dpk c pdl(rm1617_dpk,5,3)

'vector test_coef=pm1617dpk_pdl.@coefs

'equation f2529pdl_c.ls pf2529_dpk c pdl(rf2529_dpk,5,3,3)

'equation f2529pdl_manual.ls pf2529_dpk rf2529_dpk pdl(rf2529_dpk(-1),4,3,3)

'ls pf2529_dpk pdl(rf2529_dpk,5,3,3)




' format ALL tables

for %tab tab_stat_byage tab_stat_bysex tab_dpk_stat tab_pdl_stat
	for !row = 1 to 67 step 2
		{%tab}.setlines(!row) +b
	next
	{%tab}.setfont(A) +b
	{%tab}.setfont(1) +b
next

tab_pdl_stat.title Coefficients and diagnostic statistics for estimaton with PDL (degree 3)



'		make summary spool
pageselect estimation
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The file contains estimated equations for LFPRs by age and sex."
string line3 = "The estimation uses the data from " + %data
string line4 = "Tables tab_stat_byage and tab_stat_bysex list coefficients and relevant statistics for each equation."
string line5 = "Table tab_stat_byage list equations by age groups, such as f2024, m2024, f2529, m2529, etc."
string line6 = "Table tab_stat_bysex list equations by gender groups -- all equations for females first, then all equations for males."
string line7 = "Graphs named g_f(age), g_m(age), and g_16o plot, for every age group, p..._dpk and r..._dpk (inverted) as an illustration of how closely (or not) the two follow each other."
string line8 = "Table tab_dpk_stat shows coefficients and relevant statistics for the 'deviations from peak' equations."
string line9 = "Table tab_pdl_stat shows coefficients and relevant statistics for the 'deviations from peak' equations estimated with PDL lags (and a constant term). Two versions are estimated -- using the original sample period (1971-2007, named pf1617_dpk_pld) and full sample peripod (1965-2019, named pf1617dpk_pdl_full, and similarly for other a-s groups). "

string line10 = "Polina Vlasenko"


_summary.insert line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 'line11 line12 line13
_summary.display

delete line*

if %sav = "Y" then
	' put save commands for PDF files with tables here as well
	%wfpath=%outputpath + %thisfile + ".wf1"
	wfsave(2) %wfpath ' saves the workfile
endif

'close {%thisfile} 'close the workfile; comment this out if need to keep the workfile open


