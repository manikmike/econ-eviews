' This program creates Age-Sex-Adjusted series 
' for LFPR, RU, E/POP ratio
' for ANY TR and ANY base year
' for ANNUAL and QUARTERLY series


' **** UPDATE the entries below as needed

%PIN = @env("username")

' Abank
' Will load LFPR, RU, Labor force, amnd Employment series from it
%abank = "atr232"
%abankpath = "C:\Users\" + %PIN + "\GitRepos\econ-eviews" + "\" + %abank + ".wf1"

' Dbank
' Will load population series from it
%dbank = "dtr232"
%dbankpath = "C:\Users\" + %PIN + "\GitRepos\econ-eviews" + "\" + %dbank + ".wf1"

%tralt = @right(%abank, 3) 	' string that denotes TR and ALT, e.g. 232 for TR23 alt2

%base = "2020" 	' STRING denoting the Base Year for the population distribution

' **** END of UPDATE section

exec setup2

' LOAD data -- both annual and quarterly
' load series from Abank
wfopen %abankpath
for %p a q
	wfselect {%abank}
	pageselect {%p}
	smpl @all
	for %s m f
		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o	
			copy {%abank}::{%p}\p{%s}{%a} work::{%p}\* 		' LFPRs
	  		copy {%abank}::{%p}\l{%s}{%a} work::{%p}\* 		' Labor Force (level)
	  		copy {%abank}::{%p}\e{%s}{%a} work::{%p}\* 		' Employment
	  		copy {%abank}::{%p}\r{%s}{%a} work::{%p}\* 		' RUs
		next
		copy {%abank}::{%p}\p{%s}16o work::{%p}\*		' pm16o, pf16o
 		copy {%abank}::{%p}\l{%s}16o work::{%p}\*		' lm16o, lf16o
 		copy {%abank}::{%p}\e{%s}16o work::{%p}\*		' em16o, ef16o
 		copy {%abank}::{%p}\ru{%s} work::{%p}\*			' rum, ruf
	next
	for %ser p16o e16o l16o ru 
		copy {%abank}::{%p}\{%ser} work::{%p}\*
	next
next
wfclose {%abank}

' load series from Dbank
wfopen %dbankpath
for %p a q
	wfselect {%dbank}
	pageselect {%p}
	smpl @all
	for %s m f
		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 16o 65o
			copy {%dbank}::{%p}\n{%s}{%a} work::{%p}\* 	' population
		next
		copy {%dbank}::{%p}\n16o work::{%p}\*
	next
next
wfclose {%dbank}

' Compute e/pop ratios
for %p a q 
	wfselect work
	pageselect {%p}
	smpl @all
	
	for %s m f 
		for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 16o
			series ep{%s}{%a} = e{%s}{%a}/n{%s}{%a}
		next
	next
	series ep16o = e16o/n16o
next
	
' ASA conversion starts here

' ** ANNUAL version 
wfselect work
pageselect a
smpl @all

' create Base Year values (<name>_by)	
for %s f m
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 16o
   		series n{%s}{%a}_by = @elem(n{%s}{%a},%base)
   		series l{%s}{%a}_by = @elem(l{%s}{%a},%base)
	next
next
series n16o_by = nf16o_by + nm16o_by
series l16o_by = lf16o_by + lm16o_by

' ** QUARTERLY version
wfselect work
pageselect q
smpl @all

' create Base Year values (<name>_by)	
%base1 = %base + "q1"
%base2 = %base + "q2"
%base3 = %base + "q3"
%base4 = %base + "q4"

for %s f m
	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o 65o 16o
   		series n{%s}{%a}_by = (@elem(n{%s}{%a},%base1) + @elem(n{%s}{%a},%base2) + @elem(n{%s}{%a},%base3) + @elem(n{%s}{%a},%base4))/4
		series l{%s}{%a}_by = (@elem(l{%s}{%a},%base1) + @elem(l{%s}{%a},%base2) + @elem(l{%s}{%a},%base3) + @elem(l{%s}{%a},%base4))/4
	next
