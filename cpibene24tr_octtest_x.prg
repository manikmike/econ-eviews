' before running program '  
' first input excel spreadsheet with exog data for pwswto brent twexbmth ru and pragfc '
' also need to calculate and input series on pchxxpxpetpi '

' Need to Update nipa related equations !!!!! '
' Need to update the years !!!!!!!!!!!!!! '

pageselect quarterly
smpl 2022q4 2024q4
series ppficompi_q = -0.50
series ppfirestrpi_q = 1.00

' put the quarterly dates here '
string dateq = "2022q1"
string dateqq = "2023q3"
string hhyr = "2023q3"
string hayr = "2023q1"
string ahyr = "2022q4"
string byr = "2023q4"
string eyr = "2024q4"


pageselect monthly
' start date for 2019 tr should be 2018m11 2 and 5 lines below as we will have oct cpi data by then '
' remember to declare the smpl range first - around line 123 is the number of loops or months of proj to perform '
string datef = "2023m10"
string datel = "2024m12"

string byrm = "2023m10"
string eyrm = "2024m12"
' verify number of periods to project on line 123 '

smpl {datef} {datel}

series ppwswto = @pch(pwswto_m)*100
' ((pwswto/pwswto(-1) - 1)*100 '
series pbrent = @pch(brent_m)*100
' ((brent/brent(-1) -1)*100 '




pageselect quarterly

smpl {dateq} {dateqq} 


series cpiwsansa_q = cpiw_q / cpiw_u_q
series cpiwecsansa_q = cpiwec_q / cpiwec_u_q
series cpiwfosansa_q = cpiwfo_q / cpiwfo_u_q
series cpiwxfesansa_q = cpiwxfe_q / cpiwxfe_u_q

' this step should not be necessary as data now available '
' smpl {hhyr} {hhyr} '
' series xxppet = 0.5140 * imppet '

smpl {hayr} {hhyr}
series xxppetpi_q = imppetpi_q

smpl {hhyr} {hhyr}
series pfixpetpi_q = 1.0
' for the 2022TR decided to keep the 2019 weights as the 2020 weights have too low a weight for energy '
' input expenditure shares and put in 05112 instead of 05111 for energy commod to make shares sum to exactly one '
' for the 2024TR, we are using Dec 2022 weights, which are the latest available at the time (October 2023).
smpl {ahyr} {eyr}
series ewec_q = 0.04537
series ewser_q = 0.58688
series ewcxfec_q = 0.21702
series ewfo_q = 0.15073
series ewe_q = 0.08411
series ewxfe_q = 0.76517

' input gdp shares '
smpl {ahyr} {hhyr}
series rpcegdp_q = 0.680597
series rgovgdp_q = 0.172553
series rpfigdp_q = 0.175949

series rimppetgdp_q = 0.008706

smpl {ahyr} {eyr}
series rimpxpetgdp_q = 0.104292
series rimpsergdp_q = 0.026228
series rxxppetgdp_q = 0.009796

series rxxpxpetgdp_q = 0.099645

' input pce shares '
series rgaspce_q = 0.024795
series rfoopce_q = 0.077860
series rpfipetpfi_q = 0.017045


smpl {ahyr} {hhyr}
series rimppetimp_q = rimppetgdp_q / (rimpxpetgdp_q + rimppetgdp_q)

smpl {byr} {eyr}
series cpiwsansa_q = -0.001467*dumq1_q - 0.004853*dumq2_q - 0.004593*dumq3_q + 1.002754
series cpiwecsansa_q = 0.014616*dumq1_q - 0.062915*dumq2_q - 0.060704*dumq3_q + 1.028773
series cpiwfosansa_q = -0.001771*dumq1_q - 0.002811*dumq2_q - 0.001817*dumq3_q + 1.001580
series cpiwxfesansa_q = -0.003185*dumq1_q - 0.002895*dumq2_q - 0.002144*dumq3_q + 1.002257
series cpiwgsansa_q = 0.018978*dumq1_q - 0.064099*dumq2_q - 0.061396*dumq3_q + 1.027361
series cpiwsersansa_q = -0.001139*dumq1_q - 0.000580*dumq2_q - 0.001697*dumq3_q + 1.000849
series cpiwcxfecsansa_q = -0.004862*dumq1_q - 0.005943*dumq2_q - 0.002952*dumq3_q + 1.003404


