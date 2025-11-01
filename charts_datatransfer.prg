' This program loads data from the "Charts" file (for example October2021ChartsEV.xlsx) into an EViews workfile.
' The current process calls for the data from  ONLY the latest "Charts" to be loaded into wsaproj<..>.wf1 file into the latest observation. This is what this program does.
' When this was done by hand, we had ro create a separate sheet in the Excel file with 'Charts" (named 'Charts12EV') with the data that needs to be imported in eViews. 
' With automatic import doen here, there is no need to do that.
' This program is written so that it can read the data directly from the "Charts" file as it is given to us, without any need of rearranging data in the sheets.

' OUTSTANDING Q:
' Should we create a process to store the data from all the past "Charts" files? 
' My feeling is -- yes, but I have not yet figure dout how to do this.
' Currently, the data from all past "charts" files is stored in ficahistonew.xls file, tab 'W2 vs. 941 OASDI'

' Polina Vlasenko  --- 09/02/2022

wfcreate(wf=charts, page=q) q 1997q1 2050q4  	' starting dates correspond to wsaproj<>.wf1 files from Tony; ending date I picked far enough into the future so that we don't have to change it every time
pagecreate(page=a) a 1994 2050
pageselect q
smpl @all

logmode logmsg

' Provoide the "Charts" file from which to load data and relevant parameters
%file_charts = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\941Data\NewProcess\October2021ChartsDraft 2021.3.xlsx"
%tb = "Comparison Chart  2021-3" ' name of the sheet in the "Charts" file that contains data; this will change for every data release (hopefully, only the date will change)

%yr_last = @left(@right(%tb, 6),4)	' gets the latest year that appears in the data in %file_charts


!yrl = (@val(%yr_last) - 1)-1900 		' the latest year for whcih we need to create the series; it is always one year less than the data in "Charts"; converted into Aremos form

%per = %yr_last + "q4"	' indicates the period into which these data should be stored in EViews
						' Note: I have not completely figured out how this period relates to the release date of "Charts"; it is not a direct relationship, i.e. it does not move by a quarter with every new quarterly release.
						' My current thinking is that this period is always Q4 of the latest year for which we have data.
						' Example: if we are processing Charts from April 2020, they contain SOME data for 2020, thus we put the data into 2020Q4 (even though Q4 of 2020 is in the future relative ot the report data of April2020).


' initialize the series, they are filled with NAs for now
for !n=96 to !yrl
	series c1941{!n}
	series c1w2{!n}
	series c2941{!n}
	series c2w2{!n}
next

' now import data from %file_charts; need to indicate the cells range carefully
' for c1941, read data starting in B26 (unchanged for all report) and through B[26 + (!yrl - 96)]
' 	Example: for Charts Oct2021, %yr_last = 2021, !yrl = 120, and c1941 is loaded from B26-B50
' for c1w2, read data starting in C26 (unchanged for all report) and through C[26 + (!yrl - 96)]
' for c2941, read data starting in B[8+(@val(%yr_last)-1978] + 28 and through B[prev value + (!yrl - 96)]
' 	Example: for Charts Oct2021, %yr_last = 2021, !yrl = 120, and c2941 is loaded from B79-B103
' for c2w2, read data starting in C[8+(@val(%yr_last)-1978] + 28 and through C[prev value + (!yrl - 96)]
' 	Example: for Charts Oct2021, %yr_last = 2021, !yrl = 120, and c2w2 is loaded from C79-C103


' import values from Chart1; easy, b/c the starting values in ALWAYS on row 26
for !n=96 to !yrl
	!cell = !n-70
	
	%txt = "c1 row is " + @str(!cell)
	logmsg {%txt}
	
	%sername = "c1941" + @str(!n)
	import %file_charts range=%tb!B{!cell}:B{!cell} names=%sername @freq q {%per}
	're-scale
	{%sername} = {%sername} / 1000
	
	%sername = "c1w2" + @str(!n)
	import %file_charts range=%tb!C{!cell}:C{!cell} names=%sername @freq q {%per}
	're-scale
	{%sername} = {%sername} / 1000
next

' import values from Chart2; difficult, b/c the starting row changes when new year of data is added to chart1 above
!startrow = 8 + (@val(%yr_last)-1978) + 28
for !n=96 to !yrl
	!cell = !startrow
	
	%txt = "c2 row is " + @str(!cell)
	logmsg {%txt}
	
	%sername = "c2941" + @str(!n)
	import %file_charts range=%tb!B{!cell}:B{!cell} names=%sername @freq q {%per}
	're-scale
	{%sername} = {%sername} / 1000
	
	%sername = "c2w2" + @str(!n)
	import %file_charts range=%tb!C{!cell}:C{!cell} names=%sername @freq q {%per}
	're-scale
	{%sername} = {%sername} / 1000
	
	!startrow = !startrow + 1
next

wfselect charts
pageselect q
smpl {%per} {%per}


spool _ReadMeFirst
%userpin = @env("USERNAME")
string line1 = "This file was created on " + @date + " at " + @time + " by " + %userpin
string line2 = "This file contains data loaded from " + %file_charts 
string line3 = "This file loads the data from the Charts file given above for only a single period -- " + %per
string line4 = "This is the equivalent of the tab ''Charts12EV'' that Tony included into the processed Charts files; see, for example, \\s1f906b\econ\FormerUsers\Cheng\Excel\CertLet\Data\April2021ChartsEV.xlsx"
string line5 = "These data are then loaded into wsqproj.wf1 file."
string line6 = "This program does NOT preserve the earlier values of the data from the earlier Charts files. A separate program is needed for that. "


_ReadMeFirst.insert line1 line2 line3 line4 line5 line6
delete line*

' find a way to save the file with the name that would indicate which CHarts file was read into it
' Consider using this method to load MANY of the past charts so that we can create the historical record of these values; for this execrcise one would want to store the values into the exact periods they are reported in.



