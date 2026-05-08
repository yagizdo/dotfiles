# Dotfiles

Personal dotfiles for Flutter/mobile development on macOS.

## What's Included

- **Shell**: ZSH with Zinit plugins, Oh-My-Posh prompt
- **Editor**: VS Code (Flutter extensions)
- **Flutter**: FVM setup, CocoaPods, scrcpy
- **AI**: Claude Code configuration
- **Git**: SSH key setup, global gitconfig, gitignore

## Clean Install

On a fresh machine:

```bash
bash <(curl -sL https://raw.githubusercontent.com/yagizdo/dotfiles/master/install.sh) --all
```

Or manually:

```bash
git clone git@github.com:yagizdo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x bootstrap.sh
./bootstrap.sh --all
```

## Usage

```bash
./bootstrap.sh                        # show help
./bootstrap.sh --all                  # install everything
./bootstrap.sh --core                 # install core (homebrew, zsh, git)
./bootstrap.sh --dry-run --all       # preview all changes
```

### Install specific modules

```bash
./bootstrap.sh -m zsh                 # install a single module
./bootstrap.sh -m zsh -m vscode      # install multiple modules
./bootstrap.sh -m claude              # install just Claude Code config
./bootstrap.sh --dry-run -m zsh      # preview what a module would do
```

You can combine `-m` flags to install any combination. Use `--dry-run` to preview changes before applying.

### Flags

| Flag | Description |
|------|-------------|
| `-m, --module <name>` | Install a specific module (repeatable) |
| `-a, --all` | Install all modules |
| `--core` | Install core modules only |
| `-n, --dry-run` | Show what would happen without changes |
| `-v, --verbose` | Verbose output |
| `-f, --force` | Overwrite without backup |
| `-h, --help` | Show help message |

### Available Modules

| Module | Core? | Description |
|--------|-------|-------------|
| `homebrew` | Yes | Homebrew package manager and Brewfile |
| `zsh` | Yes | ZSH config with Zinit plugins |
| `git` | Yes | Git config and global gitignore |
| `oh-my-posh` | No | Oh My Posh prompt theme |
| `vscode` | No | VS Code settings |
| `ssh` | No | SSH key setup (interactive) |
| `claude` | No | Claude Code settings |
| `ghostty` | No | Ghostty terminal config |
| `zellij` | No | Zellij multiplexer config |

## Local Configuration

### Machine-specific shell config

Add machine-specific settings to `~/.zshrc.local` (not tracked by git):

```bash
# Example ~/.zshrc.local
export WORK_API_KEY="..."
alias deploy="ssh deploy@work-server"
```

### Git credentials

Git credentials are kept out of the repo via `~/.gitconfig.local`:

```bash
# Run the setup helper
./git/setup-git.sh

# Or manually
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## Manual Steps After Bootstrap

1. Install VS Code extensions:
   ```bash
   cat ~/.dotfiles/vscode/extensions.txt | xargs -L 1 code --install-extension
   ```

## Git SSH Setup

Generate SSH key:

```bash
./bootstrap.sh -m ssh
# or directly:
./ssh/ssh.sh your@email.com
```

Copy and add to GitHub:

```bash
pbcopy < ~/.ssh/id_ed25519.pub
# Add at: https://github.com/settings/ssh/new
```

## File Structure

```
dotfiles/
├── lib/                # Shared libraries
│   ├── helpers.sh      # Color, logging, link_file utilities
│   └── modules.sh      # Module registry and resolution
├── zsh/                # Shell configuration
│   ├── .zshrc          # Main config with Zinit
│   ├── .zprofile       # Homebrew init
│   ├── aliases.zsh     # Custom aliases
│   ├── path.zsh        # PATH configuration
│   ├── exports.zsh     # Environment variables
│   └── install.sh      # Module installer
├── homebrew/           # Homebrew packages
│   ├── Brewfile        # Core packages
│   ├── Brewfile.flutter # Flutter packages
│   └── install.sh      # Module installer
├── vscode/             # VS Code settings
│   ├── settings.json
│   ├── extensions.json
│   ├── extensions.txt
│   └── install.sh
├── oh-my-posh/         # Prompt theme
│   ├── theme.omp.json
│   └── install.sh
├── claude/             # Claude Code settings
│   ├── settings.json
│   ├── claude-powerline.json
│   ├── CLAUDE.md
│   └── install.sh
├── ssh/                # SSH key setup
│   ├── ssh.sh
│   └── install.sh
├── git/                # Git configuration
│   ├── .gitconfig
│   ├── .gitignore_global
│   ├── setup-git.sh
│   └── install.sh
├── ghostty/            # Ghostty terminal
│   └── install.sh
├── zellij/             # Zellij multiplexer
│   ├── config.kdl
│   ├── layouts/
│   │   └── quiver.kdl
│   └── install.sh
├── bootstrap.sh        # Main modular installer
├── install.sh          # One-liner entry point for fresh machines
├── claude-code-setup.sh # Claude Code full setup (plugins, powerline)
└── README.md
```

## Key Bindings

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

## Troubleshooting

### Symlinks not created
Bootstrap backs up existing files to `~/.dotfiles-backup/`. Check that directory if something looks wrong.

### Homebrew on Linux
The bootstrap script auto-detects the OS and uses the correct Homebrew path (`/home/linuxbrew/.linuxbrew` on Linux).

### Bootstrap from non-standard location
The repo auto-detects its own location — you can clone it anywhere, not just `~/.dotfiles`.

## Updating

```bash
cd ~/.dotfiles  # or wherever you cloned it
git pull
./bootstrap.sh --all
```
