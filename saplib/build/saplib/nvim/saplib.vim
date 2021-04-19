""" GENERAL SETTINGS

" tab settings
set smartindent
set autoindent
set tabstop=8 softtabstop=8 shiftwidth=8 expandtab
autocmd FileType make           setlocal           softtabstop=0 shiftwidth=8 noexpandtab
autocmd FileType (x)?htm(l)?    setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType css            setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" color scheme
set syntax

" show hybrid line numbers by default
set number relativenumber

" draw column 120
highlight ColorColumn ctermbg=3
set colorcolumn=120
set signcolumn=yes

" disable overlength line wrapping
set nowrap

" cursor settings
set sidescrolloff=4
set scrolloff=8

" search settings
set ignorecase
set smartcase
set nohlsearch
set incsearch

" autoupdate files when changed outside of vim
set autoread

" history settings
set nobackup
set swapfile
set undodir=~/.nvim/undodir
set undofile

" disable errorbells
set noerrorbells

" disable preview window
set completeopt-=preview



""" KEYBINDINGS

" type 'jj' to exit insert mode
imap jj <ESC>

" move between splits using Ctrl+<vi-keys>
map <silent> <C-h> :wincmd h <CR>
map <silent> <C-l> :wincmd l <CR>
map <silent> <C-j> :wincmd j <CR>
map <silent> <C-k> :wincmd k <CR>

" toggle relative/absolute line numbers
" FIXME weird behaviour. write a vimscript function instead
noremap <silent> <C-m> :set number relativenumber! <CR>
" toggle line numbers on/off
noremap <silent> <C-n> :set number! relativenumber! <CR>
