#!/bin/bash
# Module: fvm — Install FVM and configure editor SDK paths
#
# fresh: brew uninstalls + reinstalls fvm, removes dart.flutterSdkPath from
#        editor settings before re-adding it.
#        Note: ~/fvm (installed Flutter versions) is preserved — fvm reinstall
#        does not delete cached SDKs.
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "FVM (Flutter Version Management)"

# ════════════════════════════════════════════
# Install FVM
# ════════════════════════════════════════════

if is_fresh; then
  if is_macos; then
    brew_reinstall formula "leoafarias/fvm/fvm"
  else
    log_skip "FVM fresh reinstall not supported on Linux"
  fi
elif ! command -v fvm &>/dev/null; then
  if is_macos; then
    if dry_run "Would install fvm via Homebrew"; then :; else
      log_info "Installing FVM..."
      brew install fvm
      log_ok "FVM installed"
    fi
  else
    log_warn "FVM not found. Install manually: https://fvm.app/documentation/getting-started/installation"
  fi
else
  log_ok "FVM already installed ($(fvm --version))"
fi

# ════════════════════════════════════════════
# Editor SDK path
# ════════════════════════════════════════════

# Use FVM global default symlink for editor-wide settings.
# Per-project .fvm/flutter_sdk overrides this automatically.
FVM_SDK_PATH="$HOME/fvm/default"

setup_editor_fvm() {
  local editor_name="$1"
  local settings_file="$2"

  if [[ ! -f "$settings_file" ]]; then
    verbose "No $editor_name settings.json found, skipping"
    return 0
  fi

  if grep -q '"dart.flutterSdkPath"' "$settings_file" 2>/dev/null; then
    if is_fresh; then
      if dry_run "Would remove dart.flutterSdkPath from $editor_name"; then
        return 0
      fi
      # Remove existing dart.flutterSdkPath line; trailing comma cleanup
      sed_inplace '/"dart.flutterSdkPath"/d' "$settings_file"
      # Cleanup dangling commas before closing brace
      sed_inplace -e ':a' -e '$!{N;ba' -e '}' -e 's/,\s*}/}/g' "$settings_file"
      log_fresh "$editor_name: removed dart.flutterSdkPath"
    else
      log_ok "$editor_name: dart.flutterSdkPath already configured"
      return 0
    fi
  fi

  if dry_run "Would add dart.flutterSdkPath to $editor_name settings"; then
    return 0
  fi

  # Insert dart.flutterSdkPath before the last closing brace
  local tmp
  tmp=$(mktemp)
  sed '$ s/}$//' "$settings_file" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "$tmp"
  local last_line
  last_line=$(grep -v '^\s*$' "$tmp" | tail -1)
  if [[ "$last_line" != *"," ]] && [[ "$last_line" != *"{" ]]; then
    sed_inplace '$ s/$/,/' "$tmp"
  fi
  cat >> "$tmp" <<EOF
  "dart.flutterSdkPath": "$FVM_SDK_PATH"
}
EOF
  mv "$tmp" "$settings_file"
  log_ok "$editor_name: dart.flutterSdkPath -> $FVM_SDK_PATH"
}

setup_editor_fvm "VS Code" "$DOTFILES_DIR/vscode/settings.json"

# ════════════════════════════════════════════
# Usage info
# ════════════════════════════════════════════

if [[ "$DRY_RUN" != "true" ]]; then
  echo ""
  log_info "Add to project .gitignore:  .fvm/flutter_sdk  .fvm/versions"
  log_info "FVM usage:"
  echo "  fvm install stable        # install latest stable Flutter"
  echo "  fvm global stable         # set global Flutter version"
  echo "  fvm use stable            # set project Flutter version"
fi
