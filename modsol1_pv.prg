' This program replicated MODSOL1 equations that create projected RUs and LFPRs by age and sex groups.

' Questions and notes:
' (1) What period should I compute ru_fe's for? Right now I start them from 2018Q4 (%proj_start). NEW: I compute ru_fe's as far back as possible (this depends on how far back we have rtp and ru series).
' (2) What period should I compute the asa series for? Right now I start them from 2018Q4 (%proj_start). NEW: I compute them as far back as possible. This depends on the availability of ru series by age/sex. In practice this means that asa series start in 1981 (the limiting factor is 75o series, which start in 1981). 
' (3) Right now this is done using several series from a-bank (historical r[sex][age], historical base-year labor force, historical and projected rtp, historical and projected minw). Presumably, when we run this during TR season, the a-bank does not yet exist. Need to account for it in the program. Will there be a separate databank, or workfile, that contains these series even when we do not yet have a compleet a-bank?
' (4) The program also uses several series from add-factor bank -- r[sex][age]_p_add, ru_asa_adj. Do we normally have adtrXXX.bnk at the time we run modsol1?
' (5) Think about how to create the addfactors within this program, instead of having to load them from adtrXXX databank. This would be much more convenient.
' (6) In two places below -- marked by ' extend rtp' and ' extend ru_asa_adj' I am extending some projected series forward to 2199. This may not be needed in the future, if/when these series come properly extended in the source databank.
' (7) If we move from databanks to workfiles, need to change all fetch commands.
' (8) Make sure that the base year I use for asa values is correct -- %asa_by = "2011"		' this means 'use ANNUAL 2011 values'
' (9) FE run. Right now FE runs along with the rest of the program. Are there any a siatuation when we want to do an FE run, but are unable yet to run the rest of the program? In other words, should I structure this so that we can run ONLY the FE run?


' ---- Polina Vlasenko

' ******** UPDATE inputs here *******
'estimated equations
%ru_eqs = "ru_eqns_ncmw" 	'short name of the workfile contaning estimated equations for RUs (they will be dru's, i.e. first differences)
%ru_eqs_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1\ru_eqns_ncmw.wf1" 		' full path to the file

%TR = "2019"
!TRyr = 2019

'data for projections
' a-bank -- for rtp (historical and projected), minw (historical), ru's (historical)
%abank = "atr192"
%abank_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1\banks\atr192.bnk"

' a-bank from orevious TR -- need this to compute the ru targets
%abank_pr = "atr182"
%abank_pr_path = "\\"

' adtr-bank -- for add factors for ru_p equations.
%adbank = "adtr192"
%adbank_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1\banks\adtr192.bnk"

' period where the projections start; program will assume that we have data up to the previous period for sure.
%last_hist = "2018Q3"		' last historical period
%proj_start = "2018Q4"	' first projection period
!proj_yr = 2019 				' first full year of projection period (must be consistent with %proj_start above)
!end_yr = 2199 				' last year of the projection period; should not change for a LONG time
!add_per = 6 					' the number of years over which to phase in r..._p_add addfactors

' base year for age-sex-adjusted values
%asa_by = "2011"		' this means 'use ANNUAL 2011 values'

' Partial run -- this will produce the series that can be used to develop ru_asa_adj addfactor.
' Stop the program prior to the point where ru_asa_adj is applied. 
' enter Y to stop the program at ru_asa_adj, enter N to run full program.
%asa_adj_stop = "N" ' enter "Y" or "N" (case sensitive)


' output created by this program
%this_file = "modsol1_eqns" 	' name of the file 
%output_path = "\\s1f906b\econ\Off-Season Work\2019\LFPR_MODSOL1" + "\" + %this_file + ".wf1"

'save option
' Do you want the output file(s) to be saved on this run? 
' Enter N for testing/trial runs. 
' Enter Y only for the final run -- be SURE that the output location is correct because wfsave OVERWRITES any existing files with identical names without any warning!
%sav = "N" 		' enter "N" or "Y" 

' ******* END of update section

' various parameters currently used in the model

'Okun's law coefficient
!ol = 1 '50/44.72	' this may be different in the future; or it may be derived from within the program in the future -- hence I am not putting it into the UPDATE section above



