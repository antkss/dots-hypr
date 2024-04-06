
local Colors = {
  itagbg          = '#FFB0CE',
  darkestgreen   = '#1C1014',
  brightgreen    = '#FFB0CE',
  darkestcyan    = '#53201F',
  darkred        = '#FFD9E5',
  itext          = '#DBBFC8',
  brightred      = '#FFB3AF',
  brightorange   = '#683D45',
  gray1          = '#262626',
  cmdbg          = '#FC009A',
  gray5          = '#8C0053',
  gray10         = '#f0f0f0',
  cmdfg          = '#F2B7C0',
}
local M = {
  normal = {
    a = { fg = Colors.darkestgreen, bg = Colors.brightgreen, gui = 'bold' },
    c = { fg = Colors.brightgreen, bg = Colors.darkestgreen },
  },
  insert = {
    a = { fg = Colors.darkestcyan, bg = Colors.itagbg, gui = 'bold' },
    c = { fg = Colors.itext, bg = Colors.darkestgreen },
  },
  visual = { a = { fg = Colors.darkred, bg = Colors.brightorange, gui = 'bold' } },
  replace = { a = { fg = Colors.darkestgreen, bg = Colors.brightred, gui = 'bold' } },
  inactive = {
    a = { fg = Colors.gray1, bg = Colors.gray5, gui = 'bold' },
    b = { fg = Colors.gray1, bg = Colors.gray5 },
    c = { bg = Colors.gray1, fg = Colors.brightgreen },
  },
	command = { a = { fg = Colors.cmdfg, bg = Colors.cmdbg, gui = 'bold' } },

}

M.terminal = M.insert

return M


