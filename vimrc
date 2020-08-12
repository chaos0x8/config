if has("win32") " WINDOWS CONFIG
  set encoding=cp1250
  set noswapfile
else " LINUX CONFIG
  " Pathogen
  execute pathogen#infect()
  call pathogen#helptags()

  " NERDTree
  nnoremap <F3> :NERDTreeToggle<CR>
  nnoremap <F2> :NERDTreeFind<CR>

  " Other
  set dictionary+=/usr/share/dict/words
  set path=.,,**
endif

if has("gui_running") " GUI CONFIG
  set mouse=""
  set guioptions=aci
  colorscheme slate
else
  colorscheme slate
endif

syntax on

set t_Co=256
set background=dark

set autoindent
set backspace=2
set history=256

set ts=2
set sts=2
set sw=2
set expandtab

set nowrap
set linebreak
" this option is useful with smart word wrap, but it disables showing trail spaces
" set nolist

set number
set list
set listchars=trail:_,tab:>-

set incsearch
set hlsearch
set ignorecase
set smartcase

set encoding=utf-8

set cursorline

nnoremap <silent><leader>] <C-w><C-]><C-w>T
nnoremap <silent><leader>/ :noh<CR>

if executable('rg')
  let g:ackprg = 'rg --vimgrep'
elseif executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

