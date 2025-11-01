' This program creates age-sex-marital status variables for the population, labor force, unemployment rate, and military.
'   The raw data is drawn from the March ASEC via MDAT, and it is placed in an excel spreadsheet called 
'   This program reads the data from the spreadsheet, creates a name for each series that is used for the economics process
'   It also agregates the syoa to age groups that are used for the economics process, and aggregates marital status codes to 
'   marital groups (married with spouse, maried no spouse present (widowed,divorced,separated), and never married.
'   It then updates the cps68YYY bank.
'  
'   Bob Weathers, 11/9/2018


!year = 2023 ' latest year of data (default)

' Use first argument of program call to override default year
if (%0 <> "") then
   !year = @val(%0)
endif

%wfname = "cpsr" + @str(!year - 1900) + "_males_and_females"

%xlname = @str(!year) + " march male and female.xlsx"


wfcreate(wf=%wfname, page=Pop) a {!year} {!year}

%age= "14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 " + _
				"70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85"

%series="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27" 

%lo = "14 16 18 20 25 30 35 40 45 50 55 60 62 65 70 75 80" 
%hi = "15 17 19 24 29 34 39 44 49 54 59 61 64 69 74 79 84"

%agrp ="1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o"
%sex="m f"


'Civilian Non-Institutionalized Population Series: By Sex, Age, and Marital Status
%v="n"

'   Males
%s="m"

import %xlname range="Pop"!$K$4:$K$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="Pop"!$L$4:$L$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="Pop"!$M$4:$M$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="Pop"!$N$4:$N$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="Pop"!$O$4:$O$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="Pop"!$P$4:$P$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="Pop"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

' Females
%s="f"

import %xlname range="Pop"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="Pop"!$T$4:$T$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="Pop"!$U$4:$U$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="Pop"!$V$4:$V$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="Pop"!$W$4:$W$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="Pop"!$X$4:$X$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="Pop"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ms={%v}{%g}{%a}mcivs + {%v}{%g}{%a}mafs +{%v}{%g}{%a}msa 
        next
     next

	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ma={%v}{%g}{%a}mad + {%v}{%g}{%a}mas +{%v}{%g}{%a}maw 
        next
     next

group nmagrms nm????ms nm85oms
group nmagrma nm????ma nm85oma
group nmagrmn nm????nm nm85onm

group nfagrms nf????ms nf85oms
group nfagrma nf????ma nf85oma
group nfagrmn nf????nm nf85onm


'Labor Force Series: By Sex, Age, and Marital Status
pagecreate(page=LC) a {!year} {!year}
%v="l"

'   Males
%s="m"

import %xlname range="LC"!$K$4:$K$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="LC"!$L$4:$L$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="LC"!$M$4:$M$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="LC"!$N$4:$N$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="LC"!$O$4:$O$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="LC"!$P$4:$P$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="LC"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

' Females
%s="f"

import %xlname range="LC"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="LC"!$T$4:$T$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="LC"!$U$4:$U$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="LC"!$V$4:$V$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="LC"!$W$4:$W$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="LC"!$X$4:$X$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="LC"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ms={%v}{%g}{%a}mcivs + {%v}{%g}{%a}mafs +{%v}{%g}{%a}msa 
        next
     next

	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ma={%v}{%g}{%a}mad + {%v}{%g}{%a}mas +{%v}{%g}{%a}maw 
        next
     next

group lmagrms lm????ms lm85oms
group lmagrma lm????ma lm85oma
group lmagrmn lm????nm lm85onm

group lfagrms lf????ms lf85oms
group lfagrma lf????ma lf85oma
group lfagrmn lf????nm lf85onm


'Unemployed Series: By Sex, Age, and Marital Status
pagecreate(page=RU) a {!year} {!year}
%v="r"

'   Males
%s="m"

import %xlname range="RU"!$K$4:$K$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="RU"!$L$4:$L$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="RU"!$M$4:$M$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="RU"!$N$4:$N$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="RU"!$O$4:$O$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="RU"!$P$4:$P$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="RU"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

' Females
%s="f"

