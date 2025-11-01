
' This program:
' - was originally written in Aremos by Drew Sawyer in 2009.
' - used to create series P[sex][age]E_DE, which represent how changes in the distribution of educational attainment (EA) will affect LFPR, and stores them in education.bnk.
' - was converted from Aremos to EViews by Drew Sawyer in 2017.
' - was adapted to create new education scores by Sven Sinclair in 2020.
' - was adapted to read from workfiles by Sven Sinclair in 2023.
' - current version is for the 2024 TR (updating within a version requires only changing the op file name)


' background ************************************************************ 


' CPS data
' educational attainment (EA) by sex and single year of age.  five levels of attainment:
' - less than high school diploma
' - high school diploma
' - some college but less than bachelor's degree
' - bachelor's degree
' - graduate degree
' LFPRs for each of these groups

' make projections on a cohort basis
' e.g., males age 50
' to project the distribution of EA for males age 50 10 years from now, we look at current data for males age 40
' e.g., if today's males age 40 are more educated than today's males age 50, we project a positive effect on LFPR of males age 50 10 years from now

' key factor
' generally, education is acquired early in life
' we found it is reasonable to assume that all education is acquired prior to age 35

' assumption: EA for future 35-year-olds will be similar to that of recent history (average of last five years)
' projections where the relevant cohort does not have a current data point at age 35 or older
' e.g., to project distribution of EA for males age 50 30 years from now
' today, that cohort would be age 20
' but we can't use that, because at age 20, the cohort has not finished acquiring education
' assume that the cohort, by the time they are 35, will have same distribution of EA as recent 35-year-olds


exec .\setup2
' This creates workfile work (which should be saved with a different name after program runs)


' user inputs ************************************************************ 


%op_file = "op1252o"
' OP file to use for 5-year age group (5YAG) population weights


' year of last data ************************************************************ 


pageselect a

wfopen education
pageselect a
smpl @all

' just picking a series to get the year of last data
copy education::a\nm35enohsg work::a\*
copy education::a\n* work::vars\n*
close education

wfselect work
pageselect a
smpl @all

%yld = nm35enohsg.@last
' year of last data (string)

!yld =@val(%yld)
' year of last data (scalar)

!yld_m4 = !yld - 4
' year of last data, minus 4

!yld_p1 = !yld + 1
' year of last data, plus 1

!yld_p39 = !yld + 39
' year of last data, plus 39


' single year of age (SYOA), historical (Drew) ************************************************************


for %s m f

  pageselect a
  
  ' ages 35 to 74
  
  for !a = 35 to 74

    ' educational attainment (EA) weights
	
    smpl 1992 !yld
	
    genr wt{%s}{!a}enohsg =  vars\n{%s}{!a}enohsg  / vars\n{%s}{!a}e
    genr wt{%s}{!a}ehsgrad = vars\n{%s}{!a}ehsgrad / vars\n{%s}{!a}e
    genr wt{%s}{!a}ecol1t3 = vars\n{%s}{!a}ecol1t3 / vars\n{%s}{!a}e
    genr wt{%s}{!a}ecol4 =   vars\n{%s}{!a}ecol4   / vars\n{%s}{!a}e
    genr wt{%s}{!a}ecol5o =  vars\n{%s}{!a}ecol5o  / vars\n{%s}{!a}e

pageselect a


' New measures (Sven 2020)
'*******************************************	
    smpl 1992 !yld
	
  ' Fraction with HS or more
  genr wt{%s}{!a}ehsplus = 1 - wt{%s}{!a}enohsg
  ' Fraction with some college or more
  genr wt{%s}{!a}wenttoc = wt{%s}{!a}ehsplus - wt{%s}{!a}ehsgrad
  ' Fraction with batchelor's degree or more
  genr wt{%s}{!a}ebatplus = wt{%s}{!a}ecol4 + wt{%s}{!a}ecol5o
  ' Quantitative summary A: simple
  ' No HS = 0, HS = 1, some coll = 2, BA = 3, Postgrad = 4
  genr edscore{%s}{!a}_a = wt{%s}{!a}ehsgrad + 2 * wt{%s}{!a}ecol1t3 + 3 * wt{%s}{!a}ecol4 + 4 * wt{%s}{!a}ecol5o
  ' Quantitative summary B: reduce to 3 categories
  ' No HS = 0, HS = 1 = some coll, BA = 2 = Postgrad
  genr edscore{%s}{!a}_b = wt{%s}{!a}ehsgrad + wt{%s}{!a}ecol1t3 + 2 * wt{%s}{!a}ecol4 + 2 * wt{%s}{!a}ecol5o

  next

  ' age 35
  ' 5-year average of EA weights

  smpl !yld_m4 !yld

  genr avwt{%s}35enohsg  = @mean(wt{%s}35enohsg)
  genr avwt{%s}35ehsgrad = @mean(wt{%s}35ehsgrad)
  genr avwt{%s}35ecol1t3 = @mean(wt{%s}35ecol1t3)
  genr avwt{%s}35ecol4   = @mean(wt{%s}35ecol4)
  genr avwt{%s}35ecol5o  = @mean(wt{%s}35ecol5o)

  smpl !yld_p1 2100

  series avwt{%s}35enohsg  = avwt{%s}35enohsg(-1)
  series avwt{%s}35ehsgrad  = avwt{%s}35ehsgrad(-1)
  series avwt{%s}35ecol1t3  = avwt{%s}35ecol1t3(-1)
  series avwt{%s}35ecol4  = avwt{%s}35ecol4(-1)
  series avwt{%s}35ecol5o  = avwt{%s}35ecol5o(-1)

