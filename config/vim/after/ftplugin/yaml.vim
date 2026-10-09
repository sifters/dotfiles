" Indentation
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal textwidth=120
setlocal colorcolumn=120

" Prevent comments from auto-indenting
setlocal indentkeys-=0#

" Prevent colons from triggering re-indentation
setlocal indentkeys-=<:>

" Folding
setlocal foldlevelstart=20

" Linting
let g:ale_yaml_yamllint_options = '-d "{extends: relaxed, rules: {line-length: {max: 120, level: error}}}"'
