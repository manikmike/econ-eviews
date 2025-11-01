' This program produces Excel tables for the Trustees Report Long-Range Assumptions Memos
' NOTE: For the 2021 TR and later, the unadjusted portion of this program is no longer run

' Required input : atr242.wf1,  atr241.wf1, atr243.wf1,
'                  bkdr1.wf1,   bkdo1.wf1,  compdata.wf1

' Trustees Report Year
!TRYEAR = 2025

' Do you want an adjusted CPI-W run for the compound tables? 1 for yes, 0 for no.
!adjrun = 1

!yr1 = 1951
!yr2 = !TRYEAR - 2
%yrend = @str(!TRYEAR - 2)
!lryrend = !TRYEAR + 74
%abank = "atr" + @str(!TRYEAR - 2000 - 1) + "2" ' Output ABANK from previous TR (e.g, atr202)

exec .\setup2
pageselect a
smpl {!yr1} {!yr2}

'cd "C:\Users\886079\GitRepos\econ-eviews"
exec .\cmpddata {!TRYEAR}
pageselect a
smpl {!yr1} {!yr2}

'dbopen(type=aremos) compdata.bnk
wfopen compdata.wf1
wfselect work
pageselect a

if (!adjrun = 1) then
  series cpiw = cpiwadj * 100
  series cpiw_u_spreadsheet = cpiwunadj * 100
  series pgdp = pgdpadj * 100
  series rgdp17 = gdp17adj
  series emp = eadj
else
  series cpiw = cpiw_u * 100
  series pgdp = pgdp * 100
  series rgdp17 = gdp17
  series emp = e
endif

series yy = ynf + yf
series pgdpacpi = pgdp / cpiw * 100
series cove = wsca + cse_tot
series ace = cove / tcea * 1000
series arce = ace / cpiw * 100
series ahwus = tothrs / (emp + edmil) /52 * 1000
series lpus = rgdp17 / tothrs
series produs = lpus / @elem(lpus,"2017") * 100
series tote = wsd + yy
series aneus = tote/ (emp + edmil) * 1000
series areus = aneus * 100 / cpiw
series totc = wss + yy
series totcgdp = totc / gdp * 100
series totetotc = tote / totc * 100
series covetote = cove / tote
series temptcea = (emp + edmil) / tcea


' Total Productivity - Unadjusted:
series lpus_unadj = gdp17 / tothrs
series produs_unadj = lpus_unadj / @elem(lpus_unadj,"2017") * 100


' wfopen ssaprogdata
'dbopen(type=aremos) {%abank}.bnk
wfopen {%abank}.wf1
wfselect work
pageselect m
' copy ssaprogdata::m\nomint work::m\ninint
'series ninint = {%abank}::nomintr
'copy {%abank}::m\nomint work::m\ninint
copy {%abank}::m\nomintr work::m\ninint

' close ssaprogdata
close {%abank}
copy m\ninint a\ninint

pageselect a
smpl {!yr1} {!yr2}
series gace = @pc(ace)
series gcpiw = @pc(cpiw)
series gcpiw_u_spreadsheet = @pc(cpiw_u_spreadsheet)
series red = gace - gcpiw
series red_cpiw_u_spreadsheet = gace - gcpiw_u_spreadsheet


pageselect a
smpl 1937 {!yr2}
copy m\ninint a\nomint
smpl 1937 1950
if (!adjrun = 1) then
   series cpiw = cpiwadj * 100
	series cpiw_u_spreadsheet = cpiwunadj * 100
else
   series cpiw = cpiw_u * 100
endif

smpl 1937 1937
series ryield = 100 / cpiw_u_spreadsheet
smpl 1938 {!yr2}
series ryield = ryield(-1) * cpiw_u_spreadsheet(-1) * (nomint(-1) / 200 + 1)^2 / cpiw_u_spreadsheet
smpl 1937 {!yr2}
series ryindex = ryield / @elem(ryield,%yrend) * 100
series apr = ((nomint / 200 + 1)^2 - 1) * 100
series apccpiw = (cpiw_u_spreadsheet(1) / cpiw_u_spreadsheet - 1) * 100
series rapr = ((apr / 100 + 1) / (apccpiw / 100 + 1) - 1) * 100

exec .\unemp_memo {!TRYEAR}
pageselect a
smpl {!yr1} {!yr2}

series prodnf

%econvar = _
   "cpiw " + _
   "pgdp " + _
   "produs " + _
   "produs_unadj " + _ 
   "ahwus " + _
   "prodnf " + _
   "pgdpacpi " + _
   "areus " + _
   "totcgdp " + _
   "totetotc " + _
   "arce " + _
   "rttotl " + _ 
   "rtagea " + _ 
   "temptcea " + _ 
   "covetote " + _
	"cpiw_u_spreadsheet"

%tablep = "cpiw ryindex apr apccpiw rapr nomint cpiw_u_spreadsheet"


' Update linkages

