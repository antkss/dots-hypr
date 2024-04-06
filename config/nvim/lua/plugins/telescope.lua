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
		{'ff', ":Telescope find_files <CR>"},
		{'fg', ":Telescope live_grep <CR>"},
		{'fb', ":Telescope buffers <CR>"},
		{'fh', ":Telescope help_tags <CR>"},


	}

}
