"
" openUrl.vim
"
" available for windows, mac, unix/linux
"
" 1. Open the url under the cursor: <leader>u
" 2. Open the github bundle under the cursor: <leader>b
"
"



if &compatible || exists(':Only')
    finish
endif
let s:save_cpo = &cpoptions
set cpoptions&vim


function s:Only()
    execute 'silent tabonly | silent only'
endfunction



command -nargs=0 Only call s:Only()

let &cpoptions = s:save_cpo
