' This routine creates disability ratios and stores them in an operational databank (op122xo), using raw data stored in a raw databank (op122xr). 
' It is assumed the raw data has been uploaded earlier to the raw databank through another EViews program: EDDI.prg.

' Raw data is SSA Disabled Worker Population In-Current-Pay Status (DICP) as of December 31, as well as the Disability-Insured population (DINS).
 
' This program calculates ratios of DICP to total SSA-area population, as well as ratios of DICP to DINS. Current modeling uses only the latter of these ratios. 
' (Previous modeling used the former ratio, so we are keeping the code in here for now, as a vestige of prior modeling efforts, just in case. :)). 

' This program produces both annual and quarterly values for the disability ratios.

' The first section of this program creates annual series of disability data, the second section creates annual ratios using the series created in the first section, 
' and the third section creates quarterly series using the annual ratios created in the second section. 
' At the end, all series are uploaded to the operational databank, op1222o, for use in TR23. 

' Note: As currently written, this program must be run 3 separate times in order to obtain series for all Alts (1, 2, and 3). 
' Each time, %input1 and %input2 should be changed accordingly, to reference the correct op banks for the desired Alt.
 

%perend = "2100"

%input1 = "op1223r_inc1inc2inc3"

%input2 = "op1223o_inc1inc2inc3"

%username = @env("username")


exec .\setup2

logmode logmsg

pageselect a
smpl 1941 {%perend}


' Section 1 - Annual Levels

wfopen C:\Users\{%username}\GitRepos\econ-eviews\{%input1}.wf1

copy {%input1}.wf1::pm20dicp a\temp

%p1 = @otod(@ifirst(temp))
%p2 = @otod(@ilast(temp))
'%p3 = @otod(@ilast(temp)+1)

delete temp

logmsg {%p1}
logmsg {%p2}
'logmsg {%p3}

smpl {%p1} {%p2}

logmsg generating annual DICP concepts
for !a = 15 to 66
   for %s m f
      genr n{%s}{!a}d = {%input1}.wf1::p{%s}{!a}dicp / 1000000
   next
next

logmsg generating annual DINS concepts
for !a = 15 to 69
   for %s m f
      genr n{%s}{!a}di = {%input1}.wf1::p{%s}{!a}dins / 1000000
   next
next

close @wf

logmsg generating (annual) 5-yr age group DICP and DINS concepts
for !a = 15 to 60
   for %s m f
      !a0 = !a
      !a1 = !a + 1
      !a2 = !a + 2
      !a3 = !a + 3
      !a4 = !a + 4
      genr n{%s}{!a0}{!a4}di = n{%s}{!a0}di + n{%s}{!a1}di + n{%s}{!a2}di + n{%s}{!a3}di + n{%s}{!a4}di
      genr n{%s}{!a0}{!a4}d  = n{%s}{!a0}d  + n{%s}{!a1}d  + n{%s}{!a2}d  + n{%s}{!a3}d  + n{%s}{!a4}d
   next
next

logmsg generating other (annual) age group DINS concepts, by gender: 2-yr, 4-yr, 10-yr, 1519, u20, 16o 
for %s m f
   genr n{%s}1617di = n{%s}16di + n{%s}17di
   genr n{%s}1819di = n{%s}18di + n{%s}19di
   genr n{%s}19udi  = n{%s}15di + n{%s}1617di + n{%s}1819di
   genr n{%s}u20di  = n{%s}19udi

   genr n{%s}1619di = n{%s}1617di + n{%s}1819di
   genr n{%s}2534di = n{%s}2529di + n{%s}3034di
   genr n{%s}3544di = n{%s}3539di + n{%s}4044di
   genr n{%s}4554di = n{%s}4549di + n{%s}5054di
   genr n{%s}5564di = n{%s}5559di + n{%s}6064di
   genr n{%s}6061di = n{%s}60di + n{%s}61di
   genr n{%s}6162di = n{%s}61di + n{%s}62di
   genr n{%s}6263di = n{%s}62di + n{%s}63di
   genr n{%s}6364di = n{%s}63di + n{%s}64di
   genr n{%s}6264di = n{%s}62di + n{%s}63di+n{%s}64di
   genr n{%s}6569di = n{%s}65di + n{%s}66di + n{%s}67di + n{%s}68di + n{%s}69di
   genr n{%s}16odi  = n{%s}1619di + n{%s}2024di + n{%s}2534di + n{%s}3544di + n{%s}4554di + n{%s}5564di + n{%s}6569di
next

logmsg generating aggregate (annual) age group DINS concept, both genders combined: 16o 
genr n16odi = nm16odi + nf16odi

