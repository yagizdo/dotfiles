#!/bin/bash
# Module: zellij — Link Zellij config
#
# fresh: removes config and layout symlinks before relinking
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Zellij"

if is_fresh; then
  remove_path "$HOME/.config/zellij/config.kdl"
  remove_path "$HOME/.config/zellij/layouts/quiver.kdl"
fi

mkdir -p "$HOME/.config/zellij/layouts"
link_file "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
link_file "$DOTFILES_DIR/zellij/layouts/quiver.kdl" "$HOME/.config/zellij/layouts/quiver.kdl"
