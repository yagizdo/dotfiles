#!/bin/bash
# Module: vscode — Link VS Code settings
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "VS Code"

# macOS VS Code settings path
VSCODE_DIR="$HOME/Library/Application Support/Code/User"

if [[ "$(uname -s)" != "Darwin" ]]; then
  VSCODE_DIR="$HOME/.config/Code/User"
fi

mkdir -p "$VSCODE_DIR"
link_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"

log_info "To install extensions: cat $DOTFILES_DIR/vscode/extensions.txt | xargs -L 1 code --install-extension"