next

' Compute average age-35 scores over the last 5 historical years
'smpl !yld_m4 !yld
'!as35ma = avwtm35ehsgrad + 2 * avwtm35ecol1t3 + 3 * avwtm35ecol4 + 4 * avwtm35ecol5o
'!as35mb = avwtm35ehsgrad + avwtm35ecol1t3 + 2 * avwtm35ecol4 + 2 * avwtm35ecol5o
'!as35fa = avwtf35ehsgrad + 2 * avwtf35ecol1t3 + 3 * avwtf35ecol4 + 4 * avwtf35ecol5o
'!as35fb = avwtf35ehsgrad + avwtf35ecol1t3 + 2 * avwtf35ecol4 + 2 * avwtf35ecol5o
'!as35ma = @mean(edscorem35_a)
'!as35mb = @mean(edscorem35_b)
'!as35fa = @mean(edscoref35_a)
'!as35fb = @mean(edscoref35_b)

'Set default value for projected series
smpl !yld_p1 2100

for !a = 35 to 74
  series edscorem{!a}_a = avwtm35ehsgrad + 2 * avwtm35ecol1t3 + _
 3 * avwtm35ecol4 + 4 * avwtm35ecol5o
  series edscorem{!a}_b = avwtm35ehsgrad + avwtm35ecol1t3 + _
 2 * avwtm35ecol4 + 2 * avwtm35ecol5o
  series edscoref{!a}_a = avwtf35ehsgrad + 2 * avwtf35ecol1t3 + _
 3 * avwtf35ecol4 + 4 * avwtf35ecol5o
  series edscoref{!a}_b = avwtf35ehsgrad + avwtf35ecol1t3 + _
 2 * avwtf35ecol4 + 2 * avwtf35ecol5o
'  series edscorem{!a}_a = !as35ma
'  series edscorem{!a}_b = !as35mb
'  series edscoref{!a}_a = !as35fa
'  series edscoref{!a}_b = !as35fb
next

'Assign projected values for cohorts at least 35 years old in year yld
for !year = !yld_p1 to !yld_p39
  !mina = 35 + !year - !yld 'min age for which we have age-35+ data
  smpl !year !year
  for %s m f
    for %v a b
      for !a = !mina to 74
        !ba = !a - !year + !yld  'cohort's base age (age in year !yld)
        series edscore{%s}{!a}_{%v} = @elem(edscore{%s}{!ba}_{%v},!yld)
      next
    next
  next
next

smpl 1992 2100

'5-year age groups

wfopen {%op_file}
copy {%op_file}::a\n* work::vars\n*
close {%op_file}

wfselect work
pageselect a
smpl @all

for !al = 35 to 50 step 5
  !ah = !al + 4
  for %s m f
    for %v a b
      series edscore{%s}{!al}{!ah}_{%v} = 0
      for !a = !al to !ah
        series edscore{%s}{!al}{!ah}_{%v} = edscore{%s}{!al}{!ah}_{%v} + edscore{%s}{!a}_{%v} * vars\n{%s}{!a}
      next
      series edscore{%s}{!al}{!ah}_{%v} = edscore{%s}{!al}{!ah}_{%v} / vars\n{%s}{!al}{!ah}
    next
  next
next

group edscores04 ed*_a
group edscores02 ed*_b
    
  ' SYOA, quarterly ************************************************************

 
pageselect q

for %s m f

  for !a = 35 to 74

    smpl 1992 2100
  
    copy(c="dentonf") a\edscore{%s}{!a}_a q\edscore{%s}{!a}_a
    copy(c="dentonf") a\edscore{%s}{!a}_b q\edscore{%s}{!a}_b
	
	' The following genr statement is necessary because the "dentonf" interpolation method
	' apparently neglects the last 3 quarters, resulting in stale values therein.
	
    smpl 2100q2 2100q4
	
	genr edscore{%s}{!a}_a = edscore{%s}{!a}_a(-1)
	genr edscore{%s}{!a}_b = edscore{%s}{!a}_b(-1)
	
    smpl 1992 2100

  next

  for %ag 3539 4044 4549 5054

    smpl 1992 2100
  
    copy(c="dentonf") a\edscore{%s}{%ag}_a q\edscore{%s}{%ag}_a
    copy(c="dentonf") a\edscore{%s}{%ag}_b q\edscore{%s}{%ag}_b
	
	' The following genr statement is necessary because the "dentonf" interpolation method
	' apparently neglects the last 3 quarters, resulting in stale values therein.
	
    smpl 2100q2 2100q4
	
	genr edscore{%s}{%ag}_a = edscore{%s}{%ag}_a(-1)
	genr edscore{%s}{%ag}_b = edscore{%s}{%ag}_b(-1)
	
    smpl 1992 2100

  next

next

group edscores04 ed*_a
group edscores02 ed*_b
 
delete vars\n*


