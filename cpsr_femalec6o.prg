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

%wfname = "cpsr" + @str(!year - 1900) + "_femalec6o"

%xlname = @str(!year) + " march female with children over age 6.xlsx"

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

' Females: married civilian
%s="f"

import %xlname range="Pop"!$N$4:$N$75 byrow @freq a {!year} 
%m="mcivsc6o_0"
call rename
call agegroup


import %xlname range="Pop"!$O$4:$O$75 byrow @freq a {!year} 
%m="mcivsc6o_1"
call rename
call agegroup

import %xlname range="Pop"!$P$4:$P$75 byrow @freq a {!year} 
%m="mcivsc6o_2"
call rename
call agegroup

import %xlname range="Pop"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="mcivsc6o_3"
call rename
call agegroup

import %xlname range="Pop"!$R$4:$R$75 byrow @freq a {!year} 
%m="mcivsc6o_4"
call rename
call agegroup

import %xlname range="Pop"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivsc6o_5"
call rename
call agegroup

import %xlname range="Pop"!$T$4:$T$75 byrow @freq a {!year} 
%m="mcivsc6o_6"
call rename
call agegroup

import %xlname range="Pop"!$U$4:$U$75 byrow @freq a {!year} 
%m="mcivsc6o_7"
call rename
call agegroup

import %xlname range="Pop"!$V$4:$V$75 byrow @freq a {!year} 
%m="mcivsc6o_8"
call rename
call agegroup

import %xlname range="Pop"!$W$4:$W$75 byrow @freq a {!year} 
%m="mcivsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mcivsc6o_3p= {%v}f{%a}mcivsc6o_3 + {%v}f{%a}mcivsc6o_4 + {%v}f{%a}mcivsc6o_5 + {%v}f{%a}mcivsc6o_6 + _
		 {%v}f{%a}mcivsc6o_7 + {%v}f{%a}mcivsc6o_8 + {%v}f{%a}mcivsc6o_9p  
      next

' Females: married armed forces
%s="f"

import %xlname range="Pop"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="mafsc6o_0"
call rename
call agegroup

import %xlname range="Pop"!$Z$4:$Z$75 byrow @freq a {!year} 
%m="mafsc6o_1"
call rename
call agegroup

import %xlname range="Pop"!$AA$4:$AA$75 byrow @freq a {!year} 
%m="mafsc6o_2"
call rename
call agegroup

import %xlname range="Pop"!$AB$4:$AB$75 byrow @freq a {!year} 
%m="mafsc6o_3"
call rename
call agegroup

import %xlname range="Pop"!$AC$4:$AC$75 byrow @freq a {!year} 
%m="mafsc6o_4"
call rename
call agegroup

import %xlname range="Pop"!$AD$4:$AD$75 byrow @freq a {!year} 
%m="mafsc6o_5"
call rename
call agegroup

import %xlname range="Pop"!$AE$4:$AE$75 byrow @freq a {!year} 
%m="mafsc6o_6"
call rename
call agegroup

import %xlname range="Pop"!$AF$4:$AF$75 byrow @freq a {!year} 
%m="mafsc6o_7"
call rename
call agegroup

import %xlname range="Pop"!$AG$4:$AG$75 byrow @freq a {!year} 
%m="mafsc6o_8"
call rename
call agegroup

import %xlname range="Pop"!$AH$4:$AH$75 byrow @freq a {!year} 
%m="mafsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mafsc6o_3p={%v}f{%a}mafsc6o_3 + {%v}f{%a}mafsc6o_4 + {%v}f{%a}mafsc6o_5 + {%v}f{%a}mafsc6o_6 + _
		 {%v}f{%a}mafsc6o_7 + {%v}f{%a}mafsc6o_8 + {%v}f{%a}mafsc6o_9p 
      next

' Females: married spouse absent
%s="f"

import %xlname range="Pop"!$AJ$4:$AJ$75 byrow @freq a {!year} 
%m="msac6o_0"
call rename
call agegroup

import %xlname range="Pop"!$AK$4:$AK$75 byrow @freq a {!year} 
%m="msac6o_1"
call rename
call agegroup

import %xlname range="Pop"!$AL$4:$AL$75 byrow @freq a {!year} 
%m="msac6o_2"
call rename
call agegroup

import %xlname range="Pop"!$AM$4:$AM$75 byrow @freq a {!year} 
%m="msac6o_3"
call rename
call agegroup

import %xlname range="Pop"!$AN$4:$AN$75 byrow @freq a {!year} 
%m="msac6o_4"
call rename
call agegroup

import %xlname range="Pop"!$AO$4:$AO$75 byrow @freq a {!year} 
%m="msac6o_5"
call rename
call agegroup

import %xlname range="Pop"!$AP$4:$AP$75 byrow @freq a {!year} 
%m="msac6o_6"
call rename
call agegroup

import %xlname range="Pop"!$AQ$4:$AQ$75 byrow @freq a {!year} 
%m="msac6o_7"
call rename
call agegroup

import %xlname range="Pop"!$AR$4:$AR$75 byrow @freq a {!year} 
%m="msac6o_8"
call rename
call agegroup

import %xlname range="Pop"!$AS$4:$AS$75 byrow @freq a {!year} 
%m="msac6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}msac6o_3p= {%v}f{%a}msac6o_3 + {%v}f{%a}msac6o_4 + {%v}f{%a}msac6o_5 + {%v}f{%a}msac6o_6 + _
		 {%v}f{%a}msac6o_7 + {%v}f{%a}msac6o_8 + {%v}f{%a}msac6o_9p
      next

' Females: widowed
%s="f"

import %xlname range="Pop"!$AU$4:$AU$75 byrow @freq a {!year} 
%m="mawc6o_0"
call rename
call agegroup

import %xlname range="Pop"!$AV$4:$AV$75 byrow @freq a {!year} 
%m="mawc6o_1"
call rename
call agegroup

import %xlname range="Pop"!$AW$4:$AW$75 byrow @freq a {!year} 
%m="mawc6o_2"
call rename
call agegroup

import %xlname range="Pop"!$AX$4:$AX$75 byrow @freq a {!year} 
%m="mawc6o_3"
call rename
call agegroup

import %xlname range="Pop"!$AY$4:$AY$75 byrow @freq a {!year} 
%m="mawc6o_4"
call rename
call agegroup

import %xlname range="Pop"!$AZ$4:$AZ$75 byrow @freq a {!year} 
%m="mawc6o_5"
call rename
call agegroup

import %xlname range="Pop"!$BA$4:$BA$75 byrow @freq a {!year} 
%m="mawc6o_6"
call rename
call agegroup

import %xlname range="Pop"!$BB$4:$BB$75 byrow @freq a {!year} 
%m="mawc6o_7"
call rename
call agegroup

import %xlname range="Pop"!$BC$4:$BC$75 byrow @freq a {!year} 
%m="mawc6o_8"
call rename
call agegroup

