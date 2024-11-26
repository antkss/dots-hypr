local Colors = {
  ibg		= '#D9B9FF',
  bbg		= '#FFF7FF',
  nbg		= '#8400F1',
  vfg		= '#EEDBFF',
  ifg		= '#2A0054',
  rbg		= '#EBB6E4',
  vbg		= '#F7D8FF',
  cmdbg         = '#8400F1',
  cmdfg         = '#EEDBFF',
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
