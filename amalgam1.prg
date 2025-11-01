'This program estimates andover equations based on the adjusted empirical wage distribution.
'  Created by Tony Cheng long ago
'  Modified by Sven Sinclair in November 2022 for the 2020 distribution used in TR23
'  Modified by Sven Sinclair in November 2023 for the 2021 distribution used in TR24 and automated data import;
'     also separated the program into 3 parts; this is the second part, estimating single-year equations

'EDIT THE YEAR PARAMETERS
'This is the TR year:
%tyr = "25"
'This is the wage distribution year, generally 3 years before the TR year for which it will be used.
%wyr = "22"

'EDIT THE OUTPUT FILE
output(t) s:\lrecon\Data\Processed\TaxableEarnings\TR20{%tyr}\andovereqn{%tyr}tr1corr

'open the amalgam workfile
wfopen s:\lrecon\Data\Processed\TaxableEarnings\TR20{%tyr}\amalgam00{%wyr}corr.wf1

' andover equations for the latest year wage distribution
smpl 1950 1954
equation rao20{%wyr}1.ls(p) rao{%wyr}100jan-1 rm{%wyr}100jan^0.5 rm{%wyr}100jan^0.95

smpl 1952 1961
equation rao20{%wyr}2.ls(p) rao{%wyr}100jan c rm{%wyr}100jan^0.55 exp(-0.75*rm{%wyr}100jan)

smpl 1959 1970
equation rao20{%wyr}3.ls(p) rao{%wyr}100jan c exp(-0.3*rm{%wyr}100jan) exp(-1.35*rm{%wyr}100jan)

smpl 1968 1978
equation rao20{%wyr}4.ls(p) rao{%wyr}100jan c exp(-0.4*rm{%wyr}100jan) exp(-1.5*rm{%wyr}100jan)

smpl 1976 1990
equation rao20{%wyr}5.ls(p) rao{%wyr}100jan c exp(-0.15*rm{%wyr}100jan) exp(-0.4*rm{%wyr}100jan) exp(-1.15*rm{%wyr}100jan)

smpl 1988 1994
equation rao20{%wyr}6.ls(p) rao{%wyr}100jan rm{%wyr}100jan^(-1.69)

output off


