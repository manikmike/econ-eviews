'remember to update years for current TR
!year = 2024

wfopen censuspop.wf1

pageselect military

for !a=0 to 100
	genr TOT_MALE{!a}=resident\TOT_MALE{!a}-civilian\TOT_MALE{!a}
	genr TOT_FEMALE{!a}=resident\TOT_FEMALE{!a}-civilian\TOT_FEMALE{!a}
next			

	   	%lo = "16 16 18 20 25 30 35 40 45 50 55" 
	   	%hi = "59 17 19 24 29 34 39 44 49 54 59"

		' Number of age groupings:
		!anum = @wcount(%lo)

		' Construct each mef concept-sex-age grouping:
     	 	for !n = 1 to !anum          								' loops over each age grouping
         		!loAge = @val(@word(%lo,!n))
         		!hiAge  = @val(@word(%hi,!n))
	         	' Create age grouping label
		     	%ag = @str(!loAge) + @str(!hiAge) ' 1617, 1819, 2024, etc.
	       	genr nm{%ag}m = 0  ' initialize series for each grouping
	       	genr nf{%ag}m = 0  ' initialize series for each grouping
				
         			for !a = !loAge to !hiAge  ' loop over each age within the group, adding to the previous value
            			nm{%ag}m = nm{%ag}m + (tot_male{!a}/1000000)
         			     nf{%ag}m = nf{%ag}m + (tot_female{!a}/1000000)
            		next
      	next
   	  	
pagecreate(page=military_quarterly) q 2020 !year
 copy military\nm* military_quarterly\nm*
 copy military\nf* military_quarterly\nf*

group males nm1617m nm1819m nm2024m nm2529m nm3034m nm3539m nm4044m nm4549m nm5054m nm5559m nm1659m
group females nf1617m nf1819m nf2024m nf2529m nf3034m nf3539m nf4044m nf4549m nf5054m nf5559m nf1659m

pagecreate(page=military_annual) a 2020 !year
 copy military\nm* military_annual\nm*
 copy military\nf* military_annual\nf*

group males nm1617m nm1819m nm2024m nm2529m nm3034m nm3539m nm4044m nm4549m nm5054m nm5559m nm1659m
group females nf1617m nf1819m nf2024m nf2529m nf3034m nf3539m nf4044m nf4549m nf5054m nf5559m nf1659m

wfsave(2) censuspop.wf1
wfclose censuspop


