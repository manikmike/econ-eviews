exec .\setup2
pageselect a
smpl @all

%file = %0

Matrix mat
if (%file <> "") then
   mat.import(type=text) %file
   !dot = @rinstr(%file,".")
   %name = @left(%file, !dot - 1)
   %ext = @right(%file,@len(%file) - !dot)
   if (@lower(%ext) = "alt1" or @lower(%ext) = "alt2" or @lower(%ext) = "alt3") then
      %histfile = %name + ".hist"
   else
      %histfile = %name + ".hist." + %ext
   endif
else
   mat.import(type=text) \\lrserv1\usr\cwp.20\out\mul\cwpopn.alt2
   %histfile = "\\lrserv1\usr\cwp.20\out\mul\cwpopn.hist"
endif

!firstYear = mat(1,1)
!lastYear = mat(mat.@rows,1)
%group = "0t19 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o"

!col = 1
for %g {%group} ""
   !col = !col + 1
   series cem{%g} = 0
   series cef{%g} = 0
   for !year = !firstYear to !lastYear
      smpl {!year} {!year}
      !row = 2 * (!year - !firstYear) + 1
      cem{%g} = mat(!row,!col)
      cef{%g} = mat(!row+1,!col)
   next
next
delete mat

' append historical data
Matrix mat
mat.import(type=text) %histfile
!firstYear = mat(1,1)
!lastYear = mat(mat.@rows,1)

!col = 1
for %g {%group} ""
   !col = !col + 1
   for !year = !firstYear to !lastYear
      smpl {!year} {!year}
      !row = 2 * (!year - !firstYear) + 1
      cem{%g} = mat(!row,!col)
      cef{%g} = mat(!row+1,!col)
   next
next
delete mat

smpl @all


