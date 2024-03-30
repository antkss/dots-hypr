" use <tab> to trigger completion and navigate to the next complete item
"use enter key to comfirm completion
" update mapping for coc completion
inoremap <expr> <return> coc#pum#visible() ? coc#pum#confirm() : "\<RETURN>"
inoremap <silent><expr> <S-Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<S-Tab>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
