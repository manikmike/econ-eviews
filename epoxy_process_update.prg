'  EPOXY_PROCESS_UPDATE.PRG
' 	This program updates the EViews workfile that contains data from the Master Earnings File (MEF). 
'	The program assumes there already exists an EViews workfile with MEF data created with data from an earlier year. 
'	The program updates this EViews workfile with the newest raw data from EPOXY, computes the relevant series, and gives them informative labels.
'	Polina Vlasenko 01-30-2018

'	 This version applies one fix -- compute estimated finals by multiplying by the cumul.product LAGGED one period.  ---- Polina Vlasenko 04/12/2018

'	This version also does manual adjusyment to ..._ratio_2018 that account for the effects of the "data cleanup" efforts (similar to how this is done for ..._ratio_2017 and ..._ratio_2016). 
'	We have considered other ways of making adjustments (such as using only the most recent 30 years for creating the ..._avg series, but have decided not to use those yet.) 
'	-- Polina Vlasenko 10-03-2019

'	Added manual adjustment for ..._ratio_2019 (similar to how it is doen for _ratio_2016, _ratio_2017, and _ratio_2018). 
' 	Also added adjustments for nohiw_ratio_(2016, 2017, 2018, 2019); they were not in the code before, but a closer look at data shows they are needed (see lines arounf #940
' 	-- Polina Vlasenko 10-13-2019


' Before running the program the user should update the necessary values in the UPDATE section marked with *****

'**** UPDATE these entries before running the program

'years covered by the EPOXY report
!yearfirst=1978 				'not likely to change 
!yearearliest = 1951 		'some data starts as far back as 1951, NOT likely to change
!report_year_start=1997 	' NOT lineky to change -- this is the earliest **report** year for which we have ANY data in the old EPOXY EViews workfiles

!yearlast=2022				'last year of DATA in the EPOXY report (Excel file) we are using for this update
!report_year=2023 			'year of the the EPOXY report we are using for this update
								'EXAMPLE: EPOXY report that came out in Dec 2016 has data through 2015, thus !yearlast=2015, !report_year=2016
!first_report_year=2015 	'first EPOXY report that includes ***complete history***, instead of just 10 years -- NOT likely to change
						
'EViews workfile with previous-year EPOXY data
%file_initial="epoxy_r2022" 'name
%file_initial_path="\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR24_ProgramsData\epoxy_r2022.wf1" 'full path

'Raw source data epoxy file created by Bill Piet -- this is the NEW epoxy data we are using for the update
%epoxypath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\EPOXY\epoxy20231201.xlsx"    			  

'output produced by this program 
%file_output="epoxy_r"+@str(!report_year) 'name
%file_output_path="\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\"+%file_output+".wf1" 'full path

' Do you want the output file(s) to be saved on this run? 
' Enter N for testing/trial runs. 
' Enter Y for the final run ONLY -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!!!
%sav = "Y" 		' enter "N" or "Y" (case sensitive)

'**** END of the UPDATE section

'create the new workfile with appropriare paramenter
wfcreate(wf=%file_output, page=tab7a ) a !yearfirst !yearlast
smpl @all

'General outline of the process for each table/series (may be different for some series):
' (1) Get data from the previous-year workfile (epoxy_rXXXX.wf1) and place it into the appropriate workfile page
' (2) import latest data from the latest Epoxy report from Bill
'  		(2.1) Sometimes need to create a table that shows the latest data
' (3) Compute the adjustment factor for each series
' (4) Compute the estimated final value for each series
' (5) Create convenient comparison groups to see the adjustments performed.


'load series form the previous-year workfile
wfopen %file_initial_path

'copy relevant series from Table 7A
copy %file_initial::tab7a\oasdw_r* %file_output::tab7a\		
copy %file_initial::tab7a\oasdtw_r* %file_output::tab7a\
copy %file_initial::tab7a\hiw_r* %file_output::tab7a\
copy %file_initial::tab7a\hitw_r* %file_output::tab7a\

wfclose %file_initial

smpl @all
'load new data from Bill's epoxy Excel file
import(page=tab7a) %epoxypath range="Table 7A" colhead=2 names=("year","oasdw","oasdtw","hiw","hitw") na="#N/A" @freq a @id @date(year) 
'rename appropriately and add description
rename oasdw oasdw_r{!report_year}
oasdw_r{!report_year}.label(d) Persons with OASDI-taxable wages
oasdw_r{!report_year}.label(u) Number of people
oasdw_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename oasdtw oasdtw_r{!report_year}
oasdtw_r{!report_year}.label(d) Total amont of OASDI-taxable wages
oasdtw_r{!report_year}.label(u) dollars ($)
oasdtw_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename hiw hiw_r{!report_year}
hiw_r{!report_year}.label(d) Persons with HI-taxable wages
hiw_r{!report_year}.label(u) Number of people
hiw_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename hitw hitw_r{!report_year}
hitw_r{!report_year}.label(d) Total amount of HI-taxable wages
hitw_r{!report_year}.label(u) dollars ($)
hitw_r{!report_year}.label(r) from Dec {!report_year} Epoxy report


'Table 7A -- create the table for the REPORT YEAR
%table7a="table7a_r"+@str(!report_year)
freeze({%table7a}) oasdw_r{!report_year} oasdtw_r{!report_year} hiw_r{!report_year} hitw_r{!report_year}

'{%table7a}.table
{%table7a}.title Table 7A. Taxable wages for 1978 through {!yearlast}
{%table7a}.insertrow(1) 3
{%table7a}.setjust(a1:e4) center
{%table7a}.setmerge(a1:e1)
{%table7a}.setmerge(b1:c1)
{%table7a}.setmerge(d1:e1)
{%table7a}.setformat(b) ft.0
{%table7a}.setformat(d) ft.0
{%table7a}.setformat(c) ft.2
{%table7a}.setformat(e) ft.2
{%table7a}.setwidth(3) 20
{%table7a}.setwidth(5) 20

{%table7a}(1,1) = "Table 7A. Taxable wages for 1978 through "+@str(!yearlast)
{%table7a}(2,2) = "   Persons with OASDI-taxable wages"
{%table7a}(2,4) = "   Persons with HI-taxable wages"
'{%table7a}.setjust(a1:e4) center
{%table7a}(3,1) = "Year"
{%table7a}(3,2) = "Number of"
{%table7a}(4,2) = "persons"
{%table7a}(3,3) = "Total amount of"
{%table7a}(4,3) = "OASDI taxable wages"
{%table7a}(3,4) = "Number of"
{%table7a}(4,4) = "persons"
{%table7a}(3,5) = "Total amount of"
{%table7a}(4,5) = "HI taxable wages"

{%table7a}.setlines(a1:e5) +a
{%table7a}.setlines(a2:a4) -h
{%table7a}.setlines(b3:b4) -h
{%table7a}.setlines(c3:c4) -h
{%table7a}.setlines(d3:d4) -h
{%table7a}.setlines(e3:e4) -h
{%table7a}.setlines(b2) -r
{%table7a}.setlines(d2) -r

{%table7a}.setjust(a1) middle center

'create "HI less OASDI wages"
for !y=!report_year_start to !report_year
	genr hi_l_OASDIw_r{!y} = hitw_r{!y} - oasdtw_r{!y}
	hi_l_OASDIw_r{!y}.setformat f.2
	'hi_l_OASDIw_r{!y} = @recode(hi_l_OASDIw_r{!y}=0, na, hi_l_OASDIw_r{!y}) ' recode all zero value sinto NA's; need thsi to be able to craete the ratios in the loop below
next
'populate the label for hi_l_OASDIw series
hi_l_OASDIw_r{!report_year}.label(d) Total amount of wages taxable by HI but not by OASDI
hi_l_OASDIw_r{!report_year}.label(u) dollars ($)

'compute the adjustment factors