import %xlname range="RU"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="RU"!$T$4:$T$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="RU"!$U$4:$U$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="RU"!$V$4:$V$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="RU"!$W$4:$W$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="RU"!$X$4:$X$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="RU"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ms={%v}{%g}{%a}mcivs + {%v}{%g}{%a}mafs +{%v}{%g}{%a}msa 
        next
     next

	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ma={%v}{%g}{%a}mad + {%v}{%g}{%a}mas +{%v}{%g}{%a}maw 
        next
     next

group rmagrms rm????ms rm85oms
group rmagrma rm????ma rm85oma
group rmagrmn rm????nm rm85onm

group rfagrms rf????ms rf85oms
group rfagrma rf????ma rf85oma
group rfagrmn rf????nm rf85onm


'Armed Forces Series: By Sex, Age, and Marital Status
pagecreate(page=Military) a {!year} {!year}
%v="m"

'   Males
%s="m"

import %xlname range="Military"!$K$4:$K$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="Military"!$L$4:$L$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="Military"!$M$4:$M$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="Military"!$N$4:$N$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="Military"!$O$4:$O$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="Military"!$P$4:$P$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="Military"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

' Females
%s="f"

import %xlname range="Military"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivs"
call rename
call agegroup

import %xlname range="Military"!$T$4:$T$75 byrow @freq a {!year} 
%m="mafs"
call rename
call agegroup

import %xlname range="Military"!$U$4:$U$75 byrow @freq a {!year} 
%m="msa"
call rename
call agegroup

import %xlname range="Military"!$V$4:$V$75 byrow @freq a {!year} 
%m="maw"
call rename
call agegroup

import %xlname range="Military"!$W$4:$W$75 byrow @freq a {!year} 
%m="mad"
call rename
call agegroup

import %xlname range="Military"!$X$4:$X$75 byrow @freq a {!year} 
%m="mas"
call rename
call agegroup

import %xlname range="Military"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="nm"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ms={%v}{%g}{%a}mcivs + {%v}{%g}{%a}mafs +{%v}{%g}{%a}msa 
        next
     next

	for %a {%agrp}
	  for %g {%sex}
		genr {%v}{%g}{%a}ma={%v}{%g}{%a}mad + {%v}{%g}{%a}mas +{%v}{%g}{%a}maw 
        next
     next

group mmagrms mm????ms mm85oms
group mmagrma mm????ma mm85oma
group mmagrmn mm????nm mm85onm

group mfagrms mf????ms mf85oms
group mfagrma mf????ma mf85oma
group mfagrmn mf????nm mf85onm


subroutine rename

for !a=14 to 85
    if !a=14 then
      rename series01 {%v}{%s}{!a}{%m} 
   endif
   if !a=15 then
      rename series02 {%v}{%s}{!a}{%m} 
   endif
   if !a=16 then
      rename series03 {%v}{%s}{!a}{%m} 
   endif
   if !a=17 then
     rename series04 {%v}{%s}{!a}{%m} 
   endif
   if !a=18 then
      rename series05 {%v}{%s}{!a}{%m} 
   endif
   if !a=19 then
      rename series06 {%v}{%s}{!a}{%m} 
   endif
   if !a=20 then
      rename series07 {%v}{%s}{!a}{%m} 
   endif
   if !a=21 then
     rename series08 {%v}{%s}{!a}{%m} 
   endif
   if !a=22 then
     rename series09 {%v}{%s}{!a}{%m} 
   endif

   if !a>22 then
	!i=!a-13
	rename series{!i} {%v}{%s}{!a}{%m}
   endif

next
endsub

subroutine agegroup
	' Number of age groupings:
	!anum = @wcount(%lo)
   
	' Construct each mef concept-sex-age grouping:
	    for !n = 1 to !anum          ' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         ' Create age grouping label
		     %ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.

         		genr {%v}{%s}{%ag}{%m} = 0  ' initialize series for each grouping
         		for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            	     {%v}{%s}{%ag}{%m} = {%v}{%s}{%ag}{%m} + {%v}{%s}{!a}{%m}
            	next
  		next
		genr {%v}{%s}85o{%m} = {%v}{%s}85{%m}
endsub

wfsave(2) %wfname
wfclose %wfname


