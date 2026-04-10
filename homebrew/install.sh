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

# Enable tracked git hooks (pre-commit auto-dumps Brewfile)
if [[ -d "$DOTFILES_DIR/.git" ]] && [[ -d "$DOTFILES_DIR/hooks" ]]; then
  if ! dry_run "Would set core.hooksPath=hooks in dotfiles repo"; then
    git -C "$DOTFILES_DIR" config core.hooksPath hooks
    log_ok "Git hooks enabled (core.hooksPath=hooks)"
  fi
fi
