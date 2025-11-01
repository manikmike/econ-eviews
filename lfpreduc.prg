
' This program:
' - was originally written in Aremos by Drew Sawyer in 2009.
' - creates series P[sex][age]E_DE, which represent how changes in the distribution of educational attainment (EA) will affect LFPR, and stores them in education.bnk.
' - was converted from Aremos to EViews by Drew Sawyer in 2017.


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


' user inputs ************************************************************ 


%op_bank = "op1202o"
' OP bank to use for 5-year age group (5YAG) population weights


' year of last data ************************************************************ 


pageselect a

dbopen(type=aremos) education

fetch(d=education) nm35enohsg
' just picking a series to get the year of last data

%yld = nm35enohsg.@last
' year of last data (string)

!yld =@val(%yld)
' year of last data (scalar)

!yld_m4 = !yld - 4
' year of last data, minus 4

!yld_p1 = !yld + 1
' year of last data, plus 1


' single year of age (SYOA), historical ************************************************************


for %s m f

  pageselect a
  
  ' ages 35 to 74
  
  for !a = 35 to 74

    ' educational attainment (EA) weights
	
    smpl 1992 !yld
	
    genr wt{%s}{!a}enohsg =  education::n{%s}{!a}enohsg  / education::n{%s}{!a}e
    genr wt{%s}{!a}ehsgrad = education::n{%s}{!a}ehsgrad / education::n{%s}{!a}e
    genr wt{%s}{!a}ecol1t3 = education::n{%s}{!a}ecol1t3 / education::n{%s}{!a}e
    genr wt{%s}{!a}ecol4 =   education::n{%s}{!a}ecol4   / education::n{%s}{!a}e
    genr wt{%s}{!a}ecol5o =  education::n{%s}{!a}ecol5o  / education::n{%s}{!a}e

    ' change in LFPR due to change in EA weights (relative to the previous year)

    smpl 1993 !yld

    genr ded_p{%s}{!a} = _
    education::p{%s}{!a}enohsg(-1)  * (wt{%s}{!a}enohsg  - wt{%s}{!a}enohsg(-1))  + _
    education::p{%s}{!a}ehsgrad(-1) * (wt{%s}{!a}ehsgrad - wt{%s}{!a}ehsgrad(-1)) + _
    education::p{%s}{!a}ecol1t3(-1) * (wt{%s}{!a}ecol1t3 - wt{%s}{!a}ecol1t3(-1)) + _
    education::p{%s}{!a}ecol4(-1)   * (wt{%s}{!a}ecol4   - wt{%s}{!a}ecol4(-1))   + _
    education::p{%s}{!a}ecol5o(-1)  * (wt{%s}{!a}ecol5o  - wt{%s}{!a}ecol5o(-1))

    ' LFPR, starting with actual in 1992 and adding the changes

    smpl 1992 1992

    genr p{%s}{!a}e_de = education::p{%s}{!a}e
  
    smpl 1993 !yld

    p{%s}{!a}e_de = p{%s}{!a}e_de(-1) + ded_p{%s}{!a}

  next

  ' age 35
  ' 5-year average of EA weights

  smpl !yld_m4 !yld

  genr avwt{%s}35enohsg  = @mean(wt{%s}35enohsg)
  genr avwt{%s}35ehsgrad = @mean(wt{%s}35ehsgrad)
  genr avwt{%s}35ecol1t3 = @mean(wt{%s}35ecol1t3)
  genr avwt{%s}35ecol4   = @mean(wt{%s}35ecol4)
  genr avwt{%s}35ecol5o  = @mean(wt{%s}35ecol5o)

    
  ' SYOA, projected ************************************************************
  
	
  ' ages 36 to 74
  ' change in LFPR due to change in EA weights (relative to yld)
  
  for !a = 74 to 36 step -1

    fetch(d=education) _
    p{%s}{!a}enohsg _
    p{%s}{!a}ehsgrad _
    p{%s}{!a}ecol1t3 _
    p{%s}{!a}ecol4 _
    p{%s}{!a}ecol5o
    ' need to fetch into workfile because we later want to use @elem
	
	' use all available cohorts down to age 35
		
    !a_m1 = !a - 1
	' !a minus 1

    for !a2 = !a_m1 to 35 step -1

      !year = !yld + !a - !a2

      smpl !year !year

      ded_p{%s}{!a} = _
      @elem(p{%s}{!a}enohsg,!yld)  * (@elem(wt{%s}{!a2}enohsg,!yld)  - @elem(wt{%s}{!a}enohsg,!yld))  + _
      @elem(p{%s}{!a}ehsgrad,!yld) * (@elem(wt{%s}{!a2}ehsgrad,!yld) - @elem(wt{%s}{!a}ehsgrad,!yld)) + _
      @elem(p{%s}{!a}ecol1t3,!yld) * (@elem(wt{%s}{!a2}ecol1t3,!yld) - @elem(wt{%s}{!a}ecol1t3,!yld)) + _
      @elem(p{%s}{!a}ecol4,!yld)   * (@elem(wt{%s}{!a2}ecol4,!yld)   - @elem(wt{%s}{!a}ecol4,!yld))   + _
      @elem(p{%s}{!a}ecol5o,!yld)  * (@elem(wt{%s}{!a2}ecol5o,!yld)  - @elem(wt{%s}{!a}ecol5o,!yld)) 

    next

	' where cohorts >= age 35 are not available, use age 35 5-year average of EA weights
	
    !year = !year + 1
	
    smpl !year 2100

    ded_p{%s}{!a} = _
    @elem(p{%s}{!a}enohsg,!yld)  * (@elem(avwt{%s}35enohsg,!yld_m4)  - @elem(wt{%s}{!a}enohsg,!yld))  + _
    @elem(p{%s}{!a}ehsgrad,!yld) * (@elem(avwt{%s}35ehsgrad,!yld_m4) - @elem(wt{%s}{!a}ehsgrad,!yld)) + _
    @elem(p{%s}{!a}ecol1t3,!yld) * (@elem(avwt{%s}35ecol1t3,!yld_m4) - @elem(wt{%s}{!a}ecol1t3,!yld)) + _
    @elem(p{%s}{!a}ecol4,!yld)   * (@elem(avwt{%s}35ecol4,!yld_m4)   - @elem(wt{%s}{!a}ecol4,!yld))   + _
    @elem(p{%s}{!a}ecol5o,!yld)  * (@elem(avwt{%s}35ecol5o,!yld_m4)  - @elem(wt{%s}{!a}ecol5o,!yld)) 	
	
  next
 
  ' age 35
  ' change in LFPR due to change in EA weights (relative to yld)
  
  fetch(d=education) _
  p{%s}35enohsg _
  p{%s}35ehsgrad _
  p{%s}35ecol1t3 _
  p{%s}35ecol4 _
  p{%s}35ecol5o
  ' need to fetch into workfile because we later want to use @elem

  smpl !yld_p1 2100

  ded_p{%s}35 = _
  @elem(p{%s}35enohsg,!yld)  * (@elem(avwt{%s}35enohsg,!yld_m4)  - @elem(wt{%s}35enohsg,!yld))  + _
  @elem(p{%s}35ehsgrad,!yld) * (@elem(avwt{%s}35ehsgrad,!yld_m4) - @elem(wt{%s}35ehsgrad,!yld)) + _
  @elem(p{%s}35ecol1t3,!yld) * (@elem(avwt{%s}35ecol1t3,!yld_m4) - @elem(wt{%s}35ecol1t3,!yld)) + _
  @elem(p{%s}35ecol4,!yld)   * (@elem(avwt{%s}35ecol4,!yld_m4)   - @elem(wt{%s}35ecol4,!yld))   + _
  @elem(p{%s}35ecol5o,!yld)  * (@elem(avwt{%s}35ecol5o,!yld_m4)  - @elem(wt{%s}35ecol5o,!yld)) 

  ' ages 35 to 74
  ' LFPR after adding the changes to yld

  smpl !yld_p1 2100
	
  for !a = 35 to 74
  
    p{%s}{!a}e_de = @elem(p{%s}{!a}e_de,!yld) + ded_p{%s}{!a}

  next


  ' SYOA, quarterly ************************************************************

 
  pageselect q

  for !a = 35 to 74

    smpl 1992 2100
  
    copy(c="dentona") a\p{%s}{!a}e_de q\p{%s}{!a}e_de
	
  next

  
  ' 5YAG, historical ************************************************************

  
  for %a 3539 4044 4549 5054

    pageselect a

    ' educational attainment (EA) weights
	
    smpl 1992 !yld

    genr wt{%s}{%a}enohsg =  education::n{%s}{%a}enohsg  / education::n{%s}{%a}e
    genr wt{%s}{%a}ehsgrad = education::n{%s}{%a}ehsgrad / education::n{%s}{%a}e
    genr wt{%s}{%a}ecol1t3 = education::n{%s}{%a}ecol1t3 / education::n{%s}{%a}e
    genr wt{%s}{%a}ecol4 =   education::n{%s}{%a}ecol4   / education::n{%s}{%a}e
    genr wt{%s}{%a}ecol5o =  education::n{%s}{%a}ecol5o  / education::n{%s}{%a}e

    ' change in LFPR due to change in EA weights (relative to the previous year)

    smpl 1993 !yld

    genr ded_p{%s}{%a} = _
    education::p{%s}{%a}enohsg(-1)  * (wt{%s}{%a}enohsg  - wt{%s}{%a}enohsg(-1))  + _
    education::p{%s}{%a}ehsgrad(-1) * (wt{%s}{%a}ehsgrad - wt{%s}{%a}ehsgrad(-1)) + _
    education::p{%s}{%a}ecol1t3(-1) * (wt{%s}{%a}ecol1t3 - wt{%s}{%a}ecol1t3(-1)) + _
    education::p{%s}{%a}ecol4(-1)   * (wt{%s}{%a}ecol4   - wt{%s}{%a}ecol4(-1))   + _
    education::p{%s}{%a}ecol5o(-1)  * (wt{%s}{%a}ecol5o  - wt{%s}{%a}ecol5o(-1))

    ' LFPR, starting with actual in 92 and adding the changes

    smpl 1992 1992

    genr p{%s}{%a}e_de = education::p{%s}{%a}e
  
    smpl 1993 !yld

    p{%s}{%a}e_de = p{%s}{%a}e_de(-1) + ded_p{%s}{%a}


  ' 5YAG, projected ************************************************************
	
	
    ' change in LFPR due to change in EA weights (relative to yld)

    smpl !yld_p1 2100

    %a1 = @left(%a,2)
    ' 1st SYOA within 5YAG (e.g., for 3539, 35)
	
    !a1 =@val(%a1)
    !a2 = !a1 + 1
    !a3 = !a2 + 1
    !a4 = !a3 + 1
    !a5 = !a4 + 1

    dbopen(type=aremos) {%op_bank}
    
    ded_p{%s}{%a} = _
    ((ded_p{%s}{!a1} * {%op_bank}::n{%s}{!a1})  + _
     (ded_p{%s}{!a2} * {%op_bank}::n{%s}{!a2})  + _
     (ded_p{%s}{!a3} * {%op_bank}::n{%s}{!a3})  + _
     (ded_p{%s}{!a4} * {%op_bank}::n{%s}{!a4})  + _
     (ded_p{%s}{!a5} * {%op_bank}::n{%s}{!a5})) / _
    ({%op_bank}::n{%s}{!a1} + _
     {%op_bank}::n{%s}{!a2} + _
     {%op_bank}::n{%s}{!a3} + _
     {%op_bank}::n{%s}{!a4} + _
     {%op_bank}::n{%s}{!a5})
    
    close %op_bank

	
    ' LFPR after adding the changes to yld
    
    p{%s}{%a}e_de = @elem(p{%s}{%a}e_de,!yld) + ded_p{%s}{%a}

	
  ' 5YAG, quarterly ************************************************************

  
    pageselect q

    smpl 1992 2100
  
    copy(c="dentona") a\p{%s}{%a}e_de q\p{%s}{%a}e_de
	
  next

next


' store to bank ************************************************************


pageselect q

group g * not resid
' group containing all series except "resid"

%to_store = g.@members
' string containing names of all series in group "g"

smpl 1992 2100

db(type=aremos) education

pageselect a

store(d=education) {%to_store}

pageselect q

store(d=education) {%to_store}


' close stuff ************************************************************


close @db

close @wf

