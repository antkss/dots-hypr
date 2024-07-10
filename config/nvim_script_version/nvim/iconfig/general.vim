
" general configurations
" set mouse=ni
" set mousescroll=ver:0,hor:0
set number 
" change make properties
let &makeprg = 'g++ -g -o %< % -fno-stack-protector -no-pie'
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