pageselect monthly
' begin 2011m1 for 2017tr '
smpl 2012m1 {eyrm}
copy(c=dentona) Quarterly\ewec_q
copy(c=dentona) Quarterly\ewser_q
copy(c=dentona) Quarterly\ewcxfec_q
copy(c=dentona) Quarterly\ewfo_q
copy(c=dentona) Quarterly\ewxfe_q

series ewec_m = ewec_q
series ewser_m = ewser_q
series ewcxfec_m = ewcxfec_q
series ewfo_m = ewfo_q
series ewxfe_m = ewxfe_q

series ppwswto_m = @pch(pwswto_m)*100
series pbrent_m = @pch(brent_m)*100

' 14 projection months for trustees report from nov of year t to dec of year t+1 therefore zero to 13'
' 15 projection months if begin projection period in october before mid-nov release of data '
' for !a = 0 to 6 '
' datediff based on p110 of command ref and dateval converts string into date number then calc date diff to get number of periods '
' do project or loop through '
series tdate1 = @dateval(datef)
series tdate2 = @dateval(datel)
series return = @datediff(tdate2,tdate1,"mm")
!jk = @elem(return,datel)
for !a = 0 to !jk
    smpl {byrm}+!a {byrm}+!a
    ' series pcpiwec_u_m = 0.46717*ppwswto_m + 0.26539*ppwswto_m(-1) - 0.53452 * (ppwswto_m-pbrent_m) - 0.20538*(ppwswto_m(-1)-pbrent_m(-1)) + 2.04120*dumm1_m+2.86569*dumm3_m + 1.82690*dumm5_m - 2.11139*dumm7_m - 3.25122*dumm11_m - 1.54420*dumm12_m '
    series pcpiwec_u_m = 0.327653*ppwswto_m + 0.308310*ppwswto_m(-1) - 0.332490 * (ppwswto_m-pbrent_m) - 0.280057*(ppwswto_m(-1)-pbrent_m(-1)) + 1.229460*dumm1_m + 3.456479*dumm3_m + 1.350085*dumm5_m - 2.944017*dumm10_m -2.010428*dumm11_m - 1.620961*dumm12_m
    
    series cpiwec_u_m = cpiwec_u_m(-1)*(1+pcpiwec_u_m/100)
    series cpiwec_m = cpiwec_u_m*(cpiwec_m(-12)/cpiwec_u_m(-12))
    series pcpiwec_m = ((cpiwec_m/cpiwec_m(-1)) - 1)*100
    ' neuequation but put in an addfactor of -0.02 as service prices appear to be growing too fast '
    series pcpiwser_m = (0.00389*@pch(cpiwec_m(-1)) + 0.00060*@pch(cpiwec_m(-2)) + 0.00513*@pch(cpiwec_m(-3)) + 0.00127*@pch(cpiwec_m(-4)))*100 - 0.02070*((ru_m(-3)+ru_m(-4)+ru_m(-5))/3) + 0.33823
    ' altequation '
    ' series pcpiwser_m = (0.00361*@pch(cpiwec_m(-1)) + 0.00037*@pch(cpiwec_m(-2)) - 0.00036*@pch(cpiwec_m(-3)) + 0.00339*@pch(cpiwec_m(-4)) - 0.00058*@pch(cpiwec_m(-5)) + 0.00392*@pch(cpiwec_m(-6)))*100 - 0.03089*((ru_m(-3)+ru_m(-4)+ru_m(-5))/3) + 0.40430 '
    series cpiwser_m = cpiwser_m(-1)*(1+pcpiwser_m/100)
    series cpiwser_u_m = cpiwser_m*(cpiwser_u_m(-12)/cpiwser_m(-12))
    ' twexbmth series discontinued from the fed so replaced it with dtwexbgs series below '
    series pcpiwcxfec_m = @movav(@pch(cpiwser_m(-1)),3)*100 - 0.049766*@movav(@pch(dtwexbgs_m(-3)),3)*100 - 0.178033
    ' series pcpiwcxfec_m = @movav(@pch(cpiwser_m(-1)),3)*100 + 0.00364*ppwswto_m(-1) + 0.00148*ppwswto_m(-2) + 0.07008*ru_m - 0.63506 '
    series cpiwcxfec_m = cpiwcxfec_m(-1)*(1+pcpiwcxfec_m/100)
    series cpiwcxfec_u_m = cpiwcxfec_m*(cpiwcxfec_u_m(-12)/cpiwcxfec_m(-12))
    series pcpiwcxfec_u_m = @pch(cpiwcxfec_u_m)*100
    
    series pcpiwfo_m = 100*(0.01754*@pch(pragfc_m) + 0.04828*@pch(pragfc_m(-1)) - 0.02733*@pch(pragfc_m(-2)) +0.02794*@pch(pragfc_m(-3)) - 0.01306*@pch(pragfc_m(-4)) + 0.04353*@pch(pragfc_m(-5)) + 0.02121*@pch(pragfc_m(-6)) + 0.58057*@pch(cpiwser_m(-2)))
    
    series cpiwfo_m = cpiwfo_m(-1) * (1+pcpiwfo_m/100)
    series cpiwfo_u_m = cpiwfo_m * (cpiwfo_u_m(-12) / cpiwfo_m(-12))
    
    series pcpiwec_u_m = @pch(cpiwec_u_m)*100
    series pcpiwser_u_m = @pch(cpiwser_u_m)*100
    series pcpiwfo_u_m = @pch(cpiwfo_u_m)*100
    
    
    series pcpiw_u_m = ewec_m*pcpiwec_u_m + ewfo_m*pcpiwfo_u_m + ewser_m*pcpiwser_u_m + ewcxfec_m*pcpiwcxfec_u_m
    series cpiw_u_m = cpiw_u_m(-1)*(1+pcpiw_u_m/100)
    series cpiw_m = cpiw_u_m * (cpiw_m(-12) / cpiw_u_m(-12))
  
