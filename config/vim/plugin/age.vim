" yubikey-crypt.vim  (age-only)
" Edit YubiKey-encrypted text files in place: decrypt on open, encrypt on save.
" Plaintext lives only in the buffer (RAM); nothing decrypted is written to disk.
"
" Install: drop this in ~/.vim/plugin/  (Vim)  or  ~/.config/nvim/plugin/  (Neovim).
" Works the same on macOS and Linux. Operates on *.age files.
"
" Encryption uses your recipients file (no key needed). Decryption uses the
" age-plugin-yubikey identity and is the only step that prompts for PIN/touch.
"
" ---- configure these ------------------------------------------------------
let g:yk_age_identity   = expand('~/.config/age/yubikey-identity.txt')      " plugin identity
let g:yk_age_recipients = expand('~/.config/age/yubikey-recipient.txt')    " recipient string(s)
" ---------------------------------------------------------------------------

augroup YubiKeyCrypt
  autocmd!
  autocmd BufNewFile,BufReadPre *.age call s:Harden()
  autocmd BufReadCmd            *.age call s:ReadCmd()
  autocmd BufWriteCmd           *.age call s:WriteCmd()
augroup END

" Keep plaintext from leaking to disk via vim's own scratch mechanisms.
function! s:Harden() abort
  setlocal noswapfile noundofile nobackup nowritebackup
  " viminfo/shada is global; emptying it stops marks/registers/search from
  " any file being persisted this session. Comment out if too aggressive.
  setlocal viminfo=
  " Pipe shell I/O instead of staging it through a temp file on disk.
  set noshelltemp
endfunction

" Decrypt the file on disk into the buffer.
function! s:ReadCmd() abort
  call s:Harden()
  let l:file = expand('<afile>:p')
  let l:cmd  = 'age --decrypt --identity ' . shellescape(g:yk_age_identity)
        \ . ' ' . shellescape(l:file)
  let l:out = systemlist(l:cmd)
  if v:shell_error
    echohl ErrorMsg
    echom 'yubikey-crypt: decrypt failed (YubiKey inserted? PIN/touch correct?)'
    echohl None
    return
  endif
  silent keepjumps %delete _
  call setline(1, l:out)
  setlocal nomodified
  " Detect filetype from the inner name, e.g. notes.md.age -> markdown.
  execute 'doautocmd filetypedetect BufRead ' . fnameescape(expand('<afile>:r'))
endfunction

" Encrypt the buffer and write the ciphertext to disk.
function! s:WriteCmd() abort
  let l:file = expand('<afile>:p')
  let l:text = join(getline(1, '$'), "\n") . "\n"
  let l:cmd  = 'age --encrypt --recipients-file ' . shellescape(g:yk_age_recipients)
        \ . ' --output ' . shellescape(l:file)
  call system(l:cmd, l:text)
  if v:shell_error
    echohl ErrorMsg
    echom 'yubikey-crypt: encrypt failed; file NOT written.'
    echohl None
    return
  endif
  setlocal nomodified
endfunction
