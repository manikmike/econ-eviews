' Program: Ck_rHIOASDI.prg
'
' This Command File checks TRalt2 data that Karen sends to Kyle Burkhalter. The data are the ratio of HI to OASDI covered employment by
' age and sex.  
' To verify, I created the following groups:
'  1. ce_m_ck: verifies that the aggregate CE_M from atr file matches the sum of ce_m_m and ce_m_f that are constructed from age-sex specific components.
'  2. te_ck: verifies that ce_m-he_m that are constructed in the program matches the difference between tceahi and tcea.  This provides assurance that all he_m components are entered correctly.
'  3. ce and he: spot check the age-sex specific groups for ce and he
'  4. tel: spot check the age-sex specific groups for suspense file wages from legal permanent residents.
'  5. teo: spot checks the age-sex specific groups for suspense file wages from other immigrant pop.
'  6. rhi_m: contains the ratios of hi to OASDI covered wages that we send to Kyle (Awards and Cost team).  
'
'  Bob Weathers, 4-4-2017

'Update the input and output files below each year:

dbopen(type=aremos) "\\s1f906b\econ\aremos\tr2017 banks\secret place\atr172.bnk"

wfcreate(wf=ck_ks_tr16 page=rawdata_tr17) a 2010 2091
'ce_m is OASDI covered workers on mef, he_m is HI covered workers on MEF, tel_so_ is the lpr on suspense file only, teo_esf_m is the other immigrant population on suspense file only.
fetch ce_m ce_m_m15u ce_m_m???? ce_m_m70o ce_m_f15u ce_m_f???? ce_m_f70o he_m_m15u he_m_m???? he_m_m70o he_m_f15u he_m_f???? he_m_f70o tel_so_m???? tel_so_m70o tel_so_f???? tel_so_f70o 
fetch tceahi tcea tesl_n_n_hi tesl_n_n_hi_se tefc_n_n tefc_n_n_se wsw_hio_oth wsw_hio_oth_se
close atr172.bnk

'teo_esf_m is the other immigrant population on suspense file only.
dbopen(type=aremos) "\\s1f906b\econ\aremos\tr2017 banks\secret place\otl_tr172.bnk"
fetch teo_esf teo_esf_m???? teo_esf_m70o teo_esf_f???? teo_esf_f70o
close otl_tr172



'Construct ce_m variables to perform check: 
genr ce_m_m1619=ce_m_m1617+ce_m_m1819
genr ce_m_f1619=ce_m_f1617+ce_m_f1819
genr ce_m_m=ce_m_m15u+ce_m_m1619+ce_m_m2024+ce_m_m2529+ce_m_m3034+ce_m_m3539+ce_m_m4044+ce_m_m4549+ce_m_m5054+ce_m_m5559+ce_m_m6064+ce_m_m6569+ce_m_m70o
genr ce_m_f=ce_m_f15u+ce_m_f1619+ce_m_f2024+ce_m_f2529+ce_m_f3034+ce_m_f3539+ce_m_f4044+ce_m_f4549+ce_m_f5054+ce_m_f5559+ce_m_f6064+ce_m_f6569+ce_m_f70o
genr ce_m1=ce_m_f+ce_m_m

'Check1: Aggregate CE_M from atr file matches the sum of ce_m_m and ce_m_f that are constructed from age-sex specific components.
group ce_m_ck ce_m ce_m1 ce_m_m ce_m_f

'Construct he_m variables to perform check:
genr he_m_m1619=he_m_m1617+he_m_m1819
genr he_m_m=he_m_m15u+he_m_m1619+he_m_m2024+he_m_m2529+he_m_m3034+he_m_m3539+he_m_m4044+he_m_m4549+he_m_m5054+he_m_m5559+he_m_m6064+he_m_m6569+he_m_m70o

genr he_m_f1619=he_m_f1617+he_m_f1819
genr he_m_f=he_m_f15u+he_m_f1619+he_m_f2024+he_m_f2529+he_m_f3034+he_m_f3539+he_m_f4044+he_m_f4549+he_m_f5054+he_m_f5559+he_m_f6064+he_m_f6569+he_m_f70o
genr he_m=he_m_f+he_m_m

genr tce_diff=tceahi-tcea
genr he_ce_df=he_m-ce_m
genr tesl_diff=tesl_n_n_hi-tesl_n_n_hi_se
genr tefc_diff=tefc_n_n-tefc_n_n_se
genr wsw_diff=wsw_hio_oth-wsw_hio_oth_se

'Check 2: Verifies that ce_m-he_m that are constructed in the program matches the difference between tceahi and tcea.  This provides assurance that all he_m components are entered correctly.
group te_ck tce_diff he_ce_df tesl_diff tefc_diff wsw_diff


'Construct HI to OASDI covered ratios:
%sex = "m f"
%age= "15u 1619 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o"

genr tel_so_m15u=0
genr tel_so_f15u=0
genr teo_esf_m15u=0
genr teo_esf_f15u=0
genr he_m_m1619=he_m_m1617+he_m_m1819
genr he_m_f1619=he_m_f1617+he_m_f1819
genr tel_so_m1619=tel_so_m1617+tel_so_m1819
genr tel_so_f1619=tel_so_f1617+tel_so_f1819
genr teo_esf_m1619=teo_esf_m1617+teo_esf_m1819
genr teo_esf_f1619=teo_esf_f1617+teo_esf_f1819


for %a {%age}
 for %s {%sex}
  genr rhi_{%s}_{%a} = (he_m_{%s}{%a}+tel_so_{%s}{%a}+teo_esf_{%s}{%a})/(ce_m_{%s}{%a}+tel_so_{%s}{%a}+teo_esf_{%s}{%a})
 next
next

for %a {%age}
  genr rhi_{%a} = (he_m_m{%a}+tel_so_m{%a}+teo_esf_m{%a}+he_m_f{%a}+tel_so_f{%a}+teo_esf_f{%a})/(ce_m_m{%a}+tel_so_m{%a}+teo_esf_m{%a}+ce_m_f{%a}+tel_so_f{%a}+teo_esf_f{%a})
next


'Final groups for check:
group he he_m_m15u he_m_m???? he_m_m70o he_m_f15u he_m_f???? he_m_f70o
group ce ce_m_m15u ce_m_m???? ce_m_m70o ce_m_f15u ce_m_f???? ce_m_f70o
group tel tel_so_m* tel_so_f*
group teo teo_esf_m* teo_esf_f*
group rhi_m rhi_m_* rhi_f_* rhi_15u rhi_1619 rhi_2024 rhi_2529 rhi_3034 rhi_3539 rhi_4044 rhi_4549 rhi_5054 rhi_5559 rhi_6064 rhi_6569 rhi_70o

'The End
