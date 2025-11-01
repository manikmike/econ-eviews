'Check the Excel file with the ratio of HI to OASDI covered, sent annually to TFO team

'Specify TR year and path for the A file
%ty = "tr25"
%apath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\"
%aname = "a" + %ty + "2"
%abank = %apath + %aname + ".wf1"
%ckfile = "check_hi_to_oasdi_"+%ty

wfcreate(wf={%ckfile}, page={%ckfile}) a 2000 2100

%ages = "2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o"

wfopen {%abank}

for %s m f
  for %a {%ages}
    copy {%aname}::a\he_m_{%s}{%a} {%ckfile}::{%ckfile}\*
    copy {%aname}::a\ce_m_{%s}{%a} {%ckfile}::{%ckfile}\*
    copy {%aname}::a\ce{%s}{%a} {%ckfile}::{%ckfile}\*
  next
next

wfclose {%aname}

wfselect {%ckfile}
for %s m f
  for %a {%ages}
    series q{%s}{%a} = (he_m_{%s}{%a} + ce{%s}{%a} - ce_m_{%s}{%a}) / ce{%s}{%a}
  next
next

group ckf QF2024 QF2529 QF3034 QF3539 QF4044 QF4549 QF5054 QF5559 QF6064 QF6569 QF70O
group ckm QM2024 QM2529 QM3034 QM3539 QM4044 QM4549 QM5054 QM5559 QM6064 QM6569 QM70O


wfsave {%ckfile}


