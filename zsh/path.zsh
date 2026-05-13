# Function to add to PATH without duplicates
add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# FVM Flutter (MUST be first for fvm to work)
add_to_path "$HOME/fvm/default/bin"

# Antigravity
add_to_path "$HOME/.antigravity/antigravity/bin"

# Shorebird (Flutter code push)
add_to_path "$HOME/.shorebird/bin"

# Pub cache (Dart global packages)
export PATH="$PATH:$HOME/.pub-cache/bin"

# Ruby (macOS Homebrew)
if [[ "$(uname -s)" == "Darwin" ]]; then
  add_to_path "/opt/homebrew/opt/ruby/bin"
fi

# Android SDK
if [[ "$(uname -s)" == "Darwin" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
else
  export ANDROID_HOME="$HOME/Android/Sdk"
fi
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/platform-tools"
