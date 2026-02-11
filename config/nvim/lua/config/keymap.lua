-- copy things
local map = vim.keymap.set
map('n', 'q:','<nop>', { noremap = true })
map('n','<c-j>','<nop>', { noremap = true })

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
--
-- vim.opt.clipboard = "unnamedplus"
map('v', 'y', '"+y', { noremap = true })
map('v', 'Y', '"+yg_', { noremap = true })
map('n', 'y', '"+y', { noremap = true })
map('n', 'yy', '"+yy', { noremap = true })
-- paste things
map('n', 'p', '"+p', { noremap = true })
map('v', 'p', '"+p', { noremap = true })
-- cut things
map('v', 'x', '"+x', { noremap = true })
map('v', 'X', '"+X', { noremap = true })
map('n', 'X', '"+X', { noremap = true })
--D things 
map('v', 'D', '"+D', { noremap = true })
map('n', 'D', '"+D', { noremap = true })
-- map('i', '<Tab>', function () return vim.fn['codeium#Accept']() end, { noremap = true } )
map('i','<C-c>','<Esc>', { noremap = true })
map('n','<leader>j', vim.lsp.buf.definition ,{ noremap = true })
map('n','<leader>h',vim.lsp.buf.hover,{ noremap = true })
map('n','<leader>rf',vim.lsp.buf.references,{ noremap = true })
map('n', '<leader>r', vim.lsp.buf.rename ,{ noremap = true })
map('n', '<leader>p', ":bprevious <CR>" ,{ noremap = true })
map('n', '<leader>n', ":bnext <CR>" ,{ noremap = true })
vim.g.translator_target_lang = 'vi'
map({"v"}, "tt", ":Translate --engine=bing <CR>", { noremap = true })
map("v", ">", ">gv", { noremap = true })
map("v", "<", "<gv", { noremap = true })
-- map("v", "a", "<<gv", { noremap = true })

