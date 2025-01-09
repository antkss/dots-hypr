return {


	{
		'nvim-tree/nvim-web-devicons',
		keys ={
		      	{"<F5>", ":NvimTreeToggle <CR>",silent=true},
		}

	},
	{
		'nvim-tree/nvim-tree.lua' ,
		-- event = "VimEnter",
		autocmd = false,
		config = function ()
		require("nvim-tree").setup({
		  sort = {
		    sorter = "case_sensitive",
		  },
		  view = {
		    width = 30,
		  },
		  renderer = {
		    group_empty = true,
		  },
		  filters = {
		    dotfiles = true,
		  },
		})
		vim.g.webdevicons_enable = 1
		end,
		keys = {
			{ "e", "fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
		      	{"<F5>", ":NvimTreeToggle <CR>", desc = "Explorer NERDTree (cwd)", {nnoremap = true} },

		}

	}
}

