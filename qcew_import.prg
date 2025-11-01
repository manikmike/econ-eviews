logmode logmsg

'set current directory
cd "S:\LRECON\Data\Processed\BLS\QCEW"

'workfile to import to (exclude extension)
%wf_import = "qcew_2024Q3_f"

wfopen {%wf_import} + ".wf1"

%today = "20250313"

%startq = "2014q1"
%endq = "2024q3"
%startm = "2014m01"
%endm = "2024m9"

'set y or n (yes or no) to tell program if preliminary/final/published data should be imported
%import_f = "n"
%import_p = "n"
%import_pb = "y"

'set names of files to import from in current directory
%files_f = "SSANAT243_250205_f.txt " + "SSAPR243_250205_f.txt " + "SSAVI243_250205_f.txt"
%files_p = "SSANAT243_250108_p.txt " + "SSAPR243_250108_p.txt " + "SSAVI243_250108_p.txt"
%file_pb = "QCEW_PB_2014Q1_2024Q3_20250313.xlsx"

pageselect a
pagecopy(page=a_all)
delete a_all\obsid*
delete a\*

pageselect q
pagecopy(page=q_all)
delete q_all\obsid*
delete q\*

pageselect m
pagecopy(page=m_all)
delete m_all\obsid*
delete m\*


pageselect vars
pagestruct(freq=q, start=%startq, end=%endq)
alpha yq = @datestr(@date, "yyyyq")
alpha yqq = @datestr(@date, "yyyy[q]q")

if %import_f = "y" then
%yqq = @wjoin(@convert(yqq))

Text t

for %f {%files_f}
   t.append(file) {%f}
   !n = t.@linecount
   for !i = 1 to !n
		for %j = {%yqq}
			pageselect vars
			%yq = @replace(%j, "q", "")
			%q = @right(%yq, 1)
      		%s = t.@line(!i)
			%y = @left(%yq, 4)
			if %yq = @mid(%s, 13, 5) then
      			call processLine(%s, %j, %q, %y)
			else
			endif
		next
   next
	pageselect vars
   t.clear
next

pageselect vars
delete t
else
endif

subroutine processLine(string %line, string %yearq, string %quarter, string %year)
   logmsg {%line}

	%line = @replace(%line, " ", "0")

	wfselect {%wf_import}
	pageselect q

	smpl {%yearq} {%yearq}

	%series_name_raw = "e_" + @mid(%line, 1, 2) + "_" + @mid(%line, 6, 1) + "_F"
	series {%series_name_raw} = (@val(@mid(%line, 18, 9)) + @val(@mid(%line, 27, 9)) + @val(@mid(%line, 36, 9))) / 3

	%series_name_raw = "ws_" + @mid(%line, 1, 2) + "_" + @mid(%line, 6, 1) + "_F"
	series {%series_name_raw} = @val(@mid(%line, 45, 14))


	'monthly data
	pageselect m
	%series_name_raw = "e_" + @mid(%line, 1, 2) + "_" + @mid(%line, 6, 1) + "_F"
	if %quarter = "1" then
		smpl {%year}m01 {%year}m01
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m02 {%year}m02
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m03 {%year}m03
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif

	if %quarter = "2" then
		smpl {%year}m04 {%year}m04
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m05 {%year}m05
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m06 {%year}m06
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif

	if %quarter = "3" then
		smpl {%year}m07 {%year}m07
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m08 {%year}m08
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m09 {%year}m09
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif

	if %quarter = "4" then
		smpl {%year}m10 {%year}m10
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m11 {%year}m11
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m12 {%year}m12
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif



endsub

'compute total series
if %import_f = "y" then
pageselect q
smpl @all

for %s 0 1 2 5
	series e_to_{%s}_f = e_00_{%s}_f + e_72_{%s}_f + e_78_{%s}_f
	series ws_to_{%s}_f = ws_00_{%s}_f + ws_72_{%s}_f + ws_78_{%s}_f
