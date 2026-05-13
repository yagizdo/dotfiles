#!/bin/bash
# Module: ghostty — Install Ghostty and link config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Ghostty"

if is_macos; then
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
  GHOSTTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
fi

if is_fresh; then
  remove_path "$GHOSTTY_DIR/config"
  if is_macos; then
    brew_reinstall cask "ghostty"
  else
    pacman_reinstall "ghostty"
  fi
fi

if ! command -v ghostty &>/dev/null && ! is_fresh; then
  if is_macos; then
    if command -v brew &>/dev/null; then
      if dry_run "Would install ghostty via brew"; then :; else
        log_info "Installing Ghostty..."
        brew install --cask ghostty
      fi
    fi
  else
    pacman_install "ghostty"
  fi
fi

mkdir -p "$GHOSTTY_DIR"
link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"
