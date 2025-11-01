' This program creates an EViews workfile containing historical taxable and
' covered earnings values for the 2025 Trustees Report.

' Store name of ssaprogdata workfile in variable.
%outfile = "c:\GitRepos\econ-ecodev\dat\SsaProgData.wf1"

' Set up temprorary workfile.
exec c:\GitRepos\econ-eviews\setup2.prg

' Store Trustees Report year in variable.
!tryr = 2025

' Store date and time value for subfolder containing the A workfile used. 
%afdt = "2025-0106-1433"

' Store year of latest Annual Statistical Supplement available as string.
%yrass = @str(2024)

' Store date part of EPOXY file ontaining HI wage employment data.
%xlepoxydt = "20241206"

' Store TY year as string.
%stryr = @str(!tryr)
' Store last two years of TR year as string.
%stryr2 = @right(%stryr, 2)

' Store afile name in variable.
%afile = "atr" + %stryr2 + "2"
' Save full A file path in variable.
%afilefp = "S:\LRECON\ModelRuns\TR" + %stryr + "\" + %afdt + "-TR" + %stryr2 + _
     "2\out\mul\" + %afile + ".wf1"
' Store last year of historical taxable data in variable.
!lyhd = !tryr - 2
' Store last two digits of last year of historical data as string.
%lyhd2 = @right(@str(!lyhd), 2)

' Store last year of RRB data.
!lyrrb = !lyhd - 1

' Store name of Excel file containing deemed military wage credit values.
%xlfileDM = "S:\LRECON\Data\Processed\TaxableEarnings\LegacyData\DMWCFinal.xlsx"

' Store name of Excel file containing legacy values not obtainable elsewhere
' in variable.
%xlfileLV = "S:\LRECON\Data\Processed\TaxableEarnings\LegacyData\LegacyValues.xlsx"

' Store name of Excel file containing taxable wage values not obtainable elsewhere
' in variable.
%xlfileTW = "S:\LRECON\Data\Processed\TaxableEarnings\LegacyData\bmtony1006.xls"
' Store name of tab in above file.
%xlTab = "Estimates"

' Store name of Excel file containing HI wage employment values drom the MEF for
' 1983-86 in variable.
%xlepoxy = "S:\LRECON\Data\Processed\EPOXY\epoxy" + %xlepoxydt + ".xlsx"

' Store name of file containing historical HI taxable earnings data in variable.
%xlfileHI = "S:\LRECON\Data\Processed\TaxableEarnings\TR" + %stryr + _
            "\HistoricalHiTaxablePayrollTR" + %stryr + ".xlsx"

' Store name of EViews workfile containing historical OASDI taxable wage data by
' sector in variable.
%wkfileTS = "EstFinTaxEarn"
%wkfileTS_FP = "C:\GitRepos\econ-taxearn\" + %wkfileTS
%wkpage = "20241031_r"

' Store name of file containing historical OASDI taxable wage data by government
' sector for 2007 to most recent year of historical data in variable.
%xlfileGS = "S:\LRECON\Data\Processed\TaxableEarnings\TR" + %stryr + _
            "\GovtSectorTaxableRatiosTR" + %stryr + ".xlsx"

' Set page to receive imported data to annual.
pageselect a

' Get AWI data for years not available in the Econ files.
import "S:\LRECON\Data\Raw\ProgramData\AWI.xlsx" range=Sheet1!$B$3:$B$22 colhead=0 _
       namepos=all na="#N/A" names=(awi) @freq A 1951 @smpl @all

' Get deemed military wage credits for OASDI and HI from Excel file for
' 1983-2001 to use in computing total effective taxable payroll.
import {%xlfileDM} range=Sheet1!$L$6:$M$24 colhead=0 namepos=all na="#N/A" _
        names=(dmwc_o dmwc_h) @freq A 1983 @smpl @all

' Convert values to $ billions.
smpl 1983 2001
genr dmwc_o = dmwc_o / 1000000000
genr dmwc_h = dmwc_h / 1000000000

