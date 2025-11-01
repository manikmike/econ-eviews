' This program develops new variables to test the effect of changes in the earnings test on LFPRs for the 
' 2009 Labor Force Model.


' This procedure follows the outline below

' Hypothesis - We hypothesize that an increase in the earnings test (which apply to those between the ages of 62 to 69) 
'              increases the LFPR, because beneficiaries' earnings are taxed less

' Important Concepts

'    1) those in each age group may face one to three posible earnings test

'       a) low earnings test  - presently applies to retired worker beneficiaries between the age of 62 and 
'                               the normal retirement age (NRA). The beneficiariary will lose $1 of benefits for
'                               every $2 earned above the earnings limit.
'                              
'       b) high earnings test - presently applies to retired worker beneficiaries during the year they reach the NRA.
'                               The beneficiariary will lose $1 of benefits for every $3 earned above the earnings limit.
'                              
'       c) no earnings test   - presently applies to retired worker beneficiaries after they reach the NRA.

'    2) if a beneficiary has earnings over a limit, his/her benefit is reduced, but not permanently. When the beneficiary
'       reaches their NRA, their benefit is recalulated updward to offset the loss.


' Defining a potential earnings test tax rate variable

'          maximum (0, (1 - earnings limit / AIW) * ratio of dollar loss )

'          for example, in 2008, 

'                  low earnings test limit = $12,960
'                  average wage index (AIW)= $40,405.48

'                  ratio of dollar loss for low earnings test = $1 for every $2 

'          hence, 

'          maximum (0, (1 - 0.3207) * 0.500 ) = maximum (0, 0.33965)

'          roughly, this says that if the beneficiary earned a level equal to the AIW, then about 34% of the
'          beneficiaries earnings over the limit would be lost (albeit temporarily).
'          Furthermore, if the law changed such that only $1 in $3 would be lost, then the marginal tax rate
'          would fall to about 23%.

'          maximum (0, (1 - 0.3207) * 0.333 ) = maximum (0, 0.22621)



'          I calculate ratios of earnings test limits to AIW for each age group from 62 to 69. 
'             (Note: Roughly under present law, the low earnings test applies to those age 62 to the NRA, and the 
'                    high earnings test applies to those at the NRA. However, I develop separate earnings tests for 
'                    each age group because some age groups have a combination of high/low/no earnings tests, and 
'                    because in the future we may have a change in law where each age group is affected differently.)

' Outline for this Command File

'  Step 1 - create potential high and low earnings-test tax rates 
'  Step 2 - create population weights for each age group as to the reletive number covered by a high, low, or no
'           earnings test
'  Step 3 - create population-weighted potential earnings test tax rates for each age group


' Note: 10/02/09 - The above method could be improved to take into consideration that under present law the earnings test
'                  thresholds are not changed if the BENINC is 0.0 percent.
'
'                  Given that we expect no increase in the threshold amounts for CY 2010, it seems reasonable to set future 
'                  effective tax rates to levels in 2008.


exec .\setup2
pageselect a




'  Step 1 - create potential high and low earnings-test tax rates 


' Following data comes from OCACT website on or after COLA day
' https://www.ssa.gov/OACT/COLA/autoAdj.html

series etest_low
smpl 1965 2025
etest_low.fill(o=1965) _
                              1200,    1500,     1500,     1680,    1680,    1680,     1680, _
                              1680,    2100,     2400,     2520,    2760,    3000,     3240, _
                              3480,    3720,     4080,     4440,    4920,    5160,     5400, _
                              5760,    6000,     6120,     6480,    6840,    7080,     7440, _
                              7680,    8040,     8160,     8280,    8640,    9120,     9600, _
                             10080,   10680,    11280,    11520,   11640,   12000,    12480, _
                             12960,   13560,    14160,    14160,   14160,   14640,    15120, _
                             15480,   15720,    15720,    16920,   17040,   17640,    18240, _
                             18960,   19560,    21240,    22320,   23400

series etest_high
smpl 1965 2025
etest_high.fill(o=1965) _
                               1200,     1500,     1500,     1680,    1680,    1680,     1680, _
                               1680,     2100,     2400,     2520,    2760,    3000,     4000, _
                               4500,     5000,     5500,     6000,    6600,    6960,     7320, _
                               7800,     8160,     8400,     8880,    9360,    9720,    10200, _
                              10560,    11160,    11280,    12500,   13500,   14500,    15500, _
                              17000,    25000,    30000,    30720,   31080,   31800,    33240, _
                              34440,    36120,    37680,    37680,   37680,   38880,    40080, _
                              41400,    41880,    41880,    44880,   45360,   46920,    48600, _
                              50520,    51960,    56520,    59520,   62160

series aiw
smpl 1991 2023
aiw.fill(o=1991) _
                      21811.60, 22935.42, 23132.67, 23753.53, 24705.66, 25913.90, 27426.00, 28861.44, _
                      30469.84, 32154.82, 32921.92, 33252.09, 34064.95, 35648.55, 36952.94, 38651.41, _
                      40405.48, 41334.97, 40711.61, 41673.83, 42979.61, 44321.67, 44888.16, 46481.52, _
                      48098.63, 48642.15, 50321.89, 52145.80, 54099.99, 55628.60, 60575.07, 63795.13, _
					  66621.80



smpl 2024 2024
aiw = aiw(-1) * 1.038 ' ATR242:AIW.A growth from 2023 to 2024 is 3.8%

smpl 1991 2024

genr pot_et_txrt_l  =(1 - etest_low /aiw) * (1/2)
genr pot_et_txrt_h =(1 - etest_high/aiw) * (1/3)


' by law, the annual growth rate in etest_low and etest_high is set to the growth rate in the AIW. Hence, in the future, 
' the levels of pot_et_txrt_l and pot_et_txrt_h are expected to remain approximately constant and equal to their latest
' historical values.

