
local Colors = {
  itagbg          = '#C0C1FF',
  bbg   = '#12131C',
  brightgreen    = '#C0C1FF',
  darkestcyan    = '#3F2551',
  darkred        = '#E1E0FF',
  ifg          = '#C6C5D6',
  brightred      = '#DCBAF0',
  brightorange   = '#4D4465',
  gray1          = '#262626',
  cmdbg          = '#1A05FF',
  gray5          = '#1600EC',
  gray10         = '#f0f0f0',
  cmdfg          = '#CDC0E9',
}
local M = {
  normal = {
    a = { fg = Colors.bbg, bg = Colors.brightgreen, gui = 'bold' },
    c = { fg = Colors.brightgreen, bg = Colors.bbg },
  },
  insert = {
    a = { fg = Colors.darkestcyan, bg = Colors.itagbg, gui = 'bold' },
    c = { fg = Colors.ifg, bg = Colors.bbg },
  },
  visual = { a = { fg = Colors.darkred, bg = Colors.brightorange, gui = 'bold' } },
  replace = { a = { fg = Colors.bbg, bg = Colors.brightred, gui = 'bold' } },
  inactive = {
    a = { fg = Colors.gray1, bg = Colors.gray5, gui = 'bold' },
    b = { fg = Colors.gray1, bg = Colors.gray5 },
    c = { bg = Colors.gray1, fg = Colors.brightgreen },
  },
	command = { a = { fg = Colors.bbg, bg = Colors.cmdbg, gui = 'bold' } },

}

M.terminal = M.insert

return M


