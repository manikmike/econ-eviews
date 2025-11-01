' This program updates the ESF (suspense file) data by loading data from the latest report, computing the relevant ratios, and then computing the final ESF total wages.
'It also computes employment and wages for categories within the ESF and creates 'Table 1. Wage and Employment Estimates for the Master Earnings File and the Earnings Suspense File, 1951 on" 
'The program loads relevant MEF data directly from the relevant databanks/workfiles

'Table named "table1" present a summary of the resulting series
'Group 'group1' allows user to see these series in an unformatted view

'Polina Vlasenko 11-28-2017

'	Updated to TR2019 data and file locations 
' 	Added manual adjustment to series ratio_2018 (similar to how they were done to ratio_2017 and others) -- this is needed to account for the data cleanup efforts done by Systems.
' 	Also added an automated check for these data anomalies that mighh require manual adjustment. 

' Polina Vlasenko 11-09-2018

'	Adjusted how Estimated Final wage amounts are computed (line 151):
'	multiply the latest reported values by cumulative product LAGGED one period.
'	Polina Vlasenko 02-08-2019

' 10/29/2019 -- updating for TR20
' Polina Vlasenko
' Result: even without updating govsector and Charts, can run the program partially to check for the evidence of "data cleanup" effect.
' It is there. Series ratio_2019 has an unusually low value in 1979 (0.943) and 1980 (0.9865) while all values right before and right after are on the order of 0.999. 
' NEED to do manual adjustment -- take the average of 1978 and 1981 and plce that value for 1979 and 1980.

' Manual adjustment due to 'data cleanup' effort by System
' In the last few years, Systems undertook an effort to place records in ESF (from many years ago) into MEF when they can be identified. This results in historical data from years ago changing significantly more than woul happen in the cours eof normal reporting.
' To eliminate the effect of this unusual data adjustment on our historical ratio series, we adjuste the ratio resies manually .
' The following adjustment have been done (see lines following line 129 -- "MANUAL adjustments"):
'  For report year 2011: set value for ratio_2011 for years 1995-98 to the average of values in 1994 and 1999 (newly added to code in Oct2021)
'  For report year 2012: set value for ratio_2012 for years 1994-96 to the average of values in 1993 and 1997 (newly added to code in Oct2021)
'  For report year 2013: set value for ratio_2013 for years 1991-94 to the average of values in 1990 and 1995
'  For report year 2014: set value for ratio_2014 for years 1989-91 to the average of values in 1988 and 1992
'  For report year 2015: set value for ratio_2015 for years 1987-88 to the average of values in 1986 and 1989
'  For report year 2016: set value for ratio_2016 for years 1985-86 to the average of values in 1984 and 1987
'  For report year 2017: set value for ratio_2017 for years 1982-84 to the average of values in 1981 and 1985
'  For report year 2018: set value for ratio_2018 for years 1981-82 to the average of values in 1980 and 1983
'  For report year 2019: set value for ratio_2019 for years 1979-80 to the average of values in 1978 and 1981
'  For report year 2020: set value for ratio_2020 for years 1976-78 to the average of values in 1975 and 1979

' Before running the program the user should update the necessary values in the UPDATE section marked with *****

'!!!!!!!!!!!!!!!!!!!!!!!
'	To check if any manual adjutsments are needed, look at the table named check_rXXXX in the workfile (where XXXX is the report year). 
' 	The table will show the suspect observations -- look at the full series ratio_XXXX to see if the values require manual adjustments. 
'	If so, add those to the code below (followng the line 141 -- "MANUAL adjustments").
'	The table named check_rXXXX_adj shows the check AFTER the manual adjustment have been applied. It should be empty. If not, take a careful look at series ratio_XXXX to confirm that the intended manual adjustment were applied!
' 	!!!!! If manual adjustment is applied -- include a description in the notes above AND in the _summary spool at the end of the program !!!!!
'!!!!!!!!!!!!!!!!!!!!!!!

'**** UPDATE these entries before running the program
%userid = @env("username")

'years covered by the ESF report
!yearfirst = 1937 'not likely to change 
!yearlast = 2023 'last year of DATA in the LATEST ESF report, file for which is given below in %file_newdata

!first_report_year =1998 'not likely to change
!report_year = 2024 'year of the latest ESF REPORT, file for which is given below in %file_newdata
'EXAMPLE:  the report that comes out in 2017 has data covering 1937-2016; thus !yearlast=2016 and !report_year=2017

