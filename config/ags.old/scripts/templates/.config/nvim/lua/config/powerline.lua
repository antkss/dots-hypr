local Colors = {
  ibg		= '#{{ $primaryFixedDim }}',
  bbg		= '#{{ $background }}',
  nbg		= '#{{ $surfaceTint }}',
  vfg		= '#{{ $primaryFixed }}',
  ifg		= '#{{ $onPrimaryFixed }}',
  rbg		= '#{{ $tertiaryFixedDim }}',
  vbg		= '#{{ $secondaryContainer }}',
  cmdbg         = '#{{ $primary }}',
  cmdfg         = '#{{ $primaryContainer }}',
}
local M = {
  normal = {
    a = { fg = Colors.bbg, bg = Colors.nbg, gui = 'bold' },
    c = { fg = Colors.nbg, bg = Colors.bbg },
  },
  insert = {
    a = { fg = Colors.ifg, bg = Colors.ibg, gui = 'bold' },
    c = { fg = Colors.ifg, bg = Colors.bbg },
  },
  visual = { a = { fg = Colors.nbg, bg = Colors.vbg, gui = 'bold' } },
  replace = { a = { fg = Colors.bbg, bg = Colors.rbg, gui = 'bold' } },
  -- inactive = {
  --   a = { fg = Colors.gray1, bg = Colors.gray5, gui = 'bold' },
  --   b = { fg = Colors.gray1, bg = Colors.gray5 },
  --   c = { bg = Colors.gray1, fg = Colors.nbg },
  -- },
	command = { a = { fg = Colors.cmdfg, bg = Colors.cmdbg, gui = 'bold' } },

}

return M
