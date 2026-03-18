" .vimrc - Minimal and Usable Config (Primeagen Style)
" Optimized for fast editing and syntax highlighting for C, Python, Lua, Bash

" ==========================================
" 1. Essential Settings
" ==========================================
set nocompatible
filetype plugin indent on
syntax on

" Usability settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set scrolloff=8         " Keep 8 lines above/below cursor
set updatetime=50       " Faster transition times
set noerrorbells        " No sounds
set hidden              " Allow switching buffers without saving

" Indentation (General)
set tabstop=4
set shiftwidth=4
set expandtab           " Use spaces instead of tabs
set smartindent

" Search settings
set incsearch           " Search as you type
set ignorecase          " Case insensitive search
set smartcase           " ...unless capital letter used
set nohlsearch          " Clear search after use (Primeagen style)

" ==========================================
" 2. Plugins (using vim-plug)
" ==========================================
call plug#begin('~/.vim/plugged')

" The Theme: Rose Pine
Plug 'rose-pine/vim'

" Language Specific Highlighting
Plug 'vim-python/python-syntax'         " Better Python syntax
Plug 'bfrg/vim-cpp-modern'              " Modern C/C++ syntax
Plug 'voldikss/vim-lua'                 " Lua support for Vim

call plug#end()

" ==========================================
" 3. Theme & Look (no bold fonts)
" ==========================================
if (has("termguicolors"))
    set termguicolors
endif

" Rose Pine Config
let g:rose_pine_variant = 'moon'        " 'main', 'moon', or 'dawn'
let g:rose_pine_disable_bold = 1        " Disable bold fonts in the theme (VERY IMPORTANT)

" Try to apply colorscheme
try
    " The plugin uses 'rosepine' name internally
    colorscheme rosepine
catch
endtry

" Force disable bold for common groups (prevents 'W18' errors)
function! StripBold()
    let l:groups = ['Bold', 'Keyword', 'Statement', 'Identifier', 'Type', 'Function', 'Special', 'Constant', 'String', 'Comment', 'PreProc', 'Todo']
    for l:group in l:groups
        silent! execute 'highlight! ' . l:group . ' cterm=NONE gui=NONE'
    endfor
endfunction

" Re-apply on every colorscheme change
autocmd ColorScheme * call StripBold()
" Call it initially
silent! call StripBold()

" ==========================================
" 4. Keybindings (Minimalist)
" ==========================================
let mapleader = " "

" Fast way to clear search highlight
nnoremap <leader>h :nohlsearch<CR>

" Primeagen-inspired: Move highlighted text in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Fast editing: Use system clipboard (requires +clipboard support in vim)
set clipboard=unnamedplus

" Quick save/quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
