' Requested by Kyle Burkhalter & Chris Chaplain 
' Saved three sheets of hi_tr21.xlsx (Ratio Total, Ratio Male, Ratio Female) in
' a new file for Chris: Ratio of HI to OASDI Covered TR 2021 Alt 2.xlsx

' Update these parameters for the appropriate Trustees Report
shell copy "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\atr252.wf1" .
%abank = "atr252"
%outfile = "Ratio of HI to OASDI Covered TR 2025 Alt 2.xlsx"

exec .\setup2
pageselect a
sample export 2000 2100
smpl export

wfopen {%abank}

' Teenage HI and OASDI Covered by sex and age group
copy {%abank}::a\ce_m_m15u work::a\cem15u
copy {%abank}::a\ce_m_f15u work::a\cef15u

copy {%abank}::a\cem1617 work::a\*
copy {%abank}::a\cem1819 work::a\*
copy {%abank}::a\cef1617 work::a\*
copy {%abank}::a\cef1819 work::a\*

'series cem15u = {%abank}::ce_m_m15u
'series cef15u = {%abank}::ce_m_f15u

wfselect work
pageselect a
smpl export

series cem15u_hi = cem15u
series cef15u_hi = cef15u

series cem1619 = cem1617 + cem1819
series cef1619 = cef1617 + cef1819

' HI and OASDI Covered by sex and age group
for %s m f
	for %a 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
		copy {%abank}::a\he_m_{%s}{%a} work::a\*
      copy {%abank}::a\te_s_{%s}{%a} work::a\*
      copy {%abank}::a\ce{%s}{%a} work::a\*
	next
	copy {%abank}::a\he_m_{%s}1617 work::a\*
	copy {%abank}::a\te_s_{%s}1617 work::a\*
	copy {%abank}::a\he_m_{%s}1819 work::a\*
	copy {%abank}::a\te_s_{%s}1819 work::a\*
	
next
wfclose {%abank}

wfselect work
pageselect a
smpl export

for %s m f
   for %a 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
      series ce{%s}{%a}_hi = he_m_{%s}{%a} + te_s_{%s}{%a}
      'fetch(db={%atr212}) ce{%s}{%a}
   next
   
   series ce{%s}1619_hi = he_m_{%s}1617 + te_s_{%s}1617 + _
                          he_m_{%s}1819 + te_s_{%s}1819

   series ce{%s} = ce{%s}15u  + ce{%s}1619 + ce{%s}2024 + _
                   ce{%s}2529 + ce{%s}3034 + ce{%s}3539 + _
                   ce{%s}4044 + ce{%s}4549 + ce{%s}5054 + _
                   ce{%s}5559 + ce{%s}6064 + ce{%s}6569 + _
                   ce{%s}70o
next

' Total (male + female) HI and OASDI Covered by age group

for %a 15u 1619 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
   series ce{%a}_hi = cem{%a}_hi + cef{%a}_hi
   series ce{%a} = cem{%a} + cef{%a}
next
series ce = cem + cef


' Ratio of HI-covered to OASDI-covered

for %s m f
   for %a 15u 1619 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
     series ratio_{%s}{%a} = ce{%s}{%a}_hi / ce{%s}{%a}
   next
next

for %a 15u 1619 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o
   series ratio_{%a} = ce{%a}_hi / ce{%a}
next


%mratio = "ratio_m15u ratio_m1619 ratio_m2024 ratio_m2529 ratio_m3034 ratio_m3539 ratio_m4044 ratio_m4549 ratio_m5054 ratio_m5559 ratio_m6064 ratio_m6569 ratio_m70o"
%fratio = "ratio_f15u ratio_f1619 ratio_f2024 ratio_f2529 ratio_f3034 ratio_f3539 ratio_f4044 ratio_f4549 ratio_f5054 ratio_f5559 ratio_f6064 ratio_f6569 ratio_f70o"
%tratio = "ratio_15u ratio_1619 ratio_2024 ratio_2529 ratio_3034 ratio_3539 ratio_4044 ratio_4549 ratio_5054 ratio_5559 ratio_6064 ratio_6569 ratio_70o"

pagesave(type="excelxml",mode="update",noid) %outfile range="RATIO Male!B6" nonames @smpl export @keep {%mratio}
pagesave(type="excelxml",mode="update",noid) %outfile range="RATIO Female!B6" nonames @smpl export @keep {%fratio}
pagesave(type="excelxml",mode="update",noid) %outfile range="RATIO Total!B6" nonames @smpl export @keep {%tratio}

close @db
close @wf


