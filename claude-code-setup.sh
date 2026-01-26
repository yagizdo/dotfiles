#!/bin/bash
# Claude Code Settings Import Script
# Safe import - backs up existing, never deletes
#
# This script:
# 1. Installs settings files (symlink or copy)
# 2. Adds required marketplaces
# 3. Installs required plugins
# 4. Installs claude-powerline for status line
#
# Usage:
#   ./claude-code-setup.sh           # Symlink mode (default)
#   ./claude-code-setup.sh --symlink # Symlink mode
#   ./claude-code-setup.sh -s        # Symlink mode
#   ./claude-code-setup.sh --copy    # Copy mode
#   ./claude-code-setup.sh -c        # Copy mode

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MARKETPLACES=(
  "anthropics/claude-plugins-official"
  "https://github.com/kieranklaassen/compound-engineering-plugin.git"
)

PLUGINS=(
  "context7@claude-plugins-official"
  "compound-engineering@every-marketplace"
)

# Parse arguments
MODE="symlink"
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--symlink)
      MODE="symlink"
      shift
      ;;
    -c|--copy)
      MODE="copy"
      shift
      ;;
    -h|--help)
      echo "Claude Code Settings Import Script"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -s, --symlink  Symlink mode (default) - creates symlinks to dotfiles"
      echo "  -c, --copy     Copy mode - copies files from dotfiles"
      echo "  -h, --help     Show this help message"
      echo ""
      echo "This script will:"
      echo "  1. Install settings files (~/.claude/settings*.json)"
      echo "  2. Add required marketplaces (claude-plugins-official, every-marketplace)"
      echo "  3. Install plugins (context7, compound-engineering)"
      echo "  4. Install claude-powerline for status line theme"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Detect dotfiles directory from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
CLAUDE_SOURCE_DIR="$DOTFILES_DIR/.claude"
CLAUDE_TARGET_DIR="$HOME/.claude"

# Settings files to install
SETTINGS_FILES=("settings.json" "settings.local.json")

echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo -e "${BLUE}   Claude Code Settings Import${NC}"
echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo -e "Mode: ${GREEN}$MODE${NC}"
echo ""

actions_taken=()

# ════════════════════════════════════════════════════════════════
# Step 1: Check prerequisites
# ════════════════════════════════════════════════════════════════
echo -e "${BLUE}[1/4] Checking prerequisites...${NC}"
echo ""

# Check if Claude Code is installed
echo -n "  Claude Code CLI... "
if command -v claude &> /dev/null; then
  CLAUDE_CMD="claude"
  echo -e "${GREEN}found${NC}"
elif [ -f "/usr/local/bin/claude" ]; then
  CLAUDE_CMD="/usr/local/bin/claude"
  echo -e "${GREEN}found${NC}"
elif [ -f "$HOME/.local/bin/claude" ]; then
  CLAUDE_CMD="$HOME/.local/bin/claude"
  echo -e "${GREEN}found${NC}"
else
  echo -e "${RED}not found${NC}"
  echo -e "${RED}Error: Claude Code CLI is required. Install it first:${NC}"
  echo -e "${RED}  npm install -g @anthropic-ai/claude-code${NC}"
  exit 1
fi

# Check if npm is installed
echo -n "  npm... "
if command -v npm &> /dev/null; then
  echo -e "${GREEN}found${NC}"
else
  echo -e "${RED}not found${NC}"
  echo -e "${RED}Error: npm is required for installing claude-powerline.${NC}"
  exit 1
fi

# Check if source files exist
echo -n "  Source files... "
if [ ! -d "$CLAUDE_SOURCE_DIR" ]; then
  echo -e "${RED}failed${NC}"
  echo -e "${RED}Error: Source directory not found: $CLAUDE_SOURCE_DIR${NC}"
  exit 1
fi

missing_files=()
for file in "${SETTINGS_FILES[@]}"; do
  if [ ! -f "$CLAUDE_SOURCE_DIR/$file" ]; then
    missing_files+=("$file")
  fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
  echo -e "${YELLOW}warning (missing: ${missing_files[*]})${NC}"
else
  echo -e "${GREEN}ok${NC}"
fi

# ════════════════════════════════════════════════════════════════
# Step 2: Install settings files
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}[2/4] Installing settings files...${NC}"
echo ""

# Create target directory if it doesn't exist
if [ ! -d "$CLAUDE_TARGET_DIR" ]; then
  echo -n "  Creating $CLAUDE_TARGET_DIR... "
  mkdir -p "$CLAUDE_TARGET_DIR"
  echo -e "${GREEN}done${NC}"
fi

# Backup function
backup_file() {
  local file="$1"
  local backup_dir="$CLAUDE_TARGET_DIR/backup"
  local timestamp=$(date +%Y%m%d_%H%M%S)

  if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
  fi

  local backup_path="$backup_dir/${file}.${timestamp}"
  cp "$CLAUDE_TARGET_DIR/$file" "$backup_path"
  echo "$backup_path"
}

# Check if a symlink points to our dotfiles
is_our_symlink() {
  local target_file="$1"
  local source_file="$2"

  if [ -L "$target_file" ]; then
    local link_target=$(readlink "$target_file")
    if [ "$link_target" = "$source_file" ]; then
      return 0
    fi
  fi
  return 1
}

