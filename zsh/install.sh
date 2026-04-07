#!/bin/bash
# Module: zsh — Link shell config and install Zinit
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "ZSH"

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# Install Zinit
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  if dry_run "Would install Zinit"; then
    :
  else
    log_info "Installing Zinit..."
    mkdir -p "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
    log_ok "Zinit installed"
  fi
else
  log_ok "Zinit already installed"
fi