next

pageselect Quarterly
' 2014q1 for 2017tr line below '
smpl 2017q1 {eyr}

' c=a = average method '
copy(c=a, merge) Monthly\dtwexbgs_m Quarterly\dtwexbgs_q
copy(c=a, merge) Monthly\twexbmth_m Quarterly\twexbmth_q 
copy(c=a, merge) Monthly\pwswto_m Quarterly\pwswto_q
copy(c=a, merge) Monthly\pragfc_m Quarterly\pragfc_q
copy(c=a, merge) Monthly\brent_m Quarterly\brent_q

' series twexbmth_q = twexbmth_m '
' series pwswto_q = pwswto_m '
' series pragfc_q = pragfc_m '
' series brent_q = brent_m '

' smpl 2017q4 {eyr} for 2018tr '
smpl {byr} {eyr}
copy(c=a, merge) Monthly\cpiwec_u_m Quarterly\cpiwec_u_q
copy(c=a, merge) Monthly\cpiwser_u_m Quarterly\cpiwser_u_q
copy(c=a, merge) Monthly\cpiwcxfec_u_m Quarterly\cpiwcxfec_u_q
copy(c=a, merge) Monthly\cpiwfo_u_m Quarterly\cpiwfo_u_q
copy(c=a, merge) Monthly\cpiw_u_m Quarterly\cpiw_u_q
copy(c=a, merge) Monthly\cpiwe_u_m Quarterly\cpiwe_u_q
copy(c=a, merge) Monthly\cpiwxfe_u_m Quarterly\cpiwxfe_u_q

' rename cpiwec_u_m cpiwec_u_q '
' rename cpiwser_u_m cpiwser_u_q '
' rename cpiwcxfec_u_m cpiwcxfec_u_q '
' rename cpiwfo_u_m cpiwfo_u_q '
' rename cpiw_u_m cpiw_u_q '
' rename cpiwe_u_m cpiwe_u_q '
' rename cpiwxfe_u_m cpiwxfe_u_q '

' series cpiwec_u_q = cpiwec_u_m '
' series cpiwser_u_q = cpiwser_u_m '
' series cpiwcxfec_u_q = cpiwcxfec_u_m '
' series cpiwfo_u_q = cpiwfo_u_m '
' series cpiw_u_q = cpiw_u_m '
' series cpiwe_u_q = cpiwe_u_m '
' series cpiwxfe_u_q = cpiwxfe_u_m '



