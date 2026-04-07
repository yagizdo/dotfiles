#!/bin/bash
# Full system setup for a fresh machine
# Runs bootstrap --all + Claude Code setup in one go
#
# Usage:
#   bash fresh-install.sh              # full setup
#   bash fresh-install.sh --dry-run    # preview only
#
# What this does:
#   1. Clones dotfiles (if not already present)
#   2. Runs bootstrap.sh --all (Homebrew, packages, all configs)
#   3. Runs Claude Code plugin/marketplace setup
#   4. Applies macOS preferences

set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/helpers.sh"

DRY_RUN="${DRY_RUN:-false}"

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--dry-run) DRY_RUN="true"; shift ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Full system setup for a fresh machine. Installs everything and configures all dotfiles.

Options:
  -n, --dry-run   Preview what would happen
  -h, --help      Show this help

This runs:
  1. bootstrap.sh --all  (Homebrew + all modules)
  2. claude-code-setup.sh (plugins, marketplaces, powerline)
  3. macOS system preferences
EOF
      exit 0
      ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

log_header "Fresh Install"
log_info "This will set up your entire development environment."
echo ""

# ════════════════════════════════════════════
# Step 1: Bootstrap (Homebrew + all modules)
# ════════════════════════════════════════════

log_header "Step 1/3 — Bootstrap"

BOOTSTRAP_ARGS=(--all)
[[ "$DRY_RUN" == "true" ]] && BOOTSTRAP_ARGS+=(--dry-run)

bash "$DOTFILES_DIR/bootstrap.sh" "${BOOTSTRAP_ARGS[@]}"

# ════════════════════════════════════════════
# Step 2: Claude Code full setup
# ════════════════════════════════════════════

log_header "Step 2/3 — Claude Code Setup"

if [[ "$DRY_RUN" == "true" ]]; then
  dry_run "Would run claude-code-setup.sh (plugins, marketplaces, powerline)"
else
  if command -v claude &>/dev/null; then
    bash "$DOTFILES_DIR/claude-code-setup.sh"
  else
    log_warn "Claude Code CLI not found yet. Run claude-code-setup.sh after opening Claude Code."
  fi
fi

# ════════════════════════════════════════════
# Step 3: macOS preferences
# ════════════════════════════════════════════

if [[ "$(uname -s)" == "Darwin" ]]; then
  log_header "Step 3/3 — macOS Preferences"

  if [[ "$DRY_RUN" == "true" ]]; then
    dry_run "Would apply macOS keyboard modifier settings"
  else
    # Caps Lock -> Escape (built-in keyboard)
    # Reference: macos/keyboard-modifiers.md
    log_info "See macos/keyboard-modifiers.md for keyboard modifier setup (requires System Settings)"
    log_ok "macOS preferences noted"
  fi
else
  log_header "Step 3/3 — macOS Preferences"
  log_skip "Not macOS, skipping"
fi

# ════════════════════════════════════════════
# Summary
# ════════════════════════════════════════════

echo ""
log_header "Done!"

if [[ "$DRY_RUN" == "true" ]]; then
  log_warn "Dry-run mode — no changes were made"
else
  log_ok "Full setup complete!"
  echo ""
  log_info "Next steps:"
  echo "  1. Restart your shell: exec zsh"
  echo "  2. Open Claude Code and verify plugins"
  echo "  3. Set keyboard modifiers in System Settings (see macos/keyboard-modifiers.md)"
fi
