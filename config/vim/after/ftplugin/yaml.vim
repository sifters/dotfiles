" Indentation
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

" Prevent comments from auto-indenting
setlocal indentkeys-=0#

" Prevent colons from triggering re-indentation
setlocal indentkeys-=<:>

" Folding
setlocal foldlevelstart=20
let g:indentLine_char = '⦙'

" Linting
let g:ale_yaml_yamllint_options = '-d "{extends: relaxed, rules: {line-length: disable}}"'
