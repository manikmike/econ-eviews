' This programs combines the three March CPS workfiles in a single
' "raw" workfile cpsrYYY

!year = 2024 ' lastest year of data

' Use first argument of program call to override default year
if (%0 <> "") then
   !year = @val(%0)
endif

%wfname = "cpsr" + @str(!year - 1900)
%wfname1 = %wfname + "_males_and_females.wf1"
%wfname2 = %wfname + "_femalecu6.wf1"
%wfname3 = %wfname + "_femalec6o.wf1"

wfopen %wfname1

wfcreate(wf=%wfname,page=a) a {!year} {!year}


'Male Population values
copy {%wfname1}::pop\nm????ms
copy {%wfname1}::pop\nm85oms 

copy {%wfname1}::pop\nm????ma
copy {%wfname1}::pop\nm85oma 

copy {%wfname1}::pop\nm????maw
copy {%wfname1}::pop\nm85omaw 

copy {%wfname1}::pop\nm????mas
copy {%wfname1}::pop\nm85omas 

copy {%wfname1}::pop\nm????mad
copy {%wfname1}::pop\nm85omad 

copy {%wfname1}::pop\nm????nm
copy {%wfname1}::pop\nm85onm

'Male Labor Force Values
copy {%wfname1}::lc\lm????ms
copy {%wfname1}::lc\lm85oms 

copy {%wfname1}::lc\lm????ma
copy {%wfname1}::lc\lm85oma 

copy {%wfname1}::lc\lm????maw
copy {%wfname1}::lc\lm85omaw 

copy {%wfname1}::lc\lm????mas
copy {%wfname1}::lc\lm85omas 

copy {%wfname1}::lc\lm????mad
copy {%wfname1}::lc\lm85omad 

copy {%wfname1}::lc\lm????nm
copy {%wfname1}::lc\lm85onm

'Male Unemployed Values

copy {%wfname1}::ru\rm????ms
copy {%wfname1}::ru\rm85oms 

copy {%wfname1}::ru\rm????ma
copy {%wfname1}::ru\rm85oma 

copy {%wfname1}::ru\rm????maw
copy {%wfname1}::ru\rm85omaw 

copy {%wfname1}::ru\rm????mas
copy {%wfname1}::ru\rm85omas 

copy {%wfname1}::ru\rm????mad
copy {%wfname1}::ru\rm85omad

copy {%wfname1}::ru\rm????nm
copy {%wfname1}::ru\rm85onm

'Male Military Values

copy {%wfname1}::military\mm????ms
copy {%wfname1}::military\mm85oms 

copy {%wfname1}::military\mm????ma
copy {%wfname1}::military\mm85oma 

copy {%wfname1}::military\mm????maw
copy {%wfname1}::military\mm85omaw 

copy {%wfname1}::military\mm????mas
copy {%wfname1}::military\mm85omas 

copy {%wfname1}::military\mm????mad
copy {%wfname1}::military\mm85omad

copy {%wfname1}::military\mm????nm
copy {%wfname1}::military\mm85onm

wfclose {%wfname1}

wfopen %wfname2
wfselect %wfname
pageselect a

'Females
'No Children under 6: Population
copy {%wfname2}::pop\nf????nmnc6 
copy {%wfname2}::pop\nf85onmnc6 

copy {%wfname2}::pop\nf????msnc6
copy {%wfname2}::pop\nf85omsnc6

copy {%wfname2}::pop\nf????manc6
copy {%wfname2}::pop\nf85omanc6

copy {%wfname2}::pop\nf????masnc6
copy {%wfname2}::pop\nf85omasnc6

copy {%wfname2}::pop\nf????mawnc6
copy {%wfname2}::pop\nf85omawnc6

copy {%wfname2}::pop\nf????madnc6
copy {%wfname2}::pop\nf85omadnc6


'One Child under 6
copy(m) {%wfname2}::pop\nf????nmc6u1 
copy(m) {%wfname2}::pop\nf85onmc6u1 

