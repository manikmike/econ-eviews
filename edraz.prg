


exec .\setup2


wfopen bkdr1.wf1

wfselect work
pageselect q
smpl @all

genr craz1 = bkdr1.wf1::q\craz1
genr mraz  = bkdr1.wf1::q\mraz



' CRAZ1 ***************************************************************

' NOTE: CHCOC is a better source than OPM. This is because CHCOC includes locality pay whereas OPM does not. In the future, just use CHCOC.
' 2024
' https://www.chcoc.gov/transmittals
' search
' https://www.chcoc.gov/content/january-2024-pay-adjustments

smpl 2024q1 2024q4
craz1.fill(s) _
.052, 0, 0, 0



' MRAZ ***************************************************************

' NOTE: defense.gov is a better source than dfas.mil. This is because the link stays constant every year and the pay raise is easier to read. In the future, just use defense.gov.
' 2024
' https://militarypay.defense.gov/Pay/Basic-Pay/AnnualPayRaise/

smpl 2024q1 2024q4
mraz.fill(s) _
.052, 0, 0, 0



' store in BKDR1.wf1 ***************************************************************

copy craz1 bkdr1::q\craz1
copy mraz  bkdr1::q\mraz

delete craz1 mraz

wfselect bkdr1
wfsave(2) bkdr1

wfclose bkdr1