wfcreate(wf={%this_file}, page=q) q 1900Q1 {!end_yr}Q4		' What should be the sample period?
pageselect q

'*** 1. Copy in the estimated dRU equations.
'*** We will need the estimated coefficients from these.
wfopen {%ru_eqs}
copy {%ru_eqs}::q\eq_* {%this_file}::q\
wfclose {%ru_eqs}

'*** 2. Get values for exogenous variables -- rtp, minw, lc
dbopen(type=aremos) {%abank} 
fetch rtp.q minw.q ru.q

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      fetch r{%s}{%a}.q 
   next
next

' extend rtp to the end of sample; This may not be necessary in the future when the rtp series in the databank will have values for the appropriate period
smpl 2099Q4 @last
rtp = 1

smpl @all

pagecreate(wf={%this_file}, page=a) a 1900 {!end_yr}
pageselect a
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      fetch l{%s}{%a}.a
   next
next
fetch lcm.a lcf.a lc.a

close @db

'create 'base-yr values' of LC
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      !l{%s}{%a}_by = @elem(l{%s}{%a}, %asa_by)
   next
next
!lcm_by = @elem(lcm, %asa_by)
!lcf_by = @elem(lcf, %asa_by)
!lc_by = @elem(lc, %asa_by)

' load addfactors -- this is done only for the ggregate; for age-sex groups the addfactors are computed withing the program. **** MOVE this to the later part of code called **** 8. Unemployment rates, final. In the prliminary run that stops at %asa_adj_stop, there will not be any addfactor to load. Thus, need to move thsi fetch command later in the program for when we have gotten though the preliminary run. 
pageselect q
smpl @all
dbopen(type=aremos) {%adbank} 
'for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'   for %s m f
'      fetch r{%s}{%a}_p.add 
'      series r{%s}{%a}_p_addc = @cumsum(r{%s}{%a}_p_add)		' need a cumulative addfactor if applying to to the complete series
'   next
'next
fetch ru_asa_adj.q
close @db

' extend ru_asa_adj past 2099Q4???? This may not be necessary in the future when the series in the databank will have values for the appropriate period
smpl 2099Q4 @last
ru_asa_adj = ru_asa_adj(-1)



'**** 3. Unemployment rates, Full Employment Differentials
'*** This needs to be done before creating r..._p_add addfactors
pageselect q

' create 'alternative rtp' series 
smpl @all
series rtp_orig = rtp 		' save the original rtp series so that we can restore it later
series rtp_diff = 1 - rtp 	' this is deviation from rtp each period;
' we now need to create a series such that first difference of it will be equal to rtp_diff, and we must name that series rtp
rtp = @cumsum(rtp_diff) 	' this is 'new rtp'; we must have a series named exactly 'rtp' to obtain the predicted values from the estimated dru equations, I cannot do so with a series named, say, rtp_diff. 
' check that thes alternative rtp is exactly what we need; the check below should be zero
'series rtp_diff_ck = rtp_diff - d(rtp)

' get predicted values from dru equations, which will now use the new values of rtp = @cumsum(rtp_diff)
smpl @all		' QQQQ: over what period do we need to create ru_fe's?
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	eq_dr{%s}{%a}.forecast(d, f=actual) dr{%s}{%a}_fe		' create predicted values for dru's, these are the predicted value for the fist differences, not the levels
     	 	series dr{%s}{%a}_fe = dr{%s}{%a}_fe * !ol					' apply OL coef
     	next
next
' restore rtp to the original series
rtp = rtp_orig
delete rtp_orig rtp_diff
' ******

'**** 4. Create Projected values, preliminary --  r.._p***

' remove projected values of RUs
pageselect q
smpl {%proj_start} @last
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      r{%s}{%a} = na
   next
next

' set all future values of minw to zero
'minw = 0

' create "past" values of ru_p's that we might need for forecast
!y1 = !proj_yr -2
smpl {!y1}Q4 {%last_hist}
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	series r{%s}{%a}_p = r{%s}{%a}
     	next
next

smpl {%proj_start} @last		' Projection period