'ratios of reported in yr t to reported in yr (t-1)
for %ser oasdw oasdtw hiw hitw hi_l_OASDIw
	for !y=!first_report_year+1 to !report_year
		%yt=@str(!y)
		%yt1=@str(!y-1)
		series {%ser}_ratio_{!y} 	' create a ratio series filled with NAs
		
		smpl if {%ser}_r{%yt1} <> 0		' compute the ratio only if the denominator is not zero
		{%ser}_ratio_{!y}={%ser}_r{%yt}/{%ser}_r{%yt1}
		smpl @all
	next
next


if !report_year<2020 then		'can delete this entire IF statement when report_year=2020 or later.
	for !y=2013 to !report_year  	
		%yt=@str(!y)
		%yt1=@str(!y-1)
		genr oasdw_ratio_{!y}=oasdw_r{%yt}/oasdw_r{%yt1}
		genr oasdtw_ratio_{!y}=oasdtw_r{%yt}/oasdtw_r{%yt1}
		genr hiw_ratio_{!y}=hiw_r{%yt}/hiw_r{%yt1}
		genr hitw_ratio_{!y}=hitw_r{%yt}/hitw_r{%yt1}	
		genr hi_l_OASDIw_ratio_{!y}=hi_l_OASDIw_r{%yt}/hi_l_OASDIw_r{%yt1}
	next
endif

'manually adjust certain values to account for special adjustments in data for 1980s
'NOTE: if these adjustments continue in future reports, must add code here to account for them!!!!

for %ser oasdw oasdtw hiw hitw
	!r2016adj=0.5*(@elem({%ser}_ratio_2016, "1983")+@elem({%ser}_ratio_2016, "1987"))
	!r2017adj=0.5*(@elem({%ser}_ratio_2017, "1981")+@elem({%ser}_ratio_2017, "1985"))
	!r2018adj=0.5*(@elem({%ser}_ratio_2018, "1980")+@elem({%ser}_ratio_2018, "1986"))
	!r2019adj=0.5*(@elem({%ser}_ratio_2019, "1981")+@elem({%ser}_ratio_2019, "1982"))	' For _ratio_2019, the outliers are years 1978-1980. Ideally, we woudl replace them by an average of 1977 and 1981, BUT we do not have data prior to 1978. Instead, I am amaking an average of 1981 and 1982.
	' No need to adjust _ratio_2020 series because even if there are any changes, they would pply to years prior to 1978, where we have no data
	smpl 1978 1980
	{%ser}_ratio_2019 = !r2019adj
	smpl 1981 1985
	{%ser}_ratio_2018 = !r2018adj
	smpl 1982 1984
	{%ser}_ratio_2017 = !r2017adj
	smpl 1984 1986
	{%ser}_ratio_2016 = !r2016adj
	smpl @all
next

if !report_year<2020 then
'!!!!! This section applies ONLY to report years prior to and including 2019
'In r2017 we have only three years of complete data, thus can complete only two ratios. 
'Once we get at least 6 years of complete data, switch to using the code included further below, which is marked accordingly.
	for %ser oasdw oasdtw hiw hitw hi_l_OASDIw
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		
		!break_yr = !report_year - 10		' earliest yr for which we have enough  data for 5yr average
		smpl !yearfirst !break_yr-1		'years for which we do not enough data for 5yr average
		'Moving average for as many years as we have available
		if !report_year=2017 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1))/2	
		endif
		if !report_year=2018 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2))/3	
		endif
		if !report_year=2019 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2)+ {%r4}(-3))/4	
		endif	
		
		smpl !break_yr !yearlast		'years for which we have enough data for 5yr average
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
				
		smpl @all
		'final adjustment factor
		genr {%ser}_adj=@cumprod({%ser}_avg)  
	next
	
endif  	'!!!!! END of section that applies ONLY to report years prior to and including 2019.

smpl @all

'!!!!! Once we have at least SIX years of complete history (i.e. starting from report in 2020), use the code below to compute the final adjustment factor for ALL years. Remove the earlier code above that differentiates between recent and "old" years.  -- Polina Vlasenko 01-09-2018
if !report_year>2019 then
	smpl @all
	for %ser oasdw oasdtw hiw hitw hi_l_OASDIw
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
		'final adjustment factor 
		genr {%ser}_adj=@cumprod({%ser}_avg)
	next
endif  	'!!!! END of code to be used for report 2020 and after.


'change all NAs in the ..._adj series to 1. First 4 obs will be NAs b/c of how ratios are computed. Some other observations can be NAs for other reasons.
for %ser oasdw oasdtw hiw hitw hi_l_OASDIw
	{%ser}_adj = @nan({%ser}_adj,1)
next

'ALL adjustement factors are computed and are named [series]_adj, i.e. oasdw_adj, hiw_adj, etc.
smpl @all

'compute estimated final values
'series that reflect number of WORKERS (people, not $)
for %ser oasdw hiw 
	genr {%ser}_estf=({%ser}_adj(-1)*{%ser}_r{!report_year})/1000000		'resulting value is in *millions of people*
	genr {%ser}_orig={%ser}_r{!report_year}/1000000
		smpl !yearfirst !yearfirst  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 {%ser}_estf={%ser}_orig
		 smpl @all
	{%ser}_estf.label(u) millions of people
	{%ser}_estf.label(r) estimated final value based on Dec {!report_year} Epoxy report
	{%ser}_orig.label(u) millions of people
	{%ser}_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
next

'series that reflect dollar amounts 
for %ser oasdtw hitw hi_l_OASDIw
	genr {%ser}_estf=({%ser}_adj(-1)*{%ser}_r{!report_year})/1000000000			'resulting value is in *billions of dollars*
	genr {%ser}_orig={%ser}_r{!report_year}/1000000000
		smpl !yearfirst !yearfirst  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 {%ser}_estf={%ser}_orig
		 smpl @all
	{%ser}_estf.label(u) $ billions
	{%ser}_estf.label(r) estimated final amount based on Dec {!report_year} Epoxy report
	{%ser}_orig.label(u) $ billions
	{%ser}_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
next

'put descriptions into the label
oasdw_estf.label(d) Persons with OASDI-taxable wages
oasdw_orig.label(d) Persons with OASDI-taxable wages

hiw_estf.label(d) Persons with HI-taxable wages
hiw_orig.label(d) Persons with HI-taxable wages

oasdtw_estf.label(d) Total amount of OASDI-taxable wages
oasdtw_orig.label(d) Total amount of OASDI-taxable wages

hitw_estf.label(d) Total amount of HI-taxable wages
hitw_orig.label(d) Total amount of HI-taxable wages

hi_l_OASDIw_estf.label(d) Total amount of wages taxable by HI but not by OASDI
hi_l_OASDIw_orig.label(d) Total amount of wages taxable by HI but not by OASDI

'create easy-to-see comparisons of reported values and estimated finals
'this is useful when developing the code and the adjustment procedure
'if not needed in the final code, comment it out
group oasdw_compare oasdw_estf oasdw_orig 
group hiw_compare hiw_estf hiw_orig 
group oasdtw_compare oasdtw_estf oasdtw_orig 
group hitw_compare hitw_estf hitw_orig 
group hi_l_OASDIw_compare hi_l_OASDIw_estf hi_l_OASDIw_orig

'display charts with the comparisons
'oasdw_compare.line 
'hiw_compare.line  
'oasdtw_compare.line  
'hitw_compare.line  
'hi_l_OASDIw_compare.line


'***** Table 7B -- Self Employment Earnings 1978 to current
pagecreate(page=tab7b)  a !yearfirst !yearlast
pageselect tab7b

'load series form the previous-year workfile
wfopen %file_initial_path

'copy relevant series from Table 7B
copy %file_initial::tab7b\oasds_r* %file_output::tab7b\		
copy %file_initial::tab7b\taxse_r* %file_output::tab7b\
copy %file_initial::tab7b\cse_r* %file_output::tab7b\
copy %file_initial::tab7b\cmbover_r* %file_output::tab7b\
copy %file_initial::tab7b\cse_cmb_n_r* %file_output::tab7b\

wfclose %file_initial

'load new data from Bill's epoxy Excel file
import(page=tab7b) %epoxypath range="Table 7B" colhead=2 names=("year","oasds","taxse","cse","cmbover", "cse_cmb_n") na="#N/A" @freq a @id @date(year) 

