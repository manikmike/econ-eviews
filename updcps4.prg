' This program copies data from a raw CPS databank, alters and
' stores it in an operational CPS databank.  It also aggregates,
' renames and changes magnitudes.

!year = 2024 ' last year of updated data (default)

' Use first argument of program call to override default year
if (%0 <> "") then
   !year = @val(%0)
endif

!yr1 = 1968
!yr2 = !year

%rbank = "cpsr" + @str(!yr1 - 1900) + @str(!yr2 - 1900) ' raw workfile
%obank = "cpso" + @str(!yr1 - 1900) + @str(!yr2 - 1900) ' operational workfile

exec .\setup2
logmode logmsg
pageselect a
smpl {!yr1} {!yr2}

'dbopen(type=aremos) {%rbank}.bnk
wfopen {%rbank}.wf1
wfselect work
pageselect a

%l1  = "n l"
%l2  = "m f"
%l3a = "1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 " + _
       "5559 6061 6264 6569 7074 7579 8084 85o"
%l3b = "1619 2534 3544 4554 6064 5564 65o 55o 16o"
%l4  = "nm ms ma"
%l5  = "c6u nc6 c6o nc18"
%l6  = "1 2 3&"

' This section copies, aggregates and changes magnitudes for population
' and civilian labor force data from raw databank

logmsg
logmsg Copying, aggregating and changing magnitudes
logmsg  - Females by age, marital status and child presence

for %a n l
   for %d nm ms ma
      for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
         for %e c6u nc6 c6o nc18
            if (%e = "c6u") then
               for %f 1 2
                  'series {%a}f{%c}{%d}{%e}{%f} = {%rbank}::{%a}f{%c}{%d}{%e}{%f} / 1000000
						copy {%rbank}::a\{%a}f{%c}{%d}{%e}{%f} a\temp
						series {%a}f{%c}{%d}{%e}{%f} = temp / 1000000
						delete a\temp
               next 'f
               ' EViews doesn't allow '&' character in object names, so use "_" instead
               'copy {%rbank}::{%a}f{%c}{%d}{%e}3&.a temp
					copy {%rbank}::a\{%a}f{%c}{%d}{%e}3_ a\temp
               series {%a}f{%c}{%d}{%e}3_ = temp / 1000000
               delete a\temp
               series {%a}f{%c}{%d}{%e} = {%a}f{%c}{%d}{%e}1 + {%a}f{%c}{%d}{%e}2 + _
                                          {%a}f{%c}{%d}{%e}3_
            else
               'series {%a}f{%c}{%d}{%e} = {%rbank}::a\{%a}f{%c}{%d}{%e} / 1000000
					copy {%rbank}::a\{%a}f{%c}{%d}{%e} a\temp
					series {%a}f{%c}{%d}{%e} = temp / 1000000
					delete a\temp
               ' logmsg {%a}f{%c}{%d}{%e} = {%a}f{%c}{%d}{%e}1 + {%a}f{%c}{%d}{%e}2 + {%a}f{%c}{%d}{%e}3_
               ' logmsg {%a}f{%c}{%d}{%e} = {%rbank}::{%a}f{%c}{%d}{%e} / 1000000
            endif
         next 'e
         series {%a}f{%c}{%d} = {%a}f{%c}{%d}c6u + {%a}f{%c}{%d}nc6
      next 'c
      for %c 5559 6061 6264 6569 7074 7579 8084 85o
         'series {%a}f{%c}{%d} = ({%rbank}::a\{%a}f{%c}{%d}c6u + {%rbank}::a\{%a}f{%c}{%d}nc6) / 1000000
			copy {%rbank}::a\{%a}f{%c}{%d}c6u a\temp1
			copy {%rbank}::a\{%a}f{%c}{%d}nc6 a\temp2
			series {%a}f{%c}{%d} = (temp1 + temp2) /1000000
			delete a\temp1
			delete a\temp2
      next ' local c
   next 'd
next 'a

logmsg  - Broader age groups

