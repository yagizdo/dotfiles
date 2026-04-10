#!/bin/bash
# Shared utility functions for dotfiles installer
# Sourced by bootstrap.sh and per-module install scripts

# ════════════════════════════════════════════
# Dotfiles directory detection
# ════════════════════════════════════════════

# When sourced from lib/, go up one level
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# ════════════════════════════════════════════
# Color constants (respects NO_COLOR and non-TTY)
# ════════════════════════════════════════════

if [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  BOLD=''
  NC=''
fi

# ════════════════════════════════════════════
# Backup directory (single dir per run)
# ════════════════════════════════════════════

BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)}"

# ════════════════════════════════════════════
# Logging functions
# ════════════════════════════════════════════

log_info()   { printf '%b[INFO]%b %s\n' "$BLUE" "$NC" "$*"; }
log_ok()     { printf '%b[OK]%b   %s\n' "$GREEN" "$NC" "$*"; }
log_warn()   { printf '%b[WARN]%b %s\n' "$YELLOW" "$NC" "$*"; }
log_error()  { printf '%b[ERR]%b  %s\n' "$RED" "$NC" "$*" >&2; }
log_skip()   { printf '%b[SKIP]%b %s\n' "$YELLOW" "$NC" "$*"; }
log_header() { printf '\n%b══ %s ══%b\n\n' "$BOLD" "$*" "$NC"; }

# ════════════════════════════════════════════
# Dry-run support
# ════════════════════════════════════════════

DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"

dry_run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    printf '%b[DRY-RUN]%b %s\n' "$YELLOW" "$NC" "$*"
    return 0
  fi
  return 1
}

verbose() {
  if [[ "$VERBOSE" == "true" ]]; then
    printf '%b[VERBOSE]%b %s\n' "$BLUE" "$NC" "$*"
  fi
}

# ════════════════════════════════════════════
# link_file — idempotent symlink with backup
# ════════════════════════════════════════════

link_file() {
  local src="$1" dest="$2"

  # Validate source exists
  if [[ ! -e "$src" ]]; then
    log_error "Source does not exist: $src"
    return 1
  fi

  # Already correctly linked
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    log_ok "$dest -> $src (already linked)"
    return 0
  fi

  if dry_run "Would link $dest -> $src"; then
    return 0
  fi

  # Backup existing file/dir (not symlinks) unless --force
  if [[ -e "$dest" ]] && [[ ! -L "$dest" ]]; then
    if [[ "$FORCE" == "true" ]]; then
      verbose "Removing existing $dest (--force)"
      rm -rf "$dest"
    else
      mkdir -p "$BACKUP_DIR"
      mv "$dest" "$BACKUP_DIR/"
      log_warn "Backed up $dest -> $BACKUP_DIR/"
    fi
  elif [[ -L "$dest" ]]; then
    # Remove stale symlink
    rm "$dest"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dest")"

  # Use -sfn for directory symlinks on macOS
  ln -sfn "$src" "$dest"
  log_ok "$dest -> $src"
}

# ════════════════════════════════════════════
# verify_symlink — post-install check
# ════════════════════════════════════════════

verify_symlink() {
  local target="$1" label="${2:-$1}"
  if [[ -L "$target" ]]; then
    log_ok "$label -> $(readlink "$target")"
    return 0
  else
    log_error "$label (NOT LINKED)"
    return 1
  fi
}
