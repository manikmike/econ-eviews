' This program downloads data from IHS Global Insight database
' to an existing EViews workfile named bkdrw.wf1 and a new EViews workfile called bkdrw_dld1.wf1
' NOTE: This program takes about 5 minutes to run, so be patient.

exec .\setup2
clearerrs
logmode e

' If the following command fails, send an email to customercare@spglobal.com or call +1 800 447 2273
' You may also be able to create a new personal access token (PAT) here: https://myprofile.ihsmarkit.com/
dbopen(type=ihs global insight, username=eb269219-84ed-453c-87cd-9d595ac9fbc3, password=BVQXKWNVhRNnGDX4)

wfopen bkl.wf1
wfselect work
copy bkl::vars\dl*ssa work::vars\dl*ssa
copy bkl::vars\dl*wefa work::vars\dl*wefa
close bkl

%dlfreq = "m q m m m q q a a q"

for !i = 1 to 10
   if (!i <> 6) then
      pageselect vars
      %dlwefa = dl{!i}wefa
      %freq = @wordq(%dlfreq,!i)
      pageselect {%freq}
      string dl{!i}wefa = %dlwefa
      scalar aa = @wcount(%dlwefa)
      !ec = @errorcount
      setmaxerrs (!ec + aa + 1)
      for %s {%dlwefa}
         fetch(db=ihsglobalinsigh) us\{%s}
      next
      !ec = @errorcount
      setmaxerrs (!ec + 1)
      delete aa dl{!i}wefa
   endif
next

close @db

wfopen bkdrw.wf1
wfselect work

for %p a q m
   pageselect {%p}
   group grp * not resid
   %all = grp.@members
   delete grp
   for %s {%all}
      copy work::{%p}\{%s} bkdrw::{%p}\{%s}
   next
next
wfselect bkdrw
wfsave(2) bkdrw
wfclose bkdrw

wfselect work
wfsave(2) bkdrw_dld1.wf1


