' This program loads data from FICA87ON.xls file into an EViews workfile
' This is the initial load of data, to tranfer what is currectly contained in FICA 87ON.xls into eViews.
' This program will likely be use donly once; but I am doing this in a program instead of by hand to have a record of what exactly was transferred and how.
' The idea is that, in the future, we will update the data in EViews, starting with this initial file and adding to it every time we get new 941data reports.
' Polina Vlasenko  --- 08/31/2022

wfcreate(wf=fica87on, page=q) q 1997q1 2050q4  	' starting dates correspond to wsaproj<>.wf1 files from Tony; ending date I picked far enough into the future so that we don't have to change it every time
pagecreate(page=a) a 1994 2050
pageselect q
smpl @all

' Provoide the FICA87ON.xls file from which to load data
%file = "C:\Users\032158\OneDrive - Social Security Administration\Documents\usr\pvlasenk\941Data\NewProcess\FICA87ON.xls"

%userpin = @env("USERNAME")

spool _ReadMeFirst

string line1 = "This file was created on " + @date + " at " + @time + " by " + %userpin
string line2 = "This file contains data loaded from " + %file + @chr(13) + _
					"This is the initial (one time only!) load of data to capture all the data that have been entered by hand in the past. " + @chr(13) + _
					"In the future these data will be updated via a program, not by hand."
string line3 = "This file is inteneded and a snapshot of FICA87ON.xls file as of the last time it was updated by hand."
string line4 = "At the itme of this data load, FICA87ON.xls file was updated to include data from all the 941 reports dated up to and including April 2022."
string line5 = "In this file, the period corresponds to the date the 941 data were REPORTED, and the series names indicate which year the data reflect." + @chr(13) + _
					"For example, wsnal119 means 'NonAg wages for year 2019', and the value of wsnal119 in period 2022Q1 means the value reported for 'NonAg wages for year 2019' in Jan 2022 report. " + @chr(13) + _
					"941 data are reported quarterly, which is why I store these series with quarterly frequency."

_ReadMeFirst.insert line1 line2 line3 line4 line5
delete line*

import %file range="latetips2" colhead=1 namepos=last @freq q 1997q1
delete series01

import %file range="latewsna2" colhead=1 namepos=last @freq q 1997q1
delete series01

import %file range="lateag2" colhead=1 namepos=last @freq q 1997q1
delete series01

import %file range="late944" colhead=1 namepos=last @freq q 1997q1
delete series01


