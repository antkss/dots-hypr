
local Colors = {
  itagbg          = '#DDB8FF',
  bbg   = '#16111B',
  brightgreen    = '#DDB8FF',
  darkestcyan    = '#492245',
  darkred        = '#F0DBFF',
  ifg          = '#CEC2D4',
  brightred      = '#EDB5E1',
  brightorange   = '#563E5C',
  gray1          = '#262626',
  cmdbg          = '#9604FF',
  gray5          = '#6800B4',
  gray10         = '#f0f0f0',
  cmdfg          = '#DCBCE1',
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


