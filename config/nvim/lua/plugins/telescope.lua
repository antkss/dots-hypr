return {
	'nvim-telescope/telescope.nvim',
	autocmd = false, 
	tag = '0.1.6',
	opts = {
		pickers = {
                find_files = {
                    hidden = true,
                },
            },

	},
	keys = {
		{'ff', ":Telescope find_files <CR>",silent = true},
		{'fg', ":Telescope live_grep <CR>",silent = true},
		{'fb', ":Telescope buffers <CR>",silent = true},
		{'fh', ":Telescope help_tags <CR>",silent = true},


	}

}
