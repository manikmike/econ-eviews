' This program copies the "down-the-line" files from the model solution
' output directories to the Long-Range Server

' NOTES: The directories src1 and src2 must contain the model solution output files
'        The directories dest1 and dest2 must be created before running the program

%src1 = "E:\usr\Econ\EcoDev\out\mul"
%src2 = "E:\usr\Econ\EcoDev\out\cos"

%dest1 = "\\lrserv1\usr\cwp.19\out\mul"
%dest2 = "\\lrserv1\usr\gnp.19\out\cos"

%sols = "fer1 fer3 imm1 imm3 mor1 mor3 mar1 mar3 div1 div3 tax1 tax3"

for %ext {%sols}
   shell copy {%src1}\*.{%ext} {%dest1} ' captures files like .imm1 and .hist.imm1
   shell copy {%src2}\*.{%ext} {%dest2}
   if (@lower(%ext) = "alt2") then
      shell copy {%src1}\*.hist {%dest1} ' needed because only alt2 creates generic .hist files 
      shell copy {%src2}\*.hist {%dest2}
   endif
next

