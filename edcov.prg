' NOTE: 9/05/09 EDCOV20090905 is a version that introduces new/improved earnings test variables by single-year of age from 
'               62 through 69. These are believed to be more refined (see Excel file named "Earnings Test Variables.XLSX"

'               This version also introduces new variables that reflect the fact that:
'                 1) those facing the lower earnings test pay "lose" $1 for every $2 of earnings above the earnings cap
'                 2) those facing the higher earnings test pay "lose" $1 for every $3 of earnings above the earnings cap
'               Hence, holding other factors constant, it seems reasonable to believe that workers are more sensitive to
'               the lower cap.

'               The complete specification for the variable that relates the earnings test and the LFPR is

'                 (1-retest(age)) * et_weight_low             for the lower earings test, where et_weight_low = 1/2
'                 (1-retest(age)) * et_weight_high            for the higher earings test, where et_weight_high = 1/3



exec .\setup2

logmode logmsg

wfopen bkdo1.wf1
wfopen bkdr1.wf1

wfselect work

pageselect a
smpl 1971 2023

' The COLA that became effective with benefits paid in January 2000 originally had been
' determined to be 2.4%, but was effectively (and retroactively) changed to 2.5%
' due to Public Law 106-554. 

copy bkdr1::a\aiw aiw
smpl 1991 2023
aiw.adjust = 21811.60 22935.42 23132.67 23753.53 24705.66 25913.90 27426.00 28861.44 _
             30469.84 32154.82 32921.92 33252.09 34064.95 35648.55 36952.94 38651.41 _
             40405.48 41334.97 40711.61 41673.83 42979.61 44321.67 44888.16 46481.52 _
             48098.63 48642.15 50321.89 52145.80 54099.99 55628.60 60575.07 63795.13 _
			 66621.80
             
copy bkdr1::a\beninc beninc
smpl 1992 2024
beninc.adjust =  3.0 2.6 2.8 2.6 2.9 2.1 1.3 2.5 3.5 _
                 2.6 1.4 2.1 2.7 4.1 3.3 2.3 5.8 0.0 0.0 _
                 3.6 1.7 1.5 1.7 0.0 0.3 2.0 2.8 1.6 1.3 _
                 5.9 8.7 3.2 2.5

copy bkdr1::a\taxmax taxmax
smpl 1993 2025
taxmax.adjust =               57.6  60.6  61.2  62.7  65.4  68.4  72.6  76.2 _
                  80.4  84.9  87.0  87.9  90.0  94.2  97.5 102.0 106.8 106.8 _
                 106.8 110.1 113.7 117.0 118.5 118.5 127.2 128.4 132.9 137.7 _
                 142.8 147.0 160.2 168.6 176.1

copy bkdr1::a\taxmaxhi taxmaxhi
smpl 1993 1993
taxmaxhi = 135
smpl 1994 2011
taxmaxhi = 0

' Earnings Test data developed by Karen from Eli

smpl 1965 2025
series etest64u
etest64u.adjust   =  1200    1500     1500     1680     1680    1680     1680 _
                     1680    2100     2400     2520     2760    3000     3240 _
                     3480    3720     4080     4440     4920    5160     5400 _
                     5760    6000     6120     6480     6840    7080     7440 _
                     7680    8040     8160     8280     8640    9120     9600 _
                    10080   10680    11280    11520    11640   12000    12480 _
                    12960   13560    14160    14160    14160   14640    15120 _
                    15480   15720    15720    16920    17040   17640    18240 _
                    18960   19560    21240    22320    23400

smpl 1965 2025
series etest65o
etest65o.adjust   =  1200     1500     1500     1680     1680    1680     1680 _
                     1680     2100     2400     2520     2760    3000     4000 _
                     4500     5000     5500     6000     6600    6960     7320 _
                     7800     8160     8400     8880     9360    9720    10200 _
                    10560    11160    11280    12500    13500   14500    15500 _
                    17000    25000    30000    30720    31080   31800    33240 _
                    34440    36120    37680    37680    37680   38880    40080 _
                    41400    41880    41880    44880    45360   46920    48600 _
                    50520    51960    56520    59520    62160


%tr = "tr24"
%afile  = "atr242"
%dfile  = "dtr242"
%afile1 = "atr241"
%afile2 = "atr242"
%afile3 = "atr243"

' Note: November 7, 2011
'       The following section on earnings test is no longer relevant. 
'       See EARN_TEST_2011.CMD


wfopen {%dfile}.wf1
wfopen {%afile}.wf1

wfselect work
pageselect a