'raw data file with the latest ESF report
%file_newdata ="\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Raw\ESF\HistoricalW-2Reports\q_rpt7100_00_20241010.xlsx" 'full path; updated for special2		

'workfiles with processed ESF data have names of the form 'esf_rpt_[report_year].wf1', e.g. esf_rpt_2016.wf1
'previous-year ESF data
%file_initial = "esf_rpt_"+@str(!report_year-1) 'name
%file_initial_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\ESF\TR2024\"+%file_initial+".wf1" 'full path; updated for special2

'Files with other data we need to compute various wage measures
'Epoxy workfile that contains cew_m
%file_epoxy = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\epoxy_r2023.wf1" 'full path; updated for special
%page_epoxy = "est_finals" 'page within epoxy workfile that contaions cew_m

'Gov sector workfile
%file_gov = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\govtsector\govtsector202410.wf1" 'full path; updated for special
%page_gov = "govtsectormef" 'page within gov sector workfile that conmtains the required series (wefc_n and wesl_n_hi)

'Charts and 941 data - use the latest "Charts" file available (see 'From OFPO" folder
%file_charts = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\QtrlyTrustFundLetter\doc\202412\FromOFPO\Draft Charts 2024.3.xlsx" ' full path to the "Charts" file
%tb = "Comparison Chart  2024-3" 	' name of the sheet in the "Charts" file that contains data; this will change for every data release (hopefully, only the date will change)
											' !!! Note: the program assumes that the last 6 symbols in this name denote YEAR-Q, and it uses this assumption to figure out the relevant years in the code below.

'EstFinTaxEarn file
%file_EstFinTaxEarn= "C:\Users\"+%userid+"\GitRepos\econ-taxearn\EstFinTaxEarn.wf1" 	 ' full path and filename
%page_EstFinTaxEarn="20241031_r" 		'page withing the file; this determines which vintage of data is to be used

'output produced by this program 
%file_output="esf_rpt_"+@str(!report_year) 'the workfile will be called esf_rpt_2017.wf1 to denote that is it based on the REPORT issued in 2017 
%file_output_path="\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\ESF\TR2025\"+%file_output+".wf1" 'full path,

' Do you want the output file(s) to be saved on this run? 
' Enter N for testing runs.
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "Y" 		' enter "N" or "Y" case sensitive

'**** END of the UPDATE section

' Add notes for the run if any are needed
%note1 = "Table check_r2024 shows a value for year 2022 -- this is a result of A LOT more wages for year 2022 being reported in the ESF-2024-report. " + _
					" This appears to be a genuine data event, and not an evidence of any data cleanup effort. " + _
					"Therefore, no manual adjustment is needed to account for this, and table check_r2024_adj should be non-empty (showing the same value as table check_r2024)."

'create the new workfile with appropriare paramenter
wfcreate(wf=%file_output, page=data ) a !yearfirst !yearlast

'load series form the previous-year SF workfile
wfopen %file_initial_path
copy %file_initial::data\esftw* %file_output::data\esftw*
copy %file_initial::data\wsca_hist93 %file_output::data\ 'data for wsca in 1951-1993 (it should not change from one TR to the next)
wfclose %file_initial

'import  the new series from the latest SF report 
wfselect %file_output
pageselect data

pagecreate(page=temp) a !yearfirst !yearlast
pageselect temp
smpl @all
%newseries="esftw_r"+@str(!report_year) 'name of the new series to be loaded from latest ESF file
import %file_newdata @freq a 1937 @rename total_wages {%newseries}  

copy temp\{%newseries} data\{%newseries}
pagedelete temp

'DONE loading data

'ratios of ESF reported in yr t to reported in yr (t-1)
pageselect data
smpl @all

for !y=!first_report_year+1 to !report_year  
	%yt=@str(!y)
	%yt1=@str(!y-1)
	genr ratio_{!y}=esftw_r{%yt}/esftw_r{%yt1}
next

' check on the latest ratio 
' need to find obs where the value changes "a lot" from year to year
genr ratio_{!report_year}_ck = @abs(ratio_{!report_year} - ratio_{!report_year}(-1))

smpl if ratio_{!report_year}_ck >0.01
freeze(check_r{!report_year}) ratio_{!report_year}.sheet
smpl @all

