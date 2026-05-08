#!/bin/bash
# Module: vscode — Link VS Code settings and install extensions
#
# fresh: removes settings.json, uninstalls all extensions, then reinstalls
#        from extensions.txt
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "VS Code"

VSCODE_DIR="$HOME/Library/Application Support/Code/User"
if [[ "$(uname -s)" != "Darwin" ]]; then
  VSCODE_DIR="$HOME/.config/Code/User"
fi

EXTENSIONS_FILE="$DOTFILES_DIR/vscode/extensions.txt"

# ════════════════════════════════════════════
# Fresh reset
# ════════════════════════════════════════════

if is_fresh; then
  remove_path "$VSCODE_DIR/settings.json"

  if command -v code &>/dev/null && [[ -f "$EXTENSIONS_FILE" ]]; then
    if dry_run "Would uninstall all VS Code extensions"; then
      :
    else
      log_fresh "Uninstalling VS Code extensions..."
      while IFS= read -r ext; do
        [[ -z "$ext" ]] && continue
        code --uninstall-extension "$ext" &>/dev/null || true
      done < "$EXTENSIONS_FILE"
    fi
  fi
fi

# ════════════════════════════════════════════
# Sync
# ════════════════════════════════════════════

mkdir -p "$VSCODE_DIR"
link_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"

# Install extensions if `code` is on PATH
if command -v code &>/dev/null && [[ -f "$EXTENSIONS_FILE" ]]; then
  if dry_run "Would install VS Code extensions from $EXTENSIONS_FILE"; then
    :
  else
    log_info "Installing VS Code extensions..."
    while IFS= read -r ext; do
      [[ -z "$ext" ]] && continue
      code --install-extension "$ext" --force &>/dev/null && \
        log_ok "ext $ext" || log_warn "ext $ext failed"
    done < "$EXTENSIONS_FILE"
  fi
else
  log_info "Install extensions later: cat $EXTENSIONS_FILE | xargs -L 1 code --install-extension"
fi
