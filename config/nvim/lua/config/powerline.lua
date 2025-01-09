local Colors = {
  ibg		= '#E8B3FF',
  bbg		= '#FFF7FC',
  nbg		= '#9600D4',
  vfg		= '#F6D9FF',
  ifg		= '#310049',
  rbg		= '#F3B4DA',
  vbg		= '#FBD4F6',
  cmdbg         = '#9600D4',
  cmdfg         = '#F6D9FF',
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
