#!/bin/bash
# Module: warp — Link Warp terminal theme
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Warp"

mkdir -p "$HOME/.warp/themes"
link_file "$DOTFILES_DIR/warp/themes/catppuccin_mocha.yml" "$HOME/.warp/themes/catppuccin_mocha.yml"
