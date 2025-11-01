' This program creates the population workfiles for the
' disability termination rate sensitivity runs

' INPUTS: op1242r.wf1, op1242o.wf1,
'         op1241r_ter1ter2ter3.wf1, op1241o_ter1ter2ter3.wf1, 
'		    op1243r_ter1ter2ter3.wf1, op1243o_ter1ter2ter3.wf1
		  
' OUTPUTS: op1242ter1r.wf1, op1242ter1o.wf1,
'          op1242ter3r.wf1, op1242ter3o.wf1
		   
logmode logmsg

exec .\setup2

!TRYEAR = 2025
!DIYEAR = !TRYEAR - 1
!tryr = !TRYEAR - 1900
!diyr = !DIYEAR - 1900

for !alt = 1 to 3 step 2

   shell copy op{!diyr}2r.wf1  op{!diyr}2ter{!alt}r.wf1
   wfopen op{!diyr}{!alt}r_ter1ter2ter3
   wfopen op{!diyr}2ter{!alt}r.wf1
   copy(o) op{!diyr}{!alt}r_ter1ter2ter3::a\p*dicp op{!diyr}2ter{!alt}r::a\p*dicp
   wfsave(2) op{!diyr}2ter{!alt}r.wf1
   wfclose op{!diyr}2ter{!alt}r.wf1
   wfclose op{!diyr}{!alt}r_ter1ter2ter3

   shell copy op{!diyr}2o.wf1  op{!diyr}2ter{!alt}o.wf1
   wfopen op{!diyr}{!alt}o_ter1ter2ter3

   wfselect work
   pageselect a
   copy op{!diyr}{!alt}o_ter1ter2ter3::a\n*d n*d
   delete *ild
   copy op{!diyr}{!alt}o_ter1ter2ter3::a\r*d r*d
   delete *ild
   copy op{!diyr}{!alt}o_ter1ter2ter3::a\r*di r*di
   wfopen op{!diyr}2ter{!alt}o.wf1
   wfselect work
   pageselect a
   group g * not resid
   %slist = g.@members
   for %s {%slist}
      copy(o) {%s} op{!diyr}2ter{!alt}o::a\{%s}
   next
   wfselect op{!diyr}2ter{!alt}o
   wfsave(2) op{!diyr}2ter{!alt}o
   close op{!diyr}2ter{!alt}o
   wfselect work
   pageselect a
   delete *

   wfselect work
   pageselect q
   copy op{!diyr}{!alt}o_ter1ter2ter3::q\r*d r*d
   copy op{!diyr}{!alt}o_ter1ter2ter3::q\r*di r*di
   wfclose op{!diyr}{!alt}o_ter1ter2ter3
   wfopen op{!diyr}2ter{!alt}o.wf1
   wfselect work
   pageselect q
   group g * not resid
   %slist = g.@members
   for %s {%slist}
      copy(o) {%s} op{!diyr}2ter{!alt}o::q\{%s}
   next
   wfselect op{!diyr}2ter{!alt}o
   wfsave(2) op{!diyr}2ter{!alt}o
   close op{!diyr}2ter{!alt}o
   wfselect work
   pageselect q
   delete *

next

