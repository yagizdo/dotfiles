#!/bin/bash
# Module: oh-my-posh — Install Oh My Posh and link theme
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Oh My Posh"

if is_fresh; then
  remove_path "$HOME/.config/oh-my-posh/theme.omp.json"
  if is_macos; then
    brew_reinstall formula "jandedobbeleer/oh-my-posh/oh-my-posh"
  else
    if dry_run "Would reinstall oh-my-posh via install script"; then :; else
      log_fresh "Reinstalling Oh My Posh..."
      curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
  fi
fi

if ! command -v oh-my-posh &>/dev/null && ! is_fresh; then
  if is_macos; then
    if command -v brew &>/dev/null; then
      if dry_run "Would install oh-my-posh via brew"; then :; else
        log_info "Installing Oh My Posh..."
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
      fi
    fi
  else
    if dry_run "Would install oh-my-posh via install script"; then :; else
      log_info "Installing Oh My Posh..."
      curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
  fi
fi

mkdir -p "$HOME/.config/oh-my-posh"
link_file "$DOTFILES_DIR/oh-my-posh/theme.omp.json" "$HOME/.config/oh-my-posh/theme.omp.json"
