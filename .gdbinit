# source ~/.gef-2024.01.py
# set debuginfod enabled on
set auto-load safe-path /
source /usr/share/pwndbg/gdbinit.py
alias la=!ls --color=auto
alias m=start
alias uf= disassemble
alias nvim=!nvim
alias cx=context
alias at=attach
alias px=!ps aux | grep -P '\.\/' | awk '{print $2, $11}'
alias ff=search
alias vm=vmmap
alias tl=x/40xg
alias cls=!clear
set context-sections regs disasm code ghidra stack expressions threads
set context-register-color green
set enhance-comment-color green
set enhance-integer-value-color green
set enhance-string-value-color green
set enhance-unknown-color green
set telescope-skip-repeating-val off