smpl 2025 2100
pot_et_txrt_l = pot_et_txrt_l(-1)  
pot_et_txrt_h = pot_et_txrt_h(-1) 







'  Step 2 - create population weights for each age group as to the reletive number covered by a high, low, or no
'           earnings test for each age group from 62 to 69

'           (see Excel file named "Earnings Test Variables.XLS" for a derivation of these weights)


'    Age 62 and 63

smpl 1991 2100

for !a = 62 to 63
  genr wt{!a}_etesthigh = 0.0
  genr wt{!a}_etestlow  = 1.0
  genr wt{!a}_etestno   = 0.0
next


'    Age 64

  series wt64_etesthigh
  smpl 1991 1999
  wt64_etesthigh = 0.458
  smpl 2000 2002
  wt64_etesthigh = 0.458
  smpl 2003 2007
  wt64_etesthigh.fill(o=2003) 0.313, 0.194, 0.104, 0.042, 0.007
  smpl 2008 2100
  wt64_etesthigh = 0.0
  
  series wt64_etestlow
  smpl 1991 1999
  wt64_etestlow = 0.542
  smpl 2000 2002
  wt64_etestlow = 0.542
  smpl 2003 2007
  wt64_etestlow.fill(o=2003) 0.688, 0.806, 0.896, 0.958, 0.993
  smpl 2008 2100
  wt64_etestlow = 1.0

  series wt64_etestno
  smpl 1991 2100
  wt64_etestno  = 0.0



'    Age 65

  series wt65_etesthigh
  smpl 1991 1999
  wt65_etesthigh = 1.0
  smpl 2000 2002
  wt65_etesthigh = 0.0
  smpl 2003 2008
  wt65_etesthigh.fill(o=2003) 0.146, 0.229, 0.292, 0.319, 0.326, 0.313
  smpl 2009 2020
  wt65_etesthigh = 0.458
  smpl 2021 2025
  wt65_etesthigh.fill(o=2021) 0.313, 0.194, 0.104, 0.042, 0.007
  smpl 2026 2100
  wt65_etesthigh = 0.0
   
  series wt65_etestlow
  smpl 1991 1999
  wt65_etestlow = 0.0
  smpl 2000 2002
  wt65_etestlow = 0.0
  smpl 2003 2008
  wt65_etestlow.fill(o=2003) 0.021, 0.069, 0.146, 0.250, 0.382, 0.542
  smpl 2009 2020
  wt65_etestlow = 0.542
  smpl 2021 2025
  wt65_etestlow.fill(o=2021) 0.688, 0.806, 0.896, 0.958, 0.993
  smpl 2026 2100
  wt65_etestlow = 1.0

  series wt65_etestno
  smpl 1991 1999
  wt65_etestno  = 0.0
  smpl 2000 2002
  wt65_etestno  = 1.0
  smpl 2003 2008
  wt65_etestno.fill(o=2003) 0.833, 0.701, 0.563, 0.431, 0.292, 0.146
  smpl 2009 2100
  wt65_etestno  = 0.0
  
  
  

'    Age 66

  series wt66_etesthigh
  smpl 1991 1999
  wt66_etesthigh = 1.0
  smpl 2000 2002
  wt66_etesthigh = 0.0
  smpl 2003 2008
  wt66_etesthigh = 0.0
  smpl 2009 2020
  wt66_etesthigh = 0.0
  smpl 2021 2026
  wt66_etesthigh.fill(o=2021) 0.146, 0.229, 0.292, 0.319, 0.326, 0.313
  smpl 2027 2100
  wt66_etesthigh = 0.458
  
  series wt66_etestlow 
  smpl 1991 1999
  wt66_etestlow = 0.0
  smpl 2000 2002
  wt66_etestlow = 0.0
  smpl 2003 2008
  wt66_etestlow = 0.0
  smpl 2009 2020
  wt66_etestlow = 0.0
  smpl 2021 2026
  wt66_etestlow.fill(o=2021) 0.021, 0.069, 0.146, 0.250, 0.382, 0.542
  smpl 2027 2100
  wt66_etestlow = 0.542
  
  series wt66_etestno
  smpl 1991 1999
  wt66_etestno  = 0.0
  smpl 2000 2002
  wt66_etestno  = 1.0
  smpl 2003 2008
  wt66_etestno  = 1.0
  smpl 2009 2020
  wt66_etestno  = 1.0
  smpl 2021 2026
  wt66_etestno.fill(o=2021) 0.833, 0.701, 0.563, 0.431, 0.292, 0.146
  smpl 2027 2100
  wt66_etestno  = 0.0




'    Age 67, 68, and 69

for !a = 67 to 69
  smpl 1991 1999
  genr wt{!a}_etesthigh = 1.0
  genr wt{!a}_etestlow  = 0.0
  genr wt{!a}_etestno  = 0.0

  smpl 2000 2100
  wt{!a}_etesthigh = 0.0
  wt{!a}_etestlow  = 0.0
  wt{!a}_etestno   = 1.0
next



'  Step 3 - create population-weighted potential earnings test tax rates for each age group

smpl 1991 2100
for !a = 62 to 69
  series  pot_et_txrt_{!a}
  pot_et_txrt_{!a}.setattr(remarks) Created By EViews program earn_test.prg
  pot_et_txrt_{!a} = wt{!a}_etesthigh * pot_et_txrt_h + wt{!a}_etestlow * pot_et_txrt_l + wt{!a}_etestno * 0.0
next

delete aiw etest_low etest_high



wfopen bkdr1.wf1

wfselect work
pageselect a

copy * bkdr1::a\*

delete *

wfselect bkdr1
wfsave(2) bkdr1

close @wf


