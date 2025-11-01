' This program creates historical and projected wage-to-comp ratio.
' Inputs to the program are liates under the **** UPDATE section. They should be updated for every program run.

' For now the program assumes that there exists an Excel file that contains the raw data from BEA, as well as a separate file that has data from CMS. Both liste din the UPDATE section.
' In the future, the process of getting the data from BEA may be automated. 

' ***** Polina Vlasenko --- 12-14-2018


' ***** NOTES (and remaining issues)
' *1* Projected ESI share from CMS projections
'	below (around line # 415) we create projected ESI share by blending short-run and long-run CMS projections. Is the method always the same? Or does it change from year to year?
' 	If the method is not identical from year to year, this would necesitate changing the code - inconveneint. Idelly, we should create a method that can be applied every year. 
' 	Or alternatively create a separate program (or Excel) where the blending is done manually each year, and then load the completed series here.

' *2* Output of  the prorgam
'	Which series should I save where for other to be able to get them?

' *3* Do I need the "combined" series (and page)?

' *4* Loading data
'	This program loads (1) data from BEA, (2) CMS short run projections, (3) CMS long-run projections. 
'	For now these are are loaded from Excel files.
'	Need to figure out the process for loading the data that would be identical and automated from year to year. 

' *5* Projections with no CT
'	Should I create those?

' 	Polina Vlasenko 12-18-2018

' 	This version allows the user to specify the year of switching from SR to LR CMS projections in the blended ESI projections. (see !cms_link parameter)
'	 --- Polina Vlasenko 12-20-2018

' ****** UPDATE the inputs below for each run of the program
!TRyr = 2019 ' TR year; currently used only to label the output workfile

' input file that contains raw BEA data
%bea_raw = "E:\usr\pvlasenk\EViews\Wage-to-Comp\wage_comp_BEA.xlsx"
!first_row = 9 ' the row in the above file where the data start

!yr_first = 1948 ' first year in the BEA raw data
!yr_last_hist = 2017 ' last year of historical data in BEA raw data file
!yr_last = 2093 ' last year of the projections

%cms_lr = "\\s1f906b\econ\Processed data\WageToComp\Long-Run ESI Projection Based on TR18.xlsx" 	' file with CMS LONG-run projections; ideally need to devise a way to get this automated, instead of making an Excel file first
%sheet = "2018 Vintage" ' name of the sheet in the above%cms_lr file that contains the relevant data
!yr_cms = 2019 ' FIRST year of the LR CMS projections in the above %cms_lr file

%cms_sr = "\\s1f906b\econ\Processed data\WageToComp\Short-Run ESI Projection CMS Sept 2018.xlsx" 	' file with CMS SHORT-run projections; ideally need to devise a way to get this automated, instead of making an Excel file first
!cms_link = 2019 	' LAST year of using SHORT-run CMS projections for blended ESI projections; starting the following year (!cms_link+1) the growth rate from LONG-run CMS projections is used.

'A-bank (alt 2) for the previous-yr TR, the one published the year following !yr_last_hist
' Need this to pull values for wsca and wsd as a starting historical point for ratio of OASDI covered to NIPA wages
%abank = "\\LRSERV1\usr\eco.18\bnk\2018-0112-1212 TR182\atr182.bnk"

!esi_ee_fraction = 0.268 	' ASSUMED value of the full cost of employee health insurnace paid by employee; the rest (1-!esi_ee_fraction) is assumed to be covered by employer. Used for projecting the ratio of employees ESI to NIPA wages. 

' paremeters needed to compute projected avg annual % change in ratio of PPS to WSS due to changing life expectancy (LE)
' Look up the life expectancy in the alt2 files from Demo.
!le_hist = 17.9 	' Estimated life expectancy of man age 65 in 2017 (last historical year); 2019 TR Alternative 2 (see lifeexp.alt2)
!le_proj = 22.42	' Projected life expectancy of man age 65 in 2093 (last year of projection); 2019 TR Alternative 2 (see lifeexp.alt2)

!wk_part = 0.40 ' Percent of increased LE assumed to be financed by increase in Work; the rest (1-!wk_part) is assumed to be financed by increase in Savings. This is unlikely to change between TRs (it is part of our LFPR model).


'output created by this program
%output_path="E:\usr\pvlasenk\EViews\Wage-to-Comp\"
%this_file = "wage_to_comp_TR" + @str(!TRyr)  
' ****** END of the UPDATE section

'define some global parameters
'	several years as strings -- they are needed to refer to specific element in series in several computations below
	%hist = @str(!yr_last_hist) 'last historical year as a string; 
	%hist50 = @str(!yr_last_hist - 50) ' year 50 years before the last historical year
	%proj_first = @str(!yr_last_hist +1) ' first projection year
	%last = @str(!yr_last) ' last year of the projection period
	%last_sr = @str(!yr_last_hist + 11) ' last year of the Short-Range projection period

