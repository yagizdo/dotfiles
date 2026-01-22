#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./ssh.sh your@email.com"
  exit 1
fi

EMAIL=$1

echo "Generating SSH key for $EMAIL..."
ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519

echo ""
echo "Copy your public key:"
echo "pbcopy < ~/.ssh/id_ed25519.pub"
echo ""
echo "Then add it to GitHub: https://github.com/settings/ssh/new"
echo ""
echo "Test with: ssh -T git@github.com"
