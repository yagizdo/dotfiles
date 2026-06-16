#!/bin/bash
# Module: claude — Install Claude Code CLI, settings, plugins, marketplaces, and powerline.
#
# Modes:
#   sync  (default) — install/update settings + plugins idempotently
#   fresh (FRESH=true) — wipe ~/.claude/{settings.json,claude-powerline.json},
#                         uninstall all plugins, remove marketplaces, reinstall
#                         Claude CLI cask and claude-powerline npm package
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "Claude Code"

# ════════════════════════════════════════════
# Configuration
# ════════════════════════════════════════════

CLAUDE_SOURCE_DIR="$DOTFILES_DIR/.claude"
CLAUDE_TARGET_DIR="$HOME/.claude"
SETTINGS_FILES=(settings.json claude-powerline.json)

MARKETPLACES=(
  "anthropics/claude-plugins-official"
  "https://github.com/kieranklaassen/compound-engineering-plugin.git"
  "conorluddy/xclaude-plugin"
  "kepano/obsidian-skills"
  "nextlevelbuilder/ui-ux-pro-max-skill"
  "yagizdo/quiver"
  "JuliusBrussee/caveman"
)

PLUGINS=(
  "compound-engineering@every-marketplace"
  "superpowers@claude-plugins-official"
  "swift-lsp@claude-plugins-official"
  "obsidian@obsidian-skills"
  "ui-ux-pro-max@ui-ux-pro-max-skill"
  "xclaude-plugin@xclaude-plugin-marketplace"
  "quiver@quiver"
  "caveman@caveman"
)

# ════════════════════════════════════════════
# Detect Claude CLI
# ════════════════════════════════════════════

find_claude_cmd() {
  if command -v claude &>/dev/null; then echo "claude"; return; fi
  [[ -x "$HOME/.claude/bin/claude" ]] && { echo "$HOME/.claude/bin/claude"; return; }
  [[ -x "$HOME/.local/bin/claude" ]] && { echo "$HOME/.local/bin/claude"; return; }
  [[ -x /usr/local/bin/claude ]] && { echo /usr/local/bin/claude; return; }
  echo ""
}

# ════════════════════════════════════════════
# Fresh: wipe everything
# ════════════════════════════════════════════

fresh_reset() {
  log_fresh "Resetting Claude Code state"

  # Remove our settings symlinks/files
  for f in "${SETTINGS_FILES[@]}"; do
    remove_path "$CLAUDE_TARGET_DIR/$f"
  done

  local claude_cmd
  claude_cmd="$(find_claude_cmd)"

  # Uninstall plugins (best-effort; CLI may not be installed yet)
  if [[ -n "$claude_cmd" ]] && ! dry_run "Would uninstall all Claude plugins"; then
    for plugin in "${PLUGINS[@]}"; do
      local name="${plugin%@*}"
      log_fresh "Uninstalling plugin $name..."
      "$claude_cmd" plugin uninstall "$plugin" &>/dev/null || true
    done

    # Remove marketplaces
    for mp in "${MARKETPLACES[@]}"; do
      log_fresh "Removing marketplace $mp..."
      "$claude_cmd" plugin marketplace remove "$mp" &>/dev/null || true
    done
  fi

  # Reinstall Claude Code CLI
  if is_macos; then
    if command -v brew &>/dev/null; then
      brew_reinstall cask "claude-code@latest"
    fi
  else
    install_claude_native
  fi

  # Reinstall claude-powerline npm package
  npm_reinstall_global "@owloops/claude-powerline"
}

# ════════════════════════════════════════════
# Sync: install settings, marketplaces, plugins
# ════════════════════════════════════════════

