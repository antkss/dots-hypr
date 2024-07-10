# source /home/as/cac/gef/gef.py
# source /usr/share/gef/gef.py
source ~/.gef-2024.01.py
source /home/as/cac/pwndbg/.venv/lib/python3.12/site-packages/decomp2dbg/d2d.py
gef config context.layout "legend stack code args source memory extra"
gef config context.nb_lines_stack 6
gef config context.nb_lines_code 1
gef config context.nb_lines_code_prev 1
gef config theme.dereference_base_address yellow
gef config gef.disable_target_remote_overwrite false
alias ls=!ls
alias cs=checksec
alias px=!ps aux | grep -P '\.\/' | awk '{print $2, $11}'
alias m=start
alias uf=disassemble
alias nea=x/10xi $rip-0x10
alias ff=search-pattern
alias angr=decompiler connect angr
alias ghi=decompiler connect ghidra
alias cx=context
alias bin=heap bins
source ~/.gdbnew.py
# gef config context.clear_screen false
