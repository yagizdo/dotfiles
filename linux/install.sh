#!/bin/bash
# Module: linux — Install base packages via pacman
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Linux Base Packages"

if is_macos; then
  log_skip "Linux module — skipping on macOS"
  exit 0
fi

PACKAGES=(
  base-devel
  git
  curl
  nodejs
  npm
  neovim
  shellcheck
  github-cli
  scrcpy
  unzip
)

if is_fresh; then
  if dry_run "Would reinstall base packages"; then exit 0; fi
  log_fresh "Reinstalling base packages..."
  sudo pacman -S --noconfirm "${PACKAGES[@]}"
else
  if dry_run "Would install base packages"; then exit 0; fi
  log_info "Installing base packages..."
  sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
fi

log_ok "Base packages installed"