if (!adjrun = 1) then

   smpl 1951 {!yr2}
   alpha year = @datestr(@date, "YYYY")
   %smplstr = "1951 " + @str(!yr2)
   wfsave(2,type=excelxml,mode=update,noid) cmpdtblsadj.xlsx range="cmpd1_51!a5" na="" @smpl %smplstr @keep year {%econvar}
   delete year

   pageselect a
   smpl {!yr2} {!lryrend}
   alpha year = @datestr(@date, "YYYY")
   %smplstr = @str(!yr2) + " " + @str(!lryrend)
   %listalt = "prod prod_fex totcgdp totetotc ahwus wedge areus temptcea covetote arce defl cpi"
   
   for !alt = 1 to 3
      %rangestr = "alt" + @str(!alt) + "!a5"
      %abank = "atr" + @str(!TRYEAR-2000-1) + @str(!alt)
      'dbopen(type=aremos) {%abank}.bnk
		wfopen {%abank}.wf1
		wfselect work
		pageselect a
      'series prod = ::prod
		copy {%abank}::a\prod work::a\prod
      'series prod_fex = ::prod_fex
		copy {%abank}::a\prod_fex work::a\prod_fex
      'series totcgdp = (::wss + ::yf + ::ynf) / ::gdp
		wfselect {%abank}
		pageselect a
		series totcgdp = (wss + yf + ynf) / gdp
		copy {%abank}::a\totcgdp work::a\totcgdp
      'series totetotc = (::wsd + ::yf + ::ynf)/(::wss + ::yf + ::ynf) * 100
		series totetotc = (wsd + yf + ynf)/(wss + yf + ynf) * 100
		copy {%abank}::a\totetotc work::a\totetotc
      'series ahwus = (::hrs / (::e + ::edmil) / 52) * 1000
		series ahwus = (hrs / (e + edmil) / 52) *1000
		copy {%abank}::a\ahwus work::a\ahwus
      'series wedge = ::pgdp / ::cpiw_u * 100
		series wedge = pgdp / cpiw_u * 100
		copy {%abank}::a\wedge work::a\wedge
      'series areus = (((::wsd + ::yf + ::ynf) / (::e + ::edmil) * 1000) * 100) / ::cpiw_u
		series areus = (((wsd + yf + ynf) / (e + edmil) * 1000) *100) / cpiw_u
		copy {%abank}::a\areus work::a\areus
      'series temptcea = (::e + ::edmil) / ::tcea
		series temptcea = (e + edmil) / tcea
		copy {%abank}::a\temptcea work::a\temptcea
      'series covetote = (::wsca + ::cse_tot) / (::wsd + ::yf + ::ynf)
		series covetote = (wsca + cse_tot) / (wsd + yf + ynf)
		copy {%abank}::a\covetote work::a\covetote
      'series arce = ((::wsca + ::cse_tot) / ::tcea * 1000) / ::cpiw_u * 100
		series arce = ((wsca + cse_tot) / tcea * 1000) / cpiw_u * 100
		copy {%abank}::a\arce work::a\arce
      'series defl = ::pgdp
		copy {%abank}::a\pgdp work::a\defl
      'series cpi = ::cpiw_u
		copy {%abank}::a\cpiw_u work::a\cpi
		wfselect work
		pageselect a
      wfsave(2,type=excelxml,mode=update,noid) cmpdtblsadj.xlsx range=%rangestr na="" @smpl %smplstr @keep year {%listalt}   
      close {%abank}
   next
   delete year
   
   smpl 1937 {!yr2}
   alpha year = @datestr(@date, "YYYY")
   %smplstr = "1937 " + @str(!yr2)
   wfsave(2,type=excelxml,mode=update,noid) compoundtbls.xlsx range="data2_51!a5" @smpl %smplstr @keep year {%tablep}   
   delete year

else ' no adjustment

'   smpl 1951 {!yr2}
'   alpha year = @datestr(@date, "YYYY")
'   %smplstr = "1951 " + @str(!yr2)
'   wfsave(2,type=excelxml,mode=update,noid) compoundtbls.xlsx range="cmpd1_51!a5" na="" @smpl %smplstr @keep year {%econvar}
'   delete year

'   pageselect a
'   smpl {!yr2} {!lryrend}
'   alpha year = @datestr(@date, "YYYY")
'   %smplstr = @str(!yr2) + " " + @str(!lryrend)
'   %listalt = "prod prod_fex totcgdp totetotc ahwus wedge areus temptcea covetote arce defl cpi"
   
'   for !alt = 1 to 3
'      %rangestr = "alt" + @str(!alt) + "!a5"
'      %abank = "atr" + @str(!TRYEAR-2000-1) + @str(!alt)
'      dbopen(type=aremos) {%abank}.bnk
'      series prod = ::prod
'      series prod_fex = ::prod_fex
'      series totcgdp = (::wss + ::yf + ::ynf) / ::gdp
'      series totetotc = (::wsd + ::yf + ::ynf)/(::wss + ::yf + ::ynf) * 100
'      series ahwus = (::hrs / (::e + ::edmil) / 52) * 1000
'      series wedge = ::pgdp / ::cpiw_u * 100
'      series areus = (((::wsd + ::yf + ::ynf) / (::e + ::edmil) * 1000) * 100) / ::cpiw_u
'      series temptcea = (::e + ::edmil) / ::tcea
'      series covetote = (::wsca + ::cse_tot) / (::wsd + ::yf + ::ynf)
'      series arce = ((::wsca + ::cse_tot) / ::tcea * 1000) / ::cpiw_u * 100
'      series defl = ::pgdp
'      series cpi = ::cpiw_u
'      wfsave(2,type=excelxml,mode=update,noid) compoundtbls.xlsx range=%rangestr na="" @smpl %smplstr @keep year {%listalt}   
'      close {%abank}
'   next
'   delete year
   
'   smpl 1937 {!yr2}
'   alpha year = @datestr(@date, "YYYY")
'   %smplstr = "1937 " + @str(!yr2)
'   wfsave(2,type=excelxml,mode=update,noid) compoundtbls.xlsx range="data2_51!a5" @smpl %smplstr @keep year {%tablep}   
'   delete year

endif

'close compdata


