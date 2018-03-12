" vim: ts=4 sw=4 et

function! neomake#makers#ft#swift#EnabledMakers() abort
    if empty(neomake#utils#FindGlobFile('Package.swift'))
        return ['swiftpm']
    endif
    return ['swiftc']
endfunction

function! neomake#makers#ft#swift#swiftpm() abort
    let maker = neomake#makers#ft#swift#swiftc()
    call extend(maker, {
                \ 'exe': 'swiftc',
                \ 'args': ['-parse'],
                \ })
    return maker
endfunction

function! neomake#makers#ft#swift#swiftc() abort
    " `export SDKROOT="$(xcodebuild -version -sdk macosx Path)"`
    return {
        \ 'args': ['-parse'],
        \ 'errorformat':
            \ '%E%f:%l:%c: error: %m,' .
            \ '%W%f:%l:%c: warning: %m,' .
            \ '%Z%\s%#^~%#,' .
            \ '%-G%.%#',
        \ }
endfunction
