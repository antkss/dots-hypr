-- local dap = require('mason-nvim-dap')
vim.opt.makeprg = 'g++ -g -o %< % -fno-stack-protector'
-- always go to insert mode when go to terminal powered by gemini
vim.api.nvim_create_augroup('insertonenter', {})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    if vim.api.nvim_buf_get_option(0, 'buftype') == 'terminal' then
      vim.api.nvim_command('normal i')
    end
  end
})

if vim.fn.has('nvim') == 1 then
  vim.api.nvim_create_autocmd('TermOpen', {
    pattern = '*',
    callback = function()
      if vim.api.nvim_buf_get_option(0, 'buftype') == 'terminal' then
        vim.api.nvim_command('normal i')
      end
    end
  })
end

vim.api.nvim_clear_autocmds({ group = 'insertonenter' })
-- set mouse
-- vim.opt.mouse = 'n'
vim.opt.swapfile = false
-- yeah, just temporary 
-- require("colorizer").setup()
function alias(from, to)
  vim.cmd(string.format([[
    cnoreabbrev <expr> %s ((getcmdtype() == ":" && getcmdline() == "%s") ? "%s" : "%s")
  ]], from, from, to, from))
end
alias("rp","term python % DEBUG")
vim.cmd("set commentstring=#\\ %s")
