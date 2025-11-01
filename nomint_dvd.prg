
' run this program after running the adjustments program nomint...tradj.prg '

' this program creates monthly interest rates with the rates rounded to the nearest 1/8 '
' for projection years 11 through first year that ends in multiple of 5 such as 2030 '

pageselect Monthly

smpl 1937m1 2100m12

series nomintr2dvd = nomintr2
series nomintr1dvd = nomintr1
series nomintr3dvd = nomintr3

smpl 2033m1 2035m12
series nomintr2dvd = @round(nomintr2*8)/8
series nomintr1dvd = @round(nomintr1*8)/8
series nomintr3dvd = @round(nomintr3*8)/8

smpl 2033m1 2033m1
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2033m2 2033m2
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2033m5 2033m5
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2033m8 2033m8
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2033m11 2033m11
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2033m3 2033m3
series nomintr3dvd = 3.5

smpl 2033m9 2033m9
series nomintr3dvd = 3.5


smpl 2034m1 2034m1
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2034m2 2034m2
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2034m5 2034m5
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2034m8 2034m8
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2034m11 2034m11
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2034m3 2034m3
series nomintr3dvd = 3.5

smpl 2034m9 2034m9
series nomintr3dvd = 3.5


smpl 2035m1 2035m1
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2035m2 2035m2
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2035m5 2035m5
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2035m8 2035m8
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2035m11 2035m11
series nomintr2dvd = 4.625
series nomintr1dvd = 5.875

smpl 2035m3 2035m3
series nomintr3dvd = 3.5

smpl 2035m9 2035m9
series nomintr3dvd = 3.5


'smpl 2035m1 2035m1
'series nomintr2dvd = 4.625
'series nomintr1dvd = 5.875
'
'smpl 2035m2 2035m2
'series nomintr2dvd = 4.625
'series nomintr1dvd = 5.875
'
'smpl 2035m5 2035m5
'series nomintr2dvd = 4.625
'series nomintr1dvd = 5.875
'
'smpl 2035m8 2035m8
'series nomintr2dvd = 4.625
'series nomintr1dvd = 5.875
'
'smpl 2035m11 2035m11
'series nomintr2dvd = 4.625
'series nomintr1dvd = 5.875
'
'smpl 2035m3 2035m3
'series nomintr3dvd = 3.5
'
'smpl 2035m9 2035m9
'series nomintr3dvd = 3.5


smpl 1937m1 2100m12
' dump out historical and projected series for 3 alts with rounded rates for first 15 yrs of proj period '
group groupy nomintr2dvd nomintr1dvd nomintr3dvd
groupy.sheet
freeze(output2) groupy.sheet
' if get error about output1 already exists, delete it in workfile before running program '
' output2.save(t=csv) e:\usr\awcheng\eviews3\nomint2022trdvd '


