" vim: ts=4 sw=4 et
scriptencoding utf-8

function! neomake#utils#LogMessage(level, msg) abort
    let verbose = get(g:, 'neomake_verbose', 1)
    let logfile = get(g:, 'neomake_logfile')
    let msg ='Neomake: '.a:msg  " .' ('.a:level.')'
    if verbose >= a:level
        redraw
        if a:level ==# 0
            echohl ErrorMsg
        endif
        echom msg
        if a:level ==# 0
            echohl None
        endif
    endif
    if exists(':Log') == 2
        Log a:msg
    endif
    if type(logfile) ==# type('') && len(logfile)
        let date = strftime('%Y-%m-%dT%H:%M:%S%z')
        call writefile([date.' Log level '.a:level.': '.msg], logfile, 'a')
    endif
endfunction

function! neomake#utils#ErrorMessage(msg) abort
    call neomake#utils#LogMessage(0, a:msg)
endfunction

function! neomake#utils#QuietMessage(msg) abort
    call neomake#utils#LogMessage(1, a:msg)
endfunction

function! neomake#utils#LoudMessage(msg) abort
    call neomake#utils#LogMessage(2, a:msg)
endfunction

function! neomake#utils#DebugMessage(msg) abort
    call neomake#utils#LogMessage(3, a:msg)
endfunction