import %xlname range="Pop"!$BD$4:$BD$75 byrow @freq a {!year} 
%m="mawc6o_9p"
call rename
call agegroup


	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mawnc18={%v}f{%a}mawc6o_0
	    genr {%v}f{%a}mawc6o1={%v}f{%a}mawc6o_1
 	    genr {%v}f{%a}mawc6o2={%v}f{%a}mawc6o_2
	    genr {%v}f{%a}mawc6o3_={%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p
	    genr {%v}f{%a}mawc6o_3p= {%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p 
     next

' Females: Divorced 
%s="f"

import %xlname range="Pop"!$BF$4:$BF$75 byrow @freq a {!year} 
%m="madc6o_0"
call rename
call agegroup

import %xlname range="Pop"!$BG$4:$BG$75 byrow @freq a {!year} 
%m="madc6o_1"
call rename
call agegroup

import %xlname range="Pop"!$BH$4:$BH$75 byrow @freq a {!year} 
%m="madc6o_2"
call rename
call agegroup

import %xlname range="Pop"!$BI$4:$BI$75 byrow @freq a {!year} 
%m="madc6o_3"
call rename
call agegroup

import %xlname range="Pop"!$BJ$4:$BJ$75 byrow @freq a {!year} 
%m="madc6o_4"
call rename
call agegroup

import %xlname range="Pop"!$BK$4:$BK$75 byrow @freq a {!year} 
%m="madc6o_5"
call rename
call agegroup

import %xlname range="Pop"!$BL$4:$BL$75 byrow @freq a {!year} 
%m="madc6o_6"
call rename
call agegroup

import %xlname range="Pop"!$BM$4:$BM$75 byrow @freq a {!year} 
%m="madc6o_7"
call rename
call agegroup

import %xlname range="Pop"!$BN$4:$BN$75 byrow @freq a {!year} 
%m="madc6o_8"
call rename
call agegroup

import %xlname range="Pop"!$BO$4:$BO$75 byrow @freq a {!year} 
%m="madc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}madnc18={%v}f{%a}madc6o_0
	    genr {%v}f{%a}madc6o1={%v}f{%a}madc6o_1
 	    genr {%v}f{%a}madc6o2={%v}f{%a}madc6o_2
	    genr {%v}f{%a}madc6o3_={%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
	    genr {%v}f{%a}madc6o_3p= {%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
      next

' Females: Separated 
%s="f"

import %xlname range="Pop"!$BQ$4:$BQ$75 byrow @freq a {!year} 
%m="masc6o_0"
call rename
call agegroup

import %xlname range="Pop"!$BR$4:$BR$75 byrow @freq a {!year} 
%m="masc6o_1"
call rename
call agegroup

import %xlname range="Pop"!$BS$4:$BS$75 byrow @freq a {!year} 
%m="masc6o_2"
call rename
call agegroup

import %xlname range="Pop"!$BT$4:$BT$75 byrow @freq a {!year} 
%m="masc6o_3"
call rename
call agegroup

import %xlname range="Pop"!$BU$4:$BU$75 byrow @freq a {!year} 
%m="masc6o_4"
call rename
call agegroup

import %xlname range="Pop"!$BV$4:$BV$75 byrow @freq a {!year} 
%m="masc6o_5"
call rename
call agegroup

import %xlname range="Pop"!$BW$4:$BW$75 byrow @freq a {!year} 
%m="masc6o_6"
call rename
call agegroup

import %xlname range="Pop"!$BX$4:$BX$75 byrow @freq a {!year} 
%m="masc6o_7"
call rename
call agegroup

import %xlname range="Pop"!$BY$4:$BY$75 byrow @freq a {!year} 
%m="masc6o_8"
call rename
call agegroup

import %xlname range="Pop"!$BZ$4:$BZ$75 byrow @freq a {!year} 
%m="masc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}masnc18={%v}f{%a}masc6o_0
	    genr {%v}f{%a}masc6o1={%v}f{%a}masc6o_1
 	    genr {%v}f{%a}masc6o2={%v}f{%a}masc6o_2
	    genr {%v}f{%a}masc6o3_= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
	    genr {%v}f{%a}masc6o_3p= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
      next

' Females: Never Married 
%s="f"

import %xlname range="Pop"!$CB$4:$CB$75 byrow @freq a {!year} 
%m="mnc6o_0"
call rename
call agegroup

import %xlname range="Pop"!$CC$4:$CC$75 byrow @freq a {!year} 
%m="mnc6o_1"
call rename
call agegroup

import %xlname range="Pop"!$CD$4:$CD$75 byrow @freq a {!year} 
%m="mnc6o_2"
call rename
call agegroup

import %xlname range="Pop"!$CE$4:$CE$75 byrow @freq a {!year} 
%m="mnc6o_3"
call rename
call agegroup

import %xlname range="Pop"!$CF$4:$CF$75 byrow @freq a {!year} 
%m="mnc6o_4"
call rename
call agegroup

import %xlname range="Pop"!$CG$4:$CG$75 byrow @freq a {!year} 
%m="mnc6o_5"
call rename
call agegroup

import %xlname range="Pop"!$CH$4:$CH$75 byrow @freq a {!year} 
%m="mnc6o_6"
call rename
call agegroup

import %xlname range="Pop"!$CI$4:$CI$75 byrow @freq a {!year} 
%m="mnc6o_7"
call rename
call agegroup

import %xlname range="Pop"!$CJ$4:$CJ$75 byrow @freq a {!year} 
%m="mnc6o_8"
call rename
call agegroup

import %xlname range="Pop"!$CK$4:$CK$75 byrow @freq a {!year} 
%m="mnc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mnc6o_3p={%v}f{%a}mnc6o_3 + {%v}f{%a}mnc6o_4 + {%v}f{%a}mnc6o_5 + {%v}f{%a}mnc6o_6 + _
 									   {%v}f{%a}mnc6o_7 + {%v}f{%a}mnc6o_8 + {%v}f{%a}mnc6o_9p
      next


	'Aggregate up categories

	'Aggregate up categories
	for %a {%agrp}
		genr {%v}f{%a}msnc18={%v}f{%a}mcivsc6o_0 + {%v}f{%a}mafsc6o_0 + {%v}f{%a}msac6o_0 
	  	genr {%v}f{%a}msc6o1={%v}f{%a}mcivsc6o_1 + {%v}f{%a}mafsc6o_1 +{%v}f{%a}msac6o_1 
		genr {%v}f{%a}msc6o2={%v}f{%a}mcivsc6o_2 + {%v}f{%a}mafsc6o_2 +{%v}f{%a}msac6o_2
		genr {%v}f{%a}msc6o3_={%v}f{%a}mcivsc6o_3p + {%v}f{%a}mafsc6o_3p +{%v}f{%a}msac6o_3p		
      next

	for %a {%agrp}
		genr {%v}f{%a}manc18={%v}f{%a}madc6o_0 + {%v}f{%a}masc6o_0 + {%v}f{%a}mawc6o_0
		genr {%v}f{%a}mac6o1={%v}f{%a}madc6o_1 + {%v}f{%a}masc6o_1 + {%v}f{%a}mawc6o_1 
		genr {%v}f{%a}mac6o2={%v}f{%a}madc6o_2 + {%v}f{%a}masc6o_2 + {%v}f{%a}mawc6o_2
		genr {%v}f{%a}mac6o3_={%v}f{%a}madc6o_3p + {%v}f{%a}masc6o_3p +{%v}f{%a}mawc6o_3p
     next

	for %a {%agrp}
		genr {%v}f{%a}nmnc18={%v}f{%a}mnc6o_0
		genr {%v}f{%a}nmc6o1={%v}f{%a}mnc6o_1 
		genr {%v}f{%a}nmc6o2={%v}f{%a}mnc6o_2 
		genr {%v}f{%a}nmc6o3_={%v}f{%a}mnc6o_3p 
     next


'Labor Force Series: By Sex, Age, and Marital Status
pagecreate(page=LC) a {!year} {!year}

%v="l"

' Females: married civilian
%s="f"

import %xlname range="LC"!$N$4:$N$75 byrow @freq a {!year} 
%m="mcivsc6o_0"
call rename
call agegroup


import %xlname range="LC"!$O$4:$O$75 byrow @freq a {!year} 
%m="mcivsc6o_1"
call rename
call agegroup

import %xlname range="LC"!$P$4:$P$75 byrow @freq a {!year} 
%m="mcivsc6o_2"
call rename
call agegroup

import %xlname range="LC"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="mcivsc6o_3"
call rename
call agegroup

import %xlname range="LC"!$R$4:$R$75 byrow @freq a {!year} 
%m="mcivsc6o_4"
call rename
call agegroup

import %xlname range="LC"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivsc6o_5"
call rename
call agegroup

import %xlname range="LC"!$T$4:$T$75 byrow @freq a {!year} 
%m="mcivsc6o_6"
call rename
call agegroup

import %xlname range="LC"!$U$4:$U$75 byrow @freq a {!year} 
%m="mcivsc6o_7"
call rename
call agegroup

import %xlname range="LC"!$V$4:$V$75 byrow @freq a {!year} 
%m="mcivsc6o_8"
call rename
call agegroup

import %xlname range="LC"!$W$4:$W$75 byrow @freq a {!year} 
%m="mcivsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mcivsc6o_3p= {%v}f{%a}mcivsc6o_3 + {%v}f{%a}mcivsc6o_4 + {%v}f{%a}mcivsc6o_5 + {%v}f{%a}mcivsc6o_6 + _
		 {%v}f{%a}mcivsc6o_7 + {%v}f{%a}mcivsc6o_8 + {%v}f{%a}mcivsc6o_9p  
      next

' Females: married armed forces
%s="f"

import %xlname range="LC"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="mafsc6o_0"
call rename
call agegroup

import %xlname range="LC"!$Z$4:$Z$75 byrow @freq a {!year} 
%m="mafsc6o_1"
call rename
call agegroup

import %xlname range="LC"!$AA$4:$AA$75 byrow @freq a {!year} 
%m="mafsc6o_2"
call rename
call agegroup

import %xlname range="LC"!$AB$4:$AB$75 byrow @freq a {!year} 
%m="mafsc6o_3"
call rename
call agegroup

import %xlname range="LC"!$AC$4:$AC$75 byrow @freq a {!year} 
%m="mafsc6o_4"
call rename
call agegroup

import %xlname range="LC"!$AD$4:$AD$75 byrow @freq a {!year} 
%m="mafsc6o_5"
call rename
call agegroup

import %xlname range="LC"!$AE$4:$AE$75 byrow @freq a {!year} 
%m="mafsc6o_6"
call rename
call agegroup

import %xlname range="LC"!$AF$4:$AF$75 byrow @freq a {!year} 
%m="mafsc6o_7"
call rename
call agegroup

import %xlname range="LC"!$AG$4:$AG$75 byrow @freq a {!year} 
%m="mafsc6o_8"
call rename
call agegroup

import %xlname range="LC"!$AH$4:$AH$75 byrow @freq a {!year} 
%m="mafsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mafsc6o_3p={%v}f{%a}mafsc6o_3 + {%v}f{%a}mafsc6o_4 + {%v}f{%a}mafsc6o_5 + {%v}f{%a}mafsc6o_6 + _
		 {%v}f{%a}mafsc6o_7 + {%v}f{%a}mafsc6o_8 + {%v}f{%a}mafsc6o_9p 
      next

' Females: married spouse absent
%s="f"

import %xlname range="LC"!$AJ$4:$AJ$75 byrow @freq a {!year} 
%m="msac6o_0"
call rename
call agegroup

import %xlname range="LC"!$AK$4:$AK$75 byrow @freq a {!year} 
%m="msac6o_1"
call rename
call agegroup

import %xlname range="LC"!$AL$4:$AL$75 byrow @freq a {!year} 
%m="msac6o_2"
call rename
call agegroup

import %xlname range="LC"!$AM$4:$AM$75 byrow @freq a {!year} 
%m="msac6o_3"
call rename
call agegroup

import %xlname range="LC"!$AN$4:$AN$75 byrow @freq a {!year} 
%m="msac6o_4"
call rename
call agegroup

import %xlname range="LC"!$AO$4:$AO$75 byrow @freq a {!year} 
%m="msac6o_5"
call rename
call agegroup

import %xlname range="LC"!$AP$4:$AP$75 byrow @freq a {!year} 
%m="msac6o_6"
call rename
call agegroup

import %xlname range="LC"!$AQ$4:$AQ$75 byrow @freq a {!year} 
%m="msac6o_7"
call rename
call agegroup

import %xlname range="LC"!$AR$4:$AR$75 byrow @freq a {!year} 
%m="msac6o_8"
call rename
call agegroup

import %xlname range="LC"!$AS$4:$AS$75 byrow @freq a {!year} 
%m="msac6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}msac6o_3p= {%v}f{%a}msac6o_3 + {%v}f{%a}msac6o_4 + {%v}f{%a}msac6o_5 + {%v}f{%a}msac6o_6 + _
		 {%v}f{%a}msac6o_7 + {%v}f{%a}msac6o_8 + {%v}f{%a}msac6o_9p
      next

' Females: widowed
%s="f"

import %xlname range="LC"!$AU$4:$AU$75 byrow @freq a {!year} 
%m="mawc6o_0"
call rename
call agegroup

import %xlname range="LC"!$AV$4:$AV$75 byrow @freq a {!year} 
%m="mawc6o_1"
call rename
call agegroup

import %xlname range="LC"!$AW$4:$AW$75 byrow @freq a {!year} 
%m="mawc6o_2"
call rename
call agegroup

import %xlname range="LC"!$AX$4:$AX$75 byrow @freq a {!year} 
%m="mawc6o_3"
call rename
call agegroup

import %xlname range="LC"!$AY$4:$AY$75 byrow @freq a {!year} 
%m="mawc6o_4"
call rename
call agegroup

import %xlname range="LC"!$AZ$4:$AZ$75 byrow @freq a {!year} 
%m="mawc6o_5"
call rename
call agegroup

import %xlname range="LC"!$BA$4:$BA$75 byrow @freq a {!year} 
%m="mawc6o_6"
call rename
call agegroup

import %xlname range="LC"!$BB$4:$BB$75 byrow @freq a {!year} 
%m="mawc6o_7"
call rename
call agegroup

import %xlname range="LC"!$BC$4:$BC$75 byrow @freq a {!year} 
%m="mawc6o_8"
call rename
call agegroup

import %xlname range="LC"!$BD$4:$BD$75 byrow @freq a {!year} 
%m="mawc6o_9p"
call rename
call agegroup


	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mawnc18={%v}f{%a}mawc6o_0
	    genr {%v}f{%a}mawc6o1={%v}f{%a}mawc6o_1
 	    genr {%v}f{%a}mawc6o2={%v}f{%a}mawc6o_2
	    genr {%v}f{%a}mawc6o3_={%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p
	    genr {%v}f{%a}mawc6o_3p= {%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p 
     next

' Females: Divorced 
%s="f"

import %xlname range="LC"!$BF$4:$BF$75 byrow @freq a {!year} 
%m="madc6o_0"
call rename
call agegroup

import %xlname range="LC"!$BG$4:$BG$75 byrow @freq a {!year} 
%m="madc6o_1"
call rename
call agegroup

import %xlname range="LC"!$BH$4:$BH$75 byrow @freq a {!year} 
%m="madc6o_2"
call rename
call agegroup

import %xlname range="LC"!$BI$4:$BI$75 byrow @freq a {!year} 
%m="madc6o_3"
call rename
call agegroup

import %xlname range="LC"!$BJ$4:$BJ$75 byrow @freq a {!year} 
%m="madc6o_4"
call rename
call agegroup

import %xlname range="LC"!$BK$4:$BK$75 byrow @freq a {!year} 
%m="madc6o_5"
call rename
call agegroup

import %xlname range="LC"!$BL$4:$BL$75 byrow @freq a {!year} 
%m="madc6o_6"
call rename
call agegroup

import %xlname range="LC"!$BM$4:$BM$75 byrow @freq a {!year} 
%m="madc6o_7"
call rename
call agegroup

import %xlname range="LC"!$BN$4:$BN$75 byrow @freq a {!year} 
%m="madc6o_8"
call rename
call agegroup

import %xlname range="LC"!$BO$4:$BO$75 byrow @freq a {!year} 
%m="madc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}madnc18={%v}f{%a}madc6o_0
	    genr {%v}f{%a}madc6o1={%v}f{%a}madc6o_1
 	    genr {%v}f{%a}madc6o2={%v}f{%a}madc6o_2
	    genr {%v}f{%a}madc6o3_={%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
	    genr {%v}f{%a}madc6o_3p= {%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
      next

' Females: Separated 
%s="f"

import %xlname range="LC"!$BQ$4:$BQ$75 byrow @freq a {!year} 
%m="masc6o_0"
call rename
call agegroup

import %xlname range="LC"!$BR$4:$BR$75 byrow @freq a {!year} 
%m="masc6o_1"
call rename
call agegroup

import %xlname range="LC"!$BS$4:$BS$75 byrow @freq a {!year} 
%m="masc6o_2"
call rename
call agegroup

import %xlname range="LC"!$BT$4:$BT$75 byrow @freq a {!year} 
%m="masc6o_3"
call rename
call agegroup

import %xlname range="LC"!$BU$4:$BU$75 byrow @freq a {!year} 
%m="masc6o_4"
call rename
call agegroup

import %xlname range="LC"!$BV$4:$BV$75 byrow @freq a {!year} 
%m="masc6o_5"
call rename
call agegroup

import %xlname range="LC"!$BW$4:$BW$75 byrow @freq a {!year} 
%m="masc6o_6"
call rename
call agegroup

import %xlname range="LC"!$BX$4:$BX$75 byrow @freq a {!year} 
%m="masc6o_7"
call rename
call agegroup

import %xlname range="LC"!$BY$4:$BY$75 byrow @freq a {!year} 
%m="masc6o_8"
call rename
call agegroup

import %xlname range="LC"!$BZ$4:$BZ$75 byrow @freq a {!year} 
%m="masc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}masnc18={%v}f{%a}masc6o_0
	    genr {%v}f{%a}masc6o1={%v}f{%a}masc6o_1
 	    genr {%v}f{%a}masc6o2={%v}f{%a}masc6o_2
	    genr {%v}f{%a}masc6o3_= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
	    genr {%v}f{%a}masc6o_3p= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
      next

' Females: Never Married 
%s="f"

import %xlname range="LC"!$CB$4:$CB$75 byrow @freq a {!year} 
%m="mnc6o_0"
call rename
call agegroup

import %xlname range="LC"!$CC$4:$CC$75 byrow @freq a {!year} 
%m="mnc6o_1"
call rename
call agegroup

import %xlname range="LC"!$CD$4:$CD$75 byrow @freq a {!year} 
%m="mnc6o_2"
call rename
call agegroup

import %xlname range="LC"!$CE$4:$CE$75 byrow @freq a {!year} 
%m="mnc6o_3"
call rename
call agegroup

import %xlname range="LC"!$CF$4:$CF$75 byrow @freq a {!year} 
%m="mnc6o_4"
call rename
call agegroup

import %xlname range="LC"!$CG$4:$CG$75 byrow @freq a {!year} 
%m="mnc6o_5"
call rename
call agegroup

import %xlname range="LC"!$CH$4:$CH$75 byrow @freq a {!year} 
%m="mnc6o_6"
call rename
call agegroup

import %xlname range="LC"!$CI$4:$CI$75 byrow @freq a {!year} 
%m="mnc6o_7"
call rename
call agegroup

import %xlname range="LC"!$CJ$4:$CJ$75 byrow @freq a {!year} 
%m="mnc6o_8"
call rename
call agegroup

import %xlname range="LC"!$CK$4:$CK$75 byrow @freq a {!year} 
%m="mnc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mnc6o_3p={%v}f{%a}mnc6o_3 + {%v}f{%a}mnc6o_4 + {%v}f{%a}mnc6o_5 + {%v}f{%a}mnc6o_6 + _
 									   {%v}f{%a}mnc6o_7 + {%v}f{%a}mnc6o_8 + {%v}f{%a}mnc6o_9p
      next


	'Aggregate up categories

	'Aggregate up categories
	for %a {%agrp}
		genr {%v}f{%a}msnc18={%v}f{%a}mcivsc6o_0 + {%v}f{%a}mafsc6o_0 + {%v}f{%a}msac6o_0 
	  	genr {%v}f{%a}msc6o1={%v}f{%a}mcivsc6o_1 + {%v}f{%a}mafsc6o_1 +{%v}f{%a}msac6o_1 
		genr {%v}f{%a}msc6o2={%v}f{%a}mcivsc6o_2 + {%v}f{%a}mafsc6o_2 +{%v}f{%a}msac6o_2
		genr {%v}f{%a}msc6o3_={%v}f{%a}mcivsc6o_3p + {%v}f{%a}mafsc6o_3p +{%v}f{%a}msac6o_3p		
      next

	for %a {%agrp}
		genr {%v}f{%a}manc18={%v}f{%a}madc6o_0 + {%v}f{%a}masc6o_0 + {%v}f{%a}mawc6o_0
		genr {%v}f{%a}mac6o1={%v}f{%a}madc6o_1 + {%v}f{%a}masc6o_1 + {%v}f{%a}mawc6o_1 
		genr {%v}f{%a}mac6o2={%v}f{%a}madc6o_2 + {%v}f{%a}masc6o_2 + {%v}f{%a}mawc6o_2
		genr {%v}f{%a}mac6o3_={%v}f{%a}madc6o_3p + {%v}f{%a}masc6o_3p +{%v}f{%a}mawc6o_3p
     next

	for %a {%agrp}
		genr {%v}f{%a}nmnc18={%v}f{%a}mnc6o_0
		genr {%v}f{%a}nmc6o1={%v}f{%a}mnc6o_1 
		genr {%v}f{%a}nmc6o2={%v}f{%a}mnc6o_2 
		genr {%v}f{%a}nmc6o3_={%v}f{%a}mnc6o_3p 
     next


'Unemployed Series: By Sex, Age, and Marital Status
pagecreate(page=RU) a {!year} {!year}

%v="r"

' Females: married civilian
%s="f"

import %xlname range="RU"!$N$4:$N$75 byrow @freq a {!year} 
%m="mcivsc6o_0"
call rename
call agegroup


import %xlname range="RU"!$O$4:$O$75 byrow @freq a {!year} 
%m="mcivsc6o_1"
call rename
call agegroup

import %xlname range="RU"!$P$4:$P$75 byrow @freq a {!year} 
%m="mcivsc6o_2"
call rename
call agegroup

import %xlname range="RU"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="mcivsc6o_3"
call rename
call agegroup

import %xlname range="RU"!$R$4:$R$75 byrow @freq a {!year} 
%m="mcivsc6o_4"
call rename
call agegroup

import %xlname range="RU"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivsc6o_5"
call rename
call agegroup

import %xlname range="RU"!$T$4:$T$75 byrow @freq a {!year} 
%m="mcivsc6o_6"
call rename
call agegroup

import %xlname range="RU"!$U$4:$U$75 byrow @freq a {!year} 
%m="mcivsc6o_7"
call rename
call agegroup

import %xlname range="RU"!$V$4:$V$75 byrow @freq a {!year} 
%m="mcivsc6o_8"
call rename
call agegroup

import %xlname range="RU"!$W$4:$W$75 byrow @freq a {!year} 
%m="mcivsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mcivsc6o_3p= {%v}f{%a}mcivsc6o_3 + {%v}f{%a}mcivsc6o_4 + {%v}f{%a}mcivsc6o_5 + {%v}f{%a}mcivsc6o_6 + _
		 {%v}f{%a}mcivsc6o_7 + {%v}f{%a}mcivsc6o_8 + {%v}f{%a}mcivsc6o_9p  
      next

' Females: married armed forces
%s="f"

import %xlname range="RU"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="mafsc6o_0"
call rename
call agegroup

import %xlname range="RU"!$Z$4:$Z$75 byrow @freq a {!year} 
%m="mafsc6o_1"
call rename
call agegroup

import %xlname range="RU"!$AA$4:$AA$75 byrow @freq a {!year} 
%m="mafsc6o_2"
call rename
call agegroup

import %xlname range="RU"!$AB$4:$AB$75 byrow @freq a {!year} 
%m="mafsc6o_3"
call rename
call agegroup

import %xlname range="RU"!$AC$4:$AC$75 byrow @freq a {!year} 
%m="mafsc6o_4"
call rename
call agegroup

import %xlname range="RU"!$AD$4:$AD$75 byrow @freq a {!year} 
%m="mafsc6o_5"
call rename
call agegroup

import %xlname range="RU"!$AE$4:$AE$75 byrow @freq a {!year} 
%m="mafsc6o_6"
call rename
call agegroup

import %xlname range="RU"!$AF$4:$AF$75 byrow @freq a {!year} 
%m="mafsc6o_7"
call rename
call agegroup

import %xlname range="RU"!$AG$4:$AG$75 byrow @freq a {!year} 
%m="mafsc6o_8"
call rename
call agegroup

import %xlname range="RU"!$AH$4:$AH$75 byrow @freq a {!year} 
%m="mafsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mafsc6o_3p={%v}f{%a}mafsc6o_3 + {%v}f{%a}mafsc6o_4 + {%v}f{%a}mafsc6o_5 + {%v}f{%a}mafsc6o_6 + _
		 {%v}f{%a}mafsc6o_7 + {%v}f{%a}mafsc6o_8 + {%v}f{%a}mafsc6o_9p 
      next

' Females: married spouse absent
%s="f"

import %xlname range="RU"!$AJ$4:$AJ$75 byrow @freq a {!year} 
%m="msac6o_0"
call rename
call agegroup

import %xlname range="RU"!$AK$4:$AK$75 byrow @freq a {!year} 
%m="msac6o_1"
call rename
call agegroup

import %xlname range="RU"!$AL$4:$AL$75 byrow @freq a {!year} 
%m="msac6o_2"
call rename
call agegroup

import %xlname range="RU"!$AM$4:$AM$75 byrow @freq a {!year} 
%m="msac6o_3"
call rename
call agegroup

import %xlname range="RU"!$AN$4:$AN$75 byrow @freq a {!year} 
%m="msac6o_4"
call rename
call agegroup

import %xlname range="RU"!$AO$4:$AO$75 byrow @freq a {!year} 
%m="msac6o_5"
call rename
call agegroup

import %xlname range="RU"!$AP$4:$AP$75 byrow @freq a {!year} 
%m="msac6o_6"
call rename
call agegroup

import %xlname range="RU"!$AQ$4:$AQ$75 byrow @freq a {!year} 
%m="msac6o_7"
call rename
call agegroup

import %xlname range="RU"!$AR$4:$AR$75 byrow @freq a {!year} 
%m="msac6o_8"
call rename
call agegroup

import %xlname range="RU"!$AS$4:$AS$75 byrow @freq a {!year} 
%m="msac6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}msac6o_3p= {%v}f{%a}msac6o_3 + {%v}f{%a}msac6o_4 + {%v}f{%a}msac6o_5 + {%v}f{%a}msac6o_6 + _
		 {%v}f{%a}msac6o_7 + {%v}f{%a}msac6o_8 + {%v}f{%a}msac6o_9p
      next

' Females: widowed
%s="f"

import %xlname range="RU"!$AU$4:$AU$75 byrow @freq a {!year} 
%m="mawc6o_0"
call rename
call agegroup

import %xlname range="RU"!$AV$4:$AV$75 byrow @freq a {!year} 
%m="mawc6o_1"
call rename
call agegroup

import %xlname range="RU"!$AW$4:$AW$75 byrow @freq a {!year} 
%m="mawc6o_2"
call rename
call agegroup

import %xlname range="RU"!$AX$4:$AX$75 byrow @freq a {!year} 
%m="mawc6o_3"
call rename
call agegroup

import %xlname range="RU"!$AY$4:$AY$75 byrow @freq a {!year} 
%m="mawc6o_4"
call rename
call agegroup

import %xlname range="RU"!$AZ$4:$AZ$75 byrow @freq a {!year} 
%m="mawc6o_5"
call rename
call agegroup

import %xlname range="RU"!$BA$4:$BA$75 byrow @freq a {!year} 
%m="mawc6o_6"
call rename
call agegroup

import %xlname range="RU"!$BB$4:$BB$75 byrow @freq a {!year} 
%m="mawc6o_7"
call rename
call agegroup

import %xlname range="RU"!$BC$4:$BC$75 byrow @freq a {!year} 
%m="mawc6o_8"
call rename
call agegroup

import %xlname range="RU"!$BD$4:$BD$75 byrow @freq a {!year} 
%m="mawc6o_9p"
call rename
call agegroup


	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mawnc18={%v}f{%a}mawc6o_0
	    genr {%v}f{%a}mawc6o1={%v}f{%a}mawc6o_1
 	    genr {%v}f{%a}mawc6o2={%v}f{%a}mawc6o_2
	    genr {%v}f{%a}mawc6o3_={%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p
	    genr {%v}f{%a}mawc6o_3p= {%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p 
     next

' Females: Divorced 
%s="f"

import %xlname range="RU"!$BF$4:$BF$75 byrow @freq a {!year} 
%m="madc6o_0"
call rename
call agegroup

import %xlname range="RU"!$BG$4:$BG$75 byrow @freq a {!year} 
%m="madc6o_1"
call rename
call agegroup

import %xlname range="RU"!$BH$4:$BH$75 byrow @freq a {!year} 
%m="madc6o_2"
call rename
call agegroup

import %xlname range="RU"!$BI$4:$BI$75 byrow @freq a {!year} 
%m="madc6o_3"
call rename
call agegroup

import %xlname range="RU"!$BJ$4:$BJ$75 byrow @freq a {!year} 
%m="madc6o_4"
call rename
call agegroup

import %xlname range="RU"!$BK$4:$BK$75 byrow @freq a {!year} 
%m="madc6o_5"
call rename
call agegroup

import %xlname range="RU"!$BL$4:$BL$75 byrow @freq a {!year} 
%m="madc6o_6"
call rename
call agegroup

import %xlname range="RU"!$BM$4:$BM$75 byrow @freq a {!year} 
%m="madc6o_7"
call rename
call agegroup

import %xlname range="RU"!$BN$4:$BN$75 byrow @freq a {!year} 
%m="madc6o_8"
call rename
call agegroup

import %xlname range="RU"!$BO$4:$BO$75 byrow @freq a {!year} 
%m="madc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}madnc18={%v}f{%a}madc6o_0
	    genr {%v}f{%a}madc6o1={%v}f{%a}madc6o_1
 	    genr {%v}f{%a}madc6o2={%v}f{%a}madc6o_2
	    genr {%v}f{%a}madc6o3_={%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
	    genr {%v}f{%a}madc6o_3p= {%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
      next

' Females: Separated 
%s="f"

import %xlname range="RU"!$BQ$4:$BQ$75 byrow @freq a {!year} 
%m="masc6o_0"
call rename
call agegroup

import %xlname range="RU"!$BR$4:$BR$75 byrow @freq a {!year} 
%m="masc6o_1"
call rename
call agegroup

import %xlname range="RU"!$BS$4:$BS$75 byrow @freq a {!year} 
%m="masc6o_2"
call rename
call agegroup

import %xlname range="RU"!$BT$4:$BT$75 byrow @freq a {!year} 
%m="masc6o_3"
call rename
call agegroup

import %xlname range="RU"!$BU$4:$BU$75 byrow @freq a {!year} 
%m="masc6o_4"
call rename
call agegroup

import %xlname range="RU"!$BV$4:$BV$75 byrow @freq a {!year} 
%m="masc6o_5"
call rename
call agegroup

import %xlname range="RU"!$BW$4:$BW$75 byrow @freq a {!year} 
%m="masc6o_6"
call rename
call agegroup

import %xlname range="RU"!$BX$4:$BX$75 byrow @freq a {!year} 
%m="masc6o_7"
call rename
call agegroup

import %xlname range="RU"!$BY$4:$BY$75 byrow @freq a {!year} 
%m="masc6o_8"
call rename
call agegroup

import %xlname range="RU"!$BZ$4:$BZ$75 byrow @freq a {!year} 
%m="masc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}masnc18={%v}f{%a}masc6o_0
	    genr {%v}f{%a}masc6o1={%v}f{%a}masc6o_1
 	    genr {%v}f{%a}masc6o2={%v}f{%a}masc6o_2
	    genr {%v}f{%a}masc6o3_= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
	    genr {%v}f{%a}masc6o_3p= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
      next

' Females: Never Married 
%s="f"

import %xlname range="RU"!$CB$4:$CB$75 byrow @freq a {!year} 
%m="mnc6o_0"
call rename
call agegroup

import %xlname range="RU"!$CC$4:$CC$75 byrow @freq a {!year} 
%m="mnc6o_1"
call rename
call agegroup

import %xlname range="RU"!$CD$4:$CD$75 byrow @freq a {!year} 
%m="mnc6o_2"
call rename
call agegroup

import %xlname range="RU"!$CE$4:$CE$75 byrow @freq a {!year} 
%m="mnc6o_3"
call rename
call agegroup

import %xlname range="RU"!$CF$4:$CF$75 byrow @freq a {!year} 
%m="mnc6o_4"
call rename
call agegroup

import %xlname range="RU"!$CG$4:$CG$75 byrow @freq a {!year} 
%m="mnc6o_5"
call rename
call agegroup

import %xlname range="RU"!$CH$4:$CH$75 byrow @freq a {!year} 
%m="mnc6o_6"
call rename
call agegroup

import %xlname range="RU"!$CI$4:$CI$75 byrow @freq a {!year} 
%m="mnc6o_7"
call rename
call agegroup

import %xlname range="RU"!$CJ$4:$CJ$75 byrow @freq a {!year} 
%m="mnc6o_8"
call rename
call agegroup

import %xlname range="RU"!$CK$4:$CK$75 byrow @freq a {!year} 
%m="mnc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mnc6o_3p={%v}f{%a}mnc6o_3 + {%v}f{%a}mnc6o_4 + {%v}f{%a}mnc6o_5 + {%v}f{%a}mnc6o_6 + _
 									   {%v}f{%a}mnc6o_7 + {%v}f{%a}mnc6o_8 + {%v}f{%a}mnc6o_9p
      next


	'Aggregate up categories

	'Aggregate up categories
	for %a {%agrp}
		genr {%v}f{%a}msnc18={%v}f{%a}mcivsc6o_0 + {%v}f{%a}mafsc6o_0 + {%v}f{%a}msac6o_0 
	  	genr {%v}f{%a}msc6o1={%v}f{%a}mcivsc6o_1 + {%v}f{%a}mafsc6o_1 +{%v}f{%a}msac6o_1 
		genr {%v}f{%a}msc6o2={%v}f{%a}mcivsc6o_2 + {%v}f{%a}mafsc6o_2 +{%v}f{%a}msac6o_2
		genr {%v}f{%a}msc6o3_={%v}f{%a}mcivsc6o_3p + {%v}f{%a}mafsc6o_3p +{%v}f{%a}msac6o_3p		
      next

	for %a {%agrp}
		genr {%v}f{%a}manc18={%v}f{%a}madc6o_0 + {%v}f{%a}masc6o_0 + {%v}f{%a}mawc6o_0
		genr {%v}f{%a}mac6o1={%v}f{%a}madc6o_1 + {%v}f{%a}masc6o_1 + {%v}f{%a}mawc6o_1 
		genr {%v}f{%a}mac6o2={%v}f{%a}madc6o_2 + {%v}f{%a}masc6o_2 + {%v}f{%a}mawc6o_2
		genr {%v}f{%a}mac6o3_={%v}f{%a}madc6o_3p + {%v}f{%a}masc6o_3p +{%v}f{%a}mawc6o_3p
     next

	for %a {%agrp}
		genr {%v}f{%a}nmnc18={%v}f{%a}mnc6o_0
		genr {%v}f{%a}nmc6o1={%v}f{%a}mnc6o_1 
		genr {%v}f{%a}nmc6o2={%v}f{%a}mnc6o_2 
		genr {%v}f{%a}nmc6o3_={%v}f{%a}mnc6o_3p 
     next


'Military Pop: By Sex, Age, and Marital Status
pagecreate(page=MIL) a {!year} {!year}

%v="m"

' Females: married civilian
%s="f"

import %xlname range="Military"!$N$4:$N$75 byrow @freq a {!year} 
%m="mcivsc6o_0"
call rename
call agegroup


import %xlname range="Military"!$O$4:$O$75 byrow @freq a {!year} 
%m="mcivsc6o_1"
call rename
call agegroup

import %xlname range="Military"!$P$4:$P$75 byrow @freq a {!year} 
%m="mcivsc6o_2"
call rename
call agegroup

import %xlname range="Military"!$Q$4:$Q$75 byrow @freq a {!year} 
%m="mcivsc6o_3"
call rename
call agegroup

import %xlname range="Military"!$R$4:$R$75 byrow @freq a {!year} 
%m="mcivsc6o_4"
call rename
call agegroup

import %xlname range="Military"!$S$4:$S$75 byrow @freq a {!year} 
%m="mcivsc6o_5"
call rename
call agegroup

import %xlname range="Military"!$T$4:$T$75 byrow @freq a {!year} 
%m="mcivsc6o_6"
call rename
call agegroup

import %xlname range="Military"!$U$4:$U$75 byrow @freq a {!year} 
%m="mcivsc6o_7"
call rename
call agegroup

import %xlname range="Military"!$V$4:$V$75 byrow @freq a {!year} 
%m="mcivsc6o_8"
call rename
call agegroup

import %xlname range="Military"!$W$4:$W$75 byrow @freq a {!year} 
%m="mcivsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mcivsc6o_3p= {%v}f{%a}mcivsc6o_3 + {%v}f{%a}mcivsc6o_4 + {%v}f{%a}mcivsc6o_5 + {%v}f{%a}mcivsc6o_6 + _
		 {%v}f{%a}mcivsc6o_7 + {%v}f{%a}mcivsc6o_8 + {%v}f{%a}mcivsc6o_9p  
      next

' Females: married armed forces
%s="f"

import %xlname range="Military"!$Y$4:$Y$75 byrow @freq a {!year} 
%m="mafsc6o_0"
call rename
call agegroup

import %xlname range="Military"!$Z$4:$Z$75 byrow @freq a {!year} 
%m="mafsc6o_1"
call rename
call agegroup

import %xlname range="Military"!$AA$4:$AA$75 byrow @freq a {!year} 
%m="mafsc6o_2"
call rename
call agegroup

import %xlname range="Military"!$AB$4:$AB$75 byrow @freq a {!year} 
%m="mafsc6o_3"
call rename
call agegroup

import %xlname range="Military"!$AC$4:$AC$75 byrow @freq a {!year} 
%m="mafsc6o_4"
call rename
call agegroup

import %xlname range="Military"!$AD$4:$AD$75 byrow @freq a {!year} 
%m="mafsc6o_5"
call rename
call agegroup

import %xlname range="Military"!$AE$4:$AE$75 byrow @freq a {!year} 
%m="mafsc6o_6"
call rename
call agegroup

import %xlname range="Military"!$AF$4:$AF$75 byrow @freq a {!year} 
%m="mafsc6o_7"
call rename
call agegroup

import %xlname range="Military"!$AG$4:$AG$75 byrow @freq a {!year} 
%m="mafsc6o_8"
call rename
call agegroup

import %xlname range="Military"!$AH$4:$AH$75 byrow @freq a {!year} 
%m="mafsc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mafsc6o_3p={%v}f{%a}mafsc6o_3 + {%v}f{%a}mafsc6o_4 + {%v}f{%a}mafsc6o_5 + {%v}f{%a}mafsc6o_6 + _
		 {%v}f{%a}mafsc6o_7 + {%v}f{%a}mafsc6o_8 + {%v}f{%a}mafsc6o_9p 
      next

' Females: married spouse absent
%s="f"

import %xlname range="Military"!$AJ$4:$AJ$75 byrow @freq a {!year} 
%m="msac6o_0"
call rename
call agegroup

import %xlname range="Military"!$AK$4:$AK$75 byrow @freq a {!year} 
%m="msac6o_1"
call rename
call agegroup

import %xlname range="Military"!$AL$4:$AL$75 byrow @freq a {!year} 
%m="msac6o_2"
call rename
call agegroup

import %xlname range="Military"!$AM$4:$AM$75 byrow @freq a {!year} 
%m="msac6o_3"
call rename
call agegroup

import %xlname range="Military"!$AN$4:$AN$75 byrow @freq a {!year} 
%m="msac6o_4"
call rename
call agegroup

import %xlname range="Military"!$AO$4:$AO$75 byrow @freq a {!year} 
%m="msac6o_5"
call rename
call agegroup

import %xlname range="Military"!$AP$4:$AP$75 byrow @freq a {!year} 
%m="msac6o_6"
call rename
call agegroup

import %xlname range="Military"!$AQ$4:$AQ$75 byrow @freq a {!year} 
%m="msac6o_7"
call rename
call agegroup

import %xlname range="Military"!$AR$4:$AR$75 byrow @freq a {!year} 
%m="msac6o_8"
call rename
call agegroup

import %xlname range="Military"!$AS$4:$AS$75 byrow @freq a {!year} 
%m="msac6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}msac6o_3p= {%v}f{%a}msac6o_3 + {%v}f{%a}msac6o_4 + {%v}f{%a}msac6o_5 + {%v}f{%a}msac6o_6 + _
		 {%v}f{%a}msac6o_7 + {%v}f{%a}msac6o_8 + {%v}f{%a}msac6o_9p
      next

' Females: widowed
%s="f"

import %xlname range="Military"!$AU$4:$AU$75 byrow @freq a {!year} 
%m="mawc6o_0"
call rename
call agegroup

import %xlname range="Military"!$AV$4:$AV$75 byrow @freq a {!year} 
%m="mawc6o_1"
call rename
call agegroup

import %xlname range="Military"!$AW$4:$AW$75 byrow @freq a {!year} 
%m="mawc6o_2"
call rename
call agegroup

import %xlname range="Military"!$AX$4:$AX$75 byrow @freq a {!year} 
%m="mawc6o_3"
call rename
call agegroup

import %xlname range="Military"!$AY$4:$AY$75 byrow @freq a {!year} 
%m="mawc6o_4"
call rename
call agegroup

import %xlname range="Military"!$AZ$4:$AZ$75 byrow @freq a {!year} 
%m="mawc6o_5"
call rename
call agegroup

import %xlname range="Military"!$BA$4:$BA$75 byrow @freq a {!year} 
%m="mawc6o_6"
call rename
call agegroup

import %xlname range="Military"!$BB$4:$BB$75 byrow @freq a {!year} 
%m="mawc6o_7"
call rename
call agegroup

import %xlname range="Military"!$BC$4:$BC$75 byrow @freq a {!year} 
%m="mawc6o_8"
call rename
call agegroup

import %xlname range="Military"!$BD$4:$BD$75 byrow @freq a {!year} 
%m="mawc6o_9p"
call rename
call agegroup


	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mawnc18={%v}f{%a}mawc6o_0
	    genr {%v}f{%a}mawc6o1={%v}f{%a}mawc6o_1
 	    genr {%v}f{%a}mawc6o2={%v}f{%a}mawc6o_2
	    genr {%v}f{%a}mawc6o3_={%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p
	    genr {%v}f{%a}mawc6o_3p= {%v}f{%a}mawc6o_3 + {%v}f{%a}mawc6o_4 + {%v}f{%a}mawc6o_5 + {%v}f{%a}mawc6o_6 + _
                                                       {%v}f{%a}mawc6o_7 + {%v}f{%a}mawc6o_8 + {%v}f{%a}mawc6o_9p 
     next

' Females: Divorced 
%s="f"

import %xlname range="Military"!$BF$4:$BF$75 byrow @freq a {!year} 
%m="madc6o_0"
call rename
call agegroup

import %xlname range="Military"!$BG$4:$BG$75 byrow @freq a {!year} 
%m="madc6o_1"
call rename
call agegroup

import %xlname range="Military"!$BH$4:$BH$75 byrow @freq a {!year} 
%m="madc6o_2"
call rename
call agegroup

import %xlname range="Military"!$BI$4:$BI$75 byrow @freq a {!year} 
%m="madc6o_3"
call rename
call agegroup

import %xlname range="Military"!$BJ$4:$BJ$75 byrow @freq a {!year} 
%m="madc6o_4"
call rename
call agegroup

import %xlname range="Military"!$BK$4:$BK$75 byrow @freq a {!year} 
%m="madc6o_5"
call rename
call agegroup

import %xlname range="Military"!$BL$4:$BL$75 byrow @freq a {!year} 
%m="madc6o_6"
call rename
call agegroup

import %xlname range="Military"!$BM$4:$BM$75 byrow @freq a {!year} 
%m="madc6o_7"
call rename
call agegroup

import %xlname range="Military"!$BN$4:$BN$75 byrow @freq a {!year} 
%m="madc6o_8"
call rename
call agegroup

import %xlname range="Military"!$BO$4:$BO$75 byrow @freq a {!year} 
%m="madc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}madnc18={%v}f{%a}madc6o_0
	    genr {%v}f{%a}madc6o1={%v}f{%a}madc6o_1
 	    genr {%v}f{%a}madc6o2={%v}f{%a}madc6o_2
	    genr {%v}f{%a}madc6o3_={%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
	    genr {%v}f{%a}madc6o_3p= {%v}f{%a}madc6o_3 + {%v}f{%a}madc6o_4 + {%v}f{%a}madc6o_5 + {%v}f{%a}madc6o_6 + _
									      {%v}f{%a}madc6o_7 + {%v}f{%a}madc6o_8 + {%v}f{%a}madc6o_9p
      next

' Females: Separated 
%s="f"

import %xlname range="Military"!$BQ$4:$BQ$75 byrow @freq a {!year} 
%m="masc6o_0"
call rename
call agegroup

import %xlname range="Military"!$BR$4:$BR$75 byrow @freq a {!year} 
%m="masc6o_1"
call rename
call agegroup

import %xlname range="Military"!$BS$4:$BS$75 byrow @freq a {!year} 
%m="masc6o_2"
call rename
call agegroup

import %xlname range="Military"!$BT$4:$BT$75 byrow @freq a {!year} 
%m="masc6o_3"
call rename
call agegroup

import %xlname range="Military"!$BU$4:$BU$75 byrow @freq a {!year} 
%m="masc6o_4"
call rename
call agegroup

import %xlname range="Military"!$BV$4:$BV$75 byrow @freq a {!year} 
%m="masc6o_5"
call rename
call agegroup

import %xlname range="Military"!$BW$4:$BW$75 byrow @freq a {!year} 
%m="masc6o_6"
call rename
call agegroup

import %xlname range="Military"!$BX$4:$BX$75 byrow @freq a {!year} 
%m="masc6o_7"
call rename
call agegroup

import %xlname range="Military"!$BY$4:$BY$75 byrow @freq a {!year} 
%m="masc6o_8"
call rename
call agegroup

import %xlname range="Military"!$BZ$4:$BZ$75 byrow @freq a {!year} 
%m="masc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}masnc18={%v}f{%a}masc6o_0
	    genr {%v}f{%a}masc6o1={%v}f{%a}masc6o_1
 	    genr {%v}f{%a}masc6o2={%v}f{%a}masc6o_2
	    genr {%v}f{%a}masc6o3_= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
	    genr {%v}f{%a}masc6o_3p= {%v}f{%a}masc6o_3 + {%v}f{%a}masc6o_4 + {%v}f{%a}masc6o_5 + {%v}f{%a}masc6o_6 + _
 										{%v}f{%a}masc6o_7 + {%v}f{%a}masc6o_8 + {%v}f{%a}masc6o_9p
      next

' Females: Never Married 
%s="f"

import %xlname range="Military"!$CB$4:$CB$75 byrow @freq a {!year} 
%m="mnc6o_0"
call rename
call agegroup

import %xlname range="Military"!$CC$4:$CC$75 byrow @freq a {!year} 
%m="mnc6o_1"
call rename
call agegroup

import %xlname range="Military"!$CD$4:$CD$75 byrow @freq a {!year} 
%m="mnc6o_2"
call rename
call agegroup

import %xlname range="Military"!$CE$4:$CE$75 byrow @freq a {!year} 
%m="mnc6o_3"
call rename
call agegroup

import %xlname range="Military"!$CF$4:$CF$75 byrow @freq a {!year} 
%m="mnc6o_4"
call rename
call agegroup

import %xlname range="Military"!$CG$4:$CG$75 byrow @freq a {!year} 
%m="mnc6o_5"
call rename
call agegroup

import %xlname range="Military"!$CH$4:$CH$75 byrow @freq a {!year} 
%m="mnc6o_6"
call rename
call agegroup

import %xlname range="Military"!$CI$4:$CI$75 byrow @freq a {!year} 
%m="mnc6o_7"
call rename
call agegroup

import %xlname range="Military"!$CJ$4:$CJ$75 byrow @freq a {!year} 
%m="mnc6o_8"
call rename
call agegroup

import %xlname range="Military"!$CK$4:$CK$75 byrow @freq a {!year} 
%m="mnc6o_9p"
call rename
call agegroup

	'Aggregate up categories
	for %a {%agrp}
	    genr {%v}f{%a}mnc6o_3p={%v}f{%a}mnc6o_3 + {%v}f{%a}mnc6o_4 + {%v}f{%a}mnc6o_5 + {%v}f{%a}mnc6o_6 + _
 									   {%v}f{%a}mnc6o_7 + {%v}f{%a}mnc6o_8 + {%v}f{%a}mnc6o_9p
      next


	'Aggregate up categories

	'Aggregate up categories
	for %a {%agrp}
		genr {%v}f{%a}msnc18={%v}f{%a}mcivsc6o_0 + {%v}f{%a}mafsc6o_0 + {%v}f{%a}msac6o_0 
	  	genr {%v}f{%a}msc6o1={%v}f{%a}mcivsc6o_1 + {%v}f{%a}mafsc6o_1 +{%v}f{%a}msac6o_1 
		genr {%v}f{%a}msc6o2={%v}f{%a}mcivsc6o_2 + {%v}f{%a}mafsc6o_2 +{%v}f{%a}msac6o_2
		genr {%v}f{%a}msc6o3_={%v}f{%a}mcivsc6o_3p + {%v}f{%a}mafsc6o_3p +{%v}f{%a}msac6o_3p		
      next

	for %a {%agrp}
		genr {%v}f{%a}manc18={%v}f{%a}madc6o_0 + {%v}f{%a}masc6o_0 + {%v}f{%a}mawc6o_0
		genr {%v}f{%a}mac6o1={%v}f{%a}madc6o_1 + {%v}f{%a}masc6o_1 + {%v}f{%a}mawc6o_1 
		genr {%v}f{%a}mac6o2={%v}f{%a}madc6o_2 + {%v}f{%a}masc6o_2 + {%v}f{%a}mawc6o_2
		genr {%v}f{%a}mac6o3_={%v}f{%a}madc6o_3p + {%v}f{%a}masc6o_3p +{%v}f{%a}mawc6o_3p
     next

	for %a {%agrp}
		genr {%v}f{%a}nmnc18={%v}f{%a}mnc6o_0
		genr {%v}f{%a}nmc6o1={%v}f{%a}mnc6o_1 
		genr {%v}f{%a}nmc6o2={%v}f{%a}mnc6o_2 
		genr {%v}f{%a}nmc6o3_={%v}f{%a}mnc6o_3p 
     next

wfsave(2) %wfname
wfclose %wfname


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


