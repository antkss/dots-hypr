
" general configurations
set mouse=r
set number 
augroup load_ultisnips
  autocmd!
  autocmd InsertEnter * silent! NonExistentCommandUltisnips | autocmd! load_ultisnips
augroup END
" change make properties
let &makeprg = 'g++ -g -o %< % -fno-stack-protector -no-pie'
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

