
return {

	{
		"antkss/onedark.nvim",
		event = "VeryLazy",
		config = function ()
			require("onedark").setup()
			vim.opt.clipboard = "unnamedplus"
		end
	},

	  -- {
		 --  "nvim-lualine/lualine.nvim",
		 --  event = "VeryLazy",
		 --  config = function()
			-- require("lualine").setup({options = {theme = "powerline"}})
			--
		 --  end,
			--
			--
			--
	  -- },
			--

}

