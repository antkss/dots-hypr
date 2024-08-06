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
			-- vim.fn["vsnip#anonymous"](args.body)
			require'luasnip'.lsp_expand(args.body)
		  end,
	 },
	-- completion = {
	--   completeopt = 'menu,menuone,preview,noselect',
	-- },
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
			{ name = 'luasnip', option = { show_autosnippets = true } },
			-- {name = 'vsnip', option = { show_autosnippets = true }},
			{ name = 'nvim_lsp' },
			-- { name = 'codeium' },
			-- { name = 'ultisnips' }, -- For ultisnips users.
			-- { name = 'snippy' }, -- For snippy users.
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


require("lspconfig").clangd.setup{
	capabilities = capabilities,
		workspace = {
			maxPreload = 5,
			preloadFileSize = 10,
		},

}
require("lspconfig")["pyright"].setup {
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
require("lspconfig").tsserver.setup {
	capabilities = capabilities,
		workspace = {
			maxPreload = 11,
			preloadFileSize = 10,
		},

}
vim.cmd("LspStart")

