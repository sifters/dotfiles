" Indenting Logic - default to 4 spaces
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=8

" Folding
setlocal foldmethod=indent
setlocal foldlevel=99

" Visualizations
setlocal textwidth=88
setlocal colorcolumn=89

" File Format for newlines
setlocal fileformat=unix

" Formatting
" c: wrap comments; r: auto-insert # on Enter; q: format with 'gq'
" l: don't break long lines in insert mode (stay in the flow)
setlocal formatoptions+=crql
