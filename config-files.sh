# Remove all existing configs first
rm ~/.bash_profile
rm ~/.bashrc

rm ~/.xinitrc

rm ~/.xmonad/xmonad.hs
rm ~/.xmobarrc

rm ~/.config/alacritty/alacritty.yml
rm ~/.config/kitty/kitty.conf
rm ~/.config/nvim/init.vim
rm ~/.config/picom/picom.conf
rm ~/.config/rofi/config.rasi
rm ~/.config/rofi/themes/custom.rasi

# In case if repo directory gets renamed
directory=$PWD

# Bash profile
ln -s $directory/.bashrc ~/.bashrc
ln -s $directory/.bash_profile ~/.bash_profile

# X init
ln -s $directory/.xinitrc ~/.xinitrc

# XMonad WM
mkdir -p ~/.xmonad
ln -s $directory/.xmonad/xmonad.hs ~/.xmonad/xmonad.hs
ln -s $directory/.xmobarrc ~/.xmobarrc

# Create config directory if it doesn't exist
mkdir -p ~/.config

# Kitty terminal
mkdir -p ~/.config/kitty
ln -s $directory/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# Alacritty terminal
mkdir -p ~/.config/alacritty
ln -s $directory/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

# Neovim
mkdir -p ~/.config/nvim
ln -s $directory/.config/nvim/init.vim ~/.config/nvim/init.vim

# Picom compositor
mkdir -p ~/.config/picom
ln -s $directory/.config/picom/picom.conf ~/.config/picom/picom.conf

# Rofi application runner
mkdir -p ~/.config/rofi
mkdir -p ~/.config/rofi/themes
ln -s $directory/.config/rofi/config.rasi ~/.config/rofi/config.rasi
ln -s $directory/.config/rofi/themes/custom.rasi ~/.config/rofi/themes/custom.rasi
