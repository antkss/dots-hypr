"vim spector configuration
set equalalways
let g:vimspector_sidebar_width = 40
let g:vimspector_bottombar_height = 0
let g:vimspector_terminal_maxwidth = 60
let g:vimspector_terminal_minwidth = 60

"debug mapping
nnoremap <S-m> :VimspectorInstall \| execute "call vimspector\#Launch()" <CR>
nnoremap <S-c> :call vimspector#Continue()<CR>

nnoremap <S-b> :call vimspector#ToggleBreakpoint()<CR>
nnoremap <S-d> :call vimspector#ClearBreakpoints()<CR>

nmap <C-S-r> <Plug>VimspectorRestart
" nmap <S-o> <Plug>VimspectorStepOut
nmap <S-i> <Plug>VimspectorStepInto
nmap <S-n> <Plug>VimspectorStepOver
nnoremap <S-e> :call vimspector#Reset( { 'interactive': v:false } )<CR>
