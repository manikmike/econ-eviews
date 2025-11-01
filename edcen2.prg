' This procedure edits quarterly estimates of the U.S.
' Armed Forces by age and sex


' NOTE: Data for series below are unpublished data from Dept. of Commerce (Census Bureau)

'set bkdr1 and bkdo1 workfile names
%bkdr1_wf = "bkdr1.wf1"
%bkdr1 = @replace(%bkdr1_wf, ".wf1", "")
%bkdo1_wf = "bkdo1.wf1"
%bkdo1 = @replace(%bkdo1_wf, ".wf1", "")



exec .\setup2

wfopen {%bkdr1_wf}
pageselect q
wfopen {%bkdo1_wf}
pageselect q

wfselect work
pageselect q

%x = _
   "NM1617M NM1819M NM2024M NM2529M NM3034M NM3539M NM4044M NM4549M NM5054M NM5559M " + _
   "NF1617M NF1819M NF2024M NF2529M NF3034M NF3539M NF4044M NF4549M NF5054M NF5559M"

pageselect q
for %s {%x}
	wfselect work
	copy {%bkdo1}::q\{%s} work::q\{%s}

next

' Data for 2020 through 2023, come from 2020 Census
' Values from 2023 are repeated for the remainder of the sample period

smpl 2020q2 2023q4

wfopen censuspop.wf1
pageselect military_quarterly
for %s {%x}
   copy(m) {%s} work::q\{%s}
next
wfclose censuspop

wfselect work
pageselect q
smpl @all
for %s {%x}
   smpl 2024q1 2100q4
   {%s} = {%s}(-1)
   smpl @all
   copy(c="a") q\{%s} a\{%s}
next

for %f q a
	wfselect work
   pageselect {%f}
   smpl @all
   'save first in case additional historical data
	for %s {%x}
	copy(m) work::{%f}\{%s} {%bkdr1}::{%f}\{%s}
	next
	wfselect {%bkdr1}
	wfsave(2) {%bkdr1}

	wfselect work
	pageselect {%f}
   delete *          ' exists in bkdr1 to merge

	for %s {%x}
	copy(m) {%bkdr1}::{%f}\{%s} {%bkdo1}::{%f}\{%s}
	next

	wfselect {%bkdo1}
	wfsave(2) {%bkdo1}

	wfselect work
	pageselect {%f}
   delete *
next

close @wf


