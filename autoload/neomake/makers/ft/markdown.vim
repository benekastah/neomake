" vim: ts=4 sw=4 et
function! neomake#makers#ft#markdown#EnabledMakers() abort
    let makers = executable('mdl') ? ['mdl'] : ['markdownlint']
    return makers + ['proselint']
endfunction

function! neomake#makers#ft#markdown#mdl() abort
    return {
                \ 'errorformat':
                \ '%f:%l: %m'
                \ }
endfunction

function! neomake#makers#ft#markdown#proselint() abort
    return neomake#makers#ft#text#proselint()
endfunction

function! neomake#makers#ft#markdown#markdownlint() abort
    return {
                \ 'errorformat':
                \ '%f: %l: %m'
                \ }
endfunction
