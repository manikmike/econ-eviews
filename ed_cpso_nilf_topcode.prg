' Person's age as of the end of the survey week.
' Edited Universe:  PRPERTYP = 1, 2, or 3
' Topcoded at 90 from 1994 to Jan. 2002,  at 80 from Feb. 2002 to March 2004.
' Topcoded at 85, with values of 80-84 topcoded at 80, from April 2004 to present.

exec .\setup2
logmode logmsg

%last_yr = "2024"		' latest year for which we have CPS NILF data; typically we would have data for only part of the year, usually through September
%last_mo = "9"			' The last month within %last_yr for which we have data; typically this is September, i.e. month 9.
%last_full_yr = "2023"

pageselect m
smpl {%last_full_yr} {%last_yr}

wfopen cps_nilf_month


for %s m f
   for %a 80 85 90 81 82 83 84 86 87 88 89
      for %c r1 d1 o1 d2 r2 i s h o2 dc o3
         'fetch nl{%s}{%a}_{%c}
			copy cps_nilf_month::m\nl{%s}{%a}_{%c} work::m\nl{%s}{%a}_{%c}
      next
   next
next

for %s m f
   for %a 80 85 90 81 82 83 84 86 87 88 89
      for %c n e u
         'fetch {%c}{%s}{%a}
			copy cps_nilf_month::m\{%c}{%s}{%a} work::m\{%c}{%s}{%a}
      next
   next
next

for %s m f
   for %a 80 85 90 81 82 83 84 86 87 88 89
      for %c r1 d1 o1 d2 r2 i s h o2 dc o3
         for %m nm ms ma
            'fetch nl{%s}{%a}{%m}_{%c}
				copy cps_nilf_month::m\nl{%s}{%a}{%m}_{%c} work::m\nl{%s}{%a}{%m}_{%c}
		 next
      next
   next
next


for %s m f
   for %a 80 85 90 81 82 83 84 86 87 88 89
      for %c n e u
         for %m nm ms ma
            'fetch {%c}{%s}{%a}{%m}
				copy cps_nilf_month::m\{%c}{%s}{%a}{%m} work::m\{%c}{%s}{%a}{%m}
		 next
      next
   next
next

close cps_nilf_month

for %s m f
   for %c r1 d1 o1 d2 r2 i s h o2 dc o3
      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr nl{%s}90o_{%c} = 0

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}  
      genr nl{%s}8084_{%c} = nl{%s}80_{%c}

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr nl{%s}85o_{%c} = nl{%s}85_{%c}

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      nl{%s}90_{%c}  = 0

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      nl{%s}85_{%c}  = 0

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr nl{%s}80o_{%c}  = nl{%s}8084_{%c} + nl{%s}85o_{%c}

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      nl{%s}80_{%c}  = 0
   next
next

for %s m f
   for %c n e u
      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr {%c}{%s}90o = 0

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr {%c}{%s}8084 = {%c}{%s}80 

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr {%c}{%s}85o = {%c}{%s}85

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr {%c}{%s}90  = 0

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      {%c}{%s}85  = 0

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      genr {%c}{%s}80o  = {%c}{%s}8084 + {%c}{%s}85o

      smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
      {%c}{%s}80  = 0
   next
next

for %s m f
   for %c r1 d1 o1 d2 r2 i s h o2 dc o3
      for %m nm ms ma
        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        genr nl{%s}90o{%m}_{%c} = 0
        
        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        genr nl{%s}8084{%m}_{%c} = nl{%s}80{%m}_{%c} 

        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        genr nl{%s}85o{%m}_{%c} = nl{%s}85{%m}_{%c}

        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        nl{%s}90{%m}_{%c}  = 0

        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        nl{%s}85{%m}_{%c}  = 0

        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        genr nl{%s}80o{%m}_{%c}  = nl{%s}8084{%m}_{%c} + nl{%s}85o{%m}_{%c}

        smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
        nl{%s}80{%m}_{%c}  = 0
      next
   next
