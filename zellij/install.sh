#!/bin/bash
# Module: zellij — Link Zellij config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Zellij"

mkdir -p "$HOME/.config/zellij"
link_file "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
