#!/bin/bash
# Module: ghostty — Link Ghostty config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Ghostty"

mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
link_file "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
