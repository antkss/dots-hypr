inoremap <expr> <enter> coc#pum#visible() ? coc#pum#confirm() : "\<enter>"
inoremap <silent><expr> <s-Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<s-Tab>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
