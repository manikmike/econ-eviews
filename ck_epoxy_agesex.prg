' 	This program performs checks on the MEF data produced by epoxy_agesex_new.prg and stored in workfile named MEF_TRXX.wf1  (where XX stands for TR year, such as MEF_TR19.wf1)
'	The program creates various charts that allow for easy visual inspection of data.
'	The program also allows for comparison of series across TR years.

'	BEFORE running the program, update the information in the *******UPDATE section at the start of the program

'	Polina Vlasenko
'	04-05-2018

'************** UPDATE these entries before running the program
	!dataend = 2016 																											'Last calendar year of **data** in the MEF file
'	!projend = 2099																											'Update this to the last calendar year of the **projection** period (this changes once in 5 years, not every TR)
	%tr= "19"																													'Trustees Report Release Year
	%MEF_src = "\\s1f906b\econ\EViews\TR19_Programs_Data\MEF_TR19.wf1"						'Workfile that contains MEF age-sex data for the TR indicated above	

'	If need to compare data to earlier TRs,
'	(1) set the value of !compare to the NUMBER of earlier TR years to be compared, and
'	(2) enter the TR year and locations of the corresponding MEF age-sex workfiles. 
'		Naming convention: %tr1 is "TR 1 year earlier", %tr2 is "TR 2 years earlier" etc.
	!compare = 1
	%tr1 = "18"
	%MEF_src1 = "\\s1f906b\econ\EViews\TR18_Programs_Data\mef_tr18.wf1"
'	%tr2 = ???
'	%MEF_src2 = "\?????"
'	etc.

'	Concepts for which checks are to be performed:
	%concepts="ce cew ces"

							
'	output of the program:	
	%output_path = "\\s1f906b\econ\EViews\TR19_Programs_Data\" 										'Update this to the location where the output file created by this program is to be stored

'************ END of the update section



'******** Define global variables and parameters:
	%thisfile = "CK_MEF_TR" + %tr																						'The name of the output workfile created by this program.
	
	'These are age and sex strings needed in the program, they do not change from year to year (but may change if a decision is made to change the concepts):
 		'Male and Female sex categories:
 		%sex = "m f"
 		'Age groups
 		%age = "0t4 1014 15u 1617 1619 1819 2024 2529 3034 3539 4044 4549 5054 5559 6061 6064 6264 6569 7074 7579 8084 8589 9094 9599 16o 65o 70o 75o 80o 85o"

'******* End of global parameters

wfcreate(wf={%thisfile}, page=data_TR{%tr}) a 1951 !dataend

for %name {%concepts}
		pagecreate(page={%name}) a 1951 !dataend
next
pageselect data_TR{%tr}

'	copy data from MEF age-sex workfile

wfopen %MEF_src
	for %c {%concepts}
		for %s {%sex}
			for %a {%age}
				copy %MEF_src::MEF_finals\{%c}_m_{%s}{%a} {%thisfile}::data_TR{%tr}\*
			next
		next
	next
wfclose %MEF_src

'	create charts for each sex-age group and copy them to corresponding pages
	for %c {%concepts}
		for %s {%sex}
			for %a {%age}
				graph {%c}_{%s}{%a}.line {%c}_m_{%s}{%a}
				 {%c}_{%s}{%a}.datelabel format("YYYY")
				copy data_TR{%tr}\{%c}_{%s}{%a} {%c}\
			next
		next
	next

' Compare to earlier TRs

if !compare>0 then
	pagecreate(page=TR_comparison) a 1951 !dataend			'page that will hold the comparison charts and data
' 	load data from prior TR(s)
	for !i = 1 to !compare
		%try = %tr{!i}
		%wrkfile = %MEF_src{!i}
		pagecreate(page=data_TR{%try}) a 1951 !dataend
		wfopen %wrkfile 
			for %c {%concepts}
				for %s {%sex}
					for %a {%age}
						copy %wrkfile::MEF_finals\{%c}_m_{%s}{%a} {%thisfile}::data_TR{%try}\*
					next
				next
			next
		wfclose %wrkfile 
	next
	
'	copy all relevant series to TR_comparison page  and rename ot indicate TR	
'	current TR
	for %c {%concepts}
		for %s {%sex}
			for %a {%age}
				copy data_TR{%tr}\{%c}_m_{%s}{%a} TR_comparison\{%c}_m_{%s}{%a}_tr{%tr}
			next
		next
	next
'	past TRs
	for !i = 1 to !compare
		%try = %tr{!i}
			for %c {%concepts}
				for %s {%sex}
					for %a {%age}
						copy data_TR{%try}\{%c}_m_{%s}{%a} TR_comparison\{%c}_m_{%s}{%a}_tr{%try}
					next
				next
			next
	next
	pageselect TR_comparison

' create groups for comaprison
	for !i = 1 to !compare
		%try = %tr{!i}
			for %c {%concepts}
				for %s {%sex}
					for %a {%age}
						%list_{%c}_{%s}{%a} = %c+"_m_"+%s+%a+"_tr"+%tr + " " + %c+"_m_"+%s+%a +"_tr"+%try
					next
				next
			next
	next

'	create comparison groups and charts
		for %c {%concepts}
			for %s {%sex}
				for %a {%age}
					%list = %list_{%c}_{%s}{%a}
					group g_{%c}_{%s}{%a} {%list} 
					graph gr_{%c}_{%s}{%a}.line {%list}
					gr_{%c}_{%s}{%a}.datelabel format("YYYY")
				next
			next
		next

'	compute the difference between Latest TR and previous TR
	%tr_pr = @str(@val(%tr)-1)
		for %c {%concepts}
			for %s {%sex}
				for %a {%age}
					genr diff_{%c}_{%s}{%a} = {%c}_m_{%s}{%a}_tr{%tr} - {%c}_m_{%s}{%a}_tr{%tr_pr}
				next
			next
		next	
		
' 	group differences for ease of display on charts
		for %c {%concepts}
			for %s {%sex}
				group d_{%c}_{%s}_5yr diff_{%c}_{%s}????
				group d_{%c}_{%s}_agg diff_{%c}_{%s}???
				freeze({%c}_{%s}_5yr) d_{%c}_{%s}_5yr.line
				freeze({%c}_{%s}_agg) d_{%c}_{%s}_agg.line
				{%c}_{%s}_5yr.datelabel format("YYYY")
				{%c}_{%s}_agg.datelabel format("YYYY")
				show {%c}_{%s}_5yr
				show {%c}_{%s}_agg
				
			next
			group d_{%c}_16o diff_{%c}_f16o diff_{%c}_m16o
			freeze({%c}_16o) d_{%c}_16o.line
			{%c}_16o.datelabel format("YYYY")
			show {%c}_16o
		next

endif


string _Read_Me_First_ = "This file compares the following MEF databanks"+ @chr(13) + %MEF_src + @chr(13) + %MEF_src1 + @chr(13) + "Look at charts with names ending in ....._5yr and ...._agg for summary of differences between current TR and previous TR." + @chr(13) + "Also take a look at charts ce_16o, ces_16o, cew_16o."
show _Read_Me_First_

'save the workfile
%savepath = %output_path + %thisfile
'wfsave %savepath

'wfclose


