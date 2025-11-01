' This program appends the old March CPS data with the updated data for 2017
' NOTE: Run the program ccps117.prg first to create the workfile cpsr117.wf1

shell copy cpsr68116.bnk cpsr68117.bnk ' more efficient than creating an empty bank and copying individual series

wfopen cpsr117.wf1
dbopen(type=aremos) cpsr68117.bnk ' copying from workfile to databank is slow, but working around an EViews bug

copy(m) a\*_ cpsr68117::*&.a ' ampersands not allowed in workspace, so rename in databank

delete *_

store(db=cpsr68117) *

close cpsr117
close @db

