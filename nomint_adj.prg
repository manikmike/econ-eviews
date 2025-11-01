' the first section commented out was from last year and is not used because we will not have the Jan values at '
' the time we do the interest rate run '
' pageselect Quarterly '
' smpl 2015q1 2015q1 '
' series nomint2 = nomint2 + 0.0833 '
' series nomint1 = nomint1 + 0.0417 '
' series nomint3 = nomint3 + 0.1667 '

' Years updated. Updated rates after trustees agree on ult cpi!!!!!! '
pageselect Monthly
smpl 2022m10 2022m12
series nomintr1 = nomint
series nomintr2 = nomint
series nomintr3 = nomint

' this part commented out as is done in the regular program already '
' smpl 2017m1 2026m12 '
' series nomintr1 = @round(nomint1*8)/8 '
' series nomintr2 = @round(nomint2*8)/8 '
' series nomintr3 = @round(nomint3*8)/8 '

' put in values in 10th projection year if ultimate is reached to ensure the average '
' of the rounded rates is very close to the ultimate '

smpl 2032m1 2032m1
series nomintr2 = 4.625
series nomintr1 = 5.875

smpl 2032m2 2032m2
series nomintr2 = 4.625
series nomintr1 = 5.875

smpl 2032m5 2032m5
series nomintr2 = 4.625
series nomintr1 = 5.875

smpl 2032m8 2032m8
series nomintr2 = 4.625
series nomintr1 = 5.875

smpl 2032m11 2032m11
series nomintr2 = 4.625
series nomintr1 = 5.875

smpl 2032m3 2032m3
series nomintr3 = 3.5

smpl 2032m9 2032m9
series nomintr3 = 3.5

' add line to set nomintr3 for alt 3 to 3.625 very month during the 12 month period from 2028m3 to 2029m2 '
' otherwise the interest rate may overshoot the ultimate '
'smpl 2031m3 2032m2
'series nomintr3 = 3.625

pageselect Quarterly
smpl 2023q1 2032q4
copy(link, c=a) Monthly\nomintr1*
copy(link, c=a) Monthly\nomintr2*
copy(link, c=a) Monthly\nomintr3*

pageselect Annual
smpl 2023 2032
copy(link, c=a) Monthly\nomintr1*
copy(link, c=a) Monthly\nomintr2*
copy(link, c=a) Monthly\nomintr3*


pageselect Monthly
' append historical monthly rates to projected series '
smpl 1937m1 2021m12
series nomintr2 = nomint
series nomintr1 = nomint
series nomintr3 = nomint

smpl 1937m1 2100m12
' dump out historical and projected series for 3 alts '
group groupx nomintr2 nomintr1 nomintr3
groupx.sheet
freeze(output1) groupx.sheet
' if get error about output1 already exists, delete it in workfile before running program '
' output1.save(t=csv) e:\usr\awcheng\eviews3\nomint2022trout '
smpl 2022q4 2032q4