copy(c=a, merge) Monthly\cpiwec_m Quarterly\cpiwec_q
copy(c=a, merge) Monthly\cpiwser_m Quarterly\cpiwser_q
copy(c=a, merge) Monthly\cpiwcxfec_m Quarterly\cpiwcxfec_q
copy(c=a, merge) Monthly\cpiwfo_m Quarterly\cpiwfo_q
copy(c=a, merge) Monthly\cpiw_m Quarterly\cpiw_q
copy(c=a, merge) Monthly\cpiwe_m Quarterly\cpiwe_q
copy(c=a, merge) Monthly\cpiwxfe_m Quarterly\cpiwxfe_q

' rename cpiwec_m cpiwec_q '
' rename cpiwser_m cpiwser_q '
' rename cpiwcxfec_m cpiwcxfec_q '
' rename cpiwfo_m cpiwfo_q '
' rename cpiw_m cpiw_q '
' rename cpiwe_m cpiwe_q '
' rename cpiwxfe_m cpiwxfe_q '

' series cpiwec_q = cpiwec_m '
' series cpiwser_q = cpiwser_m '
' series cpiwcxfec_q = cpiwcxfec_m '
' series cpiwfo_q = cpiwfo_m '
' series cpiwe_q = cpiwe_m '
' series cpiwxfe_q = cpiwxfe_m '



copy(link, c=a) Monthly\ru*

' series brent_q = brent_m '
' series pwswto_q = pwswto_m '
' series pragfc_q = pragfc_m '
' series twexbmth_q = twexbmth_m '

' series cpiwec_u_q = cpiwec_u_m '
' series cpiwser_u_q = cpiwser_u_m '
' series cpiwcxfec_u_q = cpiwcxfec_u_m '
' series cpiwfo_u_q = cpiwfo_u_m '
' series cpiw_u_q = cpiw_u_m '
' series cpiwe_u_q = cpiwe_u_m '
' series cpiwxfe_u_q = cpiwxfe_u_m '


' series cpiwec_q = cpiwec_m '
' series cpiwser_q = cpiwser_m '
' series cpiwcxfec_q = cpiwcxfec_m '
' series cpiwfo_q = cpiwfo_m '
' series cpiw_q = cpiw_m '
' series cpiwe_q = cpiwe_m '
' series cpiwxfe_q = cpiwxfe_m '

' here we are in the quarterly sheet replacing nonseas values '

' replace the nonseas adj values with the seas adj eqns (quarterly values) '
' except for some where reverse is done as shown below '
' series cpiw_u = cpiw / cpiwsansa '
series cpiw_q = cpiw_u_q * cpiwsansa_q
series cpiwfo_u_q = cpiwfo_q / cpiwfosansa_q
series cpiwser_u_q = cpiwser_q / cpiwsersansa_q
series cpiwcxfec_u_q = cpiwcxfec_q / cpiwcxfecsansa_q
series cpiwec_q = cpiwec_u_q * cpiwecsansa_q

smpl {byr} {eyr}
for !w = 0 to 4
  smpl {byr}+!w {byr}+!w
  series pcpiwe_q = (ewec_q/ewe_q)*@pch(cpiwec_q)*100 + ((ewe_q-ewec_q)/ewe_q)*@pch(cpiwser_q)*100
  series cpiwe_q = cpiwe_q(-1)*(1+pcpiwe_q/100)
  
  series pcpiwxfe_q = (@pch(cpiw_q)*100 - ewfo_q*@pch(cpiwfo_q)*100 - ewe_q*@pch(cpiwe_q)*100)/(1-ewfo_q-ewe_q)
  series cpiwxfe_q = cpiwxfe_q(-1)*(1+pcpiwxfe_q/100)

next




smpl {byr} {eyr}