next

for %s 3
	series e_to_{%s}_f = e_00_{%s}_f + e_72_{%s}_f
	series ws_to_{%s}_f = ws_00_{%s}_f + ws_72_{%s}_f
next



pageselect q
pagecopy(page=q_f)
smpl {%startq} {%endq}
pageselect q
delete q\*



pageselect m
smpl @all

for %s 0 1 2 5
	series e_to_{%s}_f = e_00_{%s}_f + e_72_{%s}_f + e_78_{%s}_f
next

for %s 3
	series e_to_{%s}_f = e_00_{%s}_f + e_72_{%s}_f
next



pageselect m
pagecopy(page=m_f)
smpl {%startm} {%endm}
pageselect m
delete m\*

else
endif

'Preliminary
if %import_p = "y" then
pageselect vars

%yqq = @wjoin(@convert(yqq))

Text t

for %f {%files_p}
   t.append(file) {%f}
   !n = t.@linecount
   for !i = 1 to !n
		for %j = {%yqq}
			pageselect vars
			%yq = @replace(%j, "q", "")
      		%q = @right(%yq, 1)
      		%s = t.@line(!i)
			%y = @left(%yq, 4)
			if %yq = @mid(%s, 13, 5) then
      			call processLine_p(%s, %j, %q, %y)
			else
			endif
		next
   next
	pageselect vars
   t.clear
next

pageselect vars
delete t
else
endif

subroutine processLine_p(string %line, string %yearq, string %quarter, string %year)
   logmsg {%line}

	%line = @replace(%line, " ", "0")

	wfselect {%wf_import}
	pageselect q

	smpl {%yearq} {%yearq}

	%series_name_raw = "e_" + @mid(%line, 1, 2) + "_" + @mid(%line, 6, 1) + "_P"
	series {%series_name_raw} = (@val(@mid(%line, 18, 9)) + @val(@mid(%line, 27, 9)) + @val(@mid(%line, 36, 9))) / 3

	%series_name_raw = "ws_" + @mid(%line, 1, 2) + "_" + @mid(%line, 6, 1) + "_P"
	series {%series_name_raw} = @val(@mid(%line, 45, 14))


	'monthly data
	pageselect m
	%series_name_raw = "e_" + @mid(%line, 1, 2) + "_" + @mid(%line, 6, 1) + "_P"
	if %quarter = "1" then
		smpl {%year}m01 {%year}m01
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m02 {%year}m02
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m03 {%year}m03
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif

	if %quarter = "2" then
		smpl {%year}m04 {%year}m04
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m05 {%year}m05
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m06 {%year}m06
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif

	if %quarter = "3" then
		smpl {%year}m07 {%year}m07
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m08 {%year}m08
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m09 {%year}m09
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif

	if %quarter = "4" then
		smpl {%year}m10 {%year}m10
		series {%series_name_raw} = @val(@mid(%line, 18, 9))

		smpl {%year}m11 {%year}m11
		series {%series_name_raw} = @val(@mid(%line, 27, 9))

		smpl {%year}m12 {%year}m12
		series {%series_name_raw} = @val(@mid(%line, 36, 9))
	else
	endif



endsub

'compute total series
if %import_p = "y" then
pageselect q
smpl @all

for %s 0 1 2 5
	series e_to_{%s}_p = e_00_{%s}_p + e_72_{%s}_p + e_78_{%s}_p
	series ws_to_{%s}_p = ws_00_{%s}_p + ws_72_{%s}_p + ws_78_{%s}_p
next

for %s 3
	series e_to_{%s}_p = e_00_{%s}_p + e_72_{%s}_p
	series ws_to_{%s}_p = ws_00_{%s}_p + ws_72_{%s}_p
next



pageselect q
pagecopy(page=q_p)
smpl {%startq} {%endq}
pageselect q
delete q\*




pageselect m
smpl @all

