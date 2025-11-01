' This procedure uses 'raw' annual data from BKDR1 to create annual
' series for HH Survey employment by class of worker in BKDO3.

' These series should be updated before running this procedure
'   1) annual series in list BKL::BLSCLS1 in databank BKDR1
'   2) annual series in list BKL::BLSCLS2 in databank BKDR1

exec .\setup2

dbopen(type=aremos) bkl.bnk
dbopen(type=aremos) bkdr1.bnk
dbopen(type=aremos) bkdo3.bnk

pageselect vars
fetch bkl::blscls1.
fetch bkl::blscls2.
%blscls1 = @lower(blscls1)
%blscls2 = @lower(blscls2)
delete *

pageselect a
%s = @wordq(%blscls1,1)
fetch(db=bkdr1) {%s}
%y1 = @otod(@ifirst({%s}))
%y2 = @otod(@ilast({%s}))
smpl {%y1} {%y2}
delete {%s}

string s1

' Females

genr efnawph = 0
s1 = @wkeep(%blscls1,"ef*nawph")
call sum1(efnawph, s1)

genr efnawg = 0
s1 = @wkeep(%blscls1,"ef*nawg")
call sum1(efnawg, s1)

genr efnawo = 0
s1 = @wkeep(%blscls1,"ef*nawo")
call sum1(efnawo, s1)

genr efnaw = efnawph + efnawg + efnawo

genr efnas = 0
s1 = @wkeep(%blscls1,"ef*nas")
call sum1(efnas, s1)

genr efnau = 0
s1 = @wkeep(%blscls1,"ef*nau")
call sum1(efnau, s1)

genr efna = efnaw + efnas + efnau

genr efaw = 0
s1 = @wkeep(%blscls1,"ef*aw")
call sum1(efaw, s1)

genr efas = 0
call sum2(efas, %blscls1, 113, 120)

genr efau = 0
call sum2(efau, %blscls1, 121, 128)

genr efa = efaw + efas + efau

genr ef = efna + efa

' Males

genr emnawph = 0
s1 = @wkeep(%blscls1,"em*nawph")
call sum1(emnawph, s1)

genr emnawg = 0
s1 = @wkeep(%blscls1,"em*nawg")
call sum1(emnawg, s1)

genr emnawo = 0
s1 = @wkeep(%blscls1,"em*nawo")
call sum1(emnawo, s1)

genr emnaw = emnawph + emnawg + emnawo

genr emnas = 0
s1 = @wkeep(%blscls1,"em*nas")
call sum1(emnas, s1)

genr emnau = 0
s1 = @wkeep(%blscls1,"em*nau")
call sum1(emnau, s1)

genr emna = emnaw + emnas + emnau

genr emaw = 0
s1 = @wkeep(%blscls1,"em*aw")
call sum1(emaw, s1)

genr emas = 0
call sum2(emas, %blscls1, 49, 56)

genr emau = 0
call sum2(emau, %blscls1, 57, 64)

genr ema = emaw + emas + emau

genr em = emna + ema

' Totals

genr enawph = emnawph + efnawph
genr enawg = emnawg + efnawg
genr enawo = emnawo + efnawo
genr enaw = emnaw + efnaw
genr enas = emnas + efnas
genr enau = emnau + efnau
genr ena = emna + efna
genr eaw = emaw + efaw
genr eas = emas + efas
genr eau = emau + efau
genr ea = ema + efa
genr e = em + ef

' Age group 14-15 for females and males

genr ef1415naw = 0
s1 = @wkeep(%blscls2,"ef1415naw*")
call sum1(ef1415naw, s1)

genr ef1415na = ef1415naw + bkdr1::ef1415nas + bkdr1::ef1415nau
genr ef1415a = bkdr1::ef1415aw + bkdr1::ef1415as + bkdr1::ef1415au
genr ef1415 = ef1415na + ef1415a

genr em1415naw = 0
s1 = @wkeep(%blscls2,"em1415naw*")
call sum1(em1415naw, s1)

genr em1415na = em1415naw + bkdr1::em1415nas + bkdr1::em1415nau
genr em1415a = bkdr1::em1415aw + bkdr1::em1415as + bkdr1::em1415au
genr em1415 = em1415na + em1415a

genr e1415 = em1415 + ef1415

delete s1

store(db=bkdo3) *
delete *

close @db

' Series output is the sum of the series named in the string subset
subroutine sum1(series output, string subset)

   for %s {subset}
      output = output + bkdr1::{%s}
   next

endsub

' Series output is the sum of named series elements !m through !n in the string %input 
subroutine sum2(series output, string %input, scalar !m, scalar !n)

   for !i = !m to !n
      %s = @wordq(%input, !i)
      output = output + bkdr1::{%s}
   next

endsub