next

for %s m f
   for %c n e u
      for %m nm ms ma
         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         genr {%c}{%s}90o{%m} = 0

         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         genr {%c}{%s}8084{%m} = {%c}{%s}80{%m} 

         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         genr {%c}{%s}85o{%m} = {%c}{%s}85{%m}

         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         {%c}{%s}90{%m}  = 0

         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         {%c}{%s}85{%m}  = 0

         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         genr {%c}{%s}80o{%m}  = {%c}{%s}8084{%m} + {%c}{%s}85o{%m}

         smpl {%last_full_yr}m1 {%last_yr}m{%last_mo}
         {%c}{%s}80{%m}  = 0
      next
   next
next


%aggregate = _
	"nm80 nm8084 nm85 nm90 nm80o nm85o nm90o " + _
	"em80 em8084 em85 em90 em80o em85o em90o " + _
	"um80 um8084 um85 um90 um80o um85o um90o " + _
	"nf80 nf8084 nf85 nf90 nf80o nf85o nf90o " + _
	"ef80 ef8084 ef85 ef90 ef80o ef85o ef90o " + _
	"uf80 uf8084 uf85 uf90 uf80o uf85o uf90o " + _
	"nlm80_r1 nlm8084_r1 nlm85_r1 nlm90_r1 nlm80o_r1 nlm85o_r1 nlm90o_r1 " + _
	"nlm80_r2 nlm8084_r2 nlm85_r2 nlm90_r2 nlm80o_r2 nlm85o_r2 nlm90o_r2 " + _
	"nlm80_d1 nlm8084_d1 nlm85_d1 nlm90_d1 nlm80o_d1 nlm85o_d1 nlm90o_d1 " + _
	"nlm80_d2 nlm8084_d2 nlm85_d2 nlm90_d2 nlm80o_d2 nlm85o_d2 nlm90o_d2 " + _
	"nlm80_o1 nlm8084_o1 nlm85_o1 nlm90_o1 nlm80o_o1 nlm85o_o1 nlm90o_o1 " + _
	"nlm80_o2 nlm8084_o2 nlm85_o2 nlm90_o2 nlm80o_o2 nlm85o_o2 nlm90o_o2 " + _
	"nlm80_o3 nlm8084_o3 nlm85_o3 nlm90_o3 nlm80o_o3 nlm85o_o3 nlm90o_o3 " + _
	"nlm80_s nlm8084_s nlm85_s nlm90_s nlm80o_s nlm85o_s nlm90o_s " + _
	"nlm80_i nlm8084_i nlm85_i nlm90_i nlm80o_i nlm85o_i nlm90o_i " + _
	"nlm80_h nlm8084_h nlm85_h nlm90_h nlm80o_h nlm85o_h nlm90o_h " + _
	"nlm80_dc nlm8084_dc nlm85_dc nlm90_dc nlm80o_dc nlm85o_dc nlm90o_dc " + _
	"nlf80_r1 nlf8084_r1 nlf85_r1 nlf90_r1 nlf80o_r1 nlf85o_r1 nlf90o_r1 " + _
	"nlf80_r2 nlf8084_r2 nlf85_r2 nlf90_r2 nlf80o_r2 nlf85o_r2 nlf90o_r2 " + _
	"nlf80_d1 nlf8084_d1 nlf85_d1 nlf90_d1 nlf80o_d1 nlf85o_d1 nlf90o_d1 " + _
	"nlf80_d2 nlf8084_d2 nlf85_d2 nlf90_d2 nlf80o_d2 nlf85o_d2 nlf90o_d2 " + _
	"nlf80_o1 nlf8084_o1 nlf85_o1 nlf90_o1 nlf80o_o1 nlf85o_o1 nlf90o_o1 " + _
	"nlf80_o2 nlf8084_o2 nlf85_o2 nlf90_o2 nlf80o_o2 nlf85o_o2 nlf90o_o2 " + _
	"nlf80_o3 nlf8084_o3 nlf85_o3 nlf90_o3 nlf80o_o3 nlf85o_o3 nlf90o_o3 " + _
	"nlf80_s nlf8084_s nlf85_s nlf90_s nlf80o_s nlf85o_s nlf90o_s " + _
	"nlf80_i nlf8084_i nlf85_i nlf90_i nlf80o_i nlf85o_i nlf90o_i " + _
	"nlf80_h nlf8084_h nlf85_h nlf90_h nlf80o_h nlf85o_h nlf90o_h " + _
	"nlf80_dc nlf8084_dc nlf85_dc nlf90_dc nlf80o_dc nlf85o_dc nlf90o_dc"