'MANUAL adjustments:
'manually add specific values to account for adjustments in past data due to the data clean-up efforts by Systems
!r2011adj=0.5*(@elem(ratio_2011, "1994")+@elem(ratio_2011, "1999"))
!r2012adj=0.5*(@elem(ratio_2012, "1993")+@elem(ratio_2012, "1997"))
!r2013adj=0.5*(@elem(ratio_2013, "1990")+@elem(ratio_2013, "1995"))
!r2014adj=0.5*(@elem(ratio_2014, "1988")+@elem(ratio_2014, "1992"))
!r2015adj=0.5*(@elem(ratio_2015, "1986")+@elem(ratio_2015, "1989"))
!r2016adj=0.5*(@elem(ratio_2016, "1984")+@elem(ratio_2016, "1987"))
!r2017adj=0.5*(@elem(ratio_2017, "1981")+@elem(ratio_2017, "1985"))
!r2018adj=0.5*(@elem(ratio_2018, "1980")+@elem(ratio_2018, "1983"))
!r2019adj=0.5*(@elem(ratio_2019, "1978")+@elem(ratio_2019, "1981"))		' new for TR20
!r2020adj=0.5*(@elem(ratio_2020, "1975")+@elem(ratio_2020, "1979"))             ' new for TR21
!r2021adj=0.5*(@elem(ratio_2021, "1970")+@elem(ratio_2021, "1978"))             ' new for TR22

smpl 1971 1977
ratio_2021= !r2021adj        ' new for TR22
smpl 1976 1978
ratio_2020 = !r2020adj      ' new for TR21
smpl 1979 1980
ratio_2019 = !r2019adj		' new for TR20
smpl 1981 1982
ratio_2018 = !r2018adj
smpl 1982 1984
ratio_2017 = !r2017adj
smpl 1985 1986
ratio_2016 = !r2016adj
smpl 1987 1988
ratio_2015 = !r2015adj
smpl 1989 1991
ratio_2014 = !r2014adj
smpl 1991 1994
ratio_2013 = !r2013adj
smpl 1994 1996
ratio_2012 = !r2012adj
smpl 1995 1998
ratio_2011 = !r2011adj
smpl @all

'DONE manually adjusting data

' create another check variable to confirm that the manual adjustment fixed the problem
genr ratio_{!report_year}_ck_adj = @abs(ratio_{!report_year} - ratio_{!report_year}(-1))
smpl if ratio_{!report_year}_ck_adj >0.01
freeze(check_r{!report_year}_adj) ratio_{!report_year}.sheet
smpl @all

delete *_ck *_ck_adj	' delete the check series to cleanup the workfile

'average ratio
smpl 1950 !yearlast-1  'need to compute the adjustment factor starting in 1950 in order to get estimated finals starting in 1951 (lagged adj factor used in computations)

'series to be averaged
%r1="ratio_"+@str(!report_year)
%r2="ratio_"+@str(!report_year-1)
%r3="ratio_"+@str(!report_year-2)
%r4="ratio_"+@str(!report_year-3)
%r5="ratio_"+@str(!report_year-4)

'5yr average
genr ratio_5yr = 0.2*({%r1} + {%r2}(-1) + {%r3}(-2) + {%r4}(-3) + {%r5}(-4))

'ratio to last reported 
genr ratio_lastrep=@cumprod(ratio_5yr)

'	!!!!! ESTIMATED FINAL wage amounts in ESF (adjust to $billions)!!!!!!
smpl @all 'reset sample to full
genr we_sf=esftw_r{!report_year}*ratio_lastrep(-1)/1000000000

'Load other data needed to decompose ESF into components

'load worker series form epoxy
wfopen %file_epoxy
copy %file_epoxy::{%page_epoxy}\cew_m %file_output::data\
wfclose %file_epoxy

'load data for gov sector
wfopen %file_gov
copy %file_gov::{%page_gov}\wefc_n %file_output::data\
copy %file_gov::{%page_gov}\wesl_n_hi %file_output::data\
wfclose %file_gov

'create wsca series (different method for three subperiod)
'1951-1993 -- use data saved in earlier workfile
smpl 1951 1993
genr wsca = wsca_hist93
smpl @all

