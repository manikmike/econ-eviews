' This command file generates the Excel worksheets needed to produce the
' short range assumption tables for the 2020 Trustees Report.  These EViews commands
' generate the data series for the 2019 TR, the preliminary 2020 TR, and the FY 2021 Budget
' and the July CBO.  Also entered into the spreadsheet are values for Global
' Insight Baseline Macroeconomic Advisers and Moody's Analytics.

exec .\setup2

logmode logmsg

%output = "table2020.xlsx"
%prior = "19"
%current = "20"
%fiscal = "21"

%q = "gdp12 pch_gdp12 kgdp12 pch_kgdp12 rtp pgdp pch_pgdp " + _
     "cpiw_u pch_cpiw_u cpiw pch_cpiw " + _ 
     "nomintr"


%a = "GDP GDp12 PCH_GDp12 KGDp12 pch_KGDp12 RTP PGDP pch_PGDP WSD CPIW_U " + _
     "pch_CPIW_U BENINC pch_CPIW3 avg_earn pch_avg_earn avg_r_earn PCH_AVG_R_EARN " + _
     "ACWA PCH_ACWA LC pch_LC RU AHRS pch_AHRS prod pch_PROD LC_FEX pch_LC_FEX " + _
     "ru_fex AHRS_FEX pch_AHRS_FEX prod_fex pch_prod_fex"

' **********************************************************************
' ******** PRIOR YEAR'S TRUSTEES REPORT - ALTS I, II, and III **********
' **********************************************************************

for !alt = 1 to 3

   %abank = "atr" + %prior + @str(!alt)
   %range_q = "oldalt" + @str(!alt) + "!a2"
   %range_a = "oldalt" + @str(!alt) + "!a60"

   dbopen(type=aremos) {%abank}.bnk

   pageselect q
   smpl 2017 2029

   copy(c=a) {%abank}::nomintr.m q\nomintr ' this will convert to quarterly using average
   fetch gdp12 kgdp12 cpiw_u pgdp cpiw rtp


   genr pch_gdp12  = @pc(gdp12)
   genr pch_kgdp12 = @pc(kgdp12)
   genr pch_cpiw_u = @pc(cpiw_u)
   genr pch_pgdp   = @pc(pgdp)
   genr pch_cpiw   = @pca(cpiw)

   pagesave(type=excelxml, mode=update) {%output} range=%range_q @keep {%q} @smpl 2018 2029

   delete *

   pageselect a
   smpl 2017 2029

   fetch gdp12 kgdp12 cpiw_u pgdp rtp cpiwdec3_u gdp wsd ahrs lc prod ahrs_fex lc_fex prod_fex beninc acwa ru ru_fex

   genr pch_gdp12  = @pc(gdp12)
   genr pch_kgdp12   = @pc(kgdp12)
   genr pch_pgdp   = @pc(pgdp)

   genr pch_cpiw_u  = @pc(cpiw_u)
   genr pch_cpiw3  = @pc(cpiwdec3_u)

   genr avg_earn    = (wsd + ::yf + ::ynf) / (::e + ::edmil)
   genr pch_avg_earn = @pc(avg_earn)
   genr avg_r_earn    = (wsd + ::yf + ::ynf) /(::e + ::edmil) / cpiw_u
   genr pch_avg_r_earn = @pc(avg_r_earn)
   genr pch_acwa   = @pc(acwa)

   genr pch_lc     = @pc(lc)
   genr pch_ahrs   = @pc(ahrs)
   genr pch_prod   = @pc(prod)

   genr pch_lc_fex  = @pc(lc_fex)
   genr pch_ahrs_fex   = @pc(ahrs_fex)
   genr pch_prod_fex = @pc(prod_fex)

   pagesave(type=excelxml, mode=update) {%output} range=%range_a @keep {%a} @smpl 2017 2029

   delete *

   close @db

   logmsg Finished TR 20{%prior} Alt {!alt}

next

' **********************************************************************
' **************************** FY BUDGET *******************************
' **********************************************************************

%abank = "aomb" + %fiscal
%range_q = "budget!a2"
%range_a = "budget!a60"

dbopen(type=aremos) {%abank}.bnk

pageselect q
smpl 2017 2030

copy(c=a) {%abank}::nomintr.m q\nomintr ' this will convert to quarterly using average
fetch gdp12 kgdp12 cpiw_u pgdp rtp


genr pch_gdp12  = @pc(gdp12)
genr pch_kgdp12 = @pc(kgdp12)
genr pch_cpiw_u = @pc(cpiw_u)
genr pch_pgdp   = @pc(pgdp)

