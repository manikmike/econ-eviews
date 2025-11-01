' This program generates an output file for the purpose of
' checking the dfile against its source workfiles

%user = @env("username")
%path1 = "C:\Users\" + %user + "\GitRepos\econ-ecodev\dat"
%path2 = "S:\LRECON\ModelRuns\TR2024\2024-0215-0725-TR242\out\mul"

exec {%path1}\setup2

pageselect q
smpl 2009 2023Q3 ' through last quarter of data

pageselect a
smpl 2009 2022 ' through last full year of data

' Name of output file
%output = "output_from_ck_dfile.txt"

' Store contents of output file as a text object
Text t

for %file esf mef cpso_nilf cpso68123 bkdo1 bkdr1 cnipopdata
   wfopen {%path1}\{%file}.wf1
   wfselect work
   shell(out=fileinfo) dir {%path1}\{%file}.wf1 | findstr {%file}.wf1
   %s = fileinfo(1,1)
   t.append {%s}
   delete fileinfo
next
for %file atr242 dtr242
   wfopen {%path2}\{%file}.wf1
   wfselect work
   shell(out=fileinfo) dir {%path2}\{%file}.wf1 | findstr {%file}.wf1
   %s = fileinfo(1,1)
   t.append {%s}
   delete fileinfo
next
t.append .

t.append .
t.append MODEX 1
t.append .
call print_check("cpso_nilf", "nm2529ms")
call print_check("cnipopdata", "nf74")
call print_check("bkdo1", "nm4044")
call print_check("cpso68123", "nf2024mac6u")
call print_check("cpso68123", "if2024mac6u")


t.append .
t.append MODEX 2
t.append .
pageselect q
copy a\t q\t
call print_check("bkdr1", "qtr")
pageselect a
copy q\t a\t
call print_check("bkdr1", "etest65o")
call print_check("bkdr1", "retest65o")


t.append .
t.append MODEX 3
t.append .
call print_check("bkdo1", "minw")
pageselect q
copy a\t q\t
smpl 2009 2023Q2
call print_check("bkdo1", "minw")
smpl 2009 2023Q3

t.append .
t.append MODEX 4
t.append .
pageselect a
copy q\t a\t
call print_check("bkdo1", "wspes")
call print_check("bkdo1", "wspss")
call print_check("bkdo1", "wsphs")
call print_check("bkdr1", "emptroasi")
call print_check("bkdr1", "setroasi")
smpl 2009 2021
call print_check("bkdo1", "cpb")
smpl 2009 2022
call print_check("bkdr1", "eprrb")


t.append .
t.append MODEX 5
t.append .
smpl 2009 2016
genr brr62x = (48*.005556)- ((48-36)*.005556) + ((48-36)*.004167)
smpl 2017 2017
brr62x = (50*.005556)- ((50-36)*.005556) + ((50-36)*.004167)
smpl 2018 2018
brr62x = (52*.005556)- ((52-36)*.005556) + ((52-36)*.004167)
smpl 2019 2019
brr62x = (54*.005556)- ((54-36)*.005556) + ((54-36)*.004167)
smpl 2020 2020
brr62x = (56*.005556)- ((56-36)*.005556) + ((56-36)*.004167)
smpl 2021 2021
brr62x = (58*.005556)- ((58-36)*.005556) + ((58-36)*.004167)
smpl 2022 2022
brr62x = (60*.005556)- ((60-36)*.005556) + ((60-36)*.004167)
smpl 2009 2022
call print_check("work", "brr62x")


t.append .
t.append MODEN 1
t.append .
pageselect q
copy a\t q\t
call print_check("bkdo1", "cpiw_u")
call print_check("bkdo1", "rm2534")
call print_check("bkdo1", "wssph")
call print_check("bkdo1", "wsspni")
pageselect a
copy q\t a\t
call print_check("bkdo1", "yf")
call print_check("bkdo1", "ynf")
call print_check("bkdo1", "gdp")
smpl 2009 2021
call print_check("esf", "te_sfm_lrp")


t.append .
t.append MODEN 2
t.append .
call print_check("bkdo1", "oli_retsl")
call print_check("bkdo1", "socf_wc")
call print_check("bkdo1", "oli_retfc")
smpl 2009 2022
call print_check("bkdr1", "taxmax")
smpl 2009 2021


t.append .
t.append MODEN 3
t.append .
call print_check("atr242", "pf3034")


t.append .
t.append MODIN 1
t.append .
smpl 2009 2021
call print_check("mef", "ce_m_f1")
call print_check("mef", "te_ph_m_m23")


t.append .
t.append FINISHED
t.append .

t.save(t=txt) {%output}
close @wf


subroutine print_check(string %f, string %s)

   %v = @pagename
   if (%f <> "work") then
      copy {%path1}\{%f}.wf1::{%v}\{%s} {%f}_{%s}
   else
      rename {%s} work_{%s}
   endif
   copy {%path2}\dtr242.wf1::{%v}\{%s} dtr242_{%s}
   series diff =  {%f}_{%s} - dtr242_{%s}
   group g {%f}_{%s} dtr242_{%s} diff
   freeze(table1) g.sheet
   table1.setwidth(2:3) 25
   table1.setformat(D) f.6
   table1.save(t=txt) temp
   t.append(file) temp.txt
   delete g {%f}_{%s} dtr242_{%s} table1
   shell del temp.txt
   t.append .

endsub

