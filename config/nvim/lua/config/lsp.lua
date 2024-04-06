		local cmp = require'cmp'
		cmp.setup({
		    snippet = {
		      -- REQUIRED - you must specify a snippet engine
		      expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
			-- require("cmp_nvim_ultisnips").setup{}
			-- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
		      end,
		    },
		    -- window = {
		      -- completion = cmp.config.window.bordered(),
		      -- documentation = cmp.config.window.bordered(),
		    -- },

		 mapping = {

		    -- ... Your other mappings ...

		    -- ["<Tab>"] = cmp.mapping(function(fallback)
		 --      if cmp.visible() then
			-- 	cmp.select_next_item()
			--       elseif vim.fn["vsnip#available"](1) == 1 then
			-- 	feedkey("<Plug>(vsnip-expand-or-jump)", "")
			--       -- elseif has_words_before() then
			-- 	-- cmp.complete()
			--       else
			-- fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
		 --      end
		    -- end, { "i", "s" }),

		    ["<Tab>"] = cmp.mapping(function()
		      if cmp.visible() then
			cmp.select_next_item()
		 --      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
			-- feedkey("<Plug>(vsnip-jump-prev)", "")
		      end
		    end, { "i", "s" }),
			-- ["<Tab>"] = cmp.mapping.confirm({ select = true }),

		    -- ... Your other mappings ...

		  },
		 	sources = cmp.config.sources({
			{ name = "codeium" },
		      -- { name = 'nvim_lsp' },
		    }),
		  })

		  -- Set configuration for specific filetype.
		-- Set up lspconfig.
		-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
		-- require('lspconfig')['clangd'].setup {
		--   capabilities = capabilities
		--   }
		-- require('lspconfig')['lua_ls'].setup {
		--   capabilities = capabilities
		-- }
		-- require('lspconfig')['pyright'].setup {
		-- 	capabilities = capabilities
		--
		--
		-- }
-- end,
-- sign configurations
-- local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
-- for type, icon in pairs(signs) do
--   local hl = "DiagnosticSign" .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
-- vim.diagnostic.config({
--   virtual_text = {
--     prefix = '●', -- Could be '●', '▎', 'x'
--   }
-- })

