#!/bin/bash
# Module: fish — Install fish shell and link config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Fish Shell"

FISH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"

if is_fresh; then
  remove_path "$FISH_CONFIG_DIR/config.fish"
  if is_macos; then
    brew_reinstall formula "fish"
  else
    pacman_reinstall "fish"
  fi
fi

if ! command -v fish &>/dev/null && ! is_fresh; then
  if is_macos; then
    if command -v brew &>/dev/null; then
      if dry_run "Would install fish via brew"; then :; else
        log_info "Installing fish..."
        brew install fish
      fi
    fi
  else
    pacman_install "fish"
  fi
fi

mkdir -p "$FISH_CONFIG_DIR"
link_file "$DOTFILES_DIR/fish/config.fish" "$FISH_CONFIG_DIR/config.fish"
