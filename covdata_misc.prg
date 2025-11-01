
' When covdata.bnk was eliminated (TR 2016), some series needed a new home. 
' This program:
' - was originally written in Aremos by Drew Sawyer in 2015.
' - creates series and stores them in bkdo1.wf1.
' - was converted from Aremos to EViews by Drew Sawyer in 2017.


exec .\setup2


' user inputs ************************************************************ 

!TRYEAR = 2025

' The MEF workfile ends in (!TRYEAR - 3) {%trm3}, while the EstFinTaxEarn file has data for an additional year {%trm3}+1
%trm3 = @str(!TRYEAR - 3)
' TR year - 3

%wfpage = "20241031_r"

' main ************************************************************ 

pageselect a



' intermediate series (not stored) ************************************************************

series taxrat

smpl 2000 2010
taxrat.fill(s) _
.975617564280470, _
.978533807254320, .971964710577035, .982050588826085, .979617038677644, .978228411029592, .978, .978104142739585, .978436101802595, .981180789731654, .979671101114111
' COV141125.xls
' sheet: COV141125

smpl 2011 %trm3+1
taxrat.fill(s,l) .98
' COV141125.xls
' sheet: COV141125


' series created from hardcoding (and unit changes) only ************************************************************

series cprr

smpl 1971 %trm3
cprr.fill(s,l) 0
' COV141125.xls
' sheet: COV141125

series ctip

smpl 1971 %trm3
ctip.fill(s,l) 1
' COV141125.xls
' sheet: COV141125

series te

smpl 1971 %trm3
te.fill(s,l) 0
' Pat/Bob: no longer used, so set to 0

series teph_n

smpl 1971 %trm3
teph_n.fill(s,l) 0
' Pat/Bob: no longer used, so set to 0

series tepo_n

smpl 1971 %trm3
tepo_n.fill(s,l) 0
' Pat/Bob: no longer used, so set to 0

series tips_sr

smpl 1978 1999
tips_sr.fill(s) _
.102, .000, .003, _
.003, .002, .001, .011, .016, .024, .063, .087, .135, .389, _
.034, .108, .038, .494, .065, .427, .390, .361, .422 _
' COV141125.xls
' sheet: COV141125

' Estimates of OASDI Taxable Earnings, Tips, Self-reported
smpl 2000 {%trm3}+1
copy EstFinTaxEarn.wf1::{%wfpage}\tips_sr work::a\tips_sr

series wscahi

smpl 1971 1999
wscahi.fill(s) _
509, 563.3, 624.4, 681.6, 717.2, 797.2, 879.5, 1024.4, 1147.9, 1235.6, _
1361.2, 1430.3, 1568.143012, 1733.628612, 1869.416531, 1997.557409, 2141.727717, 2314.861943, 2448.127407, 2600.321459, _
2661.012196, 2812.77045, 2913.642366, 3082.623752, 3277.585346, 3465.272112, 3733.255251, 4038.534124, 4314.293350
' TR 2019 HI and OASDI Covered Wages 11052018.xlsx
' sheet: OASDI and HI Wages
' column: Covered Wages > HI > wscahi

' Estimates of HI Taxable Earnings, Wages + tips
smpl 2000 {%trm3}+1
copy EstFinTaxEarn.wf1::{%wfpage}\wscahi work::a\wscahi

series wsgmlc

smpl 1971 1999
wsgmlc.fill(s) _
15.223, 16.350, 16.454, 16.554, 16.713, 16.773, 17.613, 19.729, 20.726, 22.778, _
26.393, 29.546, 31.223, 33.348, 33.232, 34.343, 37.800, 38.000, 39.600, 40.800, _
42.900, 41.400, 39.700, 38.720, 37.640, 37.440, 37.370, 37.440, 38.030
' COV141125.xls
' sheet: COV141125

' Estimates of HI Taxable Earnings, Military
smpl 2000 {%trm3}+1
copy EstFinTaxEarn.wf1::{%wfpage}\wsgmlc work::a\wsgmlc

series wsph_o

smpl 1971 1999
wsph_o.fill(s) _
1.233, 1.260, 1.288, 1.233, 1.260, 1.452, 1.589, 1.754, 1.726, 1.644, _
1.644, 1.671, 1.699, 1.945, 1.970, 2.260, 2.390, 2.570, 2.770, 2.940, _
3.140, 3.340, 3.730, 4.082, 4.564, 3.350, 3.402, 3.651, 3.731
' COV141125.xls
' sheet: COV141125

