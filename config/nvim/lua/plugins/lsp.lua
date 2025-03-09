return {

	{
	'voldikss/vim-translator',

	config = function()

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
	-- {
	-- 	'numToStr/Comment.nvim',
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 	end,
	-- },

	{
	    "hrsh7th/nvim-cmp",
	    event = "TextChanged",

	},
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
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
	opts = { history = true, updateevents = "TextChanged,TextChangedI" },
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
		-- require("Comment").setup()
		vim.cmd("CodeiumDisable")

		end
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},
	-- { 'echasnovski/mini.animate', version = false },
	{
	  "karb94/neoscroll.nvim",
	  opts = {},
	},
	-- {
	--   "sphamba/smear-cursor.nvim",
	--   opts = {},
	-- }

}
