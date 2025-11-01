' This version of the program saves a copy of the workfile (under name cps_nilf_monthly_for_checking.wf1 in default folder). 
' This workfile is used to perform the check; use program transform_nilf_monthly_check.prg to do the check.
' ************ Polina Vlasenko

' This program assumes that: 
' (1) the DEFAULT location contains databank cps_nilf_month.bnk -- it will be modified by this program and saved to the default location.
' (2) it can save file cps_nilf_monthly_for_checking.wf1 into the DEFAULT location. (If a file with this name already exists in this location, it will be overwritten!)
' **** Make sure all the appropriate files exist in the default location and are named as intended (i.e. to prevent overwriting anything that will be needed later).****

' UPDATE values in the section marked ****UPDATE HERE below

exec .\setup2

logmode logmsg

' ***** UPDATE HERE

%last_yr = "2024"		'latest year for which we have CPS NILF data; typically we would have data for only part of the year, usually through September
%last_mo = "9"			' the last month in the %last_yr for which we have data; typically this is September, i.e. month 9
%last_qr = "3"				' the last quarter in the %last_yr for which we have data (for the entire quarter); typically we have data through September, i.e. quarter 3
%last_full_yr = "2023"	'last year for which we have FULL YEAR of CPS NILF data

' ***** END of update section

logmode l
%msg = "Running transform_nilf_monthly.prg" 
logmsg {%msg}
logmsg

tic

wfopen cps_nilf_month.wf1

pageselect m
smpl {%last_full_yr} {%last_yr}

%a = _
   "16 17 18 19 " + _
   "20 21 22 23 24 25 26 27 28 29 " + _
   "30 31 32 33 34 35 36 37 38 39 " + _
   "40 41 42 43 44 45 46 47 48 49 " + _
   "50 51 52 53 54 55 56 57 58 59 " + _
   "60 61 62 63 64 65 66 67 68 69 " + _
   "70 71 72 73 74 75 76 77 78 79 " + _
   "80 81 82 83 84 85 86 87 88 89 " + _
   "90 16o 80o"

%a2 = _
   "80 81 82 83 84 85 86 87 88 89 " + _
   "90"
 
%sex = "m f"

'********
'********
'********

%mn = @wcross("nm", %a)
%mr1 = @wcross(@wcross("nlm", %a), "_r1")
%md1 = @wcross(@wcross("nlm", %a), "_d1")
%mo1 = @wcross(@wcross("nlm", %a), "_o1")

%fn = @wcross("nf", %a)
%fr1 = @wcross(@wcross("nlf", %a), "_r1")
%fd1 = @wcross(@wcross("nlf", %a), "_d1")
%fo1 = @wcross(@wcross("nlf", %a), "_o1")


%mn_nm = @wcross(@wcross("nm", %a), "nm")
%mr1_nm = @wcross(@wcross("nlm", %a), "nm_r1")
%md1_nm = @wcross(@wcross("nlm", %a), "nm_d1")
%mo1_nm = @wcross(@wcross("nlm", %a), "nm_o1")

%fn_nm = @wcross(@wcross("nf", %a), "nm")
%fr1_nm = @wcross(@wcross("nlf", %a), "nm_r1")
%fd1_nm = @wcross(@wcross("nlf", %a), "nm_d1")
%fo1_nm = @wcross(@wcross("nlf", %a), "nm_o1")

%mn_ms = @wcross(@wcross("nm", %a), "ms")
%mr1_ms = @wcross(@wcross("nlm", %a), "ms_r1")
%md1_ms = @wcross(@wcross("nlm", %a), "ms_d1")
%mo1_ms = @wcross(@wcross("nlm", %a), "ms_o1")

%fn_ms = @wcross(@wcross("nf", %a), "ms")
%fr1_ms = @wcross(@wcross("nlf", %a), "ms_r1")
%fd1_ms = @wcross(@wcross("nlf", %a), "ms_d1")
%fo1_ms = @wcross(@wcross("nlf", %a), "ms_o1")

