""" SETTINGS

" Filetype detection
filetype on
filetype plugin on
filetype indent on

" Tab settings
set smartindent
set autoindent
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType py(w)?                     setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType yml                        setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType make,asm                   setlocal           softtabstop=0 shiftwidth=8 noexpandtab
autocmd FileType html,xhtml,css,xml,xslt    setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType vim,lua,nginx              setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" Color scheme
syntax on
colorscheme slate
" uncomment if not running in tty and using a 256-colorscheme:
" set termguicolors

" Show hybrid line numbers by default
set number relativenumber

" Draw column 80
"highlight ColorColumn ctermfg=2
"highlight ColorColumn
"let &colorcolumn=join(range(81,256),",")
"set colorcolumn=80
set signcolumn=yes

" Disable overlength line wrapping
set nowrap

" Cursor settings
set sidescrolloff=4
set scrolloff=8

" Search settings
set ignorecase
set smartcase
set nohlsearch
set incsearch

" Autoupdate files if they get changed outside of vim
set autoread

" Reduced updatetime for a smoother experience
set updatetime=100

" History settings
set nobackup
set swapfile
set undodir=~/.local/share/nvim/undodir
set undofile

" Disable errorbells
set noerrorbells

" Disable preview window
set completeopt-=preview


""" KEYBINDINGS

" Type 'jj' to exit insert mode
inoremap <silent> jj <ESC>

" Move between splits using Ctrl+<vi-keys>
noremap <silent> <C-H> :wincmd h<CR>
noremap <silent> <C-L> :wincmd l<CR>
noremap <silent> <C-J> :wincmd j<CR>
noremap <silent> <C-K> :wincmd k<CR>

" FIXME Weird behaviour when combining these. write a vimscript function instead
" Toggle line numbers on/off
noremap <silent> <C-N> :set number! relativenumber!<CR>
" Toggle relative/absolute line numbers
noremap <silent> <C-M> :set number relativenumber!<CR>
