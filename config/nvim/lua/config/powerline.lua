
local Colors = {
  itagbg          = '#87CEFF',
  darkestgreen   = '#0C141B',
  brightgreen    = '#87CEFF',
  darkestcyan    = '#212E5A',
  mediumcyan     = '#004C6D',
  darkred        = '#C8E6FF',
  itext          = '#BCC8D3',
  brightred      = '#B8C4FA',
  brightorange   = '#364A66',
  gray1          = '#262626',
  gray4          = '#585858',
  gray5          = '#004C6D',
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


