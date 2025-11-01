' Checks LR compound growth rates for several key variables.
' Updated Base Year for GDP and KGDP to 2012 from 2009, Bob Weathers 12-13-2018
' Updated to Tr2020 source files and years; also automated text in tables to check with new STARTYR and ENDYR -- Polina Vlasenko 4/13/2020
' Subsequent updates are saved in Git repo econ-eviews

' !!! The program does NOT save the resulting workfile automatically; the user must save it manually to the desired location !!!

' indicate TR and alt 
%tr = "25"
%alt = "2"

%abankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\"+ "atr" + %tr + %alt + ".wf1" 	' location of the relevant A-bank
%abank = "atr" + %tr + %alt


' **********

!STARTYEAR = 2000 + @val(%tr) - 1																				'Include base year here
!ENDYEAR = 2000 + @val(%tr) - 1 + 75																				'Include last year of 75 projection period here


%wfname="lr_compound_gr_"+%tr+%alt 
wfcreate(wf={%wfname},page=rawdata) a !STARTYEAR !ENDYEAR

wfopen %abankpath 
pageselect a

for %ser cpiw_u pgdp kgdp17 ee_fe prod_fe tothrs_fe gdp17 ee ahrs prod wsd y gdp wss aiw gdp eaw enaw edmil eas enas aiw acea acwa ase 
	copy {%abank}::a\{%ser} {%wfname}::rawdata\*
next
wfclose {%abank}

wfselect {%wfname}
pageselect rawdata

genr ahrs_fe=tothrs_fe/ee_fe

genr pricediff=pgdp/cpiw_u
genr avgrealearn=(wsd+y)/ee/cpiw_u
genr earn2prod=(wsd+y)/gdp
genr totcomp2prod=(wss+y)/gdp
genr earn2comp=(wsd+y)/(wss+y)

genr ew=eaw+enaw
genr es=eas+enas

genr  avg_r_us_wage=wsd/(ew+edmil)/cpiw_u
genr avg_r_us_seinc=y/es/cpiw_u

genr r_awi=aiw/cpiw_u

genr r1_acea=acea/cpiw_u
genr r1_acwa=acwa/cpiw_u
genr r1_ase=ase/cpiw_u

'From Start Period To Table:
table(40,20) lrcompgr_from	
%from_string = "From " + @str(!STARTYEAR) + " to:"
lrcompgr_from(1,1)=%from_string

lrcompgr_from(2,1)="CPI Wage and Cler. Wkrs (CPIW_U)"
lrcompgr_from(3,1)="GDP Ch. Wt. Price Index PGDP (PGDP)"
lrcompgr_from(4,1)="Price Differential (PGDP/CPIW_U)"

lrcompgr_from(6,1)="Potential GDP (KGDP17)"
lrcompgr_from(7,1)="Full-Empl. E (EE_FE)"
lrcompgr_from(8,1)="FE Productivity (KGDP17/HRS_FE)"
lrcompgr_from(9,1)="Avg. Hours (HRS_FE/EE_FE)"

lrcompgr_from(11,1)="Real GDP (GDP17)"
lrcompgr_from(12,1)="Employed (EE)"
lrcompgr_from(13,1)="Productivity (GDP17/HRS)"
lrcompgr_from(14,1)="Avg. Hours (HRS/EE)"

lrcompgr_from(16,1)="Avg. Real US Earnings (WSD+Y)/EE/CPIW_U)"

lrcompgr_from(18,1)="Productivity (GDP17/HRS)"
lrcompgr_from(19,1)="Avg. Hours (TOTHRS/EE)"
lrcompgr_from(20,1)="Price Differential (PGDP/CPIW_U)"
lrcompgr_from(21,1)="Earn. to GDP (WSD+Y)/GDP"
lrcompgr_from(22,1)="Tot. Comp to GDP (WSS+Y)/GDP"
lrcompgr_from(23,1)="Earn. to Comp. (WSD+Y)/(WSS+Y)"

lrcompgr_from(25,1)="Avg. Real US Wages (WSD)/EW/CPIW_U"
lrcompgr_from(26,1)="Avg. Real US SE Inc. Y/ES/CPIW_U"

lrcompgr_from(28,1)="Avg Wage Index (AIW/CPIW_U)"

lrcompgr_from(30,1)="OASDI Covered Real Earnings Divided by CPI"
lrcompgr_from(31,1)="All Workers"
lrcompgr_from(32,1)="Wage Workers"
lrcompgr_from(33,1)="Self-Employed"
lrcompgr_from(34,1)="Minus CPI Growth Rate"
lrcompgr_from(35,1)="All Workers"
lrcompgr_from(36,1)="Wage Workers"
lrcompgr_from(37,1)="Self-Employed"


