#!/bin/bash
# Module: oh-my-posh — Link prompt theme
#
# fresh: removes the theme symlink and reinstalls oh-my-posh via brew
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Oh My Posh"

if is_fresh; then
  remove_path "$HOME/.config/oh-my-posh/theme.omp.json"
  brew_reinstall formula "jandedobbeleer/oh-my-posh/oh-my-posh"
fi

mkdir -p "$HOME/.config/oh-my-posh"
link_file "$DOTFILES_DIR/oh-my-posh/theme.omp.json" "$HOME/.config/oh-my-posh/theme.omp.json"
