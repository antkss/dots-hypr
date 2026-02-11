return {

	{
		'voldikss/vim-translator',

		config = function()

		end,
	},
	{
		'echasnovski/mini.indentscope',
		-- event = "VeryLazy",
		config =  function ()
		require('mini.indentscope').setup({ options = { try_as_border = true ,delay = 400} })


	end,
	},
	{
		'echasnovski/mini.pairs',
		event = "InsertEnter",


	},
	{
	    "hrsh7th/nvim-cmp",
	    -- event = "VeryLazy",

	},

	{
		"hrsh7th/cmp-nvim-lsp",
		-- event = "VeryLazy",

	},
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp"
	},
	{
	    "hrsh7th/cmp-buffer",
	    -- event = "VeryLazy"
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},
	-- {
	--   "karb94/neoscroll.nvim",
	--   opts = {},
	-- },
	{
		"neovim/nvim-lspconfig", 
		config = function()
			vim.lsp.config('typescript-language-server', {
				 cmd = { 'typescript-language-server', "--stdio"},
				 filetypes = { 'javascript', 'typescript' },
			}) 
			vim.lsp.config('java-language-server', {
				 cmd = { 'jdtls' },
				filetypes = { 'java' },

			}) 
			vim.lsp.config('rust-analyzer', {
				cmd = { 'rust-analyzer' },
				filetypes = { 'rust' },
			})
			vim.lsp.config('vala-lang', {
				cmd = { 'vala-language-server' },
				filetypes = { 'vala' },
			})
			vim.lsp.config('gopls', {
				cmd = { 'gopls' },
				filetypes = { 'go' },
			})
			vim.lsp.enable({'luals', 'rust-analyzer', 'clangd', 'typescript-language-server', 'pyright', 'java-language-server', 'vala-lang', 'gopls'})
		end,
	}, 
	{
		"vala-lang/vala.vim"
	}

}
