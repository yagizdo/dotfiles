#!/bin/bash

set -e

echo "Setting up your Flutter development environment..."

OS="$(uname -s)"
echo "Detected OS: $OS"

# Create directories
mkdir -p $HOME/.config
mkdir -p $HOME/workspace

# Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ "$OS" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# Install packages
echo "Installing packages from Brewfile..."
brew update
brew bundle --file=./Brewfile
brew bundle --file=./Brewfile.flutter

# Install Zinit
if [ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]; then
  echo "Installing Zinit..."
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
fi

# Symlinks
echo "Creating symlinks..."

# ZSH
rm -rf $HOME/.zshrc
ln -sf $HOME/.dotfiles/zsh/.zshrc $HOME/.zshrc

rm -rf $HOME/.zprofile
ln -sf $HOME/.dotfiles/zsh/.zprofile $HOME/.zprofile

# Oh-My-Posh
mkdir -p $HOME/.config/oh-my-posh
ln -sf $HOME/.dotfiles/oh-my-posh/theme.omp.json $HOME/.config/oh-my-posh/theme.omp.json

# Warp
mkdir -p $HOME/.warp/themes
ln -sf $HOME/.dotfiles/warp/themes/catppuccin_mocha.yml $HOME/.warp/themes/catppuccin_mocha.yml

# Neovim
rm -rf $HOME/.config/nvim
ln -sf $HOME/.dotfiles/nvim $HOME/.config/nvim

# Tmux
rm -rf $HOME/.config/tmux
mkdir -p $HOME/.config/tmux
ln -sf $HOME/.dotfiles/tmux/tmux.conf $HOME/.config/tmux/tmux.conf

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM (Tmux Plugin Manager)..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Claude Code
mkdir -p $HOME/.claude
rm -rf $HOME/.claude/settings.json
ln -sf $HOME/.dotfiles/.claude/settings.json $HOME/.claude/settings.json

# FVM Setup
echo "Setting up FVM..."
if command -v fvm &> /dev/null; then
  fvm install stable
  fvm global stable
fi

# Create workspace
mkdir -p $HOME/workspace

echo ""
echo "Done! Next steps:"
echo "1. Restart your shell: exec zsh"
echo "2. Open tmux and press Ctrl+a I to install plugins"
echo "3. Open Neovim - plugins will auto-install"
echo "4. Set Warp theme: Settings > Appearance > Themes > catppuccin_mocha"