'rename appropriately and populate label
rename oasds oasds_r{!report_year}
oasds_r{!report_year}.label(d) Persons with OASDI-taxable SE earnings
oasds_r{!report_year}.label(u) Number of people
oasds_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename taxse taxse_r{!report_year}
taxse_r{!report_year}.label(d) Total amount of OASDI-taxable SE earnings
taxse_r{!report_year}.label(u) dollars $
taxse_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename cse cse_r{!report_year}
cse_r{!report_year}.label(d) Total amount of HI-taxable SE earnings (i.e. covered SE)
cse_r{!report_year}.label(u) dollars $
cse_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename cmbover cmbover_r{!report_year}
cmbover_r{!report_year}.label(d) Combination workers (people with wages and SE) whose wages exceed the taxmax
cmbover_r{!report_year}.label(u) Number of people
cmbover_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename cse_cmb_n cse_cmb_n_r{!report_year}
cse_cmb_n_r{!report_year}.label(d) Total amount of SE earnings taxable only by HI (b/c OASDI taxmax has been satisfied by wages of these combination workers)
cse_cmb_n_r{!report_year}.label(u) dollars $
cse_cmb_n_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

'compute the adjustment factors

'ratios of reported in yr t to reported in yr (t-1)
for %ser oasds taxse cse cmbover cse_cmb_n
	for !y=!first_report_year+1 to !report_year
		%yt=@str(!y)
		%yt1=@str(!y-1)
		series {%ser}_ratio_{!y} 	' create a ratio series filled with NAs
		
		smpl if {%ser}_r{%yt1} <> 0		' compute the ratio only if the denominator is not zero
		{%ser}_ratio_{!y}={%ser}_r{%yt}/{%ser}_r{%yt1}
		smpl @all
	next
next


if !report_year<2020 then		'can delete this entire IF statement when report_year=2020 or later.
	for !y=2013 to !report_year  	
		%yt=@str(!y)
		%yt1=@str(!y-1)
		genr oasds_ratio_{!y}=oasds_r{%yt}/oasds_r{%yt1}
		genr taxse_ratio_{!y}=taxse_r{%yt}/taxse_r{%yt1}
		genr cse_ratio_{!y}=cse_r{%yt}/cse_r{%yt1}
		genr cmbover_ratio_{!y}=cmbover_r{%yt}/cmbover_r{%yt1}	
		genr cse_cmb_n_ratio_{!y}=cse_cmb_n_r{%yt}/cse_cmb_n_r{%yt1}
	next
endif

'compute appropriate averages (this is dictated by available data)
if !report_year<2020 then
'!!!!! This section applies ONLY to report years prior to and including 2019
'In r2017 we have only three years of complete data, thus can complete only two ratios. 
'Once we get at least 6 years of complete data, switch to using the code included further below, which is marked accordingly.
	for %ser oasds taxse cse cmbover cse_cmb_n
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		
		!break_yr = !report_year - 10		' earliest yr for which we have enough  data for 5yr average
		smpl !yearfirst !break_yr-1		'years for which we do not enough data for 5yr average
		'Moving average for as many years as we have available
		if !report_year=2017 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1))/2	
		endif
		if !report_year=2018 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2))/3	
		endif
		if !report_year=2019 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2)+ {%r4}(-3))/4	
		endif	
		
		smpl !break_yr !yearlast		'years for which we have enough data for 5yr average
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
				
		smpl @all
		'final adjustment factor
		genr {%ser}_adj=@cumprod({%ser}_avg)  
	next

endif  	'!!!!! END of section that applies ONLY to report years prior to and including 2019.

smpl @all

'!!!!! Once we have at least SIX years of complete history (i.e. starting from report in 2020), use the code below to compute the final adjustment factor for ALL years. Remove the earlier code above that differentiates between recent and "old" years.  -- Polina Vlasenko 01-09-2018
if !report_year>2019 then
	smpl @all
	for %ser oasds taxse cse cmbover cse_cmb_n
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
		'final adjustment factor 
		genr {%ser}_adj=@cumprod({%ser}_avg)
	next
endif
'!!!! END of code to be used for report 2020 and after.

'change all NAs in the ..._adj series to 1. First 4 obs will be NAs b/c of how ratios are computed. Some other observations can be NAs for other reasons.
for %ser oasds taxse cse cmbover cse_cmb_n
	{%ser}_adj = @nan({%ser}_adj,1)
next
'ALL adjustement factors are computed and are named [series]_adj, i.e. oasdw_adj, hiw_adj, etc.

smpl @all
'compute estimated final values
'series that reflect number of WORKERS (people, not $)
for %ser oasds cmbover 
	genr {%ser}_estf=({%ser}_adj(-1)*{%ser}_r{!report_year})/1000000		'resulting value is in *millions of people*
	genr {%ser}_orig={%ser}_r{!report_year}/1000000
		smpl !yearfirst !yearfirst  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 {%ser}_estf={%ser}_orig
		 smpl @all
	{%ser}_estf.label(u) millions of people
	{%ser}_estf.label(r) estimated final value based on Dec {!report_year} Epoxy report
	{%ser}_orig.label(u) millions of people
	{%ser}_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
next
'series that reflect dollar amounts 
for %ser taxse cse cse_cmb_n
	genr {%ser}_estf=({%ser}_adj(-1)*{%ser}_r{!report_year})/1000000000			'resulting value is in *billions of dollars*
	genr {%ser}_orig={%ser}_r{!report_year}/1000000000
		smpl !yearfirst !yearfirst  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 {%ser}_estf={%ser}_orig
		 smpl @all
	{%ser}_estf.label(u) $ billions
	{%ser}_estf.label(r) estimated final amount based on Dec {!report_year} Epoxy report
	{%ser}_orig.label(u) $ billions
	{%ser}_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
next

'labels
oasds_estf.label(d) Persons with OASDI-taxable SE earnings
oasds_orig.label(d) Persons with OASDI-taxable SE earnings

cmbover_estf.label(d) Combination workers (people with wages and SE) whose wages exceed the taxmax
cmbover_orig.label(d) Combination workers (people with wages and SE) whose wages exceed the taxmax

taxse_estf.label(d) Total amount of OASDI-taxable SE earnings
taxse_orig.label(d) Total amount of OASDI-taxable SE earnings

cse_estf.label(d) Total amount of covered (HI-taxable) SE earnings
cse_orig.label(d) Total amount of covered (HI-taxable) SE earnings

cse_cmb_n_estf.label(d) Total amount of SE earnings taxable only by HI (b/c OASDI taxmax has been satisfied by wages of these combination workers)
cse_cmb_n_orig.label(d) Total amount of SE earnings taxable only by HI (b/c OASDI taxmax has been satisfied by wages of these combination workers)


'create easy-to-see comparisons of reported values and estimated finals
'this is useful when developing the code and the adjustment procedure
'if not needed in the final code, comment it out
group oasds_compare oasds_estf oasds_orig 
group taxse_compare taxse_estf taxse_orig 
group cmbover_compare cmbover_estf cmbover_orig 
group cse_compare cse_estf cse_orig 
group cse_cmb_n_compare cse_cmb_n_estf cse_cmb_n_orig

'display charts with the comparisons
'oasds_compare.line 
'taxse_compare.line  
'cmbover_compare.line  
'cse_compare.line  
'cse_cmb_n_compare.line


'***** Table 7C -- Taxable Earnings 1951 (=!yearearliest) to current
pagecreate(page=tab7c)  a !yearearliest !yearlast
pageselect tab7c

'load series form the previous-year workfile
wfopen %file_initial_path

'copy relevant series from Table 7C
copy %file_initial::tab7c\oasde_r* %file_output::tab7c\		
copy %file_initial::tab7c\hie_r* %file_output::tab7c\

wfclose %file_initial

'load new data from Bill's epoxy Excel file
import(page=tab7c) %epoxypath range="Table 7C" colhead=2 names=("year","oasde","col2","hie","col4") na="#N/A" @freq a @id @date(year) 