for file in "${SETTINGS_FILES[@]}"; do
  source_file="$CLAUDE_SOURCE_DIR/$file"
  target_file="$CLAUDE_TARGET_DIR/$file"

  # Skip if source doesn't exist
  if [ ! -f "$source_file" ]; then
    echo -e "  ${YELLOW}⊘${NC} $file - source not found, skipping"
    continue
  fi

  # Check if already correctly symlinked (symlink mode only)
  if [ "$MODE" = "symlink" ] && is_our_symlink "$target_file" "$source_file"; then
    echo -e "  ${GREEN}✓${NC} $file - already symlinked correctly"
    continue
  fi

  # Backup existing file if it exists and is not our symlink
  if [ -e "$target_file" ] || [ -L "$target_file" ]; then
    if [ -L "$target_file" ]; then
      # It's a symlink but not ours, remove it
      echo -n "  Removing old symlink for $file... "
      rm "$target_file"
      echo -e "${GREEN}done${NC}"
      actions_taken+=("Removed old symlink: $file")
    else
      # It's a regular file, back it up
      echo -n "  Backing up existing $file... "
      backup_path=$(backup_file "$file")
      rm "$target_file"
      echo -e "${GREEN}done${NC}"
      echo -e "    Backup saved to: ${BLUE}$backup_path${NC}"
      actions_taken+=("Backed up: $file → $backup_path")
    fi
  fi

  # Install the file
  if [ "$MODE" = "symlink" ]; then
    echo -n "  Symlinking $file... "
    ln -sf "$source_file" "$target_file"
    echo -e "${GREEN}done${NC}"
    actions_taken+=("Symlinked: $file")
  else
    echo -n "  Copying $file... "
    cp "$source_file" "$target_file"
    echo -e "${GREEN}done${NC}"
    actions_taken+=("Copied: $file")
  fi
done

# ════════════════════════════════════════════════════════════════
# Step 3: Add marketplaces and install plugins
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}[3/4] Setting up marketplaces and plugins...${NC}"
echo ""

# Get current marketplaces
current_marketplaces=$($CLAUDE_CMD plugin marketplace list 2>&1 || true)

# Add marketplaces
for marketplace in "${MARKETPLACES[@]}"; do
  # Extract marketplace name for display
  if [[ "$marketplace" == *"/"* ]] && [[ "$marketplace" != http* ]]; then
    marketplace_name=$(echo "$marketplace" | cut -d'/' -f2)
  elif [[ "$marketplace" == *".git" ]]; then
    marketplace_name=$(basename "$marketplace" .git)
  else
    marketplace_name="$marketplace"
  fi

  echo -n "  Adding marketplace: $marketplace_name... "

  # Check if already added (by checking the source in the list)
  if echo "$current_marketplaces" | grep -q "$marketplace" 2>/dev/null; then
    echo -e "${GREEN}already added${NC}"
  else
    if $CLAUDE_CMD plugin marketplace add "$marketplace" &>/dev/null; then
      echo -e "${GREEN}done${NC}"
      actions_taken+=("Added marketplace: $marketplace_name")
    else
      echo -e "${YELLOW}failed (may already exist)${NC}"
    fi
  fi
done

# Get current plugins
current_plugins=$($CLAUDE_CMD plugin list 2>&1 || true)

# Install plugins
for plugin in "${PLUGINS[@]}"; do
  plugin_name=$(echo "$plugin" | cut -d'@' -f1)

  echo -n "  Installing plugin: $plugin_name... "

  # Check if already installed
  if echo "$current_plugins" | grep -q "$plugin" 2>/dev/null; then
    echo -e "${GREEN}already installed${NC}"
  else
    if $CLAUDE_CMD plugin install "$plugin" &>/dev/null; then
      echo -e "${GREEN}done${NC}"
      actions_taken+=("Installed plugin: $plugin_name")
    else
      echo -e "${YELLOW}failed${NC}"
    fi
  fi
done

# Enable plugins (in case they're disabled)
for plugin in "${PLUGINS[@]}"; do
  plugin_name=$(echo "$plugin" | cut -d'@' -f1)

  # Check if plugin is disabled
  if echo "$current_plugins" | grep -q "$plugin" | grep -q "disabled" 2>/dev/null; then
    echo -n "  Enabling plugin: $plugin_name... "
    if $CLAUDE_CMD plugin enable "$plugin" &>/dev/null; then
      echo -e "${GREEN}done${NC}"
      actions_taken+=("Enabled plugin: $plugin_name")
    fi
  fi
done

# ════════════════════════════════════════════════════════════════
# Step 4: Install claude-powerline
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}[4/4] Installing claude-powerline...${NC}"
echo ""

echo -n "  Installing @owloops/claude-powerline globally... "

# Check if already installed
if npm list -g @owloops/claude-powerline &>/dev/null; then
  echo -e "${GREEN}already installed${NC}"
else
  if npm install -g @owloops/claude-powerline &>/dev/null; then
    echo -e "${GREEN}done${NC}"
    actions_taken+=("Installed: @owloops/claude-powerline")
  else
    echo -e "${YELLOW}failed (will use npx fallback)${NC}"
    echo -e "    ${YELLOW}Note: Status line will work via npx but may be slower${NC}"
  fi
fi

# ════════════════════════════════════════════════════════════════
# Summary
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}   Setup Complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""

if [ ${#actions_taken[@]} -gt 0 ]; then
  echo "Actions taken:"
  for action in "${actions_taken[@]}"; do
    echo "  • $action"
  done
else
  echo "No changes were necessary - everything was already configured."
fi

echo ""
echo "Installed configuration:"
echo "  • Settings: ~/.claude/settings.json"
echo "  • Local settings: ~/.claude/settings.local.json"
echo "  • Marketplaces: claude-plugins-official, every-marketplace"
echo "  • Plugins: context7, compound-engineering"
echo "  • Status line: rose-pine powerline theme"
echo ""
echo -e "${BLUE}Restart Claude Code to apply all changes.${NC}"