for !w = 0 to 4
  smpl {byr}+!w {byr}+!w
  
  ' the pre pce '
  series pcpiwg_u_q = 1.0 * @pch(cpiwec_u_q)*100
  series cpiwg_u_q = cpiwg_u_q(-1) * (1+pcpiwg_u_q/100)
  series cpiwg_q = cpiwg_u_q * cpiwgsansa_q
  series pcpiwg_q = @pch(cpiwg_q)*100
  
  series pcpiwhe_q = 0.11629*@pch(cpiwg_q)*100 + 0.13894*@pch(cpiwg_q(-1))*100 + 0.10150*@pch(cpiwg_q(-2))*100 + 0.05103*@pch(cpiwg_q(-3))*100 + 0.06867*@pch(cpiwg_q(-4))*100
  series cpiwhe_q = cpiwhe_q(-1)*(1+pcpiwhe_q/100)
  
  ' now the pce '
  series ppcegaspi_q = pcpiwg_q + 0.03108
  series pcegaspi_q = pcegaspi_q(-1)*(1+ppcegaspi_q/100)
  
  series ppcefoopi_q = @pch(cpiwfo_q)*100 - 0.132222 
  series pcefoopi_q = pcefoopi_q(-1)*(1+ppcefoopi_q/100)
  
  ' this part may nor may not be used '
  series pcpiwm_q = @pch(cpiwxfe_q(-1))*100 + 0.30372
  series cpiwm_q = cpiwm_q(-1)*(1+pcpiwm_q/100)
  
  series ppcemedpi_q = pcpiwm_q - 0.375547
  series pcemedpi_q = pcemedpi_q(-1) * (1+ppcemedpi_q/100)
  
  series ppcexfepi_q = @pch(cpiwxfe_q)*100 - 0.048711
  series pcexfepi_q = pcexfepi_q(-1) * (1+ppcexfepi_q/100)

  series rgaspce_q = 0.062354*(pwswto_q/cpiw_q) - 0.000262*dumq1_q - 0.001116*dumq2_q - 0.000512*dumq3_q + 0.011196
  series ppcepi_q = rgaspce_q*@pch(pcegaspi_q)*100 + rfoopce_q*@pch(pcefoopi_q)*100 + (1-rgaspce_q-rfoopce_q)*@pch(pcexfepi_q)*100
  
  series pcepi_q = pcepi_q(-1) * (1+ppcepi_q/100)
  
 
 ' the g part here '
  
  series pgovpi_q =  1.089371*@pch(pcexfepi_q)*100*dumq1_q + 1.187089*@pch(pcexfepi_q)*100*dumq2_q + 1.115085*@pch(pcexfepi_q)*100*dumq3_q + 1.113268*@pch(pcexfepi_q)*100*(1-dumq1_q-dumq2_q-dumq3_q) + 0.036832*@pch(cpiwec_q)*100 + 0.010567*@pch(cpiwec_q(-1))*100
  series govpi_q = govpi_q(-1) * (1+pgovpi_q/100)
  
  ' the impxpet part here '
  ' twexbmth series discontinued so replaced it with dtwexbgs series '
  series pimpxpetpi_q = 100*(-0.149452*@pch(dtwexbgs_q) - 0.174569*@pch(dtwexbgs_q(-1)) - 0.040219*@pch(dtwexbgs_q(-2)) - 0.040916*@pch(dtwexbgs_q(-3))) + 0.075377
  series impxpetpi_q = impxpetpi_q(-1) * (1+pimpxpetpi_q/100)
  
  series pxxpxpetpi_q = 0.715891*pimpxpetpi_q + 0.025748*@pch(pragfc_q)*100 + 0.312806
  series xxpxpetpi_q = xxpxpetpi_q(-1) * (1+pxxpxpetpi_q/100)
  
  ' the pet/cat stuff below '
  series pimppetpi_q = @pch(brent_q)*100
  series imppetpi_q = imppetpi_q(-1) * (1+pimppetpi_q/100)
  series pxxppetpi_q = pimppetpi_q
  
  series pimpserpi_q = 0.509487*@pch(impxpetpi_q)*100 + 0.008573*@pch(imppetpi_q)*100 + 0.361420
  series impserpi_q = impserpi_q(-1) * (1+pimpserpi_q/100)
  
  ' the x part here '
  series xxppetpi_q = imppetpi_q
  series rxxppetxxp_q = rxxppetgdp_q / (rxxpxpetgdp_q + rxxppetgdp_q)
  series pxxppi_q = (rxxppetxxp_q*@pch(xxppetpi_q) + (1-rxxppetxxp_q)*@pch(xxpxpetpi_q))*100
  series xxppi_q = xxppi_q(-1) * (1+pxxppi_q/100)
  
  ' series rimppetgdp_q = 0.06782*pwswto_q/cpiw_q '
  series rimppetgdp_q = 0.045827*pwswto_q/cpiw_q
  
  ' 2.280019 before for 2018tr and 1.634396 for 2019tr and 2.028388 for 2020tr and assumed 2.3 for 2021tr '
  series pfipetpi_q = 2.0*pwswto_q
  series ppfipetpi_q = @pch(pfipetpi_q)*100
  
  ' now the rest of the invt '
  series pfirestrpi_q = pfirestrpi_q(-1) *(1+ppfirestrpi_q/100)
  series pficompi_q = pficompi_q(-1) * (1+ppficompi_q/100)
   
  series ppfixpetpi_q = @pch(pcepi_q(-1))*100 + 0.224090*@pch(pfirestrpi_q)*100 - 0.007441*@pch(pwswto_q(-1))*100 - 0.333148
  
  ' now the other main components '
  ' the gov component '
  
  series ppfipi_q = rpfipetpfi_q*ppfipetpi_q + (1-rpfipetpfi_q)*ppfixpetpi_q
  series pfipi_q = pfipi_q(-1) * (1+ppfipi_q/100)
  
  ' xxp is the same with pch '
  series rimppetimp_q = rimppetgdp_q / (rimpxpetgdp_q + rimppetgdp_q)
  series pimppi_q = rimppetimp_q * pimppetpi_q  + (1-rimppetimp_q)*pimpxpetpi_q
  series imppi_q = imppi_q(-1)*(1+pimppi_q/100)
  
  ' now wt them up please '
  ' calc change in pet share '
  series petshd_q = rimppetgdp_q - rimppetgdp_q(-1)
  
  ' the other shares of gdp are assumed to be affected proportionally such that the total effect '
  ' exactly offsets the effect of oil prices on shares of imports '
  series rpcegdp_q = rpcegdp_q(-1) + (rpcegdp_q(-1)/(rpcegdp_q(-1)+rpfigdp_q(-1)+rgovgdp_q(-1)+rxxppetgdp_q(-1)+rxxpxpetgdp_q(-1)))*petshd_q
  
  series rpfigdp_q = rpfigdp_q(-1) + (rpfigdp_q(-1)/(rpcegdp_q(-1)+rpfigdp_q(-1)+rgovgdp_q(-1)+rxxppetgdp_q(-1)+rxxpxpetgdp_q(-1)))*petshd_q
  
  series rgovgdp_q = rgovgdp_q(-1) + (rgovgdp_q(-1)/(rpcegdp_q(-1)+rpfigdp_q(-1)+rgovgdp_q(-1)+rxxppetgdp_q(-1)+rxxpxpetgdp_q(-1)))*petshd_q
  
  series rxxppetgdp_q = rxxppetgdp_q(-1) + (rxxppetgdp_q(-1)/(rpcegdp_q(-1)+rpfigdp_q(-1)+rgovgdp_q(-1)+rxxppetgdp_q(-1)+rxxpxpetgdp_q(-1)))*petshd_q
  
  series rxxpxpetgdp_q = rxxpxpetgdp_q(-1) + (rxxpxpetgdp_q(-1)/(rpcegdp_q(-1)+rpfigdp_q(-1)+rgovgdp_q(-1)+rxxppetgdp_q(-1)+rxxpxpetgdp_q(-1)))*petshd_q
  
  series rimpxpetgdp_q = rimpxpetgdp_q(-1)
  
  series pgdppi_q = rpcegdp_q*ppcepi_q + rpfigdp_q*ppfipi_q + rgovgdp_q*pgovpi_q +rxxppetgdp_q*pxxppetpi_q + rxxpxpetgdp_q*pxxpxpetpi_q - rimpxpetgdp_q*pimpxpetpi_q - rimpsergdp_q*pimpserpi_q - rimppetgdp_q*pimppetpi_q
  
  series gdppi_q = gdppi_q(-1) * (1+pgdppi_q/100)
  
  ' now do calc to check pur part '
  
  series pgdpurpi_q = (rpcegdp_q*ppcepi_q + rpfigdp_q*ppfipi_q + rgovgdp_q*pgovpi_q)*(1/(rpcegdp_q+rpfigdp_q+rgovgdp_q))
  
  series gdpurpi_q = gdpurpi_q(-1) * (1+pgdpurpi_q/100)
  