'rename appropriately and create labels
rename oasde oasde_r{!report_year}
oasde_r{!report_year}.label(d) Persons with OASDI-taxable earnings of any form (wages, SE, or both)
oasde_r{!report_year}.label(u) Number of people
oasde_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

rename hie hie_r{!report_year}
hie_r{!report_year}.label(d) Persons with HI-taxable earnings of any form (wages, SE, or both)
hie_r{!report_year}.label(u) Number of people
hie_r{!report_year}.label(r) from Dec {!report_year} Epoxy report

delete col*

'create oasdsw = workers with OASDI-taxable BOTH wages and SE income.
smpl !yearfirst !yearlast
for !y=!report_year_start to !report_year
	genr oasdsw_r{!y} = tab7a\oasdw_r{!y}+tab7b\oasds_r{!y}-tab7c\oasde_r{!y}
	oasdsw_r{!y}.label(d) Persons with *both* OASDI-taxable wages and OASDI-taxable SE
	oasdsw_r{!y}.label(u) Number of people
	oasdsw_r{!y}.label(r) from Dec {!y} Epoxy report
next

smpl @all


'compute the adjustment factors
'ratios of reported in yr t to reported in yr (t-1)
for %ser oasde hie oasdsw
	for !y=!first_report_year+1 to !report_year
		%yt=@str(!y)
		%yt1=@str(!y-1)
		series {%ser}_ratio_{!y} 	' create a ratio series filled with NAs
		
		smpl if {%ser}_r{%yt1} <> 0		' compute the ratio only if the denominator is not zero
		{%ser}_ratio_{!y}={%ser}_r{%yt}/{%ser}_r{%yt1}
		smpl @all
	next
next


if !report_year<2020 then		'can delete this entire IF statement when report_year=2020 or later.
	for !y=2013 to !report_year  	
		%yt=@str(!y)
		%yt1=@str(!y-1)
		genr oasde_ratio_{!y}=oasde_r{%yt}/oasde_r{%yt1}
		genr hie_ratio_{!y}=hie_r{%yt}/hie_r{%yt1}
		genr oasdsw_ratio_{!y}=oasdsw_r{%yt}/oasdsw_r{%yt1}
	next
endif

'manually adjust certain values to account for special adjustments in data for 1980s
'NOTE: if these adjustments continue in future reports, must add code here to account for them!!!!

for %ser oasde oasdsw hie 
	!r2016adj=0.5*(@elem({%ser}_ratio_2016, "1983")+@elem({%ser}_ratio_2016, "1987"))
	!r2017adj=0.5*(@elem({%ser}_ratio_2017, "1981")+@elem({%ser}_ratio_2017, "1985"))
	!r2018adj=0.5*(@elem({%ser}_ratio_2018, "1980")+@elem({%ser}_ratio_2018, "1986"))
	smpl 1981 1985
	{%ser}_ratio_2018 = !r2018adj
	smpl 1982 1984
	{%ser}_ratio_2017 = !r2017adj
	smpl 1984 1986
	{%ser}_ratio_2016 = !r2016adj
	smpl @all
next
' Manual adjustments to _ratio_2019 and _ratio_2020.
' These differ from series to series b/c of data availability (for some series data extends propr to 1978, for others it does not), so the formulas differ
' oasde
!r2019adj_oasde=0.5*(@elem(oasde_ratio_2019, "1977")+@elem(oasde_ratio_2019, "1981"))
smpl 1978 1980
oasde_ratio_2019 = !r2019adj_oasde
smpl @all
!r2020adj_oasde=0.5*(@elem(oasde_ratio_2020, "1975")+@elem(oasde_ratio_2020, "1978"))
smpl 1976 1977
oasde_ratio_2020 = !r2020adj_oasde
smpl @all
' oasdsw
!r2019adj_oasdsw=0.5*(@elem(oasdsw_ratio_2019, "1981")+@elem(oasdsw_ratio_2019, "1982")) ' ideally, I would have liked to do an average fo 1977 and 1981, but there is not data prior to 1978
smpl 1978 1980
oasdsw_ratio_2019 = !r2019adj_oasdsw
smpl @all
' No need to adjust oasdsw_ratio_2020 series because even if there are any changes, they would pply to years prior to 1978, where we have no data
' hie
!r2019adj_hie=0.5*(@elem(hie_ratio_2019, "1977")+@elem(hie_ratio_2019, "1981"))
smpl 1978 1980
hie_ratio_2019 = !r2019adj_hie
smpl @all
!r2020adj_hie=0.5*(@elem(hie_ratio_2020, "1975")+@elem(hie_ratio_2020, "1978"))
smpl 1976 1977
hie_ratio_2020 = !r2020adj_hie
smpl @all
' ** Manual adjustments done

'compute appropriate averages (this is dictated by available data)
if !report_year<2020 then
'!!!!! This section applies ONLY to report years prior to and including 2019
'In r2017 we have only three years of complete data, thus can complete only two ratios. 
'Once we get at least 6 years of complete data, switch to using the code included further below, which is marked accordingly.
	for %ser oasde hie oasdsw
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		
		!break_yr = !report_year - 10		' earliest yr for which we have enough  data for 5yr average
		smpl !yearfirst !break_yr-1		'years for which we do not enough data for 5yr average
		'Moving average for as many years as we have available
		if !report_year=2017 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1))/2	
		endif
		if !report_year=2018 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2))/3	
		endif
		if !report_year=2019 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2)+ {%r4}(-3))/4	
		endif	
		
		smpl !break_yr !yearlast		'years for which we have enough data for 5yr average
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
				
		smpl @all
		'final adjustment factor
		genr {%ser}_adj=@cumprod({%ser}_avg)  
	next

endif  	'!!!!! END of section that applies ONLY to report years prior to and including 2019.

smpl @all

'!!!!! Once we have at least SIX years of complete history (i.e. starting from report in 2020), use the code below to compute the final adjustment factor for ALL years. Remove the earlier code above that differentiates between recent and "old" years.  -- Polina Vlasenko 01-09-2018
if !report_year>2019 then
	smpl @all
	for %ser oasde hie oasdsw
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
		'final adjustment factor 
		genr {%ser}_adj=@cumprod({%ser}_avg)
	next
endif
'!!!! END of code to be used for report 2020 and after.

'change all NAs in the ..._adj series to 1. First 4 obs will be NAs b/c of how ratios are computed. Some other observations can be NAs for other reasons.
for %ser oasde hie oasdsw
	{%ser}_adj = @nan({%ser}_adj,1)
next
'ALL adjustment factors are computed and are named [series]_adj, i.e. oasdw_adj, hiw_adj, etc.

smpl @all
'compute estimated final values
'series that reflect number of WORKERS (people, not $)
for %ser oasde hie oasdsw
	genr {%ser}_estf=({%ser}_adj(-1)*{%ser}_r{!report_year})/1000000		'resulting value is in *millions of people*
	genr {%ser}_orig={%ser}_r{!report_year}/1000000
		smpl !yearearliest !yearearliest  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 {%ser}_estf={%ser}_orig
		 smpl @all
	{%ser}_estf.label(u) millions of people
	{%ser}_estf.label(r) estimated final value based on Dec {!report_year} Epoxy report
	{%ser}_orig.label(u) millions of people
	{%ser}_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
next

oasde_estf.label(d) Persons with OASDI-taxable earnings of any form (wages, SE, or both)
oasde_orig.label(d) Persons with OASDI-taxable earnings of any form (wages, SE, or both)

hie_estf.label(d) Persons with HI-taxable earnings of any form (wages, SE, or both)
hie_orig.label(d) Persons with HI-taxable earnings of any form (wages, SE, or both)

oasdsw_estf.label(d) Persons with *both* OASDI-taxable wages and OASDI-taxable SE
oasdsw_orig.label(d) Persons with *both* OASDI-taxable wages and OASDI-taxable SE

