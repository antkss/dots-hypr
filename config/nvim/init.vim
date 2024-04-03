call plug#begin('~/.local/share/nvim/lazy')
	Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
	"highlight syntax
	" Plug 'bfrg/vim-cpp-modern'
	" neovim icons
	Plug 'nvim-tree/nvim-web-devicons'
	" neovim compile
	" Plug 'skywind3000/asyncrun.vim'
	" indent 
	Plug 'echasnovski/mini.indentscope'
	"COC VIM, load on insert mode only 
	Plug 'neoclide/coc.nvim', {'branch': 'release','on' : 'NonExistentCommandUltisnips'}
	" lualine for statusline
	Plug 'nvim-lualine/lualine.nvim'
	"vim translator 
	Plug 'voldikss/vim-translator'
	" Finder plugin
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }
	" debug plugin
	Plug 'puremourning/vimspector',  { 'on': 'VimspectorInstall' }
	"code assistant plugin load on insert mode only 
	Plug 'Exafunction/codeium.vim', { 'branch': 'main','on' : 'NonExistentCommandUltisnips'  }
	"theme plugin
	Plug 'navarasu/onedark.nvim'
	"auto pair load on insert mode only
	Plug 'echasnovski/mini.pairs',{ 'on' : 'NonExistentCommandUltisnips' }
	" comment plugin
	Plug 'numToStr/Comment.nvim'
	" mini surround load on insert mode only 
	Plug 'echasnovski/mini.surround',{ 'on' : 'NonExistentCommandUltisnips' }
	" vim startup time
	Plug 'dstein64/vim-startuptime'
	" keep size
	Plug 'kwkarlwang/bufresize.nvim'
call plug#end()
"load config when insert mode is on
augroup load_ultisnips
  autocmd!
  autocmd InsertEnter * silent! NonExistentCommandUltisnips | autocmd! load_ultisnips 
  autocmd InsertEnter * silent! Codeium Enable
augroup END
syntax enable
" insert load lua
autocmd InsertEnter * silent! execute "source" stdpath('config') . "/lua.vim" 
" instant load lua
execute 'source' stdpath('config') . "/ilua.vim"
" instant load config
for source_file in split(glob(stdpath('config').'/iconfig/*.vim'))
	execute 'source' source_file
endfor

" load config when insert mode is on
function! s:loadconfig()
	for source_file in split(glob(stdpath('config').'/config/*.vim'))
		execute 'source' source_file 
	endfor
endfunction
autocmd InsertEnter * call s:loadconfig()
