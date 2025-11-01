' This program adds an additional year of data to the March CPS
' workfile (cpso68YYY.wf1)
' IMPORTANT: Click "OK TO ALL" when the program complains about illegal workfile names

!year = 2024 ' latest year of updated data
%dbname = "cpso68" + @str(!year - 1900) + ".wf1"

exec .\cpsr_male_and_female !year

exec .\cpsr_femalecu6 !year

exec .\cpsr_femalec6o !year

' Create a workfile (cpsrYYY.wf1) with an additional year of raw data
exec .\cpsr !year

' Append the additional year of raw data to data from cpsr68(YYY-1).wf1
' into a new workfile cpsr68YYY.wf1
exec .\ccps !year

' Create an operational workfile (cpso68YYY.wf1) for later
'db(type=aremos) %dbname
exec .\setup2
wfsave %dbname
close @wf

' Populate the operational workfile
exec .\updcps4 !year


