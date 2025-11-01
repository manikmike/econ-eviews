'Check otl1 otl2 otl3
'  Extended to 2105 for TR25 checks
' Sven Sinclair 03/03/2025

%otlfile = "S:\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\otl_tr252.wf1"

wfopen {%otlfile}
wfcreate(wf=check_otl_1_2_3) a 1981 2105

%c = "Check1"
pagecreate(page={%c}) a 1981 2105
for %srs teo_no_16o teo_nol_16o teo_noi_16o
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum = teo_nol_16o + teo_noi_16o
genr check=teo_no_16o - (teo_nol_16o + teo_noi_16o)
group  chk teo_no_16o teo_nol_16o teo_noi_16o sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep teo_no_16o teo_nol_16o teo_noi_16o sum check

%c = "Check2"
pagecreate(page={%c}) a 1981 2105
for %srs eo_no_16o eo_nol_16o eo_noi_16o
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr check=eo_no_16o - (eo_nol_16o + eo_noi_16o)
group  chk eo_no_16o eo_nol_16o eo_noi_16o check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep eo_no_16o eo_nol_16o eo_noi_16o check

%c = "Check3"
pagecreate(page={%c}) a 1981 2105
for %srs eo_a eo_aw eo_as 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=eo_as + eo_aw
genr check=eo_a - (eo_as + eo_aw)
group chk eo_a eo_aw eo_as sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep eo_a eo_aw eo_as sum check

%c = "Check4"
pagecreate(page={%c}) a 1981 2105
for %srs eo_a_16o eo_as_16o eo_aw_16o 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=eo_as_16o + eo_aw_16o
genr check=eo_a_16o - (eo_as_16o + eo_aw_16o)
group chk eo_a_16o eo_as_16o eo_aw_16o sum check 
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep eo_a_16o eo_as_16o eo_aw_16o sum check

%c = "Check5"
pagecreate(page={%c}) a 1981 2105
for %srs teo_a_16o teo_as_16o teo_aw_16o 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=teo_as_16o + teo_aw_16o
genr check=teo_a_16o - (teo_as_16o + teo_aw_16o)
group chk teo_a_16o teo_as_16o teo_aw_16o sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep teo_a_16o teo_as_16o teo_aw_16o sum check

%c = "Check6"
pagecreate(page={%c}) a 1981 2105
for %srs eo_nol_16o eo_nol_1_16o eo_nol_2_16o 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=eo_nol_1_16o + eo_nol_2_16o
genr check=eo_nol_16o -(eo_nol_1_16o + eo_nol_2_16o)
group chk eo_nol_16o eo_nol_1_16o eo_nol_2_16o sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep eo_nol_16o eo_nol_1_16o eo_nol_2_16o sum check

%c = "Check7"
pagecreate(page={%c}) a 1981 2105
for %srs eo_noi_16o eo_noi_1_16o eo_noi_2_16o 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=eo_noi_1_16o + eo_noi_2_16o
genr check=eo_noi_16o - (eo_noi_1_16o + eo_noi_2_16o)
group chk eo_noi_16o eo_noi_1_16o eo_noi_2_16o sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep eo_noi_16o eo_noi_1_16o eo_noi_2_16o sum check

%c = "Check8"
pagecreate(page={%c}) a 1981 2105
for %srs WS_EO_NOL WS_EO_NOL_M WS_EO_NOL_S WS_EO_NOL_U 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=WS_EO_NOL_M + WS_EO_NOL_S + WS_EO_NOL_U
genr check=WS_EO_NOL - ( WS_EO_NOL_M + WS_EO_NOL_S + WS_EO_NOL_U) 
group chk WS_EO_NOL WS_EO_NOL_M WS_EO_NOL_S WS_EO_NOL_U sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep WS_EO_NOL WS_EO_NOL_M WS_EO_NOL_S WS_EO_NOL_U sum check

%c = "Check9"
pagecreate(page={%c}) a 1981 2105
for %srs eo_na_16o eo_nas_16o eo_naw_16o 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=eo_nas_16o + eo_naw_16o
genr check=eo_na_16o - (eo_nas_16o + eo_naw_16o)
group chk eo_na_16o eo_nas_16o eo_naw_16o sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep eo_na_16o eo_nas_16o eo_naw_16o sum check

%c = "Check10"
pagecreate(page={%c}) a 1981 2105
for %srs teo_na_16o teo_nas_16o teo_naw_16o 
  copy %otlfile::a\{%srs} check_otl_1_2_3::{%c}\*
next
wfselect check_otl_1_2_3
pageselect {%c}
genr sum=teo_nas_16o + teo_naw_16o
genr check=teo_na_16o - (teo_nas_16o + teo_naw_16o)
group chk teo_na_16o teo_nas_16o teo_naw_16o sum check
%r = %c + "!a1"
save(type=excelxml, mode=update) check_otl_1_2_3.xlsx range=%r @keep teo_na_16o teo_nas_16o teo_naw_16o sum check

wfclose {%otlfile}


