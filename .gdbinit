# source ~/.gef-2024.01.py
# set debuginfod enabled on
set auto-load safe-path /
source /home/as/cac/pwndbg/gdbinit.py
alias la=!ls --color=auto
alias m=start
alias uf= disassemble
alias nvim=!nvim
alias cx=context
alias at=attach
alias px=!ps aux | grep "\.\/"
alias ff=search
set context-sections regs disasm code ghidra stack expressions threads
set context-register-color green
set enhance-comment-color green
set enhance-integer-value-color green
set enhance-string-value-color green
set enhance-unknown-color green
set telescope-skip-repeating-val off

