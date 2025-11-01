' This program is called by cmpdexcel.prg to gather historical data for the
' Long-Range Assumptions Memo tables  - Unemployment Section, with no military
' Base year is set to 2011 for the 2022 Trustees Report
' Base year is set to 2020 for the 2024 Trustees Report

!TRYEAR = @val(%0) ' Trustees Report year passed as parameter (e.g., 2023)

!yr2 = !TRYEAR - 2 ' Last year of historical data (e.g., 2021)

!baseyr = 2020
!fuyr = 1959

%sex1 = "m f t"
%age1 = "1619 2024 2534 3544 4554 5564"
%age2 = "2529 3034 3539 4044 4549 5054 5559 6064"
%age3 = "6064 6569 70o"

smpl 1951 {!yr2}


for %s m f
   for %a {%age1}
      if (%a = "1619") then
         series l{%s}{%a} = l{%s}1617 + l{%s}1819
         series u{%s}{%a} = l{%s}1617 * r{%s}1617 / 100 + l{%s}1819 * r{%s}1819 / 100
         series e{%s}{%a} = (1 - r{%s}1617 / 100) * l{%s}1617 + (1-r{%s}1819 / 100) * l{%s}1819
         series r{%s}{%a} = u{%s}{%a} / l{%s}{%a} * 100
      else
      if (%a = "2024") then
         series l{%s}{%a} = l{%s}{%a}
         series u{%s}{%a} = l{%s}{%a} * (r{%s}{%a} / 100)
         series e{%s}{%a} = (1 - r{%s}{%a} / 100) * l{%s}{%a}
         series r{%s}{%a} = u{%s}{%a} / l{%s}{%a} * 100
      else
         series l{%s}{%a} = l{%s}{%a}
         series u{%s}{%a} = l{%s}{%a} * (r{%s}{%a} / 100)
         series e{%s}{%a} = (1 - r{%s}{%a} / 100) * l{%s}{%a}
     endif
     endif
   next
next

for %s m f
   for %a {%age2}
      smpl 1959 {!yr2}
      series l{%s}{%a} = l{%s}{%a}
      smpl 1977 {!yr2}
      series u{%s}{%a} = l{%s}{%a} * (r{%s}{%a} / 100)
      series e{%s}{%a} = (1 - r{%s}{%a} / 100) * l{%s}{%a}
      series r{%s}{%a} = u{%s}{%a} / l{%s}{%a} * 100
   next
next

smpl 1959 {!yr2}
for %s m f
   series u{%s}2534 = (l{%s}2529 + l{%s}3034) * r{%s}2534 / 100
   series u{%s}3544 = (l{%s}3539 + l{%s}4044) * r{%s}3544 / 100
   series u{%s}4554 = (l{%s}4549 + l{%s}5054) * r{%s}4554 / 100
   series u{%s}5564 = (l{%s}5559 + l{%s}6064) * r{%s}5564 / 100
   series e{%s}2534 = (1 - r{%s}2534 / 100) * (l{%s}2529 + l{%s}3034)
   series e{%s}3544 = (1 - r{%s}3544 / 100) * (l{%s}3539 + l{%s}4044)
   series e{%s}4554 = (1 - r{%s}4554 / 100) * (l{%s}4549 + l{%s}5054)
   series e{%s}5564 = (1 - r{%s}5564 / 100) * (l{%s}5559 + l{%s}6064)
next

smpl 1951 {!yr2}
for %s m f
   for %a 2534 3544 4554 5564
      series r{%s}{%a} = u{%s}{%a} / l{%s}{%a} *100
   next
next

for %s m f
   smpl 1959 {!yr2}
   series r{%s}2534 = u{%s}2534 / (l{%s}2529 + l{%s}3034) * 100
   series r{%s}3544 = u{%s}3544 / (l{%s}3539 + l{%s}4044) * 100
   series r{%s}4554 = u{%s}4554 / (l{%s}4549 + l{%s}5054) * 100
   series r{%s}5564 = u{%s}5564 / (l{%s}5559 + l{%s}6064) * 100
   smpl 1951 {!yr2}
   series l{%s}65o = l{%s}65o
   series u{%s}65o = (r{%s}65o / 100) * l{%s}65o
   series e{%s}65o = (1 - r{%s}65o / 100) * l{%s}65o
   series r{%s}65o = u{%s}65o / l{%s}65o *100
