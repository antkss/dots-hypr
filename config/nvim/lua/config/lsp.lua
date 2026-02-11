
require('mini.pairs').setup()
require("ibl").setup {
    indent = { char = "·" },
    -- whitespace = {
    --     highlight = highlight,
    --     remove_blankline_trail = false,
    -- },
    scope = { enabled = false },

}
-- require('neoscroll').setup({
--   mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
--     '<C-u>', '<C-d>',
--     '<C-b>', '<C-f>',
--     '<C-y>', '<C-e>',
--     'zt', 'zz', 'zb',
--   },
--   hide_cursor = true,          -- Hide cursor while scrolling
--   stop_eof = true,             -- Stop at <EOF> when scrolling downwards
--   respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
--   cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
--   duration_multiplier = 1.0,   -- Global duration multiplier
--   easing = 'linear',           -- Default easing function
--   pre_hook = nil,              -- Function to run before the scrolling animation starts
--   post_hook = nil,             -- Function to run after the scrolling animation ends
--   performance_mode = false,    -- Disable "Performance Mode" on all buffers.
--   ignored_events = {           -- Events ignored while scrolling
--       'WinScrolled', 'CursorMoved'
--   },
-- })

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
local luasnip = require("luasnip")
cmp.setup({
	mapping = cmp.mapping.preset.insert({
	      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
	      ['<C-f>'] = cmp.mapping.scroll_docs(4),
	      ['<C-Space>'] = cmp.mapping.complete(),
	      -- ['<C-e>'] = cmp.mapping.abort(),
		["<C-e>"] = cmp.mapping(
		function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		   ['<CR>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					if luasnip.expandable() then
						luasnip.expand()
					else
						cmp.confirm({
							select = true,
						})
					end
				else
					fallback()
				end
			end),

			["<Tab>"] = cmp.mapping(function(fallback)
			  if cmp.visible() then
				cmp.select_next_item()
			  elseif luasnip.locally_jumpable(1) then
				luasnip.jump(1)
			  else
				fallback()
			  end
			end, { "i", "s" }),

			["<S-Tab>"] = cmp.mapping(function(fallback)
			  if cmp.visible() then
				cmp.select_prev_item()
			  elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			  else
				fallback()
			  end
			end, { "i", "s" }),

	    }),
	 sources = cmp.config.sources(
		{
			{ name = 'luasnip', option = { show_autosnippets = true } },
			{ name = 'nvim_lsp' },
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
		-- codeium = "",
	      })[entry.source.name]
	      return vim_item
	    end
	  },
	  window = {
		  completion = cmp.config.window.bordered(),
		  documentation = cmp.config.window.bordered(),
	  },
})

