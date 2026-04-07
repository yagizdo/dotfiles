#!/bin/bash
# Module: homebrew — Install Homebrew and run Brewfile
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Homebrew"

OS="$(uname -s)"

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  if dry_run "Would install Homebrew"; then
    :
  else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$OS" == "Darwin" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    log_ok "Homebrew installed"
  fi
else
  log_ok "Homebrew already installed"
fi

# Run Brewfile
if dry_run "Would run brew bundle with $DOTFILES_DIR/homebrew/Brewfile"; then
  :
else
  log_info "Installing packages from Brewfile..."
  brew update
  brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile"
  log_ok "Brewfile packages installed"
fi
