'This program estimates amalgam andover ratio equations as a function of amalgam relmax.
'  Created by Tony Cheng in Aremos long ago
'  Modified by Sven Sinclair in November 2023, carving it out from amalgam.prg

'EDIT THE YEAR PARAMETERS
'This is the TR year:
%tyr = "25"
'This is the wage distribution year, generally 3 years before the TR year for which it will be used.
%wyr = "22"
'EDIT THE COLUMN FOR AMALGAMATED ANDOVER RATIO IN THE INPUT FILE (This changes every year as columns are inserted)
%aoc = "DQ"

'INPUT FILE (Excel with amalgam distribution) - EDIT IF NEEDED (years now change automatically, edits may be needed if there are corrections or other runs outside the routine)
'NOTE: EDITED. NEXT YEAR, CHANGE 'Corrected' BACK TO 'Decdata'.
%amaldistfile = "s:\lrecon\Data\Processed\TaxableEarnings\TR20"+%tyr+"\Amalgam200020"+%wyr+"Corrected.xlsx"

'TEXT OUTPUT FILE - EDIT IF NEEDED (see above for possible reasons)
'NOTE: EDITED. NEXT YEAR, REMOVE 'Corr'
output(t) s:\lrecon\Data\Processed\TaxableEarnings\TR20{%tyr}\andovereqn{%tyr}tr2Corr

'open the amalgam workfile
wfopen s:\lrecon\Data\Processed\TaxableEarnings\TR20{%tyr}\amalgam00{%wyr}Corr.wf1

'import the andover and relmax from annual distribution spreadsheet into the amalgam workfile
%tb = "MainSheet"
%aoser = "raoamal00" + %wyr + "j"
import %amaldistfile range=%tb!{%aoc}29:{%aoc}73 names=%aoser @freq a 1950

' andover equations for the amalgam distribution for years since 2000

smpl 1950 1954
equation raoamal00{%wyr}1.ls(p) raoamal00{%wyr}j-1 rm{%wyr}100jan^0.5 rm{%wyr}100jan

smpl 1952 1960
equation raoamal00{%wyr}2.ls(p) raoamal00{%wyr}j c rm{%wyr}100jan^0.5 exp(-0.69*rm{%wyr}100jan)

smpl 1958 1970
equation raoamal00{%wyr}3.ls(p) raoamal00{%wyr}j c exp(-0.25*rm{%wyr}100jan) exp(-1.3*rm{%wyr}100jan)

smpl 1967 1976
equation raoamal00{%wyr}4.ls(p) raoamal00{%wyr}j c exp(-0.3*rm{%wyr}100jan) exp(-1.55*rm{%wyr}100jan)

smpl 1974 1987
equation raoamal00{%wyr}5.ls(p) raoamal00{%wyr}j c exp(-0.15*rm{%wyr}100jan) exp(-0.4*rm{%wyr}100jan) exp(-1.25*rm{%wyr}100jan)

'THE LAST EQUATION HAS ONLY ONE PARAMETER. YOU MAY NEED TO ITERATE WITH DIFFERENT VALUES OF THIS TAIL PARAMETER UNTIL YOU GET THE BEST FIT.
smpl 1986 1994
equation raoamal00{%wyr}6.ls(p) raoamal00{%wyr}j rm{%wyr}100jan^(-1.86)


output off


