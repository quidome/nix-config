set nocompatible

" Leader
let mapleader = " "

" UI
set number
set relativenumber
set cursorline
set scrolloff=3
set sidescrolloff=5
set showmatch
set laststatus=2
set noshowmode
set termguicolors
highlight clear SignColumn

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase
nnoremap <Esc> :nohlsearch<CR><Esc>

" Indentation
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set smartindent
set autoindent
autocmd FileType ruby,yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" Files and editing
set encoding=utf-8
set fileencoding=utf-8
set fileformats=unix,dos,mac
set backspace=indent,eol,start
set clipboard=unnamedplus
set undofile
set wildmenu
set wildmode=longest:full,full
set list
set listchars=tab:»·,trail:·

" Convenience
nnoremap ; :
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <F11> :set nonumber!<CR>:GitGutterDisable<CR>
command WQ wq
command Wq wq
command Q q
command W :execute ':silent w !sudo tee % > /dev/null' | edit!

" Plugin config
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#empty_message = 'no scm'
let g:DirDiffExcludes = 'CVS,*.class,*.exe,.*.swp,.DS_Store'

" Let Home Manager's Catppuccin integration manage the colorscheme.

" Restore cursor position
if has('autocmd')
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif
endif

" Go shortcuts
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)

syntax enable
filetype plugin indent on