' Get employee values for deemed military wage credits for 1975-81 from Excel
' file containing legacy values (which are in $ billions).
import {%xlfileLV} range=Sheet1!$B$11:$B$17 colhead=0 namepos=all na="#N/A" _
       names=(dmwcee_o_lv) @freq A 1975 @smpl @all

' Get employee and employer values for deemed military wage credits for
' 1982-2001 from Excel file containing final values.
import {%xlfileDM} range=Sheet1!$D$5:$G$24 colhead=0 _
       namepos=all na="#N/A" names=(dmwcee_o dmwcer_o dmwcee_h dmwcer_h) @freq A 1982 @smpl @all

' Store legacy values for 1975-81 for OASDI employee deemed military wage
' credits in OASDI and HI employee and employer values.
smpl 1975 1981
series dmwcee_o = dmwcee_o_lv
series dmwcer_o = dmwcee_o
series dmwcee_h = dmwcee_o
series dmwcer_h = dmwcee_o

' Convert values to $ billions.
smpl 1982 2001
series dmwcee_o = dmwcee_o / 1000000000
series dmwcer_o = dmwcer_o / 1000000000
series dmwcee_h = dmwcee_h / 1000000000
series dmwcer_h = dmwcer_h / 1000000000

' Store name of file containing historical taxable earnings and covered
' employment in variable.
%xlfile = "S:\LRECON\Data\Processed\TaxableEarnings\TR" + %stryr + _
          "\HistoricalOasdiTaxableEarningsTR" + %stryr + ".xlsx"

' Store last row of data in Excel file.
%lrow = @str(!lyhd - 1929)

' Get OASDI taxable wages, multi-employer refund wages, and self-employment
' income, and covered employment.
import {%xlfile} range=Final!$B$8:$E${%lrow} colhead=0 _
       namepos=all na="#N/A" names=(oasdi_tw oasdi_merw oasdise_ti tcea) @freq A 1937 @smpl @all

' Save values for total OASDI covered employment for 1937-1970 in a separate series
' for later writing to the output workfile;
smpl 1937 1970
series tcea_p = tcea

' Get OASDI taxable wages on the Earnings Suspense File for 1937-70.
import {%xlfile} range=Final!$G$8:$G$41 colhead=0 _
       namepos=all na="#N/A" names=(we_sf) @freq A 1937 @smpl @all

'Get OASDI covered employment on the Master Earnings File for 1937-50.
import {%xlfile} range=Final!$H$8:$H$21 colhead=0 _
       namepos=all na="#N/A" names=(ce_m) @freq A 1937 @smpl @all

' Save values for total OASDI covered employment on the MEF for 1937-1950 in a
' separate series for later writing to the output workfile;
smpl 1937 1950
series ce_m_p = ce_m

' Store name of file containing historical single- and multi-employer refund
' wages in variable.
%xlfile = "S:\LRECON\Data\Processed\Refunds\RefundsActual.xlsx"

' Store last row of data in Excel file.
%lrow = @str(!lyhd - 1947)

' Get OASDI and HI single-employer refund wages (in $ millions).
import {%xlfile} range=Single!$BJ$4:$BJ{%lrow} colhead=0 _
       namepos=all na="#N/A" names=(oasdi_serw) @freq A 1951 @smpl @all
import {%xlfile} range="Single HI!$G$4:$G$6" colhead=0 _
       namepos=all na="#N/A" names=(hi_serw) @freq A 1991 @smpl @all

' Convert values from $ millions to $ billions.
smpl 1951 !lyhd
series oasdi_serw = oasdi_serw / 1000
smpl 1966 1990
series hi_serw = oasdi_serw
smpl 1991 1993
series hi_serw = hi_serw / 1000

' Get OASI DI, and HI tax rates.
import "S:\LRECON\Data\Raw\ProgramData\TaxRates.xlsx" _
       range=TaxRates!$B$4:$J$172 colhead=0 _
       namepos=all na="#N/A" names=(rate_oasi_ee rate_di_ee rate_hi_ee _
               rate_oasi_er rate_di_er rate_hi_er rate_oasi_se rate_di_se _
               rate_hi_se) @freq A 1937 @smpl @all

