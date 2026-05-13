#!/bin/bash
# Module: zellij — Install Zellij and link config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Zellij"

if is_fresh; then
  remove_path "$HOME/.config/zellij/config.kdl"
  remove_path "$HOME/.config/zellij/layouts/quiver.kdl"
  if is_macos; then
    brew_reinstall formula "zellij"
  else
    pacman_reinstall "zellij"
  fi
fi

if ! command -v zellij &>/dev/null && ! is_fresh; then
  if is_macos; then
    if command -v brew &>/dev/null; then
      if dry_run "Would install zellij via brew"; then :; else
        log_info "Installing Zellij..."
        brew install zellij
      fi
    fi
  else
    pacman_install "zellij"
  fi
fi

mkdir -p "$HOME/.config/zellij/layouts"
link_file "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
link_file "$DOTFILES_DIR/zellij/layouts/quiver.kdl" "$HOME/.config/zellij/layouts/quiver.kdl"