copy {%wfname2}::pop\nf????msc6u1
copy {%wfname2}::pop\nf85omsc6u1

copy {%wfname2}::pop\nf????mac6u1
copy {%wfname2}::pop\nf85omac6u1

copy {%wfname2}::pop\nf????masc6u1
copy {%wfname2}::pop\nf85omasc6u1

copy {%wfname2}::pop\nf????mawc6u1
copy {%wfname2}::pop\nf85omawc6u1

copy {%wfname2}::pop\nf????madc6u1
copy {%wfname2}::pop\nf85omadc6u1

'Two Children under 6
copy(m) {%wfname2}::pop\nf????nmc6u2 
copy(m) {%wfname2}::pop\nf85onmc6u2 

copy {%wfname2}::pop\nf????msc6u2
copy {%wfname2}::pop\nf85omsc6u2

copy {%wfname2}::pop\nf????mac6u2
copy {%wfname2}::pop\nf85omac6u2

copy {%wfname2}::pop\nf????masc6u2
copy {%wfname2}::pop\nf85omasc6u2

copy {%wfname2}::pop\nf????mawc6u2
copy {%wfname2}::pop\nf85omawc6u2

copy {%wfname2}::pop\nf????madc6u2
copy {%wfname2}::pop\nf85omadc6u2


'Three or More Children under 6
copy(m) {%wfname2}::pop\nf????nmc6u3_ 
copy(m) {%wfname2}::pop\nf85onmc6u3_ 

copy {%wfname2}::pop\nf????msc6u3_
copy {%wfname2}::pop\nf85omsc6u3_

copy {%wfname2}::pop\nf????mac6u3_
copy {%wfname2}::pop\nf85omac6u3_

copy {%wfname2}::pop\nf????masc6u3_
copy {%wfname2}::pop\nf85omasc6u3_

copy {%wfname2}::pop\nf????mawc6u3_
copy {%wfname2}::pop\nf85omawc6u3_

copy {%wfname2}::pop\nf????madc6u3_
copy {%wfname2}::pop\nf85omadc6u3_


'Labor Force
'No Children under 6
copy(m) {%wfname2}::lc\lf????nmnc6 
copy(m) {%wfname2}::lc\lf85onmnc6 

copy {%wfname2}::lc\lf????msnc6
copy {%wfname2}::lc\lf85omsnc6

copy {%wfname2}::lc\lf????manc6
copy {%wfname2}::lc\lf85omanc6

copy {%wfname2}::lc\lf????masnc6
copy {%wfname2}::lc\lf85omasnc6

copy {%wfname2}::lc\lf????mawnc6
copy {%wfname2}::lc\lf85omawnc6

copy {%wfname2}::lc\lf????madnc6
copy {%wfname2}::lc\lf85omadnc6


'One Child under 6
copy(m) {%wfname2}::lc\lf????nmc6u1 
copy(m) {%wfname2}::lc\lf85onmc6u1 

copy {%wfname2}::lc\lf????msc6u1
copy {%wfname2}::lc\lf85omsc6u1

copy {%wfname2}::lc\lf????mac6u1
copy {%wfname2}::lc\lf85omac6u1

copy {%wfname2}::lc\lf????masc6u1
copy {%wfname2}::lc\lf85omasc6u1

copy {%wfname2}::lc\lf????mawc6u1
copy {%wfname2}::lc\lf85omawc6u1

copy {%wfname2}::lc\lf????madc6u1
copy {%wfname2}::lc\lf85omadc6u1

'Two Children under 6
copy(m) {%wfname2}::lc\lf????nmc6u2 
copy(m) {%wfname2}::lc\lf85onmc6u2 

copy {%wfname2}::lc\lf????msc6u2
copy {%wfname2}::lc\lf85omsc6u2

copy {%wfname2}::lc\lf????mac6u2
copy {%wfname2}::lc\lf85omac6u2

copy {%wfname2}::lc\lf????masc6u2
copy {%wfname2}::lc\lf85omasc6u2

copy {%wfname2}::lc\lf????mawc6u2
copy {%wfname2}::lc\lf85omawc6u2

