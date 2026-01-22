# Dotfiles

Personal dotfiles for Flutter/mobile development on macOS.

## What's Included

- **Shell**: ZSH with Zinit plugins, Oh-My-Posh prompt
- **Terminal**: Warp with Catppuccin Mocha theme
- **Editor**: Neovim (LazyVim), VS Code (Flutter extensions)
- **Multiplexer**: Tmux with vim navigation
- **Flutter**: FVM setup, CocoaPods, scrcpy
- **AI**: Claude Code configuration
- **Git**: SSH key setup, global gitconfig, gitignore

## Quick Start

```bash
# Clone to ~/.dotfiles
git clone git@github.com:yagizdo/dotfiles.git ~/.dotfiles

# Run bootstrap
cd ~/.dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

## Manual Steps After Bootstrap

1. Open tmux and press `Ctrl+a I` to install plugins
2. Open Neovim - plugins will auto-install
3. Set Warp theme: Settings > Appearance > Themes > catppuccin_mocha
4. Install VS Code extensions:
   ```bash
   cat ~/.dotfiles/vscode/extensions.txt | xargs -L 1 code --install-extension
   ```

## Git SSH Setup

Generate SSH key:

```bash
./ssh/ssh.sh your@email.com
```

Copy and add to GitHub:

```bash
pbcopy < ~/.ssh/id_ed25519.pub
# Add at: https://github.com/settings/ssh/new
```

Configure git and test:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
ssh -T git@github.com
```

## File Structure

```
~/.dotfiles/
├── zsh/                # Shell configuration
│   ├── .zshrc          # Main config with Zinit
│   ├── .zprofile       # Homebrew init
│   ├── aliases.zsh     # Custom aliases
│   ├── path.zsh        # PATH configuration
│   └── exports.zsh     # Environment variables
├── warp/               # Warp terminal theme
│   └── themes/
│       └── catppuccin_mocha.yml
├── tmux/               # Tmux configuration
│   └── tmux.conf
├── nvim/               # Neovim/LazyVim
│   ├── init.lua
│   └── lua/plugins/
├── vscode/             # VS Code settings
│   ├── settings.json
│   └── extensions.txt
├── oh-my-posh/         # Prompt theme
│   └── theme.omp.json
├── .claude/            # Claude Code settings
│   └── settings.json
├── ssh/                # SSH key setup
│   └── ssh.sh
├── git/                # Git configuration
│   ├── .gitconfig      # Global git config
│   └── .gitignore_global
├── Brewfile            # Core packages
├── Brewfile.flutter    # Flutter packages
├── bootstrap.sh        # Setup script
└── README.md           # This file
```

## Key Bindings

### Tmux

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix key |
| `Ctrl+a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+a \|` | Split horizontally |
| `Ctrl+a -` | Split vertically |
| `Ctrl+a r` | Reload config |
| `Shift+Left/Right` | Switch windows |

### Shell Aliases

| Alias | Command |
|-------|---------|
| `f` | `flutter` |
| `fp` | `flutter pub get` |
| `fr` | `flutter run` |
| `fc` | `flutter clean` |
| `gs` | `git status` |
| `glog` | `git log --oneline --graph` |
| `vim` | `nvim` |
| `ll` | `eza -l --icons` |

## Updating

```bash
cd ~/.dotfiles
git pull
./bootstrap.sh
```
