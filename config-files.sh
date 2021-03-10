# In case if repo directory gets renamed
directory=$PWD

# Bash profile
ln -s $directory/.bashrc ~/.bashrc
ln -s $directory/.bash_profile ~/.bash_profile

# XMonad WM
mkdir -p ~/.xmonad
ln -s $directory/.xmonad/xmonad.hs ~/.xmonad/xmonad.hs
ln -s $directory/.xmobarrc ~/.xmobarrc

# Create config directory if it doesn't exist
mkdir -p ~/.config

# Kitty terminal
mkdir -p ~/.config/kitty
ln -s $directory/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# Neovim
mkdir -p ~/.config/nvim
ln -s $directory/.config/nvim/init.vim ~/.config/nvim/init.vim

# Picom compositor
mkdir -p ~/.config/picom
ln -s $directory/.config/picom/picom.conf ~/.config/picom/picom.conf