' Store name of file containing historical taxable tips in variable.
%xlfile = "S:\LRECON\Data\Processed\TaxableEarnings\TR" + %stryr + _
          "\TaxableTipsTR" + %stryr + ".xlsx"

' Store last row of data in Excel file.
%lrow = @str(!lyhd - 1959)

' Get OASDI employee and employer tips reported by employers and tips reported
' by employees (in $ millions).
import {%xlfile} range=Final!$D$7:$D${%lrow} colhead=0 _
       namepos=all na="#N/A" names=(tips_er_ee) @freq A 1966 @smpl @all
import {%xlfile} range=Final!$G$21:$G${%lrow} colhead=0 _
       namepos=all na="#N/A" names=(tips_er_er) @freq A 1980 @smpl @all
import {%xlfile} range=Final!$H$19:$H${%lrow} colhead=0 _
       namepos=all na="#N/A" names=(tips_sr) @freq A 1978 @smpl @all

' Convert tips value to $ billions.
smpl 1966 !lyhd
genr tips_er_ee = tips_er_ee / 1000
genr tips_er_er = tips_er_er / 1000
genr tips_sr = tips_sr / 1000
' Set employee tips to employer-reported tips for 1966-77.
smpl 1966 1977
genr tips_ee = tips_er_ee
' Compute total taxable employee tips equal employer-reported plus
' employee-reported for 1978 on.
smpl 1978 !lyhd
genr tips_ee = tips_er_ee + tips_sr
' Set total taxable employer tips to employer-reported tips for 1980-87 and
' the sum of employer-reported and employee-reported tips for 1988 on.
smpl 1980 1987
genr tips_er = tips_er_er
smpl 1988 !lyhd
genr tips_er = tips_ee

' Store zeroes in employee and employer tips and deemed military wage credit
' series so that effective taxable payroll is computed correctly.
tips_ee.fill(o=1937) 0
tips_er.fill(o=1937) 0
dmwc_o.fill(o=1937) 0
smpl 1938 1965
series tips_ee = tips_ee(-1)
smpl 1938 1979
series tips_er = tips_er(-1)
smpl 1938 1982
series dmwc_o = dmwc_o(-1)
dmwc_o.fill(o=2002) 0
smpl 2003 !lyhd
series dmwc_o = dmwc_o(-1)
dmwc_h.fill(o=1966) 0
smpl 1967 1982
series dmwc_h = dmwc_h(-1)
dmwc_h.fill(o=2002) 0
smpl 2003 !lyhd
series dmwc_h = dmwc_h(-1)


' Compute OASDI effective taxable payroll.
smpl 1937 !lyhd
series oasdi_tw_ee = oasdi_tw - oasdi_merw
series oasdi_tw_er = oasdi_tw - (tips_ee - tips_er)
series oasdi_tw_etp = (oasdi_tw_ee + oasdi_tw_er) / 2

series oasdise_ti_etp = oasdise_ti * _
                        (rate_oasi_se + rate_di_se) / _
                        (rate_oasi_ee + rate_di_ee + _
                        rate_oasi_er + rate_di_er)

series oasdi_etp = oasdi_tw_etp + oasdise_ti_etp
series oasdi_etp_tot = oasdi_etp + dmwc_o

' Store name of file containing historical taxable maximums in variable.
%xlfile = "S:\LRECON\Data\Raw\ProgramData\WageBase.xlsx"

' Get OASDI wage bases (taxmaxes) for 1937-54 from Excel file.
' 1937-50
import {%xlfile} range="Sheet1!$B$16:$B$16" colhead=0 _
       namepos=all na="#N/A" names=(taxmax37) @freq A 1937 @smpl @all
' 1951-54
import {%xlfile} range="Sheet1!$B$17:$B$17" colhead=0 _
       namepos=all na="#N/A" names=(taxmax51) @freq A 1951 @smpl @all

' Store all taxmaxes for 1937 through 1953 in one series.
smpl 1937 1937
series taxmax_o = taxmax37
smpl 1938 1950
series taxmax_o = taxmax_o(-1)
smpl 1951 1951
series taxmax_o = taxmax51
smpl 1952 1953
series taxmax_o = taxmax_o(-1)

' Remove unneeded series.
delete taxmax37 taxmax51