'1994-1999 -- import data from "Charts"
pageselect data
smpl @all
' import data for year 1990 -1999
%yr_last = @left(@right(%tb, 6),4)		' gets the latest year that appears in the data in %file_charts
' Import from Chart1 -- row references are same no matter the report year
import %file_charts  range=%tb!B20:B29 names="c1941" @freq a 1990
import %file_charts  range=%tb!C20:C29 names="c1w2" @freq a 1990
' import  from Chart2 -- starting row changes when new year of data is added to chart1 above
!startrow = 8 + (@val(%yr_last)-1978) + 22
!cell1 = !startrow
!cell2 = !cell1 + 9
import %file_charts  range=%tb!B{!cell1}:B{!cell2} names="c2941" @freq a 1990 
import %file_charts  range=%tb!C{!cell1}:C{!cell2} names="c2w2" @freq a 1990 
're-scale all series
c1941 = c1941 / 1000000000
c1w2 = c1w2 / 1000000000
c2941 = c2941 / 1000000000
c2w2 = c2w2 / 1000000000
' now compute wscahi
group c1 c1941 c1w2
group c2 c2941 c2w2
series wscahi_charts = @rmax(c1) + @rmax(c2)
wscahi_charts = @round(wscahi_charts*10^3)/10^3

smpl 1994 1999
genr wsca = wscahi_charts - wefc_n - wesl_n_hi
delete wscahi_charts c1941 c1w2 c2941 c2w2 c1 c2
smpl @all


'2000 and later -- import data from EstFinTaxEarn 
smpl 2000 !yearlast

wfopen %file_EstFinTaxEarn
copy EstFinTaxEarn::{%page_EstFinTaxEarn}\wscahi {%file_output}::data\wscahi
wfclose %file_EstFinTaxEarn

genr wsca = wscahi - wefc_n - wesl_n_hi
smpl @all

'MEF only
genr wsca_m=wsca-we_sf

'average MEF wage
genr mef_avg_wage = wsca_m/cew_m
'ratio of SF wages to (MEF+ESF)
genr sf_to_totalw = we_sf/wsca

'compute wages and employment for categories within SF
'Legal Resident Population (lrp)
'wages
genr we_sf_lrp = we_sf
smpl 1967 @last
we_sf_lrp = wsca*0.002
smpl 1964 1964
we_sf_lrp = we_sf - 0.0001*wsca
smpl 1965 1965
we_sf_lrp = we_sf - 0.0002*wsca
smpl 1966 1966
we_sf_lrp = we_sf - 0.0003*wsca
smpl @all
'employment
genr te_sf_lrp = we_sf_lrp/(mef_avg_wage*0.75)
'divide into MEF and ESF employment
genr te_sfo_lrp = 0.5*te_sf_lrp
genr te_sfm_lrp = te_sf_lrp - te_sfo_lrp

'from employment to wages
genr we_sfo_lrp = te_sfo_lrp*mef_avg_wage
genr we_sfm_lrp = te_sfm_lrp*mef_avg_wage*0.5

'other population
genr we_sf_teo = we_sf - we_sf_lrp
genr te_sf_teo = we_sf_teo/(mef_avg_wage*0.825)

'create final table, name it 'table1'
smpl 1951 !yearlast-1
group group1 wsca_m cew_m mef_avg_wage we_sf sf_to_totalw we_sf_lrp te_sf_lrp te_sfo_lrp we_sfo_lrp te_sfm_lrp we_sfm_lrp we_sf_teo te_sf_teo
freeze(table1) wsca_m cew_m mef_avg_wage we_sf sf_to_totalw we_sf_lrp te_sf_lrp te_sfo_lrp we_sfo_lrp te_sfm_lrp we_sfm_lrp we_sf_teo te_sf_teo
%title = "Table 1. Wage and Employment Estimates for the Master Earnings File and the Earnings Suspense File, 1951-"+@str(!yearlast-1)
table1.title {%title}
table1.setformat(@all) f.3
table1.insertrow(1) 6
!lastrow = !yearlast-1951+8 'define the number of the last row in the table (useful for later formatting)

table1(4,1) = "Calendar"
table1(5,1) = "Year"

table1.setmerge(b2:d2)
table1.setmerge(b3:d3)
table1.setmerge(e2:n2)
table1.setmerge(e3:f3)
table1.setmerge(g3:l3)
table1.setmerge(m3:n3)
table1.setmerge(i4:l4)
table1.setmerge(i5:j5)
table1.setmerge(k5:l5)