next
  
pageselect Annual

smpl 2001 2023
copy(c=a) Quarterly\cpiw*
' actually the asterisk does it for all series that begin with cpiw  so the cpiw ones below are not needed '
copy(c=a, merge) Quarterly\cpiw_u_q Annual\cpiw_u_a
copy(c=a, merge) Quarterly\cpiw_q Annual\cpiw_a
copy(c=a, merge) Quarterly\cpiwser_q Annual\cpiwser_a
copy(c=a, merge) Quarterly\cpiwcxfec_q Annual\cpiwcxfec_a
copy(c=a, merge) Quarterly\cpiwfo_q Annual\cpiwfo_a
copy(c=a, merge) Quarterly\cpiwec_q Annual\cpiwec_a
copy(c=a, merge) Quarterly\cpiwxfe_q Annual\cpiwxfe_a
copy(c=a, merge) Quarterly\gdpurpi_q Annual\gdpurpi_a
copy(c=a, merge) Quarterly\gdppi_q Annual\gdppi_a
copy(c=a, merge) Quarterly\pcepi_q Annual\pcepi_a
copy(c=a, merge) Quarterly\pfipi_q Annual\pfipi_a
copy(c=a, merge) Quarterly\govpi_q Annual\govpi_a
copy(c=a, merge) Quarterly\imppi_q Annual\imppi_a
copy(c=a, merge) Quarterly\xxppi_q Annual\xxppi_a
copy(c=a, merge) Quarterly\imppetpi_q Annual\imppetpi_a
copy(c=a, merge) Quarterly\impxpetpi_q Annual\impxpetpi_a
copy(c=a, merge) Quarterly\impserpi_q Annual\impserpi_a
copy(c=a, merge) Quarterly\xxpxpetpi_q Annual\xxpxpetpi_a
copy(c=a, merge) Quarterly\xxppetpi_q Annual\xxppetpi_a
copy(c=a, merge) Quarterly\pcexfepi_q Annual\pcexfepi_a

