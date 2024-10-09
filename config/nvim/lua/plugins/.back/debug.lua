return {

	{
		'puremourning/vimspector',
		autocmd = false,
		keys = {
		{ "<S-m>", "<Plug>VimspectorRestart <CR>" },
		{ "<S-c>", "<Plug>VimspectorContinue<CR>"},
		{ "<S-b>", "<Plug>VimspectorToggleBreakpoint<CR>"},
		{ "<C-S-r>", "<Plug>VimspectorRestart <CR>"},
		-- { "<C-o>", "<Plug>VimspectorStepOut <CR>"},
		{ "<S-i>", "<Plug>VimspectorStepInto <CR>"},
		{ "<S-n>", "<Plug>VimspectorStepOver <CR>"},
		{ "<S-e>", ":tabclose<CR>"}
		},
	},


}