'end of global parameters

wfcreate(wf={%this_file}, page=results) a !yr_first !yr_last
pagecreate(page=Historical) a !yr_first !yr_last_hist
pagecreate(page=Projected) a !yr_last_hist !yr_last
pagecreate(page=CMS) a !yr_last_hist !yr_last

pageselect Historical

'!!!!! According to EViews command description, the following import command or wfopen commend should work. But they do not!!!
'import %bea_raw colhead=8 namepos=discard @freq a !yr_first  @smpl @all
'wfopen %bea_raw colhead=8 namepos=discard
' Hence I included manual indicatoon of the range to be imported (see below). I would have liked to avoid the need to do that -- because this requires knowing which columns the data are in. 

' 	Load historical NIPA data
!last_row = !first_row + !yr_last_hist - !yr_first
import %bea_raw range="Sheet1"!$B${!first_row}:$P${!last_row} @freq a !yr_first  @smpl @all 

' clean up the raw data, rename series, create descriptions

genr wss = series01/1000
genr ws = series02/1000
genr soc = series03/1000
genr oli = series04/1000
genr oli_pps = series05/1000
genr oli_ghi = series06/1000

genr oli_oth = oli - oli_pps - oli_ghi

genr wssggesl = (series07 + series08)/1000
genr wssggefc = (series09 + series10)/1000
genr wssgfm = series11/1000
genr oli_retsl = series12/1000
genr oli_retfc = series13/1000
genr oli_retfm = series14/1000
genr oli_ppps = series15/1000

delete series*

'create labels for series

wss.label(d) Compensation of Employess
wss.label(s) BEA Table 1.12 line 2

ws.label(d) Wages and Salaries
ws.label(s) BEA Table 1.12 line 3

soc.label(d) Employer contributions for government social insurance
soc.label(s) BEA Table 1.12 line 8

oli.label(d) Employer contributions for employee pension and insurance funds
oli.label(s) BEA Table 1.12 line 7

oli_pps.label(d) Employer contributions for employee pension plans
oli_pps.label(s) BEA Table 6.11 B/C line 21, Table 6.11 D line 23

oli_ghi.label(d) Employer contributions for employee group health insurance
oli_ghi.label(s) BEA Table 6.11 B/C line 30, Table 6.11 D line 32

wssggesl.label(d) Compensation of Employess in State & Local govt and govt enterprises
wssggesl.label(s) Sum of: (1) BEA Table 3.10.5 line 50 and (2) BEA Table 6.2 B/C line 86, Table 6.2 D line 96

wssggefc.label(d) Compensation of Employess in Federal govt (civilian) and govt enterprises
wssggefc.label(s) Sum of: (1) BEA Table 6.2 B/C line 79, Table 6.2 D line 89 and (2) BEA Table 6.2 B/C line 81, Table 6.2 D line 91

wssgfm.label(d) Compensation of Employess in Federal govt (military)
wssgfm.label(s) BEA Table 6.2 B/C line 80, Table 6.2 D line 90

oli_retsl.label(d) Employer contributions for State and Local Government Defined Benefit Pension Plans
oli_retsl.label(s) BEA Table 7.24 line 5

oli_retfc.label(d) Employer contributions for Federal civilian pension plans
oli_retfc.label(s) BEA Table 7.8 line 6

oli_retfm.label(d) Employer contributions for Federal military pension plans
oli_retfm.label(s) BEA Table 7.8 line 7

oli_ppps.label(d) Employer contributions for private pension plans
oli_ppps.label(s) Residual = difference between oli_pps and (oli_retsl + oli_retfc + oli_retfm)

for %ser wss ws soc oli oli_pps oli_ghi wssggesl wssggefc wssgfm oli_retsl oli_retfc oli_retfm oli_ppps
	{%ser}.label(u) $Billions
next


'compute ratios for the Historical table
genr wage_to_comp = ws/wss
wage_to_comp.label(d) Ratio of NIPA wages and salaries (ws) to total employee compensation (wss)

genr soc_to_comp = soc/wss
soc_to_comp.label(d) Ratio of Employer contributions for government social insurance (soc) to total employee compensation (wss)

genr oli_to_comp = oli/wss
oli_to_comp.label(d) Ratio of Employer contributions for employee pension and insurance funds (oli) to total employee compensation (wss)

genr pps_to_comp = oli_pps/wss
pps_to_comp.label(d) Ratio of Employer contributions for employee pension plans (oli_pps) to total employee compensation (wss)

