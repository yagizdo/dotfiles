#!/bin/bash
# Module: zed — Install Zed editor (Linux-only)
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Zed Editor"

if is_macos; then
  log_skip "Zed module — skipping on macOS"
  exit 0
fi

if is_fresh; then
  pacman_reinstall "zed"
elif ! command -v zed &>/dev/null; then
  pacman_install "zed"
else
  log_ok "Zed already installed ($(zed --version 2>/dev/null | head -1))"
fi
