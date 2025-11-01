
output(t) e:\usr\awcheng\eviews3\wsqproj19bud

' dbopen(type=eviews) e:\usr\awcheng\eviews3\wsqproj16tr.edb '
wfopen e:\usr\awcheng\eviews3\wsqprojbud19.wf1

' Year for which wage projection is to be made '
scalar sel1 = 2017
string datel = "2017"

!g = 1
!gg = 4

' Enter name of workfile with annual sheet below'
' wfopen e:\usr\awcheng\eviews3\testwf.wf1 '
' pageselect Annual '

' calendar number (1 to 14) corresponding to year above '
scalar sel2 = 1


scalar selsw = 0.33
scalar selst = 0.30
scalar selag = 32

'Ult OASDI tips to total tips'
scalar sel3 = 1.0105

'Ult OASDI non-ag wages to total non-ag wages'
scalar sel4 = 1.005

'Ult HI non-ag wages to total non-ag wages'
scalar sel5 = 1.006

'Ult HI 941 wages to ult W2 wages'
scalar sel6 = 1

'944 wages in billions'
scalar sel7 = 5.5

smpl {datel} {datel}
series calen = sel2
series rtip = sel3
series roasdiws = sel4
series rhiws = sel5
series rhiws941w2 = sel6
series ws944 = sel7

series wsdnaq3 = 8408.6
series wsdnaq4 = 8496.4

series emax123 = 154494
series emax1234 = 154494

smpl {datel}-1 {datel}-1
series emax123 = 152437
series emax1234 = 152437

smpl {datel} {datel}
series ruq2 = 4.2
series ruq3 = 4.4
' line for ruq4 removed as it is not used anymore '
' series ruq4 for q4 above not used '
series selfws = selsw
series selft = selst
series swsst = selfws + selft
series wsagult = selag

smpl {datel}-1 {datel}-1
series xfridayq3 = 1
series xfridayq4 = 0

smpl {datel} {datel}
series xfridayq3 = 0
series xfridayq4 = 0

' set dummy variables corresponding to calendar '
!calen = sel2

if !calen = 7 then
  series dumcal7 = 1
else
  series dumcal7 = 0
endif

if !calen = 6 then
  series dumcal6 = 1
else
  series dumcal6 = 0
endif

if !calen = 5 then
  series dumcal5 = 1
else
  series dumcal5 = 0
endif

if !calen = 11 then
  series dumcal11 = 1
else
  series dumcal11 = 0
endif

if !calen = 12 then
  series dumcal12 = 1
else
  series dumcal12 = 0
endif

if !calen = 13 then
  series dumcal13 = 1
else
  series dumcal13 = 0
endif

' do hi wages first   We adjust Q1 down by 1.962 billion because of bogus wage report '
series wsnahi41p = 0.00329*(wsnahi11+wsnahi21+wsnahi31-1962000)
series wsnahiall1p = wsnahi11+wsnahi21+wsnahi31+wsnahi41p-1962000
' for Q2    We adjust Q2 up by 24.2 billion = 16 billion for fed civ and 8.2 for private sector underreporting ' 
series wsnahiall2p = 1.03376*(wsnahi22+wsnahi32+24200000) 

series wsnahiall3p = (wsdnaq3/wsdnaq3(-1) + 0.03451*(xfridayq3-xfridayq3(-1)))*(wsnahiall3(-1))
series wsnahiall4p = (wsdnaq4/wsdnaq4(-1) + 0.03195*(xfridayq4-xfridayq4(-1)))*(wsnahiall4(-1))
series wsnahi = wsnahiall1p + wsnahiall2p + wsnahiall3p + wsnahiall4p

for !a = !g to !gg
  wsnahiall{!a}p.sheet
  wsnahiall{!a}p.setformat f.0
  print wsnahiall{!a}p
  close wsnahiall{!a}p
next

wsnahi.sheet
wsnahi.setformat f.0
print wsnahi
close wsnahi

