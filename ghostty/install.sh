#!/bin/bash
# Module: ghostty — Link Ghostty config
#
# fresh: removes the config symlink before relinking
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Ghostty"

GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"

if is_fresh; then
  remove_path "$GHOSTTY_DIR/config"
fi

mkdir -p "$GHOSTTY_DIR"
link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"