%mn_ma = @wcross(@wcross("nm", %a), "ma")
%mr1_ma = @wcross(@wcross("nlm", %a), "ma_r1")
%md1_ma = @wcross(@wcross("nlm", %a), "ma_d1")
%mo1_ma = @wcross(@wcross("nlm", %a), "ma_o1")

%fn_ma = @wcross(@wcross("nf", %a), "ma")
%fr1_ma = @wcross(@wcross("nlf", %a), "ma_r1")
%fd1_ma = @wcross(@wcross("nlf", %a), "ma_d1")
%fo1_ma = @wcross(@wcross("nlf", %a), "ma_o1")

'********
'********
'********


%md2 = @wcross(@wcross("nlm", %a), "_d2")
%mi = @wcross(@wcross("nlm", %a), "_i")
%ms = @wcross(@wcross("nlm", %a), "_s")
%mh = @wcross(@wcross("nlm", %a), "_h")
%mr2 = @wcross(@wcross("nlm", %a), "_r2")
%mo2 = @wcross(@wcross("nlm", %a), "_o2")

%fd2 = @wcross(@wcross("nlf", %a), "_d2")
%fi = @wcross(@wcross("nlf", %a), "_i")
%fs = @wcross(@wcross("nlf", %a), "_s")
%fh = @wcross(@wcross("nlf", %a), "_h")
%fr2 = @wcross(@wcross("nlf", %a), "_r2")
%fo2 = @wcross(@wcross("nlf", %a), "_o2")


%md2_ms = @wcross(@wcross("nlm", %a), "ms_d2")
%mi_ms = @wcross(@wcross("nlm", %a), "ms_i")
%ms_ms = @wcross(@wcross("nlm", %a), "ms_s")
%mh_ms = @wcross(@wcross("nlm", %a), "ms_h")
%mr2_ms = @wcross(@wcross("nlm", %a), "ms_r2")
%mo2_ms = @wcross(@wcross("nlm", %a), "ms_o2")

%fd2_ms = @wcross(@wcross("nlf", %a), "ms_d2")
%fi_ms = @wcross(@wcross("nlf", %a), "ms_i")
%fs_ms = @wcross(@wcross("nlf", %a), "ms_s")
%fh_ms = @wcross(@wcross("nlf", %a), "ms_h")
%fr2_ms = @wcross(@wcross("nlf", %a), "ms_r2")
%fo2_ms = @wcross(@wcross("nlf", %a), "ms_o2")

 

%md2_ma = @wcross(@wcross("nlm", %a), "ma_d2")
%mi_ma = @wcross(@wcross("nlm", %a), "ma_i")
%ms_ma = @wcross(@wcross("nlm", %a), "ma_s")
%mh_ma = @wcross(@wcross("nlm", %a), "ma_h")
%mr2_ma = @wcross(@wcross("nlm", %a), "ma_r2")
%mo2_ma = @wcross(@wcross("nlm", %a), "ma_o2")

%fd2_ma = @wcross(@wcross("nlf", %a), "ma_d2")
%fi_ma = @wcross(@wcross("nlf", %a), "ma_i")
%fs_ma = @wcross(@wcross("nlf", %a), "ma_s")
%fh_ma = @wcross(@wcross("nlf", %a), "ma_h")
%fr2_ma = @wcross(@wcross("nlf", %a), "ma_r2")
%fo2_ma = @wcross(@wcross("nlf", %a), "ma_o2")


%md2_nm = @wcross(@wcross("nlm", %a), "nm_d2")
%mi_nm = @wcross(@wcross("nlm", %a), "nm_i")
%ms_nm = @wcross(@wcross("nlm", %a), "nm_s")
%mh_nm = @wcross(@wcross("nlm", %a), "nm_h")
%mr2_nm = @wcross(@wcross("nlm", %a), "nm_r2")
%mo2_nm = @wcross(@wcross("nlm", %a), "nm_o2")

