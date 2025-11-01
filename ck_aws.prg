' This program loads the necessary data for the 'check of AWS and components'

' Update all entries prior to line ' *** END of Update section ***

%TR = "25" 		' current TR year

%abankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\atr252.wf1" 	' location of the relevant A-bank
%abank = "atr252"

%dbankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\dtr252.wf1" 	' location of the relevant D-bank
%dbank = "dtr252"

%otlbankpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\ModelRuns\TR2025\2025-0205-1400-TR252\out\mul\otl_tr252.wf1" 	' location of the relevant OTL bank
%otlbank = "otl_tr252"


%outputpath = "\\Ba.ad.ssa.gov\files\SHARED_OLRAE\LRECON\TrusteesReports\TR2025\Checks\EconConsistencyChecks\" 	' location to save the resulting workfile to
' *** END of Update section ***

!STARTYEAR=1990
!ENDYEAR=2100


%wfname = "ck_aws_tr" + %TR + "2"
%pg = "atr" + %TR + "2data"

wfcreate(wf={%wfname},page={%pg}) a !STARTYEAR !ENDYEAR
smpl @all

wfopen %abankpath 
pageselect a

for %ser acwahi acwa aws_mef aiw wsd wscahi wsca ws_mef wswahi wswa wsw_mef eaw enaw edmil prod ahrs pgdp we_sf wsprrb wesl_n_nhi wesl_n_nhi_s wesl_n_nhi_e wesl_n_nhi_ns wsph wsph_o tesl_n_s wefc_n wesl_n_hi wsca_hio_oth wsgfm wsgmlc
	copy {%abank}::a\{%ser} {%wfname}::{%pg}\*
next
wfclose {%abank}

wfselect {%wfname}
pageselect {%pg}
smpl @all


wfopen %otlbankpath 
pageselect a

for %ser ws_eo_und ws_eo_esf ws_eo_mef ws_eo_mefc
	copy {%otlbank}::a\{%ser} {%wfname}::{%pg}\*
next
wfclose {%otlbank}

wfselect {%wfname}
pageselect {%pg}
smpl @all


wfopen %dbankpath 
pageselect a

for %ser te_ps_m te_ph_m
	copy {%dbank}::a\{%ser} {%wfname}::{%pg}\*
next
wfclose {%dbank}

wfselect {%wfname}
pageselect {%pg}
smpl @all

series ew=eaw+enaw+edmil
series aws_us=wsd/ew
series ws_ps_m = (wesl_n_nhi_s/tesl_n_s) * te_ps_m
series ws_ph_m = (0.5 * 1.800 /44.32167) *  (aiw(-1)/1000 * prod/prod(-1) * ahrs/ahrs(-1) * pgdp/pgdp(-1)) * te_ph_m

group atr{%TR}2 	aws_us acwahi acwa aws_mef aiw wsd wscahi wsca ws_mef ew wswahi wswa wsw_mef _
					ws_eo_und ws_eo_esf ws_eo_mef ws_eo_mefc we_sf wsprrb wesl_n_nhi wesl_n_nhi_s _
					wesl_n_nhi_e wesl_n_nhi_ns wsph wsph_o tesl_n_s te_ps_m ws_ps_m ws_ph_m wefc_n wesl_n_hi wsca_hio_oth wsgfm wsgmlc

%save = %outputpath + %wfname + ".wf1"
wfsave(2) %save
'wfclose %wfname


