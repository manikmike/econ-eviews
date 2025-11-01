' Download Resident and Civilian Populatino Data from Census Bureau from 2010 Decennial Census to Present
'	Notes: (1) Data is Monthly Postcensal Resident Population Files (Several Universe=P) and Monthly Postcensal Civilian Population (Universe=C)
'			  (2) Military is constructed as Resident Pop minus Civilian Pop for each Age-Sex specific group.
'
'	We place the Postcensal resident population files here: \\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\
'			and the civilian population files here :\\s1f906b\econ\Raw data\Census\Civilian Pop
'
'	Files are in .csv format and all files going back to 2010 are updated each year, called a "vintage"
'	  The 2018 are estimates for the 2017 vintage (which contains actuals through July 1, and estimates thereafter
'
'	This program could be improved in the future as follows:
'		(1) Add the 2010:1 2010:12 4.2 files.
'		(2) Construct some global strings in front of the program to make updating easier, this might include strings for the source data files as well as the last year of data.
'
'	MAKE SURE THAT THE DATA FILES AND THE YEARS ARE UPDATED THROUGHOUT THE PROGRAM.
'
'     Bob Weathers, 11-17-2018



wfcreate(wf=censuspop, page=resident) m 2010:1 2018:12
pagecreate(page=civilian) m 2010:1 2018:12
pagecreate(page=military) m 2010:1 2018:12

'Resident Popuation

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file02.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2010:7 2010:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next
copy(smpl="2010M06 2011M12") p\* censuspop::resident\*
close "nc-est2017-alldata-p-file02" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file03.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2011:1 2011:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2011M01 2011M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file03" 


wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file04.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2011:7 2011:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2011M07 2011M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file04" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file05.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2012:1 2012:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2012M01 2012M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file05" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file06.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2012:7 2012:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2012M07 2012M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file06" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file07.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2013:1 2013:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2013M01 2013M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file07" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file08.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2013:7 2013:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2013M07 2013M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file08" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file09.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2014:1 2014:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2014M01 2014M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file09" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file10.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2014:7 2014:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2014M07 2014M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file10" 


wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file11.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2015:1 2015:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2015M01 2015M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file11" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file12.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2015:7 2015:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2015M07 2015M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file12" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file13.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2016:1 2016:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2016M01 2016M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file13" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file14.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2016:7 2016:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2016M07 2016M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file14" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file15.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2017:1 2017:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2017M01 2017M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file15" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file16.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2017:7 2017:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2017M07 2017M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file16" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file17.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2018:1 2018:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2018M01 2018M06")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file17" 

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Resident plus AF overseas Pop\nc-est2017-alldata-p-file18.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=p) m 2018:7 2018:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* p\* 
			pagedelete untitled
  		next

copy(m,smpl="2018M07 2018M12")  p\* censuspop::resident\*
close "nc-est2017-alldata-p-file18" 


'Civilian Popuation

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file02.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2010:7 2010:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next
copy(smpl="2010M06 2011M12") c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file02"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file03.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2011:1 2011:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2011M01 2011M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file03"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file04.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2011:7 2011:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2011M07 2011M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file04"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file05.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2012:1 2012:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2012M01 2012M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file05"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file06.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2012:7 2012:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2012M07 2012M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file06"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file07.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2013:1 2013:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2013M01 2013M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file07"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file08.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2013:7 2013:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2013M07 2013M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file08"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file09.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2014:1 2014:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2014M01 2014M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file09"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file10.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2014:7 2014:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2014M07 2014M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file10"


wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file11.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2015:1 2015:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2015M01 2015M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file11"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file12.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2015:7 2015:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2015M07 2015M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file12"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file13.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2016:1 2016:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2016M01 2016M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file13"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file14.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2016:7 2016:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2016M07 2016M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file14"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file15.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2017:1 2017:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2017M01 2017M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file15"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file16.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2017:7 2017:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2017M07 2017M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file16"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file17.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2018:1 2018:6
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2018M01 2018M06")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file17"

wfopen(page=rawdata) "\\s1f906b\econ\Raw data\Census\Civilian Pop\nc-est2017-alldata-c-file18.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @smpl @all
	pagecreate(page=c) m 2018:7 2018:12
	'Read in raw age-sex specific data from Drew's epoxy file provided by Systems
		 for !a=0 to 100
			pageselect rawdata
			pagecopy(smpl=if age=!a) year month age universe tot_pop tot_male tot_female
			rename tot_pop tot_pop{!a}
                rename tot_male tot_male{!a}
			rename tot_female tot_female{!a}
			copy untitled\* c\* 
			pagedelete untitled
  		next

copy(m,smpl="2018M07 2018M12")  c\* censuspop::civilian\*
close "nc-est2017-alldata-c-file18"

'After Download of ALL New Residential and Civilian Data, the below program:
'  (1) Creates Military as the difference
'  (2) Creates age groupings for Military
'  (3) Aggregates to Quarterly and Annual
'  (4) Creates Groups to make checks easy

pageselect military

for !a=0 to 100
	genr TOT_MALE{!a}=resident\TOT_MALE{!a}-civilian\TOT_MALE{!a}
	genr TOT_FEMALE{!a}=resident\TOT_FEMALE{!a}-civilian\TOT_FEMALE{!a}
next			

	   	%lo = "16 16 18 20 25 30 35 40 45 50 55" 
	   	%hi = "59 17 19 24 29 34 39 44 49 54 59"

		' Number of age groupings:
		!anum = @wcount(%lo)

		' Construct each mef concept-sex-age grouping:
     	 	for !n = 1 to !anum          								' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         	' Create age grouping label
		     	%ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.
	       	genr nm{%ag}m = 0  ' initialize series for each grouping
	       	genr nf{%ag}m = 0  ' initialize series for each grouping
				
         			for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            			nm{%ag}m = nm{%ag}m + (tot_male{!a}/1000000)
         			     nf{%ag}m = nf{%ag}m + (tot_female{!a}/1000000)
            		next
      	next
   	  	
pagecreate(page=military_quarterly) q 2010 2018
 copy military\nm* military_quarterly\nm*
 copy military\nf* military_quarterly\nf*

group males nm1617m nm1819m nm2024m nm2529m nm3034m nm3539m nm4044m nm4549m nm5054m nm5559m nm1659m
group females nf1617m nf1819m nf2024m nf2529m nf3034m nf3539m nf4044m nf4549m nf5054m nf5559m nf1659m

pagecreate(page=military_annual) a 2010 2018
 copy military\nm* military_annual\nm*
 copy military\nf* military_annual\nf*

group males nm1617m nm1819m nm2024m nm2529m nm3034m nm3539m nm4044m nm4549m nm5054m nm5559m nm1659m
group females nf1617m nf1819m nf2024m nf2529m nf3034m nf3539m nf4044m nf4549m nf5054m nf5559m nf1659m