%fd2_nm = @wcross(@wcross("nlf", %a), "nm_d2")
%fi_nm = @wcross(@wcross("nlf", %a), "nm_i")
%fs_nm = @wcross(@wcross("nlf", %a), "nm_s")
%fh_nm = @wcross(@wcross("nlf", %a), "nm_h")
%fr2_nm = @wcross(@wcross("nlf", %a), "nm_r2")
%fo2_nm = @wcross(@wcross("nlf", %a), "nm_o2")

'********
'********
'********

%me = @wcross("em", %a)
%mu = @wcross("um", %a)
%mdc = @wcross(@wcross("nlm", %a), "_dc")
%mo3 = @wcross(@wcross("nlm", %a), "_o3")

%fe = @wcross("ef", %a)
%fu = @wcross("uf", %a)
%fdc = @wcross(@wcross("nlf", %a), "_dc")
%fo3 = @wcross(@wcross("nlf", %a), "_o3")


%me_nm = @wcross(@wcross("em", %a), "nm")
%mu_nm = @wcross(@wcross("um", %a), "nm")
%mdc_nm = @wcross(@wcross("nlm", %a), "nm_dc")
%mo3_nm = @wcross(@wcross("nlm", %a), "nm_o3")

%fe_nm = @wcross(@wcross("ef", %a), "nm")
%fu_nm = @wcross(@wcross("uf", %a), "nm")
%fdc_nm = @wcross(@wcross("nlf", %a), "nm_dc")
%fo3_nm = @wcross(@wcross("nlf", %a), "nm_o3")

%me_ms = @wcross(@wcross("em", %a), "ms")
%mu_ms = @wcross(@wcross("um", %a), "ms")
%mdc_ms = @wcross(@wcross("nlm", %a), "ms_dc")
%mo3_ms = @wcross(@wcross("nlm", %a), "ms_o3")

%fe_ms = @wcross(@wcross("ef", %a), "ms")
%fu_ms = @wcross(@wcross("uf", %a), "ms")
%fdc_ms = @wcross(@wcross("nlf", %a), "ms_dc")
%fo3_ms = @wcross(@wcross("nlf", %a), "ms_o3")

%me_ma = @wcross(@wcross("em", %a), "ma")
%mu_ma = @wcross(@wcross("um", %a), "ma")
%mdc_ma = @wcross(@wcross("nlm", %a), "ma_dc")
%mo3_ma = @wcross(@wcross("nlm", %a), "ma_o3")

%fe_ma = @wcross(@wcross("ef", %a), "ma")
%fu_ma = @wcross(@wcross("uf", %a), "ma")
%fdc_ma = @wcross(@wcross("nlf", %a), "ma_dc")
%fo3_ma = @wcross(@wcross("nlf", %a), "ma_o3")


%nilf_lcstatus =     %mn    + " " + %mr1    + " " + %md1    + " " + %mo1 + " " + _
                     %fn    + " " + %fr1    + " " + %fd1    + " " + %fo1 + " " + _
                     %mn_nm + " " + %mr1_nm + " " + %md1_nm + " " + %mo1_nm + " " + _
                     %fn_nm + " " + %fr1_nm + " " + %fd1_nm + " " + %fo1_nm + " " + _
                     %mn_ms + " " + %mr1_ms + " " + %md1_ms + " " + %mo1_ms + " " + _
                     %fn_ms + " " + %fr1_ms + " " + %fd1_ms + " " + %fo1_ms + " " + _
                     %mn_ma + " " + %mr1_ma + " " + %md1_ma + " " + %mo1_ma + " " + _
                     %fn_ma + " " + %fr1_ma + " " + %fd1_ma + " " + %fo1_ma

