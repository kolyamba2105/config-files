local lualine = require'lualine'

lualine.setup {
  options = {
    theme = 'gruvbox_material'
  }
}

vim.cmd [[au BufEnter,BufWinEnter,WinEnter,CmdwinEnter * if bufname('%') == "NvimTree" | set laststatus=0 | else | set laststatus=2 | endif]]