%nevermarried = _
	"nm80nm nm8084nm nm85nm nm90nm nm80onm nm85onm nm90onm " + _
	"em80nm em8084nm em85nm em90nm em80onm em85onm em90onm " + _
	"um80nm um8084nm um85nm um90nm um80onm um85onm um90onm " + _
	"nf80nm nf8084nm nf85nm nf90nm nf80onm nf85onm nf90onm " + _
	"ef80nm ef8084nm ef85nm ef90nm ef80onm ef85onm ef90onm " + _
	"uf80nm uf8084nm uf85nm uf90nm uf80onm uf85onm uf90onm " + _
	"nlm80nm_r1 nlm8084nm_r1 nlm85nm_r1 nlm90nm_r1 nlm80onm_r1 nlm85onm_r1 nlm90onm_r1 " + _
	"nlm80nm_r2 nlm8084nm_r2 nlm85nm_r2 nlm90nm_r2 nlm80onm_r2 nlm85onm_r2 nlm90onm_r2 " + _
	"nlm80nm_d1 nlm8084nm_d1 nlm85nm_d1 nlm90nm_d1 nlm80onm_d1 nlm85onm_d1 nlm90onm_d1 " + _
	"nlm80nm_d2 nlm8084nm_d2 nlm85nm_d2 nlm90nm_d2 nlm80onm_d2 nlm85onm_d2 nlm90onm_d2 " + _
	"nlm80nm_o1 nlm8084nm_o1 nlm85nm_o1 nlm90nm_o1 nlm80onm_o1 nlm85onm_o1 nlm90onm_o1 " + _
	"nlm80nm_o2 nlm8084nm_o2 nlm85nm_o2 nlm90nm_o2 nlm80onm_o2 nlm85onm_o2 nlm90onm_o2 " + _
	"nlm80nm_o3 nlm8084nm_o3 nlm85nm_o3 nlm90nm_o3 nlm80onm_o3 nlm85onm_o3 nlm90onm_o3 " + _
	"nlm80nm_s nlm8084nm_s nlm85nm_s nlm90nm_s nlm80onm_s nlm85onm_s nlm90onm_s " + _
	"nlm80nm_i nlm8084nm_i nlm85nm_i nlm90nm_i nlm80onm_i nlm85onm_i nlm90onm_i " + _
	"nlm80nm_h nlm8084nm_h nlm85nm_h nlm90nm_h nlm80onm_h nlm85onm_h nlm90onm_h " + _
	"nlm80nm_dc nlm8084nm_dc nlm85nm_dc nlm90nm_dc nlm80onm_dc nlm85onm_dc nlm90onm_dc " + _
	"nlf80nm_r1 nlf8084nm_r1 nlf85nm_r1 nlf90nm_r1 nlf80onm_r1 nlf85onm_r1 nlf90onm_r1 " + _
	"nlf80nm_r2 nlf8084nm_r2 nlf85nm_r2 nlf90nm_r2 nlf80onm_r2 nlf85onm_r2 nlf90onm_r2 " + _
	"nlf80nm_d1 nlf8084nm_d1 nlf85nm_d1 nlf90nm_d1 nlf80onm_d1 nlf85onm_d1 nlf90onm_d1 " + _
	"nlf80nm_d2 nlf8084nm_d2 nlf85nm_d2 nlf90nm_d2 nlf80onm_d2 nlf85onm_d2 nlf90onm_d2 " + _
	"nlf80nm_o1 nlf8084nm_o1 nlf85nm_o1 nlf90nm_o1 nlf80onm_o1 nlf85onm_o1 nlf90onm_o1 " + _
	"nlf80nm_o2 nlf8084nm_o2 nlf85nm_o2 nlf90nm_o2 nlf80onm_o2 nlf85onm_o2 nlf90onm_o2 " + _
	"nlf80nm_o3 nlf8084nm_o3 nlf85nm_o3 nlf90nm_o3 nlf80onm_o3 nlf85onm_o3 nlf90onm_o3 " + _
	"nlf80nm_s nlf8084nm_s nlf85nm_s nlf90nm_s nlf80onm_s nlf85onm_s nlf90onm_s " + _
	"nlf80nm_i nlf8084nm_i nlf85nm_i nlf90nm_i nlf80onm_i nlf85onm_i nlf90onm_i " + _
	"nlf80nm_h nlf8084nm_h nlf85nm_h nlf90nm_h nlf80onm_h nlf85onm_h nlf90onm_h " + _
	"nlf80nm_dc nlf8084nm_dc nlf85nm_dc nlf90nm_dc nlf80onm_dc nlf85onm_dc nlf90onm_dc"