next
series n16o_by = nf16o_by + nm16o_by
series l16o_by = lf16o_by + lm16o_by

' DONE with base year series
	
' compute ASA values
' both ANNUAL and QUARTERLY

for %p a q 
	wfselect work
	pageselect {%p}
	smpl @all
	
	' Version AA -- when the age split is avaialble to 75o
	for %s f m
	  	series p{%s}16o_aa = 0
  		series ep{%s}16o_aa = 0
 	 	series r{%s}16o_aa = 0
	
 	 	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   	 		p{%s}16o_aa = p{%s}16o_aa + p{%s}{%a} * n{%s}{%a}_by
    		ep{%s}16o_aa = ep{%s}16o_aa + ep{%s}{%a} * n{%s}{%a}_by
    		r{%s}16o_aa = r{%s}16o_aa + r{%s}{%a} * l{%s}{%a}_by
  		next
  	
	  	p{%s}16o_aa = p{%s}16o_aa / n{%s}16o_by
	  	ep{%s}16o_aa = ep{%s}16o_aa / n{%s}16o_by
	  	r{%s}16o_aa = r{%s}16o_aa / l{%s}16o_by
	next
	
	' assign values to the ASA series
	series p16o_asa = (pf16o_aa * nf16o_by + pm16o_aa * nm16o_by) / n16o_by
	series ep16o_asa = (epf16o_aa * nf16o_by + epm16o_aa * nm16o_by) / n16o_by
	series ru_asa = (rf16o_aa * lf16o_by + rm16o_aa * lm16o_by) / l16o_by
	
	for %s f m
	   	series p{%s}16o_asa = p{%s}16o_aa
	   	series ep{%s}16o_asa = ep{%s}16o_aa
	   	series ru{%s}_asa = r{%s}16o_aa
	next
	
	delete *_aa
	
	'' Version AB -- when the age split is avaialble only to 65o; older data do not split 65o group further into smaller age groups
	' NOT using it now; including here just in case
	'for %s f m	
	'  	series p{%s}16o_ab = 0
	'  	series ep{%s}16o_ab = 0
	'  	series r{%s}16o_ab = 0
	'	
	'  	for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 65o 
	'    	p{%s}16o_ab = p{%s}16o_ab + p{%s}{%a} * n{%s}{%a}_by
	'    	ep{%s}16o_ab = ep{%s}16o_ab + ep{%s}{%a} * n{%s}{%a}_by
	'    	r{%s}16o_ab = r{%s}16o_ab + r{%s}{%a} * l{%s}{%a}_by
	'  	next
	'  	
	'  	p{%s}16o_ab = p{%s}16o_ab / n{%s}16o_by
	'  	ep{%s}16o_ab = ep{%s}16o_ab / n{%s}16o_by
	'  	r{%s}16o_ab = r{%s}16o_ab / l{%s}16o_by
	'next
	

'	' OPTIONAL -- uncomment if desired
'	' rename all ASA series to indicate TR, alt, and base year for ASA conversion
'	for %ser ep16o_asa epf16o_asa epm16o_asa p16o_asa pf16o_asa pm16o_asa ru_asa ruf_asa rum_asa
'		rename {%ser} {%ser}_tr{%tralt}_by{%base}
'	next
next

' create groups for easy viewing
wfselect work
pageselect q
smpl 1980q1 @last

group _LFPR_asa p16o_asa pf16o_asa pm16o_asa
group _EPOP_asa ep16o_asa epf16o_asa epm16o_asa
group _RU_asa ru_asa ruf_asa rum_asa


wfselect work
pageselect a
smpl 1980 @last

group _LFPR_asa p16o_asa pf16o_asa pm16o_asa
group _EPOP_asa ep16o_asa epf16o_asa epm16o_asa
group _RU_asa ru_asa ruf_asa rum_asa


' name the file appropriately and save it
%filename = "ASAvalues_tr" + %tralt + "_by" + %base
wfsave(2) %filename