copy {%wfname2}::lc\lf????madc6u2
copy {%wfname2}::lc\lf85omadc6u2


'Three or More Children under 6
copy(m) {%wfname2}::lc\lf????nmc6u3_ 
copy(m) {%wfname2}::lc\lf85onmc6u3_ 

copy {%wfname2}::lc\lf????msc6u3_
copy {%wfname2}::lc\lf85omsc6u3_

copy {%wfname2}::lc\lf????mac6u3_
copy {%wfname2}::lc\lf85omac6u3_

copy {%wfname2}::lc\lf????masc6u3_
copy {%wfname2}::lc\lf85omasc6u3_

copy {%wfname2}::lc\lf????mawc6u3_
copy {%wfname2}::lc\lf85omawc6u3_

copy {%wfname2}::lc\lf????madc6u3_
copy {%wfname2}::lc\lf85omadc6u3_

'Unemployed
'No Children under 6
copy(m) {%wfname2}::ru\rf????nmnc6 
copy(m) {%wfname2}::ru\rf85onmnc6 

copy {%wfname2}::ru\rf????msnc6
copy {%wfname2}::ru\rf85omsnc6

copy {%wfname2}::ru\rf????manc6
copy {%wfname2}::ru\rf85omanc6

copy {%wfname2}::ru\rf????masnc6
copy {%wfname2}::ru\rf85omasnc6

copy {%wfname2}::ru\rf????mawnc6
copy {%wfname2}::ru\rf85omawnc6

copy {%wfname2}::ru\rf????madnc6
copy {%wfname2}::ru\rf85omadnc6


'One Child under 6
copy(m) {%wfname2}::ru\rf????nmc6u1 
copy(m) {%wfname2}::ru\rf85onmc6u1 

copy {%wfname2}::ru\rf????msc6u1
copy {%wfname2}::ru\rf85omsc6u1

copy {%wfname2}::ru\rf????mac6u1
copy {%wfname2}::ru\rf85omac6u1

copy {%wfname2}::ru\rf????masc6u1
copy {%wfname2}::ru\rf85omasc6u1

copy {%wfname2}::ru\rf????mawc6u1
copy {%wfname2}::ru\rf85omawc6u1

copy {%wfname2}::ru\rf????madc6u1
copy {%wfname2}::ru\rf85omadc6u1

'Two Children under 6
copy(m) {%wfname2}::ru\rf????nmc6u2 
copy(m) {%wfname2}::ru\rf85onmc6u2 

copy {%wfname2}::ru\rf????msc6u2
copy {%wfname2}::ru\rf85omsc6u2

copy {%wfname2}::ru\rf????mac6u2
copy {%wfname2}::ru\rf85omac6u2

copy {%wfname2}::ru\rf????masc6u2
copy {%wfname2}::ru\rf85omasc6u2

copy {%wfname2}::ru\rf????mawc6u2
copy {%wfname2}::ru\rf85omawc6u2

copy {%wfname2}::ru\rf????madc6u2
copy {%wfname2}::ru\rf85omadc6u2


'Three or More Children under 6
copy(m) {%wfname2}::ru\rf????nmc6u3_ 
copy(m) {%wfname2}::ru\rf85onmc6u3_ 

copy {%wfname2}::ru\rf????msc6u3_
copy {%wfname2}::ru\rf85omsc6u3_

copy {%wfname2}::ru\rf????mac6u3_
copy {%wfname2}::ru\rf85omac6u3_

copy {%wfname2}::ru\rf????masc6u3_
copy {%wfname2}::ru\rf85omasc6u3_

copy {%wfname2}::ru\rf????mawc6u3_
copy {%wfname2}::ru\rf85omawc6u3_

copy {%wfname2}::ru\rf????madc6u3_
copy {%wfname2}::ru\rf85omadc6u3_

'Military
'No Children under 6
copy(m) {%wfname2}::mil\mf????nmnc6 
copy(m) {%wfname2}::mil\mf85onmnc6 

