" .vimrc

" We're VIMproved!
set nocompatible

" Vundle requires this
filetype off


"""""""""""""""""""""""""""""""""""""
" Vundle
"""""""""""""""""""""""""""""""""""""

" Setup Vundle
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" Let Vundle manage Vundle
Plugin 'gmarik/vundle'

" Plugin these plugins
Plugin 'tsaleh/vim-align'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'scrooloose/nerdtree'
Plugin 'kchmck/vim-coffee-script'
Plugin 'skwp/vim-rspec'
Plugin 'myusuf3/numbers.vim'
Plugin 'flazz/vim-colorschemes'
Plugin 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/syntastic'
Plugin 'pangloss/vim-javascript'


""""""""""""""""""""""""""""""""""""""
" Color Scheme
""""""""""""""""""""""""""""""""""""""

" Install Solarized (the last color scheme you'll ever need)
Plugin 'altercation/vim-colors-solarized'

" Also required by vundle
filetype plugin indent on

syntax enable
set background=dark
"tanner's colors
"colorscheme base16-tomorrow
"let g:solarized_termcolors=256
"let g:solarized_visibility="normal"
"colorscheme solarized

" Disable the GUI menu bar (if running)
if has("gui_running")
  set guioptions-=T
endif

"highlight the current cursor line
set cursorline

"
" Tabs n' shit
"
" Tabs / Spaces
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab
set autoindent
set smartindent

" Line Nunbers
set number

" Incremental search, highlight searches
set incsearch
set hlsearch
set visualbell
set shell=bash

"Add Git status to statusline
set statusline=%{fugitive#statusline()}

""""""""""""""""""""""""""""""""""""""
" Key Bindings
""""""""""""""""""""""""""""""""""""""
" Map return in command mode to clear search buffer
nnoremap <cr> :noh<cr><cr>

"Default leader sucks, comma makes a lot of things cleaner
let mapleader = ","

" File navigation with ease

" Command-T (well, command-f really)
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>

" Edit in current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%

" Tab navigation
noremap <c-tab> :tabnext<cr>

" NerdTree
map <leader>n :NERDTreeToggle<cr>

" Turn off the arrow keys you fucking Neanderthal. THIS IS VIM!
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

"""""""""""""""""""""""""""""""""""""""
" Swap file containment
"""""""""""""""""""""""""""""""""""""""

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.
