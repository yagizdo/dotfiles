#!/bin/bash
# Shared utility functions for dotfiles installer
# Sourced by setup and per-module install scripts

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
log_fresh()  { printf '%b[FRESH]%b %s\n' "$YELLOW" "$NC" "$*"; }
log_header() { printf '\n%b══ %s ══%b\n\n' "$BOLD" "$*" "$NC"; }

# ════════════════════════════════════════════
# Mode flags
# ════════════════════════════════════════════

DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"
COPY_MODE="${COPY_MODE:-false}"
FRESH="${FRESH:-false}"

# ════════════════════════════════════════════
# OS detection (evaluated once at source time)
# ════════════════════════════════════════════

OS_KERNEL="$(uname -s)"
OS_DISTRO=""
if [[ "$OS_KERNEL" == "Linux" ]] && [[ -f /etc/os-release ]]; then
  OS_DISTRO="$(. /etc/os-release && echo "$ID")"
fi
export OS_KERNEL OS_DISTRO

is_macos() { [[ "$OS_KERNEL" == "Darwin" ]]; }
is_linux() { [[ "$OS_KERNEL" == "Linux" ]]; }

sed_inplace() {
  if is_macos; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

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

is_fresh() { [[ "$FRESH" == "true" ]]; }

# ════════════════════════════════════════════
# link_file — idempotent symlink with backup
# ════════════════════════════════════════════

link_file() {
  local src="$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    log_error "Source does not exist: $src"
    return 1
  fi

  # Already correctly linked (skip check in copy mode — we want to replace the symlink)
  if [[ "$COPY_MODE" != "true" ]] && [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    log_ok "$dest -> $src (already linked)"
    return 0
  fi

  if [[ "$COPY_MODE" == "true" ]]; then
    if dry_run "Would copy $src -> $dest"; then
      return 0
    fi
  else
    if dry_run "Would link $dest -> $src"; then
      return 0
    fi
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
    rm "$dest"
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ "$COPY_MODE" == "true" ]]; then
    cp -R "$src" "$dest"
    log_ok "$dest (copied from $src)"
  else
    ln -sfn "$src" "$dest"
    log_ok "$dest -> $src"
  fi
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

# ════════════════════════════════════════════
# Fresh-mode helpers
# ════════════════════════════════════════════

# remove_path — delete file/symlink/directory if it exists
# Used by --fresh to wipe old configs before reinstalling.
remove_path() {
  local path="$1"
  if [[ -L "$path" ]] || [[ -e "$path" ]]; then
    if dry_run "Would remove $path"; then
      return 0
    fi
    rm -rf "$path"
    log_fresh "Removed $path"
  fi
}

# brew_reinstall — uninstall+reinstall a brew formula or cask
# Args: <formula|cask> <name>
brew_reinstall() {
  local kind="$1" name="$2"
  if ! command -v brew &>/dev/null; then
    log_warn "brew not found, cannot reinstall $name"
    return 0
  fi

  if dry_run "Would reinstall $kind $name"; then
    return 0
  fi

  case "$kind" in
    formula)
      if brew list --formula "$name" &>/dev/null; then
        log_fresh "Uninstalling $name..."
        brew uninstall --ignore-dependencies "$name" || true
      fi
      log_info "Installing $name..."
      brew install "$name"
      ;;
    cask)
      if brew list --cask "$name" &>/dev/null; then
        log_fresh "Uninstalling cask $name..."
        brew uninstall --cask "$name" || true
      fi
      log_info "Installing cask $name..."
      brew install --cask "$name"
      ;;
    *)
      log_error "Unknown brew kind: $kind"
      return 1
      ;;
  esac
}

# ════════════════════════════════════════════
# Pacman helpers (Linux)
# ════════════════════════════════════════════

pacman_install() {
  local pkg="$1"
  if ! command -v pacman &>/dev/null; then
    log_warn "pacman not found, cannot install $pkg"
    return 0
  fi
  if dry_run "Would pacman install $pkg"; then return 0; fi
  if pacman -Qi "$pkg" &>/dev/null; then
    log_ok "$pkg already installed"
    return 0
  fi
  log_info "Installing $pkg..."
  sudo pacman -S --needed --noconfirm "$pkg"
}

pacman_reinstall() {
  local pkg="$1"
  if ! command -v pacman &>/dev/null; then
    log_warn "pacman not found, cannot reinstall $pkg"
    return 0
  fi
  if dry_run "Would reinstall $pkg via pacman"; then return 0; fi
  log_fresh "Reinstalling $pkg..."
  sudo pacman -S --noconfirm "$pkg"
}

# npm_reinstall_global — uninstall+reinstall a global npm package
npm_reinstall_global() {
  local pkg="$1"
  if ! command -v npm &>/dev/null; then
    log_warn "npm not found, cannot reinstall $pkg"
    return 0
  fi

  if dry_run "Would reinstall global npm package $pkg"; then
    return 0
  fi

  local sudo_prefix=""
  if is_linux; then sudo_prefix="sudo"; fi

  if npm list -g "$pkg" &>/dev/null; then
    log_fresh "Uninstalling global npm $pkg..."
    $sudo_prefix npm uninstall -g "$pkg" || true
  fi
  log_info "Installing global npm $pkg..."
  $sudo_prefix npm install -g "$pkg"
}
