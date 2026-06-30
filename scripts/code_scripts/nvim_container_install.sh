#!/bin/bash

# update ubuntu lxc container & install packages
apt update
apt install -y git curl ripgrep fd-find nodejs npm unzip

# install nvim latest version
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz

# clone configs
git clone --bare https://github.com/yxki-th/arch-dotfiles.git /tmp/dotfiles-bare
git --git-dir=/tmp/dotfiles-bare --work-tree=$HOME checkout -- ~/.config/nvim/
rm -rf /tmp/dotfiles-bare

echo "nvim + lazyvim configg ready. Run nvim to start"
