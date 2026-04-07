#!/bin/bash
# Module: antigravity — Link Antigravity (VS Code fork) config
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Antigravity"

ANTIGRAVITY_DIR="$HOME/Library/Application Support/Antigravity/User"
mkdir -p "$ANTIGRAVITY_DIR"

link_file "$DOTFILES_DIR/antigravity/settings.json" "$ANTIGRAVITY_DIR/settings.json"
link_file "$DOTFILES_DIR/antigravity/keybindings.json" "$ANTIGRAVITY_DIR/keybindings.json"

# Install extensions
if [[ "$DRY_RUN" == "true" ]]; then
  dry_run "Would install Antigravity extensions from extensions.txt"
elif command -v antigravity &>/dev/null; then
  log_info "Installing extensions..."
  while IFS= read -r ext; do
    antigravity --install-extension "$ext" --force 2>/dev/null || true
  done < "$DOTFILES_DIR/antigravity/extensions.txt"
else
  log_warn "Antigravity CLI not found, skipping extension install"
fi