copy {%wfname2}::mil\mf????msnc6
copy {%wfname2}::mil\mf85omsnc6

copy {%wfname2}::mil\mf????manc6
copy {%wfname2}::mil\mf85omanc6

copy {%wfname2}::mil\mf????masnc6
copy {%wfname2}::mil\mf85omasnc6

copy {%wfname2}::mil\mf????mawnc6
copy {%wfname2}::mil\mf85omawnc6

copy {%wfname2}::mil\mf????madnc6
copy {%wfname2}::mil\mf85omadnc6


'One Child under 6
copy(m) {%wfname2}::mil\mf????nmc6u1 
copy(m) {%wfname2}::mil\mf85onmc6u1 

copy {%wfname2}::mil\mf????msc6u1
copy {%wfname2}::mil\mf85omsc6u1

copy {%wfname2}::mil\mf????mac6u1
copy {%wfname2}::mil\mf85omac6u1

copy {%wfname2}::mil\mf????masc6u1
copy {%wfname2}::mil\mf85omasc6u1

copy {%wfname2}::mil\mf????mawc6u1
copy {%wfname2}::mil\mf85omawc6u1

copy {%wfname2}::mil\mf????madc6u1
copy {%wfname2}::mil\mf85omadc6u1

'Two Children under 6
copy(m) {%wfname2}::mil\mf????nmc6u2 
copy(m) {%wfname2}::mil\mf85onmc6u2 

copy {%wfname2}::mil\mf????msc6u2
copy {%wfname2}::mil\mf85omsc6u2

copy {%wfname2}::mil\mf????mac6u2
copy {%wfname2}::mil\mf85omac6u2

copy {%wfname2}::mil\mf????masc6u2
copy {%wfname2}::mil\mf85omasc6u2

copy {%wfname2}::mil\mf????mawc6u2
copy {%wfname2}::mil\mf85omawc6u2

copy {%wfname2}::mil\mf????madc6u2
copy {%wfname2}::mil\mf85omadc6u2


'Three or More Children under 6
copy(m) {%wfname2}::mil\mf????nmc6u3_ 
copy(m) {%wfname2}::mil\mf85onmc6u3_ 

copy {%wfname2}::mil\mf????msc6u3_
copy {%wfname2}::mil\mf85omsc6u3_

copy {%wfname2}::mil\mf????mac6u3_
copy {%wfname2}::mil\mf85omac6u3_

copy {%wfname2}::mil\mf????masc6u3_
copy {%wfname2}::mil\mf85omasc6u3_

copy {%wfname2}::mil\mf????mawc6u3_
copy {%wfname2}::mil\mf85omawc6u3_

copy {%wfname2}::mil\mf????madc6u3_
copy {%wfname2}::mil\mf85omadc6u3_

wfclose %wfname2

wfopen %wfname3
wfselect %wfname
pageselect a


'Females
'No Children under 18: Population
copy(m) {%wfname3}::pop\nf????nmnc18 
copy(m) {%wfname3}::pop\nf85onmnc18

copy {%wfname3}::pop\nf????msnc18
copy {%wfname3}::pop\nf85omsnc18

copy {%wfname3}::pop\nf????manc18
copy {%wfname3}::pop\nf85omanc18

copy {%wfname3}::pop\nf????masnc18
copy {%wfname3}::pop\nf85omasnc18

copy {%wfname3}::pop\nf????mawnc18
copy {%wfname3}::pop\nf85omawnc18

copy {%wfname3}::pop\nf????madnc18
copy {%wfname3}::pop\nf85omadnc18


'One Child under 6
copy(m) {%wfname3}::pop\nf????nmc6o1 
copy(m) {%wfname3}::pop\nf85onmc6o1 

copy {%wfname3}::pop\nf????msc6o1
copy {%wfname3}::pop\nf85omsc6o1

copy {%wfname3}::pop\nf????mac6o1
copy {%wfname3}::pop\nf85omac6o1

copy {%wfname3}::pop\nf????masc6o1
copy {%wfname3}::pop\nf85omasc6o1

