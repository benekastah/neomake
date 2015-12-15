
function! neomake#makers#ft#lhaskell#EnabledMakers()
    " Have not tested hdevtools yet!
    "return ['ghcmod', 'hdevtools', 'hlint']
    return ['ghcmod', 'hlint'] 
endfunction

function! neomake#makers#ft#lhaskell#hdevtools()
    return {
        \ 'exe': 'hdevtools',
        \ 'args': ['check', '-g-Wall'],
        \ 'errorformat':
            \ '%-Z %#,'.
            \ '%W%f:%l:%v: Warning: %m,'.
            \ '%W%f:%l:%v: Warning:,'.
            \ '%E%f:%l:%v: %m,'.
            \ '%E%>%f:%l:%v:,'.
            \ '%+C  %#%m,'.
            \ '%W%>%f:%l:%v:,'.
            \ '%+C  %#%tarning: %m,'
        \ }
endfunction

function! neomake#makers#ft#lhaskell#ghcmod()
    " This filters out newlines, which is what neovim gives us instead of the
    " null bytes that ghc-mod sometimes spits out.
    let mapexpr = 'substitute(v:val, "\n", "", "g")'
    return {
        \ 'exe': 'ghc-mod',
        \ 'args': ['check'],
        \ 'mapexpr': mapexpr,
        \ 'errorformat':
            \ '%-G%\s%#,' .
            \ '%f:%l:%c:%trror: %m,' .
            \ '%f:%l:%c:%tarning: %m,'.
            \ '%f:%l:%c: %trror: %m,' .
            \ '%f:%l:%c: %tarning: %m,' .
            \ '%E%f:%l:%c:%m,' .
            \ '%E%f:%l:%c:,' .
            \ '%Z%m'
        \ }
endfunction

function! neomake#makers#ft#lhaskell#hlint()
    return {
        \ 'errorformat':
            \ 'hlint: In file %f at line %l:%m,' .
            \ '%E%f:%l:%v: Error: %m,' .
            \ '%W%f:%l:%v: Warning: %m,' .
            \ '%C%m'
        \ }
endfunction