for %a n l
   for %d nm ms ma
      for %e c6u nc6 c6o nc18
         series {%a}f1619{%d}{%e} = {%a}f1617{%d}{%e} + {%a}f1819{%d}{%e}
         series {%a}f2534{%d}{%e} = {%a}f2529{%d}{%e} + {%a}f3034{%d}{%e}
         series {%a}f3544{%d}{%e} = {%a}f3539{%d}{%e} + {%a}f4044{%d}{%e}
         series {%a}f4554{%d}{%e} = {%a}f4549{%d}{%e} + {%a}f5054{%d}{%e}
      next
      for %f 1 2 3_
         series {%a}f1619{%d}c6u{%f} = {%a}f1617{%d}c6u{%f} + {%a}f1819{%d}c6u{%f}
         series {%a}f2534{%d}c6u{%f} = {%a}f2529{%d}c6u{%f} + {%a}f3034{%d}c6u{%f}
         series {%a}f3544{%d}c6u{%f} = {%a}f3539{%d}c6u{%f} + {%a}f4044{%d}c6u{%f}
         series {%a}f4554{%d}c6u{%f} = {%a}f4549{%d}c6u{%f} + {%a}f5054{%d}c6u{%f}
      next
   next
next


logmsg  - Male and female by marital status and by age

for %a n l
   for %b m f
      for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
         for %d nm ms ma
            if (%b = "m") then
               if (%a = "l") then
                  'series {%a}{%b}{%c}{%d} = {%rbank}::{%a}{%b}{%c}{%d}/1000000
						copy {%rbank}::a\{%a}{%b}{%c}{%d} a\temp
						series {%a}{%b}{%c}{%d} = temp / 1000000
						delete a\temp
               else
                  ' Note:: CPS Labor force data for males includes military before 1988
                  ' Next section removes military so that all N*.* series are
                  ' defined as civilian noninstitutional population.

                  smpl {!yr1} 1988
                  'series {%a}{%b}{%c}{%d} = {%rbank}::{%a}{%b}{%c}{%d} / 1000000 - _
                                          '{%rbank}::m{%b}{%c}{%d} / 1000000
						copy {%rbank}::a\{%a}{%b}{%c}{%d} a\temp1
						copy {%rbank}::a\m{%b}{%c}{%d} a\temp2
						series {%a}{%b}{%c}{%d} = (temp1 / 1000000) - (temp2 / 1000000)
						delete a\temp1
						delete a\temp2
                  smpl 1989 {!yr2}
                  'series {%a}{%b}{%c}{%d} = {%rbank}::{%a}{%b}{%c}{%d} / 1000000
						copy {%rbank}::a\{%a}{%b}{%c}{%d} a\temp
						series {%a}{%b}{%c}{%d} = temp / 1000000
						delete a\temp

                  smpl {!yr1} {!yr2}
               endif
            endif

         next
      next
   next
next

' IMPORTANT - Some raw DRI data for noninst. pop. females aged 60
'             and over for 1982 through 1988 is incorrect.  Some
'             corrected values will automatically be entered here.

logmsg  - Corrections to Noninst. Pop. females age 60 and over who are
logmsg    married with spouse present in 1982 through 1988 due to known
logmsg    errors in raw DRI data

smpl 1982 1988
nf6061ms.adjust = 1.599611 1.571303 1.531428 1.545645 1.530892 1.586991 1.577141
nf6264ms.adjust = 2.044828 1.987722 2.141141 2.132148 2.210938 2.181938 2.144627
nf6569ms.adjust = 2.674728 2.699905 2.691289 2.781717 2.832031
nf7074ms.adjust = 1.725746 1.709016 1.785556 1.795117
nf7579ms.adjust = 0.873638 0.977097

smpl {!yr1} {!yr2}
for %a n l
   for %b m f
      for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
         series {%a}{%b}{%c} = {%a}{%b}{%c}nm + {%a}{%b}{%c}ms + {%a}{%b}{%c}ma
      next
   next
next

logmsg  - Broader age groups

