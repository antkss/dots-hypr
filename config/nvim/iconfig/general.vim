
" general configurations
set mouse=n
set number 
" change make properties
let &makeprg = 'g++ -g -o %< % -fno-stack-protector -no-pie'
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

