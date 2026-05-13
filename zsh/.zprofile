# Homebrew shell init (macOS only)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# Swiftly (if installed)
[[ -f "$HOME/.swiftly/env.sh" ]] && . "$HOME/.swiftly/env.sh"
