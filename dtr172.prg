' This program creates series covered wages and covered self-employment income
' and copies them to the DBANK

%DBANK = "dtr172"

exec ..\setup2

pageselect a
dbopen(type=aremos) {%DBANK}.bnk

series wscahi
wscahi.fill(o="2000") _
   4664.200, 4771.300, 4784.400, 4902.100, 5183.300, _
   5452.300, 5794.800, 6121.300, 6255.200, 5961.800, _
   6082.500, 6312.200, 6604.000, 6778.600, 7128.900, _
   7511.500

series cse_tot 
cse_tot.fill(o="2000") _
   326.600, 334.200, 344.200, 363.700, 401.800, _
   438.500, 464.400, 477.700, 473.700, 447.100, _
   452.800, 490.900, 530.000, 528.500, 558.000, _
   584.802

store(db={%DBANK}) wscahi cse_tot

close @db
close @wf