' Get HI wage bases for 1991-93 from Excel file containing legacy values.
import {%xlfileLV} range=Sheet1!$C$27:$C$29 colhead=0namepos=all na="#N/A" _
        names=(taxmax_h) @freq A 1991 @smpl @all

' Store name of file containing historical railroad employment and compensation
' in variable.
%xlfile = "S:\LRECON\Data\Raw\RRB\TableD1.xlsx"
' Store name of tab containing railroad data.
%rrbtab = "ST" + %lyhd2 + "PartD"
' Store last row of data in Excel file.
%lrow = @str(!lyhd - 1932)

' Get railroad employment and compensation (wages) for 1937 to latest available
' year of data from the Railroad Retirement Board (in thousands for employment
' and $ millions for compensation.
import {%xlfile} range={%rrbtab}!$B$6:$B${%lrow} colhead=0 namepos=all _
       na="#N/A" names=(teprrb) @freq A 1937 @smpl @all
import {%xlfile} range={%rrbtab}!$D$6:$E${%lrow} colhead=0 namepos=all _
       na="#N/A" names=(wsprrb wsprrbt1) @freq A 1937 @smpl @all

' Convert employment values to millions and compensation values to $ billions.
smpl 1937 !lyrrb
series teprrb = teprrb / 1000
series wsprrb = wsprrb / 1000
series wsprrbt1 = wsprrbt1 / 1000

' Store name of file containing data from the latest Annual Statistical
' Supplement in variable.
%xlfile = "S:\LRECON\Data\Raw\ORES\AnnStatSupp\" + %yrass + "\Table4B2ASS" + _
          %yrass + ".xlsx"

' Get values for OASDI covered wages and employment and covered self-employment
' income (SE) for workers with taxable SE for 1937-70 using the latest Annual
' Statistical Supplement.
import {%xlfile} range=Tab4B2!$D$5:$D$38 colhead=0 namepos=all _
       na="#N/A" names=(wsca) @freq A 1937 @smpl @all
import {%xlfile} range=Tab4B2!$B$5:$B$38 colhead=0 namepos=all _
       na="#N/A" names=(wswa) @freq A 1937 @smpl @all
import {%xlfile} range=Tab4B2!$I$19:$I$38 colhead=0 namepos=all _
       na="#N/A" names=(cse) @freq A 1951 @smpl @all

' Convert earnings values to $ billions and employment values to millions.
smpl 1937 1970
series wsca = wsca / 1000
series wswa = wswa / 1000
series cse = cse / 1000

' Set values for HI covered wage employment to OASDI values for 1966-70.
smpl 1966 1970
series wswahi = wswa

' Get values for HI wage employment on the MEF for 1983 through 1986 from the
' latest EPOXY file available when determining estimates for this year's
' Trustees Report.
import %xlepoxy range="Table 7A!$D$9:$D$12" colhead=0 namepos=all na="#N/A" _
       names=(wswahi_mef) @freq A 1983 @smpl @all

' Convert employment values to millions.
smpl 1983 1986
series wswahi_mef = wswahi_mef / 1000000

' Get values for OASDI total covered employment and employment on the MEF
' from this year's Trustees Report A file.
open %afilefp
copy {%afile}::a\ce_m work::a\
copy {%afile}::a\tcea work::a\
close %afile

' Compute total HI covered employment levels for 1983-86 by adding reported HI
' covered employment to the number of workers imputed to be only on the Earnings
' Suspense File by subtracting OASDI covered employment on the MEF from total
' covered employment,
series work::a\wswahi = wswahi_mef + (tcea - ce_m)

' Get total covered self-employment income for all workers with SE (including
' OASDI wage workers at the wage base) for 1951-93 from Excel file containing
' estimates.
import "S:\LRECON\Data\Processed\TaxableEarnings\LegacyData\Estimating Historical CSE_TOT - July 20 2005 - Steve add.xls" _
        range=Sheet1!$O$11:$O$53 colhead=0 namepos=all na="#N/A" _
        names=(cse_tot) @freq A 1951 @smpl @all

