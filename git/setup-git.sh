#!/bin/bash
# Git credentials setup
# Creates ~/.gitconfig.local with user name and email

set -e

echo "Git credentials setup"
echo "====================="
echo ""

# Prompt for name
read -rp "Your name: " git_name
if [ -z "$git_name" ]; then
  echo "Error: Name cannot be empty."
  exit 1
fi

# Prompt for email
read -rp "Your email: " git_email
if [ -z "$git_email" ]; then
  echo "Error: Email cannot be empty."
  exit 1
fi

# Write to ~/.gitconfig.local
cat > "$HOME/.gitconfig.local" <<EOF
[user]
    name = $git_name
    email = $git_email
EOF

echo ""
echo "Wrote ~/.gitconfig.local"
echo "  name:  $git_name"
echo "  email: $git_email"
