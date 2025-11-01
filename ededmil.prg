'This procedure edits the latest quarterly edmil with projected values.
'Data is stored in BKDO and BKDR1
'remember to update years and months for current TR


' setup ************************************************************

exec .\setup2

pageselect vars

'Section 1 - Assign name and end year to variable containing projected military data.

%milname = "edmil" ' series name in BKDR1

%endyr = "2100"
%endyrqtr = %endyr+"q4"

!year_tr = 2024

' ************************************************************

' Section 2 - Enter latest historical monthly aggregate military data, which is then converted
'             to quarterly and annual data. All values are then stored in BKDO1 databank.

'set bkdr1 and bkdo1 workfile names
%bkdr1_wf = "bkdr1.wf1"
%bkdr1 = @replace(%bkdr1_wf, ".wf1", "")
%bkdo1_wf = "bkdo1.wf1"
%bkdo1 = @replace(%bkdo1_wf, ".wf1", "")

wfopen {%bkdr1_wf}
pageselect m
wfopen {%bkdo1_wf}
pageselect m

wfselect work
pageselect m

copy {%bkdo1}::m\edmil work::m\edmil

' The population values may be updated by The Census Bureau
' all the way back to the last decennial census.

smpl 2020m4 {!year_tr}m12
wfopen censuspop.wf1
pageselect military
genr edmil = nm1659m + nf1659m
copy(m) edmil work::m\edmil
close censuspop
                                                        
' Hold the last value from year prior to TR year constant instead of using preliminary estimates from TR year
wfselect work
pageselect m

smpl {!year_tr}m1 {%endyr}m12
edmil = edmil(-1)
smpl @all

pageselect q
smpl @all
copy(c="a") m\edmil q\edmil
pageselect a
smpl @all
copy(c="a") q\edmil a\edmil
for %freq m q a
   pageselect {%freq}
	wfselect work
	copy {%freq}\edmil {%bkdo1}::{%freq}\edmil
	wfselect {%bkdo1}
	wfsave(2) {%bkdo1}

	wfselect work
	copy {%freq}\edmil {%bkdr1}::{%freq}\edmil
	wfselect {%bkdr1}
	wfsave(2) {%bkdr1}

   'delete edmil
next

close @wf


