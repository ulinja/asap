""" PLUGINS

call plug#begin('/usr/local/lib/vimplug')

" The ale linting engine.
" See 'https://github.com/dense-analysis/ale/blob/master/supported-tools.md'
" for a list of supported linting engines
Plug 'dense-analysis/ale'
let g:ale_linters = {
        \ 'sh': ['language_server'],
        \ }
let g:ale_fixers = {
        \ 'javascript': ['prettier'],
        \ 'css': ['prettier'],
        \ }

" The deoplete code completion engine
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'deoplete-plugins/deoplete-jedi'
Plug 'deoplete-plugins/deoplete-clang'
Plug 'deoplete-plugins/deoplete-docker'

" A nice status-bar
Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Auto-closing quotes, brackets, etc.
Plug 'raimondi/delimitmate'

" Comment out things
Plug 'tomtom/tcomment_vim'

" Fzf file finder
Plug 'junegunn/fzf' | Plug 'junegunn/fzf.vim'

" Undo-tree
Plug 'mbbill/undotree'

" Remember previous cursor position
Plug 'farmergreg/vim-lastplace'

" Smooth scrolling
Plug 'psliwka/vim-smoothie'

" Highlight trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

" Rainbow parentheses
Plug 'luochen1990/rainbow'

" Support for i3 config files
Plug 'potatoesmaster/i3-vim-syntax'

call plug#end()

""" GENERAL SETTINGS
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

" Show hybrid line numbers by default
set number relativenumber

" Draw column 80
highlight ColorColumn ctermbg=3
set colorcolumn=80
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
set undodir=~/.nvim/undodir
set undofile

" Disable errorbells
set noerrorbells

" Disable preview window
set completeopt-=preview

" Deoplete: enable it
let g:deoplete#enable_at_startup = 1

" Rainbow: enable it
let g:rainbow_active = 1

" Airline: enable tabline
let g:airline#extensions#tabline#enabled = 1


""" KEYBINDINGS

" Type 'jj' to exit insert mode
inoremap jj <ESC>

" Search for and open files
noremap <silent> <F1> :Files /<CR>
noremap <silent> <F2> :GFiles<CR>
noremap          <F3> :Files 

" Search for lines using fzf
noremap <silent> <M-F> :Lines<CR>

" Open undo-tree
noremap <silent> <F12> :UndotreeToggle<CR>

" use the tab key for deoplete completion
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Move between splits using Ctrl+<vi-keys>
noremap <silent> <C-H> :wincmd h<CR>
noremap <silent> <C-L> :wincmd l<CR>
noremap <silent> <C-J> :wincmd j<CR>
noremap <silent> <C-K> :wincmd k<CR>

" FIXME Weird behaviour when combining both. write a vimscript function instead
" Toggle line numbers on/off
noremap <silent> <C-N> :set number! relativenumber!<CR>
" Toggle relative/absolute line numbers
noremap <silent> <C-M> :set number relativenumber!<CR>