!r=2
for %v cpiw_u pgdp pricediff kgdp17 ee_fe prod_fe ahrs_fe gdp17 ee prod ahrs avgrealearn prod ahrs pricediff earn2prod totcomp2prod earn2comp avg_r_us_wage avg_r_us_seinc r_awi r1_acea r1_acwa r1_ase acea acwa _
ase ase
	!c=1
	if !r=5 then
		!r=6
	endif
	if !r=10 then
		!r=11
	endif
	if !r=15 then
		!r=16
	endif
	if !r=17 then
		!r=18
	endif
	if !r=24 then
		!r=25
	endif
	if !r=27 then
		!r=28
	endif
	if !r=29 then
		!r=31
	endif
	
	for !t=5 to 75 step 5
		!c=!c+1	
		!start=!STARTYEAR+!t
		lrcompgr_from(1,!c)=!start
		pageselect rawdata
		if !r<34 then
			!hi=@elem({%v},@str(!start))
			!low=@elem({%v},@str(!STARTYEAR))
			!entry=((!hi/!low)^(1/!t)-1)*100
			lrcompgr_from(!r,!c)=!entry
		endif
		if !r=35 then
			!acea_g_hi=@elem(acea,@str(!start))
			!acea_g_low=@elem(acea,@str(!STARTYEAR))
			!acea_grow=((!acea_g_hi/!acea_g_low)^(1/!t)-1)*100
			!cpiw_u_g_hi=@elem(cpiw_u,@str(!start))
			!cpiw_u_g_low=@elem(cpiw_u,@str(!STARTYEAR))
			!cpiw_grow=((!cpiw_u_g_hi/!cpiw_u_g_low)^(1/!t)-1)*100
			!entry=!acea_grow-!cpiw_grow
			lrcompgr_from(!r,!c)=!entry
		endif
		if !r=36 then
			!acwa_g_hi=@elem(acwa,@str(!start))
			!acwa_g_low=@elem(acwa,@str(!STARTYEAR))
			!acwa_grow=((!acwa_g_hi/!acwa_g_low)^(1/!t)-1)*100
			!cpiw_u_g_hi=@elem(cpiw_u,@str(!start))
			!cpiw_u_g_low=@elem(cpiw_u,@str(!STARTYEAR))
			!cpiw_grow=((!cpiw_u_g_hi/!cpiw_u_g_low)^(1/!t)-1)*100
			!entry=!acwa_grow-!cpiw_grow
			lrcompgr_from(!r,!c)=!entry
		endif
		if !r=37 then
			!ase_g_hi=@elem(ase,@str(!start))
			!ase_g_low=@elem(ase,@str(!STARTYEAR))
			!ase_grow=((!ase_g_hi/!ase_g_low)^(1/!t)-1)*100
			!cpiw_u_g_hi=@elem(cpiw_u,@str(!start))
			!cpiw_u_g_low=@elem(cpiw_u,@str(!STARTYEAR))
			!cpiw_grow=((!cpiw_u_g_hi/!cpiw_u_g_low)^(1/!t)-1)*100
			!entry=!ase_grow-!cpiw_grow
			lrcompgr_from(!r,!c)=!entry
		endif
	next
	!r=!r+1
next

'To End Period From Table:
table(40,20) lrcompgr_to	
%to_string = "To " + @str(!ENDYEAR) + " from:"
lrcompgr_to(1,1)=%to_string

lrcompgr_to(2,1)="CPI Wage and Cler. Wkrs (CPIW_U)"
lrcompgr_to(3,1)="GDP Ch. Wt. Price Index PGDP (PGDP)"
lrcompgr_to(4,1)="Price Differential (PGDP/CPIW_U)"

lrcompgr_to(6,1)="Potential GDP (KGDP17)"
lrcompgr_to(7,1)="Full-Empl. E (EE_FE)"
lrcompgr_to(8,1)="FE Productivity (KGDP17/HRS_FE)"
lrcompgr_to(9,1)="Avg. Hours (HRS_FE/EE_FE)"

lrcompgr_to(11,1)="Real GDP (GDP17)"
lrcompgr_to(12,1)="Employed (EE)"
lrcompgr_to(13,1)="Productivity (GDP17/HRS)"
lrcompgr_to(14,1)="Avg. Hours (HRS/EE)"

lrcompgr_to(16,1)="Avg. Real US Earnings (WSD+Y)/EE/CPIW_U)"

