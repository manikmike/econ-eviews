!tryr = 23
%wfile = "ck_tr"+%tryr+"2_addfactors"

wfcreate(wf={%wfile}, page=q) q ({!tryr}-3) {!tryr}
pagecreate(page=a) a {!tryr} {!tryr}
series {%wfile} = 0

