" mapping teleport
vnoremap <C-j> <C-d>
vnoremap <C-k> <C-u>
nnoremap <C-k> <C-u>
nnoremap <C-j> <C-d>
" nerdtree config
nnoremap <F5> :NERDTreeToggle<CR>
"nnoremap <C-f> :NERDTreeFind<CR>
nnoremap = :Files<CR>
nnoremap q: q <CR>

nmap <S-j> <PageDown> 
" mapping function
nnoremap + :join <CR>
" " Paste from clipboard
nnoremap p "+p
vnoremap p "+p
vnoremap P p
"vim translator configuration
vnoremap t :'<,'>Translate --engine=bing<CR>
let g:translator_target_lang = 'vi'
nnoremap t :Translate --engine=bing<CR>
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
