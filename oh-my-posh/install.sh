#!/bin/bash
# Module: oh-my-posh — Link prompt theme
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Oh My Posh"

mkdir -p "$HOME/.config/oh-my-posh"
link_file "$DOTFILES_DIR/oh-my-posh/theme.omp.json" "$HOME/.config/oh-my-posh/theme.omp.json"
