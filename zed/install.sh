#!/bin/bash
# Module: zed — Install Zed editor and link settings
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Zed Editor"

ZED_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zed"

# ════════════════════════════════════════════
# Fresh reset
# ════════════════════════════════════════════

if is_fresh; then
  remove_path "$ZED_DIR/settings.json"
  if is_linux; then
    pacman_reinstall "zed"
  fi
fi

# ════════════════════════════════════════════
# Install (Linux only — macOS uses the .app bundle)
# ════════════════════════════════════════════

if is_linux && ! is_fresh; then
  if ! command -v zed &>/dev/null; then
    pacman_install "zed"
  else
    log_ok "Zed already installed ($(zed --version 2>/dev/null | head -1))"
  fi
fi

# ════════════════════════════════════════════
# Sync settings
# ════════════════════════════════════════════

mkdir -p "$ZED_DIR"
link_file "$DOTFILES_DIR/zed/settings.json" "$ZED_DIR/settings.json"
