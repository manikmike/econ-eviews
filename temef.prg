


' Drew Sawyer converted this program from Aremos (temef_tr192.cmd) to EViews in 2020 May.



exec .\setup2



' user inputs ************************************************************ 

!tryr = 2024

%output_file = "TR 2024 - Employment Posted to MEF.xlsx"



' setup ************************************************************ 

pageselect a

!histend = !tryr - 3

!projbeg = !tryr - 2

!fileyr = !tryr - 2000

%afile   =    "atr" + @str(!fileyr)
%dfile   =    "dtr" + @str(!fileyr)
%otlfile = "otl_tr" + @str(!fileyr)



' old (but helpful) comments from Aremos ************************************************************ 

' This program calculates and exports values to an Excel file for total employment posted to the MEF (TE_MEF)
' These values were requested by Kent Morgan on April 27, 2009 and are needed to "align" polisim. 

' For the 2009 TR, we defined total employment (TE) as the sum of total reported employment (TE_R) and total unreported 
' employment (TE_NR).

'    E1     TE  =  TE_R + TE_NR

' TE_NR represents employment in the underground economy. Presently, we define total employment in the underground economy as
' equal to the other immigrant employment in the underground economy (TEO_UND). Hence,

'    E2     TE  =  TE_R + TEO_UND

' TE_R is defined as the sum of total employment posted to the MEF (TE_MEF) and total employment sent to the ESF (TE_ESF).

'    E3     TE  =  (TE_MEF + TE_ESF) + TEO_UND

' Presently, we define TE_ESF as the sum of the legal resident population with earnings in the ESF (TE_SFO_LRP) and other immigrant
' employment in the ESF (TEO_ESF).

'    E4     TE  =  TE_MEF + TE_SFO_LRP + TEO_ESF + TEO_UND

' Thus, 

'    E5     TE_MEF =  TE  - TE_SFO_LRP - TEO_ESF - TEO_UND

' Kent requested data by sex and age (15, 16, ***, 100). However, we presently don't produce this level of disaggregation for
' the concepts defined by E5.



' historical: TE_MEF_[sex][age] ************************************************************

wfopen mef.wf1
wfopen {%afile}2.wf1
wfopen {%otlfile}2.wf1

wfselect work
pageselect a

smpl 1994 {!histend}

%export = ""

for %s m f


  ' age 15

  genr te_mef_{%s}15 = mef.wf1::a\ce_m_{%s}15

  %export = %export + "te_mef_" + %s + "15" + " "


  ' age 16-99
  
  for !a = 16 to 99
  
    genr te_mef_{%s}{!a} = mef.wf1::a\HE_m_{%s}{!a} + _
                           mef.wf1::a\TE_RRO_M_{%s}{!a} + _
                           mef.wf1::a\TE_SLOO_M_{%s}{!a} + _
                           mef.wf1::a\TE_SLOS_M_{%s}{!a} + _
                           mef.wf1::a\TE_SLOE_M_{%s}{!a} + _
                           mef.wf1::a\TE_PS_M_{%s}{!a} + _
                           mef.wf1::a\TE_PH_M_{%s}{!a} + _
                    {%otlfile}2.wf1::a\TEO_MEF_{%s}{!a} - _
                    {%otlfile}2.wf1::a\TEO_MEFC_{%s}{!a}

	%export = %export + "te_mef_" + %s + @str(!a) + " "
	 
  next


  ' age 100
	
  genr te_mef_{%s}100 = mef.wf1::a\HE_m_{%s}100o + _
                        mef.wf1::a\TE_RRO_M_{%s}100o + _
                        mef.wf1::a\TE_SLOO_M_{%s}100o + _
                        mef.wf1::a\TE_SLOS_M_{%s}100o + _
                        mef.wf1::a\TE_SLOE_M_{%s}100o + _
                        mef.wf1::a\TE_PS_M_{%s}100o + _
                        mef.wf1::a\TE_PH_M_{%s}100o + _
                 {%otlfile}2.wf1::a\TEO_MEF_{%s}100 - _
                 {%otlfile}2.wf1::a\TEO_MEFC_{%s}100

  %export = %export + "te_mef_" + %s + "100" + " "


  ' age 16o
	
  genr te_mef_{%s}16o = {%afile}2.wf1::a\te_m_{%s}1617 + _
	                    {%afile}2.wf1::a\te_m_{%s}1819 + _
	                    {%afile}2.wf1::a\te_m_{%s}2024 + _
	                    {%afile}2.wf1::a\te_m_{%s}2529 + _
	                    {%afile}2.wf1::a\te_m_{%s}3034 + _
	                    {%afile}2.wf1::a\te_m_{%s}3539 + _
	                    {%afile}2.wf1::a\te_m_{%s}4044 + _
	                    {%afile}2.wf1::a\te_m_{%s}4549 + _
	                    {%afile}2.wf1::a\te_m_{%s}5054 + _
	                    {%afile}2.wf1::a\te_m_{%s}5559 + _
	                    {%afile}2.wf1::a\te_m_{%s}6064 + _
	                    {%afile}2.wf1::a\te_m_{%s}6569 + _
	                    {%afile}2.wf1::a\te_m_{%s}70o

  %export = %export + "te_mef_" + %s + "16o" + " "

