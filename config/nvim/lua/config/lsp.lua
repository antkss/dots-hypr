
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
		client.server_capabilities.semanticTokensProvider = nil
    end,
});

local capabilities = require('cmp_nvim_lsp').default_capabilities()


require('mini.pairs').setup()
local cmp = require'cmp'
local kind_icons = {
  Text = " text",
  Method = "󰆧 method",
  Function = "󰊕 function",
  Constructor = " constructor",
  Field = "󰇽 field",
  Variable = "󰂡 variable",
  Class = "󰠱 class",
  Interface = " interface",
  Module = " module",
  Property = "󰜢 property",
  Unit = " unit",
  Value = "󰎠 value",
  Enum = " enum",
  Keyword = "󰌋 keyword",
  Snippet = " snippet",
  Color = "󰏘 color",
  File = "󰈙 file",
  Reference = " reference",
  Folder = "󰉋 folder",
  EnumMember = " enum member",
  Constant = "󰏿 constant",
  Struct = " struct",
  Event = " event",
  Operator = "󰆕 operator",
  TypeParameter = "󰅲 type parameter",
  Codeium = "󰫢 ai",
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
	      -- ['<C-e>'] = cmp.mapping.abort(),
	      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<C-e>"] = cmp.mapping(
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
			{ name = 'buffer' },
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

require"lspconfig".pyright.setup {
	capabilities = capabilities,
		workspace = {
			maxPreload = 11,
			preloadFileSize = 10,
		},

}
require("lspconfig").clangd.setup{
	capabilities = capabilities,
	cmd = { "/usr/bin/clangd", "--background-index-priority=low","-j=1", "--log=verbose", "--index=false"},
	filetypes = { "c", "cpp","h","hpp" },
		workspace = {
			maxPreload = 5,
			preloadFileSize = 10,
		},

}
require('lspconfig').rust_analyzer.setup {
  handlers = {
	["textDocument/publishDiagnostics"] = vim.lsp.with(
	  vim.lsp.diagnostic.on_publish_diagnostics, {
		-- Disable virtual_text
		virtual_text = false
	  }
	),
  }
}
vim.api.nvim_create_autocmd('FileType', {
  -- This handler will fire when the buffer's 'filetype' is "python"
  pattern = 'cs',
  callback = function(ev)
	vim.lsp.start({
	  name = 'csharp',
	  cmd = {'/usr/bin/csharp-ls'},

	  -- Set the "root directory" to the parent directory of the file in the
	  -- current buffer (`ev.buf`) that contains either a "setup.py" or a
	  -- "pyproject.toml" file. Files that share a root directory will reuse
	})
  end,
})
require("lspconfig").lua_ls.setup {
	capabilities = capabilities,
	filetypes = { "lua" },
		workspace = {
			maxPreload = 11,
			preloadFileSize = 10,
		},

}
require("lspconfig").ts_ls.setup {
    capabilities = capabilities,
    workspace = {
	    maxPreload = 11,
	    preloadFileSize = 10,
    },

}


require'lspconfig'.vala_ls.setup {
  -- defaults, no need to specify these
  cmd = { "vala-language-server" },
  filetypes = { "vala", "genie" },
  single_file_support = true,
}



require("ibl").setup {
    indent = { char = "·" },
    -- whitespace = {
    --     highlight = highlight,
    --     remove_blankline_trail = false,
    -- },
    scope = { enabled = false },

}
-- vim.cmd("LspStart")
require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    '<C-u>', '<C-d>',
    '<C-b>', '<C-f>',
    '<C-y>', '<C-e>',
    'zt', 'zz', 'zb',
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 1.0,   -- Global duration multiplier
  easing = 'linear',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
  ignored_events = {           -- Events ignored while scrolling
      'WinScrolled', 'CursorMoved'
  },
})