genr ghi_to_comp = oli_ghi/wss
ghi_to_comp.label(d) Ratio of Employer contributions for employee group health insurance (oli_ghi) to total employee compensation (wss)

genr olioth_to_comp = oli_oth/wss
olioth_to_comp.label(d) Ratio of Employer contributions for employee other pension and insurance funds (oli_oth) to total employee compensation (wss)
olioth_to_comp.label(r) Includes Group Life Insurance, Workers Compensation, and Supplemental Unemployment

genr soc_to_wages = soc/ws
soc_to_wages.label(d) Ratio of Employer contributions for government social insurance (soc) to NIPA wages and salaries (ws)


'**** Table 1 -- Historical ******
group levels wss ws soc oli oli_pps oli_ghi oli_oth
group ratios wage_to_comp soc_to_comp oli_to_comp pps_to_comp ghi_to_comp olioth_to_comp soc_to_wages
group historical levels ratios

'create and format Table 1 -- Historical data
freeze(table1) historical.sheet
table1.title Table 1 - Historical Values for Total Employee Compensation, Its Major Components, and Key Ratios of the Components
table1.insertrow(1) 10

table1(2,2) = "Compensation of Employees ($bil.)"
table1(4,1) = "Calendar"
table1(5,1) = "Year"
table1(3,2) = "Levels"
table1(3,9) = "Key Ratios"
table1(4,2) = "Total"
table1(4,9) = "Ratio of Component to Total Employee Compensation"
table1(4,3) = "Components"
table1(5,3) = "Wage and"
table1(6,3) = "Salary"
table1(7,3) = "Accruals"
table1(5,4) = "Employer Contributions for"
table1(6,4) = "Gov't"
table1(7,4) = "Social"
table1(8,4) = "Insurance"
table1(6,5) = "Employee Pension and Insurance Funds"
table1(7,5) = "Total"
table1(7,6) = "Components"
table1(8,6) = "Pension"
table1(9,6) = "& Profit Sh."
table1(8,7) = "Group"
table1(9,7) = "Health Ins."
table1(8,8) = "Other"

table1(5,9) = "Wage and"
table1(6,9) = "Salary"
table1(7,9) = "Accruals"
table1(5,10) = "Employer Contributions for"
table1(6,10) = "Gov't"
table1(7,10) = "Social"
table1(8,10) = "Insurance"
table1(6,11) = "Employee Pension and Insurance Funds"
table1(7,11) = "Total"
table1(7,12) = "Components"
table1(8,12) = "Pension"
table1(9,12) = "& Profit Sh."
table1(8,13) = "Group"
table1(9,13) = "Health Ins."
table1(8,14) = "Other"
table1(4,15) = "Ratio of"
table1(5,15) = "Gov. Soc."
table1(6,15) = "Insurance"
table1(7,15) = "to Wages"

table1.setmerge(b2:o2)
table1.setmerge(b3:h3)
table1.setmerge(i3:o3)
table1.setmerge(c4:h4)
table1.setmerge(d5:h5)
table1.setmerge(e6:h6)
table1.setmerge(f7:h7)
table1.setmerge(i4:n4)
table1.setmerge(j5:n5)
table1.setmerge(k6:n6)
table1.setmerge(l7:n7)

table1.setlines(a1:o10) +a

table1.setlines(a2:a9) -h
table1.setlines(b4:b9) -h
table1.setlines(c5:c9) -h
table1.setlines(d6:d9) -h
table1.setlines(e7:e9) -h
table1.setlines(f8:f9) -h
table1.setlines(g8:g9) -h
table1.setlines(h8:h9) -h
table1.setlines(i5:i9) -h
table1.setlines(j6:j9) -h
table1.setlines(k7:k9) -h
table1.setlines(l8:l9) -h
table1.setlines(m8:m9) -h
table1.setlines(n8:n9) -h
table1.setlines(o4:o9) -h

for %col H I J K L M N O
	table1.setformat({%col}) f.4
next

setcolwidth(table1, 2, 9)
setcolwidth(table1, 3, 10)
setcolwidth(table1, 4, 10)
setcolwidth(table1, 5, 8)
setcolwidth(table1, 6, 10)
setcolwidth(table1, 7, 10)
setcolwidth(table1, 8, 8)
setcolwidth(table1, 9, 10)
setcolwidth(table1, 10, 10)
setcolwidth(table1, 11, 8)
setcolwidth(table1, 12, 11)
setcolwidth(table1, 13, 11)
setcolwidth(table1, 14, 8)
setcolwidth(table1, 15, 10)

'table1.display