for %a n l
   for %b m f
      for %d nm ms ma
         series {%a}{%b}1619{%d} = {%a}{%b}1617{%d} + {%a}{%b}1819{%d}
         series {%a}{%b}2534{%d} = {%a}{%b}2529{%d} + {%a}{%b}3034{%d}
         series {%a}{%b}3544{%d} = {%a}{%b}3539{%d} + {%a}{%b}4044{%d}
         series {%a}{%b}4554{%d} = {%a}{%b}4549{%d} + {%a}{%b}5054{%d}
         series {%a}{%b}6064{%d} = {%a}{%b}6061{%d} + {%a}{%b}6264{%d}
         series {%a}{%b}5564{%d} = {%a}{%b}5559{%d} + {%a}{%b}6064{%d}
         series {%a}{%b}65o{%d}  = {%a}{%b}6569{%d} + {%a}{%b}7074{%d}+{%a}{%b}7579{%d}+ _
                {%a}{%b}8084{%d} + {%a}{%b}85o{%d}
         series {%a}{%b}55o{%d}  = {%a}{%b}5564{%d} + {%a}{%b}65o{%d}
         series {%a}{%b}16o{%d}  = {%a}{%b}1619{%d} + {%a}{%b}2024{%d}+{%a}{%b}2534{%d}+ _
                {%a}{%b}3544{%d} + {%a}{%b}4554{%d} + {%a}{%b}55o{%d}
      next
   next
next

logmsg  - Male and females by broader age groups

for %a n l
   for %b m f
      for %c 1619 2534 3544 4554 6064 5564 65o 55o 16o
         series {%a}{%b}{%c} = {%a}{%b}{%c}nm + {%a}{%b}{%c}ms + {%a}{%b}{%c}ma
      next
   next
next


' Create child present indexes

logmsg
logmsg Creating child present indexes for females by marital status

for %d nm ms ma
   for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054
      series denom = @recode(nf{%c}{%d}c6u <> 0, nf{%c}{%d}c6u, na)
      series if{%c}{%d}c6u = (denom <> 0) * _
         (nf{%c}{%d}c6u1 + nf{%c}{%d}c6u2 * 2 + nf{%c}{%d}c6u3_ * 3) / denom
   next
next


' Calculate civilian labor force participation rates for females

logmsg Creating civilian LFPRs for females

for %d nm ms ma
   for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 1619 2534 3544 4554
      for %e c6u nc6 c6o nc18
         series denom = @recode(nf{%c}{%d}{%e}<>0, nf{%c}{%d}{%e}, na)
         series pf{%c}{%d}{%e} = lf{%c}{%d}{%e} / denom
      next
      for %e c6u
         for %f 1 2 3_
            series denom = @recode(nf{%c}{%d}{%e}{%f}<>0, nf{%c}{%d}{%e}{%f}, na)
            series pf{%c}{%d}{%e}{%f} = lf{%c}{%d}{%e}{%f} / denom
         next
      next
   next
   for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o _
          1619 2534 3544 4554 6064 5564 65o 55o 16o
      series denom = @recode(nf{%c}{%d}<>0, nf{%c}{%d}, na)
      series pf{%c}{%d} = lf{%c}{%d} / denom
   next
next
for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o _
       1619 2534 3544 4554 6064 5564 65o 55o 16o
   series denom = @recode(nf{%c}<>0, nf{%c}, na)
   series pf{%c} = lf{%c} / denom
next
delete denom


logmsg Creating Military data and LFPRs for Males

'dbopen(type=aremos) bkdr1.bnk
wfopen bkdr1.wf1
wfselect work
pageselect a

' Calculate male members of the Armed Forces living off post or
' with their families on post

for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 _
       5559 6061 6264 6569 7074 7579 8084 85o
   for %d nm ms ma
      'series mm{%c}{%d} = {%rbank}::mm{%c}{%d} / 1000000
		copy {%rbank}::a\mm{%c}{%d} a\temp
		series mm{%c}{%d} = temp / 1000000
		delete a\temp
   next
   series mm{%c} = mm{%c}nm + mm{%c}ma + mm{%c}ms
next