%nilf_reason   =     %mi    + " " + %ms     + " " + %mh     + " " + %mr2    + " " + %md2    + " " + %mo2 + " " +  _
                     %fi    + " " + %fs     + " " + %fh     + " " + %fr2    + " " + %fd2    + " " + %fo2 + " " + _
                     %mi_nm + " " + %ms_nm  + " " + %mh_nm  + " " + %mr2_nm + " " + %md2_nm + " " + %mo2_nm + " " + _
                     %fi_nm + " " + %fs_nm  + " " + %fh_nm  + " " + %fr2_nm + " " + %fd2_nm + " " + %fo2_nm + " " + _      
                     %mi_ms + " " + %ms_ms  + " " + %mh_ms  + " " + %mr2_ms + " " + %md2_ms + " " + %mo2_ms + " " + _
                     %fi_ms + " " + %fs_ms  + " " + %fh_ms  + " " + %fr2_ms + " " + %fd2_ms + " " + %fo2_ms + " " + _      
                     %mi_ma + " " + %ms_ma  + " " + %mh_ma  + " " + %mr2_ma + " " + %md2_ma + " " + %mo2_ma + " " + _
                     %fi_ma + " " + %fs_ma  + " " + %fh_ma  + " " + %fr2_ma + " " + %fd2_ma + " " + %fo2_ma    
                     
                     
%nilf_disc     =     %me    + " " + %mu    + " " + %mdc    + " " + %mo3 + " " + _
                     %fe    + " " + %fu    + " " + %fdc    + " " + %fo3 + " " + _
                     %me_nm + " " + %mu_nm + " " + %mdc_nm + " " + %mo3_nm + " " + _
                     %fe_nm + " " + %fu_nm + " " + %fdc_nm + " " + %fo3_nm + " " + _
                     %me_ms + " " + %mu_ms + " " + %mdc_ms + " " + %mo3_ms + " " + _
                     %fe_ms + " " + %fu_ms + " " + %fdc_ms + " " + %fo3_ms + " " + _
                     %me_ma + " " + %mu_ma + " " + %mdc_ma + " " + %mo3_ma + " " + _
                     %fe_ma + " " + %fu_ma + " " + %fdc_ma + " " + %fo3_ma
                     

%nilf_import   = %nilf_lcstatus + " " + %nilf_reason + " " + %nilf_disc

wfselect work
pageselect m
copy cps_nilf_month::m\* work::m\*


'logmode l
%msg = "Done loading monthly data for SYOA" 
logmsg {%msg}
logmsg


'Create series for 5yr and other interval age groups
for %s m f
   for %c r1 d1 o1 d2 r2 i s h o2 dc o3
      genr nl{%s}1617_{%c} = nl{%s}16_{%c} + nl{%s}17_{%c}
      genr nl{%s}1819_{%c} = nl{%s}18_{%c} + nl{%s}19_{%c}
      genr nl{%s}2024_{%c} = nl{%s}20_{%c} + nl{%s}21_{%c} + nl{%s}22_{%c} + nl{%s}23_{%c} + nl{%s}24_{%c}
      genr nl{%s}2529_{%c} = nl{%s}25_{%c} + nl{%s}26_{%c} + nl{%s}27_{%c} + nl{%s}28_{%c} + nl{%s}29_{%c}
      genr nl{%s}3034_{%c} = nl{%s}30_{%c} + nl{%s}31_{%c} + nl{%s}32_{%c} + nl{%s}33_{%c} + nl{%s}34_{%c}
      genr nl{%s}3539_{%c} = nl{%s}35_{%c} + nl{%s}36_{%c} + nl{%s}37_{%c} + nl{%s}38_{%c} + nl{%s}39_{%c}
      genr nl{%s}4044_{%c} = nl{%s}40_{%c} + nl{%s}41_{%c} + nl{%s}42_{%c} + nl{%s}43_{%c} + nl{%s}44_{%c}
      genr nl{%s}4549_{%c} = nl{%s}45_{%c} + nl{%s}46_{%c} + nl{%s}47_{%c} + nl{%s}48_{%c} + nl{%s}49_{%c}
      genr nl{%s}5054_{%c} = nl{%s}50_{%c} + nl{%s}51_{%c} + nl{%s}52_{%c} + nl{%s}53_{%c} + nl{%s}54_{%c}
      genr nl{%s}5559_{%c} = nl{%s}55_{%c} + nl{%s}56_{%c} + nl{%s}57_{%c} + nl{%s}58_{%c} + nl{%s}59_{%c}
      genr nl{%s}6064_{%c} = nl{%s}60_{%c} + nl{%s}61_{%c} + nl{%s}62_{%c} + nl{%s}63_{%c} + nl{%s}64_{%c}
      genr nl{%s}6569_{%c} = nl{%s}65_{%c} + nl{%s}66_{%c} + nl{%s}67_{%c} + nl{%s}68_{%c} + nl{%s}69_{%c}
      genr nl{%s}7074_{%c} = nl{%s}70_{%c} + nl{%s}71_{%c} + nl{%s}72_{%c} + nl{%s}73_{%c} + nl{%s}74_{%c}
      genr nl{%s}7579_{%c} = nl{%s}75_{%c} + nl{%s}76_{%c} + nl{%s}77_{%c} + nl{%s}78_{%c} + nl{%s}79_{%c}

      genr nl{%s}1619_{%c} = nl{%s}1617_{%c} + nl{%s}1819_{%c}
      genr nl{%s}75o_{%c}  = nl{%s}7579_{%c} + nl{%s}80o_{%c}
      genr nl{%s}65o_{%c}  = nl{%s}6569_{%c} + nl{%s}7074_{%c} + nl{%s}75o_{%c}
      genr nl{%s}55o_{%c}  = nl{%s}5559_{%c} + nl{%s}6064_{%c} + nl{%s}65o_{%c}
   next
