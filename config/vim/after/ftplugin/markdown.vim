if exists('b:loaded_mdpreview_ftplugin')
  finish
endif
let b:loaded_mdpreview_ftplugin = 1

setlocal backupcopy=yes

" Buffer-local key mappings. <LocalLeader> defaults to '\' but most users
" remap it; we use <Plug> so these can be overridden in a vimrc without
" editing the plugin.
nnoremap <buffer> <silent> <Plug>(MdPreviewStart) :MdPreview<CR>
nnoremap <buffer> <silent> <Plug>(MdPreviewStop)  :MdPreviewStop<CR>
nnoremap <buffer> <silent> <Plug>(MdPreviewList)  :MdPreviewList<CR>
 
if !hasmapto('<Plug>(MdPreviewStart)') && empty(maparg('<LocalLeader>mp', 'n'))
  nmap <buffer> <LocalLeader>mp <Plug>(MdPreviewStart)
endif
if !hasmapto('<Plug>(MdPreviewStop)') && empty(maparg('<LocalLeader>ms', 'n'))
  nmap <buffer> <LocalLeader>ms <Plug>(MdPreviewStop)
endif
if !hasmapto('<Plug>(MdPreviewList)') && empty(maparg('<LocalLeader>ml', 'n'))
  nmap <buffer> <LocalLeader>ml <Plug>(MdPreviewList)
endif
 
" Stop the container when the buffer is unloaded, so vim quitting (or :bd)
" doesn't leave orphan podman containers running. Guarded by
" g:mdpreview_auto_stop inside mdpreview#OnBufUnload itself.
augroup mdpreview_buffer
  autocmd! * <buffer>
  autocmd BufUnload <buffer> call mdpreview#OnBufUnload(expand('<afile>:p'))
augroup END
 