'create easy-to-see comparisons of reported values and estimated finals
'this is useful when developing the code and the adjustment procedure
'if not needed in the final code, comment it out
group oasde_compare oasde_estf oasde_orig 
group hie_compare hie_estf hie_orig 

'display charts with the comparisons
'oasde_compare.line 
'hie_compare.line  

'move oasdsw and all related measures to a separate workfile page
pagecreate(page=ws)  a !yearfirst !yearlast
pageselect ws
copy tab7c\oasdsw_* 
group oasdsw_compare oasdsw_estf oasdsw_orig 
'oasdsw_compare.line 

pageselect tab7c
delete oasdsw_*  'oasdsw and all releated measures are now stored in workfile page "ws" ONLY

smpl @all


'***** MQGE -- Medicare Qualified Government Employees
pagecreate(page=MQGE)  a !yearfirst !yearlast
pageselect MQGE

'create various MQGE measures
for !y=!report_year_start to !report_year
	genr mqgew_r{!y} = tab7a\hiw_r{!y} - tab7a\oasdw_r{!y}
	genr mqgee_r{!y} = tab7c\hie_r{!y} - tab7c\oasde_r{!y}
	genr mqges_r{!y} = mqgew_r{!y} - mqgee_r{!y}
next

mqgew_r{!report_year}.label(d) All Medicare-Qualified Government Employees (MQGE)
mqgew_r{!report_year}.label(u) Number of people
mqgew_r{!report_year}.label(r) from Dec {!report_year} Epoxy report
mqgew_r{!report_year}.label(r) These are people who have HI-taxable wages but no OASDI-taxable wages; they may also have SE earnings.

mqgee_r{!report_year}.label(d) Medicare-Qualified Government Employees (MQGE) who have wages only
mqgee_r{!report_year}.label(u) Number of people
mqgee_r{!report_year}.label(r) from Dec {!report_year} Epoxy report
mqgee_r{!report_year}.label(r) These are people who have HI-taxable earnings of any form but no OASDI-taxable earnings of any form, i.e. they can only have HI-taxable wages.

mqges_r{!report_year}.label(d) Medicare-Qualified Government Employees (MQGE) who also have SE earnings
mqges_r{!report_year}.label(u) Number of people
mqges_r{!report_year}.label(r) from Dec {!report_year} Epoxy report
mqges_r{!report_year}.label(r) These are people who have HI-taxable (but not OASDI-taxable) wages and OASDI-taxable (and HI-taxable) SE.


'compute the adjustment factors
'ratios of reported in yr t to reported in yr (t-1)
for %ser mqgew mqgee mqges
	for !y=!first_report_year+1 to !report_year
		%yt=@str(!y)
		%yt1=@str(!y-1)
		series {%ser}_ratio_{!y} 	' create a ratio series filled with NAs
		
		smpl if {%ser}_r{%yt1} <> 0		' compute the ratio only if the denominator is not zero
		{%ser}_ratio_{!y}={%ser}_r{%yt}/{%ser}_r{%yt1}
		smpl @all
	next
next

if !report_year<2020 then		'can delete this entire IF statement when report_year=2020 or later.
	for !y=2013 to !report_year  	
		%yt=@str(!y)
		%yt1=@str(!y-1)
		genr mqgew_ratio_{!y}=mqgew_r{%yt}/mqgew_r{%yt1}
		genr mqgee_ratio_{!y}=mqgee_r{%yt}/mqgee_r{%yt1}
		genr mqges_ratio_{!y}=mqges_r{%yt}/mqges_r{%yt1}
	next
endif


'compute appropriate averages (this is dictated by available data)
if !report_year<2020 then
'!!!!! This section applies ONLY to report years prior to and including 2019
'In r2017 we have only three years of complete data, thus can complete only two ratios. 
'Once we get at least 6 years of complete data, switch to using the code included further below, which is marked accordingly.
	for %ser mqgew mqgee mqges
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		
		!break_yr = !report_year - 10		' earliest yr for which we have enough  data for 5yr average
		smpl !yearfirst !break_yr-1		'years for which we do not enough data for 5yr average
		'Moving average for as many years as we have available
		if !report_year=2017 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1))/2	
		endif
		if !report_year=2018 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2))/3	
		endif
		if !report_year=2019 then
			genr {%ser}_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2)+ {%r4}(-3))/4	
		endif	
		
		smpl !break_yr !yearlast		'years for which we have enough data for 5yr average
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
				
		smpl @all
		'final adjustment factor -- for these series (MQGE) we do cumulative product of only the last 10 elements. 
		genr {%ser}_avg_mod={%ser}_avg
		smpl !yearfirst !yearlast-10
		genr {%ser}_avg_mod=1
		smpl @all
		genr {%ser}_adj=@cumprod({%ser}_avg_mod)  
		delete {%ser}_avg_mod
	next
endif  	'!!!!! END of section that applies ONLY to report years prior to and including 2019.

smpl @all

'!!!!! Once we have at least SIX years of complete history (i.e. starting from report in 2020), use the code below to compute the final adjustment factor for ALL years. Remove the earlier code above that differentiates between recent and "old" years.  -- Polina Vlasenko 01-09-2018
if !report_year>2019 then
	smpl @all
	for %ser mqgew mqgee mqges
		'series to be averaged
		%r1=%ser+"_ratio_"+@str(!report_year)
		%r2=%ser+"_ratio_"+@str(!report_year-1)
		%r3=%ser+"_ratio_"+@str(!report_year-2)
		%r4=%ser+"_ratio_"+@str(!report_year-3)
		%r5=%ser+"_ratio_"+@str(!report_year-4)
		'5yr average
		genr {%ser}_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
		'final adjustment factor -- for these series (MQGE) we do cumulative product of only the last 10 elements. 
		genr {%ser}_avg_mod={%ser}_avg
		smpl !yearfirst !yearlast-10
		genr {%ser}_avg_mod=1
		smpl @all
		genr {%ser}_adj=@cumprod({%ser}_avg_mod)  
		delete {%ser}_avg_mod
	next
endif  	'!!!! END of code to be used for report 2020 and after.


'change all NAs in the ..._adj series to 1. First 4 obs will be NAs b/c of how ratios are computed. Some other observations can be NAs for other reasons.
for %ser mqgew mqgee mqges
	{%ser}_adj = @nan({%ser}_adj,1)
next
'ALL adjustment factors are computed and are named [series]_adj, i.e. oasdw_adj, hiw_adj, etc.

smpl @all
'compute estimated final values
'series that reflect number of WORKERS (people, not $)
for %ser mqgew mqgee mqges
	genr {%ser}_estf=({%ser}_adj(-1)*{%ser}_r{!report_year})/1000000		'resulting value is in *millions of people*
	genr {%ser}_orig={%ser}_r{!report_year}/1000000
		smpl !yearfirst !yearfirst  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 {%ser}_estf={%ser}_orig
		 smpl @all
	{%ser}_estf.label(u) millions of people
	{%ser}_estf.label(r) estimated final value based on Dec {!report_year} Epoxy report
	{%ser}_orig.label(u) millions of people
	{%ser}_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
next

mqgew_estf.label(d) All Medicare-Qualified Government Employees (MQGE)
mqgew_estf.label(r) These are people who have HI-taxable wages but no OASDI-taxable wages; they may also have SE earnings.
mqgew_orig.label(d) All Medicare-Qualified Government Employees (MQGE)
mqgew_orig.label(r) These are people who have HI-taxable wages but no OASDI-taxable wages; they may also have SE earnings.

mqgee_estf.label(d) Medicare-Qualified Government Employees (MQGE) who have wages only
mqgee_estf.label(r) These are people who have HI-taxable earnings of any form but no OASDI-taxable earnings of any form, i.e. they can only have HI-taxable wages.
mqgee_orig.label(d) Medicare-Qualified Government Employees (MQGE) who have wages only
mqgee_orig.label(r) These are people who have HI-taxable earnings of any form but no OASDI-taxable earnings of any form, i.e. they can only have HI-taxable wages.

