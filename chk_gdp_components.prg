' This program loads the necessary data for the check of GDP components
%abankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\atr252.wf1" 	' location of the relevant A-bank
%abank = "atr252"

%outputpath = "\\ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\EconConsistencyChecks\" 	' location to save the resulting workfile to

%tralt = @right(%abank, 3)
%wfname="CheckGDPComponents_"+%tralt 

wfcreate(wf={%wfname},page=annData) a 1949 2100

wfopen %abankpath 
pageselect a

for %ser gdp	gdpg gdpge gdpgefc gdpgesl gdpgf gdpgfc gdpgfm gdpgge gdpggefc gdpggesl gdpgsl gdppbnfxge gdppf gdpph gdppni wss wssg wssge wssgefc wssgesl wssgf wssgfc wssgfm wssgge wssggefc wssggesl wssgsl wssp wsspbnfxge wsspes wsspf wssph wssphs wsspni wsspss ws wsd wsdp wsp wsph wspf wspni wsdpb wsgefc wsgfc wsgfca wsgfm wsgge wsggefc wsggesl wsgmlc ynf yf y
	copy {%abank}::a\{%ser} {%wfname}::annData\*
next
wfclose {%abank}

wfselect {%wfname}
pageselect annData
smpl @all

group checks gdp 	gdpg	gdpge	gdpgefc	gdpgesl	gdpgf	gdpgfc	gdpgfm	gdpgge	gdpggefc	gdpggesl	gdpgsl	gdppbnfxge	gdppf	gdpph	gdppni	wss	wssg	wssge	wssgefc	wssgesl	wssgf	wssgfc	wssgfm	wssgge	wssggefc	wssggesl	wssgsl	wssp	wsspbnfxge	wsspes	wsspf	wssph	wssphs	wsspni	wsspss	ws	wsd	wsdp	wsp	wsph	wspf	wspni	wsdpb	wsgefc	wsgfc	wsgfca	wsgfm	wsgge	wsggefc	wsggesl	wsgmlc	ynf	yf	y

%save = %outputpath + %wfname + ".wf1"
wfsave %save
'wfclose %wfname