' Get historical HI taxable wages, multi-empoyer refund wages, and
' self-employment income for 1966 through 1993.
import {%xlfileHI} range=Final!$B$8:$B$35 colhead=0 _
       namepos=all na="#N/A" names=(hi_tw) @freq A 1966 @smpl @all
import {%xlfileHI} range=Final!$G$8:$H$35 colhead=0 _
       namepos=all na="#N/A" names=(hi_merw hise_ti) @freq A 1966 @smpl @all

' Compute HI taxable amounts not otherwise obtained.
smpl 1966 !lyhd
series hi_tw_ee = hi_tw - hi_merw
series hi_tw_er = hi_tw - ( tips_ee - tips_er )
series hi_tw_etp = ( hi_tw_ee + hi_tw_er ) / 2
series hise_ti_etp = ( rate_hi_se / ( rate_hi_ee + rate_hi_er ) ) * hise_ti
series hi_etp = hi_tw_etp + hise_ti_etp
smpl 1966 1990
series hi_twrr = wsprrbt1
smpl 1991 1993
series hi_twrr = wsprrb
smpl 1966 1993
series hi_etp_tot = hi_etp + dmwc_h + hi_twrr

' Set OASDI taxable wage amounts by farm, Federal Civilian, military, and State
' and Local sectors.

' Get OASDI farm data for 1971-86 from file containing legacy data.
import {%xlfileLV} range=Sheet1!$D$7:$D$22 colhead=0 namepos=all na="#N/A" _
       names=(oasdiag_tw_lv) @freq A 1971 @smpl @all

' Get OASDI military data for 1968-86 from file containing legacy data.
import {%xlfileLV} range=Sheet1!$E$4:$E$22 colhead=0 namepos=all na="#N/A" _
       names=(oasdifm_tw_lv) @freq A 1968 @smpl @all

' Get OASDI Federal Civilian and State and Local data for 1968-82 from file
' containing legacy data.
import {%xlfileLV} range=Sheet1!$F$4:$G$18 colhead=0 namepos=all na="#N/A" _
       names=(oasdifc_tw_lv oasdisl_tw_lv) @freq A 1968 @smpl @all

' Get data for 1983-1993 for Federal Civilian and State and Local OASDI and HI
' taxable wages from file where these were determined for this year's Trustees
' Report.
import {%xlfileHI} range=GovtSector!$D$23:$E$33 colhead=0 namepos=all _
       na="#N/A" names=(oasdifc_tw_hi oasdisl_tw_hi) @freq A 1983 @smpl @all
import {%xlfileHI} range=GovtSector!$L$23:$M$33 colhead=0 namepos=all _
       na="#N/A" names=(hifc_tw_hi hisl_tw_hi) @freq A 1983 @smpl @all

' Get data for 1987-99 for farm and military wages and for 1994-99 for Federal
' Civilian and State and Local wages.

' OASDI farm and military for 1987-93
import {%xlfileTW} range={%xlTab}!$D$95:$J$95 byrow namepos=all _
       na="#N/A" names=(oasdiag_tw_tw) @freq A 1987 @smpl @all
import {%xlfileTW} range={%xlTab}!$D$99:$J$99 byrow namepos=all _
       na="#N/A" names=(oasdifm_tw_tw) @freq A 1987 @smpl @all

' HI farm and military for 1991-93
import {%xlfileTW} range={%xlTab}!$H$141:$J$141 byrow namepos=all _
       na="#N/A" names=(hiag_tw_tw) @freq A 1991 @smpl @all
import {%xlfileTW} range={%xlTab}!$H$145:$J$145 byrow namepos=all _
       na="#N/A" names=(hifm_tw_tw) @freq A 1991 @smpl @all

' OASDI farm, Federal Civilian, military, and State and Local for 1994-95
import {%xlfileTW} range={%xlTab}!$AE$95:$AF$95 byrow namepos=all _
       na="#N/A" names=(oasdiag_tw_tw1) @freq A 1994 @smpl @all
import {%xlfileTW} range={%xlTab}!$AE$101:$AF$101 byrow namepos=all _
       na="#N/A" names=(oasdifc_tw_tw1) @freq A 1994 @smpl @all
