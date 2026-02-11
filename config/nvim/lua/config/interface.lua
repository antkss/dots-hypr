-- vim.g.qf_disable_statusline = 1
-- vim.o.showtabline = 2
vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '●', '▎', 'x'
  }
})
local signs = {
  { name = "DiagnosticSignError", text = "󰅚" },
  { name = "DiagnosticSignWarn", text = "!" },
  { name = "DiagnosticSignHint", text = "󰌶" },
  { name = "DiagnosticSignInfo", text = "" },
}
-- for _, sign in ipairs(signs) do
--   vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
-- end -- deprecated
local c = require('config.powerline')
vim.api.nvim_set_hl(0, "StatuslineModeNormal", { fg = c.normal.a.fg, bg = c.normal.a.bg })
vim.api.nvim_set_hl(0, "StatuslineModeSeparatorNormal", { fg = c.normal.c.fg, bg = c.normal.c.bg })
vim.api.nvim_set_hl(0, "NobgNormal", { fg = c.normal.c.fg, bg = c.normal.c.bg })
-- insert group
vim.api.nvim_set_hl(0, "StatuslineModeInsert", { fg = c.insert.a.fg, bg = c.insert.a.bg })
vim.api.nvim_set_hl(0, "StatuslineModeSeparatorInsert", { fg = c.insert.a.bg, bg = c.insert.a.fg })
vim.api.nvim_set_hl(0, "NobgInsert", { fg = c.insert.a.bg, bg = c.insert.a.fg })

-- visual group
vim.api.nvim_set_hl(0, "StatuslineModeVisual", { fg = c.visual.a.fg, bg = c.visual.a.bg })
vim.api.nvim_set_hl(0, "StatuslineModeSeparatorVisual", { fg = c.visual.a.bg, bg = c.visual.a.fg })
vim.api.nvim_set_hl(0, "NobgVisual", { fg = c.visual.a.bg, bg = c.visual.a.fg })

-- replace group
vim.api.nvim_set_hl(0, "StatuslineModeReplace", { fg = c.replace.a.fg, bg = c.replace.a.bg })
vim.api.nvim_set_hl(0, "StatuslineModeSeparatorReplace", { fg = c.replace.a.bg, bg = c.replace.a.fg })
vim.api.nvim_set_hl(0, "NobgReplace", { fg = c.replace.a.bg, bg = c.replace.a.fg })

-- command group
vim.api.nvim_set_hl(0, "StatuslineModeCommand", { fg = c.command.a.fg, bg = c.command.a.bg })
vim.api.nvim_set_hl(0, "StatuslineModeSeparatorCommand", { fg = c.command.a.bg, bg = c.command.a.fg })
vim.api.nvim_set_hl(0, "NobgCommand", { fg = c.command.a.bg, bg = c.command.a.fg })

local warn = ""
local error = ""
local warns = 0
local errors = 0
vim.api.nvim_create_autocmd({'VimEnter','ModeChanged','CursorHold'}, {
callback = function()
	local levels = vim.diagnostic.severity
	errors = #vim.diagnostic.get(0, {severity = levels.ERROR})
					if errors > 0 then
					  error = "󰅚"
					 else
					  error = ""
					end
	warns = #vim.diagnostic.get(0, {severity = levels.WARN})
			  if warns > 0 then
			    warn = "󰀪"
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
	    hl = 'Replace'
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
		string.format('%%#StatuslineMode%s# %s ',hl,mode),
		string.format('%%#StatuslineModeSeparator%s#',hl),
		-- string.format('%%#StatuslineModeSeparator%s#',hl),
		string.format('%s'," "),
		'%=',
		string.format('%%#Nobg%s#',hl),
		string.format("%%#StatuslineModeSeparator%s#%s",hl," "),
		string.format('%%#StatuslineMode%s# %s ',hl,"%.40t"),
		string.format('%s',""),
	}
	if errors ~=0 then
		string = string .. string.format('%s %d',error,errors)
	end
	if warns ~=0 then
		string = string .. string.format(' %s %d',warn,warns)
	end
	string = string .. string.format(" %s","%3l:%-2c")
	vim.opt.statusline = string

    end
  })

-- vim.go.tabline="%#StatuslineModeSeparatorNormal#%#StatuslineModeNormal# %f %#StatuslineModeSeparatorNormal#"
