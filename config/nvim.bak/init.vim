"NERDTree plugin 
call plug#begin('~/.config/nvim/plugged')
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
" nerdtree hightlight and icons
Plug 'octol/vim-cpp-enhanced-highlight'
" Plug 'neovim/nvim-lsp' " nvim-lsp
Plug 'VonHeikemen/lsp-zero.nvim'
" Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'ryanoasis/vim-devicons'
" Plug 'skywind3000/asyncrun.vim'
" save and restore nerdtree state between sessions
"Git status flag
" Plug 'Xuyuanp/nerdtree-git-plugin'
"COC VIM
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Vim line
Plug 'vim-airline/vim-airline'
"vim translator 
Plug 'voldikss/vim-translator'
"find and replace
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-pack/nvim-spectre'
" Fuzzy Finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" debug plugin "
Plug 'puremourning/vimspector'
"comment plugin
Plug 'numToStr/Comment.nvim'
"chatgpt plugin 
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
"theme plugin
Plug 'navarasu/onedark.nvim'
call plug#end()

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`. call plug#end()
let &makeprg = 'g++ -g -o %< % -fno-stack-protector -no-pie'
syntax enable
set mousescroll=ver:0
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
" NERDTreeToggle configuration
nnoremap <F5> :NERDTreeToggle<CR>
"nnoremap <C-f> :NERDTreeFind<CR>
nnoremap = :Files<CR>
nnoremap q: q <CR>
set number

" auto close bracket setup 
nmap <S-j> <PageDown> 
" map <ScrollWheelUp> <C-k>
" map <ScrollWheelDown> <C-j>
nnoremap + :join <CR>
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
lua require('Comment').setup()
"debug configuration "

nnoremap <S-m> :call vimspector#Launch()<CR>
nnoremap <S-c> :call vimspector#Continue()<CR>

nnoremap <S-b> :call vimspector#ToggleBreakpoint()<CR>
nnoremap <S-d> :call vimspector#ClearBreakpoints()<CR>

nmap <C-S-r> <Plug>VimspectorRestart
" nmap <S-o> <Plug>VimspectorStepOut
nmap <S-i> <Plug>VimspectorStepInto
nmap <S-n> <Plug>VimspectorStepOver
nnoremap <S-e> :call vimspector#Reset( { 'interactive': v:false } )<CR>
nmap <C-s> :w<CR>
" map the alt key to the esc key
inoremap <C-c> <Esc>
" " Copy to clipboard
vnoremap  y  "+y
nnoremap  Y  "+yg_
nnoremap  y  "+y
nnoremap  yy  "+yy
" " Cut to clipboard
vnoremap  x  "+x
nnoremap  x  "+x
vnoremap  X  "+X
nnoremap  X  "+X

set autoread

" " Paste from clipboard
nnoremap p "+p
vnoremap p "+p
vnoremap P p
"vim translator configuration
vnoremap t :'<,'>Translate --engine=bing<CR>
let g:translator_target_lang = 'vi'
nnoremap t :Translate --engine=bing<CR>

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
colorscheme onedark  
" mov binding 
" nnoremap <C-l> <C-W><C-L>
" nnoremap <C-k> <C-W><C-K>
" nnoremap <C-j> <C-W><C-J>
" nnoremap <C-h> <C-W><C-H>
vnoremap <C-j> <C-d>
vnoremap <C-k> <C-u>
nnoremap <C-k> <C-u>
nnoremap <C-j> <C-d>