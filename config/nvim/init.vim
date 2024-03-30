"NERDTree plugin 
call plug#begin('~/.local/share/nvim/lazy')
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
" indent 
Plug 'echasnovski/mini.indentscope'
"COC VIM
"Plug 'nvim-tree/nvim-web-devicons'
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
"chatgpt plugin 
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
"theme plugin
Plug 'navarasu/onedark.nvim'
"auto pair
Plug 'echasnovski/mini.pairs'
" comment plugin
Plug 'numToStr/Comment.nvim'
" mini surround
Plug 'echasnovski/mini.surround'
call plug#end()
colorscheme onedark  
" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`. call plug#end()
syntax enable
" set autoread

source ~/.config/nvim/lua.vim
source ~/.config/nvim/config.vim
source ~/.config/nvim/mapping.vim
