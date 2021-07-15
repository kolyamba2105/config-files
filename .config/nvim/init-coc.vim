call plug#begin(stdpath('data') . 'vimplug')

Plug 'arcticicestudio/nord-vim'
Plug 'hoob3rt/lualine.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'romgrk/barbar.nvim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'

call plug#end()

colorscheme nord

source ~/.config/nvim/vim/basics.vim
source ~/.config/nvim/vim/buffer-line.vim
source ~/.config/nvim/vim/coc.vim
source ~/.config/nvim/vim/mappings.vim
source ~/.config/nvim/vim/nvim-tree.vim
source ~/.config/nvim/vim/telescope.vim

lua << EOF
require('fuzzy-finder')
require('status-line')
require('treesitter')
EOF
