' This program is used to fulfill an annually recurring  data request from OMB 

' From: Thomas, Payton A. EOP/OMB <Payton_A_Thomas@omb.eop.gov> 
' Sent: Tuesday, August 31, 2021
' Subject: Backup data from 2021 Trustees Report

' Would it be possible to get this year’s backup data after your team has had a chance to exhale?
' I’m attaching what was sent last year as a reference.

' NOTE: Update the end of the sample period, the solution databank, and the population databank

exec .\setup2
pageselect a
smpl 2001 2095

dbopen(type=aremos) op1212o.bnk
   fetch n
   for %ag 65o 6569 7074 7579 8084 85o 65o
      for %s m f
        fetch n{%s}{%ag}
      next
      genr n{%ag} = nm{%ag} + nf{%ag}
      delete nm{%ag} nf{%ag}
   next
   genr n6574 = n6569 + n7074
   delete n6569 n7074
   genr n7584 = n7579 + n8084
   delete n7579 n8084
   genr pct65o = n65o / n * 100
close op1212o

dbopen(type=aremos) \\lrserv1\usr\eco.21\bnk\2021-0430-1559-TR212\atr212.bnk
  fetch l16o p16o e ru hrs ahrs gdp12 pgdp gdp wsd
close atr212

dbopen(type=aremos) dtr212.bnk
  copy ::n16o n_cni
close dtr212

genr lc2n65o = l16o / n65o

group g n n65o n6574 n7584 n85o pct65o lc2n65o n_cni l16o p16o e ru hrs ahrs gdp12 pgdp gdp wsd
g.sheet
