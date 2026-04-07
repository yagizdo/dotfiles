#!/bin/bash
# Module: ssh — Interactive SSH key setup (requires terminal)
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "SSH"

if [[ "$DRY_RUN" == "true" ]]; then
  dry_run "Would run interactive SSH setup: $DOTFILES_DIR/ssh/ssh.sh <email>"
  exit 0
fi

# SSH setup is interactive — guard against non-interactive shells
if [[ ! -t 0 ]]; then
  log_skip "SSH setup requires an interactive terminal. Run manually: bash $DOTFILES_DIR/ssh/ssh.sh your@email.com"
  exit 0
fi

if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  log_ok "SSH key already exists at ~/.ssh/id_ed25519"
else
  log_info "Running SSH key setup..."
  bash "$DOTFILES_DIR/ssh/ssh.sh" "${1:-}"
fi
