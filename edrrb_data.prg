'
' This program creates/updates historical and projected (Path B-Intermediate) data from
' the Railroad Retirement Board (RRB). 
' Data was dowloaded from Internet (https://secure.rrb.gov/)
' Details of the data sources and instruction of how to update the data each year are listed in \\s1f906b\econ\Raw data\RRB\RRB employment - 20181017.xlsx (and similar files created in subsequent years).
' This program copies the data from \\s1f906b\econ\Raw data\RRB\RRB employment - 20181017.xlsx and stores the relevant series to an EViews workfile.
'
' Polina Vlasenko 10-23-2018

' Updated for TR20:
' (1) extended !projend to 2100
' (2) updated input files
' Polina Vlasenko 11/12/2019

'Updated for TR21 - changed dataend year, updated excel input file, names of input file and workfile. Beth Hima 10-20-2020
'Updated for TR22 - changed dataend year, updated excel input file, names of input file and workfile. Beth Hima 10-26-2021
'Updated for TR23 - changed dataend year, updated excel input file, names of input file and workfile. Beth Hima 10-04-2022
'Updated for TR25 - changed dataend year, updated excel input file, names of input file and workfile. Beth Hima 11-08-2024


' ***** UPDATE this section
!dataend = 2022  ' last year of historical data for RRB data; this will change every year
!projend = 2100 	'2099 ' last year of the projection period; this will change infrequently, probably every five years

' input files
%rrbdata = "T:\LRECON\Data\Raw\RRB\RRB employment - 20241008.xlsx"  'Excel file that contains the RRB data loaded from the original PDF sources; this file is assumed to have a sheet named 'ToBKDR1' that contains the two series we need -- EPRRB and WSPRRB.

' output file created by this program
%file_output = "edrrb_tr25" 		' short name of the workfile
%file_output_path = "C:\Users\715256\GitRepos\econ-eviews\edrrb_tr25.wf1"	    'full path to the workfile, including file extension

' ***** END of update section

wfcreate(wf={%file_output}, page=edrrb) a 1971 !projend

'import data from the Excel file %rrbdata

import %rrbdata range="ToBKDR1" na="#N/A" @freq a 1971 @smpl @all
delete series01

' at this point the workfile contains only two series -- EPRRB and WSPRRB. 
' THESE TWO SERIES NEED TO BE PLACED IN BKDR1.bnk

wfsave %file_output_path
wfclose %file_output