next

for %c n e u
   for %s m f
      genr {%c}{%s}1617 = {%c}{%s}16 + {%c}{%s}17
      genr {%c}{%s}1819 = {%c}{%s}18 + {%c}{%s}19
      genr {%c}{%s}2024 = {%c}{%s}20 + {%c}{%s}21 + {%c}{%s}22 + {%c}{%s}23 + {%c}{%s}24
      genr {%c}{%s}2529 = {%c}{%s}25 + {%c}{%s}26 + {%c}{%s}27 + {%c}{%s}28 + {%c}{%s}29
      genr {%c}{%s}3034 = {%c}{%s}30 + {%c}{%s}31 + {%c}{%s}32 + {%c}{%s}33 + {%c}{%s}34
      genr {%c}{%s}3539 = {%c}{%s}35 + {%c}{%s}36 + {%c}{%s}37 + {%c}{%s}38 + {%c}{%s}39
      genr {%c}{%s}4044 = {%c}{%s}40 + {%c}{%s}41 + {%c}{%s}42 + {%c}{%s}43 + {%c}{%s}44
      genr {%c}{%s}4549 = {%c}{%s}45 + {%c}{%s}46 + {%c}{%s}47 + {%c}{%s}48 + {%c}{%s}49
      genr {%c}{%s}5054 = {%c}{%s}50 + {%c}{%s}51 + {%c}{%s}52 + {%c}{%s}53 + {%c}{%s}54
      genr {%c}{%s}5559 = {%c}{%s}55 + {%c}{%s}56 + {%c}{%s}57 + {%c}{%s}58 + {%c}{%s}59
      genr {%c}{%s}6064 = {%c}{%s}60 + {%c}{%s}61 + {%c}{%s}62 + {%c}{%s}63 + {%c}{%s}64
      genr {%c}{%s}6569 = {%c}{%s}65 + {%c}{%s}66 + {%c}{%s}67 + {%c}{%s}68 + {%c}{%s}69
      genr {%c}{%s}7074 = {%c}{%s}70 + {%c}{%s}71 + {%c}{%s}72 + {%c}{%s}73 + {%c}{%s}74
      genr {%c}{%s}7579 = {%c}{%s}75 + {%c}{%s}76 + {%c}{%s}77 + {%c}{%s}78 + {%c}{%s}79

      genr {%c}{%s}1619 = {%c}{%s}1617 + {%c}{%s}1819
      genr {%c}{%s}75o  = {%c}{%s}7579 + {%c}{%s}80o
      genr {%c}{%s}65o  = {%c}{%s}6569 + {%c}{%s}7074 + {%c}{%s}75o
      genr {%c}{%s}55o  = {%c}{%s}5559 + {%c}{%s}6064 + {%c}{%s}65o
   next