' Compute long-term averages for historical ratios
scalar wage_to_comp_chg_50yr = @elem(wage_to_comp, %hist) - @elem(wage_to_comp, %hist50) 
%desc = "Change during last 50 years (" + %hist50 + " - " + %hist + ") in the level of ratio of wages and salaries (ws) to employee compensation (wss)" 
wage_to_comp_chg_50yr.label(d) {%desc}
scalar wage_to_comp_gr_50yr = 100*((@elem(wage_to_comp, %hist)/@elem(wage_to_comp, %hist50))^(1/50) -1) 
%desc = "Average Annual Rate of Change during last 50 years (" + %hist50 + " - " + %hist + ") in ratio of wages and salaries (ws) to employee compensation (wss)" 
wage_to_comp_gr_50yr.label(d) {%desc}

scalar soc_to_comp_chg_50yr = @elem(soc_to_comp, %hist) - @elem(soc_to_comp, %hist50) 
%desc = "Change during last 50 years (" + %hist50 + " - " + %hist + ") in the level of ratio of Employer contributions for government social insurance (soc) to employee compensation (wss)" 
soc_to_comp_chg_50yr.label(d) {%desc}
scalar soc_to_comp_gr_50yr = 100*((@elem(soc_to_comp, %hist)/@elem(soc_to_comp, %hist50))^(1/50) -1) 
%desc = "Average Annual Rate of Change during last 50 years (" + %hist50 + " - " + %hist + ") in ratio of Employer contributions for government social insurance (soc) to employee compensation (wss)" 
soc_to_comp_gr_50yr.label(d) {%desc}

scalar oli_to_comp_chg_50yr = @elem(oli_to_comp, %hist) - @elem(oli_to_comp, %hist50) 
%desc = "Change during last 50 years (" + %hist50 + " - " + %hist + ") in the level of ratio of Employer contributions for employee pension and insurance funds (oli) to employee compensation (wss)" 
oli_to_comp_chg_50yr.label(d) {%desc}
scalar oli_to_comp_gr_50yr = 100*((@elem(oli_to_comp, %hist)/@elem(oli_to_comp, %hist50))^(1/50) -1) 
%desc = "Average Annual Rate of Change during last 50 years (" + %hist50 + " - " + %hist + ") in ratio of Employer contributions for employee pension and insurance funds (oli) to employee compensation (wss)" 
oli_to_comp_gr_50yr.label(d) {%desc}

scalar pps_to_comp_chg_50yr = @elem(pps_to_comp, %hist) - @elem(pps_to_comp, %hist50) 
%desc = "Change during last 50 years (" + %hist50 + " - " + %hist + ") in the level of ratio of Employer contributions for employee pension plans (oli_pps) to employee compensation (wss)" 
pps_to_comp_chg_50yr.label(d) {%desc}
scalar pps_to_comp_gr_50yr = 100*((@elem(pps_to_comp, %hist)/@elem(pps_to_comp, %hist50))^(1/50) -1) 
%desc = "Average Annual Rate of Change during last 50 years (" + %hist50 + " - " + %hist + ") in ratio of Employer contributions for employee pension plans (oli_pps) to employee compensation (wss)" 
pps_to_comp_gr_50yr.label(d) {%desc}

scalar ghi_to_comp_chg_50yr = @elem(ghi_to_comp, %hist) - @elem(ghi_to_comp, %hist50) 
%desc = "Change during last 50 years (" + %hist50 + " - " + %hist + ") in the level of ratio of Employer contributions for employee group health insurance (oli_ghi) to employee compensation (wss)" 
ghi_to_comp_chg_50yr.label(d) {%desc}
scalar ghi_to_comp_gr_50yr = 100*((@elem(ghi_to_comp, %hist)/@elem(ghi_to_comp, %hist50))^(1/50) -1) 
%desc = "Average Annual Rate of Change during last 50 years (" + %hist50 + " - " + %hist + ") in ratio of Employer contributions for employee group health insurance (oli_ghi) to employee compensation (wss)" 
ghi_to_comp_gr_50yr.label(d) {%desc}

scalar olioth_to_comp_chg_50yr = @elem(olioth_to_comp, %hist) - @elem(olioth_to_comp, %hist50) 
%desc = "Change during last 50 years (" + %hist50 + " - " + %hist + ") in the level of ratio of Employer contributions for employee other pension and insurance funds (oli_oth) to employee compensation (wss)" 
olioth_to_comp_chg_50yr.label(d) {%desc}
scalar olioth_to_comp_gr_50yr = 100*((@elem(olioth_to_comp, %hist)/@elem(olioth_to_comp, %hist50))^(1/50) -1) 
%desc = "Average Annual Rate of Change during last 50 years (" + %hist50 + " - " + %hist + ") in ratio of Employer contributions for employee other pension and insurance funds (oli_oth) to employee compensation (wss)" 
olioth_to_comp_gr_50yr.label(d) {%desc}

