' Age/sex level of total U.S armed forces for March.  Values are defined as
' total less civilian labor force for 1968-2024

!TRYEAR = 2025

%bkdr1_wf = "bkdr1.wf1"
%bkdr1 = @replace(%bkdr1_wf, ".wf1", "")
%bkdo1_wf = "bkdo1.wf1"
%bkdo1 = @replace(%bkdo1_wf, ".wf1", "")


exec .\setup2

wfopen censuspop.wf1
wfselect work

wfopen {%bkdr1_wf}
pageselect a
smpl @all


' Next section creates an annual series on March observations for Age/sex
' and an annual series on March observations for EDMIL
wfselect work
pageselect a
for %s f m
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559
      'fetch(db=bkdr1) n{%s}{%a}m_3
		copy {%bkdr1}::a\n{%s}{%a}m_3 work::a\n{%s}{%a}m_3
		wfselect work
		pageselect a
      copy(smpl="if @month=3") censuspop::military\n{%s}{%a}m temp
      smpl 2021 {!TRYEAR}-1
      n{%s}{%a}m_3 = temp
      delete temp
      smpl @all
   next
next

'fetch(db=bkdr1) edmil_3
copy {%bkdr1}::a\edmil_3 work::a\edmil_3
wfselect work
pageselect m
genr temp = 0
genr tempm = 0
genr tempf = 0
for %s m f
   copy(m) censuspop::military\n{%s}1659m temp{%s}
   temp{%s} = temp{%s}(2)
next
temp = tempm + tempf
copy(c=f) temp work::a\temp
delete temp tempm tempf
pageselect a
edmil_3 = (temp > 0) * temp + (temp <= 0) * edmil_3
delete temp
close censuspop

pageselect a
smpl @all

for %s f m
   for %a 1415 6061 6264 6569 7074 7579 8084 85O
      genr n{%s}{%a}m_3 = 0
   next
next

genr nm16om_3 = _
   nm1415m_3 + nm1617m_3 + nm1819m_3 + nm2024m_3 + nm2529m_3 + nm3034m_3 + _
   nm3539m_3 + nm4044m_3 + nm4549m_3 + nm5054m_3 + nm5559m_3 + nm6061m_3 + _
   nm6264m_3 + nm6569m_3 + nm7074m_3 + nm7579m_3 + nm8084m_3 + nm85om_3
   
genr nf16om_3 = _
   nf1415m_3 + nf1617m_3 + nf1819m_3 + nf2024m_3 + nf2529m_3 + nf3034m_3 + _
   nf3539m_3 + nf4044m_3 + nf4549m_3 + nf5054m_3 + nf5559m_3 + nf6061m_3 + _
   nf6264m_3 + nf6569m_3 + nf7074m_3 + nf7579m_3 + nf8084m_3 + nf85om_3
   
genr n16om_3 = nm16om_3 + nf16om_3


pageselect a
smpl {!TRYEAR} 2100
for %s f m
   for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 1415 6061 6264 6569 7074 7579 8084 85O 16o
      n{%s}{%a}m_3 = n{%s}{%a}m_3(-1)
   next
next
n16om_3 = n16om_3(-1)

smpl @all
edmil_3 = n16om_3
'store(db=bkdr1) *
copy(m) a\* {%bkdr1}::a\*
delete *
pageselect vars

wfselect {%bkdr1}
wfsave(2) {%bkdr1}

close @wf


