exec .\setup2
pageselect a
smpl @all

%file = %0

%loAge =  "0 20 25 30 35 40 45 50 55 60 65 70"
%hiAge = "19 24 29 34 39 44 49 54 59 64 69 100"

Matrix mat
if (%file <> "") then
   mat.import(type=text) %file
   !dot = @rinstr(%file,".")
   %name = @left(%file, !dot - 1)
   %ext = @right(%file, @len(%file) - !dot)
   if (@lower(%ext) = "alt1" or @lower(%ext) = "alt2" or @lower(%ext) = "alt3") then
      %histfile = %name + ".hist"
   else
      %histfile = %name + ".hist." + %ext
   endif
   %histfile = @replace(%histfile,"\Pop\","\Hist\")
else
   mat.import(type=text) \\lrserv1\usr\dem.20\Pop\out\mul\PopJul.alt2
   %histfile = "\\lrserv1\usr\dem.20\Hist\out\mul\PopJul.hist"
endif
!firstYear = mat(2,1)
!lastYear = mat(mat.@rows,1)

!col = 2
for !a = 0 to 100
   !col = !col + 1
   series nm{!a} = 0
   series nf{!a} = 0
   for !year = !firstYear to !lastYear
      smpl {!year} {!year}
      !row = 2 * (!year - !firstYear) + 2
      nm{!a} = mat(!row,!col)
      nf{!a} = mat(!row+1,!col)
   next
next
delete mat

'append historical data
Matrix mat
mat.import(type=text) %histfile
!firstYear = mat(2,1)
!lastYear = mat(mat.@rows,1)

!col = 2
for !a = 0 to 100
   !col = !col + 1
   for !year = !firstYear to !lastYear
      smpl {!year} {!year}
      !row = 2 * (!year - !firstYear) + 2
      nm{!a} = mat(!row,!col)
      nf{!a} = mat(!row+1,!col)
   next
next
delete mat

' derive the age groups by summing single-year of ages
smpl @all
series nm = 0
series nf = 0
!numGroups = @wcount(%loAge)
for !g = 1 to !numGroups
   !lo = @val(@word(%loAge,!g))
   !hi = @val(@word(%hiAge,!g))
   series nm{!lo}{!hi} = 0
   series nf{!lo}{!hi} = 0
   for !a = !lo to !hi
      nm{!lo}{!hi} = nm{!lo}{!hi} + nm{!a}
      nf{!lo}{!hi} = nf{!lo}{!hi} + nf{!a}
      delete nm{!a} nf{!a}
   next
   nm = nm + nm{!lo}{!hi}
   nf = nf + nf{!lo}{!hi}
next

rename nm019 nm0t19
rename nf019 nf0t19
rename nm70100 nm70o
rename nf70100 nf70o

