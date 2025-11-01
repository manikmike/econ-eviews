
exec .\setup2

wfopen \\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Data\Processed\TR25_ProgramsData\MEF_TR25.wf1

%file = "MEF_TR25"  	' filename only

pageselect MEF_finals

' create group containing all series except "resid"
group g * not resid

' create string variable containing names of all series in group "g"
%store = g.@members

for %s {%store}
   copy {%file}::MEF_finals\{%s} work::a\{%s}
next

wfclose {%file}

wfselect work
wfsave(2) mef
wfclose mef


