-- copy things
vim.api.nvim_set_keymap('n', 'q:','<nop>', {noremap = true})
-- vim.api.nvim_set_keymap('t','<C-c>','<C-\\><C-n>', {noremap = true})
vim.api.nvim_set_keymap('n','<S-j>','<nop>', {noremap = true})
vim.api.nvim_set_keymap('n','<c-j>','<C-d>', {noremap = true})
vim.api.nvim_set_keymap('n','<c-k>','<C-u>', {noremap = true})
vim.api.nvim_set_keymap('v','<S-j>','<nop>', {noremap = true})
vim.api.nvim_set_keymap('v','<c-j>','<C-d>', {noremap = true})
vim.api.nvim_set_keymap('v','<c-k>','<C-u>', {noremap = true})
vim.api.nvim_set_keymap('n','+',':join <CR>', {noremap = true})

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
--
-- vim.opt.clipboard = "unnamedplus"
-- vim.api.nvim_set_keymap('n','<LeftMouse>','<nop>', {noremap = true})
vim.api.nvim_set_keymap('v', 'y', '"+y', {noremap = true})
vim.api.nvim_set_keymap('v', 'Y', '"+yg_', {noremap = true})
vim.api.nvim_set_keymap('n', 'y', '"+y', {noremap = true})
vim.api.nvim_set_keymap('n', 'yy', '"+yy', {noremap = true})
-- paste things
vim.api.nvim_set_keymap('n', 'p', '"+p', {noremap = true})
vim.api.nvim_set_keymap('v', 'p', '"+p', {noremap = true})
-- cut things
vim.api.nvim_set_keymap('v', 'x', '"+x', {noremap = true})
-- vim.api.nvim_set_keymap('n', 'x', '"+x', {noremap = true})
vim.api.nvim_set_keymap('v', 'X', '"+X', {noremap = true})
vim.api.nvim_set_keymap('n', 'X', '"+X', {noremap = true})
--D things 
-- vim.api.nvim_set_keymap('v', 'd', '"+d', {noremap = true})
-- vim.api.nvim_set_keymap('n', 'd', '"+d', {noremap = true})
vim.api.nvim_set_keymap('v', 'D', '"+D', {noremap = true})
vim.api.nvim_set_keymap('n', 'D', '"+D', {noremap = true})
vim.keymap.set('i', '<Tab>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
vim.api.nvim_set_keymap('i','<C-c>','<Esc>', {noremap = true})
vim.api.nvim_set_keymap('n','<leader>j',':lua vim.lsp.buf.definition({ loclist = true }) <CR>',{noremap = true,expr = false})
vim.api.nvim_set_keymap('n','<leader>h',':lua vim.lsp.buf.hover() <CR>',{noremap = true,expr = false})
vim.api.nvim_set_keymap('n','<leader>rf',':lua vim.lsp.buf.references(nil, { on_list = on_list }) <CR>',{noremap = true,expr = false})
vim.api.nvim_set_keymap('n', '<leader>r', ':lua vim.lsp.buf.rename() <CR>',{noremap = true,expr = false})
vim.g.translator_target_lang = 'vi'
vim.keymap.set({"n","v"}, "t", ":Translate --engine=bing <CR>", {noremap = true})
vim.keymap.set("v", ">", ">gv", {noremap = true})
vim.keymap.set("v", "<", "<gv", {noremap = true})
-- vim.keymap.set("v", "a", "<<gv", {noremap = true})

