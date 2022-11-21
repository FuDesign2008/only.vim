if &compatible || exists(':Cfdo') == 2
    finish
endif
let s:save_cpo = &cpoptions
set cpoptions&vim


let s:cache_status = {
        \ 'eventignore': '',
        \ 'ale_fix_on_save': 0,
        \ 'ale_enabled': 0
        \}


function s:before_exec_action()
    let s:cache_status['eventignore'] = &eventignore
    let s:cache_status['ale_fix_on_save'] = get(g:, 'ale_fix_on_save', 0)
    let s:cache_status['ale_enabled'] = get(g:, 'ale_enabled', 0)

    set eventignore=all
    let g:ale_fix_on_save=0
    let g:ale_enabled=0
endfunction


function s:after_exec_action()
    execute 'set eventignore=' . get(s:cache_status, 'eventignore')
    let g:ale_fix_on_save = get(s:cache_status, 'ale_fix_on_save')
    let g:ale_enabled = get(s:cache_status, 'ale_enabled')
endfunction

function s:exec_action(command, params)
    call s:before_exec_action()

    try
        execute ': ' . a:command  . a:params
    finally
        call s:after_exec_action()
    endtry

endfunction


function s:exec_cdo(params)
    call s:exec_action('cdo', a:params)
endfunction

function s:exec_cfdo(params)
    call s:exec_action('cfdo', a:params)
endfunction

function s:exec_ldo(params)
    call s:exec_action('ldo', a:params)
endfunction

function s:exec_lfdo(params)
    call s:exec_action('lfdo', a:params)
endfunction

function s:exec_bufdo(params)
    call s:exec_action('bufdo', a:params)
endfunction

function s:exec_tabdo(params)
    call s:exec_action('tabdo', a:params)
endfunction

function s:exec_argdo(params)
    call s:exec_action('argdo', a:params)
endfunction

function s:exec_windo(params)
    call s:exec_action('windo', a:params)
endfunction



command! -nargs=+ Cfdo call s:exec_cfdo(<q-args>)
command! -nargs=+ Cdo call s:exec_cdo(<q-args>)
command! -nargs=+ Ldo call s:exec_ldo(<q-args>)
command! -nargs=+ Lfdo call s:exec_lfdo(<q-args>)
command! -nargs=+ Bufdo call s:exec_bufdo(<q-args>)
command! -nargs=+ Tabdo call s:exec_tabdo(<q-args>)
command! -nargs=+ Argdo call s:exec_argdo(<q-args>)
command! -nargs=+ Windo call s:exec_windo(<q-args>)


let &cpoptions = s:save_cpo