' get predicted values from estimated equations
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	eq_dr{%s}{%a}.forecast(f=actual) r{%s}{%a}_p	 'create predicted values, name them r[sex][age]_p, such as rm2024_p
     	next
next

' **** 5. Create r..._p_add addfactors -- in a separate page so as not to mix up rtp and ru series
pagecreate(wf={%this_file}, page="targets") q 1900Q1 {!end_yr}Q4
pageselect targets
dbopen(type=aremos) {%abank_pr} 
fetch rtp.q

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
      fetch r{%s}{%a}.q 
      fetch r{%s}{%a}_fe.q			' QQQ: Why am I fetching r.._fe's from the a-bank? Are they used anywhere?
   next
next
close @db

%yr_last_hist = @left(%last_hist, 4)	
%yr1 = @str(@val(%yr_last_hist) - 31)
%yr2 = @str(@val(%yr_last_hist) - 1)
smpl {%yr1}Q1 {%yr2}Q3		
series rtp1 = rtp -1
series tr = @trend - @elem(@trend,%proj_start)

smpl {%yr1}Q1 {%yr2}Q3		' sample should be exactly the latest 30 yrs (120 quarters) of historical data, ending exactly 1 yr before %last_hist
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
       equation eq_r{%s}{%a}_trgt.ls r{%s}{%a} tr rtp1 rtp1(-1) rtp1(-2) rtp1(-3) c		' estimated constant terms in these equations are the targets
       scalar r{%s}{%a}_fe_tgt = eq_r{%s}{%a}_trgt.@coef(6)									' save the target (i.e. estimated constant term) in the scalar -- QQQ Can this be done with just ! element, or do we need to save the scalars for later use?
   next
next

'   Unemployment Rate Adjustments for Initial Error

'   Linearly phasing out the initial error over 6 years (24 quarters) (or other period defined above in !add_per)
'   Initial errors are differences between the target full-employment unemployment rates
'   and the sum of preliminary unemployment rate and the full-employment differential
'   for the first projection quarter (2018Q4)

pageselect q
smpl @all
copy targets\*_tgt q\			' copy the target to q page

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
       series r{%s}{%a}_p_add = 0			' initiate r..._p_add series
   next
next

!yr1 = !proj_yr
!yr2 = !yr1 + !add_per -1
smpl {!yr1}Q1 {!yr2}Q4			' period over which r..._p_add addfactors are phased in, note the quarters!
!nq = 4 *(!yr2 - !yr1)				' number of quarters in this period

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
   for %s m f
       !r{%s}{%a}_ierr = r{%s}{%a}_fe_tgt - @elem(r{%s}{%a}_p, %proj_start) - @elem(dr{%s}{%a}_fe, %proj_start)			' create the initial errors
       r{%s}{%a}_p_add =  !r{%s}{%a}_ierr / !nq 				' these are the addfactor series 
       series r{%s}{%a}_p_addc = @cumsum(r{%s}{%a}_p_add)		' need a cumulative addfactor if applying to to the complete series
   next
next
' *** done with r..._p_add addfactors


'**** 6. apply addfactors; there is no way to apply Okun's law coefficicnts in this specification!

pageselect q

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	r{%s}{%a}_p = r{%s}{%a}_p + r{%s}{%a}_p_addc		' addfactor is here; OL coef is not!!!!!!
     	next
next

