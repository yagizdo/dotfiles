#!/bin/bash
# Module: claude — Link Claude Code settings and CLAUDE.md
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Claude Code"

mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
link_file "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

log_info "For full Claude Code setup (plugins, powerline), run: bash $DOTFILES_DIR/claude-code-setup.sh"