function! neomake#utils#Stringify(obj) abort
    if type(a:obj) == type([])
        let ls = map(copy(a:obj), 'neomake#utils#Stringify(v:val)')
        return '['.join(ls, ', ').']'
    elseif type(a:obj) == type({})
        let ls = []
        for key in keys(a:obj)
            call add(ls, key.': '.neomake#utils#Stringify(a:obj[key]))
        endfor
        return '{'.join(ls, ', ').'}'
    else
        return ''.a:obj
    endif
endfunction

function! neomake#utils#DebugObject(msg, obj) abort
    call neomake#utils#DebugMessage(a:msg.' '.neomake#utils#Stringify(a:obj))
endfunction

" This comes straight out of syntastic.
"print as much of a:msg as possible without "Press Enter" prompt appearing
function! neomake#utils#WideMessage(msg) abort " {{{2
    let old_ruler = &ruler
    let old_showcmd = &showcmd

    "This is here because it is possible for some error messages to
    "begin with \n which will cause a "press enter" prompt.
    let msg = substitute(a:msg, "\n", '', 'g')

    "convert tabs to spaces so that the tabs count towards the window
    "width as the proper amount of characters
    let chunks = split(msg, "\t", 1)
    let msg = join(map(chunks[:-2], "v:val . repeat(' ', &tabstop - strwidth(v:val) % &tabstop)"), '') . chunks[-1]
    let msg = strpart(msg, 0, &columns - 1)

    set noruler noshowcmd
    redraw

    call neomake#utils#DebugMessage('WideMessage echo '.msg)
    echo msg

    let &ruler = old_ruler
    let &showcmd = old_showcmd
endfunction " }}}2

" This comes straight out of syntastic.
function! neomake#utils#IsRunningWindows() abort
    return has('win32') || has('win64')
endfunction

" This comes straight out of syntastic.
function! neomake#utils#DevNull() abort
    if neomake#utils#IsRunningWindows()
        return 'NUL'
    endif
    return '/dev/null'
endfunction

function! neomake#utils#Exists(exe) abort
    " DEPRECATED: just use executable() directly.
    return executable(a:exe)
endfunction

function! neomake#utils#Random() abort
    call neomake#utils#DebugMessage('Calling neomake#utils#Random')
    if neomake#utils#IsRunningWindows()
        let cmd = 'Echo %RANDOM%'
    else
        let cmd = 'echo $RANDOM'
    endif
    let answer = 0 + system(cmd)
    if v:shell_error
        " If complaints come up about this, consider using python
        throw "Can't generate random number for this platform"
    endif
    return answer
endfunction

function! neomake#utils#MakerFromCommand(shell, command) abort
    let command = substitute(a:command, '%\(:[a-z]\)*',
                           \ '\=expand(submatch(0))', 'g')
    let shell_name = split(a:shell, '/')[-1]
    if index(['sh', 'csh', 'ash', 'bash', 'dash', 'ksh', 'pdksh', 'mksh', 'zsh', 'fish'],
            \shell_name) >= 0
        let args = ['-c', command]
    else
        let shell_name = split(a:shell, '\\')[-1]
        if (shell_name ==? 'cmd.exe')
            let args = [&shellcmdflag, command]
        endif
    endif
    return {
        \ 'exe': a:shell,
        \ 'args': args
        \ }
endfunction

let s:available_makers = {}
function! neomake#utils#MakerIsAvailable(ft, maker_name) abort
    if a:maker_name ==# 'makeprg'
        " makeprg refers to the actual makeprg, which we don't need to check
        " for our purposes
        return 1
    endif
    if !has_key(s:available_makers, a:maker_name)
        let maker = neomake#GetMaker(a:maker_name, a:ft)
        let s:available_makers[a:maker_name] = executable(maker.exe)
    endif
    return s:available_makers[a:maker_name]
endfunction

function! neomake#utils#AvailableMakers(ft, makers) abort
    return filter(copy(a:makers), 'neomake#utils#MakerIsAvailable(a:ft, v:val)')
endfunction

function! neomake#utils#GetSupersetOf(ft) abort
    try
        return eval('neomake#makers#ft#' . a:ft . '#SupersetOf()')
    catch /^Vim\%((\a\+)\)\=:E117/
        return ''
    endtry
endfunction

" Attempt to get list of filetypes in order of most specific to least specific.
function! neomake#utils#GetSortedFiletypes(ft) abort
    function! CompareFiletypes(ft1, ft2) abort
        if neomake#utils#GetSupersetOf(a:ft1) ==# a:ft2
            return -1
        elseif neomake#utils#GetSupersetOf(a:ft2) ==# a:ft1
            return 1
        else
            return 0
        endif
    endfunction

    return sort(split(a:ft, '\.'), function('CompareFiletypes'))
endfunction

" Get a setting by key, based on filetypes, from the buffer or global
" namespace, defaulting to default.
function! neomake#utils#GetSetting(key, maker, default, fts, bufnr) abort
  if len(a:fts)
    for ft in a:fts
      let config_var = 'neomake_'.ft.'_'.a:maker.name.'_'.a:key
      if has_key(g:, config_var)
            \ || getbufvar(a:bufnr, config_var) !=# ''
        break
      endif
    endfor
  else
    let config_var = 'neomake_'.a:maker.name.'_'.a:key
  endif
  if getbufvar(a:bufnr, config_var) !=# ''
    return copy(getbufvar(a:bufnr, config_var))
  elseif has_key(g:, config_var)
    return copy(get(g:, config_var))
  elseif has_key(a:maker, a:key)
    return a:maker[a:key]
  endif
  " Look for 'neomake_'.key in the buffer and global namespace.
  let bufvar = getbufvar(a:bufnr, 'neomake_'.a:key)
  if bufvar !=# ''
      return bufvar
  endif
  let var = get(g:, 'neomake_'.a:key)
  if var !=# ''
      return var
  endif
  return a:default
endfunction

" Get property from highlighting group.
function! neomake#utils#GetHighlight(group, what) abort
  let reverse = synIDattr(synIDtrans(hlID(a:group)), 'reverse')
  let what = a:what
  if reverse
    if what ==# 'fg'
      let what = 'bg'
    elseif what ==# 'bg'
      let what = 'fg'
    elseif what ==# 'fg#'
      let what = 'bg#'
    elseif what ==# 'bg#'
      let what = 'fg#'
    endif
  endif
  if what[-1:] ==# '#'
      let val = synIDattr(synIDtrans(hlID(a:group)), what, 'gui')
  else
      let val = synIDattr(synIDtrans(hlID(a:group)), what, 'cterm')
  endif
  if empty(val) || val == -1
    let val = 'NONE'
  endif
  return val
endfunction

function! neomake#utils#CompressWhitespace(entry) abort
    let text = a:entry.text
    let text = substitute(text, "\001", '', 'g')
    let text = substitute(text, '\n', ' ', 'g')
    let text = substitute(text, '\m\s\{2,}', ' ', 'g')
    let text = substitute(text, '\m^\s\+', '', '')
    let text = substitute(text, '\m\s\+$', '', '')
    let a:entry.text = text
endfunction

function! neomake#utils#ExpandArgs(args) abort
    " Only expand those args that start with \ and a single %
    call map(a:args, "v:val =~# '\\(^\\\\\\|^%$\\|^%[^%]\\)' ? expand(v:val) : v:val")
endfunction
