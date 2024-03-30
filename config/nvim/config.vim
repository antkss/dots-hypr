
" general configurations
set mouse=r
set number 
set mousescroll=ver:0
"vim spector configuration
let g:vimspector_sidebar_width = 40
let g:vimspector_bottombar_height = 0
let g:vimspector_terminal_maxwidth = 60
let g:vimspector_terminal_minwidth = 60

let g:airline_powerline_fonts = 1                       " Enable font for status bar
let g:airline_theme='base16_flat'                           " Theme OneDark

let g:airline#extensions#tabline#enabled = 1            " Enable Tab bar
let g:airline#extensions#tabline#left_sep = ' '         " Enable Tab seperator 
let g:airline#extensions#tabline#left_alt_sep = '|'     " Enable Tab seperator
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#fnamemod = ':t'        " Set Tab name as file name

let g:airline#extensions#whitespace#enabled = 0         " Remove warning whitespace"

let g:airline_section_error=''
" NERDTree hightlight configuration
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
" change make properties
let &makeprg = 'g++ -g -o %< % -fno-stack-protector -no-pie'
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
"use enter key to comfirm completion
inoremap <expr> <return> coc#pum#visible() ? coc#pum#confirm() : "\<RETURN>"
inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