'create a table that displays the 50 yr changes 
table(14, 7) hist_avg
tabplace(hist_avg, table1, "b1", "i3", "n10")
hist_avg(4,1) = "50 years"
%desc =  "(" + %hist50 + " - " + %hist + ")" 
hist_avg(5,1) = %desc
hist_avg.setlines(a2:a7) +o
setcolwidth(hist_avg, 1, 22)
hist_avg(9,1) = "Change in Level of Ratio"
hist_avg(11,1) = "Average Annual Rate of"
hist_avg(12,1) = "Change in Ratio (percent)"

hist_avg(9,2) = wage_to_comp_chg_50yr
hist_avg(9,3) = soc_to_comp_chg_50yr
hist_avg(9,4) = oli_to_comp_chg_50yr
hist_avg(9,5) = pps_to_comp_chg_50yr
hist_avg(9,6) = ghi_to_comp_chg_50yr
hist_avg(9,7) = olioth_to_comp_chg_50yr

hist_avg(12,2) = wage_to_comp_gr_50yr
hist_avg(12,3) = soc_to_comp_gr_50yr
hist_avg(12,4) = oli_to_comp_gr_50yr
hist_avg(12,5) = pps_to_comp_gr_50yr
hist_avg(12,6) = ghi_to_comp_gr_50yr
hist_avg(12,7) = olioth_to_comp_gr_50yr

hist_avg.setlines(a8:g14) +o
hist_avg.title Historical Values for Key Ratios of Components to Total Employee Compensation


' 	Load CMS projections data
pageselect CMS
' short-run projections
import %cms_sr  @freq a !yr_last_hist  

delete series01
rename series02 esi_cms
rename series03 gdp_cms

esi_cms.label(d) Employer-Sponsored Insurance (ESI), CMS February 2018 projection w/ ACA
esi_cms.label(s) CMS, OACT; September 2018
esi_cms.label(u) $billions

gdp_cms.label(d) Projected GDP, CMS February 2018 projection w/ ACA
gdp_cms.label(s) CMS, OACT; September 2018
gdp_cms.label(u) $billions

' long-run projections
import %cms_lr  range=%sheet @freq a !yr_cms 

delete series01

rename gdp gdp_cms_lr
rename pre_tax esi_cms_lr_noCT
rename post_tax esi_cms_lr

for %ser gdp_cms_lr esi_cms_lr_noCT esi_cms_lr
	{%ser}.label(u) $Billions
	{%ser}.label(s) CMS long-run projections based on TR18
next

gdp_cms_lr.label(d) Projected GDP 
esi_cms_lr_noCT.label(d) Projected spending on Employer-Sponsored Insurnace (no Cadillac tax)
esi_cms_lr.label(d) Projected spending on Employer-Sponsored Insurnace (with Cadillac tax)

genr esi_ratio_lr = esi_cms_lr/gdp_cms_lr
genr esi_ratio_lr_noCT = esi_cms_lr_noCT/gdp_cms_lr
'need to fill in the missing value in the last projection year (2093)
smpl !yr_last !yr_last
esi_ratio_lr = esi_ratio_lr(-1)*esi_ratio_lr(-1)/esi_ratio_lr(-2)
esi_ratio_lr_noCT = esi_ratio_lr_noCT(-1)*esi_ratio_lr_noCT(-1)/esi_ratio_lr_noCT(-2)
'done
smpl !yr_last_hist !yr_last

genr esi_ratio_gr = @pch(esi_ratio_lr)
genr esi_ratio_gr_noCT = @pch(esi_ratio_lr_noCT)

genr esi_ratio_sr = esi_cms/gdp_cms

'create a projection of ESI share, blending short-run and long-run CMS projections
' for years up to and including !cms_link (specified above at the start fo program), use short-run projections
smpl !yr_last_hist !cms_link
genr esi_cms_blend = esi_ratio_sr
genr esi_cms_blend_noCT = esi_ratio_sr
' starting in year !cms_link+1, grow the blended esi share by the growth rate of the long-range projections (i.e. by esi_ratio_gr)
smpl !cms_link+1 !yr_last
genr esi_cms_blend = esi_cms_blend(-1) * (1 + esi_ratio_gr)
genr esi_cms_blend_noCT = esi_cms_blend_noCT(-1) * (1 + esi_ratio_gr_noCT)

'create the index by which to inflate future ESI share
' these index series are the ones needed to compute projected ghi_to_comp in Table 2a.
smpl !yr_last_hist !yr_last
genr esi_cms_blend_index = esi_cms_blend/@elem(esi_cms_blend, %hist)
genr esi_cms_blend_index_noCT = esi_cms_blend_noCT/@elem(esi_cms_blend_noCT, %hist)