import {%xlfileTW} range={%xlTab}!$AE$99:$AF$99 byrow namepos=all _
       na="#N/A" names=(oasdifm_tw_tw1) @freq A 1994 @smpl @all
import {%xlfileTW} range={%xlTab}!$AE$97:$AF$97 byrow namepos=all _
       na="#N/A" names=(oasdisl_tw_tw1) @freq A 1994 @smpl @all

' OASDI farm, Federal Civilian, military, and State and Local for 1996
import {%xlfileTW} range={%xlTab}!$AO$95:$AO$95 namepos=all _
       na="#N/A" names=(oasdiag_tw_tw2) @freq A 1996 @smpl @all
import {%xlfileTW} range={%xlTab}!$AO$101:$AO$101 namepos=all _
       na="#N/A" names=(oasdifc_tw_tw2) @freq A 1996 @smpl @all
import {%xlfileTW} range={%xlTab}!$AO$99:$AO$99 namepos=all _
       na="#N/A" names=(oasdifm_tw_tw2) @freq A 1996 @smpl @all
import {%xlfileTW} range={%xlTab}!$AO$97:$AO$97 namepos=all _
       na="#N/A" names=(oasdisl_tw_tw2) @freq A 1996 @smpl @all

' OASDI farm, Federal Civilian, military, and State and Local for 1997
import {%xlfileTW} range={%xlTab}!$AY$95:$AY$95 namepos=all _
       na="#N/A" names=(oasdiag_tw_tw3) @freq A 1997 @smpl @all
import {%xlfileTW} range={%xlTab}!$AY$102:$AY$102 namepos=all _
       na="#N/A" names=(oasdifc_tw_tw3) @freq A 1997 @smpl @all
import {%xlfileTW} range={%xlTab}!$AY$99:$AY$99 namepos=all _
       na="#N/A" names=(oasdifm_tw_tw3) @freq A 1997 @smpl @all
import {%xlfileTW} range={%xlTab}!$AY$97:$AY$97 namepos=all _
       na="#N/A" names=(oasdisl_tw_tw3) @freq A 1997 @smpl @all

' OASDI farm, Federal Civilian, military, and State and Local for 1998-99
import {%xlfileTW} range={%xlTab}!$BS$95:$BT$95 byrow namepos=all _
       na="#N/A" names=(oasdiag_tw_tw4) @freq A 1998 @smpl @all
import {%xlfileTW} range={%xlTab}!$BS$101:$BT$101 byrow namepos=all _
       na="#N/A" names=(oasdifc_tw_tw4) @freq A 1998 @smpl @all
import {%xlfileTW} range={%xlTab}!$BS$99:$BT$99 byrow namepos=all _
       na="#N/A" names=(oasdifm_tw_tw4) @freq A 1998 @smpl @all
import {%xlfileTW} range={%xlTab}!$BS$97:$BT$97 byrow namepos=all _
       na="#N/A" names=(oasdisl_tw_tw4) @freq A 1998 @smpl @all

' Get historical data for 2000 on for the farm, military, Federal
' Civilian, and State and Local sectors from the EstFinTaxEarn file.

wfopen %wkfileTS_FP

pageselect {%wkpage}

copy wspf_o work::a\oasdiag_tw_ts
copy oasdifm_tw work::a\oasdifm_tw_ts
copy oasdifc_tw work::a\oasdifc_tw_ts
copy oasdisl_tw work::a\oasdisl_tw_ts

close %wkfileTS

'Call subroutine to determine column containing latest year of data.
call GetCol("B", 2007, !lyhd, %sCol)

' Get data for 2007 through the latest historical year for the Federal Civilian
' and State and Local sectors.
import {%xlfileGS} range=Final!$B$9:{%sCol}$9 byrow namepos=all _
       na="#N/A" names=(oasdifc_tw_gs) @freq A 2007 @smpl @all
import {%xlfileGS} range=Final!$B$18:{%sCol}$18 byrow namepos=all _
       na="#N/A" names=(oasdisl_tw_gs) @freq A 2007 @smpl @all

' Store values for farm, Federal Civilian, military, and State and Local taxable
' wages in series to output to workfile.