next

for %s m f
   for %c r1 d1 o1 d2 r2 i s h o2 dc o3
      for %m nm ms ma
         genr nl{%s}1617{%m}_{%c} = nl{%s}16{%m}_{%c} + nl{%s}17{%m}_{%c}
         genr nl{%s}1819{%m}_{%c} = nl{%s}18{%m}_{%c} + nl{%s}19{%m}_{%c}
         genr nl{%s}2024{%m}_{%c} = nl{%s}20{%m}_{%c} + nl{%s}21{%m}_{%c} + nl{%s}22{%m}_{%c} + nl{%s}23{%m}_{%c} + nl{%s}24{%m}_{%c}
         genr nl{%s}2529{%m}_{%c} = nl{%s}25{%m}_{%c} + nl{%s}26{%m}_{%c} + nl{%s}27{%m}_{%c} + nl{%s}28{%m}_{%c} + nl{%s}29{%m}_{%c}
         genr nl{%s}3034{%m}_{%c} = nl{%s}30{%m}_{%c} + nl{%s}31{%m}_{%c} + nl{%s}32{%m}_{%c} + nl{%s}33{%m}_{%c} + nl{%s}34{%m}_{%c}
         genr nl{%s}3539{%m}_{%c} = nl{%s}35{%m}_{%c} + nl{%s}36{%m}_{%c} + nl{%s}37{%m}_{%c} + nl{%s}38{%m}_{%c} + nl{%s}39{%m}_{%c}
         genr nl{%s}4044{%m}_{%c} = nl{%s}40{%m}_{%c} + nl{%s}41{%m}_{%c} + nl{%s}42{%m}_{%c} + nl{%s}43{%m}_{%c} + nl{%s}44{%m}_{%c}
         genr nl{%s}4549{%m}_{%c} = nl{%s}45{%m}_{%c} + nl{%s}46{%m}_{%c} + nl{%s}47{%m}_{%c} + nl{%s}48{%m}_{%c} + nl{%s}49{%m}_{%c}
         genr nl{%s}5054{%m}_{%c} = nl{%s}50{%m}_{%c} + nl{%s}51{%m}_{%c} + nl{%s}52{%m}_{%c} + nl{%s}53{%m}_{%c} + nl{%s}54{%m}_{%c}
         genr nl{%s}5559{%m}_{%c} = nl{%s}55{%m}_{%c} + nl{%s}56{%m}_{%c} + nl{%s}57{%m}_{%c} + nl{%s}58{%m}_{%c} + nl{%s}59{%m}_{%c}
         genr nl{%s}6064{%m}_{%c} = nl{%s}60{%m}_{%c} + nl{%s}61{%m}_{%c} + nl{%s}62{%m}_{%c} + nl{%s}63{%m}_{%c} + nl{%s}64{%m}_{%c}
         genr nl{%s}6569{%m}_{%c} = nl{%s}65{%m}_{%c} + nl{%s}66{%m}_{%c} + nl{%s}67{%m}_{%c} + nl{%s}68{%m}_{%c} + nl{%s}69{%m}_{%c}
         genr nl{%s}7074{%m}_{%c} = nl{%s}70{%m}_{%c} + nl{%s}71{%m}_{%c} + nl{%s}72{%m}_{%c} + nl{%s}73{%m}_{%c} + nl{%s}74{%m}_{%c}
         genr nl{%s}7579{%m}_{%c} = nl{%s}75{%m}_{%c} + nl{%s}76{%m}_{%c} + nl{%s}77{%m}_{%c} + nl{%s}78{%m}_{%c} + nl{%s}79{%m}_{%c}

         genr nl{%s}1619{%m}_{%c} = nl{%s}1617{%m}_{%c} + nl{%s}1819{%m}_{%c}
         genr nl{%s}75o{%m}_{%c}  = nl{%s}7579{%m}_{%c} + nl{%s}80o{%m}_{%c}
         genr nl{%s}65o{%m}_{%c}  = nl{%s}6569{%m}_{%c} + nl{%s}7074{%m}_{%c} + nl{%s}75o{%m}_{%c}
         genr nl{%s}55o{%m}_{%c}  = nl{%s}5559{%m}_{%c} + nl{%s}6064{%m}_{%c} + nl{%s}65o{%m}_{%c}
      next
   next
