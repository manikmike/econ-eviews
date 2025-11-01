
exec .\setup2

wfopen S:\LRECON\Data\Processed\ESF\TR2025\esf_rpt_2024.wf1

%store = _
"TE_SF_LRP " + _
"TE_SF_TEO " + _
"TE_SFM_LRP " + _
"TE_SFO_LRP " + _
"WE_SF " + _
"WE_SF_LRP " + _
"WE_SF_TEO " + _
"WE_SFM_LRP " + _
"WE_SFO_LRP"

for %s {%store}
   copy esf_rpt_2024::data\{%s} work::a\{%s}
next

wfclose esf_rpt_2024

wfselect work
wfsave(2) esf
wfclose esf


