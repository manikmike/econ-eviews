'check TR addfactors

%tryr = "25"
!firsty = 2022 'this should be TR year - 3
!lasty = 2036 'this should be TR year + 11
%wfile = "ck_tr"+%tryr+"2_addfactors" 	' make sure an Excel file of this same name exists in the EViews default folder
													' ideally this should be a copy of this same file from previous TR
													' the program will update the necessary data in this file
%mrdpath = "S:\LRECON\ModelRuns\TR2025\2024-1215-0811-TR252\dat\"
%mropath = "S:\LRECON\ModelRuns\TR2025\2024-1215-0811-TR252\out\mul\"
%addfile = "adtr"+%tryr+"2"
%dfile = "dtr"+%tryr+"2"
%addpath = %mrdpath+%addfile+".wf1"
%dpath = %mropath+%dfile+".wf1"

%PIN = @env("username") ' need this later to identify the GitRepos folder

wfcreate(wf={%wfile}, page=q) q !firsty !lasty
pagecreate(page=a) a 2014 !lasty 'need 2015 for historical series in the assector check and 2014 for lagged indep var

wfopen {%addpath}
copy {%addfile}::q\ynf_mult {%wfile}::q\*
copy {%addfile}::q\rwsspbnfxge_adj {%wfile}::q\*
copy {%addfile}::q\ru_asa_adj {%wfile}::q\*
copy {%addfile}::adj\lc {%wfile}::q\lc_adj
copy {%addfile}::adj\ef* {%wfile}::q\ef*_adj
copy {%addfile}::adj\em* {%wfile}::q\em*_adj
copy {%addfile}::add_q\gdppf17 {%wfile}::q\gdppf17_add
copy {%addfile}::add_q\pgdpaf {%wfile}::q\pgdpaf_add
copy {%addfile}::add_q\ea {%wfile}::q\ea_add
copy {%addfile}::add_q\eaw {%wfile}::q\eaw_add
copy {%addfile}::add_q\enas {%wfile}::q\enas_add
copy {%addfile}::add_q\enawph {%wfile}::q\enawph_add
copy {%addfile}::add_q\rcwsp {%wfile}::q\rcwsp_add
copy {%addfile}::add_q\rcwsm {%wfile}::q\rcwsm_add
copy {%addfile}::add_q\rcwsf {%wfile}::q\rcwsf_add
copy {%addfile}::add_q\rcwssl {%wfile}::q\rcwssl_add
copy {%addfile}::add_q\r*_p {%wfile}::q\r*_p_add
copy {%addfile}::add_a\cse_tot {%wfile}::a\cse_tot_add
copy {%addfile}::add_a\tips_sr {%wfile}::a\tips_sr_add
copy {%addfile}::a\multcmb {%wfile}::a\multcmb
copy {%addfile}::a\multseo {%wfile}::a\multseo
wfclose {%addfile}

%bkdo1path = "C:\Users\" + %PIN + "\GitRepos\econ-ecodev\dat\bkdo1.wf1"
wfopen %bkdo1path
copy bkdo1::a\rtp {%wfile}::a\*
copy bkdo1::a\cpiw_u {%wfile}::a\*
copy bkdo1::a\minw {%wfile}::a\*
copy bkdo1::a\e {%wfile}::a\*
copy bkdo1::a\ea {%wfile}::a\*
copy bkdo1::a\eaw {%wfile}::a\*
copy bkdo1::a\ef* {%wfile}::a\ef*
copy bkdo1::a\em* {%wfile}::a\em*
copy bkdo1::a\nf* {%wfile}::a\nf*
copy bkdo1::a\nm* {%wfile}::a\nm*
wfclose bkdo1

