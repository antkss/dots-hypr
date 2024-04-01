lua require('mini.pairs').setup()
lua require('mini.surround').setup()
lua require('mini.indentscope').setup({symbol = "│",options = { try_as_border = true }})



###### config load after enter insert mode ####################
inoremap <expr> <enter> coc#pum#visible() ? coc#pum#confirm() : "\<enter>"
inoremap <silent><expr> <s-Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<s-Tab>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
