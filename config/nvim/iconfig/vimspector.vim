

"vim spector configuration
let g:vimspector_sidebar_width = 85
let g:vimspector_code_minwidth = 85
let g:vimspector_terminal_minwidth = 70
let g:vimspector_bottombar_height = 0
function! s:fixeverything()
	
	" call win_gotoid( g:vimspector_session_windows.terminal ) 
	" set wfw
	" call win_gotoid( g:vimspector_session_windows.code )  
	" set wfw
	" call win_gotoid( g:vimspector_session_windows.variables )
	" set wfw
	" call win_gotoid( g:vimspector_session_windows.stack_trace )
	call win_gotoid( g:vimspector_session_windows.output ) | q
	" nnoremap <S-l> :wincmd l<CR>
	" nnoremap <S-h> :wincmd h<CR>
	" nnoremap <S-j> :wincmd j<CR>
	" nnoremap <S-k> :wincmd k<CR>
	" function! s:nomalkeymap()
	" 	unmap <S-l>
	" 	unmap  <S-h>
	" 	nmap  <S-j> <PageDown>
	" 	unmap  <S-k>
	" endfunction
	" autocmd TabLeave  * silent! call s:nomalkeymap()
	" autocmd CursorMoved * wincmd = 
endfunction

autocmd User VimspectorTerminalOpened call s:fixeverything()  
"

" "debug mapping
nnoremap <S-m> :VimspectorInstall \| execute "call vimspector\#Launch()" <CR>
nnoremap <S-c> :call vimspector#Continue()<CR>

nnoremap <S-b> :call vimspector#ToggleBreakpoint()<CR>
nnoremap <S-d> :call vimspector#ClearBreakpoints()<CR>

nmap <C-S-r> <Plug>VimspectorRestart
nmap <C-o> <Plug>VimspectorStepOut
nmap <S-i> <Plug>VimspectorStepInto
nmap <S-n> <Plug>VimspectorStepOver
nnoremap <S-e> :call vimspector#Reset( { 'interactive': v:false } )<CR>