mqges_estf.label(d) Medicare-Qualified Government Employees (MQGE) who also have SE earnings
mqges_estf.label(r) These are people who have HI-taxable (but not OASDI-taxable) wages and OASDI-taxable (and HI-taxable) SE.
mqges_orig.label(d) Medicare-Qualified Government Employees (MQGE) who also have SE earnings
mqges_orig.label(r) These are people who have HI-taxable (but not OASDI-taxable) wages and OASDI-taxable (and HI-taxable) SE.

'create easy-to-see comparisons of reported values and estimated finals
group mqgew_compare mqgew_estf mqgew_orig 
group mqgee_compare mqgee_estf mqgee_orig 
group mqges_compare mqges_estf mqges_orig 

'display charts with the comparisons
'mqgew_compare.line 
'mqgee_compare.line 
'mqges_compare.line 

'***** Workers with No HI wages
pagecreate(page=NoHI_wages)  a !yearfirst !yearlast
pageselect NoHI_wages

'load series form the previous-year workfile
wfopen %file_initial_path

'copy relevant series from page NoHI_wages
copy %file_initial::NoHI_wages\mefw_r* %file_output::NoHI_wages\		
'copy %file_initial::NoHI_wages\nohiw_r* %file_output::NoHI_wages\

wfclose %file_initial

'load new data from Bill's epoxy Excel file
import(page=NoHI_wages) %epoxypath range="Table 8" colhead=2 names=("year","mefw","col2","col3","col4", "col5", "col6") na="#N/A" @freq a @id @date(year) 

'rename appropriately
rename mefw mefw_r{!report_year}
mefw_r{!report_year}.label(d) Wage earners with compensation greater than zero
mefw_r{!report_year}.label(u) Number of people
mefw_r{!report_year}.label(r) from Dec {!report_year} Epoxy report
mefw_r{!report_year}.label(r) *Compensation* here includes not only wages, but also deferred compensation contributions

delete col2 col3 col4 col5 col6

'generate NoHI_wage workers
for !y=!report_year_start to !report_year
	genr nohiw_r{!y} = mefw_r{!y} - tab7a\hiw_r{!y}
	nohiw_r{!y}.label(d) Wage earners with no HI-taxable wages
	nohiw_r{!y}.label(u) Number of people
	nohiw_r{!y}.label(r) from Dec {!y} Epoxy report
	nohiw_r{!y}.label(r) These are people who have wage compensation (wages or deferred compensation contributions) but none of it is taxable by HI.
next


'compute the adjustment factor and create estimated final for nohiw (this is workers, not $)
'ratios of reported in yr t to reported in yr (t-1)

for !y=!first_report_year+1 to !report_year  	
	%yt=@str(!y)
	%yt1=@str(!y-1)
	series nohiw_ratio_{!y} 	' create a ratio series filled with NAs
		
	smpl if nohiw_r{%yt1} <> 0		' compute the ratio only if the denominator is not zero
	nohiw_ratio_{!y}=nohiw_r{%yt}/nohiw_r{%yt1}
	smpl @all
next

'manually adjust certain values to account for special adjustments in data for 1980s
'NOTE: if these adjustments continue in future reports, must add code here to account for them!!!!
	!r2016adj=0.5*(@elem(nohiw_ratio_2016, "1983")+@elem(nohiw_ratio_2016, "1987"))
	!r2017adj=0.5*(@elem(nohiw_ratio_2017, "1981")+@elem(nohiw_ratio_2017, "1985"))
	!r2018adj=0.5*(@elem(nohiw_ratio_2018, "1979")+@elem(nohiw_ratio_2018, "1983"))
	!r2019adj=0.5*(@elem(nohiw_ratio_2019, "1981")+@elem(nohiw_ratio_2019, "1982"))	' ideally, this should be the average of 1977 an 1981, but there is no data prior to 1978
	' no need for adjustments to nohiw_ratio_2020; even if adjustment took place, they were for years prior to 1978, for which we have no data
	smpl 1984 1986
	nohiw_ratio_2016 = !r2016adj
	smpl 1982 1984
	nohiw_ratio_2017 = !r2017adj
	smpl 1981 1982
	nohiw_ratio_2018 = !r2018adj
	smpl 1978 1980
	nohiw_ratio_2019 = !r2019adj
	smpl @all
' end of manual adjustments


if !report_year<2020 then		'can delete this entire IF statement when report_year=2020 or later.
	for !y=2013 to !report_year  	
		%yt=@str(!y)
		%yt1=@str(!y-1)
		genr nohiw_ratio_{!y}=nohiw_r{%yt}/nohiw_r{%yt1}
	next
endif


'compute appropriate averages (this is dictated by available data)
if !report_year<2020 then
'!!!!! This section applies ONLY to report years prior to and including 2019
'In r2017 we have only three years of complete data, thus can complete only two ratios. 
'Once we get at least 6 years of complete data, switch to using the code included further below, which is marked accordingly.

		'series to be averaged
		%r1="nohiw_ratio_"+@str(!report_year)
		%r2="nohiw_ratio_"+@str(!report_year-1)
		%r3="nohiw_ratio_"+@str(!report_year-2)
		%r4="nohiw_ratio_"+@str(!report_year-3)
		%r5="nohiw_ratio_"+@str(!report_year-4)
		
		!break_yr = !report_year - 10		' earliest yr for which we have enough  data for 5yr average
		smpl !yearfirst !break_yr-1		'years for which we do not enough data for 5yr average
		'Moving average for as many years as we have available
		if !report_year=2017 then
			genr nohiw_avg = ({%r1} + {%r2}(-1))/2	
		endif
		if !report_year=2018 then
			genr nohiw_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2))/3	
		endif
		if !report_year=2019 then
			genr nohiw_avg = ({%r1} + {%r2}(-1)+ {%r3}(-2)+ {%r4}(-3))/4	
		endif	
		
		smpl !break_yr !yearlast		'years for which we have enough data for 5yr average
		'5yr average
		genr nohiw_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
				
		smpl @all
		'final adjustment factor -- for these series (MQGE) we do cumulative product of only the last 10 elements. 
		genr nohiw_avg_mod=nohiw_avg
		smpl !yearfirst !yearlast-10
		genr nohiw_avg_mod=1
		smpl @all
		genr nohiw_adj=@cumprod(nohiw_avg_mod)  
		delete nohiw_avg_mod

endif  	'!!!!! END of section that applies ONLY to report years prior to and including 2019.

smpl @all

'!!!!! Once we have at least SIX years of complete history (i.e. starting from report in 2020), use the code below to compute the final adjustment factor for ALL years. Remove the earlier code above that differentiates between recent and "old" years.  -- Polina Vlasenko 01-09-2018
if !report_year>2019 then
	smpl @all
	'series to be averaged
	%r1="nohiw_ratio_"+@str(!report_year)
	%r2="nohiw_ratio_"+@str(!report_year-1)
	%r3="nohiw_ratio_"+@str(!report_year-2)
	%r4="nohiw_ratio_"+@str(!report_year-3)
	%r5="nohiw_ratio_"+@str(!report_year-4)
	'5yr average
	genr nohiw_avg = ({%r1} + {%r2}(-1) + {%r3}(-2)+ {%r4}(-3)+ {%r5}(-4))/5
	'final adjustment factor -- for these series (MQGE) we do cumulative product of only the last 10 elements. 
	genr nohiw_avg_mod=nohiw_avg
	smpl !yearfirst !yearlast-10
	genr nohiw_avg_mod=1
	smpl @all
	genr nohiw_adj=@cumprod(nohiw_avg_mod)  
	delete nohiw_avg_mod
endif
'!!!! END of code to be used for report 2020 and after.

'change all NAs in the ..._adj series to 1. First 4 obs will be NAs b/c of how ratios are computed. Some other observations can be NAs for other reasons.
nohiw_adj = @nan(nohiw_adj,1)

smpl @all
'compute estimated final values

genr nohiw_estf=(nohiw_adj(-1)*nohiw_r{!report_year})/1000000		'resulting value is in *millions of people*
genr nohiw_orig=nohiw_r{!report_year}/1000000
		smpl !yearfirst !yearfirst  '	first year in the sample we assume adj factor of 1, thus set estf=orig
		 nohiw_estf=nohiw_orig
		 smpl @all
