#!/bin/bash
# Module: ssh — Interactive SSH key setup (requires terminal)
#
# fresh: SSH keys are NEVER auto-deleted. Re-running with --fresh just re-runs
#        the key generation flow if no key exists. To regenerate, manually
#        delete ~/.ssh/id_ed25519 first.
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "SSH"

if [[ "$DRY_RUN" == "true" ]]; then
  dry_run "Would run interactive SSH setup: $DOTFILES_DIR/ssh/ssh.sh <email>"
  exit 0
fi

if [[ ! -t 0 ]]; then
  log_skip "SSH setup requires an interactive terminal. Run manually: bash $DOTFILES_DIR/ssh/ssh.sh your@email.com"
  exit 0
fi

if is_fresh && [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  log_warn "Fresh mode: SSH keys are not auto-deleted (too risky)"
  log_warn "To regenerate: rm ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub  then re-run"
fi

if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  log_ok "SSH key already exists at ~/.ssh/id_ed25519"
else
  log_info "Running SSH key setup..."
  bash "$DOTFILES_DIR/ssh/ssh.sh" "${1:-}"
fi