lrcompgr_to(18,1)="Productivity (GDP17/HRS)"
lrcompgr_to(19,1)="Avg. Hours (TOTHRS/EE)"
lrcompgr_to(20,1)="Price Differential (PGDP/CPIW_U)"
lrcompgr_to(21,1)="Earn. to GDP (WSD+Y)/GDP"
lrcompgr_to(22,1)="Tot. Comp to GDP (WSS+Y)/GDP"
lrcompgr_to(23,1)="Earn. to Comp. (WSD+Y)/(WSS+Y)"

lrcompgr_to(25,1)="Avg. Real US Wages (WSD)/EW/CPIW_U"
lrcompgr_to(26,1)="Avg. Real US SE Inc. Y/ES/CPIW_U"

lrcompgr_to(28,1)="Avg Wage Index (AIW/CPIW_U)"

lrcompgr_to(30,1)="OASDI Covered Real Earnings Divided by CPI"
lrcompgr_to(31,1)="All Workers"
lrcompgr_to(32,1)="Wage Workers"
lrcompgr_to(33,1)="Self-Employed"
lrcompgr_to(34,1)="Minus CPI Growth Rate"
lrcompgr_to(35,1)="All Workers"
lrcompgr_to(36,1)="Wage Workers"
lrcompgr_to(37,1)="Self-Employed"


!r=2
for %v cpiw_u pgdp pricediff kgdp17 ee_fe prod_fe ahrs_fe gdp17 ee prod ahrs avgrealearn prod ahrs pricediff earn2prod totcomp2prod earn2comp avg_r_us_wage avg_r_us_seinc r_awi r1_acea r1_acwa r1_ase acea acwa _
ase ase
	!c=1
	if !r=5 then
		!r=6
	endif
	if !r=10 then
		!r=11
	endif
	if !r=15 then
		!r=16
	endif
	if !r=17 then
		!r=18
	endif
	if !r=24 then
		!r=25
	endif
	if !r=27 then
		!r=28
	endif
	if !r=29 then
		!r=31
	endif
	
	for !t=5 to 75 step 5
		!c=!c+1	
		!start=!ENDYEAR-!t
		lrcompgr_to(1,!c)=!start
		pageselect rawdata
		if !r<34 then
			!hi=@elem({%v},@str(!ENDYEAR))
			!low=@elem({%v},@str(!start))
			!entry=((!hi/!low)^(1/!t)-1)*100
			lrcompgr_to(!r,!c)=!entry
		endif
		if !r=35 then
			!acea_g_hi=@elem(acea,@str(!ENDYEAR))
			!acea_g_low=@elem(acea,@str(!start))
			!acea_grow=((!acea_g_hi/!acea_g_low)^(1/!t)-1)*100
			!cpiw_u_g_hi=@elem(cpiw_u,@str(!ENDYEAR))
			!cpiw_u_g_low=@elem(cpiw_u,@str(!start))
			!cpiw_grow=((!cpiw_u_g_hi/!cpiw_u_g_low)^(1/!t)-1)*100
			!entry=!acea_grow-!cpiw_grow
			lrcompgr_to(!r,!c)=!entry
		endif
		if !r=36 then
			!acwa_g_hi=@elem(acwa,@str(!ENDYEAR))
			!acwa_g_low=@elem(acwa,@str(!start))
			!acwa_grow=((!acwa_g_hi/!acwa_g_low)^(1/!t)-1)*100
			!cpiw_u_g_hi=@elem(cpiw_u,@str(!ENDYEAR))
			!cpiw_u_g_low=@elem(cpiw_u,@str(!start))
			!cpiw_grow=((!cpiw_u_g_hi/!cpiw_u_g_low)^(1/!t)-1)*100
			!entry=!acwa_grow-!cpiw_grow
			lrcompgr_to(!r,!c)=!entry
		endif
		if !r=37 then
			!ase_g_hi=@elem(ase,@str(!ENDYEAR))
			!ase_g_low=@elem(ase,@str(!start))
			!ase_grow=((!ase_g_hi/!ase_g_low)^(1/!t)-1)*100
			!cpiw_u_g_hi=@elem(cpiw_u,@str(!ENDYEAR))
			!cpiw_u_g_low=@elem(cpiw_u,@str(!start))
			!cpiw_grow=((!cpiw_u_g_hi/!cpiw_u_g_low)^(1/!t)-1)*100
			!entry=!ase_grow-!cpiw_grow
			lrcompgr_to(!r,!c)=!entry
		endif
	next
	!r=!r+1
next
	

stop