logmsg generating other (annual) age group DICP concepts, by gender: 2-yr, 4-yr, 10-yr, 1519, u20, 16o 
for %s m f
   genr n{%s}1617d = n{%s}16d + n{%s}17d
   genr n{%s}1819d = n{%s}18d + n{%s}19d
   genr n{%s}19ud  = n{%s}15d + n{%s}1617d + n{%s}1819d
   genr n{%s}u20d  = n{%s}19ud

   genr n{%s}1619d = n{%s}1617d + n{%s}1819d
   genr n{%s}2534d = n{%s}2529d + n{%s}3034d
   genr n{%s}3544d = n{%s}3539d + n{%s}4044d
   genr n{%s}4554d = n{%s}4549d + n{%s}5054d
   genr n{%s}5564d = n{%s}5559d + n{%s}6064d
   genr n{%s}6061d = n{%s}60d + n{%s}61d
   genr n{%s}6162d = n{%s}61d + n{%s}62d
   genr n{%s}6263d = n{%s}62d + n{%s}63d
   genr n{%s}6364d = n{%s}63d + n{%s}64d
   genr n{%s}6264d = n{%s}62d + n{%s}63d+n{%s}64d
   genr n{%s}6569d = n{%s}65d + n{%s}66d
   genr n{%s}16od  = n{%s}1619d + n{%s}2024d + n{%s}2534d + n{%s}3544d + n{%s}4554d + n{%s}5564d + n{%s}6569d
next

logmsg generating aggregate (annual) age group DICP concept, both genders combined: 16o
genr n16od = nm16od + nf16od


' Section 2 - Annual Ratios


%gage = "1617 1819 " + _
        "2024 2529 " + _
        "3034 3539 " + _
        "4044 4549 " + _
        "5054 5559 " + _
        "6061 6264 6064 6569 " + _
        "16o"

%sage = "15 16 17 18 19 20 " + _
        "21 22 23 24 25 26 27 28 29 30 " + _
        "31 32 33 34 35 36 37 38 39 40 " + _
        "41 42 43 44 45 46 47 48 49 50 " + _
        "51 52 53 54 55 56 57 58 59 60 " + _
        "61 62 63 64 65 66"
            
for %a {%sage}
   %sagem = %sagem + "m" + %a + " "
   %sagef = %sagef + "f" + %a + " "
next
			
for %a {%gage}
   %gagem = %gagem + "m" + %a + " "
   %gagef = %gagef + "f" + %a + " "
next

%tage = "16o"

wfopen C:\Users\{%username}\GitRepos\econ-eviews\{%input2}.wf1

' create a ratio of disabled beneficiaries to the disability insured pop:
logmsg creating annual ratios of dicp to dins, by gender, by single year of age, and by age group
for %i {%sagem} {%sagef} {%gagem} {%gagef} {%tage}

   smpl 1969 {%perend}
   genr denom = @recode(n{%i}di<>0, n{%i}di,na)
   genr r{%i}di = n{%i}d /denom
 
  r{%i}di.setattr(remarks) ratio of disability beneficiaries in current pay to total disability insured

 '  smpl {%p3} {%perend}
  ' r{%i}di = @elem(r{%i}di, "2100a1")

next

' Inserted 8/17/10:create a ratio of disabled beneficiaries to the SSA-Area pop.
' This is the "old style" disability ratio, which we dont use for the TR anymore, 
' but which is still a useful concept.
' The SSA-area pop'n numbers are already in the op1102xo bank, because it 
' was just a copy of the  old "o" bank.
logmsg creating annual ratios of dicp to SSA-Area population, by gender, by single year of age, and by age group
for %i {%sagem} {%sagef} {%gagem} {%gagef} {%tage}

   smpl 1969 {%perend}-2
   genr r{%i}d = n{%i}d / ::n{%i}(1)
   
   smpl {%perend}-1 {%perend}
   genr denom2 = @recode(r{%i}d(-2)<>0, r{%i}d(-2),na)
   genr r{%i}d = r{%i}d(-1) * r{%i}d(-1) /denom2
   
   smpl 1969 {%perend}
   
   r{%i}d.setattr(remarks) ratio of disability beneficiaries in current pay to the SSA-Area population

  ' smpl {%p3} {%perend}
   'r{%i}d = @elem(r{%i}d, "2100a1")

next 

close {%input2}


' Section 3 - Quarterly Levels

logmsg creating quarterly ratios of dicp to dins, and of dicp to SSA-Area population, by gender, by single year of age, and by age group
group g1 r*di not resid
group g2 r*d not resid

%rdi = g1.@members
%rd = g2.@members

delete g1 g2
'the following executes a cubic spline interpolation
for %i {%rdi}
   copy(c="cubicl") a\{%i} q\{%i}
next

for %i {%rd}
   copy(c="cubicl") a\{%i} q\{%i}
next


close @wf
logmsg store the created annual and quarterly data in op121xo wf1, and close the wf1

wfopen C:\Users\{%username}\GitRepos\econ-eviews\{%input2}.wf1

pageselect a
store n*d n*di r*di r*d
delete *

pageselect q
store r*di r*d
delete *

close @wf

logmsg
logmsg disability ratios finished
logmsg


