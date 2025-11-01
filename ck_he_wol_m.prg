' This program ensures that the Old World mnemonic TESL_N_N_HI and
'                           the New World mnemonic HE_WOL_M match

' NOTE: It is assumed that the single-year of age and sex series
'       are correct. They are used to construct all of the others.

exec .\setup2

dbopen(type=aremos) mef.bnk

pageselect a
smpl 1901 2099

fetch(db=mef) he_wol_m*
fetch(db=mef) tesl_n_n_hi

' CHOOSE AN OPTION
' Option 1: Set tesl_n_n_hi equal to he_wol_m after totaling age/sex groups
' Option 2: Scale single-year of age/sex levels so that the total is consistent with tesl_n_n_hi
!option = 2

' Compute temporary total from single-years of age and sex levels
genr he_wol_m_total = 0
for %sex m f
   for !age = 0 to 110
      he_wol_m_total = he_wol_m_total + he_wol_m_{%sex}{!age}
   next
next

if (!option == 1) then
   tesl_n_n_hi = he_wol_m_total
endif

if (!option == 2) then
   smpl 1951 2099
   genr scaleFactor = 1
   %per1 = tesl_n_n_hi.@first
   %per2 = tesl_n_n_hi.@last
   smpl  {%per1} {%per2}
   scaleFactor = tesl_n_n_hi / (he_wol_m_total + 1e-300)' prevent division by 0
   smpl 1951 2099
   for %sex m f
      for !age = 0 to 110
         he_wol_m_{%sex}{!age} = he_wol_m_{%sex}{!age} * scaleFactor
      next
   next
   delete scaleFactor
endif
delete he_wol_m_total

pagecreate(page=ck) a 1901 2099
pageselect ck
smpl @all
delete ck\*

%lo_age = "0 5 10 16 18 20 25 30 35 40 45 50 55 60 62 65 70 75 80 85 90 95"
%hi_age = "4 9 14 17 19 24 29 34 39 44 49 54 59 61 64 69 74 79 84 89 94 99"

copy a\tesl_n_n_hi ck\tesl_n_n_hi
genr he_wol_m = 0

for %sex m f

   ' Create (non-overlapping) age groups with consecutive single-years
   !n = @wcount(%lo_age)
   for !i = 1 to !n
      !lo = @val(@word(%lo_age,!i))
      !hi = @val(@word(%hi_age,!i))
      genr he_wol_m_{%sex}{!lo}{!hi} = 0
      for !age = !lo to !hi
         he_wol_m_{%sex}{!lo}{!hi} = he_wol_m_{%sex}{!lo}{!hi} + a\he_wol_m_{%sex}{!age}
      next
      if (!lo == 0 or !lo == 5) then
         rename he_wol_m_{%sex}{!lo}{!hi} he_wol_m_{%sex}{!lo}t{!hi}
      endif
   next

   ' Copy the single years of age and sum to check the totals: he_wol_m_m, he_wol_m_f, and he_wol_m
   genr he_wol_m_{%sex} = 0
   for !age = 0 to 99
      copy a\he_wol_m_{%sex}{!age} ck\he_wol_m_{%sex}{!age}
      he_wol_m_{%sex} = he_wol_m_{%sex} + he_wol_m_{%sex}{!age}
   next
   ' Assuming the sum of ages 100-110 equals 100o
   genr he_wol_m_{%sex}100o = 0
   for !age = 100 to 110
      copy a\he_wol_m_{%sex}{!age} ck\he_wol_m_{%sex}{!age}
      he_wol_m_{%sex}100o = he_wol_m_{%sex}100o + he_wol_m_{%sex}{!age}
   next
   he_wol_m_{%sex} = he_wol_m_{%sex} + he_wol_m_{%sex}100o
   he_wol_m = he_wol_m + he_wol_m_{%sex}

   ' Derive the remaining age groups from exisiting age groups
   genr he_wol_m_{%sex}1619 = he_wol_m_{%sex}1617 + he_wol_m_{%sex}1819
   genr he_wol_m_{%sex}6064 = he_wol_m_{%sex}6061 + he_wol_m_{%sex}6264
   genr he_wol_m_{%sex}15u  = he_wol_m_{%sex}0t4 + he_wol_m_{%sex}5t9 + he_wol_m_{%sex}1014 + he_wol_m_{%sex}15
   genr he_wol_m_{%sex}16o  = he_wol_m_{%sex} - he_wol_m_{%sex}15u
   genr he_wol_m_{%sex}85o  = he_wol_m_{%sex}8589 + he_wol_m_{%sex}9094 + he_wol_m_{%sex}9599 + he_wol_m_{%sex}100o
   genr he_wol_m_{%sex}80o  = he_wol_m_{%sex}8084 + he_wol_m_{%sex}85o
   genr he_wol_m_{%sex}75o  = he_wol_m_{%sex}7579 + he_wol_m_{%sex}80o
   genr he_wol_m_{%sex}70o  = he_wol_m_{%sex}7074 + he_wol_m_{%sex}75o
   genr he_wol_m_{%sex}65o  = he_wol_m_{%sex}6569 + he_wol_m_{%sex}70o

next

close mef


