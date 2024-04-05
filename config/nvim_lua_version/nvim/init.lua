local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`
vim.wo.number = true
require("lazy").setup("plugins",{

	change_detection = {
		notify = false,
	},
	checker = { enabled = false },
	performance = {
		rtp = {
		    -- disable some rtp plugins
		    disabled_plugins = {
			"gzip",
			-- "matchit",
			-- "matchparen",
			-- "netrwPlugin",
			"tarPlugin",
			"tohtml",
			"tutor",
			"zipPlugin",
		    },
		},
	    },
})

vim.opt.termguicolors=true
 -- local fileExtension = '.lua'
 -- local function isLuaFile(filename)
 --   return filename:sub(-#fileExtension) == fileExtension
 -- end
 --
 --
 -- local function loadAll(paths)
 --   local scan = require('plenary.scandir')
 --   for _, file in ipairs(scan.scan_dir(paths, { depth = 0 })) do
 --     if isLuaFile(file) then
 --       dofile(file) end
 --   end
 -- end
-- vim.opt.termguicolors = true
-- dofile(os.getenv('HOME') .. '/.config/nvim/lua/config/coding.lua')
dofile(os.getenv('HOME') .. '/.config/nvim/lua/config/debug.lua')
-- dofile(os.getenv('HOME') .. '/.config/nvim/lua/config/interface.lua')
dofile(os.getenv('HOME') .. '/.config/nvim/lua/config/keymap.lua')
-- dofile(os.getenv('HOME') .. '/.config/nvim/lua/config/lsp.lua')


