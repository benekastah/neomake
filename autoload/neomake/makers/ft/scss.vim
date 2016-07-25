" vim: ts=4 sw=4 et

function! neomake#makers#ft#scss#EnabledMakers()
    return ['scsslint']
endfunction

function! neomake#makers#ft#scss#scsslint()
    return {
        \ 'exe': 'scss-lint',
        \ 'errorformat': '%A%f:%l:%v [%t] %m'
    \ }
endfunction
