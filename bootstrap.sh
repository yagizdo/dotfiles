#!/bin/bash
# Modular dotfiles installer
# Usage: ./bootstrap.sh [OPTIONS] [module ...]
set -eo pipefail

# ════════════════════════════════════════════
# Load libraries
# ════════════════════════════════════════════

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# shellcheck source=lib/helpers.sh
source "$DOTFILES_DIR/lib/helpers.sh"
# shellcheck source=lib/modules.sh
source "$DOTFILES_DIR/lib/modules.sh"

# ════════════════════════════════════════════
# Error handling
# ════════════════════════════════════════════

cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    log_error "Bootstrap failed (exit code $exit_code)"
  fi
}
trap cleanup EXIT

# ════════════════════════════════════════════
# Usage
# ════════════════════════════════════════════

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [module ...]

Modular dotfiles installer. Install individual modules or groups.

Options:
  -m, --module <name>   Install a specific module (repeatable)
  -a, --all             Install all modules
      --core            Install core modules only (homebrew, zsh, git)
  -n, --dry-run         Show what would happen without making changes
  -v, --verbose         Verbose output
  -f, --force           Overwrite without backup
  -h, --help            Show this help message

Examples:
  $(basename "$0")                        # show this help
  $(basename "$0") --all                  # install everything
  $(basename "$0") --core                 # install core (homebrew, zsh, git)
  $(basename "$0") -m zsh -m tmux        # install specific modules
  $(basename "$0") -m claude              # install just Claude Code config
  $(basename "$0") --dry-run --all       # preview all changes

EOF
  list_modules
}

# ════════════════════════════════════════════
# Parse arguments
# ════════════════════════════════════════════

MODULES=()
MODE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--module)
      if [[ -z "${2:-}" ]]; then
        log_error "--module requires a module name"
        exit 1
      fi
      MODULES+=("$2")
      MODE="specific"
      shift 2
      ;;
    -a|--all)
      MODE="all"
      shift
      ;;
    --core)
      MODE="core"
      shift
      ;;
    -n|--dry-run)
      DRY_RUN="true"
      shift
      ;;
    -v|--verbose)
      VERBOSE="true"
      shift
      ;;
    -f|--force)
      FORCE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      log_error "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      # Positional args treated as module names
      MODULES+=("$1")
      MODE="specific"
      shift
      ;;
  esac
done

# No flags = show help
if [[ -z "$MODE" ]]; then
  usage
  exit 0
fi

# ════════════════════════════════════════════
# Preflight checks
# ════════════════════════════════════════════

preflight() {
  verbose "Running preflight checks..."

  local os
  os="$(uname -s)"
  if [[ "$os" != "Darwin" ]] && [[ "$os" != "Linux" ]]; then
    log_error "Unsupported OS: $os"
    exit 1
  fi
  verbose "OS: $os"

  for tool in git curl; do
    if ! command -v "$tool" &>/dev/null; then
      log_error "Required tool not found: $tool"
      exit 1
    fi
  done
  verbose "Required tools: OK"
}

preflight

# ════════════════════════════════════════════
# Resolve and validate modules
# ════════════════════════════════════════════

if [[ "$MODE" == "specific" ]]; then
  resolve_modules specific "${MODULES[@]}"
else
  resolve_modules "$MODE"
fi

# Validate all modules
for mod in "${RESOLVED_MODULES[@]}"; do
  validate_module "$mod"
done

# ════════════════════════════════════════════
# Create common directories
# ════════════════════════════════════════════

if ! dry_run "Would create ~/.config and ~/workspace"; then
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/workspace"
fi

# ════════════════════════════════════════════
# Export environment for subshell module scripts
# ════════════════════════════════════════════

export DOTFILES_DIR DRY_RUN VERBOSE FORCE BACKUP_DIR

# ════════════════════════════════════════════
# Install modules
# ════════════════════════════════════════════

log_info "Installing modules: ${RESOLVED_MODULES[*]}"
if [[ "$DRY_RUN" == "true" ]]; then
  log_warn "Dry-run mode — no changes will be made"
fi
echo ""

failed_modules=()

for mod in "${RESOLVED_MODULES[@]}"; do
  if bash "$DOTFILES_DIR/$mod/install.sh"; then
    verbose "Module '$mod' completed"
  else
    log_error "Module '$mod' failed"
    failed_modules+=("$mod")
  fi
done

# ════════════════════════════════════════════
# Summary
# ════════════════════════════════════════════

echo ""
if [[ ${#failed_modules[@]} -gt 0 ]]; then
  log_error "Failed modules: ${failed_modules[*]}"
  exit 1
else
  log_ok "All modules installed successfully"
fi

if [[ "$DRY_RUN" != "true" ]]; then
  echo ""
  log_info "Next steps:"
  echo "  1. Restart your shell: exec zsh"
  echo "  2. Open tmux and press Ctrl+a I to install plugins"
  echo "  3. Open Neovim — plugins will auto-install"
fi
