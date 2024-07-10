" instant load
lua require('Comment').setup()
" lua require('lualine').setup({ options = { theme = 'horizon' }})
lua require('mini.indentscope').setup({symbol = "│",options = { try_as_border = true }})
lua require('bufresize').setup({trigger_events = { "VimResized" }, increment = 5})
lua require("interface")

