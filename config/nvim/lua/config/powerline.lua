
local Colors = {
  itagbg          = '#FFB1C2',
  darkestgreen   = '#1D1013',
  brightgreen    = '#FFB1C2',
  darkestcyan    = '#52220E',
  mediumcyan     = '#8F0040',
  darkred        = '#FFD9E0',
  itext          = '#DDBFC4',
  brightred      = '#FFB599',
  brightorange   = '#693D3A',
  gray1          = '#262626',
  gray4          = '#585858',
  gray5          = '#8F0040',
  gray10         = '#f0f0f0',
}

local M = {
  normal = {
    a = { fg = Colors.darkestgreen, bg = Colors.brightgreen, gui = 'bold' },
    b = { fg = Colors.gray10, bg = Colors.gray5 },
    c = { fg = Colors.brightgreen, bg = Colors.darkestgreen },
  },
  insert = {
    a = { fg = Colors.darkestcyan, bg = Colors.itagbg, gui = 'bold' },
    b = { fg = Colors.itext, bg = Colors.mediumcyan },
    c = { fg = Colors.itext, bg = Colors.darkestgreen },
  },
  visual = { a = { fg = Colors.darkred, bg = Colors.brightorange, gui = 'bold' } },
  replace = { a = { fg = Colors.darkestgreen, bg = Colors.brightred, gui = 'bold' } },
  inactive = {
    a = { fg = Colors.gray1, bg = Colors.gray5, gui = 'bold' },
    b = { fg = Colors.gray1, bg = Colors.gray5 },
    c = { bg = Colors.gray1, fg = Colors.brightgreen },
  },
}

M.terminal = M.insert

return M


