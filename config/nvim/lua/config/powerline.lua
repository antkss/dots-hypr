
local Colors = {
  itagbg          = '#CDBDFF',
  darkestgreen   = '#14121C',
  brightgreen    = '#CDBDFF',
  darkestcyan    = '#45234B',
  darkred        = '#E7DEFF',
  itext          = '#CAC4D5',
  brightred      = '#E6B7E8',
  brightorange   = '#544262',
  gray1          = '#262626',
  cmdbg          = '#6309FF',
  gray5          = '#4F00D1',
  gray10         = '#f0f0f0',
  cmdfg          = '#D5BEE5',
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


