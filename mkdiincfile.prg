' This program creates the population workfiles for the
' disability incidence rate sensitivity runs

' INPUTS: op1242r.wf1, op1242o.wf1,
'         op1241r_inc1inc2inc3.wf1, op1241o_inc1inc2inc3.wf1, 
'		    op1243r_inc1inc2inc3.wf1, op1243o_inc1inc2inc3.wf1
		  
' OUTPUTS: op1242inc1r.wf1, op1242inc1o.wf1,
'          op1242inc3r.wf1, op1242inc3o.wf1
		   
logmode logmsg

exec .\setup2

!TRYEAR = 2025
!DIYEAR = !TRYEAR - 1
!tryr = !TRYEAR - 1900
!diyr = !DIYEAR - 1900

for !alt = 1 to 3 step 2

   shell copy op{!diyr}2r.wf1  op{!diyr}2inc{!alt}r.wf1
   wfopen op{!diyr}{!alt}r_inc1inc2inc3
   wfopen op{!diyr}2inc{!alt}r.wf1
   copy(o) op{!diyr}{!alt}r_inc1inc2inc3::a\p*dicp op{!diyr}2inc{!alt}r::a\p*dicp
   wfsave(2) op{!diyr}2inc{!alt}r.wf1
   wfclose op{!diyr}2inc{!alt}r.wf1
   wfclose op{!diyr}{!alt}r_inc1inc2inc3

   shell copy op{!diyr}2o.wf1  op{!diyr}2inc{!alt}o.wf1
   wfopen op{!diyr}{!alt}o_inc1inc2inc3

   wfselect work
   pageselect a
   copy op{!diyr}{!alt}o_inc1inc2inc3::a\n*d n*d
   delete *ild
   copy op{!diyr}{!alt}o_inc1inc2inc3::a\r*d r*d
   delete *ild
   copy op{!diyr}{!alt}o_inc1inc2inc3::a\r*di r*di
   wfopen op{!diyr}2inc{!alt}o.wf1
   wfselect work
   pageselect a
   group g * not resid
   %slist = g.@members
   for %s {%slist}
      copy(o) {%s} op{!diyr}2inc{!alt}o::a\{%s}
   next
   wfselect op{!diyr}2inc{!alt}o
   wfsave(2) op{!diyr}2inc{!alt}o
   close op{!diyr}2inc{!alt}o
   wfselect work
   pageselect a
   delete *

   wfselect work
   pageselect q
   copy op{!diyr}{!alt}o_inc1inc2inc3::q\r*d r*d
   copy op{!diyr}{!alt}o_inc1inc2inc3::q\r*di r*di
   wfclose op{!diyr}{!alt}o_inc1inc2inc3
   wfopen op{!diyr}2inc{!alt}o.wf1
   wfselect work
   pageselect q
   group g * not resid
   %slist = g.@members
   for %s {%slist}
      copy(o) {%s} op{!diyr}2inc{!alt}o::q\{%s}
   next
   wfselect op{!diyr}2inc{!alt}o
   wfsave(2) op{!diyr}2inc{!alt}o
   close op{!diyr}2inc{!alt}o
   wfselect work
   pageselect q
   delete *

next

