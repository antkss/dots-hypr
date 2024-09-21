set debuginfod enabled on
# set auto-load safe-path /
source /home/as/cac/pwndbg/gdbinit.py
source /home/as/cac/tools/gdbinit
# source /home/as/cac/pwn/gdbinit.py
# source ~/gef/gef/gef.py
# source ~/gef/gef.py
# source /home/as/cac/pwndbg/.venv/lib/python3.12/site-packages/decomp2dbg/d2d.py
# source /usr/share/pwndbg/gdbinit.py
source /home/as/.gdbnew.py
# source /usr/share/pwndbg/gdbinit.py
# alias de=decompiler
# alias angr=decompiler connect angr
# alias bj=decompiler connect binaryninja
define ls 
!ls
end
define rm
!rm
end
define malloc
call (int*)malloc($arg0)
end
define free
call (void)free($arg0)
end
define calloc
call (int*)calloc($arg0, $arg1)
end
define realloc
call (int*)realloc($arg0, $arg1)
end
define set64
set *(long int*)$arg0 = $arg1
end
define set32
set *(int*)$arg0 = $arg1
end
# how to use protect
# protect dataofaddress address
# result is the mangle of dataofaddress
define protect
p/x $arg0^($arg1>>12)
end
# define nea
# x/10xi $pc
# end
set disassembly-flavor intel
# alias la=!ls --color=auto
alias m=start
alias uf= disassemble
alias nvim=!nvim
alias at=attach
alias px=!ps aux | grep -P '\.\/' | awk '{print $2, $11}'
alias ff=search
alias cx=context
# alias px = !px
alias vm=vmmap
#alias ghi=decompiler connect ghidra
# alias tl=x/40xg
alias cls=!clear
alias cs=checksec
# alias ne=nextjump
# alias pds=pdisass pc
# alias ls=!ls
# alias ls=!ls --color=auto

set context-clear-screen on
set context-sections regs  stack ghidra expressions threads disasm code
set context-register-color red
set context-register-changed-color underline
set dereference-limit 5
set enhance-comment-color green
set enhance-integer-value-color green
set enhance-string-value-color green
set enhance-unknown-color green
set telescope-skip-repeating-val off
set memory-heap-color yellow
set gcc-compiler-path /usr/bin/gcc
set context-disasm-lines 5
# set context-code-lines 5
set context-stack-lines 6
set show-flags on
set show-compact-regs on
set resolve-heap-via-heuristic force
set disable-randomization off
# set emulate-future-annotations False
# set emulate-annotations off
# gef config gef.bruteforce_main_arena True
set history filename ~/.gdb_history
set history size 1000000
# gef config gef.extra_plugins_dir /home/as/gef/gef/scripts
# gef config context.ignore_registers  "$cs $ss $ds $es $fs $gs"
# source ~/cac/splitmind/gdbinit.py
# python
# import splitmind
# (splitmind.Mind()
#   .above(display="regs")
#   .right(display="stack")
#   # .right(of="main", display="code")
#   .right(of="main", display="disasm")
#   .show("legend", on="disasm")
# ).build()
# end
#
