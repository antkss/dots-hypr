# source ~/cac/gef/gef.py
# set debuginfod enabled off
set auto-load safe-path /
source /usr/share/pwndbg/gdbinit.py
# alias la=!ls --color=auto
alias m=start
alias uf= disassemble
alias nvim=!nvim
alias cx=context
alias at=attach
alias px=!ps aux | grep -P '\.\/' | awk '{print $2, $11}'
# alias px = !px
alias ff=search
alias vm=vmmap
alias tl=x/40xg
alias cls=!clear
alias cs=checksec
alias nec=nextc
# alias ls=!ls --color=auto
set context-sections code stack expressions threads disasm
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
# set max-visualize-chunk-size 10
set context-clear-screen on
set resolve-heap-via-heuristic force
define ls 
!ls
end
# gef region
# theme address_stack yellow
# gef config gef.bruteforce_main_arena True
