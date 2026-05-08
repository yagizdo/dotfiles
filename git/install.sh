#!/bin/bash
# Module: git — Link gitconfig and gitignore_global
#
# fresh: removes ~/.gitconfig and ~/.gitignore_global symlinks before relinking.
#        ~/.gitconfig.local (your name/email) is NOT touched.
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Git"

if is_fresh; then
  remove_path "$HOME/.gitconfig"
  remove_path "$HOME/.gitignore_global"
  log_info "Note: ~/.gitconfig.local (credentials) preserved"
fi

link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  log_warn "Git credentials not configured. Run: bash $DOTFILES_DIR/git/setup-git.sh"
fi
