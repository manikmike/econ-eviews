
%output_file = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Budget\FY2025\President's_FY25_Budget\Revenues\FY25B.out"

%save_path = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\Budget\FY2025\President's_FY25_Budget\Revenues\FY25B.wf1"

%save = "Y"

'import description rows
wfopen %output_file ftype=ascii rectype=crlf rformat="descriptions 1-50" colhead=0 eoltype=pad badfield=NA @freq U 1 @smpl @all

pagecontract 4 5

%des_run = descriptions(1)
%des_date = descriptions(2)

wfclose

'import data
wfopen(wf=revout_import) %output_file ftype=ascii rectype=crlf skip=0 fieldtype=delimited na="A" custom=" \" delim=space types=(,A,A,A,,,A,) colhead=0 eoltype=pad badfield=NA @freq U 1 @smpl @all

pagecontract @first+6 @last
delete series07 series08 series09
pagerename Untitled import_raw
pageselect import_raw





!seg_index = 0
!current_row = 1
!find_end = 0

'loop to identify variable segments
for !i=1 to @rows(resid)
	if !find_end = 0 then
		if @val(series01({!i})) = NA then
			!seg_index = !seg_index + 1
			!seg_start_{!seg_index} = !i
			!find_end = 1
		endif
	else
	if !find_end = 1 then
		if @val(series01({!i})) = NA then
			!seg_end_{!seg_index} = !i - 1
			!seg_index = !seg_index + 1
			!seg_start_{!seg_index} = !i
		else
			if !i = @rows(resid) then
				!seg_end_{!seg_index} = !i
endif
endif
endif
endif
next


'create first page where segment data will be appended
pagecopy(smpl=!seg_start_1 !seg_end_1)
pagerename Untitled segment_append
%var_name = series01(1)
%aq = series02(1)
if %aq = "A" then
	%startper = series03(1)
	%endper = series04(1)
else
	if %aq = "Q" then
		%startper = series03(1) + "q" + series04(1)
		%endper = series05(1) + "q" + series06(1)
else
	if %aq = "M" then
		%startper = series03(1) + "m" + series04(1)
		%endper = series05(1) + "m" + series06(1)
endif
endif
endif
pagecontract @first+1 @last
delete series05 series06
pagestack(interleave) series? @ *?  *
series stack = @val(series)
pagecontract IF STACK <> NA
if %aq = "A" then
	pagestruct(freq=a, start=%startper)
else
	if %aq = "Q" then
		pagestruct(freq=q, start=%startper)
else
	if %aq = "M" then
		pagestruct(freq=m, start=%startper)
endif
endif
endif

stack.label(d) %des_run
stack.label(Date) %des_date

rename stack {%var_name}

pagecreate(page=a) a 1900 2100
pagecreate(page=q) q 1900 2100
pagecreate(page=m) m 1900 2100
pageselect segment_append_STK

if %aq = "A" then
	copy {%var_name} a\
else
	if %aq = "Q" then
		copy {%var_name} q\
else
	if %aq = "M" then
		copy {%var_name} m\
endif
endif
endif
pageselect import_raw
pagedelete segment_append_STK segment_append




'loop to copy rest of variable segments to a and q pages

for !i=2 to !seg_index
pageselect import_raw
pagecopy(smpl=!seg_start_{!i} !seg_end_{!i})
pagerename Untitled segment_append
%var_name = series01(1)
%aq = series02(1)
if %aq = "A" then
	%startper = series03(1)
	%endper = series04(1)
else
	if %aq = "Q" then
		%startper = series03(1) + "q" + series04(1)
		%endper = series05(1) + "q" + series06(1)
else
	if %aq = "M" then
		%startper = series03(1) + "m" + series04(1)
		%endper = series05(1) + "m" + series06(1)
endif
endif
endif
pagecontract @first+1 @last
delete series05 series06
pagestack(interleave) series? @ *?  *
series stack = @val(series)
pagecontract IF STACK <> NA
if %aq = "A" then
	pagestruct(freq=a, start=%startper)
else
	if %aq = "Q" then
		pagestruct(freq=q, start=%startper)
else
	if %aq = "M" then
		pagestruct(freq=m, start=%startper)
endif
endif
endif

stack.label(d) %des_run
stack.label(Date) %des_date

rename stack {%var_name}

pageselect segment_append_STK

if %aq = "A" then
	copy {%var_name} a\
else
	if %aq = "Q" then
		copy {%var_name} q\
else
	if %aq = "M" then
		copy {%var_name} m\
endif
endif
endif

pageselect import_raw
pagedelete segment_append_STK segment_append

next

pagedelete import_raw

if %save = "Y" then
	wfsave(2) %save_path
else
	if %save = "N" then
		@uiprompt("Workfile has not been saved")
endif
endif


