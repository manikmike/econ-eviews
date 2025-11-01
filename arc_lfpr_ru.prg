' This program writes labor force participation rates and unemployment rates by
' age-sex groups to an Excel file as requested by the Actuarial Research
' Company.

' Store user name in variable.
%usrnm = @env("username")

' Set up temprorary workfile.
exec c:\Users\{%usrnm}\GitRepos\econ-eviews\setup2.prg

' Set folder conatining A file.
%afldr = "S:\LRECON\ModelRuns\TR2023\2023-0127-1550-TR232\out\mul\"

' Set Trustees Report year.
!yrtr = 2023
' Convert TR year to string.
%syrtr = @str(!yrtr)
' Store last two digits of TR year in string variable.
%syrtrr2 = @right(%syrtr, 2)
' Set string variable for EViews workfile for intermediate assumptions.
%swf = "atr" + %syrtrr2 + "2.wf1"
' Set string to full path of A file.
%swfp = %afldr + %swf
' Set ranges of Excel tabs.
%r1 = "LFPR_F_" + %syrtrr2+ "2!B6"
%r2 = "LFPR_M_" + %syrtrr2+ "2!B6"
%r3 = "RU_F_" + %syrtrr2+ "2!B6"
%r4 = "RU_M_" + %syrtrr2+ "2!B6"

' Set first year of output to year prior to Trustees Report year.
!yfo = !yrtr - 1
' Set last year of output.
!ylo = !yrtr + 74

' Construct output Excel file based on Trustees Report year.
%xlfile = "S:\LRECON\TrusteesReports\TR" + @str(!yrtr) + _
          "\Requests\ARC\LFPR&RU_TR" + + %syrtrr2 + "2.xlsx"

%age = "1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o 16o"

%pfage = @wreplace(%age, "*", "pf*")
%pmage = @wreplace(%age, "*", "pm*")
%rfage = @wreplace(%age, "*", "rf*")
%rmage = @wreplace(%age, "*", "rm*")

open {%swfp}
pageselect a

for %s {%pfage} {%pmage} {%rfage} {%rmage}
  copy %s work::a\
next

close {%swf}

sample export !yfo !ylo

pagesave(type="excelxml",mode=update,noid) %outfile range={%r1} nonames @smpl export @keep {%pfage}
pagesave(type="excelxml",mode=update,noid) %outfile range={%r2} nonames @smpl export @keep {%pmage}
pagesave(type="excelxml",mode=update,noid) %outfile range={%r3} nonames @smpl export @keep {%rfage}
pagesave(type="excelxml",mode=update,noid) %outfile range={%r4} nonames @smpl export @keep {%rmage}

delete *
close @all


