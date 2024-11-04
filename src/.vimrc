" General
set wildmenu
set viminfo=
set splitright

" Disable backups
set nobackup
set noswapfile
set nowritebackup

" Colors, theme, etc
filetype on
filetype plugin off
syntax on
colorscheme elflord
set background=dark

set number
set ruler
set title

" Tabs and spaces
set expandtab
set nostartofline
set shiftwidth=4
set tabstop=4

" Cursor and columns
" set cursorline
set cursorcolumn

" Note: Vim 7.2 does not support 'colorcolumn'
if exists('+colorcolumn')
  set colorcolumn=80
endif

highlight CursorColumn ctermbg=234
highlight ColorColumn ctermbg=234

" Indentation
" filetype plugin indent on
" set autoindent

" Search
set ignorecase
set hlsearch
set incsearch

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Shortcuts
map 0 ^

map <Tab> :tabnext<cr>
map <S-Tab> :tabprevious<cr>

" Pathogen
if filereadable(expand($HOME . "/.vim/autoload/pathogen.vim"))
    execute pathogen#infect()
endif

" Syntax highlighting
au BufNewFile,BufRead Jenkinsfile set filetype=groovy
au BufNewFile,BufRead Vagrantfile set filetype=ruby
au BufNewFile,BufRead composer.lock set filetype=json
au BufNewFile,BufRead docker-compose*.yml set filetype=yaml
au BufNewFile,BufRead kops-edit*yaml set filetype=yaml
au BufNewFile,BufRead *.aws/config* set filetype=cfg
au BufNewFile,BufRead *.aws/credentials* set filetype=cfg
au BufNewFile,BufRead *.edgerc set filetype=cfg
au BufNewFile,BufRead *.kube/config set filetype=yaml
au BufNewFile,BufRead *.nomad set filetype=hcl
au BufNewFile,BufRead *.oci/config set filetype=cfg
au BufNewFile,BufRead *.rego set filetype=go
au BufNewFile,BufRead *.textile set filetype=redminewiki
au BufNewFile,BufRead *.tfstate set filetype=json

" Settings for specific filetypes
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype hcl,terraform,tf setlocal ts=2 sts=2 sw=2
autocmd Filetype toml setlocal ts=2 sts=2 sw=2
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2
