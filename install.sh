#!/bin/bash
# One-liner entry point for fresh machines
# Usage: curl -sL <raw-url> | bash
#   or:  bash install.sh [--all | --core | -m <module> ...]

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
  if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Install git first."
    exit 1
  fi
  echo "Cloning dotfiles to $DOTFILES_DIR..."
  git clone https://github.com/yagizdo/dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
bash bootstrap.sh "$@"
