#!/bin/bash
# Module: git — Link gitconfig and gitignore_global
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Git"

link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Remind about credentials if not set up
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  log_warn "Git credentials not configured. Run: bash $DOTFILES_DIR/git/setup-git.sh"
fi
