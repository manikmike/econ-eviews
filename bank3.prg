' Compress databanks (BANK3 command file logic)

logmode logmsg

%banklist = "adtr222 atr222 dtr222 otl_tr222"

if (%0 <> "") then
   %banklist = %0
endif

for %bank {%banklist}
  logmsg {%bank}
  shell del temp.bnk > NUL
  dbopen(type=aremos) {%bank}.bnk
  db(type=aremos) temp.bnk
  copy {%bank}::*.* temp::*.*
  close @db
  shell attrib -r {%bank}.bnk
  shell backup.exe {%bank}
  shell copy temp.bnk {%bank}.bnk > NUL
  shell del databank.txt temp.bnk temp.txt > NUL
next

' Maybe do it this way to insert into the B-trees in random order
' rather than how EViews chooses to (probably alphabetical order):
'    %objects = @wquery("atr212.bnk", "name matches *", "name")
' randomize the %objects string and copy element-by-element


