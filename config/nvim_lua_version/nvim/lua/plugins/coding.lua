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
		event = "InsertEnter",


	},
	{
		'numToStr/Comment.nvim',
		event = "VimEnter",
		config = function()	
			require('Comment').setup()
		end,
	},
	-- {'echasnovski/mini.surround'},

	{
		"neovim/nvim-lspconfig",
		lazy = true,
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		lazy = true,

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
	    event = {"BufRead","CmdlineEnter"},
	    config = function ()

		local capabilities = require('cmp_nvim_lsp').default_capabilities()

		require('mini.pairs').setup()
		-- require('mini.surround').setup()
		local cmp = require'cmp'
		local kind_icons = {
		  Text = "",
		  Method = "󰆧",
		  Function = "󰊕",
		  Constructor = "",
		  Field = "󰇽",
		  Variable = "󰂡",
		  Class = "󰠱",
		  Interface = "",
		  Module = "",
		  Property = "󰜢",
		  Unit = "",
		  Value = "󰎠",
		  Enum = "",
		  Keyword = "󰌋",
		  Snippet = "",
		  Color = "󰏘",
		  File = "󰈙",
		  Reference = "",
		  Folder = "󰉋",
		  EnumMember = "",
		  Constant = "󰏿",
		  Struct = "",
		  Event = "",
		  Operator = "󰆕",
		  TypeParameter = "󰅲",
		  Codeium = "󰫢 ",
		}
		cmp.setup({
			snippet = {
				  expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
				  end,
			 },
			completion = {
			  completeopt = 'menu,menuone,preview,noselect',
			},
			mapping = cmp.mapping.preset.insert({
			      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
			      ['<C-f>'] = cmp.mapping.scroll_docs(4),
			      ['<C-Space>'] = cmp.mapping.complete(),
			      ['<C-e>'] = cmp.mapping.abort(),
			      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				["<Tab>"] = cmp.mapping(
				function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end, { "i", "s" }),
			    }),
			 sources = cmp.config.sources(
				{
					{ name = 'codeium' },
					{ name = 'nvim_lsp' },
				      -- { name = 'codeium', trigger_characters = {'/', '.'}},
				      { name = 'vsnip' }, -- For vsnip users.
				      -- { name = 'luasnip' }, -- For luasnip users.
				      -- { name = 'ultisnips' }, -- For ultisnips users.
				      -- { name = 'snippy' }, -- For snippy users.
				},
				{
				  { name = 'buffer' },
				}
			),

			formatting = {
			    format = function(entry, vim_item)
			      -- Kind icons
			      vim_item.kind = string.format('%s', kind_icons[vim_item.kind]) -- This concatenates the icons with the name of the item kind
			      -- Source
			      vim_item.menu = ({
				buffer = "",
				nvim_lsp = "",
				codeium = "",
			      })[entry.source.name]
			      return vim_item
			    end
			  },
			  window = {
				  completion = cmp.config.window.bordered(),
				  documentation = cmp.config.window.bordered(),
			  },
		})


		require("codeium").setup({})
		require("lspconfig").clangd.setup{
			capabilities = capabilities,
				workspace = {
					maxPreload = 5,
					preloadFileSize = 10,
				},

		}
		require("lspconfig").pyright.setup {
			capabilities = capabilities,
				workspace = {
					maxPreload = 11,
					preloadFileSize = 10,
				},

		}
		require("lspconfig").lua_ls.setup {
			capabilities = capabilities,
				workspace = {
					maxPreload = 11,
					preloadFileSize = 10,
				},

		}
		vim.cmd("LspStart")
	    end,
	},
	{
		'kwkarlwang/bufresize.nvim',
		event = "VimResized",
		config = function ()
			require('bufresize').setup({trigger_events = { "VimResized" }, increment = 5})
		end
	},


}
