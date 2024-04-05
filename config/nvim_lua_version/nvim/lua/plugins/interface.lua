
return {

	{
		"antkss/onedark.nvim",
		config = function ()
			require("onedark").setup()
			
		end
	},

	  {
		  "nvim-lualine/lualine.nvim",
		  config = function()
			  require("lualine").setup({options = {theme = "powerline"}})
		vim.opt.clipboard = "unnamedplus"
		  end,



	  },


}

