#!/bin/bash
# Module: fvm — Install FVM and configure editor/global settings
set -eo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

log_header "FVM (Flutter Version Management)"

# ════════════════════════════════════════════
# Install FVM via Homebrew
# ════════════════════════════════════════════

if ! command -v fvm &>/dev/null; then
  if dry_run "Would install fvm via Homebrew"; then
    :
  else
    log_info "Installing FVM..."
    brew install fvm
    log_ok "FVM installed"
  fi
else
  log_ok "FVM already installed ($(fvm --version))"
fi

# ════════════════════════════════════════════
# Editor SDK path (VS Code + Antigravity)
# ════════════════════════════════════════════

# Use FVM global default symlink for editor-wide settings
# Per-project .fvm/flutter_sdk overrides this automatically
FVM_SDK_PATH="$HOME/fvm/default"

setup_editor_fvm() {
  local editor_name="$1"
  local settings_file="$2"

  if [[ ! -f "$settings_file" ]]; then
    verbose "No $editor_name settings.json found, skipping"
    return 0
  fi

  if grep -q '"dart.flutterSdkPath"' "$settings_file" 2>/dev/null; then
    log_ok "$editor_name: dart.flutterSdkPath already configured"
    return 0
  fi

  if dry_run "Would add dart.flutterSdkPath to $editor_name settings"; then
    return 0
  fi

  # Insert dart.flutterSdkPath before the last closing brace
  local tmp
  tmp=$(mktemp)
  sed '$ s/}$//' "$settings_file" | sed -e :a -e '/^\n*$/{$d;N;ba}' > "$tmp"
  # Add comma if needed
  local last_line
  last_line=$(grep -v '^\s*$' "$tmp" | tail -1)
  if [[ "$last_line" != *"," ]] && [[ "$last_line" != *"{" ]]; then
    sed -i '' '$ s/$/,/' "$tmp"
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
# .gitignore recommendation
# ════════════════════════════════════════════

log_info "Remember to add these to project .gitignore:"
echo "  .fvm/flutter_sdk"
echo "  .fvm/versions"

# ════════════════════════════════════════════
# Usage info
# ════════════════════════════════════════════

if [[ "$DRY_RUN" != "true" ]]; then
  echo ""
  log_info "FVM usage:"
  echo "  fvm install stable        # install latest stable Flutter"
  echo "  fvm global stable         # set global Flutter version"
  echo "  fvm use stable            # set project Flutter version"
  echo "  fvm list                  # list installed versions"
fi
