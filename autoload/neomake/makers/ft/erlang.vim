
function! neomake#makers#ft#erlang#EnabledMakers() abort
    return ['erlc']
endfunction

function! neomake#makers#ft#erlang#erlc() abort
    return {
        \ 'exe': 'erlc',
        \ 'args': function('neomake#makers#ft#erlang#GlobPaths'),
        \ 'errorformat':
            \ '%W%f:%l: Warning: %m,' .
            \ '%E%f:%l: %m'
        \ }
endfunction

function! neomake#makers#ft#erlang#GlobPaths() abort
    " Pick the rebar3 profile to use.
    if expand('%') =~# '_SUITE.erl$'
        let profile = 'test'
    else
        let profile = 'default'
    endif
    " Find project root directory.
    let root = fnamemodify(neomake#utils#FindGlobFile('rebar.config'), ':h')
    let ebins = glob(root . '/_build/' . profile . '/lib/*/ebin', '', 1)
    " Set g:neomake_erlang_erlc_extra_deps in a project-local .vimrc, e.g.:
    "   let g:neomake_erlang_erlc_extra_deps = ['deps.local']
    " Or just b:neomake_erlang_erlc_extra_deps in a specific buffer.
    let extra_deps_dirs = get(b:, 'neomake_erlang_erlc_extra_deps',
                        \ get(g:, 'neomake_erlang_erlc_extra_deps'))
    if !empty(extra_deps_dirs)
        for extra_deps in extra_deps_dirs
            let ebins += glob(extra_deps . '/*/ebin', '', 1)
        endfor
    endif
    let args = ['-pa', 'ebin', '-I', 'include', '-I', 'src']
    for ebin in ebins
        let args += [ '-pa', ebin,
                    \ '-I', substitute(ebin, 'ebin$', 'include', '') ]
    endfor
    let build_dir = root . '/_build'
    " If <project-root>/_build doesn't exist we'll clutter CWD with .beam files,
    " the same way erlc does by default.
    if isdirectory(build_dir)
        let target_dir = build_dir . '/neomake'
        if !isdirectory(target_dir)
            call mkdir(target_dir, 'p')
        endif
        let args += ['-o', target_dir]
    endif
    return args
endfunction
