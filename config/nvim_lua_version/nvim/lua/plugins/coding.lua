return {

	{
	'voldikss/vim-translator',
	autocmd = false,
	keys = {
		{ 't', ':Translate --engine=bing <CR>' },
		-- { 't', ':\'<,\'>Translate --engine=bing<CR>', mode = visual}
	},
	config = function()
	vim.g.translator_target_lang = 'vi'
	end,
	},
	{
		'echasnovski/mini.indentscope',
		event = "VimEnter",
		config =  function ()
		require('mini.indentscope').setup({ options = { try_as_border = true ,delay = 400} })


	end,
	},
	{
		'echasnovski/mini.pairs',
		event = "InsertEnter"


	},
	{
		'numToStr/Comment.nvim',
		event =  "BufEnter",
		config = function()
			require('Comment').setup()
		end,
	},
	-- {'echasnovski/mini.surround'},
	{
		'ryanoasis/vim-devicons',

	},
	{
		"neovim/nvim-lspconfig",
		event = "InsertEnter"
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		event = "InsertEnter"
	},
	{
		'hrsh7th/vim-vsnip',
		event = "InsertEnter"
	},
	{
	    "Exafunction/codeium.nvim",
	    dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	    },
	    event = "InsertEnter",
	    config = function ()

		local capabilities = require('cmp_nvim_lsp').default_capabilities()

		require('mini.pairs').setup()
		-- require('mini.surround').setup()
		local cmp = require'cmp'
		cmp.setup({
		snippet = {
			  expand = function(args)
				vim.fn["vsnip#anonymous"](args.body)
			  end,
		  },
		-- completion = {
		--   completeopt = 'menu,menuone,preview,noselect',
		--   
		-- },

		 mapping = {
		    ["<Tab>"] = cmp.mapping(function()
		      if cmp.visible() then
			cmp.select_next_item()
		      end
		    end, { "i", "s" }),
		["<CR>"] = cmp.mapping.confirm({ select = true }),

		  },
		 	sources = cmp.config.sources({
			{ name = "codeium" },
		      { name = 'nvim_lsp' },
		    }),
		  })
		require("lspconfig").clangd.setup{
			capabilities = capabilities

		}
		require("lspconfig").pyright.setup {
			capabilities = capabilities
		}
		require("codeium").setup({})
		vim.cmd("LspStart")
	    end
	
	},
	{
		'kwkarlwang/bufresize.nvim',
		event = "VimResized",
		config = function ()
			require('bufresize').setup({trigger_events = { "VimResized" }, increment = 5})
		end
	},


}
