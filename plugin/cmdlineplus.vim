if exists('g:loaded_cmdlineplus')| finish| endif| let g:loaded_cmdlineplus = 1
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
cnoremap <Plug>(cmdlineplus-CTRL_O) <C-\>ecmdlineplus#CTRL_O()<CR>