pagesave(type=excelxml, mode=update) {%output} range=%range_q @keep {%qb} @smpl 2018 2030

delete *

pageselect a
smpl 2017 2030

fetch gdp12 kgdp12 cpiw_u pgdp rtp cpiwdec3_u gdp wsd ahrs lc prod ahrs_fex lc_fex prod_fex beninc acwa ru ru_fex

genr pch_gdp12  = @pc(gdp12)
genr pch_kgdp12   = @pc(kgdp12)
genr pch_pgdp   = @pc(pgdp)

genr pch_cpiw_u  = @pc(cpiw_u)
genr pch_cpiw3  = @pc(cpiwdec3_u)

genr avg_earn    = (wsd + ::yf + ::ynf) / (::e + ::edmil)
genr pch_avg_earn = @pc(avg_earn)
genr avg_r_earn    = (wsd + ::yf + ::ynf) /(::e + ::edmil) / cpiw_u
genr pch_avg_r_earn = @pc(avg_r_earn)
genr pch_acwa   = @pc(acwa)

genr pch_lc     = @pc(lc)
genr pch_ahrs   = @pc(ahrs)
genr prod = gdp12 / (::e + ::edmil)
genr pch_prod   = @pc(prod)
genr pch_lc_fex  = @pc(lc_fex)
genr pch_ahrs_fex   = @pc(ahrs_fex)
genr prod_fex = kgdp12 / (::e_fe + ::edmil)
genr pch_prod_fex = @pc(prod_fex)

pch_prod.fill(o="2015") na
pch_prod_fex.fill(o="2015") na

pagesave(type=excelxml, mode=update) {%output} range=%range_a @keep {%a} @smpl 2017 2030

delete *

close @db

logmsg Finished Budget

' **********************************************************************
' ******** CURRENT YEAR'S TRUSTEES REPORT - ALTS I, II, and III ********
' **********************************************************************

'for !alt = 1 to 3
for !alt = 2 to 2

   %abank = "atr" + %current + @str(!alt)
   %range_q = "newalt" + @str(!alt) + "!a2"
   %range_a = "newalt" + @str(!alt) + "!a60"

   dbopen(type=aremos) {%abank}.bnk

   pageselect q
   smpl 2017 2029

   copy(c=a) {%abank}::nomintr.m q\nomintr ' this will convert to quarterly using average
   fetch gdp12 kgdp12 cpiw_u pgdp cpiw rtp


   genr pch_gdp12  = @pc(gdp12)
   genr pch_kgdp12 = @pc(kgdp12)
   genr pch_cpiw_u = @pc(cpiw_u)
   genr pch_pgdp   = @pc(pgdp)
   genr pch_cpiw   = @pca(cpiw)

   pagesave(type=excelxml, mode=update) {%output} range=%range_q @keep {%q} @smpl 2018 2029

   delete *

   pageselect a
   smpl 2017 2029

   fetch gdp12 kgdp12 cpiw_u pgdp rtp cpiwdec3_u gdp wsd ahrs lc prod ahrs_fex lc_fex prod_fex beninc acwa ru ru_fex

   genr pch_gdp12  = @pc(gdp12)
   genr pch_kgdp12   = @pc(kgdp12)
   genr pch_pgdp   = @pc(pgdp)

   genr pch_cpiw_u  = @pc(cpiw_u)
   genr pch_cpiw3  = @pc(cpiwdec3_u)

   genr avg_earn    = (wsd + ::yf + ::ynf) / (::e + ::edmil)
   genr pch_avg_earn = @pc(avg_earn)
   genr avg_r_earn    = (wsd + ::yf + ::ynf) /(::e + ::edmil) / cpiw_u
   genr pch_avg_r_earn = @pc(avg_r_earn)
   genr pch_acwa   = @pc(acwa)

   genr pch_lc     = @pc(lc)
   genr pch_ahrs   = @pc(ahrs)
   genr pch_prod   = @pc(prod)

   genr pch_lc_fex  = @pc(lc_fex)
   genr pch_ahrs_fex   = @pc(ahrs_fex)
   genr pch_prod_fex = @pc(prod_fex)

   pagesave(type=excelxml, mode=update) {%output} range=%range_a @keep {%a} @smpl 2017 2029

   delete *

   close @db

   logmsg Finished TR 20{%current} Alt {!alt}

next

logmsg Finished


logmsg ************************************************************
logmsg ************************************************************
logmsg ******* Remember to get the BENINC series from WIACEB ******
logmsg ************************************************************
logmsg ************************************************************


