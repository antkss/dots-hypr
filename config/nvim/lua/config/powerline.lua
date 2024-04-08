
local Colors = {
  itagbg          = '#CEBDFF',
  bbg   = '#14121C',
  brightgreen    = '#CEBDFF',
  darkestcyan    = '#46234A',
  darkred        = '#E8DDFF',
  ifg          = '#CAC3D5',
  brightred      = '#E7B7E8',
  brightorange   = '#544262',
  gray1          = '#262626',
  cmdbg          = '#6602FF',
  gray5          = '#5100CF',
  gray10         = '#f0f0f0',
  cmdfg          = '#D6BEE5',
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


