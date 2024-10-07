local Colors = {
  ibg		= '#FFB694',
  bbg		= '#FFF8F6',
  nbg		= '#A14000',
  vfg		= '#FFDBCC',
  ifg		= '#351000',
  rbg		= '#F1BE7A',
  vbg		= '#FFCAA2',
  cmdbg         = '#A14000',
  cmdfg         = '#FFDBCC',
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
