" mdpreview.vim — container-backed Markdown / Marp preview for vanilla Vim
" Loaded once at startup. Defines :MdPreview, :MdPreviewStop, :MdPreviewList
" and the supporting helper functions used by after/ftplugin/markdown.vim.

if exists('g:loaded_mdpreview') || &compatible
  finish
endif
let g:loaded_mdpreview = 1

" ---------------------------------------------------------------------------
" User-overridable settings (set any of these in your vimrc to customise)
" ---------------------------------------------------------------------------
let g:mdpreview_runtime       = get(g:, 'mdpreview_runtime', 'podman')
let g:mdpreview_grip_image    = get(g:, 'mdpreview_grip_image', 'docker.io/mbentley/go-grip:latest')
let g:mdpreview_marp_image    = get(g:, 'mdpreview_marp_image', 'localhost/mdpreview-marp:latest')
let g:mdpreview_port_base     = get(g:, 'mdpreview_port_base', 38000)
let g:mdpreview_port_range    = get(g:, 'mdpreview_port_range', 1000)
let g:mdpreview_open_browser  = get(g:, 'mdpreview_open_browser', 1)
let g:mdpreview_auto_stop     = get(g:, 'mdpreview_auto_stop', 1)

" ---------------------------------------------------------------------------
" Internal state: maps absolute file path -> container metadata dict
" { name, port, kind, file }
" ---------------------------------------------------------------------------
if !exists('s:active')
  let s:active = {}
endif

" ---------------------------------------------------------------------------
" Helpers
" ---------------------------------------------------------------------------

" Stable, collision-resistant port derived from the file path. The same file
" always maps to the same port across vim sessions, which is convenient if
" you keep a browser tab open; different files get different ports so multiple
" previews can run at once.
function! s:PortFor(path) abort
  let l:h = 0
  for l:i in range(strlen(a:path))
    " classic djb2-ish rolling hash; keep it small-int friendly
    let l:h = (l:h * 33 + char2nr(a:path[l:i])) % 2147483647
  endfor
  return g:mdpreview_port_base + (l:h % g:mdpreview_port_range)
endfunction

" Container name derived from the file path. Podman requires names match
" [a-zA-Z0-9][a-zA-Z0-9_.-]*; we sanitise and truncate.
function! s:ContainerName(path) abort
  let l:safe = substitute(a:path, '[^A-Za-z0-9]', '_', 'g')
  let l:safe = substitute(l:safe, '^_*', '', '')
  return 'mdpreview_' . strpart(l:safe, max([0, strlen(l:safe) - 80]))
endfunction

" Decide which renderer to use. Marp slides are detected by either a
" 'marp: true' line in YAML frontmatter or a `.marp.md` extension.
function! s:DetectKind(path) abort
  if a:path =~? '\.marp\.md$'
    return 'marp'
  endif
  " Cheap frontmatter scan: only the first ~20 lines.
  try
    let l:lines = readfile(a:path, '', 25)
  catch
    return 'grip'
  endtry
  if len(l:lines) > 0 && l:lines[0] =~# '^---\s*$'
    for l:line in l:lines[1:]
      if l:line =~# '^---\s*$'
        break
      endif
      if l:line =~? '^\s*marp\s*:\s*true\s*$'
        return 'marp'
      endif
    endfor
  endif
  return 'grip'
endfunction

" Open a URL in the user's browser, best-effort, non-blocking.
function! s:OpenBrowser(url) abort
  if !g:mdpreview_open_browser
    return
  endif
  if has('mac') || has('macunix')
    call system('open ' . shellescape(a:url) . ' &')
  elseif executable('xdg-open')
    call system('xdg-open ' . shellescape(a:url) . ' >/dev/null 2>&1 &')
  endif
endfunction

" Run a podman command, capturing output and reporting non-zero exits.
function! s:Run(cmd) abort
  let l:out = system(a:cmd)
  if v:shell_error != 0
    echohl ErrorMsg
    echom '[mdpreview] command failed: ' . a:cmd
    echom l:out
    echohl None
    return 0
  endif
  return 1
endfunction

" Percent-encode a single URL path segment. We only encode characters that
" actually cause trouble in a path component (spaces, #, ?, %, and anything
" non-ASCII-printable). Letters, digits, '.', '_', '-', '~' stay literal.
function! s:UrlEncodeSegment(s) abort
  let l:out = ''
  for l:i in range(strlen(a:s))
    let l:c = a:s[l:i]
    let l:n = char2nr(l:c)
    if (l:n >= char2nr('A') && l:n <= char2nr('Z'))
      \ || (l:n >= char2nr('a') && l:n <= char2nr('z'))
      \ || (l:n >= char2nr('0') && l:n <= char2nr('9'))
      \ || l:c ==# '.' || l:c ==# '_' || l:c ==# '-' || l:c ==# '~'
      let l:out .= l:c
    else
      let l:out .= printf('%%%02X', l:n)
    endif
  endfor
  return l:out
endfunction

