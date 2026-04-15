#!/bin/bash
# Module: claude — Link Claude Code config, install plugins + powerline binary
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Claude Code"

mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
link_file "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_file "$DOTFILES_DIR/.claude/claude-powerline.json" "$HOME/.claude/claude-powerline.json"

# Full setup: marketplaces, plugins, powerline binary.
# Requires `claude` CLI (installed by homebrew module, which runs before this one).
if [[ "${DRY_RUN:-false}" == "true" ]]; then
  dry_run "Would run claude-code-setup.sh (plugins, marketplaces, powerline)"
elif command -v claude &>/dev/null; then
  bash "$DOTFILES_DIR/claude-code-setup.sh"
else
  log_warn "Claude Code CLI not found. Skipping plugins/powerline install."
  log_warn "After installing Claude Code, run: bash $DOTFILES_DIR/claude-code-setup.sh"
fi