%spousepresent = _
	"nm80ms nm8084ms nm85ms nm90ms nm80oms nm85oms nm90oms " + _
	"em80ms em8084ms em85ms em90ms em80oms em85oms em90oms " + _
	"um80ms um8084ms um85ms um90ms um80oms um85oms um90oms " + _
	"nf80ms nf8084ms nf85ms nf90ms nf80oms nf85oms nf90oms " + _
	"ef80ms ef8084ms ef85ms ef90ms ef80oms ef85oms ef90oms " + _
	"uf80ms uf8084ms uf85ms uf90ms uf80oms uf85oms uf90oms " + _
	"nlm80ms_r1 nlm8084ms_r1 nlm85ms_r1 nlm90ms_r1 nlm80oms_r1 nlm85oms_r1 nlm90oms_r1 " + _
	"nlm80ms_r2 nlm8084ms_r2 nlm85ms_r2 nlm90ms_r2 nlm80oms_r2 nlm85oms_r2 nlm90oms_r2 " + _
	"nlm80ms_d1 nlm8084ms_d1 nlm85ms_d1 nlm90ms_d1 nlm80oms_d1 nlm85oms_d1 nlm90oms_d1 " + _
	"nlm80ms_d2 nlm8084ms_d2 nlm85ms_d2 nlm90ms_d2 nlm80oms_d2 nlm85oms_d2 nlm90oms_d2 " + _
	"nlm80ms_o1 nlm8084ms_o1 nlm85ms_o1 nlm90ms_o1 nlm80oms_o1 nlm85oms_o1 nlm90oms_o1 " + _
	"nlm80ms_o2 nlm8084ms_o2 nlm85ms_o2 nlm90ms_o2 nlm80oms_o2 nlm85oms_o2 nlm90oms_o2 " + _
	"nlm80ms_o3 nlm8084ms_o3 nlm85ms_o3 nlm90ms_o3 nlm80oms_o3 nlm85oms_o3 nlm90oms_o3 " + _
	"nlm80ms_s nlm8084ms_s nlm85ms_s nlm90ms_s nlm80oms_s nlm85oms_s nlm90oms_s " + _
	"nlm80ms_i nlm8084ms_i nlm85ms_i nlm90ms_i nlm80oms_i nlm85oms_i nlm90oms_i " + _
	"nlm80ms_h nlm8084ms_h nlm85ms_h nlm90ms_h nlm80oms_h nlm85oms_h nlm90oms_h " + _
	"nlm80ms_dc nlm8084ms_dc nlm85ms_dc nlm90ms_dc nlm80oms_dc nlm85oms_dc nlm90oms_dc " + _
	"nlf80ms_r1 nlf8084ms_r1 nlf85ms_r1 nlf90ms_r1 nlf80oms_r1 nlf85oms_r1 nlf90oms_r1 " + _
	"nlf80ms_r2 nlf8084ms_r2 nlf85ms_r2 nlf90ms_r2 nlf80oms_r2 nlf85oms_r2 nlf90oms_r2 " + _
	"nlf80ms_d1 nlf8084ms_d1 nlf85ms_d1 nlf90ms_d1 nlf80oms_d1 nlf85oms_d1 nlf90oms_d1 " + _
	"nlf80ms_d2 nlf8084ms_d2 nlf85ms_d2 nlf90ms_d2 nlf80oms_d2 nlf85oms_d2 nlf90oms_d2 " + _
	"nlf80ms_o1 nlf8084ms_o1 nlf85ms_o1 nlf90ms_o1 nlf80oms_o1 nlf85oms_o1 nlf90oms_o1 " + _
	"nlf80ms_o2 nlf8084ms_o2 nlf85ms_o2 nlf90ms_o2 nlf80oms_o2 nlf85oms_o2 nlf90oms_o2 " + _
	"nlf80ms_o3 nlf8084ms_o3 nlf85ms_o3 nlf90ms_o3 nlf80oms_o3 nlf85oms_o3 nlf90oms_o3 " + _
	"nlf80ms_s nlf8084ms_s nlf85ms_s nlf90ms_s nlf80oms_s nlf85oms_s nlf90oms_s " + _
	"nlf80ms_i nlf8084ms_i nlf85ms_i nlf90ms_i nlf80oms_i nlf85oms_i nlf90oms_i " + _
	"nlf80ms_h nlf8084ms_h nlf85ms_h nlf90ms_h nlf80oms_h nlf85oms_h nlf90oms_h " + _
	"nlf80ms_dc nlf8084ms_dc nlf85ms_dc nlf90ms_dc nlf80oms_dc nlf85oms_dc nlf90oms_dc"



