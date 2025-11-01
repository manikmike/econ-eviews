' This program exports series needed for the bkdr1 COW Check
' to an Excel spreadsheet
' The Excel spreadsheet compares the raw data from BLS to the data in bkdr1 to confirm that
' it was properly placed in the bkdr1 databank.
' Bob Weathers, 1-0502017

'FOR EVERY RUN  -- adjust 
'							%FILENAME 
'							!checkyr
'This program points to bkdr1.bnk in E:\usr\econ\EcoDev\dat\ . Make sure the latest version of bkdr1 is used. 
'Polina Vlasenko 11-30-2017

' updated to TR2019 file locations -- PV 11-20-2018
' updated to TR2021 locations -- PV 06-17-2021
' updated to TR2023 locations -- SL 11-18-2022

'	!!!!!		MAKE SURE correct location is used for bkdr1 bank on line 83	!!!!


exec .\setup2

%FILENAME = "S:\LRECON\TrusteesReports\TR2023\Checks\COW_check\Check of COW_raw bkdr1.xlsx"  ' path to file to store extracted data
!checkyr=2021 'the year of data that needs to be ckecked

pageselect a
smpl !checkyr !checkyr

%l_name0 = "em1617aw em1617as em1617au em1617nawo em1617nawph em1617nawg em1617nas em1617nau " + _
           "em1819aw em1819as em1819au em1819nawo em1819nawph em1819nawg em1819nas em1819nau " + _
           "em2024aw em2024as em2024au em2024nawo em2024nawph em2024nawg em2024nas em2024nau " + _
           "em2534aw em2534as em2534au em2534nawo em2534nawph em2534nawg em2534nas em2534nau " + _
           "em3544aw em3544as em3544au em3544nawo em3544nawph em3544nawg em3544nas em3544nau " + _
           "em4554aw em4554as em4554au em4554nawo em4554nawph em4554nawg em4554nas em4554nau " + _
           "em5564aw em5564as em5564au em5564nawo em5564nawph em5564nawg em5564nas em5564nau " + _
           "em65Oaw em65Oas em65Oau em65Onawo em65Onawph em65Onawg em65Onas em65Onau " + _
           "em6569aw em6569as em6569au em6569nawo em6569nawph em6569nawg em6569nas em6569nau " + _
           "em7074aw em7074as em7074au em7074nawo em7074nawph em7074nawg em7074nas em7074nau " + _
		"em75Oaw em75Oas em75Oau em75Onawo em75Onawph em75Onawg em75Onas em75Onau " + _
		"ef1617aw ef1617as ef1617au ef1617nawo ef1617nawph ef1617nawg ef1617nas ef1617nau " + _
           "ef1819aw ef1819as ef1819au ef1819nawo ef1819nawph ef1819nawg ef1819nas ef1819nau " + _
           "ef2024aw ef2024as ef2024au ef2024nawo ef2024nawph ef2024nawg ef2024nas ef2024nau " + _
           "ef2534aw ef2534as ef2534au ef2534nawo ef2534nawph ef2534nawg ef2534nas ef2534nau " + _
           "ef3544aw ef3544as ef3544au ef3544nawo ef3544nawph ef3544nawg ef3544nas ef3544nau " + _
           "ef4554aw ef4554as ef4554au ef4554nawo ef4554nawph ef4554nawg ef4554nas ef4554nau " + _
           "ef5564aw ef5564as ef5564au ef5564nawo ef5564nawph ef5564nawg ef5564nas ef5564nau " + _
           "ef65Oaw ef65Oas ef65Oau ef65Onawo ef65Onawph ef65Onawg ef65Onas ef65Onau " + _
           "ef6569aw ef6569as ef6569au ef6569nawo ef6569nawph ef6569nawg ef6569nas ef6569nau " + _
           "ef7074aw ef7074as ef7074au ef7074nawo ef7074nawph ef7074nawg ef7074nas ef7074nau " + _
		"ef75Oaw ef75Oas ef75Oau ef75Onawo ef75Onawph ef75Onawg ef75Onas ef75Onau"

   %db_name0 = "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
		 "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 " + _
            "bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1 bkdr1"


call getseries(100, %db_name0, %l_name0, "raw_blscow!a11")


subroutine getseries(scalar !n, string %database, string %series, string %range)

   %list = @winterleave(%database, %series)
   for %db %s {%list}
     !n = !n + 1
     dbopen C:\Users\886079\GitRepos\econ-ecodev\dat\{%db}.bnk		'MAKE sure this location is correct!!!
     genr _{!n}_{%s} = {%db}::{%s}
   next
   close @db
   pagesave(type=excelxml, mode=update) %FILENAME range=%range @smpl !checkyr !checkyr
   delete *

endsub


