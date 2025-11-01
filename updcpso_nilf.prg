exec .\setup2
wfopen cps_nilf_tcode.wf1

for %f a q m
	'wfselect work
   'pageselect {%f}
   'fetch *.{%f}
	copy cps_nilf_tcode::{%f}\* work::{%f}\*
next

close cps_nilf_tcode

' Copy last year's version of cpso_nilf.wf1 to the current directory
' before running this program
' so that the additional year of data from cps_nilf_month.wf1 can be appended

%wf = "cpso_nilf.wf1"
%wf_append = @replace(%wf, ".wf1", "")

wfopen {%wf}

pageselect a
wfselect work
pageselect a
copy(merge) a\* {%wf_append}::a\*

wfselect work
pageselect q
copy(merge) q\* {%wf_append}::q\*

wfselect work
pageselect m
copy(merge) m\* {%wf_append}::m\*

wfselect {%wf_append}
wfsave cpso_nilf

close @wf

