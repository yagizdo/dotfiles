#!/bin/bash
# Module registry for dotfiles installer
# Sourced by bootstrap.sh
# Compatible with Bash 3.2+ (macOS default)

# ════════════════════════════════════════════
# Module definitions
# ════════════════════════════════════════════

CORE_MODULES=(homebrew zsh git)
ALL_MODULES=(homebrew zsh git oh-my-posh vscode ssh claude ghostty zellij antigravity fvm)

# Module descriptions via function (Bash 3.2 has no associative arrays)
module_desc() {
  case "$1" in
    homebrew)   echo "Homebrew package manager and Brewfile" ;;
    zsh)        echo "ZSH config with Zinit plugins" ;;
    git)        echo "Git config and global gitignore" ;;
    oh-my-posh) echo "Oh My Posh prompt theme" ;;
    vscode)     echo "VS Code settings" ;;
    ssh)        echo "SSH key setup (interactive)" ;;
    claude)     echo "Claude Code settings" ;;
    ghostty)    echo "Ghostty terminal config" ;;
    zellij)     echo "Zellij multiplexer config" ;;
    antigravity) echo "Antigravity (VS Code fork) settings" ;;
    fvm)        echo "FVM (Flutter Version Management) + editor config" ;;
    *)          echo "" ;;
  esac
}

# ════════════════════════════════════════════
# Functions
# ════════════════════════════════════════════

validate_module() {
  local name="$1"
  if [[ ! -f "$DOTFILES_DIR/$name/install.sh" ]]; then
    log_error "Unknown module: '$name' (no $name/install.sh found)"
    log_info "Available modules: ${ALL_MODULES[*]}"
    return 1
  fi
}

# shellcheck disable=SC2034  # RESOLVED_MODULES is used by bootstrap.sh
resolve_modules() {
  local mode="$1"
  shift

  RESOLVED_MODULES=()
  case "$mode" in
    core)
      RESOLVED_MODULES=("${CORE_MODULES[@]}")
      ;;
    all)
      RESOLVED_MODULES=("${ALL_MODULES[@]}")
      ;;
    specific)
      RESOLVED_MODULES=("$@")
      ;;
    *)
      log_error "Unknown resolve mode: $mode"
      return 1
      ;;
  esac
}

list_modules() {
  printf '%b%s%b\n\n' "$BOLD" "Available modules:" "$NC"
  for mod in "${ALL_MODULES[@]}"; do
    local label=""
    for core in "${CORE_MODULES[@]}"; do
      if [[ "$mod" == "$core" ]]; then
        label=" [core]"
        break
      fi
    done
    printf "  %-12s %s%s\n" "$mod" "$(module_desc "$mod")" "$label"
  done
  echo ""
}
