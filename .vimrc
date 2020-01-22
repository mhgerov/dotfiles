set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Vim Settings
Plugin 'tpope/vim-sensible'
" Utility Plugins
Plugin 'scrooloose/nerdtree'
Plugin 'mattn/emmet-vim'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
" Syntax Plugins
Plugin 'aklt/plantuml-syntax'
Bundle 'gabrielelana/vim-markdown'
" Theme Plugins
Plugin 'nlknguyen/papercolor-theme'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" set tabstop=4 softtabstop=4 shiftwidth=2 noexpandtab
set number relativenumber
set splitright splitbelow
set ignorecase smartcase

set mouse=a
set listchars=tab:→\ ,trail:-,extends:>,precedes:<,nbsp:+,eol:¬

" Papercolor
set t_Co=256
set background=dark
colorscheme PaperColor

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