copy(c=a, merge) Quarterly\pwswto_q Annual\pwswto_a
copy(c=a, merge) Quarterly\brent_q Annual\brent_a

' series cpiw_a = cpiw_q '
' series cpiw_u_a = cpiw_u_q '
' series cpiwser_a = cpiwser_q '
' series cpiwser_u_a = cpiwser_u_q '
' series cpiwcxfec_a = cpiwcxfec_q '
' series cpiwcxfec_u_a = cpiwcxfec_u_q '
' series cpiwfo_a = cpiwfo_q '
' series cpiwfo_u_a = cpiwfo_u_q '
' series cpiwec_a = cpiwec_q '
' series cpiwec_u_a = cpiwec_u_q '
' series cpiwxfe_a = cpiwxfe_q '
' series cpiwxfe_u_a = cpiwxfe_u_q '
' series gdpurpi_a = gdpurpi_q '
' series gdppi_a = gdppi_q '
' series pcepi_a = pcepi_q '
' series pfipi_a = pfipi_q '
' series govpi_a = govpi_q '
' series imppi_a = imppi_q '
' series xxppi_a = xxppi_q '
' series imppetpi_a = imppetpi_q '
' series impserpi_a = impserpi_q '
' series xxpxpetpi_a = xxpxpetpi_q '
' series xxppetpi_a = xxppetpi_q '


' rename cpiw_q cpiw_a '
' rename cpiw_u_q cpiw_u_a '
' rename cpiwser_q cpiwser_a '
' rename cpiwser_u_q cpiwser_u_a '
' rename cpiwcxfec_q cpiwcxfec_a '
' rename cpiwcxfec_u_q cpiwcxfec_u_a '
' rename cpiwfo_q cpiwfo_a '
' rename cpiwfo_u_q cpiwfo_u_a '
' rename cpiwec_q cpiwec_a '
' rename cpiwec_u_q cpiwec_u_a '
' rename cpiwxfe_q cpiwxfe_a '
' rename cpiwxfe_u_q cpiwxfe_u_a '
' rename gdpurpi_q gdpurpi_a '
' rename gdppi_q gdppi_a '
' rename pcepi_q pcepi_a ' 
' rename pfipi_q pfipi_a ' 
' rename govpi_q govpi_a '
' rename imppi_q imppi_a '
' rename xxppi_q xxppi_a '
' rename imppetpi_q imppetpi_a '
' rename impserpi_q impserpi_a '
' rename xxpxpetpi_q xxpxpetpi_a '
' rename xxppetpi_q xxppetpi_a '



  
pageselect Quarterly
smpl {hayr} {eyr}

series pgdp = gdppi_q
group groupx cpiw_u_q cpiw_q pgdp
groupx.sheet
freeze(output1) groupx.sheet
' if get error about output1 already exists, delete it in workfile before running program '
output1.save(t=csv) cpi24trout_OCTTEST_X


