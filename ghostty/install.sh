#!/bin/bash
# Module: ghostty — Link Ghostty config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Ghostty"

mkdir -p "$HOME/.config/ghostty"
link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
