' This program converts a (specific type of) EViews workfile to an Aremos databank

' The workfile must have the 4 pages - a, q, m, and vars
' Additional pages will be processed to reverse the operations in db2wf.prg

%workfile = "atr212.wf1"

%databank = "atr212.bnk"

' Optional first argument to program can be input/output filenames (without extension)
if (%0 <> "") then
   %workfile = %0 + ".wf1"
   %databank = %0 + ".bnk"
endif

' Optional second argument to program can be output filename (without extension)
if (%1 <> "") then
   %databank = %1 + ".bnk"
endif



wfopen {%workfile}
db(type=aremos) {%databank}

for %f a q m
   pageselect {%f}
   group g * not resid
   %series = g.@members
   delete g
   if (%series <> "") then
      for %s {%series}
         if (@instr(@lower(%s), "xampx") <> 0) then
            %samp = @replace(@lower(%s), "xampx", "&")
            copy {%s} {%databank}::{%samp}.{%f}
         else
            copy {%s} {%databank}::{%s}.{%f}
         endif
      next
   endif
next

pageselect vars
%strings = @wlookup("*")
string strings = %strings
if (%strings <> "") then
   for %s {%strings}
      ' Assume there are no string variable names with an ampersand
      copy {%s} {%databank}::{%s}
   next
endif

' Process remaining pages as if they had been created by db2wf.prg
%pages = @pagelist
' string pages = %pages
%pages = @wdrop(%pages,"a q m vars")
if (%pages <> "") then
   for %p {%pages}
      pageselect {%p}
      %v = %p
      ' Get rid of _freq if needed
      !i = @instr(%v, "_")
      if (!i > 0) then
         %v = @left(%v, !i-1)
      endif
      ' Copy the series to the databank
      group g * not resid
      %series = g.@members
      delete g
      if (%series <> "") then
         for %s {%series}
            if (@instr(@lower(%s), "xampx") <> 0) then
               %samp = @replace(@lower(%s), "xampx", "&")
               copy {%s} {%databank}::{%samp}.{%v}
            else
               copy {%s} {%databank}::{%s}.{%v}
            endif
         next
      endif
   next
endif

wfclose {%workfile}
close {%databank}


