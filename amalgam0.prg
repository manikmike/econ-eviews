'This program estimates andover equations based on the adjusted empirical wage distribution.
'  Created by Tony Cheng long ago
'  Modified by Sven Sinclair in November 2022 for the 2020 distribution used in TR23
'  Modified by Sven Sinclair in November 2023 for the 2021 distribution used in TR24 and automated data import;
'     also separated the program in three parts; this is the first part, which imports data from Excel to the EViews workfile
' Modified by Sven Sinclair in November 2024 to eliminate the need to routinely edit more than the years at the beginning

'EDIT THE YEAR PARAMETERS
'This is the TR year:
%tyr = "25"
'This is the previous TR year, i.e., tyr-1:
%ptyr = "24"
'This is the wage distribution year, generally 3 years before the TR year for which it will be used.
%wyr = "22"
'This is the previous wage distribution year, generally wyr-1:
%pwyr = "21"

' INPUT FILE (Excel with annual distribution) AND AMALGAM FILE (EViews workfile) - EDIT ONLY IF NEEDED (e.g., might need to edit the year in both path and file name if this is a correction of a past year's process)
'NOTE: EDITS IN THIS VERSION. REMOVE "CORR" NEXT YEAR!
%anndistfile = "s:\lrecon\Data\Processed\TaxableEarnings\TR20" + %tyr + "\taxratcur" + %wyr +"corr.xlsx"
%amalfile = "s:\lrecon\Data\Processed\TaxableEarnings\TR20" + %tyr + "\amalgam00" + %wyr+ "corr.wf1"
%old_amalfile = "s:\lrecon\Data\Processed\TaxableEarnings\TR20" + %ptyr + "\amalgam00" + %pwyr+ ".wf1"

'Copy the old amalgam file to the new folder with a new name - EDIT ONLY IF NEEDED:
shell copy {%old_amalfile} {%amalfile}

'open the amalgam workfile
wfopen {%amalfile}
smpl @all

'import the andover and relmax from annual distribution spreadsheet into the amalgam workfile
%tb = "20" + %wyr + "dist"
%aoser = "rao" + %wyr + "100jan"
%rmser = "rm" + %wyr + "100jan"
import %anndistfile range=%tb!AK8:AK52 names=%aoser @freq a 1950
import %anndistfile range=%tb!AL8:AL52 names=%rmser @freq a 1950

wfsave {%amalfile}


