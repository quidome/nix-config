" Set keymappings

" make content copyable
nnoremap <F11> :set nonumber!<CR>:GitGutterDisable<CR>

" Disable search highlights by pressing escape
nnoremap <leader><esc> :noh<return><esc>

" easy buffer switching
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>


" no need for shift
nnoremap    ;     :

" s for seek
nmap s <Plug>(easymotion-s2)

" q no more
map q :

" neovim terminal stuff
nnoremap <Leader>t :call TermEnter()<CR>
"autocmd TermOpen * set bufhidden=hide
"tnoremap <Esc> <C-\><C-n>
"tnoremap <C-Left> <m-b>
noremap <C-Right> <m-f>
":au TermOpen * :let  g:terminal_scrollback_buffer_size=100000

" color nested [({
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle

" Add git diff to gutter

" Lean & mean status/tabline for vim that's light as air.
let g:airline#extensions#branch#empty_message = 'no scm'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ctrlp#color_template = 'normal'
let g:airline#extensions#ctrlp#show_adjacent_modes = 1
let g:airline#extensions#eclim#enabled = 1
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#flags = 'f'
let g:airline#extensions#virtualenv#enabled = 1
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

"
let g:airline_theme='dark_minimal'
"let g:airline_theme='sol'
" nerdtree
"Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
map <C-n> :NERDTreeToggle<CR>

let g:DirDiffExcludes = "CVS,*.class,*.exe,.*.swp,.DS_Store"

" delimitMate provides insert mode auto-completion for quotes, parens, brackets, etc
"Plug 'Raimondi/delimitMate'
"let g:delimitMate_balance_matchpairs = 1
"let g:delimitMate_expand_cr = 2
"let g:delimitMate_expand_inside_quotes = 1
"let g:delimitMate_expand_space = 1
"let g:delimitMate_jump_expansion = 1

" you complete me
"let g:ycm_complete_in_comments = 1 " Completion in comments
"let g:ycm_complete_in_strings = 1 " Completion in string
"let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword

" sirver/UltiSnips
"Plug 'sirver/UltiSnips'
"let g:UltiSnipsExpandTrigger       ="<c-tab>"
"let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
"let g:UltiSnipsJumpForwardTrigger  = "<tab>"

" tmux interaction
"Plug 'johnsonch/vimux'
"map <Leader>r :VimuxPromptCommand<CR>
"map <Leader>a :VimuxRunLastCommand<CR>
"let VimuxUseNearest = 0

" Addn & mean status/tabline for vim that's light as air. plugins to &runtimepath
"call plug#end()

filetype plugin indent on
filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

" Per filetype indentation
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2 expandtab

" Favo colors, gruvbox dark ftw
if $TERM_BG == "light"
  set background=light
else
  set background=dark
endif

try
   colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
endtry

" Make gutter background color match that of line numbers
highlight clear SignColumn

" unite plugin
nnoremap <Leader>f :Unite -start-insert file_rec/async<CR>

" fix common typos
" use W to write as root
command WQ wq
command Wq wq
command Q q
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

syntax enable
syntax on             " Enable syntax highlighting
set autoindent
set backspace=indent,eol,start " Set for maximum backspace smartness"
set clipboard=unnamed
set cmdheight=1         " Less Hit Return messages
set cursorline
set display+=uhex " Show unprintables as <xx>
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set fileencodings=utf-8
set fileencodings=utf-8,ucs-bom,cp1251
set fileformat=unix
set fileformats=unix,dos,mac
set gdefault
set hlsearch	" Enable highlight search
set ignorecase
set incsearch
set laststatus=2        " Always show status bar
set linespace=1 " add some line space for easy reading
set list
set listchars=tab:»·,trail:·
set nocompatible      " We're running Vim, not Vi!
set noshowmode
set number
set pastetoggle=<F10>
set relativenumber
set scrolloff=3 " don't scroll any closer to top/bottom
set secure
set shiftwidth=2
set shortmess=aoOtT     " Abbreviate the status messages
set showcmd             " Show command I'm typing
set showmatch
set sidescrolloff=5 " don't scroll any closer to left/right
set smartcase
set smartindent
set smarttab
set softtabstop=2
set t_Co=256
set tabstop=2
set timeoutlen=500
set undodir=~/.vim/undodir
set undofile
set wildchar=<TAB>      " Character to start command line completion
set wildmenu            " Enhanced command line completion mode
set wildmode=longest:full,full

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"Go
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