for %s 0 1 2 5
	series e_to_{%s}_p = e_00_{%s}_p + e_72_{%s}_p + e_78_{%s}_p
next

for %s 3
	series e_to_{%s}_p = e_00_{%s}_p + e_72_{%s}_p
next



pageselect m
pagecopy(page=m_p)
smpl {%startm} {%endm}
pageselect m
delete m\*
else
endif

'rename series in pages q_f m_f to prepare for merging
if %import_f = "y" then
for %p q_f m_f
pageselect {%p}
rename *00* *us*
rename *72* *pr*
rename *78* *vi*

rename *_0* *_to*
rename *_1* *_gf*
rename *_2* *_gs*
rename *_3* *_gl*
rename *_5* *_pv*
next

'transform magnitude
pageselect m_f
group e e*
for !i = 1 to e.@count
	%name = e.@seriesname(!i)
	series {%name} = {%name} / (10^6)
next
delete e
delete obs*

pageselect q_f
group e e*
for !i = 1 to e.@count
	%name = e.@seriesname(!i)
	series {%name} = {%name} / (10^6)
next
group ws ws*
for !i = 1 to ws.@count
	%name = ws.@seriesname(!i)
	series {%name} = {%name} / (10^9)
next
delete e
delete ws
delete obs*

'merge q_f page in page q_all
copy(m) q_f\* q_all\
pageselect q_all
smpl 2006q4 {%endq}

'merge m_f page in page m_all
copy(m) m_f\* m_all\
pageselect m_all
smpl 2006m10 {%endm}

pagedelete q_f m_f

else
endif

'rename series in pages q_p m_p to prepare for merging
if %import_p = "y" then
for %p q_p m_p
pageselect {%p}
rename *00* *us*
rename *72* *pr*
rename *78* *vi*

rename *_0* *_to*
rename *_1* *_gf*
rename *_2* *_gs*
rename *_3* *_gl*
rename *_5* *_pv*
next

'transform magnitude
pageselect m_p
group e e*
for !i = 1 to e.@count
	%name = e.@seriesname(!i)
	series {%name} = {%name} / (10^6)
next
delete e
delete obs*


pageselect q_p
group e e*
for !i = 1 to e.@count
	%name = e.@seriesname(!i)
	series {%name} = {%name} / (10^6)
next
group ws ws*
for !i = 1 to ws.@count
	%name = ws.@seriesname(!i)
	series {%name} = {%name} / (10^9)
next
delete e
delete ws
delete obs*

'merge q_p page in page q_all
copy(m) q_p\* q_all\
pageselect q_all
smpl 2006q4 {%endq}

'merge m_p page in page m_all
copy(m) m_p\* m_all\
pageselect m_all
smpl 2006m10 {%endm}

pagedelete q_p m_p

else
endif

'import published data
if %import_pb = "y" then
pageselect m_all
import(mode="u") {%file_pb} range=emplvl colhead=1 na="#N/A" @freq M @id @date(month) @destid @date @smpl @all
copy(c=an) m_all\*pb q_all\

pageselect q_all
import(mode="u") {%file_pb} range=wages colhead=1 namepos=custom colheadnames=("Name") na="#N/A" format=(D,4W) @freq Q @id @date(quarter) @destid @date @smpl @all
else
endif

'copy q to a converting frequency
pageselect q_all
copy(c=an) q_all\e* a_all\
copy(c=sn) q_all\ws* a_all\
pageselect a_all
smpl 2006 {%endq}

pagedelete a q m

pageselect a_all
pagecopy(page=a)
delete obs*
smpl 2006 {%endq}

pageselect q_all
pagecopy(page=q)
delete obs*
smpl 2006q4 {%endq}

pageselect m_all
pagecopy(page=m)
delete obs*
smpl 2006m10 {%endm}

pagedelete a_all q_all m_all

pageselect vars
delete yq*

wforder a q m vars

pageselect a

wfsave(2) qcew_import_{%today}