'***** 5alt & 6alt. Alternative -- forecast dru's (instead of ru's), apply OL, then create ru_p's by hand *****
' delete r*_p 	' this deletes ru_p' computed above

'smpl {%proj_start} @last
' get predicted values from equations
'for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'  	for %s m f
'     	 	eq_dr{%s}{%a}.forecast(d, f=actual) dr{%s}{%a}_p		' create predicted values for dru's
'     	 	series dr{%s}{%a}_p = dr{%s}{%a}_p * !ol					' apply OL coef
'     	next
'next

'for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'  	for %s m f
'     	 	smpl {%proj_start}Q4 {%proj_start}				' to create dynamic projected values (i.e. using lagged ru_p's) we much iterate through time periods! this is what EViews does automatically with .forecast command when we do not need to apply OL coef.
'     	 	series r{%s}{%a}_p = r{%s}{%a}_p(-1) + dr{%s}{%a}_p + r{%s}{%a}_p_add		' create ru (level) and apply addfactor
'     	 	for !y=!proj_yr to !end_yr
'     	 		smpl {!y}Q1 {!y}Q1
'     	 		series r{%s}{%a}_p = r{%s}{%a}_p(-1) + dr{%s}{%a}_p + r{%s}{%a}_p_add		' create ru (level) and apply addfactor
'     	 		smpl {!y}Q2 {!y}Q2
'     	 		series r{%s}{%a}_p = r{%s}{%a}_p(-1) + dr{%s}{%a}_p + r{%s}{%a}_p_add		' create ru (level) and apply addfactor
'     	 		smpl {!y}Q3 {!y}Q3
'     	 		series r{%s}{%a}_p = r{%s}{%a}_p(-1) + dr{%s}{%a}_p + r{%s}{%a}_p_add		' create ru (level) and apply addfactor
'     	 		smpl {!y}Q4 {!y}Q4
'     	 		series r{%s}{%a}_p = r{%s}{%a}_p(-1) + dr{%s}{%a}_p + r{%s}{%a}_p_add		' create ru (level) and apply addfactor
'     	 	next
'     	next
'next
'smpl 1948Q1 {!end_yr}Q4

' compare ru_p's and ru_ph's -- this is irrelevant now (ru_ph's used to eb the ones computed by manual iteration above)

'for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'  	for %s m f
'     	 	series r{%s}{%a}_ck = r{%s}{%a}_p - r{%s}{%a}_ph 
'     	next
'next

'***** END of Alternative version***

'**** 7. ASA values, preliminary
smpl @all
series rum_asa_p =   (rm1617_p * !lm1617_by + _
                  rm1819_p * !lm1819_by + _
                  rm2024_p * !lm2024_by + _
                  rm2529_p * !lm2529_by + _
                  rm3034_p * !lm3034_by + _
                  rm3539_p * !lm3539_by + _
                  rm4044_p * !lm4044_by + _
                  rm4549_p * !lm4549_by + _
                  rm5054_p * !lm5054_by + _
                  rm5559_p * !lm5559_by + _
                  rm6064_p * !lm6064_by + _
                  rm6569_p * !lm6569_by + _
                  rm7074_p * !lm7074_by + _
                  rm75o_p  * !lm75o_by  )/ !lcm_by
                  
series ruf_asa_p =   (rf1617_p * !lf1617_by + _
                  rf1819_p * !lf1819_by + _
                  rf2024_p * !lf2024_by + _
                  rf2529_p * !lf2529_by + _
                  rf3034_p * !lf3034_by + _
                  rf3539_p * !lf3539_by + _
                  rf4044_p * !lf4044_by + _
                  rf4549_p * !lf4549_by + _
                  rf5054_p * !lf5054_by + _
                  rf5559_p * !lf5559_by + _
                  rf6064_p * !lf6064_by + _
                  rf6569_p * !lf6569_by + _
                  rf7074_p * !lf7074_by + _
                  rf75o_p  * !lf75o_by  )/ !lcf_by

series ru_asa_p  = (rum_asa_p * !lcm_by  + ruf_asa_p * !lcf_by) / !lc_by

'create groups for convenient viewing
smpl 1948Q1 @last
group males_ru_p rm1617_p rm1819_p rm2024_p rm2529_p rm3034_p rm3539_p rm4044_p rm4549_p rm5054_p rm5559_p rm6064_p rm6569_p rm7074_p rm75o_p rum_asa_p
group females_ru_p rf1617_p rf1819_p rf2024_p rf2529_p rf3034_p rf3539_p rf4044_p rf4549_p rf5054_p rf5559_p rf6064_p rf6569_p rf7074_p rf75o_p ruf_asa_p


' **** intermediate stop here for determining ru_asa_adj ****
' ru_asa_adj is derived separately from this program, using professional judgement. Stopping the program here allows the user to see the series needed for developing ru_asa_adj.

if %asa_adj_stop = "Y" then
	smpl @all
	string msg = "Program stopped prior to applying ru_asa_adj factor. Please save the workfile manually. "
	show msg
	spool _summary
	string line1 = "This file was created on " + @date + " at " + @time
	string line2 = "The file contains the PRELIMINARY projected values fo RUs."
	string line3 = "These preliminary values can be used to develop the ru_asa_adj addfactor. "
	string line4 = "The projections use the estimated coefficients from  " + %ru_eqs_path + " for RUs."
	string line5 = "Polina Vlasenko"

	_summary.insert line1 line2 line3 line4 line5 

	delete line*
	stop
endif



'**** 8. Unemployment rates, final
smpl {%proj_start} @last

for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	r{%s}{%a} = r{%s}{%a}_p * (1+ru_asa_adj / ru_asa_p)
     	next
next

'**** 9.  ASA values, final
smpl @all
series rum_asa =   (rm1617 * !lm1617_by + _
                  rm1819 * !lm1819_by + _
                  rm2024 * !lm2024_by + _
                  rm2529 * !lm2529_by + _
                  rm3034 * !lm3034_by + _
                  rm3539 * !lm3539_by + _
                  rm4044 * !lm4044_by + _
                  rm4549 * !lm4549_by + _
                  rm5054 * !lm5054_by + _
                  rm5559 * !lm5559_by + _
                  rm6064 * !lm6064_by + _
                  rm6569 * !lm6569_by + _
                  rm7074 * !lm7074_by + _
                  rm75o  * !lm75o_by  )/ !lcm_by
                  
series ruf_asa =   (rf1617 * !lf1617_by + _
                  rf1819 * !lf1819_by + _
                  rf2024 * !lf2024_by + _
                  rf2529 * !lf2529_by + _
                  rf3034 * !lf3034_by + _
                  rf3539 * !lf3539_by + _
                  rf4044 * !lf4044_by + _
                  rf4549 * !lf4549_by + _
                  rf5054 * !lf5054_by + _
                  rf5559 * !lf5559_by + _
                  rf6064 * !lf6064_by + _
                  rf6569 * !lf6569_by + _
                  rf7074 * !lf7074_by + _
                  rf75o  * !lf75o_by  )/ !lcf_by

series ru_asa  = (rum_asa * !lcm_by  + ruf_asa * !lcf_by) / !lc_by

'create groups for convenient viewing
smpl 1948Q1 @last
group males_ru rm1617 rm1819 rm2024 rm2529 rm3034 rm3539 rm4044 rm4549 rm5054 rm5559 rm6064 rm6569 rm7074 rm75o rum_asa
group females_ru rf1617 rf1819 rf2024 rf2529 rf3034 rf3539 rf4044 rf4549 rf5054 rf5559 rf6064 rf6569 rf7074 rf75o ruf_asa

' ***** Unemployment rates, Full Employment Differentials
' This would be easier to do within Model object as a scenario with alternative values for rtp

' create alternative rtp series 
'smpl @all
'series rtp_orig = rtp 		' save the original rtp series so that we can restore it later
'series rtp_diff = 1 - rtp 	' this is deviation from rtp each period;
' we now need to create a series such that first fifference of it will be equal to rtp_diff, and we must name that series rtp
'rtp = @cumsum(rtp_diff) 	' this is 'new rtp'; we must have a series named exactly 'rtp' to obtain the predicted values from the estimated dru equations, I cannot do so with a series named, say, rtp_diff. Using series with an alternative name, like rtp_diff,  would be possible if doing this as a scenario within a model object.
' check that thes alternative rtp is exactly what we need; the check below should be zero
'series rtp_diff_ck = rtp_diff - d(rtp)


' get predicted values from dru equations, which will now use the new values of rtp = @cumsum(rtp_diff)
'smpl @all		' QQQQ: over what period do we need to create ru_fe's?
'for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
'  	for %s m f
'     	 	eq_dr{%s}{%a}.forecast(d, f=actual) dr{%s}{%a}_fe		' create predicted values for dru's
'     	 	series dr{%s}{%a}_fe = dr{%s}{%a}_fe * !ol					' apply OL coef
'     	next
'next
' restore rtp to the original series
'rtp = rtp_orig
'delete rtp_orig

' ***** 10. Unemployment rates, Full Employment -- compute the levels ru_fe
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	series r{%s}{%a}_fe = r{%s}{%a} + dr{%s}{%a}_fe
     	next
next

'create groups for convenient viewing
smpl 1948Q1 @last
group males_ru_fe rm1617_fe rm1819_fe rm2024_fe rm2529_fe rm3034_fe rm3539_fe rm4044_fe rm4549_fe rm5054_fe rm5559_fe rm6064_fe rm6569_fe rm7074_fe rm75o_fe
group females_ru_fe rf1617_fe rf1819_fe rf2024_fe rf2529_fe rf3034_fe rf3539_fe rf4044_fe rf4549_fe rf5054_fe rf5559_fe rf6064_fe rf6569_fe rf7074_fe rf75o_fe









' do the same using EViews Model object
' the Model object is not letting me use !lm1617_by. It seems it needs permanent object in the workfile, so I am redoing all the _by numbers as scalar.
pageselect q
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	scalar l{%s}{%a}_by = !l{%s}{%a}_by 
     	next
next
scalar lcm_by = !lcm_by
scalar lcf_by = !lcf_by
scalar lc_by = !lc_by

model ru_proj	' declare the model
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	ru_proj.merge eq_dr{%s}{%a} 
     	next
next

ru_proj.append rum_asa =   (rm1617 * lm1617_by + rm1819 * lm1819_by + rm2024 * lm2024_by + rm2529 * lm2529_by + rm3034 * lm3034_by + rm3539 * lm3539_by + rm4044 * lm4044_by + rm4549 * lm4549_by + rm5054 * lm5054_by + rm5559 * lm5559_by + rm6064 * lm6064_by + rm6569 * lm6569_by + rm7074 * lm7074_by + rm75o  * lm75o_by  )/ lcm_by
ru_proj.append ruf_asa =   (rf1617 * lf1617_by + rf1819 * lf1819_by + rf2024 * lf2024_by + rf2529 * lf2529_by + rf3034 * lf3034_by + rf3539 * lf3539_by + rf4044 * lf4044_by + rf4549 * lf4549_by + rf5054 * lf5054_by + rf5559 * lf5559_by + rf6064 * lf6064_by + rf6569 * lf6569_by + rf7074 * lf7074_by + rf75o  * lf75o_by  )/ lcf_by
ru_proj.append ru_asa  = (rum_asa * lcm_by  + ruf_asa * lcf_by) / lc_by

ru_proj.addassign(c) @stochastic		' create the addfactor series in the model for all stochastic equations
'assign values to addfactor series; right now I do this manually. There are three kind of addfactors that can be created automatically; need to investigate if this option works for us. 
for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 7074 75o
  	for %s m f
     	 	r{%s}{%a}_a = r{%s}{%a}_p_addc 
     	next
next



smpl 1948Q1 @last
'		make summary spool
spool _summary
string line1 = "This file was created on " + @date + " at " + @time
string line2 = "The file contains the projected values fo RUs and LFPRs by age and sex. (RUs only for now, No Okun's law scale factor for the coefficients.)"
string line3 = "This version computed the r..._p_add addfactor series internally. "
string line4 = "Look at groups males_ru_p, females_ru_p, males_ru, females_ru, males_ru_fe and females_ru_fe for easy view of the projections (preliminary, final, and full-employment)."
string line5 = "The file also includes a model object -- ru_proj. It contains all estimated dRU equations and the identities that define the ASA series (rum_asa, ruf_asa, and ru_asa). I also added r..._p_add addfactors manually to the model. To see the results the model producers, open the model object, click Proc>Solve Model... The projected series produced by the model solution will have names ending in _0, such as rm75o_. "
string line6 = "The projections use the estimated coefficients from  " + %ru_eqs_path + " for RUs and from ... for LFPRs."
string line7 = "Polina Vlasenko"

_summary.insert line1 line2 line3 line4 line5 line6 line7 

delete line*

if %sav = "Y" then
	wfsave(2) %output_path ' saves the workfile
endif

'close {%this_file} 'close the workfile; comment this out if need to keep the workfile open