next

for %c n e u
   for %s m f
      for %m nm ms ma
         genr {%c}{%s}1617{%m} = {%c}{%s}16{%m} + {%c}{%s}17{%m}
         genr {%c}{%s}1819{%m} = {%c}{%s}18{%m} + {%c}{%s}19{%m}
         genr {%c}{%s}2024{%m} = {%c}{%s}20{%m} + {%c}{%s}21{%m} + {%c}{%s}22{%m} + {%c}{%s}23{%m} + {%c}{%s}24{%m}
         genr {%c}{%s}2529{%m} = {%c}{%s}25{%m} + {%c}{%s}26{%m} + {%c}{%s}27{%m} + {%c}{%s}28{%m} + {%c}{%s}29{%m}
         genr {%c}{%s}3034{%m} = {%c}{%s}30{%m} + {%c}{%s}31{%m} + {%c}{%s}32{%m} + {%c}{%s}33{%m} + {%c}{%s}34{%m}
         genr {%c}{%s}3539{%m} = {%c}{%s}35{%m} + {%c}{%s}36{%m} + {%c}{%s}37{%m} + {%c}{%s}38{%m} + {%c}{%s}39{%m}
         genr {%c}{%s}4044{%m} = {%c}{%s}40{%m} + {%c}{%s}41{%m} + {%c}{%s}42{%m} + {%c}{%s}43{%m} + {%c}{%s}44{%m}
         genr {%c}{%s}4549{%m} = {%c}{%s}45{%m} + {%c}{%s}46{%m} + {%c}{%s}47{%m} + {%c}{%s}48{%m} + {%c}{%s}49{%m}
         genr {%c}{%s}5054{%m} = {%c}{%s}50{%m} + {%c}{%s}51{%m} + {%c}{%s}52{%m} + {%c}{%s}53{%m} + {%c}{%s}54{%m}
         genr {%c}{%s}5559{%m} = {%c}{%s}55{%m} + {%c}{%s}56{%m} + {%c}{%s}57{%m} + {%c}{%s}58{%m} + {%c}{%s}59{%m}
         genr {%c}{%s}6064{%m} = {%c}{%s}60{%m} + {%c}{%s}61{%m} + {%c}{%s}62{%m} + {%c}{%s}63{%m} + {%c}{%s}64{%m}
         genr {%c}{%s}6569{%m} = {%c}{%s}65{%m} + {%c}{%s}66{%m} + {%c}{%s}67{%m} + {%c}{%s}68{%m} + {%c}{%s}69{%m}
         genr {%c}{%s}7074{%m} = {%c}{%s}70{%m} + {%c}{%s}71{%m} + {%c}{%s}72{%m} + {%c}{%s}73{%m} + {%c}{%s}74{%m}
         genr {%c}{%s}7579{%m} = {%c}{%s}75{%m} + {%c}{%s}76{%m} + {%c}{%s}77{%m} + {%c}{%s}78{%m} + {%c}{%s}79{%m}
                                 
         genr {%c}{%s}1619{%m} = {%c}{%s}1617{%m} + {%c}{%s}1819{%m}
         genr {%c}{%s}75o{%m}  = {%c}{%s}7579{%m} + {%c}{%s}80o{%m}
         genr {%c}{%s}65o{%m}  = {%c}{%s}6569{%m} + {%c}{%s}7074{%m} + {%c}{%s}75o{%m}
         genr {%c}{%s}55o{%m}  = {%c}{%s}5559{%m} + {%c}{%s}6064{%m} + {%c}{%s}65o{%m}
      next
   next
