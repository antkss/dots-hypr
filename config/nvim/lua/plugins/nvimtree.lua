return {
	--
	-- {'MunifTanjim/nui.nvim'},
	--   {
	--     "nvim-neo-tree/neo-tree.nvim",
	--     autocmd = false,
	--     branch = "v3.x",
	--     cmd = "Neotree",
	--     keys = {
	--       {
	-- 	"fe",
	-- 	function()
	-- 	  require("neo-tree.command").execute({ toggle = true})
	-- 	end,
	-- 	desc = "Explorer NeoTree (Root Dir)",
	--       },
	--       {
	-- 	"fE",
	-- 	function()
	-- 	  require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
	-- 	end,
	-- 	desc = "Explorer NeoTree (cwd)",
	--       },
	--       { "e", "fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
	--       { "<F5>", "fE", desc = "Explorer NeoTree (cwd)", remap = true },
	--
	-- 	}
	--
	-- }

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

