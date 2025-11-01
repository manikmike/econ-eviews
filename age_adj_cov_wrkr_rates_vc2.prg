' This program produces age-adjusted covered worker rates.
' These rates are needed when updating TR text in section V.C.2. Covered Employment.
' This program was converted from Aremos to Eviews by Drew Sawyer for TR 2018.



exec .\setup2

pageselect vars



' user inputs begin ************************************************************ 

!tryear = 2025
!endyr = 2105
!base = 2020 ' CHANGE TO 2020 FOR TR24



' user inputs end ************************************************************ 



!afileyr = !tryear - 2000
!opfileyr = !tryear - 1900

%afile = "atr" + @str(!afileyr)
%opfile = "op" + @str(!opfileyr)



for %alt 1 2 3

  wfopen {%afile}{%alt}.wf1
  wfopen {%opfile}{%alt}o.wf1

next



wfselect work
pageselect a

smpl !base !endyr



for %s m f

  for %alt 1 2 3

    genr num = 0

	copy {%opfile}{%alt}o::a\n{%s}16o n{%s}16o
    ' need to fetch into workfile because we later want to use @elem

    for %a 1617 1819 2024 2529 3034 3539 4044 4549 5054 5559 6064 6569 70o 

      copy {%opfile}{%alt}o::a\n{%s}{%a} n{%s}{%a}
      ' need to fetch into workfile because we later want to use @elem

      genr rce{%s}{%a} = {%afile}{%alt}.wf1::a\ce{%s}{%a} / n{%s}{%a}

      genr num = num + rce{%s}{%a} * @elem(n{%s}{%a},!base)

	  delete n{%s}{%a} rce{%s}{%a}
	  
    next

    genr rce{%s}16o_asa_a{%alt} = num / @elem(n{%s}16o,!base)

    delete num n{%s}16o
	
	rce{%s}16o_asa_a{%alt}.setformat g.3
	
  next

next



group g * not resid
' group containing all series except "resid"

g.sheet



for %alt 1 2 3

  wfclose {%afile}{%alt}.wf1
  wfclose {%opfile}{%alt}o.wf1

next


