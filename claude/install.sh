#!/bin/bash
# Module: claude — Link Claude Code settings
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Claude Code"

mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

if [[ -f "$DOTFILES_DIR/claude/settings.local.json" ]]; then
  link_file "$DOTFILES_DIR/claude/settings.local.json" "$HOME/.claude/settings.local.json"
fi

log_info "For full Claude Code setup (plugins, powerline), run: bash $DOTFILES_DIR/claude-code-setup.sh"
