#!/bin/bash
# Module: claude — Install Claude Code CLI and delegate config+plugins to claude-code-setup.sh
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Claude Code"

# Install Claude Code CLI if missing (via Homebrew cask)
if ! command -v claude &>/dev/null; then
  if dry_run "Would install claude-code cask via brew"; then
    :
  elif command -v brew &>/dev/null; then
    log_info "Installing Claude Code CLI..."
    brew install --cask claude-code@latest
    log_ok "Claude Code CLI installed"
  else
    log_warn "Homebrew not found. Install Claude Code manually, then re-run this module."
  fi
fi

# Delegate settings install + plugins + powerline to the dedicated setup script.
# It handles symlink/copy modes itself and also installs settings.local.json.
SETUP_FLAG="--symlink"
[[ "${COPY_MODE:-false}" == "true" ]] && SETUP_FLAG="--copy"

if [[ "${DRY_RUN:-false}" == "true" ]]; then
  dry_run "Would run claude-code-setup.sh $SETUP_FLAG"
elif command -v claude &>/dev/null; then
  bash "$DOTFILES_DIR/claude-code-setup.sh" "$SETUP_FLAG"
else
  log_warn "Claude Code CLI not found. Skipping plugins/powerline install."
  log_warn "After installing Claude Code, run: bash $DOTFILES_DIR/claude-code-setup.sh $SETUP_FLAG"
fi