nohiw_estf.label(u) millions of people
nohiw_estf.label(r) estimated final value based on Dec {!report_year} Epoxy report
nohiw_estf.label(d) Wage earners with no HI-taxable wages
nohiw_estf.label(r) These are people who have wage compensation (wages or deferred compensation contributions) but none of it is taxable by HI.

nohiw_orig.label(u) millions of people
nohiw_orig.label(r) as originally reported in Dec {!report_year} Epoxy report
nohiw_orig.label(d) Wage earners with no HI-taxable wages
nohiw_orig.label(r) These are people who have wage compensation (wages or deferred compensation contributions) but none of it is taxable by HI.


'create and disply comparisons of reported values and estimated finals
group nohiw_compare nohiw_estf nohiw_orig 
'nohiw_compare.line

'***** Load historical data (starting in 1951) for some series from The Buckler Report pages
' Series we are interested in: 
' "Total having SE in the year" -- we call this cse_m
' " Equal to maximum for the current year" -- we call this atmax and use it to compute cmb_over
pagecreate(page=hist_data)  a !yearearliest !yearlast

'CSE_M values for 1951 through 1977 workers with OASDI taxable SE are from pages 2-3 in EPOXY report 
' They are placed in the HIST_DATA Page, and then used for CSE_M values for the pre-1978 period in the est_finals page

wfopen(wf=tab23, page=tab23) %epoxypath range="Pages 2-3" colhead=2 na="#N/A" @id @smpl @all
!lastline=(!yearlast-1950)*5-1 'the last line in Epoxy "Pages 2-3" that should be read in (the file gets longer with every new year of data added)
for !j= 4 to !lastline step 5
  	smpl !j !j
     genr dum=1
next
pagecopy(smpl=if dum=1, dataonly, nolinks) fica_number
smpl 1 1
genr year=!yearlast
smpl 2 !yearlast-1950
genr year=year(-1) -1
pagestruct @date(year)
copy tab23 
pagerename Untitled se
wfselect %file_output
pageselect hist_data
copy TAB23::SE\FICA_NUMBER *
rename fica_number fica_number_se
genr se_adjusted=fica_number_se*0.99
wfclose tab23

fica_number_se.label(d) Persons with OASDI-taxable SE earnings in the year
fica_number_se.label(u) Number of people
fica_number_se.label(r) as reported in Dec {!report_year} Epoxy report (the Buckler report)

se_adjusted.label(d) Persons with OASDI-taxable SE earnings in the year
se_adjusted.label(u) Number of people
se_adjusted.label(r) adjusted from Dec {!report_year} Epoxy report (the Buckler report) to reflect estimated final

'CMB_OVER for 1951 through 1993 workers with Covered SE that is not taxable because of wages at the taxable maximum. 
' They are placed in the HIST_DATA page, and then used for CMB_OVER for the 1951 through 1993 period.

wfopen(wf=tab23, page=tab23) %epoxypath range="Pages 2-3" colhead=2 na="#N/A" @id @smpl @all
for !j= 1 to !lastline step 5
  	smpl !j !j
     genr dum=1
next
pagecopy(smpl=if dum=1, dataonly, nolinks) fica_number
smpl 1 1
genr year=!yearlast
smpl 2 !yearlast-1950
genr year=year(-1)-1
pagestruct @date(year)
copy tab23 
pagerename Untitled atmax
wfselect %file_output
pageselect hist_data
copy TAB23::ATMAX\FICA_NUMBER *
rename fica_number fica_number_atmax
genr cmb_over_e=tab7b\cmbover_estf
genr cmb_over_h=fica_number_atmax*(@elem(cmb_over_e,1994)/@elem(fica_number_atmax,1994))
genr cmb_over_coef=cmb_over_e/fica_number_atmax 'this series shows the ratio that is used as the coefficient on the line above; the line above uses ONLY 1994 value, the series allows us to see how the value changed over time to determine if 1994 value is reasonable.
wfclose tab23

fica_number_atmax.label(d) Persons with earnings (wages and/or SE) at or above the taxmax for the year
fica_number_atmax.label(u) Number of people
fica_number_atmax.label(r) as reported in Dec {!report_year} Epoxy report (the Buckler report)

cmb_over_e.label(d) Combination workers (people with wages and SE) whose wages exceed the taxmax
cmb_over_e.label(u) millions of people
cmb_over_e.label(r) These people have covered SE that is not taxable because of wages at the taxable maximum

cmb_over_h.label(d) Combination workers (people with wages and SE) whose wages exceed the taxmax
cmb_over_h.label(u) millions of people
cmb_over_h.label(r) These people have covered SE that is not taxable because of wages at the taxable maximum
cmb_over_h.label(r) This number is estimated by adjusting fica_number_atmax; see cmb_over_coef for the adjustment factor.

cmb_over_coef.label(r) The adjustment factor used to obtain cmb_over_h. 
cmb_over_coef.label(r) Value in 1994 is used at the adjustment. 
cmb_over_coef.label(r) Check the history of the series to see if 1994 value is reasonable. 
 
'****************************
'***** ESTIMATED FINALS
pagecreate(page=est_finals) a !yearearliest !yearlast

	'OASDI Covered Worker Concepts:
smpl !yearfirst !yearlast
	genr cew_m=tab7a\oasdw_estf
	genr ces_m=tab7b\oasds_estf
	genr cesw_m=ws\oasdsw_estf
	genr ce_m=cew_m+ces_m-cesw_m
	genr ceso_m=ces_m-cesw_m
	genr cewo_m=cew_m-cesw_m
	
	'labels
	cew_m.label(d) Persons with OASDI-taxable wages posted to MEF
	cew_m.label(u) millions of people
	cew_m.label(r) cew_m is *c*overed *e*mployment *w*age workers posted to *m*ef
	
	ces_m.label(d) Persons with OASDI-taxable SE earnings posted to MEF
	ces_m.label(u) millions of people
	ces_m.label(r) ces_m is *c*overed *e*mployment *s*elf-employed workers posted to *m*ef
	
	cesw_m.label(d) Persons with *both* OASDI-taxable wages and OASDI-taxable SE posted to MEF
	cesw_m.label(u) millions of people
	cesw_m.label(r) cesw_m is *c*overed *e*mployment with *s*elf-employment and *w*ages posted to *m*ef
	
	ce_m.label(d) Persons with any OASDI-taxable earnings (wages, SE, or both) posted to MEF
	ce_m.label(u) millions of people
	ce_m.label(r) ce_m is *c*overed *e*mployment posted to *m*ef
	
	ceso_m.label(d) Persons with OASDI-taxable SE earnings *only* posted to MEF
	ceso_m.label(u) millions of people
	ceso_m.label(r) ceso_m is *c*overed *e*mployees with *s*elf-employment income *o*nly posted to *m*ef
	
	cewo_m.label(d) Persons with OASDI-taxable wages *only* posted to MEF
	cewo_m.label(u) millions of people
	cewo_m.label(r) cewo_m is *c*overed *e*mployees with *w*ages *o*nly posted to *m*ef
	
smpl 1994 !yearlast
     genr cmb_over=tab7b\cmbover_estf
     genr cse=tab7b\cse_estf
     genr cse_cmb_n=tab7b\cse_cmb_n_estf
     
     'labels
     	cmb_over.label(d) Combination workers (people with wages and SE) whose wages exceed the taxmax
	cmb_over.label(u) millions of people

	cse.label(d) Total amount of HI-taxable SE earnings (i.e. covered SE)
	cse.label(u) $ billions
	cse.label(r) cse is *c*overed *s*self *e*mployment
	
	cse_cmb_n.label(d) Total amount of SE earnings taxable only by HI (b/c OASDI taxmax has been satisfied by wages of these combination workers)
	cse_cmb_n.label(u) $ billions
	cse_cmb_n.label(r) cse_cmb_n is *c*overed *s*self *e*mployment of combination workers (cmb) *n*ot taxable by OASDI