' print wsnahiall4p '
' print wsdnaq4 '
' print xfridayq4 '
' print wsnahiall4 '


' do oasdi tips '
series wstipall1p = 1.00982*(wstip11+wstip21+wstip31)
series wstipall2p = 1.03901*(wstip22+wstip32)
series wstipall3p = (-0.03755*(ruq3-ruq2) + 1.03442)*wstipall2p
series wstipall4p = (0.01343*(dumcal5+dumcal6+dumcal11) - 0.03166*dumcal7 + 0.98745)*wstipall3p
series wstip = wstipall1p + wstipall2p + wstipall3p + wstipall4p

for !a = !g to !gg
  wstipall{!a}p.sheet
  wstipall{!a}p.setformat f.0
  print wstipall{!a}p
  close wstipall{!a}p
next

wstip.sheet
wstip.setformat f.0
print wstip
close wstip

' print wstipall1p '
' print wstipall2p '
' print wstipall3p '
' print wstipall4p '


' calculate percent change in relmaxproxy in q3 '
smpl {datel}-1 {datel}-1
series rmq3 = taxmax/((wsnahiall1+wsnahiall2+wsnahiall3)/emax123)
smpl {datel} {datel}
series rmq3 = taxmax/((wsnahiall1p+wsnahiall2p+wsnahiall3p)/emax123)
series prmq3 = ((rmq3 / rmq3(-1)) - 1)*100

' calculate percent change in relmaxproxy in q4 '
smpl {datel}-1 {datel}-1
series rmq4 = taxmax/((wsnahiall1+wsnahiall2+wsnahiall3+wsnahiall4)/emax1234)
smpl {datel} {datel}
series rmq4 = taxmax/((wsnahiall1p+wsnahiall2p+wsnahiall3p+wsnahiall4p)/emax1234)
series prmq4 = ((rmq4 / rmq4(-1)) - 1)*100

print prmq3
print prmq4

' do oasdi wages '
series wsnaall1p = 1.00336*(wsna11+wsna21+wsna31-1962000)
' for q2 assume the ratio of oasdi to hi remains the same for the remaining reports '
series wsnaall2p = ((wsna22+wsna32+22700000)/(wsnahi22+wsnahi32+24200000-wstip22-wstip32))*(wsnahiall2p-wstipall2p)
' We adjust Q2 oasdi up by 22.7 billion = 15 billion for fed civ underreporting plus 7.7 in private sector underreporting '
series wsnaall3p = ((0.00206*prmq3 + 0.00771*(ruq3/ruq3(-1)) - 0.00941) + (wsnahiall3p-wstipall3p)/(wsnahiall3(-1)-wstipall3(-1)))*(wsnaall3(-1))

series wsnaall4p = ((0.00251*prmq4 - 0.00069) + (wsnahiall4p-wstipall4p)/(wsnahiall4(-1)-wstipall4(-1)))*(wsnaall4(-1))

series wsna = wsnaall1p + wsnaall2p + wsnaall3p + wsnaall4p

for !a = !g to !gg
  wsnaall{!a}p.sheet
  wsnaall{!a}p.setformat f.0
  print wsnaall{!a}p
  close wsnaall{!a}p
next

wsna.sheet
wsna.setformat f.0
print wsna
close wsna

' print wsnaall1p '
' print wsnaall2p '
' print wsnaall3p '
' print wsnaall4p '


' convert wage totals in thousands to wages in billions dollars '
series wsnahi = wsnahi / 1000000
series wsna = wsna / 1000000
series wstip = wstip / 1000000


' estimate ultimate '
series wstipult = rtip*wstip
series wsnault = roasdiws*wsna
series wsult941 = wsnault + wstipult + swsst + wsagult + ws944

series wsnahiult = rhiws*wsnahi
series wshiult941 = wsnahiult + wsagult
series wshiultw2 = wshiult941/rhiws941w2
series wshiult = wshiultw2

wsult941.sheet
print wsult941
close wsult941

wshiult.sheet
print wshiult
close wshiult

output off



