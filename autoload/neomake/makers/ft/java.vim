"============================================================================
"File:        java.vim
"Description: Syntax checking plugin for neomake
"Maintainer:  Wang Shidong <wsdjeg at outlook dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================


let s:save_cpo = &cpo
set cpo&vim

if exists('g:neomake_java_javac_maker')
    finish
endif

function! s:getClasspath() abort
    return '.'
endfunction
let g:neomake_java_javac_option =
            \get(g:,'neomake_java_javac_option','-Xlint')
let g:neomake_java_javac_outputdir =
            \get(g:,'neomake_java_javac_outputdir','.')
let g:neomake_java_javac_classpath =
            \get(g:,'neomake_java_javac_classpath',s:getClasspath())


function! neomake#makers#ft#java#EnabledMakers()
        return ['javac']
endfunction

function! neomake#makers#ft#java#javac()
    return {
                \ 'args':[
                \g:neomake_java_javac_option,
                \'-cp',g:neomake_java_javac_classpath,
                \'-d',g:neomake_java_javac_outputdir
                \],
                \ 'errorformat':
                \ '%E%f:%l: error: %m,'.
                \ '%W%f:%l: warning: %m,'.
                \ '%E%f:%l: %m,'.
                \ '%Z%p^,'.
                \ '%-G%.%#'
                \ }
endfunction

let g:neomake_java_javac_maker = 1
let &cpo = s:save_cpo
unlet s:save_cpo
