# Function to add to PATH without duplicates
add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# FVM Flutter (MUST be first for fvm to work)
add_to_path "$HOME/fvm/default/bin"

# Local bin
add_to_path "$HOME/.local/bin"

# Node
add_to_path "$HOME/.node/bin"

# Go
add_to_path "$HOME/go/bin"

# Pub cache (Dart global packages)
add_to_path "$HOME/.pub-cache/bin"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/platform-tools"
