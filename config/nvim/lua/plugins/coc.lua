return {

	{
	'voldikss/vim-translator',
	autocmd = false,
	keys = {
		{ 't', ':Translate --engine=bing <CR>' ,silent = true},
		-- { 't', ':\'<,\'>Translate --engine=bing<CR>', mode = visual}
	},
	config = function()
	vim.g.translator_target_lang = 'vi'
	end,
	},
	{
		'echasnovski/mini.indentscope',
		event = "VeryLazy",
		config =  function ()
		require('mini.indentscope').setup({ options = { try_as_border = true ,delay = 400} })


	end,
	},
	{
		'echasnovski/mini.pairs',
		event = "InsertEnter",


	},
	{
		'numToStr/Comment.nvim',
		event = "VeryLazy",
		config = function()
		end,
	},
	{
		'neoclide/coc.nvim',
		branch =  "release",
		event = "VeryLazy",
		build = "npm install --prefix ~/.local/share/nvim/lazy/coc.nvim",
		config = function()
				local opts = {silent = true, noremap = true, expr = true, replace_keycodes = true}
				require('mini.pairs').setup()
				require("Comment").setup()
				vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

				vim.keymap.set("i", "<c-e>",
				    function()
					if vim.fn['coc#pum#visible']() == 1 then
					    return vim.fn['coc#pum#next'](1)
					else
					    return vim.fn['coc#refresh']()
					end
				    end
				    , opts)
			end,

	},
	{
		"Exafunction/codeium.vim",
		event = "VeryLazy",
		config = function ()
		vim.cmd("CodeiumEnable")
		local opts = {silent = true, noremap = true, expr = true, replace_keycodes = true}
		end
	}


}