install_claude_native() {
  if ! command -v npm &>/dev/null; then
    log_info "npm not found, installing nodejs and npm via pacman..."
    pacman_install "nodejs"
    pacman_install "npm"
  fi

  # Bootstrap via npm if claude is not available at all
  if [[ -z "$(find_claude_cmd)" ]]; then
    if command -v npm &>/dev/null; then
      log_info "Bootstrapping Claude Code via npm..."
      sudo npm install -g @anthropic-ai/claude-code
    else
      log_warn "npm still not found. Install Node.js first, then re-run."
      return 1
    fi
  fi

  local claude_cmd
  claude_cmd="$(find_claude_cmd)"
  if [[ -z "$claude_cmd" ]]; then
    log_warn "Claude CLI not available after bootstrap."
    return 1
  fi

  log_info "Installing Claude Code native build..."
  if "$claude_cmd" install --force; then
    log_ok "Claude Code native build installed"
    # Remove npm version if native install succeeded
    if npm list -g @anthropic-ai/claude-code &>/dev/null 2>&1; then
      log_info "Removing npm bootstrap package..."
      sudo npm uninstall -g @anthropic-ai/claude-code || true
    fi
  else
    log_warn "Native install failed — keeping npm version"
  fi
}

ensure_claude_cli() {
  if [[ -n "$(find_claude_cmd)" ]]; then
    return 0
  fi
  if dry_run "Would install Claude Code CLI"; then return 0; fi

  if is_macos; then
    if command -v brew &>/dev/null; then
      log_info "Installing Claude Code CLI (brew)..."
      brew install --cask claude-code@latest
      log_ok "Claude Code CLI installed"
    else
      log_warn "Homebrew not found. Install Claude Code manually."
      return 1
    fi
  else
    install_claude_native
  fi
}

ensure_powerline() {
  if ! command -v npm &>/dev/null; then
    log_warn "npm not found — claude-powerline statusline will not render"
    return 0
  fi

  if npm list -g @owloops/claude-powerline &>/dev/null; then
    log_ok "@owloops/claude-powerline already installed"
    return 0
  fi

  if dry_run "Would npm install -g @owloops/claude-powerline"; then
    return 0
  fi

  local sudo_prefix=""
  if is_linux; then sudo_prefix="sudo"; fi

  log_info "Installing @owloops/claude-powerline..."
  if $sudo_prefix npm install -g @owloops/claude-powerline &>/dev/null; then
    log_ok "claude-powerline installed"
  else
    log_warn "claude-powerline install failed — statusline will not render"
  fi
}

install_settings() {
  mkdir -p "$CLAUDE_TARGET_DIR"
  for f in "${SETTINGS_FILES[@]}"; do
    if [[ -f "$CLAUDE_SOURCE_DIR/$f" ]]; then
      link_file "$CLAUDE_SOURCE_DIR/$f" "$CLAUDE_TARGET_DIR/$f"
    else
      log_skip "$f (source not found)"
    fi
  done
}

install_marketplaces_and_plugins() {
  local claude_cmd
  claude_cmd="$(find_claude_cmd)"
  if [[ -z "$claude_cmd" ]]; then
    log_warn "Claude CLI not available — skipping plugins/marketplaces"
    return 0
  fi

  if dry_run "Would add marketplaces and install plugins"; then
    return 0
  fi

  local current_mp
  current_mp="$("$claude_cmd" plugin marketplace list 2>&1 || true)"

  for mp in "${MARKETPLACES[@]}"; do
    local label="$mp"
    if echo "$current_mp" | grep -q "$mp" 2>/dev/null; then
      log_ok "marketplace $label (already added)"
    else
      if "$claude_cmd" plugin marketplace add "$mp" &>/dev/null; then
        log_ok "marketplace $label added"
      else
        log_warn "marketplace $label failed (may already exist)"
      fi
    fi
  done

  local current_plugins
  current_plugins="$("$claude_cmd" plugin list 2>&1 || true)"

  for plugin in "${PLUGINS[@]}"; do
    local name="${plugin%@*}"
    if echo "$current_plugins" | grep -q "$plugin" 2>/dev/null; then
      log_ok "plugin $name (already installed)"
    else
      if "$claude_cmd" plugin install "$plugin" &>/dev/null; then
        log_ok "plugin $name installed"
      else
        log_warn "plugin $name failed"
      fi
    fi
  done
}

# ════════════════════════════════════════════
# Run
# ════════════════════════════════════════════

if is_fresh; then
  fresh_reset
fi

ensure_claude_cli
install_settings
install_marketplaces_and_plugins
ensure_powerline

if [[ "$DRY_RUN" != "true" ]] && is_fresh; then
  echo ""
  log_info "Restart Claude Code to apply all changes."
fi
