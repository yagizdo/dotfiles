#!/bin/bash
# Claude Code Settings Import Script
# Safe import - backs up existing, never deletes
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

echo -e "${BLUE}Claude Code Settings Import${NC}"
echo -e "Mode: ${GREEN}$MODE${NC}"
echo ""

# Check if Claude Code is installed
echo -n "Checking for Claude Code... "
if command -v claude &> /dev/null; then
  echo -e "${GREEN}found${NC}"
elif [ -f "/usr/local/bin/claude" ] || [ -f "$HOME/.local/bin/claude" ]; then
  echo -e "${GREEN}found${NC}"
else
  echo -e "${YELLOW}not found${NC}"
  echo -e "${YELLOW}Warning: Claude Code CLI not detected. Continuing anyway...${NC}"
fi

# Check if source files exist
echo -n "Checking source files... "
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
  echo -e "${YELLOW}warning${NC}"
  echo -e "${YELLOW}Warning: Some source files missing: ${missing_files[*]}${NC}"
else
  echo -e "${GREEN}ok${NC}"
fi

# Create target directory if it doesn't exist
if [ ! -d "$CLAUDE_TARGET_DIR" ]; then
  echo -n "Creating $CLAUDE_TARGET_DIR... "
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

# Install settings files
echo ""
echo "Installing settings files..."
echo ""

actions_taken=()

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

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
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
echo "Installed settings include:"
echo "  • Default mode: plan"
echo "  • Status line: rose-pine powerline theme"
echo "  • Plugins: context7, compound-engineering"
echo ""
echo -e "${BLUE}Restart Claude Code to apply changes.${NC}"
