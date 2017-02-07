" vim: ts=4 sw=4 et

function! neomake#makers#ft#php#EnabledMakers() abort
    return ['php', 'phpmd', 'phpcs', 'phpstan']
endfunction

function! neomake#makers#ft#php#php() abort
    return {
        \ 'args': ['-l', '-d', 'display_errors=1', '-d', 'log_errors=0',
            \      '-d', 'xdebug.cli_color=0'],
        \ 'errorformat':
            \ '%-GNo syntax errors detected in%.%#,'.
            \ '%EParse error: %#syntax error\, %m in %f on line %l,'.
            \ '%EParse error: %m in %f on line %l,'.
            \ '%EFatal error: %m in %f on line %l,'.
            \ '%-G\s%#,'.
            \ '%-GErrors parsing %.%#',
        \ }
endfunction

function! neomake#makers#ft#php#phpcs() abort
    let l:args = ['--report=csv']

    if exists('g:neomake_php_phpcs_args_post')
        call add(l:args, , g:neomake_php_phpmd_args_post))
    endif

    return {
        \ 'args': args,
        \ 'errorformat':
            \ '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity%.%#,'.
            \ '"%f"\,%l\,%c\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]%.%#',
        \ }
endfunction

function! neomake#makers#ft#php#phpmd() abort
    let l:args = ['%:p', 'text']

    if exists('g:neomake_php_phpmd_args_post')
        call add(l:args, g:neomake_php_phpmd_args_post)
    else
        call add(l:args, 'codesize,design,unusedcode,naming')
    endif

    return {
        \ 'args': ['%:p', 'text', 'codesize,design,unusedcode,naming'],
        \ 'errorformat': '%W%f:%l%\s%\s%#%m'
        \ }
endfunction

function! neomake#makers#ft#php#phpstan() abort
    return {
        \ 'args': ['analyse', '--errorFormat', 'raw'],
        \ 'errorformat': '%E%f:%l:%m',
        \ }
endfunction