esi_cms_blend_index.label(d) Index to inflate projected ESI share, based on CMS projections assuming adoption of Cadillac Tax
esi_cms_blend_index.label(s) blend of CMS short-run and long-run projections
%desc = " = 1 in " + %hist
esi_cms_blend_index.label(u) {%desc}

esi_cms_blend_index_noCT.label(d) Index to inflate projected ESI share, based on CMS projections assuming no Cadillac Tax
esi_cms_blend_index_noCT.label(s) blend of CMS short-run and long-run projections
%desc = " = 1 in " + %hist
esi_cms_blend_index_noCT.label(u) {%desc}

'*****Table 2a -- projections ******

pageselect Projected 
smpl !yr_last_hist !yr_last_hist
dbopen(type=aremos) %abank
fetch wsca wsd
close @db

'copy last historical values we will need to create projections
copy Historical\wage_to_comp Projected\
copy Historical\soc_to_comp Projected\
copy Historical\pps_to_comp Projected\
copy Historical\ghi_to_comp Projected\
copy Historical\olioth_to_comp Projected\
copy Historical\soc_to_wages Projected\
copy Historical\oli_ghi Projected\
copy Historical\ws Projected\

smpl !yr_last_hist !yr_last
'copy ESI index series from CMS page
copy CMS\esi_cms_blend_index Projected\
copy CMS\esi_cms_blend_index_noCT Projected\

' compute projected values
smpl !yr_last_hist+1 !yr_last

soc_to_wages = @elem(soc_to_wages, %hist)
olioth_to_comp = @elem(olioth_to_comp, %hist)

' compute Projected Average Annual Percent Change in Ratio of PPS to WSS (last historical yr to end of projection)
!pps_hist = @elem(pps_to_comp, %hist) ' lst historical value of pps_to_comp
!pps_proj = !pps_hist + !pps_hist*(1-!wk_part)*((!le_proj/!le_hist)-1)
scalar pps_gr = (!pps_proj/!pps_hist)^(1/(!yr_last - !yr_last_hist)) -1

pps_to_comp = pps_to_comp(-1) * (1+ pps_gr)

' Compute projected growth of ESI share of GDP, based on CMS projections
ghi_to_comp = @elem(ghi_to_comp, %hist) * esi_cms_blend_index 

' total employer contributions for pension and insurnace funds
smpl !yr_last_hist !yr_last
genr oli_to_comp = pps_to_comp + ghi_to_comp + olioth_to_comp

smpl !yr_last_hist+1 !yr_last
wage_to_comp = (1 - oli_to_comp)/(1 + soc_to_wages)
genr wage_to_comp_gr = @pc(wage_to_comp)
soc_to_comp = 1 - wage_to_comp - oli_to_comp

'ratio of employEE esi to NIPA wages
smpl !yr_last_hist !yr_last_hist
genr esi_ee_to_wages = oli_ghi * (!esi_ee_fraction/(1-!esi_ee_fraction))/ws
smpl !yr_last_hist+1 !yr_last
genr esi_ee_to_wages = ghi_to_comp * (!esi_ee_fraction/(1-!esi_ee_fraction))/wage_to_comp

'ratio of OASDI covered to NIPA wages
smpl !yr_last_hist !yr_last_hist
genr cov_to_nipa = wsca / wsd
smpl !yr_last_hist+1 !yr_last
genr cov_to_nipa = @elem(cov_to_nipa, %hist) + (@elem(esi_ee_to_wages, %hist) - esi_ee_to_wages)
genr cov_to_nipa_gr = @pc(cov_to_nipa)

' annual pct change in ratio of OASDI covered wage to employee comp
smpl !yr_last_hist+1 !yr_last
genr cov_to_comp_gr = ((1 + wage_to_comp_gr/100) * (1 + cov_to_nipa_gr/100) -1) * 100


'create and format Table 2 -- Projections
smpl !yr_last_hist !yr_last
group proj wage_to_comp wage_to_comp_gr soc_to_comp oli_to_comp pps_to_comp ghi_to_comp olioth_to_comp soc_to_wages esi_ee_to_wages cov_to_nipa cov_to_nipa_gr cov_to_comp_gr
freeze(table2) proj.sheet