copy {%wfname3}::pop\nf????mawc6o1
copy {%wfname3}::pop\nf85omawc6o1

copy {%wfname3}::pop\nf????madc6o1
copy {%wfname3}::pop\nf85omadc6o1

'Two Children under 6
copy(m) {%wfname3}::pop\nf????nmc6o2 
copy(m) {%wfname3}::pop\nf85onmc6o2 

copy {%wfname3}::pop\nf????msc6o2
copy {%wfname3}::pop\nf85omsc6o2

copy {%wfname3}::pop\nf????mac6o2
copy {%wfname3}::pop\nf85omac6o2

copy {%wfname3}::pop\nf????masc6o2
copy {%wfname3}::pop\nf85omasc6o2

copy {%wfname3}::pop\nf????mawc6o2
copy {%wfname3}::pop\nf85omawc6o2

copy {%wfname3}::pop\nf????madc6o2
copy {%wfname3}::pop\nf85omadc6o2


'Three or More Children under 6
copy(m) {%wfname3}::pop\nf????nmc6o3_ 
copy(m) {%wfname3}::pop\nf85onmc6o3_ 

copy {%wfname3}::pop\nf????msc6o3_
copy {%wfname3}::pop\nf85omsc6o3_

copy {%wfname3}::pop\nf????mac6o3_
copy {%wfname3}::pop\nf85omac6o3_

copy {%wfname3}::pop\nf????masc6o3_
copy {%wfname3}::pop\nf85omasc6o3_

copy {%wfname3}::pop\nf????mawc6o3_
copy {%wfname3}::pop\nf85omawc6o3_

copy {%wfname3}::pop\nf????madc6o3_
copy {%wfname3}::pop\nf85omadc6o3_


'Labor Force
'No Children under 6
copy(m) {%wfname3}::lc\lf????nmnc18 
copy(m) {%wfname3}::lc\lf85onmnc18 

copy {%wfname3}::lc\lf????msnc18
copy {%wfname3}::lc\lf85omsnc18

copy {%wfname3}::lc\lf????manc18
copy {%wfname3}::lc\lf85omanc18

copy {%wfname3}::lc\lf????masnc18
copy {%wfname3}::lc\lf85omasnc18

copy {%wfname3}::lc\lf????mawnc18
copy {%wfname3}::lc\lf85omawnc18

copy {%wfname3}::lc\lf????madnc18
copy {%wfname3}::lc\lf85omadnc18

'Females

'One Child 6 to 18

copy(m) {%wfname3}::lc\lf????nmc6o1 
copy(m) {%wfname3}::lc\lf85onmc6o1 

copy {%wfname3}::lc\lf????msc6o1
copy {%wfname3}::lc\lf85omsc6o1

copy {%wfname3}::lc\lf????mac6o1
copy {%wfname3}::lc\lf85omac6o1

copy {%wfname3}::lc\lf????masc6o1
copy {%wfname3}::lc\lf85omasc6o1

copy {%wfname3}::lc\lf????mawc6o1
copy {%wfname3}::lc\lf85omawc6o1

copy {%wfname3}::lc\lf????madc6o1
copy {%wfname3}::lc\lf85omadc6o1

'Two Children under 6
copy(m) {%wfname3}::lc\lf????nmc6o2 
copy(m) {%wfname3}::lc\lf85onmc6o2 

copy {%wfname3}::lc\lf????msc6o2
copy {%wfname3}::lc\lf85omsc6o2

copy {%wfname3}::lc\lf????mac6o2
copy {%wfname3}::lc\lf85omac6o2

copy {%wfname3}::lc\lf????masc6o2
copy {%wfname3}::lc\lf85omasc6o2

copy {%wfname3}::lc\lf????mawc6o2
copy {%wfname3}::lc\lf85omawc6o2

copy {%wfname3}::lc\lf????madc6o2
copy {%wfname3}::lc\lf85omadc6o2


'Three or More Children under 6
copy(m) {%wfname3}::lc\lf????nmc6o3_ 
copy(m) {%wfname3}::lc\lf85onmc6o3_ 

