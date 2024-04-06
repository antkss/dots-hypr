vim.g.qf_disable_statusline = 1
local signs = {
  { name = "DiagnosticSignError", text = "✘ " },
  { name = "DiagnosticSignWarn", text = "▲" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}
for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end
local c = require('config.powerline')
vim.cmd("syntax keyword StatuslineModeSeparatorNormal StatuslineModeSeparatorNormal")
vim.cmd("syntax keyword StatuslineModeNormal StatuslineModeNormal")
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeNormal",c.normal.a.fg,c.normal.a.bg))
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeSeparatorNormal",c.normal.c.fg,"nil"))
vim.cmd("syntax keyword StatuslineModeSeparatorInsert StatuslineModeSeparatorInsert")
vim.cmd("syntax keyword StatuslineModeInsert StatuslineModeInsert")
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeInsert",c.insert.a.fg,c.insert.a.bg))
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeSeparatorInsert",c.normal.c.fg,"nil"))
vim.cmd("syntax keyword StatuslineModeSeparatorVisual StatuslineModeSeparatorVisual")
vim.cmd("syntax keyword StatuslineModeVisual StatuslineModeVisual")
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeVisual",c.visual.a.fg,c.visual.a.bg))
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeSeparatorVisual",c.visual.a.bg,"nil"))
vim.cmd("syntax keyword StatuslineModeSeparatorReplace StatuslineModeSeparatorReplace")
vim.cmd("syntax keyword StatuslineModeReplace StatuslineModeReplace")
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeReplace",c.replace.a.fg,c.replace.a.bg))
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeSeparatorReplace",c.replace.a.bg,"nil"))
vim.cmd("syntax keyword StatuslineModeSeparatorCommand StatuslineModeSeparatorCommand")
vim.cmd("syntax keyword StatuslineModeCommand StatuslineModeCommand")
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeCommand",c.normal.a.fg,c.normal.a.bg))
vim.cmd(string.format("hi %s guifg=%s guibg=%s","StatuslineModeSeparatorCommand",c.normal.a.bg,"nil"))
local warn = ""
local error = ""
local warns = 0
local errors = 0
vim.api.nvim_create_autocmd({'VimEnter','ModeChanged','CursorHold'}, {
callback = function()
	local levels = vim.diagnostic.severity
	errors = #vim.diagnostic.get(0, {severity = levels.ERROR})
					if errors > 0 then
					  error = " "
					 else
					  error = ""
					end
	warns = #vim.diagnostic.get(0, {severity = levels.WARN})
			  if warns > 0 then
			    warn = " "
			    else
			    warn = ""
			  end


end,
}
)

local mode_to_str = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
}

vim.api.nvim_create_autocmd({'ModeChanged', 'VimEnter','CursorHold'} ,{
    callback = function()
	local mode = mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'
	-- Set the highlight group.
	local hl = 'Other'
	if mode:find 'NORMAL' then
	    hl = 'Normal'
	elseif mode:find 'PENDING' then
	    hl = 'Pending'
	elseif mode:find 'VISUAL' then
	    hl = 'Visual'
	elseif mode:find 'INSERT' or mode:find 'SELECT' then
	    hl = 'Insert'
	elseif mode:find 'COMMAND' or mode:find 'TERMINAL' or mode:find 'EX' then
	    hl = 'Command'
	elseif mode:find 'REPLACE' then
		hl = 'Replace'
	end
	local string = table.concat {
		string.format('%%#StatuslineModeSeparator%s#',hl),
		string.format('%%#StatuslineMode%s# %s ',hl,mode),
		string.format('%%#StatuslineModeSeparator%s#',hl),
		string.format("%%#StatuslineModeSeparator%s#%s",mode,"%= "),
		string.format('%%#StatuslineMode%s# %s ',mode,"%f"),
	}
	if errors ~=0 then
		string = string .. string.format('%s%d',error,errors)
	end
	if warns ~=0 then
		string = string .. string.format(' %s%d ',warn,warns)
	end
	string = string .. string.format(" %s","%3l:%-2c ")
	vim.opt.statusline = string

    end
  })