for %d nm ms ma
   series mm1619{%d} = mm1617{%d} + mm1819{%d}
   series mm2534{%d} = mm2529{%d} + mm3034{%d}
   series mm3544{%d} = mm3539{%d} + mm4044{%d}
   series mm4554{%d} = mm4549{%d} + mm5054{%d}
   series mm6064{%d} = mm6061{%d} + mm6264{%d}
   series mm5564{%d} = mm5559{%d} + mm6064{%d}
   series  mm65o{%d} = mm6569{%d} + mm7074{%d} + mm7579{%d} + _
                       mm8084{%d} + mm85o{%d}
   series  mm55o{%d} = mm5564{%d} + mm65o{%d}
   series  mm16o{%d} = mm1619{%d} + mm2024{%d} + mm2534{%d} + _
                       mm3544{%d} + mm4554{%d} + mm55o{%d}
next

for %c 1619 2534 3544 4554 6064 5564 65o 55o 16o
   series mm{%c} = mm{%c}nm + mm{%c}ma + mm{%c}ms
next


' This section calculates labor force participation rates for males

' Calculate military population series

'copy bkdr1::nm*m_3.a a\nm*m_3
copy bkdr1::a\nm*m_3 a\nm*m_3

series nm1619m_3 = nm1617m_3 + nm1819m_3
series nm2534m_3 = nm2529m_3 + nm3034m_3
series nm3544m_3 = nm3539m_3 + nm4044m_3
series nm4554m_3 = nm4549m_3 + nm5054m_3
series nm6064m_3 = nm6061m_3 + nm6264m_3
series nm5564m_3 = nm5559m_3 + nm6064m_3
series nm6574m_3 = nm6569m_3 + nm7074m_3
series nm7584m_3 = nm7579m_3 + nm8084m_3
series  nm65om_3 = nm6574m_3 + nm7584m_3 + nm85om_3
series  nm55om_3 = nm5564m_3 + nm65om_3


' Calculate Male LFPRs defined as ratio of lc to (pop + mil)

for %c 2024 2529 3034 3539 4044 4549 5054 2534 3544 4554
   for %d nm ms ma
      if(%d = "nm") then
         series pm{%c}{%d} = lm{%c}{%d} / (nm{%c}{%d} + (nm{%c}m_3 - mm{%c}ms - mm{%c}ma))
         series rmm{%c}{%d} = (nm{%c}m_3 - mm{%c}ms - mm{%c}ma) / (nm{%c}{%d} + (nm{%c}m_3 - mm{%c}ms - mm{%c}ma))
      else
         series pm{%c}{%d} = lm{%c}{%d} / (nm{%c}{%d} + mm{%c}{%d})
         series rmm{%c}{%d} = mm{%c}{%d} / (nm{%c}{%d} + mm{%c}{%d})
     endif
  next
  series pm{%c} = lm{%c} / (nm{%c} + nm{%c}m_3)
  series rmm{%c} = nm{%c}m_3 /(nm{%c} + nm{%c}m_3)
next


' Calculate Civilian Male LFPRs

for %c 1415 1617 1819 5559 6061 6264 6569 7074 7579 8084 85o 1619 6064 5564 65o 55o 16o
   for %d nm ms ma
      series denom = @recode(nm{%c}{%d}<>0, nm{%c}{%d}, na)
      series pm{%c}{%d} = lm{%c}{%d} / denom
   next
   series denom = @recode(nm{%c}<>0, nm{%c}, na)
  series pm{%c} = lm{%c} / denom
next
delete denom
smpl {!yr1} {!yr2}-1
series pm16o = lm16o / (nm16o + nm16om_3)
series pm16onm = lm16onm / (nm16onm +(nm16om_3 - mm16oms - mm16oma))
smpl {!yr1} {!yr2}
series pm16oms = lm16oms / (nm16oms + mm16oms)
series pm16oma = lm16oma / (nm16oma + mm16oma)


' Override some miscellaneous historical values

smpl 2002 2003

nm85o.adjust = 1.160667 1.181333
nf85o.adjust = 2.224400 2.296500

nm8084.adjust = 1.805833 2.064967
nf8084.adjust = 3.051200 3.097600

lm85o.adjust = 0.046863 0.043996
lf85o.adjust = 0.038364 0.043364

