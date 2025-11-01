
' datel and dateml are end of short range period for TR '
' begin quarterly period 2 years before TR year '
' begin monthly period october in year before TR year '

pageselect Monthly
string datemf = "2022m10" 'first month of TR projection
string dateml = "2032m12" 'last month of SR
string datemflr = "2033m1" 'first month of LR
string datemllr = "2100m12" 'last month of LR
string datemfh = "1937m1" 'first month of historical data
string datemlh = "2022m12" 'last month of historical data
string datemvf = "2021m1" 'first month of the sample set at the end for easy review

pageselect Quarterly
string datef = "2021q1" 'first quarter of estimation
string datel = "2032q4" 'last quarter of SR
string datefpq = "2022q4" 'first quarter of TR projection

' create some adjustment factors '
for !j = 0 to 3
  smpl {datef}+8+!j {datef}+8+!j
  series adje = 0.75 - ( !j * 0.25 )
  series adjf = 0.75 - adje
next

smpl {datef}+12 {datef}+47
series adjf = 1

smpl {datef}+8 {datef}+11
series ltt = 0

for !j = 1 to 36
  smpl {datef}+11+!j {datef}+11+!j
  series ltt = ltt(-1) + 0.25
next


' set period to go from datef to datel '
smpl {datef} {datel}

series ultryld1 = 2.8
series ultcpiw1 = 3.0 
series ultnomint1 = (((1+ultryld1/100)*(1+ultcpiw1/100))^0.5)*200-200
series ultryld2 = 2.3
series ultcpiw2 = 2.4
series ultnomint2 = (((1+ultryld2/100)*(1+ultcpiw2/100))^0.5)*200-200
series ultryld3 = 1.8
series ultcpiw3 = 1.8
series ultnomint3 = (((1+ultryld3/100)*(1+ultcpiw3/100))^0.5)*200-200

series qaltadj1 = 0.25
series qaltadj2 = 0
series qaltadj3 = -0.25

series k1 = -1.461724
series k2 = -1.589918
series k3 = -1.654821

for !a = 1 to 3
  smpl {datef} {datel} 
  series pcpiw{!a} = ((cpiw{!a} / cpiw{!a}(-4)) - 1) * 100
  series prtp{!a} = ((rtp{!a} / rtp{!a}(-4)) - 1) * 100
   
  smpl {datef}+4 {datel}
  series nomint!a = pcpiw!a + 0.5*prtp!a + k!a
  series qx!a = nomint!a
  ' set period to last historical period which is quarter before TR year '
  smpl {datef}+7 {datef}+7
  series inerr!a = nomint - nomint!a
   
  ' set period to projection period from TR year q1 to q4 of tenth year eg datef+8 = 2015q1 for 2015TR '
  smpl {datef}+8 {datel}
  for !j = 1 to 40
    smpl {datef}+7+!j {datef}+7+!j
    series inerr!a = inerr!a(-{!j})
  next
  smpl {datef}+7 {datef}+7
  series nomint!a = nomint!a + inerr!a
   
  
  smpl {datef}+8 {datef}+11
  series nomint!a = nomint!a + inerr!a * adje
  series qyy!a = nomint!a
  smpl {datef}+7 {datel}
  series maltadj!a = qaltadj!a * adjf
  series nomint!a = nomint!a + maltadj!a
  series qyz!a = nomint!a
  
  
  series nltt = 9 * (1 - (1 - ltt/9)^2)
  for !j = 0 to 40
    smpl {datel}-!j {datel}-!j
    series nomendest!a = nomint!a({!j})
  next
  smpl {datef}+8 {datel}
  series nomint!a = nomint!a - (nomendest!a - ultnomint!a) * nltt/9
  series qyzz!a = nomint!a
  ' ***when testing without the adjustment comment the line below out '
  series nomint!a = nomint!a + intadjust!a 
next
' need a different set of addfactors for alt 3 above for intadjust '
' set projected series for most recent historical quarter of data to historical series
smpl {datefpq} {datefpq}
series nomint1 = nomint
series nomint2 = nomint
series nomint3 = nomint

smpl {datef}+7 {datel}
pageselect Monthly

smpl {datemf} {dateml}
copy(c=dentona) Quarterly\nomint1*
copy(c=dentona) Quarterly\nomint2*
copy(c=dentona) Quarterly\nomint3*

' smpl {datemf} {dateml} '
series nomintr1 = @round(nomint1*8)/8
series nomintr2 = @round(nomint2*8)/8
series nomintr3 = @round(nomint3*8)/8

'overwrite historical months with actual interest rates
smpl {datemfh} {datemlh}
for !a = 1 to 3
  series nomintr{!a} = nomint
next

' put in rates for long range period '
' smpl 2032m1 2100m12 '
smpl {datemflr} {datemllr} 
series nomintr1 = 5.799903
series nomintr2 = 4.699976
series nomintr3 = 3.60000

'for easier viewing of results
smpl {datemvf} {dateml}


