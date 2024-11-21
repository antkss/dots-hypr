return {

	{
	'voldikss/vim-translator',

	config = function()

	end,
	},
	{
	    "lukas-reineke/indent-blankline.nvim",
	    event = "VeryLazy",
	    config = function()
		-- local highlight = {
		--     "CursorColumn",
		--     "Whitespace",
		-- }
		require("ibl").setup {
		    indent = {  char = "." },
		    whitespace = {
			-- highlight = highlight,
			remove_blankline_trail = true,
		    },
		    scope = { enabled = false },
		}
	    end,
	},
	{
		'echasnovski/mini.indentscope',
		event = "VeryLazy",
		config =  function ()
		require('mini.indentscope').setup({ options = { try_as_border = true ,delay = 400} })


	end,
	},
	{
		'echasnovski/mini.pairs',
		event = "InsertEnter",


	},
	{
		'numToStr/Comment.nvim',
		event = "VeryLazy",
		config = function()
		end,
	},

	{
	    "hrsh7th/nvim-cmp",
	    event = "TextChanged",
	    dependencies = {
		"neovim/nvim-lspconfig",
	    },


	},

	{
		"hrsh7th/cmp-nvim-lsp",
		event = "VeryLazy",

	},
	{
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp",
	-- event = "VeryLazy",
	},
	{
	    "hrsh7th/cmp-buffer",
	    -- event = "VeryLazy"
	},
	{
		"antkss/codeium",
		event = "VeryLazy",
		config = function ()
		require('mini.pairs').setup()
		require("Comment").setup()
		vim.cmd("CodeiumDisable")

		end
	},





}