'***** Data prior to 1978 are obtained in various other ways
	'Values are from COV141125.xls in the econ server processed data covdata folder.
smpl 1971 1993
     cse.adjust = 50.410 57.620 66.980 69.280 70.410 76.750 80.780 94.020 100.610 97.850 98.740 98.640 109.850 128.200 141.840 158.590 179.900 199.700 210.900 193.800 195.500 206.800 214.000
	cse_cmb_n.adjust = 5.927 6.078 5.571 4.851 5.444 5.822 5.852 8.062 6.714 5.817 5.896 6.167 6.088 6.595 7.739 8.791 10.702 13.206 12.725 12.109 12.447 13.932 13.971

smpl 1951 1993
	genr cmb_over=hist_data\cmb_over_h

	'FOR REFERENCE: Data from Annual Statistical Supplement 
     'ces_m.adjust = 4190 4240 4340 4350 6810 7390 7150 7130 7060 6870 6790 6720 6590 6480 6550 6630 6470 6570 6350 6270 6290 6600 7100 7040 7000 7400 7480

	'FOR REFERENCE: Old Skirvin method for CESW_M is based on 1% CWHS EE-ER file ratio of CESW/CES times MEF CES_M.
     'SMPL 1951 1970
	'cesw_m.adjust = 2.642958 2.700721 2.680646 2.707252 4.767983 4.899302 4.637134 4.602639 4.712000 4.595733 4.558942 4.336905 4.147132 3.938248 3.765026 4.242863 3.897522 1.546240 1.532643 1.401542
	'SMPL 1971 1977
     'cesw_m.adjust = 1.390028 1.570631 1.851759 1.858876 1.834982 1.979599 1.986225

	smpl 1951 1977	
	genr ces_m=hist_data\se_adjusted/1000000
 	genr ce_m=tab7c\oasde_estf

	'Historical wages are from Annual Statistical Supplement.  This is a change from Pat's method using the CWHS.  However, since we are using 100% epoxy now for SE and Earnings, we are switching to the supplement.
	cew_m.adjust =54630 56060 57220 55940 59560 61560 64730 64040 66000 66980 67360 68890 70310 72230 75430 79460 82020 84470 87200 88180 88460 91220 94610 96190 94900 97230 100450
	genr cew_m=cew_m/1000

	cesw_m=ces_m+cew_m-ce_m 
     cewo_m=cew_m-cesw_m
	ceso_m=ces_m-cesw_m
smpl @all


'HI Concepts 1978 to present:

	'Medicare Qualified Government Employees(MQGE) with no OASDI wages concepts:

smpl 1978 !yearlast
	genr mqge=MQGE\mqgew_estf
	genr mqge_wse=MQGE\mqges_estf
	genr mqge_wose=mqge-mqge_wse

	'HI Covered Worker Concepts:
	genr he_m=ce_m+mqge_wose
	genr hew_m=cew_m+mqge
	genr hesw_m=cesw_m+cmb_over+mqge_wse
	genr heso_m=he_m-hew_m
	genr hes_m=heso_m+hesw_m
	genr hewo_m=he_m-hes_m
	
	'labels
	mqge.label(d) All Medicare-Qualified Government Employees (MQGE)
	mqge.label(u) millions of people

	mqge_wse.label(d) Medicare-Qualified Government Employees (MQGE) who also have SE earnings
	mqge_wse.label(u) millions of people
	mqge_wse.label(r) mqge_wse = *MQGE* *w*ith *SE* earnings

	mqge_wose.label(d) Medicare-Qualified Government Employees (MQGE) who have wages only
	mqge_wose.label(u) millions of people
	mqge_wose.label(r) mqge_wose = *MQGE* *w*ith*o*ut *SE* earnings
	
	he_m.label(d) Persons with any HI-taxable earnings (wages, SE, or both) posted to MEF
	he_m.label(u) millions of people
	he_m.label(r) Includes people with OADSI-taxable earnings plus MQGE with wages only
	he_m.label(r) he_m is *H*I-covered *e*mployment posted to *m*ef
	
	hew_m.label(d) Persons with HI-taxable wages posted to MEF
	hew_m.label(u) millions of people
	hew_m.label(r) Includes people with OASDI-taxable wages plus MQGE
	hew_m.label(r) hew_m is *H*I -covered *e*mployment *w*age workers posted to *m*ef
	
	hesw_m.label(d) Persons with *both* HI-taxable wages and HI-taxable SE posted to MEF
	hesw_m.label(u) millions of people
	hesw_m.label(r) Includes people with HI-taxable wages and HI-taxable SE (including those whose wages exceed taxmax) plus MQGE with SE
	hesw_m.label(r) hesw_m is *H*I -covered *e*mployment with *s*elf-employment and *w*ages posted to *m*ef
	
	heso_m.label(d) Persons with HI-taxable SE earnings *only* posted to MEF
	heso_m.label(u) millions of people
	heso_m.label(r) heso_m is *H*I -covered *e*mployment with *S*E earnings *o*nly posted to *m*ef
	
	hes_m.label(d) Persons with HI-taxable SE earnings posted to MEF
	hes_m.label(u) millions of people
	hes_m.label(r) Some of these people also have HI-taxable wages
	hes_m.label(r) hes_m is *H*I -covered *e*mployment with *S*E earnings posted to *m*ef

	hewo_m.label(d) Persons with HI-taxable wages *only* posted to MEF
	hewo_m.label(u) millions of people
	hewo_m.label(r) hewo_m is *H*I -covered *e*mployment with *w*ages *o*nly posted to *m*ef
	
	
'HI Concepts 1966 to 1977:
smpl 1966 1977
	genr mqge=0
	genr mqge_wse=0
	genr mqge_wose=0

	genr he_m=ce_m+mqge_wose
	genr hew_m=cew_m+mqge
	genr hesw_m=cesw_m+mqge_wse
	genr heso_m=he_m-hew_m
	genr hes_m=heso_m+hesw_m
	genr hewo_m=he_m-hes_m

'No HI Wages
smpl @all
	genr nohiw_m=NoHI_wages\nohiw_estf
	
	nohiw_m.label(d) Wage earners with no HI-taxable wages posted to MEF
	nohiw_m.label(u) millions of people
	nohiw_m.label(r) nohiw_m is people with *no HI*-taxable *w*ages posted to *m*ef

	'Groups
	group ce cew_m ces_m cesw_m cewo_m ceso_m ce_m cmb_over 
	group hi mqge mqge_wse mqge_wose hew_m hes_m hesw_m heso_m hewo_m he_m
	group te nohiw_m

'FOR Bill: est_taxables
pagecreate(page=est_taxables) a !yearfirst !yearlast
	copy tab7a\oasdtw_r{!report_year}
	copy tab7a\oasdtw_estf
	copy tab7a\hi_l_OASDIw_estf
     copy tab7a\hi_l_OASDIw_r{!report_year}
	copy tab7b\taxse_r{!report_year}
	copy tab7b\taxse_estf
     copy tab7b\cse_r{!report_year}
	copy tab7b\cse_estf
	copy tab7b\cse_cmb_n_r{!report_year}
     copy tab7b\cse_cmb_n_estf


smpl @all
pageselect est_finals

'		make summary spool
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The file contains the estimated final amounts for various concepts to be included in the MEF bank."
string line3 = "The file combines data from an earlier Epoxy MEF workfile " + %file_initial_path + " with new data from EPOXY file " + %epoxypath 
string line4 = "The new EPOXY file " + %epoxypath + " contains data reported in Dec of " + @str(!report_year)
string line5 = "Estimated final amounts for MEF concepts are located in 'est_finals' page."
string line6 = "Other pages contain data as reported in past EPOXY reports. Groups with names ending in ..._compare show comparison between originally-reported data and estimated final amounts for various MEF concepts."

'string line7 = "Polina Vlasenko"

_summary.insert line1 line2 line3 line4 line5 line6
_summary.display

delete line*

if %sav = "Y" then
	wfsave %file_output_path
endif

'wfclose


