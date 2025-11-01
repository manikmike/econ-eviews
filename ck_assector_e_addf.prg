wfcreate (wf=assector_e_addf_check) a 2009 2021
dbopen(type=aremos) C:\usr\Econ\EcoDev\dat\bkdo1.bnk
fetch rtp.a minw.a cpiw_u.a nf*.a nm*.a ef*.a em*.a e.a ea.a eaw.a
close bkdo1
dbopen(type=aremos) C:\usr\Econ\EcoDev\dat\dtr222.bnk
fetch ef*as.a em*as.a ef*au.a em*au.a ef*aw.a em*aw.a ef*nas.a em*nas.a ef*nau.a em*nau.a ef*nawph.a em*nawph.a
close dtr222
'spot check of several addfactors:
genr em3544nawph_add = em3544nawph - ((-0.00446 * rtp(-1) - 0.00041 - 0.00053 * minw / cpiw_u + 0.00726) * em3544)
genr ef2024nas_add = ::ef2024nas - ((0.08908 * rtp(-1) - 0.07176) * ef2024)
genr ef4554aw_add = ef4554aw - (eaw * (0.00185 + 0.08747 * rtp + 0.28022 * ef4554 / e - 0.08053))
genr em5564as_add = em5564as - (nm5564 * (-0.00460 + 2.78817 * ea / (nm16o + nf16o) - 0.02398))
group addchecks em3544nawph_add ef2024nas_add ef4554aw_add em5564as_add
pagecreate q 2019 2031
dbopen(type=aremos) C:\usr\Econ\EcoDev\dat\adtr222.bnk
fetch ef*.adj em*.adj
close adtr222
group checked em3544nawph_adj ef2024nas_adj ef4554aw_adj  em5564as_adj


