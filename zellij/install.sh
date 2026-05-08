#!/bin/bash
# Module: zellij — Link Zellij config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Zellij"

mkdir -p "$HOME/.config/zellij/layouts"
link_file "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
link_file "$DOTFILES_DIR/zellij/layouts/quiver.kdl" "$HOME/.config/zellij/layouts/quiver.kdl"