copy {%wfname3}::lc\lf????msc6o3_
copy {%wfname3}::lc\lf85omsc6o3_

copy {%wfname3}::lc\lf????mac6o3_
copy {%wfname3}::lc\lf85omac6o3_

copy {%wfname3}::lc\lf????masc6o3_
copy {%wfname3}::lc\lf85omasc6o3_

copy {%wfname3}::lc\lf????mawc6o3_
copy {%wfname3}::lc\lf85omawc6o3_

copy {%wfname3}::lc\lf????madc6o3_
copy {%wfname3}::lc\lf85omadc6o3_

'Unemployed
'No Children under 6
copy(m) {%wfname3}::ru\rf????nmnc18 
copy(m) {%wfname3}::ru\rf85onmnc18 

copy {%wfname3}::ru\rf????msnc18
copy {%wfname3}::ru\rf85omsnc18

copy {%wfname3}::ru\rf????manc18
copy {%wfname3}::ru\rf85omanc18

copy {%wfname3}::ru\rf????masnc18
copy {%wfname3}::ru\rf85omasnc18

copy {%wfname3}::ru\rf????mawnc18
copy {%wfname3}::ru\rf85omawnc18

copy {%wfname3}::ru\rf????madnc18
copy {%wfname3}::ru\rf85omadnc18


'One Child under 6
copy(m) {%wfname3}::ru\rf????nmc6o1 
copy(m) {%wfname3}::ru\rf85onmc6o1 

copy {%wfname3}::ru\rf????msc6o1
copy {%wfname3}::ru\rf85omsc6o1

copy {%wfname3}::ru\rf????mac6o1
copy {%wfname3}::ru\rf85omac6o1

copy {%wfname3}::ru\rf????masc6o1
copy {%wfname3}::ru\rf85omasc6o1

copy {%wfname3}::ru\rf????mawc6o1
copy {%wfname3}::ru\rf85omawc6o1

copy {%wfname3}::ru\rf????madc6o1
copy {%wfname3}::ru\rf85omadc6o1

'Two Children under 6
copy(m) {%wfname3}::ru\rf????nmc6o2 
copy(m) {%wfname3}::ru\rf85onmc6o2 

copy {%wfname3}::ru\rf????msc6o2
copy {%wfname3}::ru\rf85omsc6o2

copy {%wfname3}::ru\rf????mac6o2
copy {%wfname3}::ru\rf85omac6o2

copy {%wfname3}::ru\rf????masc6o2
copy {%wfname3}::ru\rf85omasc6o2

copy {%wfname3}::ru\rf????mawc6o2
copy {%wfname3}::ru\rf85omawc6o2

copy {%wfname3}::ru\rf????madc6o2
copy {%wfname3}::ru\rf85omadc6o2


'Three or More Children under 6
copy(m) {%wfname3}::ru\rf????nmc6o3_ 
copy(m) {%wfname3}::ru\rf85onmc6o3_ 

copy {%wfname3}::ru\rf????msc6o3_
copy {%wfname3}::ru\rf85omsc6o3_

copy {%wfname3}::ru\rf????mac6o3_
copy {%wfname3}::ru\rf85omac6o3_

copy {%wfname3}::ru\rf????masc6o3_
copy {%wfname3}::ru\rf85omasc6o3_

copy {%wfname3}::ru\rf????mawc6o3_
copy {%wfname3}::ru\rf85omawc6o3_

copy {%wfname3}::ru\rf????madc6o3_
copy {%wfname3}::ru\rf85omadc6o3_

'Military
'No Children under 6
copy(m) {%wfname3}::mil\mf????nmnc18 
copy(m) {%wfname3}::mil\mf85onmnc18 

copy {%wfname3}::mil\mf????msnc18
copy {%wfname3}::mil\mf85omsnc18

copy {%wfname3}::mil\mf????manc18
copy {%wfname3}::mil\mf85omanc18

