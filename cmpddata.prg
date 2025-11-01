' This program is called by cmpdexcel.prg to gather historical data for the
' Long-Range Assumptions Memo tables

!TRYEAR = @val(%0) ' Trustees Report year passed as parameter (e.g., 2024)

!yr2 = !TRYEAR - 2 ' Last year of historical data (e.g., 2022)
%abank = "atr" + @str(!TRYEAR - 2000 - 1) + "2" ' Output ABANK from previous TR (e.g, atr222)

exec .\setup2

pageselect a
smpl 1948 {!yr2}

' Update the following series with the most recent historical data

' ************* Adjusted CPIW ***********************

import "S:\LRECON\TrusteesReports\Assumptions\Inflation\TR2025 - CPIW and PGDP.xlsx" _
   range="Table 1 - CPI Lev. & ann. % ch"!$L$16:$L$91 colhead=0 namepos=all _
   na="#N/A" names=("cpiwadj") @freq A 1948 @smpl 1948 2023


' ************* Unadjusted CPIW ***********************

import "S:\LRECON\TrusteesReports\Assumptions\Inflation\TR2025 - CPIW and PGDP.xlsx" _
   range="BLS CPI-W"!$N$37:$N$123 colhead=0 namepos=all _
   na="#N/A" names=("cpiwunadj") @freq A 1937 @smpl 1937 2023

smpl 1937 {!yr2}
series cpiwunadj = cpiwunadj / 100
smpl 1948 {!yr2}


' ************* Adjusted PGDP ***********************

import "S:\LRECON\TrusteesReports\Assumptions\Inflation\TR2025 - CPIW and PGDP.xlsx" _
   range="Table 4 - PGDP Lev. & ann. % ch"!$P$16:$P$91 colhead=0 namepos=all _
   na="#N/A" names=("pgdpadj") @freq A 1948 @smpl 1948 2023


' ************* Total Hours ***********************

pageselect q
import "S:\LRECON\Data\Raw\BLS\Hours\total-economy-hours-employment_20240905.xlsx" _
   range="Quarterly"!$J$4:$LA$4 byrow colhead=0 namepos=all _
   na="#N/A" names=("tothrs") @freq Q 1948q1 @smpl 1948q1 2023q4
copy tothrs a\tothrs
delete tothrs
pageselect a


' ************* Adjusted Employment ***********************

wfopen S:\LRECON\Data\Processed\BLS\BLSadj\blsadj24.wf1
   copy  blsadj24::data_a\e16o_aadj work::a\temp
wfclose blsadj24
wfselect work
pageselect a
smpl 1965 {!yr2}
series eadj = temp
delete temp


' ************* BKDR1 ***********************

'dbopen(type=aremos) bkdr1.bnk
wfopen bkdr1.wf1

wfselect work
pageselect a
smpl 1937 1969
'series cemu20 = bkdr1::cemu20
copy bkdr1::a\cemu20 work::a\
'series cefu20 = bkdr1::cefu20
copy bkdr1::a\cefu20 work::a\

for %s m f
   series ce{%s}u20 = ce{%s}u20 / 1000
next

close bkdr1


' ************* ABANK ***********************

pageselect a
smpl 1937 {!yr2}

'dbopen(type=aremos) {%abank}.bnk
wfopen {%abank}.wf1

wfselect work
pageselect a
copy {%abank}::a\cem* work::a\cem*
copy {%abank}::a\cef* work::a\cef*

group g cem* cef*
%slist = g.@members
delete g
for %s {%slist}
   smpl {!yr2}+1 2100
   {%s} = na
next

smpl 1970 {!yr2}
for %s m f
   ce{%s}u20 = 0
   for !a = 0 to 15
      ce{%s}u20 = ce{%s}u20 + ce{%s}{!a}
   next
   for %ag 1617 1819
      ce{%s}u20 = ce{%s}u20 + ce{%s}{%ag}
   next
next

%a = "cse csw tcea wsca wswa"
pageselect a
smpl 1937 {!yr2}
for %s {%a}
   series {%s} = {%abank}::{%s}
next

'wfopen ssaprogdata
'wfselect work
'pageselect a
'smpl 1950 1990
'copy ssaprogdata::a\cse_tot cse_tot
'close ssaprogdata

wfselect work
pageselect a
smpl 1950 {!yr2}
series cse_tot = {%abank}::cse_tot
close {%abank}


' ************* BKDO1 ***********************

'dbopen(type=aremos) bkdo1.bnk
wfopen bkdo1.wf1
%copy_sample = "1937 " + @str(!yr2)
wfselect work
pageselect a
smpl 1937 {!yr2}
%b = "cpiw_u e eaw edmil ena enas enau gdp gdp17 kgdp17 pgdp pgdpi wsd wss yf ynf"
for %s {%b}
   'series {%s} = bkdo1::{%s}
   copy(smpl=%copy_sample) bkdo1::a\{%s} work::a\{%s}
next

for %t l r
   for %s m f
      for %ag 6569 7074 75o 65o
         'series {%t}{%s}{%ag} = bkdo1::{%t}{%s}{%ag}
			copy bkdo1::a\{%t}{%s}{%ag} work::a\{%t}{%s}{%ag}
      next
   next
next

series rm70o = ((lm7074 * rm7074) + (lm75o *rm75o)) / (lm7074 + lm75o)
series rf70o = ((lf7074 * rf7074) + (lf75o *rf75o)) / (lf7074 + lf75o)
series lm70o = lm65o - lm6569
series lf70o = lf65o - lf6569

for %t l r
   for %s m f
      for %ag 7074 75o
         delete {%t}{%s}{%ag}
      next
   next
next

for %t l r
   for %s m f
      for %ag 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o _
              2534 3544 4554 5564 65o 
         'series {%t}{%s}{%ag} = bkdo1::{%t}{%s}{%ag}
			copy bkdo1::a\{%t}{%s}{%ag} work::a\{%t}{%s}{%ag}
      next
   next
next

for %s m f
   for %ag 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559
      'series n{%s}{%ag}m = bkdo1::n{%s}{%ag}m
		copy(smpl=%copy_sample) bkdo1::a\n{%s}{%ag}m work::a\n{%s}{%ag}m
   next
next

smpl 1948 1977
series gdp17adj = gdp / pgdpadj
smpl 1978 {!yr2}
series gdp17adj = gdp17

close bkdo1


' ************* COPY DATA to COMPDATA ***********************

'dbopen(type=aremos) compdata.bnk
wfopen compdata.wf1

wfselect work
pageselect a
smpl 1937 {!yr2}

for %s m f
   for %ag u20 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
      copy(m) ce{%s}{%ag} compdata::a\ce{%s}{%ag}
   next
   copy(m) ce{%s} compdata::a\ce{%s}
next

smpl 1951 2022
for %s {%a}
   copy(m) {%s} compdata::a\{%s}
next

smpl 1937 2022
for %s {%b}
   copy(m) {%s} compdata::a\{%s}
next
copy(m) rf* compdata::a\rf*
copy(m) rm* compdata::a\rm*
copy(m) l* compdata::a\l*
copy(m) n* compdata::a\n*
for %s cpiwadj cpiwunadj pgdpadj gdp17adj eadj tothrs cse_tot
   copy(m) {%s} compdata::a\{%s}
next

delete *
copy compdata::a\* a\*

wfselect compdata
pageselect a
wfsave compdata
close compdata


