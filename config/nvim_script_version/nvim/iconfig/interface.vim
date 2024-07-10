" lualine configurations for interface
" colorscheme configurations
autocmd VimEnter * silent! syntax keyword datatype
			\ bool char short int long long long float double long double void* T* T& T[] T() void struct class enum typedef
autocmd VimEnter * silent! syntax keyword ccpp_function
			\ printf scanf gets puts fgets fputs getchar putchar fopen fclose fread fwrite fseek ftell rewind remove rename system exit malloc free realloc calloc qsort bsearch memcpy memset memcmp strlen strcpy strcat strcmp strncmp strchr strstr strtol strtoul strtod strtof strtod atof atoi atol main
autocmd VimEnter * silent! syntax keyword ccpp_condition
			\ if else switch case default  
autocmd VimEnter * silent! syntax keyword ccpp_loop
			\ for while do while 
autocmd VimEnter * silent! syntax keyword cpp_keywords
			\ using return endl 
autocmd VimEnter * silent! syntax keyword cpp_inout
			\ cin cout cerr 


autocmd VimEnter * silent! hi Normal guifg=white
autocmd VimEnter * silent! hi Number guifg=#eaff00
autocmd VimEnter * silent! hi datatype guifg=orange
autocmd VimEnter * silent! hi ccpp_function guifg=lightpink
autocmd VimEnter * silent! hi ccpp_condition guifg=#72df4a
autocmd VimEnter * silent! hi ccpp_loop guifg=#00faed
autocmd VimEnter * silent! hi cpp_keywords guifg=#00ff91
autocmd VimEnter * silent! hi cpp_inout guifg=#ff006a


" colorscheme onedark
lua require("onedark").setup()
