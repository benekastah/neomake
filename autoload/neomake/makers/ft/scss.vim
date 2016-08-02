" vim: ts=4 sw=4 et

function! neomake#makers#ft#scss#EnabledMakers()
    return executable('sass-lint') ? ['sass-lint'] : ['scss-lint']
endfunction

function! neomake#makers#ft#scss#scsslint()
    return {
        \ 'exe': 'scss-lint',
        \ 'errorformat': '%A%f:%l:%v [%t] %m'
    \ }
endfunction

function! neomake#makers#ft#scss#sasslint()
    return {
        \ 'exe': 'sass-lint',
        \ 'args': ['--no-exit', '--verbose', '--format=compact'],
        \ 'errorformat':
            \ '%E%f: line %l\, col %c\, Error - %m,' .
            \ '%W%f: line %l\, col %c\, Warning - %m',
        \ }
endfunction

