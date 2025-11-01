'Work experience aww_check
'This program gets work experience data for all age groups from BKDO1 bank and groups the series in the way that makes it easy to check the values agaist the raw BLS data

'12-01-2017 Polina Vlasenko

'Once the program runs, use the spreadsheet view of groups (8 groups named wem, em, nm, awwm, wef, ef, nf, awwf) to easily copy the required data into the Excel check file aww_check.xlsx.


'enter databank name and path
%bank="E:\usr\econ\EcoDev\dat\bkdo1.bnk"

'enter year(s) of data to be displayed; if need only one year, enter it for BOTH !yr1 ans !yr2
!yr1=2017
!yr2=2018


'enter location to save this workfile to
%result="\\s1f906b\econ\TrusteesReports\TR2021\Checks\BKDO1.bnk-WorkExperience&AverageWeeksWorked\aww_check.wf1"

wfcreate(aww_check) a !yr1 !yr2
dbopen(type=aremos) {%bank}

fetch wem1617_3.a  wem16o_3.a  wem1819_3.a  wem2024_3.a  wem2529_3.a  wem2534_3.a  wem3034_3.a  wem3539_3.a  wem3544_3.a  wem4044_3.a  wem4549_3.a  wem4554_3.a  wem5054_3.a  wem5559_3.a  wem6061_3.a  wem6064_3.a  wem6264_3.a  wem6569_3.a  wem65o_3.a  wem70o_3.a
group wem wem16o_3 wem1617_3 wem1819_3 wem2024_3 wem2534_3 wem3544_3 wem4554_3 wem5559_3 wem6064_3 wem6061_3 wem6264_3 wem65o_3 wem6569_3 wem70o_3 

fetch em16o.a  em1617.a  em1819.a  em2024.a  em2534.a  em3544.a  em4554.a  em5559.a  em6064.a  em65o.a  em6569.a  em70o.a
group em  em16o  em1617  em1819  em2024  em2534  em3544  em4554  em5559  em6064  em65o  em6569  em70o 

fetch  nm16o.a nm1617.a nm1819.a nm2024.a nm2534.a nm3544.a nm4554.a nm5559.a nm6064.a  nm6061.a nm6264.a nm65o.a nm6569.a nm70o.a 
group  nm   nm16o   nm1617   nm1819   nm2024   nm2534   nm3544   nm4554   nm5559   nm6064  nm6061 nm6264 nm65o   nm6569   nm70o 

fetch  awwm16o.a awwm1617.a awwm1819.a awwm2024.a awwm2534.a awwm3544.a awwm4554.a awwm5559.a awwm6064.a awwm65o.a awwm6569.a awwm70o.a 
group  awwm awwm16o awwm1617 awwm1819 awwm2024 awwm2534 awwm3544 awwm4554 awwm5559 awwm6064 awwm65o awwm6569 awwm70o 

fetch wef16o_3.a wef1617_3.a wef1819_3.a wef2024_3.a wef2534_3.a wef3544_3.a wef4554_3.a wef5559_3.a wef6064_3.a wef6061_3.a wef6264_3.a wef65o_3.a wef6569_3.a wef70o_3.a 
group wef wef16o_3 wef1617_3 wef1819_3 wef2024_3 wef2534_3 wef3544_3 wef4554_3 wef5559_3 wef6064_3 wef6061_3 wef6264_3 wef65o_3 wef6569_3 wef70o_3 

fetch ef16o.a ef1617.a ef1819.a ef2024.a ef2534.a ef3544.a ef4554.a ef5559.a ef6064.a ef65o.a ef6569.a ef70o.a 
group ef  ef16o  ef1617  ef1819  ef2024  ef2534  ef3544  ef4554  ef5559  ef6064  ef65o  ef6569  ef70o 

fetch nf16o.a nf1617.a nf1819.a nf2024.a nf2534.a nf3544.a nf4554.a nf5559.a nf6064.a nf6061.a nf6264.a nf65o.a nf6569.a nf70o.a 
group  nf   nf16o   nf1617   nf1819   nf2024   nf2534   nf3544   nf4554   nf5559   nf6064  nf6061 nf6264 nf65o   nf6569   nf70o 

fetch awwf16o.a awwf1617.a awwf1819.a awwf2024.a awwf2534.a awwf3544.a awwf4554.a awwf5559.a awwf6064.a awwf65o.a awwf6569.a awwf70o.a
group  awwf awwf16o awwf1617 awwf1819 awwf2024 awwf2534 awwf3544 awwf4554 awwf5559 awwf6064 awwf65o awwf6569 awwf70o 

close @db

'show all groups
wem.sheet(t)
em.sheet(t)
nm.sheet(t)
awwm.sheet(t)
wef.sheet(t)
ef.sheet(t)
nf.sheet(t)
awwf.sheet(t)

wfsave {%result}
'wfclose


