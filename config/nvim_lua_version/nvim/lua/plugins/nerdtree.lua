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
	-- }
	{
		'preservim/nerdtree' ,
		-- event = "VimEnter",
		autocmd = false,
		-- config = {
		-- 
		--
		-- },
		keys = {
			{ "e", "fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
		      	{"<F5>", ":NERDTreeToggle <CR>", desc = "Explorer NeoTree (cwd)", {nnoremap = true} },

		}

	}
}