%t2 = "Table 2 - Projected Changes in the Ratios of NIPA Wages to Compenstion, OASDI Covered to NIPA Wages, and OASDI Covered Wages to Compensation,  " + @str(!yr_last_hist+1) + "-" + @str(!yr_last)
table2.title {%t2}
table2.insertrow(1) 10
table2.insertrow(14) 1
table2.insertrow(13) 1
table2(13,1) = "Historical"
table2(15,1) = "Projected"
table2(5,1) = "Calendar"
table2(6,1) = "Year"
table2(2,2) = "Ratio of Component to Total Employee Compensation (WSS)"
table2(3,2) = "NIPA Wages and Salaries (WS)"
table2(4,2) = "Level of"
table2(5,2) = "Ratio"
table2(4,3) = "Annual"
table2(5,3) = "Pct Chg"
table2(6,3) = "in Ratio"
table2(3,4) = "Employer Contributions for"
table2(4,5) = "Employee Pension and Insurance Funds"
table2(5,6) = "Components"
table2(5,5) = "Total"
table2(6,6) = "PPS"
table2(6,7) = "ER ESI (GHI)"
table2(6,8) = "Other"
table2(4,4) = "Govt."
table2(5,4) = "Social"
table2(6,4) = "Insurance"
table2(2,9) = "Ratio of"
table2(3,9) = "Gov. Soc."
table2(4,9) = "Insurance"
table2(5,9) = "to NIPA"
table2(6,9) = "Wages"
table2(2,10) = "Ratio of"
table2(3,10) = "Employee"
table2(4,10) = "ESI to "
table2(5,10) = "NIPA"
table2(6,10) = "Wages"
table2(2,11) = "Ratio of"
table2(3,11) = "OASDI Covered"
table2(4,11) = "to NIPA wages"
table2(5,11) = "Level"
table2(5,12) = "Pct. Chg."
table2(2,13) = "Annual Pct"
table2(3,13) = "Chg in Ratio"
table2(4,13) = "of OASDI"
table2(5,13) = "Covered Wage"
table2(6,13) = "to Employee"
table2(7,13) = "Comp"

table2(14,3) = " "
table2(14,12) = " "
table2(14,13) = " "

table2.setmerge(b2:h2)
table2.setmerge(b3:c3)
table2.setmerge(d3:h3)
table2.setmerge(e4:h4)
table2.setmerge(f5:h5)

table2.setmerge(k2:l2)
table2.setmerge(k3:l3)
table2.setmerge(k4:l4)

table2.setlines(a1:m8) +a
table2.setlines(a2:a7) -h
table2.setlines(b4:b7) -h
table2.setlines(c4:c7) -h
table2.setlines(d4:d7) -h
table2.setlines(e5:e7) -h
table2.setlines(f6:f7) -h
table2.setlines(g6:g7) -h
table2.setlines(h6:h7) -h
table2.setlines(i2:i7) -h
table2.setlines(j2:j7) -h
table2.setlines(k5:k7) -h
table2.setlines(l5:l7) -h
table2.setlines(m2:m7) -h
table2.setlines(k2:k4) -h

table2.setformat(@all) f.4

setcolwidth(table2, 4, 10)
setcolwidth(table2, 5, 8)
setcolwidth(table2, 6, 8)
setcolwidth(table2, 8, 8)
setcolwidth(table2, 9, 10)
setcolwidth(table2, 10, 10)
setcolwidth(table2, 11, 8)
setcolwidth(table2, 12, 8)

'table2.display

' Compute long-term averages for projections

for %ser wage_to_comp soc_to_comp oli_to_comp pps_to_comp ghi_to_comp olioth_to_comp soc_to_wages esi_ee_to_wages cov_to_nipa
	
	scalar {%ser}_gr76 = 100*((@elem({%ser}, %last)/@elem({%ser}, %hist))^(1/76) -1) 
	{%ser}_gr76.label(u) Percent

	scalar {%ser}_gr11 = 100*((@elem({%ser}, %last_sr)/@elem({%ser}, %hist))^(1/11) -1) 
	{%ser}_gr11.label(u) Percent

	scalar {%ser}_gr75 = 100*((@elem({%ser}, %last)/@elem({%ser}, %proj_first))^(1/75) -1) 
	{%ser}_gr75.label(u) Percent

	scalar {%ser}_gr10 = 100*((@elem({%ser}, %last_sr)/@elem({%ser}, %proj_first))^(1/10) -1) 
	{%ser}_gr10.label(u) Percent

	scalar {%ser}_gr65 = 100*((@elem({%ser}, %last)/@elem({%ser}, %last_sr))^(1/65) -1) 
	{%ser}_gr65.label(u) Percent
	
next

