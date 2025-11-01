wfopen bkdr1.wf1
wfopen edrrb_tr25.wf1
pageselect edrrb
smpl 1971 2100
copy eprrb bkdr1::a\eprrb
copy wsprrb bkdr1::a\wsprrb
wfselect bkdr1
wfsave(2) bkdr1
wfclose bkdr1
wfclose edrrb_tr25.wf1