' Estimates of HI Taxable Earnings, Private Household (NOTE: HI taxable equals OASDI covered here)
smpl 2000 {%trm3}+1
copy EstFinTaxEarn.wf1::{%wfpage}\wsph_o work::a\wsph_o

series wsprr_o

smpl 1971 %trm3
wsprr_o.fill(s,l) 0
' COV141125.xls
' sheet: COV141125

series wswa_sf

smpl 1979 %trm3
wswa_sf.fill(s,l) 0
' COV141125.xls
' sheet: COV141125


' series created from hardcoding and workfiles only ************************************************************

shell attrib -r bkdo1.wf1

wfopen mef.wf1
wfopen esf.wf1
wfopen bkdo1.wf1
wfopen bkdr1.wf1

wfselect work
pageselect a

series acfcw

smpl 1971 1982
acfcw.fill(s) _
2.19967296296811, 2.37337501437608, 2.53385851844296, 2.68484453041702, 2.89563455875799, 3.12635214360228, 3.35371897296766, 3.61972877470952, 3.84200000000000, 4.06063673270390, _
4.53493492518813, 4.80076273360505
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
acfcw = mef.wf1::a\wefc_o / mef.wf1::a\tefc_o

series acslw

smpl 1971 1982
acslw.fill(s) _
5.59804231859259, 5.89246881565081, 6.27114920637428, 6.62063675007482, 7.09649673941077, 7.55923972788182, 7.99105557925686, 8.35359534143745, 8.91859745534442, 9.70392560926193, _
10.57997239105400, 11.51886299887490
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
acslw = mef.wf1::a\wesl_o / mef.wf1::a\tesl_o

smpl 1971 %trm3
genr ase = mef.wf1::a\cse / mef.wf1::a\csw

series cfca

smpl 1971 1982
cfca.fill(s) _
0.0589037537342512, 0.0591898428053204, 0.0620915965187616, 0.0659751474304970, 0.0678831586844462, 0.0698896834886187, 0.0718889544190749, 0.0744118781334362, 0.0820285537835580, 0.0864136112631212, _
0.0823335721581122, 0.0832299948938653
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
cfca = mef.wf1::a\wefc_o / bkdo1.wf1::a\wsggefc

series csla

smpl 1971 1982
csla.fill(s) _
0.694310844205883, 0.709960890348124, 0.689609638449030, 0.704928521443567, 0.716578879121469, 0.718848573929415, 0.715967555749222, 0.712638272783424, 0.710705122419773, 0.717283078772740, _
0.702125820947114, 0.704059136950048
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
csla = mef.wf1::a\wesl_o / bkdo1.wf1::a\wsggesl

smpl 1971 %trm3
genr wswa = mef.wf1::a\wsw_mef_o + esf.wf1::a\te_sfo_lrp + esf.wf1::a\te_sf_teo


' series created from other work series ************************************************************

series acmw

smpl 1971 1981
acmw.fill(s) _
3.48189262255369, 4.24477256372249, 4.50026154198989, 4.77786754032284, 5.01454838779353, 5.18245501974499, 5.39308767079929, 5.74284598554947, 6.11237809482946, 6.71322391908084, _
7.75528253197245
' COV141125.xls
' sheet: COV141125

smpl 1982 %trm3
acmw = wsgmlc / mef.wf1::a\teml_o

series wsca

smpl 1971 1993
wsca.fill(s) _
509, 563.3, 624.4, 681.6, 717.2, 797.2, 879.5, 1024.4, 1147.9, 1235.6, _
1361.2, 1430.3, 1503.8, 1666.3, 1802.4, 1925.5, 2057.2, 2232.6, 2362.5, 2510.4, _
2566.7, 2709.7, 2808.9
' TR 2019 HI and OASDI Covered Wages 11052018.xlsx
' sheet: OASDI and HI Wages
' column: Covered Wages > OASDI > wsca

smpl 1994 %trm3
wsca = wscahi - mef.wf1::a\wefc_n - mef.wf1::a\wesl_n_hi

smpl 1971 %trm3
genr acwa = wsca / wswa

smpl 1971 %trm3
genr cml = wsgmlc / bkdo1.wf1::a\wsgfm

smpl 1971 %trm3
genr coverna = wsca + mef.wf1::a\cse