next

smpl 1981 {!yr2}
for %s m f
   for %a 6569 70o
      series l{%s}{%a} = l{%s}{%a}
      series u{%s}{%a} = (r{%s}{%a} / 100) * l{%s}{%a}
      series e{%s}{%a} = (1 - r{%s}{%a} / 100) * l{%s}{%a}
      series r{%s}{%a} = u{%s}{%a} / l{%s}{%a} * 100
   next
next

smpl 1951 {!yr2}
for %a 1619 2024 2534 3544 4554 5564 65o
  series lt{%a} = lm{%a} + lf{%a}
  series et{%a} = em{%a} + ef{%a}
  series ut{%a} = um{%a} + uf{%a}
  series rt{%a} = ut{%a} / lt{%a} * 100
next

smpl 1977 {!yr2}
for %a 2529 3034 3539 4044 4549 5054 5559 6064
  series lt{%a} = lm{%a} + lf{%a}
  series et{%a} = em{%a} + ef{%a}
  series ut{%a} = um{%a} + uf{%a}
  series rt{%a} = ut{%a} / lt{%a} * 100
next

smpl 1981 {!yr2}
for %a 6569 70o
  series lt{%a} = lm{%a} + lf{%a}
  series et{%a} = em{%a} + ef{%a}
  series ut{%a} = um{%a} + uf{%a}
  series rt{%a} = ut{%a} / lt{%a} * 100
next

for %s {%sex1}
   for %t l u e

   smpl 1951 {!yr2}
   series {%t}{%s}totl = {%t}{%s}1619 + {%t}{%s}2024 + {%t}{%s}2534 + {%t}{%s}3544 + _
                         {%t}{%s}4554 + {%t}{%s}5564 + {%t}{%s}65o
   
   smpl 1977 {!yr2}
   series {%t}{%s}totl = {%t}{%s}1619 + {%t}{%s}2024 + {%t}{%s}2529 + {%t}{%s}3034 + _
                         {%t}{%s}3539 + {%t}{%s}4044 + {%t}{%s}4549 + {%t}{%s}5054 + _
                         {%t}{%s}5559 + {%t}{%s}6064 + {%t}{%s}65o
   
   smpl 1981 {!yr2}
   series {%t}{%s}totl = {%t}{%s}1619 + {%t}{%s}2024 + {%t}{%s}2529 + {%t}{%s}3034 + _
                         {%t}{%s}3539 + {%t}{%s}4044 + {%t}{%s}4549 + {%t}{%s}5054 + _
                         {%t}{%s}5559 + {%t}{%s}6064 + {%t}{%s}6569 + {%t}{%s}70o
   
   next
next


smpl 1951 {!yr2}
for %s {%sex1}
   series r{%s}totl = u{%s}totl / l{%s}totl * 100


   series r{%s}agea = (r{%s}1619 / 100 * @elem(l{%s}1619,{!baseyr}) + _
                       r{%s}2024 / 100 * @elem(l{%s}2024,{!baseyr}) + _
                       r{%s}2534 / 100 * @elem(l{%s}2534,{!baseyr}) + _
                       r{%s}3544 / 100 * @elem(l{%s}3544,{!baseyr}) + _
                       r{%s}4554 / 100 * @elem(l{%s}4554,{!baseyr}) + _
                       r{%s}5564 / 100 * @elem(l{%s}5564,{!baseyr}) + _
                       r{%s}65o  / 100 * @elem(l{%s}65o,{!baseyr})) / _
                      @elem(l{%s}totl,{!baseyr}) * 100
next

smpl 1947 {!yr2}

for %v rttotl rtagea
   smpl {!fuyr} {!yr2}
   for %i 1 5 10 15 20 25 30 35 40
      !start = {!fuyr} + @val(%i)
      for !j = {!start} to {!yr2}
         series {%v}{%i} = @movav({%v},{%i})
      next
   next
next


