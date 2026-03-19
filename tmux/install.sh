#!/bin/bash
# Module: tmux — Link tmux.conf and install TPM
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Tmux"

mkdir -p "$HOME/.config/tmux"
link_file "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Install TPM (Tmux Plugin Manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  if dry_run "Would install TPM (Tmux Plugin Manager)"; then
    :
  else
    log_info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log_ok "TPM installed — press Ctrl+a I inside tmux to install plugins"
  fi
else
  log_ok "TPM already installed"
fi
