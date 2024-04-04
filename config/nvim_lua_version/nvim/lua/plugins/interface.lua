
return {

	{
		"navarasu/onedark.nvim",
	},

	  {
		  "nvim-lualine/lualine.nvim",
		  config = function()
			  require("lualine").setup({options = {theme = "powerline"}})
		vim.opt.clipboard = "unnamedplus"
		  end,



	  },


}

