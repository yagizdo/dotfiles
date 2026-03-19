#!/bin/bash

set -e

# Auto-detect repo location
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up your development environment..."
echo "Dotfiles directory: $DOTFILES_DIR"

OS="$(uname -s)"
echo "Detected OS: $OS"

# Parse arguments
MINIMAL=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --minimal)
      MINIMAL=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# ════════════════════════════════════════════
# Helper functions
# ════════════════════════════════════════════

backup_and_link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    mv "$dest" "$backup_dir/"
    echo "  Backed up $dest → $backup_dir/"
  fi
  ln -sf "$src" "$dest"
}

verify_symlink() {
  local target="$1" label="$2"
  if [ -L "$target" ]; then
    echo "  ✓ $label → $(readlink "$target")"
  else
    echo "  ✗ $label (FAILED)"
  fi
}

# ════════════════════════════════════════════
# Create directories
# ════════════════════════════════════════════
mkdir -p "$HOME/.config"
mkdir -p "$HOME/workspace"

# ════════════════════════════════════════════
# Install Homebrew
# ════════════════════════════════════════════
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ "$OS" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# ════════════════════════════════════════════
# Install packages
# ════════════════════════════════════════════
echo "Installing packages from Brewfile..."
brew update
brew bundle --file="$DOTFILES_DIR/Brewfile"

if [ "$MINIMAL" = false ]; then
  echo "Install Flutter development tools? (y/N)"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile.flutter"
  fi
else
  echo "Minimal mode: skipping optional Brewfiles."
fi

# ════════════════════════════════════════════
# Install Zinit
# ════════════════════════════════════════════
if [ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]; then
  echo "Installing Zinit..."
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
fi

# ════════════════════════════════════════════
# Symlinks
# ════════════════════════════════════════════
echo "Creating symlinks..."

# ZSH
backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# Oh-My-Posh
mkdir -p "$HOME/.config/oh-my-posh"
backup_and_link "$DOTFILES_DIR/oh-my-posh/theme.omp.json" "$HOME/.config/oh-my-posh/theme.omp.json"

# Warp
mkdir -p "$HOME/.warp/themes"
backup_and_link "$DOTFILES_DIR/warp/themes/catppuccin_mocha.yml" "$HOME/.warp/themes/catppuccin_mocha.yml"

# Neovim
backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux
mkdir -p "$HOME/.config/tmux"
backup_and_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM (Tmux Plugin Manager)..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Claude Code
mkdir -p "$HOME/.claude"
backup_and_link "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

# Git
backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
backup_and_link "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Check for git credentials setup
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo ""
  echo "Note: Git credentials not configured yet."
  echo "Run: bash $DOTFILES_DIR/git/setup-git.sh"
fi

# ════════════════════════════════════════════
# FVM Setup
# ════════════════════════════════════════════
echo "Setting up FVM..."
if command -v fvm &> /dev/null; then
  fvm install stable
  fvm global stable
fi

# ════════════════════════════════════════════
# Claude Code Integration
# ════════════════════════════════════════════
if [ "$MINIMAL" = false ] && command -v claude &>/dev/null; then
  echo ""
  echo "Claude Code detected. Run claude-code-setup.sh? (y/N)"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    bash "$DOTFILES_DIR/claude-code-setup.sh" --symlink
  fi
fi

# ════════════════════════════════════════════
# Create workspace
# ════════════════════════════════════════════
mkdir -p "$HOME/workspace"

# ════════════════════════════════════════════
# Verification
# ════════════════════════════════════════════
echo ""
echo "Symlink verification:"
verify_symlink "$HOME/.zshrc" ".zshrc"
verify_symlink "$HOME/.zprofile" ".zprofile"
verify_symlink "$HOME/.config/oh-my-posh/theme.omp.json" "oh-my-posh/theme.omp.json"
verify_symlink "$HOME/.warp/themes/catppuccin_mocha.yml" "warp/catppuccin_mocha.yml"
verify_symlink "$HOME/.config/nvim" "nvim"
verify_symlink "$HOME/.config/tmux/tmux.conf" "tmux/tmux.conf"
verify_symlink "$HOME/.claude/settings.json" "claude/settings.json"
verify_symlink "$HOME/.gitconfig" ".gitconfig"
verify_symlink "$HOME/.gitignore_global" ".gitignore_global"

echo ""
echo "Done! Next steps:"
echo "1. Restart your shell: exec zsh"
echo "2. Setup SSH: $DOTFILES_DIR/ssh/ssh.sh your@email.com"
echo "3. Open tmux and press Ctrl+a I to install plugins"
echo "4. Open Neovim - plugins will auto-install"
echo "5. Set Warp theme: Settings > Appearance > Themes > catppuccin_mocha"
