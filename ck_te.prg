' This program exports series needed for Pat's TE Check
' to an Excel spreadsheet

exec .\setup2

%FILENAME = "e:\usr\mlmiller\TR20202 - Check of TE and components - 20200123.xlsx"

pageselect a
smpl 1980 2100

%l_name0 = "no_asf1 no_nasf1 " + _
           "no_asf2 no_nasf2 " + _
           "no_asj1 no_nasj1 " + _
           "no_asj2 no_nasj2 " + _
           "no_awj no_nawj "   + _
           "no_awjf no_nawjf " + _
           "no_awh no_nawh "   + _
           "no_awt no_nawt "   + _
           "no_awtfa no_awtfn no_nawtf " + _
           "no_a no_na no_no nil nild"

%db_name0 = "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 otl_tr202 op1202o op1202o"

call getseries(100, %db_name0, %l_name0, "raw_no!a11")

%l_name1 = "teo_asf1 teo_asf2 teo_asj1 teo_asj2 teo_awj teo_awjf teo_awh teo_awt teo_awtfa teo_awtfn " + _
           "teo_nasf1 teo_nasf2 teo_nasj1 teo_nasj2 teo_nawj teo_nawjf teo_nawh teo_nawt teo_nawtf teo_no_16o " + _
           "teo_nol_m_16o teo_nol_s_16o teo_nol_u_16o " + _
           "teo_noi_m_16o teo_noi_s_16o teo_noi_u_16o " + _
           "teo_mef_16o teo_mefc_16o teo_esf_16o teo_und_16o teo teo_a teo_na teo_no teo teo_mef teo_mefc teo_esf teo_und"

%db_name1 = "otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 otl_tr202 " + _
            "otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202 otl_tr202"

call getseries(200, %db_name1, %l_name1, "raw_teo!a11")

%l_name2 = "te tceahi tcea tefc_n_n tesl_n_n_hi tcea ce_m te_sfo_lrp teph_n eprrb tep_n_n_s tepo_n " + _
           "tesl_n_n_nhi_s tesl_n_n_nhi_e tesl_n_n_nhi_ns seo_hi seo wsw_mef wsw_hio_oth tefc_n_n_se tesl_n_n_hi_se wsw_hio_oth_se " + _
           "wsw_hio_oth tefc_n_n_se tesl_n_n_hi_se wsw_hio_oth_se te_mn te_slos_m te_sloe_m te_sloo_m te_rro_m te_ps_m te_ph_m heso_m " + _
           "he_wof_m he_wol_m he_wor_m he_wosf_m he_wosl_m he_wosr_m ceso_m tel_so wswahi wswa"

%db_name2 = "atr202 atr202 atr202 atr202 atr202 atr202 atr202 atr202 atr202 dtr202 atr202 dtr202 " + _
            "atr202 atr202 atr202 atr202 atr202 atr202 atr202 atr202 atr202 atr202 " + _
            "atr202 atr202 atr202 atr202 atr202 dtr202 dtr202 mef mef dtr202 dtr202 atr202 " + _
            "dtr202 atr202 atr202 dtr202 atr202 atr202 atr202 atr202 atr202 atr202"

call getseries(300, %db_name2, %l_name2, "raw_te!a11")

subroutine getseries(scalar !n, string %database, string %series, string %range)

   %list = @winterleave(%database, %series)
   for %db %s {%list}
     !n = !n + 1
     dbopen {%db}.bnk
     genr _{!n}_{%s} = {%db}::{%s}
   next
   close @db
   pagesave(type=excelxml, mode=update) %FILENAME range=%range @smpl 1980 2100
   delete *

endsub