" Is a container by this name already running?
function! s:IsRunning(name) abort
  let l:out = system(g:mdpreview_runtime . ' ps --filter name=^' . a:name . '$ --format "{{.Names}}"')
  return v:shell_error == 0 && l:out =~# '\v^\s*' . a:name . '\s*$'
endfunction

" ---------------------------------------------------------------------------
" Public API
" ---------------------------------------------------------------------------

function! mdpreview#Start(...) abort
  let l:path = a:0 > 0 && !empty(a:1) ? fnamemodify(a:1, ':p') : expand('%:p')
  if empty(l:path) || !filereadable(l:path)
    echohl ErrorMsg | echom '[mdpreview] no readable file: ' . l:path | echohl None
    return
  endif

  if has_key(s:active, l:path) && s:IsRunning(s:active[l:path].name)
    let l:meta = s:active[l:path]
    let l:url = 'http://localhost:' . l:meta.port . '/' . s:UrlEncodeSegment(l:meta.file)
    echom '[mdpreview] already running: ' . l:url
    call s:OpenBrowser(l:url)
    return
  endif

  let l:kind  = s:DetectKind(l:path)
  let l:port  = s:PortFor(l:path)
  let l:name  = s:ContainerName(l:path)
  let l:dir   = fnamemodify(l:path, ':h')
  let l:file  = fnamemodify(l:path, ':t')

  if l:kind ==# 'marp'
    " Marp server mode on the directory so the watcher catches edits. We bind
    " the unique per-file port to Marp's internal 8080, and the live-reload
    " websocket on 37717 to itself.
    let l:cmd  = g:mdpreview_runtime . ' run --rm -d --init'
    let l:cmd .= ' --name ' . shellescape(l:name)
    let l:cmd .= ' -v ' . shellescape(l:dir) . ':/home/marp/app:Z'
    let l:cmd .= ' -e LANG=' . shellescape($LANG)
    let l:cmd .= ' -p ' . l:port . ':8080'
    let l:cmd .= ' -p ' . (l:port + 1) . ':37717'
    let l:cmd .= ' ' . shellescape(g:mdpreview_marp_image)
    let l:cmd .= ' -s .'
  else
    " go-grip: bind the per-file port to the container's 6419. go-grip listens
    " on all interfaces inside the container by default. We pass -b=false so
    " it doesn't try (and fail) to spawn a browser inside the container — we
    " open the browser from vim on the host instead. The file argument is
    " relative to /data (the mounted directory).
    let l:cmd  = g:mdpreview_runtime . ' run --rm -d --init'
    let l:cmd .= ' --name ' . shellescape(l:name)
    let l:cmd .= ' -v ' . shellescape(l:dir) . ':/data:Z'
    let l:cmd .= ' -p ' . l:port . ':6419'
    let l:cmd .= ' ' . shellescape(g:mdpreview_grip_image)
    let l:cmd .= ' -b=false -p 6419 ' . shellescape(l:file)
  endif

  if !s:Run(l:cmd)
    return
  endif

  let s:active[l:path] = {'name': l:name, 'port': l:port, 'kind': l:kind, 'file': l:file}
  let l:url = 'http://localhost:' . l:port . '/' . s:UrlEncodeSegment(l:file)
  echom '[mdpreview] ' . l:kind . ' -> ' . l:url
  call s:OpenBrowser(l:url)
endfunction

function! mdpreview#Stop(...) abort
  let l:path = a:0 > 0 && !empty(a:1) ? fnamemodify(a:1, ':p') : expand('%:p')
  if !has_key(s:active, l:path)
    " Fall back to name-based stop, in case state was lost across vim sessions.
    let l:name = s:ContainerName(l:path)
    if s:IsRunning(l:name)
      call s:Run(g:mdpreview_runtime . ' stop ' . shellescape(l:name))
      echom '[mdpreview] stopped ' . l:name
    endif
    return
  endif
  let l:entry = s:active[l:path]
  call s:Run(g:mdpreview_runtime . ' stop ' . shellescape(l:entry.name))
  call remove(s:active, l:path)
  echom '[mdpreview] stopped ' . l:entry.name
endfunction

function! mdpreview#List() abort
  if empty(s:active)
    echom '[mdpreview] no active previews'
    return
  endif
  for [l:path, l:meta] in items(s:active)
    let l:url = 'http://localhost:' . l:meta.port . '/' . s:UrlEncodeSegment(l:meta.file)
    echom printf('%s  %s  (%s)  %s', l:meta.kind, l:url, l:meta.name, l:path)
  endfor
endfunction

function! mdpreview#OnBufUnload(path) abort
  if g:mdpreview_auto_stop && has_key(s:active, a:path)
    call mdpreview#Stop(a:path)
  endif
endfunction

" ---------------------------------------------------------------------------
" Commands
" ---------------------------------------------------------------------------
command! -nargs=? -complete=file MdPreview      call mdpreview#Start(<q-args>)
command! -nargs=? -complete=file MdPreviewStop  call mdpreview#Stop(<q-args>)
command! -nargs=0                MdPreviewList  call mdpreview#List()
