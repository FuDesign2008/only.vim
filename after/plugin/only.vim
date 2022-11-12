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


" @params {0|1} isOnly
" @params {number|string} columns
function s:LayoutWindows(isOnly, columns)
    if a:isOnly
        execute 'silent tabonly | silent only'
    else
        execute 'silent only'
    endif

    let l:columnTotal = str2nr(a:columns)

    if l:columnTotal < 2
        return
    endif

    let l:count = 0
    while l:count < l:columnTotal
        execute 'vsplit'
        let l:count = l:count + 1
    endwhile

    execute 'wincmd ='

endfunction


function s:Only()
    if len(a:000) == 0
        call s:LayoutWindows(1, 1)
    else
        call s:LayoutWindows(1, a:1)
    endif
endfunction

function s:Layout()
    if len(a:000) == 0
        call s:LayoutWindows(0, 1)
    else
        call s:LayoutWindows(0, a:1)
    endif
endfunction





command -nargs=? Only call s:Only()
command -nargs=? Layout call s:Layout()

let &cpoptions = s:save_cpo