smpl 1971 %trm3
genr cph = wsph_o / bkdo1.wf1::a\wsph

smpl 1971 %trm3
genr tcea = wswa + mef.wf1::a\seo

series wspc

smpl 1971 1982
wspc.fill(s) _
439.705, 486.176, 542.579, 592.026, 617.552, 690.275, 764.819, 899.281, 1012.412, 1084.711, _
1199.406, 1254.849
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
wspc = wsca - mef.wf1::a\wefc_o - mef.wf1::a\wesl_o - wsgmlc

series wspf_o

smpl 1971 1999
wspf_o.fill(s) _
3.416, 3.653, 4.209, 4.900, 5.498, 6.002, 6.402, 7.058, 7.943, 8.874, _
9.621, 9.877, 10.000, 10.358, 10.379, 10.409, 10.962, 11.853, 12.436, 13.122, _
13.400, 13.971, 14.411, 14.970, 15.297, 15.854, 16.875, 17.634, 18.022
' COV141125.xls
' sheet: COV141125

' Estimates of OASDI Taxable Earnings, Farm wages
smpl 2000 {%trm3}+1
copy EstFinTaxEarn.wf1::{%wfpage}\wspf_o work::a\wspf_o
wspf_o = wspf_o / taxrat

series wswahi

smpl 1971 1982
wswahi.fill(s) _
88.3536291371891, 91.1584365469214, 94.6491140650788, 96.1615987341563, 94.9726107881339, 97.4845754873794, 100.6606153801880, 103.8490379970810, 106.3416479896620, 106.9908456796610, _
107.2635659007370, 105.4992960713120
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
wswahi = wswa + mef.wf1::a\tesl_n_n_hi + mef.wf1::a\tefc_n_n + mef.wf1::a\wsw_hio_oth

smpl 1971 %trm3
genr acfmw = wspf_o / bkdo1.wf1::a\eaw

series cp

smpl 1971 1982
cp.fill(s) _
0.960578918623703, 0.970604911159912, 0.968934327425331, 0.967718523967145, 0.967040400876918, 0.971089930714311, 0.966229549617838, 0.998590861140414, 0.996272387325330, 0.975481463162391, _
0.978667537024193, 0.980369929100178
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
cp = wspc / bkdo1.wf1::a\wsdp

smpl 1971 %trm3
genr cpf = wspf_o / bkdo1.wf1::a\wspf

smpl 1971 %trm3
genr tceahi = wswahi + mef.wf1::a\seo_hi

series wspb_o

smpl 1971 1977
wspb_o.fill(s) _
435.056199584200, 481.262750259067, 537.082016326531, 585.893000000000, 610.793674688797, 682.820765412004, 756.827360975610
' COV141125.xls
' sheet: COV141125

smpl 1978 %trm3
wspb_o = wspc - wspf_o - wsph_o - tips_sr

series cpb

smpl 1971 1982
cpb.fill(s) _
0.982653770156932, 0.992050919999149, 0.989755688063620, 0.987344182621254, 0.985453081894124, 0.989981261407714, 0.984373071418588, 1.016539331779760, 1.013358047370240, 0.990379069828922, _
0.991655956685392, 0.992864292012804
' COV141125.xls
' sheet: COV141125

smpl 1983 %trm3
cpb = wspb_o / (bkdo1.wf1::a\wsdp - bkdo1.wf1::a\wsph - bkdr1.wf1::a\wsprrb - bkdo1.wf1::a\wspf)


' store in bkdo1.wf1 ************************************************************

%store_bkdo1 = _
"acfcw " + _
"acfmw " + _
"acmw " + _
"acslw " + _
"acwa " + _
"ase " + _
"cfca " + _
"cml " + _
"coverna " + _
"cp " + _
"cpb " + _
"cpf " + _
"cph " + _
"cprr " + _
"csla " + _
"ctip " + _
"tcea " + _
"tceahi " + _
"te " + _
"teph_n " + _
"tepo_n " + _
"tips_sr " + _
"wsca " + _
"wscahi " + _
"wsgmlc " + _
"wspb_o " + _
"wspc " + _
"wspf_o " + _
"wsph_o " + _
"wsprr_o " + _
"wswa " + _
"wswa_sf " + _
"wswahi"

for %v {%store_bkdo1}

  copy(m) {%v} bkdo1::a\{%v}
  
next

wfselect bkdo1
wfsave(2) bkdo1

close @wf


