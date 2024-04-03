

"vim spector configuration
let g:vimspector_sidebar_width = 70
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
	" call win_gotoid( g:vimspector_session_windows.output ) | q
	call win_gotoid( g:vimspector_session_windows.code )
	set winheight=30
	augroup insertonenter
	function! InsertOnTerminal()
		if &buftype ==# "terminal"
			normal i
		endif
	endfunction

	autocmd! BufEnter * call InsertOnTerminal()
	if has('nvim')
		autocmd! TermOpen * call InsertOnTerminal()
	endif
	augroup END
	map <LeftDrag> <nop>
	map <RightMouse> <nop>
	nnoremap <S-l> :wincmd l<CR>
	nnoremap <S-h> :wincmd h<CR>
	nnoremap <S-j> :wincmd j<CR>
	nnoremap <S-k> :wincmd k<CR>
	function! s:nomalkeymap()
		unmap <S-l>
		unmap  <S-h>
		nmap  <S-j> <PageDown>
		unmap  <S-k>
	endfunction
	autocmd TabLeave  * silent! call s:nomalkeymap()
endfunction

autocmd User VimspectorTerminalOpened call s:fixeverything()  
"

" "debug mapping
nnoremap <silent> <S-m> :VimspectorInstall \| execute "call vimspector\#Launch()" <CR>
nnoremap <silent> <S-c> :call vimspector#Continue()<CR>

nnoremap <silent> <S-b> :VimspectorInstall \| execute "call vimspector\#ToggleBreakpoint()"<CR>
nnoremap <silent> <S-d> :VimspectorInstall \| "call vimspector\#ClearBreakpoints()"<CR>

nmap <silent> <C-S-r> <Plug>VimspectorRestart <CR>
nmap <silent> <C-o> <Plug>VimspectorStepOut <CR>
nmap <silent> <S-i> <Plug>VimspectorStepInto <CR>
nmap <silent> <S-n> <Plug>VimspectorStepOver <CR>
nnoremap <silent> <S-e> :tabclose<CR>
