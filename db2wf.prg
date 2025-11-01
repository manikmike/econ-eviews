' This program converts an Aremos databank to an EViews workfile
' in the usual way with pages a, g, m, and vars

' NOTE: It creates separate pages for series with versions other than 
'       a, q, or m with the page name set to the version name
'       possibly with an underscore frequency appended (e.g, "_q")
'       if the version has multiple frequencies
'       Strings and other objects are copied to the vars page

%databank = "atr212_0.bnk"

%workfile = "atr212.wf1"

' Optional first argument to program can be filename (without extension)
if (%0 <> "") then
   %databank = %0 + ".bnk"
   %workfile = %0 + ".wf1"
endif

' Optional second argument to program can be output filename (without extension)
if (%1 <> "") then
    %workfile = %1 + ".wf1"
endif

dbopen(type=aremos) {%databank}

wfcreate(wf=%workfile, page=a) a 1901 2100
pagecreate(page=q) q 1900Q2 2100Q4
pagecreate(page=m) m 1900M2 2100M12
pagecreate(page=vars) a 1901 2100

' Some series names in BKDO1 contain a "&" which is automatically converted to a "_"
' However, there is already a corresponding series name with the "_"
' so one of the series gets overwritten by the other
' Replacing "&" with "xampx" in the workfile prevents the series name conflict and overwrite
' Need to reverse this process in wf2db.prg to restore "&" in the databank series name
for %f a q m
   pageselect {%f}
   %check = @wquery(%databank, "name matches *." + %f + " and not name matches *&*", "name")
   %amps = @wquery(%databank, "name matches *&*." + %f, "name")
   ' string _amp{%f} = %amps
   if (%check <> "") then
      for %s {%check}
         copy {%databank}::{%s} {%f}\*
      next
   endif
   if (%amps <> "") then
      for %s {%amps}
         %sxampx = @replace(%s,"&","xampx")
         copy {%databank}::{%s} {%f}\{%sxampx}
      next
   endif
next


' String objects (lists)
' There are 44 unknown object types in the OTL bank that start with "get_"
pageselect vars
%lists = @wquery(%databank, "name matches *. and not name matches get_*.", "name")
%lists = @lower(%lists)
if (%lists <> "") then
   for %s {%lists}
      fetch(db=%databank) {%s} ' the names have dots appended already
   next
endif

' Convert series with versions other than a, q, or m
' Add factor bank has both quarterly and annual series with version .add
' Resolve by splitting into add_q and add_a pages
' The underscore frequency (e.g, "_q") will be removed from the page name if the version is unique
%other = @wquery(%databank, "not name matches *.a and not name matches *.q and not name matches *.m and not name matches *.", "name, freq")
%other = @lower(%other)
' string other = %other
%version = ""
%frequency = ""
%page = ""
if (%other <> "") then
   for %v %f {%other}
      %v = @mid(%v,@instr(%v,".")+1)
      %version = %version + " " + %v
      %frequency = %frequency + " " + %f
      %page = %page + " " + %v + "_" + %f
   next
endif
%version = @trim(%version)
%frequency = @trim(%frequency)
%page = @trim(%page)

' string version = %version
' string frequency = %frequency
' string page = %page

' Detect frequency automatically for the pagecreate
if (%page <> "") then
   for %p {%page}
      if (@pageexist(%p) = 0) then
          %f = @right(%p,1)
          if (%f = "a") then
             pagecreate(page={%p}) {%f} 1901 2100
          else
          if (%f = "q") then
             pagecreate(page={%p}) {%f} 1900Q2 2100Q4
          else
          if (%f = "m") then
             pagecreate(page={%p}) {%f} 1900M2 2100M12
          endif
          endif
          endif
      endif
   next
endif

if (%other <> "") then
  %nfp = @winterleave(%other, %page, 2, 1) ' name, frequency, page for each series
  for %n %f %p {%nfp}
     pageselect {%p}
     %s = @left(%n,@instr(%n,".")-1)
     copy ::{%n} {%s}
  next
endif

' Rename pages (without underscore frequency) if version only appears with a single frequency
if (%page <> "") then
   %pages = @wunique(%page)
   for %p {%pages}
      %v = @left(%p, @instr(%p,"_")-1)
      ' If it only appears once, then it starts at the same place
      ' whether you start looking from the left or the right
      !i = @instr(%pages, %v)
      !j = @rinstr(%pages, %v)
      if (!i = !j) then
         pagerename {%p} {%v}
      endif
   next
endif

wfsave(2) {%workfile}

wfclose {%workfile}
close {%databank}