%end1 = @otod(@ilast(aiw))
%end1p1 = @otod(@ilast(aiw) + 1)
%endp = "2100"
smpl 1971 {%end1}
genr aiw_est = aiw
smpl {%end1p1} {%endp}
aiw_est = aiw_est(-1) * {%afile}.wf1::a\aiw / {%afile}.wf1::a\aiw(-1)

smpl 1971 {%endp}
genr retest64u =  etest64u / aiw_est

smpl 1971 1999
genr retest65o =  etest65o / aiw_est
genr retest67 = retest65o
genr retest68 = retest65o
genr retest69 = retest65o

smpl 2000 {%endp}
retest65o = 1.0
retest67 = 1.0
retest68 = 1.0
retest69 = 1.0

for %i retest64u
  %end2 = @otod(@ilast({%i}))
  %end2p1 = @otod(@ilast({%i}) + 1)
  smpl {%end2p1} {%endp}
  {%i} = {%i}(-1)
next

' adjustment to change in retirement age from 65 to 66 beginning in 2003
smpl 1971 2002
genr retest65_adj=1
smpl 2003 2007
retest65_adj.adjust = 10 8 6 4 2
retest65_adj.adjust /= 12 12 12 12 12
smpl 2008 {%endp}
retest65_adj = 0

' adjustment to change in retirement age from 66 to 67 beginning in 2021
smpl 1971 2020
genr retest66_adj = 1
smpl 2021 2025
retest66_adj.adjust = 10 8 6 4 2
retest66_adj.adjust /= 12 12 12 12 12
smpl 2026 {%endp}
retest66_adj = 0

smpl 1971 {%endp}
genr retest65 = (1 - retest65_adj) * retest64u + retest65_adj * retest65o
genr retest66 = (1 - retest66_adj) * retest64u + retest66_adj * retest65o

delete aiw_est




' NOTE: 8/29/04
'       The following is an adjustment to lower federal civilian covered wages relative
'       NIPA wages due to a presumed increase in the relative amount placed into an FSA
'       (see GDPGGEFC.WPD)

smpl 1971 2100
genr adj_fsa_fc = 1

pageselect q
smpl 1971 2100
copy(c="r") a\adj_fsa_fc q\adj_fsa_fc

pageselect vars
copy {%afile}::vars\assumpt assumpt
%assumpt2 = @wordq(assumpt,2)
delete assumpt

pageselect a
smpl 1971 {%endp}

copy {%afile}::a\cfca cfca
cfca.setattr(remarks) Ratio of Federal Civilian OASDI Covered to NIPA wages\Includes projected values from {%assumpt2}

copy {%dfile}::a\cml cml
cml.setattr(remarks) Ratio of Federal Military OASDI Covered to NIPA wages\Includes projected values from {%assumpt2}

copy {%dfile}::a\csla csla
csla.setattr(remarks) Ratio of State and Local OASDI Covered to NIPA wages\Includes projected values from {%assumpt2}

smpl 1986 1992
genr cslhi = csla
cslhi.setattr(remarks) Ratio of State and Local HI Covered to NIPA wages\Includes projected values from {%assumpt2}
smpl 1993 {%endp}
cslhi = ({%afile}.wf1::a\wesl_o + {%afile}.wf1::a\wesl_n_hi) / {%afile}.wf1::a\wsggesl

smpl 1971 {%endp}
copy {%afile}::a\cp cp
cp.setattr(remarks) Ratio of Private OASDI Covered to NIPA wages\Includes projected values from {%assumpt2}

for %y cfca cml csla cslhi cp
   smpl @all
   %endx = @otod(@ilast({%y}))
   smpl {%endx} {%endp}
   {%y} = {%y}(-1)
next

for !i = 1 to 3
   %file = %afile{!i}
   wfopen {%file}.wf1
   wfselect work
   pageselect a
   smpl 1971 2100   
   genr txrp_{%tr}{!i} = {%afile2}.wf1::a\oasdip_tw / {%file}.wf1::a\wspc
   copy {%file}::a\cp a\temp
   copy(c="r") a\temp q\cp_{%tr}{!i}
   delete temp
   copy(c="r") a\txrp_{%tr}{!i} q\txrp_{%tr}{!i}
next

wfclose %afile1
wfclose %afile2
wfclose %afile3

' Lines 323-1716 from edcov20171121 safely removed per email from Bill 10/03/2018

pageselect q
smpl 1971 2016
genr csla = a\csla
genr cslhi = a\cslhi

for %f q a
   pageselect {%f}
   copy * bkdr1::{%f}\*
   delete *
next

for !i = 1 to 5
   logmsg
next
logmsg program finished

wfselect bkdr1
wfsave(2) bkdr1

close @wf

