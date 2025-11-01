'This program estimates andover equations based on the adjusted empirical wage distribution.
'  Created by Tony Cheng long ago
'  Modified by Sven Sinclair in November 2022 for the 2020 distribution used in TR23
'  Modified by Sven Sinclair in November 2023 for the 2021 distribution used in TR24 and automated data import;
'     also carved out what used to be a second half as a separate standalone program

'EDIT THE YEAR PARAMETERS
'This is the TR year:
%tyr = "24"
'This is the wage distribution year, generally 3 years before the TR year for which it will be used.
%wyr = "21"

'EDIT THE INPUT FILE (Excel with annual distribution; typically edit the year in both path and file name)
%anndistfile = "s:\lrecon\Data\Processed\TaxableEarnings\TR2024\taxratcur21.xlsx"

'EDIT THE YEARS IN THE FOLLOWING LINE (copying last year's workfile to this year's folder):
shell copy s:\lrecon\Data\Processed\TaxableEarnings\TR2023\amalgam0020.wf1 s:\lrecon\Data\Processed\TaxableEarnings\TR2024\amalgam0021.wf1

'EDIT THE OUTPUT FILE
output(t) s:\lrecon\Data\Processed\TaxableEarnings\TR2024\andovereqn24tr

'open the amalgam workfile
wfopen s:\lrecon\Data\Processed\TaxableEarnings\TR20{%tyr}\amalgam00{%wyr}.wf1

'import the andover and relmax from annual distribution spreadsheet into the amalgam workfile
%tb = "20" + %wyr + "dist"
%aoser = "rao" + %wyr + "100jan"
%rmser = "rm" + %wyr + "100jan"
import %anndistfile range=%tb!AK8:AK52 names=%aoser @freq a 1950
import %anndistfile range=%tb!AL8:AL52 names=%rmser @freq a 1950

' andover equations for the latest year wage distribution
smpl 1950 1954
equation rao20{%wyr}1.ls(p) rao{%wyr}100jan-1 rm{%wyr}100jan^0.5 rm{%wyr}100jan^0.95

smpl 1952 1960
equation rao20{%wyr}2.ls(p) rao{%wyr}100jan c rm{%wyr}100jan^0.55 exp(-0.75*rm{%wyr}100jan)

smpl 1958 1969
equation rao20{%wyr}3.ls(p) rao{%wyr}100jan c exp(-0.3*rm{%wyr}100jan) exp(-1.35*rm{%wyr}100jan)

smpl 1967 1977
equation rao20{%wyr}4.ls(p) rao{%wyr}100jan c exp(-0.4*rm{%wyr}100jan) exp(-1.5*rm{%wyr}100jan)

smpl 1976 1988
equation rao20{%wyr}5.ls(p) rao{%wyr}100jan c exp(-0.15*rm{%wyr}100jan) exp(-0.4*rm{%wyr}100jan) exp(-1.15*rm{%wyr}100jan)

smpl 1986 1994
equation rao20{%wyr}6.ls(p) rao{%wyr}100jan rm{%wyr}100jan^(-1.75)

output off