next

pagesave(type=excelxml, mode=update) %output_file range="hist!a1" @keep {%export} @smpl 1994 {!histend}

wfclose mef.wf1
wfclose {%afile}2.wf1
wfclose {%otlfile}2.wf1



' projected: TE[sex][age] ************************************************************

for %alt 1 2 3 

  wfopen {%afile}{%alt}.wf1
  wfopen {%dfile}{%alt}.wf1
  wfopen {%otlfile}{%alt}.wf1

  wfselect work
  pageselect a

  smpl {!projbeg} 2100
  
  for %s m f
  
  
    ' age 15
  
      genr te{%s}15 = {%afile}{%alt}.wf1::a\ce_m_{%s}15
  
  
    ' age 16-19
    
    for !a1 = 16 to 18 step 2
    
      !a2 = !a1 + 1
  	
      for !a3 = !a1 to !a2
  	
        genr te{%s}{!a3} = {%afile}{%alt}.wf1::a\te{%s}{!a1}{!a2} * {%afile}{%alt}.wf1::a\ce{%s}{!a3} / {%afile}{%alt}.wf1::a\ce{%s}{!a1}{!a2} 
  	  
      next
  	
    next
  
  
    ' age 20-69
    
    for !a1 = 20 to 65 step 5
    
      !a2 = !a1 + 4
  	
      for !a3 = !a1 to !a2
  	
        genr te{%s}{!a3} = {%afile}{%alt}.wf1::a\te{%s}{!a1}{!a2} * {%afile}{%alt}.wf1::a\ce{%s}{!a3} / {%afile}{%alt}.wf1::a\ce{%s}{!a1}{!a2} 
  	  
      next
  	
    next
  
  
    ' age 70-100
  
    for !a = 70 to 74
    
      genr e{%s}{!a} = {%afile}{%alt}.wf1::a\l{%s}{!a} * (1 - {%afile}{%alt}.wf1::a\r{%s}7074 / 100)
  	
    next
    
    for !a = 75 to 79
    
      genr e{%s}{!a} = {%afile}{%alt}.wf1::a\l{%s}{!a} * (1 - {%afile}{%alt}.wf1::a\r{%s}75o / 100)
  	
    next
    
    for !a = 80 to 100
    
      genr e{%s}{!a} = {%afile}{%alt}.wf1::a\p{%s}{!a} * {%dfile}{%alt}.wf1::a\n{%s}{!a} * (1 - {%afile}{%alt}.wf1::a\r{%s}75o / 100)
  	
    next
  
    for !a = 70 to 100
    
      series te{%s}{!a} = {%afile}{%alt}.wf1::a\te{%s}70o * e{%s}{!a} / {%afile}{%alt}.wf1::a\e{%s}70o 
  	
    next
    
  
  
    ' projected: TE_MEF_[sex][age] (before adjustments) ************************************************************
  
    genr te_mef_wlrp = {%afile}{%alt}.wf1::a\te - {%otlfile}{%alt}.wf1::a\teo_esf_16o - {%otlfile}{%alt}.wf1::a\teo_und_16o
  
  
    ' age 15
  
    te_mef_{%s}15 = te{%s}15 * (1 - {%afile}{%alt}.wf1::a\te_sfo_lrp / te_mef_wlrp)
  
  
    ' age 16-100
  
    for !a = 16 to 100
  	
      te_mef_{%s}{!a} = (te{%s}{!a} - {%otlfile}{%alt}.wf1::a\teo_esf_{%s}{!a} - {%otlfile}{%alt}.wf1::a\teo_und_{%s}{!a}) * (1 - {%afile}{%alt}.wf1::a\te_sfo_lrp / te_mef_wlrp)
  		
    next
  
  
    ' age 16o
  	
    te_mef_{%s}16o = {%afile}{%alt}.wf1::a\te_m_{%s}1617 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}1819 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}2024 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}2529 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}3034 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}3539 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}4044 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}4549 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}5054 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}5559 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}6064 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}6569 + _
  	                    {%afile}{%alt}.wf1::a\te_m_{%s}70o
  
  
  
    ' projected: TE_MEF_[sex][age] (prepare for adjustments) ************************************************************
  
  
    ' age 1617-1819
    
    for !a1 = 16 to 18 step 2
    
      !a2 = !a1 + 1
  	
      genr te_mef_{%s}{!a1}{!a2}a = te_mef_{%s}{!a1} + te_mef_{%s}{!a2} 
  	  	
    next
  
  
    ' age 2024-6569
    
    for !a1 = 20 to 65 step 5
    
      !a2 = !a1 + 1
      !a3 = !a1 + 2
      !a4 = !a1 + 3
      !a5 = !a1 + 4
  
      genr te_mef_{%s}{!a1}{!a5}a = te_mef_{%s}{!a1} + te_mef_{%s}{!a2} + te_mef_{%s}{!a3} + te_mef_{%s}{!a4} + te_mef_{%s}{!a5}
  	
    next
  
  
    ' age 70o
  
    genr te_mef_{%s}70oa = 0
  
    for !a = 70 to 100
    
      te_mef_{%s}70oa = te_mef_{%s}70oa + te_mef_{%s}{!a}
  	
    next
  
  
  
    ' projected: TE_MEF_[sex][age] (apply adjustments) ************************************************************
  
  
    ' age 16-19
    
    for !a1 = 16 to 18 step 2
    
      !a2 = !a1 + 1
  	
      for !a3 = !a1 to !a2
  	
  	  te_mef_{%s}{!a3} = te_mef_{%s}{!a3} * {%afile}{%alt}.wf1::a\te_m_{%s}{!a1}{!a2} / te_mef_{%s}{!a1}{!a2}a
  	  
      next
  	
    next
  
  
    ' age 20-69
    
    for !a1 = 20 to 65 step 5
    
      !a2 = !a1 + 4
  	
      for !a3 = !a1 to !a2
  	
  	  te_mef_{%s}{!a3} = te_mef_{%s}{!a3} * {%afile}{%alt}.wf1::a\te_m_{%s}{!a1}{!a2} / te_mef_{%s}{!a1}{!a2}a
  	  
      next
  	
    next
  
  
    ' age 70-100
  
    for !a = 70 to 100
  	
  	te_mef_{%s}{!a} = te_mef_{%s}{!a} * {%afile}{%alt}.wf1::a\te_m_{%s}70o / te_mef_{%s}70oa
  	  
    next

  next
  
  %range = "alt" + %alt + "!a1"
  
  pagesave(type=excelxml, mode=update) %output_file range=%range @keep {%export} @smpl {!projbeg} 2100
  
wfclose {%afile}{%alt}.wf1
wfclose {%dfile}{%alt}.wf1
wfclose {%otlfile}{%alt}.wf1
  
next