next

%msg = "Done creating 5yr-age-group data, monthly " 
logmsg {%msg}
logmsg

'create rnl.... and pl.... series
wfselect work
pageselect m
smpl {%last_full_yr} {%last_yr}

%age = _
   "16 17 18 19 " + _
   "20 21 22 23 24 25 26 27 28 29 " + _
   "30 31 32 33 34 35 36 37 38 39 " + _
   "40 41 42 43 44 45 46 47 48 49 " + _
   "50 51 52 53 54 55 56 57 58 59 " + _
   "60 61 62 63 64 65 66 67 68 69 " + _
   "70 71 72 73 74 75 76 77 78 79 " + _
   "80 81 82 83 84 85 86 87 88 89 " + _
   "90"
 
'For aggregate groups (no mar status indicator)  
'rln... series   
for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %c r1 d1 o1 d2 r2 i s h o2 dc o3
      n{%s}{%a} = @recode(n{%s}{%a} = 0, 1*10^(-9), n{%s}{%a})
 		genr rnl{%s}{%a}_{%c} = nl{%s}{%a}_{%c} / n{%s}{%a}
 	next
 next
next

'pl... series   
for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	genr pl{%s}{%a} = (e{%s}{%a} + u{%s}{%a}) / n{%s}{%a}
 next
next


' For groups by marital status

' Need to fix the issue that some n{sex}{age}marst = 0, and we can't divide by zero
' Replace zero value by very small positive
for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %m nm ms ma
 		n{%s}{%a}{%m} = @recode(n{%s}{%a}{%m} = 0, 1*10^(-9), n{%s}{%a}{%m}) 		
 	next
 next
next

' rnl... series
for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %c r1 d1 o1 d2 r2 i s h o2 dc o3
 		for %m nm ms ma
 			genr rnl{%s}{%a}{%m}_{%c} = nl{%s}{%a}{%m}_{%c} / n{%s}{%a}{%m}
 		next
 	next
 next
next

' pl... series
for %s m f
 for %a {%age} 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 7579 80o 1619 55o 65o 75o 16o
 	for %m nm ms ma
 		genr pl{%s}{%a}{%m} = (e{%s}{%a}{%m} + u{%s}{%a}{%m}) / n{%s}{%a}{%m}
 	next
 next
next

%msg = "Creating rnl... and pl... series, monthly -- done" 
logmsg {%msg}
logmsg

'save a copy of workfile to do the check separately
wfsave cps_nilf_monthly_for_checking

close cps_nilf_month

%msg = "Saved copy of workfile for checking -- cps_nilf_monthly_for_checking.wf1" 
logmsg {%msg}
logmsg




' Copy data to pages q and a; EViews automatically aggregates them by averaging and keeps the series names
pageselect q
smpl {%last_full_yr}q1 {%last_yr}q{%last_qr}
copy(c=an) m\* *

%msg = "Quarterly data for ALL ages (SYOA and intervals) and all series -- done" 
logmsg {%msg}
logmsg

pageselect a
smpl {%last_full_yr} {%last_full_yr}
copy(c=an) q\* *

%msg = "Annual data for ALL ages (SYOA and intervals) and all series -- done" 
logmsg {%msg}
logmsg

' store data to databank and clear the workfile
wfsave cps_nilf_month


%msg = "Done storing ALL data (monthly, quarterly, and annual) to cps_nilf_month workfile" 
logmsg {%msg}
logmsg

close @wf

' *****
!runtime = @toc
%msg = "Runtime " + @str(!runtime) + " sec" 
logmsg {%msg}

stop