for %per 76 11 75 10 65
	if %per = "76" then
		%period = %per + " years (" + %hist + " - " + %last + ")" 
	endif
	
	if %per = "11" then
		%period = %per + " years (" + %hist + " - " + %last_sr + ")" 
	endif
	
	if %per = "75" then
		%period = %per + " years (" + %proj_first + " - " + %last + ")" 
	endif
	
	if %per = "10" then
		%period = %per + " years (" + %proj_first + " - " + %last_sr + ")" 
	endif
	
	if %per = "65" then
		%period = %per + " years (" + %last_sr + " - " + %last + ")" 
	endif
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of wages and salaries (ws) to employee compensation (wss)"
	wage_to_comp_gr{%per}.label(d) {%desc}
		
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employer contributions for government social insurance (soc) to employee compensation (wss)"
	soc_to_comp_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employer contributions for employee pension and insurance funds (oli) to employee compensation (wss)"
	oli_to_comp_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employer contributions for employee pension plans (oli_pps) to employee compensation (wss)"
	pps_to_comp_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employer contributions for employee group health insurance (oli_ghi) to employee compensation (wss)"
	ghi_to_comp_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employer contributions for employee other pension and insurance funds (oli_oth) to employee compensation (wss)"
	olioth_to_comp_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employer contributions for government social insurance (soc) to NIPA wages and salaries (ws)"
	soc_to_wages_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of Employee ESI contributions to NIPA wages and salaries (ws)"
	esi_ee_to_wages_gr{%per}.label(d) {%desc}
	
	%desc = "Avg Annual Rate of Change projected for " + %period + " in ratio of OASDI covered wages to NIPA wages and salaries (ws)"
	cov_to_nipa_gr{%per}.label(d) {%desc}
next
	

'create a table that displays long-term averages 
table(20, 13) proj_avg
tabplace(proj_avg, table2, "a1", "a1", "m9")
proj_avg(4,1) = "Average Annual"
proj_avg(5,1) = "Rate of Change"
proj_avg(6,1) = "(percent)"
setcolwidth(proj_avg, 1, 18)
setcolwidth(proj_avg, 13, 12)

proj_avg.title Projected Average Annual Rate of Change in Key Ratios of NIPA Wages to Compenstion, OASDI Covered to NIPA Wages, and Components

%desc =  %hist + " - " + %last + " (76 yrs)" 
proj_avg(10,1) = %desc
%desc =  "   " + %hist + " - " + %last_sr + " (11 yrs)" 
proj_avg(11,1) = %desc
%desc =  %proj_first + " - " + %last + " (75 yrs)" 
proj_avg(13,1) = %desc
%desc =  "   " + %proj_first + " - " + %last_sr + " (10 yrs)" 
proj_avg(14,1) = %desc
%desc =  "   " + %last_sr + " - " + %last + " (65 yrs)" 
proj_avg(15,1) = %desc

proj_avg(10,2) = wage_to_comp_gr76
proj_avg(11,2) = wage_to_comp_gr11
proj_avg(13,2) = wage_to_comp_gr75
proj_avg(14,2) = wage_to_comp_gr10
proj_avg(15,2) = wage_to_comp_gr65

!col = 4
for %ser soc_to_comp oli_to_comp pps_to_comp ghi_to_comp olioth_to_comp soc_to_wages esi_ee_to_wages cov_to_nipa
	
	proj_avg(10,!col) = {%ser}_gr76
	proj_avg(11,!col) = {%ser}_gr11
	proj_avg(13,!col) = {%ser}_gr75
	proj_avg(14,!col) = {%ser}_gr10
	proj_avg(15,!col) = {%ser}_gr65
	
	!col = !col +1
	
next

proj_avg(10,13) = wage_to_comp_gr76 + cov_to_nipa_gr76
proj_avg(11,13) = wage_to_comp_gr11 + cov_to_nipa_gr11
proj_avg(13,13) = wage_to_comp_gr75 + cov_to_nipa_gr75
proj_avg(14,13) = wage_to_comp_gr10 + cov_to_nipa_gr10
proj_avg(15,13) = wage_to_comp_gr65 + cov_to_nipa_gr65


'	Collect all results in one page
pageselect results

'copy the tables into one convnient place to view them
copy Historical\table1 results\
copy Projected\table2 results\
copy Historical\hist_avg results\
copy Projected\proj_avg results\


'create a spool that contains summary info for the run
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The run uses historical BEA data from " + @str(!yr_first) + " to " + @str(!yr_last_hist) + @chr(13) + " and creates projections for subsequent years through "+ @str(!yr_last)
string line3 = "The following input files were used:"
string line4 = "CMS projections from " + @chr(13) + %cms_lr + @chr(13) + " and " + @chr(13) + %cms_sr
string line5 = "Historical data from BEA" + @chr(13) + "and from " + %abank


_summary.insert line1 line2 line3 line4 line5
'_summary.display

delete line*

'	save the workfile
%full_output=%output_path+%this_file
'wfsave %full_output



