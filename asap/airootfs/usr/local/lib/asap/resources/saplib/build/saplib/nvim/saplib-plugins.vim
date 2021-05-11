""" PLUGINS

call plug#begin('~/.config/nvim/vimplug')

" The coc code completion and LSP engine
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = ['coc-clangd', 'coc-cmake', 'coc-css', 'coc-cssmodules', 'coc-eslint', 'coc-html', 'coc-htmldjango', 'coc-java', 'coc-jedi', 'coc-json', 'coc-markdownlint', 'coc-prettier', 'coc-sh', 'coc-sql', 'coc-texlab', 'coc-tsserver', 'coc-xml', 'coc-yaml']

" Tag manager
Plug 'ludovicchabant/vim-gutentags'

" The prettier code formatter (https://github.com/prettier/vim-prettier)
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" Python docstring generator (type :Pydocstring)
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }

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

" Change the current directory to the project root folder automatically
Plug 'airblade/vim-rooter'

" Remember previous cursor position
Plug 'farmergreg/vim-lastplace'

" Smooth scrolling
Plug 'psliwka/vim-smoothie'

" Highlight trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

" Rainbow parentheses
Plug 'luochen1990/rainbow'

" Support for latex
Plug 'lervag/vimtex'

" Support for i3 config files
Plug 'potatoesmaster/i3-vim-syntax'

" Support for jsonc config files
Plug 'kevinoid/vim-jsonc'

call plug#end()

""" SETTINGS

" Rainbow: enable it
let g:rainbow_active = 1

" Airline: enable tabline
let g:airline#extensions#tabline#enabled = 1

" Numpy docstrings for pydocstring
let g:pydocstring_formatter = 'numpy'


""" KEYBINDINGS

" Search for and open files
noremap <silent> <F1> <Nop>
noremap <silent> <F1> :Files /<CR>
"deprecated in favor of vim-rooter: noremap <silent> <F2> :GFiles<CR>
noremap          <F2> :Files .<CR>
noremap          <F3> :Files 

" Search for lines using fzf
noremap <silent> <F4> :Lines<CR>

" Open undo-tree
noremap <silent> <F12> :UndotreeToggle<CR>

" use <CR> for coc completion selection and tab key for coc completion
" navigation
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" run :Prettier to auto-reformat supported files
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Toggle git gutter on/off
noremap <silent> <C-N> :GitGutterToggle <CR>