wfopen {%dpath}
copy {%dfile}::a\ef*as {%wfile}::a\ef*as
copy {%dfile}::a\ef*au {%wfile}::a\ef*au
copy {%dfile}::a\ef*aw {%wfile}::a\ef*aw
copy {%dfile}::a\ef*nawph {%wfile}::a\ef*nawph
copy {%dfile}::a\em*as {%wfile}::a\em*as
copy {%dfile}::a\em*au {%wfile}::a\em*au
copy {%dfile}::a\em*aw {%wfile}::a\em*aw
copy {%dfile}::a\em*nawph {%wfile}::a\em*nawph
wfclose {%dfile}

wfselect {%wfile}
pageselect q

save(type=excelxml, mode=update) {%wfile}.xlsx range="lc_adj!a1" @keep lc_adj

save(type=excelxml, mode=update) {%wfile}.xlsx range="ru_asa_adj!a1" @keep ru_asa_adj

save(type=excelxml, mode=update) {%wfile}.xlsx range="ynf_mult!a1" @keep ynf_mult

save(type=excelxml, mode=update) {%wfile}.xlsx range="gdppf17_add!a1" @keep gdppf17_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="pgdpaf_add!a1" @keep pgdpaf_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="ea_add!a1" @keep ea_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="eaw_add!a1" @keep eaw_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="enas_add!a1" @keep enas_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="enawph_add!a1" @keep enawph_add

'save(type=excelxml, mode=update) {%wfile}.xlsx range="rcwsp_add!a1" @keep rcwsp_add ***NOT USED IN TR23***

save(type=excelxml, mode=update) {%wfile}.xlsx range="rwsspbnfxge_adj!a1" @keep rwsspbnfxge_adj

save(type=excelxml, mode=update) {%wfile}.xlsx range="rcwsm_add!a1" @keep rcwsm_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="rcwsf_add!a1" @keep rcwsf_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="rcwssl_add!a1" @keep rcwssl_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="r_p_add!a1" @keep r*_p_add

pageselect a
smpl !firsty !lasty

save(type=excelxml, mode=update) {%wfile}.xlsx range="cse_tot_add!a1" @keep cse_tot_add

save(type=excelxml, mode=update) {%wfile}.xlsx range="multcmb!a1" @keep multcmb

'NOT USED IN TR23:

'save(type=excelxml, mode=update) {%wfile}.xlsx range="tips_sr_add!a1" @keep tips_sr_add

'save(type=excelxml, mode=update) {%wfile}.xlsx range="multseo!a1" @keep multseo

'spot check of several addfactors:
smpl @all
genr em3544nawph_add = em3544nawph - ((-0.00446 * rtp(-1) - 0.00041 - 0.00053 * minw / cpiw_u + 0.00726) * em3544)
genr ef2024nas_add = ef2024nas - ((0.08908 * rtp(-1) - 0.07176) * ef2024)
genr ef4554aw_add = ef4554aw - (eaw * (0.00185 + 0.08747 * rtp + 0.28022 * ef4554 / e - 0.08053))
genr em5564as_add = em5564as - (nm5564 * (-0.00460 + 2.78817 * ea / (nm16o + nf16o) - 0.02398))
for %ser em3544nawph_add ef2024nas_add ef4554aw_add em5564as_add
  series {%ser} = @elem({%ser},"2015")
next
copy q\em3544nawph_adj a\*
copy q\ef2024nas_adj a\*
copy q\ef4554aw_adj a\*
copy q\em5564as_adj a\*
smpl !firsty !lasty
series ck_em3544nawph_adj = em3544nawph_add - em3544nawph_adj
series ck_ef2024nas_adj = ef2024nas_add - ef2024nas_adj
series ck_ef4554aw_adj = ef4554aw_add - ef4554aw_adj
series ck_em5564as_adj = em5564as_add - em5564as_adj
group assect_checked ck_em3544nawph_adj ck_ef2024nas_adj ck_ef4554aw_adj ck_em5564as_adj
save(type=excelxml, mode=update) {%wfile}.xlsx range="assect_checked!a1" @keep ck_em3544nawph_adj ck_ef2024nas_adj ck_ef4554aw_adj ck_em5564as_adj