copy {%wfname3}::mil\mf????masnc18
copy {%wfname3}::mil\mf85omasnc18

copy {%wfname3}::mil\mf????mawnc18
copy {%wfname3}::mil\mf85omawnc18

copy {%wfname3}::mil\mf????madnc18
copy {%wfname3}::mil\mf85omadnc18


'One Child under 6
copy(m) {%wfname3}::mil\mf????nmc6o1 
copy(m) {%wfname3}::mil\mf85onmc6o1 

copy {%wfname3}::mil\mf????msc6o1
copy {%wfname3}::mil\mf85omsc6o1

copy {%wfname3}::mil\mf????mac6o1
copy {%wfname3}::mil\mf85omac6o1

copy {%wfname3}::mil\mf????masc6o1
copy {%wfname3}::mil\mf85omasc6o1

copy {%wfname3}::mil\mf????mawc6o1
copy {%wfname3}::mil\mf85omawc6o1

copy {%wfname3}::mil\mf????madc6o1
copy {%wfname3}::mil\mf85omadc6o1

'Two Children under 6
copy(m) {%wfname3}::mil\mf????nmc6o2 
copy(m) {%wfname3}::mil\mf85onmc6o2 

copy {%wfname3}::mil\mf????msc6o2
copy {%wfname3}::mil\mf85omsc6o2

copy {%wfname3}::mil\mf????mac6o2
copy {%wfname3}::mil\mf85omac6o2

copy {%wfname3}::mil\mf????masc6o2
copy {%wfname3}::mil\mf85omasc6o2

copy {%wfname3}::mil\mf????mawc6o2
copy {%wfname3}::mil\mf85omawc6o2

copy {%wfname3}::mil\mf????madc6o2
copy {%wfname3}::mil\mf85omadc6o2


'Three or More Children under 6
copy(m) {%wfname3}::mil\mf????nmc6o3_ 
copy(m) {%wfname3}::mil\mf85onmc6o3_ 

copy {%wfname3}::mil\mf????msc6o3_
copy {%wfname3}::mil\mf85omsc6o3_

copy {%wfname3}::mil\mf????mac6o3_
copy {%wfname3}::mil\mf85omac6o3_

copy {%wfname3}::mil\mf????masc6o3_
copy {%wfname3}::mil\mf85omasc6o3_

copy {%wfname3}::mil\mf????mawc6o3_
copy {%wfname3}::mil\mf85omawc6o3_

copy {%wfname3}::mil\mf????madc6o3_
copy {%wfname3}::mil\mf85omadc6o3_

'Aggregates population, labor force, and number unemployed
for %t n l r
   for %a 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
      for %m ma mad mas maw ms nm
        genr {%t}f{%a}{%m}c6u = {%t}f{%a}{%m}c6u1 + {%t}f{%a}{%m}c6u2 + {%t}f{%a}{%m}c6u3_
        genr {%t}f{%a}{%m}c6o = {%t}f{%a}{%m}c6o1 + {%t}f{%a}{%m}c6o2 + {%t}f{%a}{%m}c6o3_
      next
   next
next

'Females: Converts Unemployed to unemployment rate.  
for %a 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
   for %m ma mad mas maw ms nm
      for %n nc6 c6u1 c6u2 c6u3_ c6u nc18 c6o1 c6o2 c6o3_ c6o
         if (lf{%a}{%m}{%n} <> 0) then
            genr rf{%a}{%m}{%n}= (rf{%a}{%m}{%n}/lf{%a}{%m}{%n})*100
         else
            genr rf{%a}{%m}{%n}= 0
         endif
      next
   next
next

'Males: Converts Unemployed to unemployment rate. 
for %a 1415 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6264 6569 7074 7579 8084 85o
   for %m ma mad mas maw ms nm
      if (lm{%a}{%m} <> 0) then
         genr rm{%a}{%m} = (rm{%a}{%m}/lm{%a}{%m})*100
       else
         genr rm{%a}{%m} = 0
       endif
    next
next



wfclose %wfname3

wfsave(2) %wfname
wfclose %wfname


