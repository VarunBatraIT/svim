set background=dark
colorscheme solarized
set relativenumber
set number
" set term=xterm=256color
" Indent Settings
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=lightblue
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=lightcyan
"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=black   ctermbg=3
"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=grey ctermbg=4
set updatetime=100
let g:gitgutter_grep=''
let g:gitgutter_enabled = 1
let g:gitgutter_highlight_lines = 1
let g:gitgutter_signs = 1
let g:gitgutter_async = 0
let s:grep_available = 0
let g:gitgutter_realtime = 1
au FocusLost * nested silent! wall

nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk
nmap ]s <Plug>GitGutterStageHunk
nmap ]u <Plug>GitGutterUndoHunk