' Data from legacy values file (already in $ billions)
'   Farm and military
smpl 1971 1986
series oasdiag_tw = oasdiag_tw_lv
smpl 1968 1986
series oasdifm_tw = oasdifm_tw_lv
'   Federal Civilian and State and Local
smpl 1968 1982
series oasdifc_tw = oasdifc_tw_lv
series oasdisl_tw = oasdisl_tw_lv
' Set HI to OASDI amounts.
series hifc_tw = oasdifc_tw
series hisl_tw = oasdisl_tw

' Data from HI taxable payroll file for this year's TR (already in $ billions)
smpl 1983 1993
series oasdifc_tw = oasdifc_tw_hi
series oasdisl_tw = oasdisl_tw_hi
series hifc_tw = hifc_tw_hi
series hisl_tw = hisl_tw_hi

' Data from October 2006 bmtony file (in $ millions)
'   Farm and military
smpl 1987 1993
series oasdiag_tw = oasdiag_tw_tw
series oasdifm_tw = oasdifm_tw_tw
' Set HI farm and military data for 1987-90 to OASDI amounts.
smpl 1971 1990
series hiag_tw = oasdiag_tw
smpl 1968 1990
series hifm_tw = oasdifm_tw
' HI farm and military data for 1987-90
smpl 1991 1993
series hiag_tw = hiag_tw_tw
series hifm_tw = hifm_tw_tw
'OASDI data from various columns in file
smpl 1994 1995
series oasdiag_tw = oasdiag_tw_tw1
series oasdifc_tw = oasdifc_tw_tw1
series oasdifm_tw = oasdifm_tw_tw1
series oasdisl_tw = oasdisl_tw_tw1
smpl 1996 1996
series oasdiag_tw = oasdiag_tw_tw2
series oasdifc_tw = oasdifc_tw_tw2
series oasdifm_tw = oasdifm_tw_tw2
series oasdisl_tw = oasdisl_tw_tw2
smpl 1997 1997
series oasdiag_tw = oasdiag_tw_tw3
series oasdifc_tw = oasdifc_tw_tw3
series oasdifm_tw = oasdifm_tw_tw3
series oasdisl_tw = oasdisl_tw_tw3
smpl 1998 1999
series oasdiag_tw = oasdiag_tw_tw4
series oasdifc_tw = oasdifc_tw_tw4
series oasdifm_tw = oasdifm_tw_tw4
series oasdisl_tw = oasdisl_tw_tw4

' Data from latest estimated taxable earnings file
'  Farm and military for 2000 to latest historical year
smpl 2000 !lyhd
series oasdifm_tw = oasdifm_tw_ts
series oasdiag_tw = oasdiag_tw_ts
' Federal Civilian and State and Local for 2000-2006
smpl 2000 2006
series oasdifc_tw = oasdifc_tw_ts
series oasdisl_tw = oasdisl_tw_ts

' Data from government sector file
smpl 2007 !lyhd
series oasdifc_tw = oasdifc_tw_gs / 1000
series oasdisl_tw = oasdisl_tw_gs / 1000

' Convert values in $ millions to $ billions.
smpl 1987 1999
series oasdiag_tw = oasdiag_tw / 1000
series oasdifm_tw = oasdifm_tw / 1000
smpl 1994 1999
series oasdifc_tw = oasdifc_tw / 1000
series oasdisl_tw = oasdisl_tw / 1000
smpl 1991 1993
series hiag_tw = hiag_tw / 1000
series hifm_tw = hifm_tw / 1000

' Set HI to OASDI amounts.
smpl 1971 1990
series hiag_tw = oasdiag_tw
series hifm_tw = oasdifm_tw


' Delete series read from A bank that are not needed on output workfile and
' rename series saved earlier.
delete ce_m *_gs *_hi *_lv *_ts *tw_tw* tcea
rename ce_m_p ce_m
rename tcea_p tcea

smpl @all
wfsave %outfile

close @all

subroutine GetCol(string %sCol, scalar !sYr, scalar !eYr, string %eCol)

  %eCol =@chr(!eYr - !sYr + @asc(%sCol))
  
endsub