table1(1,1) = %title
table1(2,2) = "MEF Final Estimates"
table1(3,2) = "OASDI Covered"
table1(2,5) = "Estimate of Final OASDI Covered Wages and Wage Workers Sent to ESF"
table1(3,5) = "Total Wages"
table1(3,7) = "Legal Resident Population"
table1(3,13) = "Other Population"
table1(4,9) = "Total with wage items posted to"
table1(5,9) = "ESF Only"
table1(5,11) = "ESF and MEF"

table1(4,2) = "Total"
table1(5,2) = "Wages"
table1(6,2) = "(in $bil.)"
table1(4,3) = "Empl."
table1(6,3) = "(in mil.)"
table1(4,4) = "Avg."
table1(5,4) = "Wage"
table1(6,4) = "($thou.)"
table1(4,5) = "Level"
table1(6,5) = "(in $bil.)"
table1(4,6) = "Ratio to"
table1(5,6) = "MEF and"
table1(6,6) = "ESF"
table1(4,7) = "Total"
table1(5,7) = "Wages"
table1(4,8) = "Empl."
table1(6,9) = "Empl."
table1(6,10) = "Wages"
table1(6,11) = "Empl."
table1(6,12) = "Wages"
table1(4,13) = "Total"
table1(5,13) = "Wages"
table1(4,14) = "Empl."
table1(7,4) = " "
table1(7,6) = " "

table1.setwidth(1:6) 8
table1.setwidth(2) 9
table1.setwidth(7:8) 10
table1.setwidth(9:14) 11
table1.setjust(a1:n7) center
table1.setlines(a1:n8) +a
table1.setlines(a2:a7) -h
table1.setlines(b2:b3) -h
table1.setlines(b4:b6) -h
table1.setlines(c4:c6) -h
table1.setlines(d4:d6) -h
table1.setlines(e4:e6) -h
table1.setlines(f4:f6) -h
table1.setlines(g4:g6) -h
table1.setlines(h4:h6) -h
table1.setlines(m4:m6) -h
table1.setlines(n4:n6) -h

table1.setlines(a1:n{!lastrow}) +o
table1.setlines(a9:a{!lastrow}) +o
table1.setlines(b9:d{!lastrow}) +o
table1.setlines(g9:l{!lastrow}) +o

table1.setfont(b7:n7) 7pt

'show table1

' summary spool
spool _summary
string line1 = "This file was created on " + @date + " at " + @time + " by " + %userid 
string line2 = "The file contains the updated data for the Earnings Suspense file. The latest data were loaded from " + %file_newdata + ". The file combines the new data with earlier data from " + %file_initial_path + ". "
string line3 = "The program also used inputs from the following files:" + @chr(13) + %file_epoxy + @chr(13) + %file_gov + @chr(13) + %file_charts + @chr(13) + %file_bmtony
string line4 = "Manual adjustments were applied to account for the ''data cleanup'' by Systems. These adjustment are as follows: " + @chr(13) + _
				 "For report year 2013: set value for ratio_2013 for years 1991-94 to the average of values in 1990 and 1995" + @chr(13) + _
				 "For report year 2014: set value for ratio_2014 for years 1989-91 to the average of values in 1988 and 1992" + @chr(13) + _
				 "For report year 2015: set value for ratio_2015 for years 1987-88 to the average of values in 1986 and 1989" + @chr(13) + _
				 "For report year 2016: set value for ratio_2016 for years 1985-86 to the average of values in 1984 and 1987" + @chr(13) + _
				 "For report year 2017: set value for ratio_2017 for years 1982-84 to the average of values in 1981 and 1985" + @chr(13) + _
				 "For report year 2018: set value for ratio_2018 for years 1981-82 to the average of values in 1980 and 1983" + @chr(13) + _
				 "For report year 2019: set value for ratio_2019 for years 1979-80 to the average of values in 1978 and 1981"  + @chr(13) + _
				 "For report year 2020: set value for ratio_2019 for years 1976-78 to the average of values in 1975 and 1979"  + @chr(13) + _
				 "For report year 2021: set value for ratio_2021 for years 1971-77 to the average of values in 1970 and 1978"
string line5 = "If table check_r" + @str(!report_year) + " is not empty, it shows the years where ratio_... series changed significantly, indicating a possible need for manual adjustment." + @chr(13) + "Table check_r" + @str(!report_year) + "_adj should be EMPTY if the manual adjustment were applied correctly. Check to make sure it is!"
string line6 = %note1

_summary.insert line1 line2 line3 line4 line5 line6
delete line*

show _summary

if %sav = "Y" then
	wfsave(2) %file_output_path
endif

'wfclose