lm8084.adjust = 0.119337 0.138004
lf8084.adjust = 0.065136 0.094836

pm85o.adjust = 0.040376 0.037243
pf85o.adjust = 0.017247 0.018883

pm8084.adjust = 0.066084 0.066831
pf8084.adjust = 0.021348 0.030616

smpl {!yr1} {!yr2}


logmsg
logmsg Copying series to {%obank}

'dbopen(type=aremos) {%obank}.bnk
wfopen {%obank}.wf1
wfselect work
pageselect a

copy(o) nm*  {%obank}::a\nm* 
copy(o) lm*  {%obank}::a\lm* 
copy(o) pm*  {%obank}::a\pm* 
copy(o) rmm* {%obank}::a\rmm*
copy(o) mm*  {%obank}::a\mm* 
copy(o) nf*  {%obank}::a\nf* 
copy(o) lf*  {%obank}::a\lf* 
copy(o) pf*  {%obank}::a\pf* 
copy(o) if*  {%obank}::a\if*
'copy(o) *3_  {%obank}::*3&.a
copy(o) *3_  {%obank}::a\*3_


' Presence of children ratios

smpl {!yr1} {!yr2}
'dbopen(type=aremos) {%obank}.bnk
'wfopen {%obank}.wf1
'dbopen(type=aremos) {%rbank}.bnk
'wfopen {%rbank}.wf1

wfselect work
pageselect a

logmsg
logmsg Creating child present ratios for females

for %c 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
   'copy {%obank}::nf{%c} denom
	 copy {%obank}::a\nf{%c} denom

   denom = @recode(denom<>0, denom, na)
   'series rf{%c}c6u = ({%obank}::nf{%c}nmc6u + {%obank}::nf{%c}msc6u + {%obank}::nf{%c}mac6u) / denom
	copy {%obank}::a\nf{%c}nmc6u a\temp1
	copy {%obank}::a\nf{%c}msc6u a\temp2
	copy {%obank}::a\nf{%c}mac6u a\temp3
	series rf{%c}c6u = (temp1 + temp2 + temp3) / denom
	delete a\temp1
	delete a\temp2
	delete a\temp3

   'series rf{%c}c617 = ({%obank}::nf{%c}nmc6o + {%obank}::nf{%c}msc6o + {%obank}::nf{%c}mac6o) / denom
	copy {%obank}::a\nf{%c}nmc6o a\temp1
	copy {%obank}::a\nf{%c}msc6o a\temp2
	copy {%obank}::a\nf{%c}mac6o a\temp3
	series rf{%c}c617 = (temp1 + temp2 + temp3) / denom
	delete a\temp1
	delete a\temp2
	delete a\temp3

   'series rf{%c}c6ur  = ({%rbank}::nf{%c}nmc6u + {%rbank}::nf{%c}msc6u + {%rbank}::nf{%c}mac6u) / (denom * 1000000)
	copy {%rbank}::a\nf{%c}nmc6u a\temp1
	copy {%rbank}::a\nf{%c}msc6u a\temp2
	copy {%rbank}::a\nf{%c}mac6u a\temp3
	series rf{%c}c6ur  = (temp1 + temp2 + temp3) / (denom * 1000000)
	delete a\temp1
	delete a\temp2
	delete a\temp3

   'series rf{%c}c617r = ({%rbank}::nf{%c}nmc6o + {%rbank}::nf{%c}msc6o + {%rbank}::nf{%c}mac6o) / (denom * 1000000)
	copy {%rbank}::a\nf{%c}nmc6o a\temp1
	copy {%rbank}::a\nf{%c}msc6o a\temp2
	copy {%rbank}::a\nf{%c}mac6o a\temp3
	series rf{%c}c617r = (temp1 + temp2 + temp3) / (denom * 1000000)
	delete a\temp1
	delete a\temp2
	delete a\temp3
   delete denom
next

copy(o) rf* {%obank}::a\rf*


delete *

wfselect {%obank}
pageselect a
wfsave {%obank}.wf1

close @wf

logmsg
logmsg Procedure Finished


