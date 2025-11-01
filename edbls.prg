' This program calculates civilian noninstitutional population by sex and 
' age group for the final two months of the year. 

' November & December data are not available from the BLS at this time, so OCACT makes estimates:
'  1.  Calculate growth in civilian noninstitutional population from September to October
'  2.  Apply the growth rate to the October population to generate the November population.
'  3.  Repeat to get the December values.
' All estimates are made for each age-sex group

' NOTES: Be sure to modify the sample period below as needed
'        After running this program, you must run upd1.prg

exec .\setup2

wfselect work
pageselect m

wfopen bkdrw.wf1
wfselect work

%x1 = _
   "npcmt1617_u npcmt1819_u npcmt2024_u npcmt2529_u npcmt3034_u npcmt3539_u npcmt4044_u " + _
   "npcmt4549_u npcmt5054_u npcmt5559_u npcmt6064_u npcmt6569_u npcmt7074_u npcmtge75_u " + _
   "npcmt1619_u npcmt2534_u npcmt3544_u npcmt4554_u npcmt5564_u npcmtge65_u npcmt_u " + _
   "npcft1617_u npcft1819_u npcft2024_u npcft2529_u npcft3034_u npcft3539_u npcft4044_u " + _
   "npcft4549_u npcft5054_u npcft5559_u npcft6064_u npcft6569_u npcft7074_u npcftge75_u " + _
   "npcft1619_u npcft2534_u npcft3544_u npcft4554_u npcft5564_u npcftge65_u npcft_u"

for %s {%x1}
   copy bkdrw::m\{%s} work::m\{%s}
next

copy bkdrw::m\npctt_u work::m\npctt_u

%x2 = _
   "npcmt1617_u npcmt1819_u npcmt2024_u npcmt2529_u npcmt3034_u npcmt3539_u npcmt4044_u " + _
   "npcmt4549_u npcmt5054_u npcmt5559_u npcmt6064_u npcmt6569_u npcmt7074_u npcmtge75_u " + _
   "npcft1617_u npcft1819_u npcft2024_u npcft2529_u npcft3034_u npcft3539_u npcft4044_u " + _
   "npcft4549_u npcft5054_u npcft5559_u npcft6064_u npcft6569_u npcft7074_u npcftge75_u"


smpl 2024M11 2024M12 ' In a "normal" year, this would be M11 thru M12
   
for %i {%x2}
   {%i} = ({%i}(-1)/{%i}(-2)) * {%i}(-1)
next


npcmt1619_u = npcmt1617_u + npcmt1819_u
npcmt2534_u = npcmt2529_u + npcmt3034_u
npcmt3544_u = npcmt3539_u + npcmt4044_u
npcmt4554_u = npcmt4549_u + npcmt5054_u
npcmt5564_u = npcmt5559_u + npcmt6064_u
npcmtge65_u = npcmt6569_u + npcmt7074_u + npcmtge75_u
npcmt_u     = npcmt1619_u + npcmt2024_u + npcmt2534_u + npcmt3544_u + npcmt4554_u + npcmt5564_u + npcmtge65_u

npcft1619_u = npcft1617_u + npcft1819_u
npcft2534_u = npcft2529_u + npcft3034_u
npcft3544_u = npcft3539_u + npcft4044_u
npcft4554_u = npcft4549_u + npcft5054_u
npcft5564_u = npcft5559_u + npcft6064_u
npcftge65_u = npcft6569_u + npcft7074_u + npcftge75_u
npcft_u     = npcft1619_u + npcft2024_u + npcft2534_u + npcft3544_u + npcft4554_u + npcft5564_u + npcftge65_u

npctt_u = npcft_u + npcmt_u

smpl @all

copy work::m\* bkdrw::m\*

wfselect bkdrw
wfsave(2) bkdrw
wfclose bkdrw

delete *


