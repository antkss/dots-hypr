# source ~/cac/gef/gef.py
set debuginfod enabled on
set auto-load safe-path /
source /home/as/cac/pwndbg/gdbinit.py
source /usr/lib/python3.12/site-packages/decomp2dbg/d2d.py
source /home/as/.gdbnew.py
# source /usr/share/pwndbg/gdbinit.py
alias de=decompiler
alias angr=decompiler connect angr
alias bj=decompiler connect binaryninja
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
alias ghi=decompiler connect ghidra
alias tl=x/40xg
alias cls=!clear
alias cs=checksec
# alias ne=nextjump
alias pds=pdisass pc
# alias ls=!ls
# alias ls=!ls --color=auto
set context-sections code stack ghidra expressions threads disasm
set context-register-color red
set context-register-changed-color underline
set enhance-comment-color green
set enhance-integer-value-color green
set enhance-string-value-color green
set enhance-unknown-color green
set telescope-skip-repeating-val off
set memory-heap-color yellow
set gcc-compiler-path /usr/bin/gcc
set context-code-lines 1
set context-stack-lines 6
set show-flags on
# set exec-wrapper env 'LD_PRELOAD=/home/as/Music/libc.so.6'
# set exec-wrapper env 'LD_LIBRARY_PATH=/home/as/Music'
# dir /home/as/cac/glibc-2.39/cac
# set max-visualize-chunk-size 10
set context-clear-screen on
set resolve-heap-via-heuristic force

# gef region
# theme address_stack yellow
# gef config gef.bruteforce_main_arena True
set history filename ~/.gdb_history