%spouseabsent = _
	"nm80ma nm8084ma nm85ma nm90ma nm80oma nm85oma nm90oma " + _
	"em80ma em8084ma em85ma em90ma em80oma em85oma em90oma " + _
	"um80ma um8084ma um85ma um90ma um80oma um85oma um90oma " + _
	"nf80ma nf8084ma nf85ma nf90ma nf80oma nf85oma nf90oma " + _
	"ef80ma ef8084ma ef85ma ef90ma ef80oma ef85oma ef90oma " + _
	"uf80ma uf8084ma uf85ma uf90ma uf80oma uf85oma uf90oma " + _
	"nlm80ma_r1 nlm8084ma_r1 nlm85ma_r1 nlm90ma_r1 nlm80oma_r1 nlm85oma_r1 nlm90oma_r1 " + _
	"nlm80ma_r2 nlm8084ma_r2 nlm85ma_r2 nlm90ma_r2 nlm80oma_r2 nlm85oma_r2 nlm90oma_r2 " + _
	"nlm80ma_d1 nlm8084ma_d1 nlm85ma_d1 nlm90ma_d1 nlm80oma_d1 nlm85oma_d1 nlm90oma_d1 " + _
	"nlm80ma_d2 nlm8084ma_d2 nlm85ma_d2 nlm90ma_d2 nlm80oma_d2 nlm85oma_d2 nlm90oma_d2 " + _
	"nlm80ma_o1 nlm8084ma_o1 nlm85ma_o1 nlm90ma_o1 nlm80oma_o1 nlm85oma_o1 nlm90oma_o1 " + _
	"nlm80ma_o2 nlm8084ma_o2 nlm85ma_o2 nlm90ma_o2 nlm80oma_o2 nlm85oma_o2 nlm90oma_o2 " + _
	"nlm80ma_o3 nlm8084ma_o3 nlm85ma_o3 nlm90ma_o3 nlm80oma_o3 nlm85oma_o3 nlm90oma_o3 " + _
	"nlm80ma_s nlm8084ma_s nlm85ma_s nlm90ma_s nlm80oma_s nlm85oma_s nlm90oma_s " + _
	"nlm80ma_i nlm8084ma_i nlm85ma_i nlm90ma_i nlm80oma_i nlm85oma_i nlm90oma_i " + _
	"nlm80ma_h nlm8084ma_h nlm85ma_h nlm90ma_h nlm80oma_h nlm85oma_h nlm90oma_h " + _
	"nlm80ma_dc nlm8084ma_dc nlm85ma_dc nlm90ma_dc nlm80oma_dc nlm85oma_dc nlm90oma_dc " + _
	"nlf80ma_r1 nlf8084ma_r1 nlf85ma_r1 nlf90ma_r1 nlf80oma_r1 nlf85oma_r1 nlf90oma_r1 " + _
	"nlf80ma_r2 nlf8084ma_r2 nlf85ma_r2 nlf90ma_r2 nlf80oma_r2 nlf85oma_r2 nlf90oma_r2 " + _
	"nlf80ma_d1 nlf8084ma_d1 nlf85ma_d1 nlf90ma_d1 nlf80oma_d1 nlf85oma_d1 nlf90oma_d1 " + _
	"nlf80ma_d2 nlf8084ma_d2 nlf85ma_d2 nlf90ma_d2 nlf80oma_d2 nlf85oma_d2 nlf90oma_d2 " + _
	"nlf80ma_o1 nlf8084ma_o1 nlf85ma_o1 nlf90ma_o1 nlf80oma_o1 nlf85oma_o1 nlf90oma_o1 " + _
	"nlf80ma_o2 nlf8084ma_o2 nlf85ma_o2 nlf90ma_o2 nlf80oma_o2 nlf85oma_o2 nlf90oma_o2 " + _
	"nlf80ma_o3 nlf8084ma_o3 nlf85ma_o3 nlf90ma_o3 nlf80oma_o3 nlf85oma_o3 nlf90oma_o3 " + _
	"nlf80ma_s nlf8084ma_s nlf85ma_s nlf90ma_s nlf80oma_s nlf85oma_s nlf90oma_s " + _
	"nlf80ma_i nlf8084ma_i nlf85ma_i nlf90ma_i nlf80oma_i nlf85oma_i nlf90oma_i " + _
	"nlf80ma_h nlf8084ma_h nlf85ma_h nlf90ma_h nlf80oma_h nlf85oma_h nlf90oma_h " + _
	"nlf80ma_dc nlf8084ma_dc nlf85ma_dc nlf90ma_dc nlf80oma_dc nlf85oma_dc nlf90oma_dc"

%nilf_import = %nevermarried + " " + %spousepresent + " " + %spouseabsent

wfopen cps_nilf_month

' ******** Change the order here: first create q and a variables, and only after that store to databank and clear the workfile. Removes the need for fetch commands below.

pageselect m
copy work::m\* cps_nilf_month::m\*
' delete *

wfselect work
pageselect q
smpl {%last_full_yr} {%last_yr}
for %i {%nilf_import}
   pageselect m
   ' fetch(m) {%i}
   copy(c="an",m) m\{%i} q\{%i}
next
' delete *
pageselect q
smpl @all
copy work::q\* cps_nilf_month::q\*
' delete *

pageselect a
smpl {%last_full_yr} {%last_yr}
for %i {%nilf_import}
   pageselect q
   ' fetch(m) {%i}
   copy(c="an",m) q\{%i} a\{%i}
next
' delete *
pageselect a
smpl @all
copy work::a\* cps_nilf_month::a\*
' delete *

wfselect cps_nilf_month
wfsave cps_nilf_tcode

close @wf

logmsg FINISHED


