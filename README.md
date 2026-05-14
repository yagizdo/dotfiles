# Dotfiles

Personal dotfiles for macOS and Linux (Arch).

Two modes for everything:

- **sync** (default) — install or update configs, idempotent.
- **fresh** (`--fresh`) — wipe existing configs, uninstall + reinstall the program from scratch, then re-apply configs.

## Quick start

Fresh machine, one-liner:

```bash
bash <(curl -sL https://raw.githubusercontent.com/yagizdo/dotfiles/master/install.sh) --all --fresh
```

Or manually:

```bash
git clone git@github.com:yagizdo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup --all --fresh
```

## Usage

```bash
./setup                          # show help
./setup --all                    # sync everything (default mode)
./setup --all --fresh            # nuke + reinstall everything
./setup --core                   # sync core: base packages, zsh, git
./setup claude                   # sync only Claude Code
./setup claude --fresh           # nuke + reinstall Claude Code (plugins, settings, powerline)
./setup zsh vscode               # sync multiple modules
./setup --dry-run --all --fresh  # preview a fresh install
```

You can pass module names as positional args (`./setup claude`) or with `-m` (`./setup -m claude -m zsh`). They're equivalent.

### Flags

| Flag | What it does |
|------|--------------|
| `-m, --module <name>` | Install a specific module (repeatable) |
| `-a, --all` | Install all modules |
| `--core` | Install core modules only |
| `-F, --fresh` | Fresh install: remove existing configs and reinstall programs |
| `-n, --dry-run` | Show what would happen without making changes |
| `-v, --verbose` | Verbose output |
| `-f, --force` | Overwrite existing files without backup |
| `-c, --copy` | Copy files instead of symlinking (for disposable clones) |
| `-h, --help` | Show help |

### Modules

| Module | Core? | Platform | What sync does | What `--fresh` adds on top |
|--------|-------|----------|----------------|------------------------------|
| `macos` | ✓ | macOS | Install Homebrew, run Brewfile | `brew bundle cleanup --force` then reinstall everything |
| `linux` | ✓ | Linux | Install base packages via pacman | Reinstall all base packages |
| `zsh` | ✓ | both | Link `.zshrc`/`.zprofile`, install Zinit | Remove old configs, delete Zinit, reinstall |
| `fish` | | both | Link `config.fish` with Oh My Posh | Reinstall fish shell |
| `git` | ✓ | both | Link `.gitconfig`, `.gitignore_global` | Remove existing symlinks (preserves `.gitconfig.local`) |
| `oh-my-posh` | | both | Link prompt theme (Catppuccin Macchiato) | brew/curl reinstall oh-my-posh |
| `claude` | | both | Settings, marketplaces, plugins, powerline | Uninstall all plugins, remove marketplaces, reinstall |
| `vscode` | | both | Link `settings.json`, install extensions | Uninstall all extensions, reinstall from `extensions.txt` |
| `ssh` | | both | Interactive key setup if missing | SSH keys are NOT auto-deleted (manual step required) |
| `ghostty` | | both | Link Ghostty config | Remove config symlink |
| `zellij` | | both | Link Zellij config + layouts | Remove config symlinks |
| `zed` | | Linux | Link Zed settings | Remove config symlink |
| `fvm` | | both | Install FVM, configure editor SDK path | brew reinstall fvm, reset editor SDK setting |

`--fresh` always prompts for confirmation in interactive shells. Backups go to `~/.dotfiles-backup/<timestamp>/`.

### Shell architecture

```
Ghostty → Zellij (command = zellij) → fish panes (oh-my-posh catppuccin macchiato)
Alacritty → fish → auto-starts Zellij → fish panes
```

Both macOS and Linux use fish as the primary shell inside Zellij. The zsh config is kept for compatibility and direct terminal use.

## Local configuration

### Machine-specific shell config

Add machine-specific settings to `~/.zshrc.local` (not tracked):

```bash
export WORK_API_KEY="..."
alias deploy="ssh deploy@work-server"
```

### Git credentials

Kept out of the repo via `~/.gitconfig.local`:

```bash
./git/setup-git.sh
```

`--fresh` on the `git` module preserves `~/.gitconfig.local`.

## Git SSH setup

```bash
./setup ssh
# or directly:
./ssh/ssh.sh your@email.com
```

Then add the public key to GitHub:

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519.pub
# Linux
wl-copy < ~/.ssh/id_ed25519.pub
```

Visit https://github.com/settings/ssh/new

## File structure

```
dotfiles/
├── setup                # Main entry point — invoke this
├── install.sh           # curl one-liner for fresh machines
├── lib/
│   ├── helpers.sh       # link_file, log_*, fresh helpers
│   └── modules.sh       # Module registry
├── macos/install.sh
├── linux/install.sh
├── zsh/install.sh
├── fish/install.sh
├── git/install.sh
├── claude/install.sh
├── oh-my-posh/install.sh
├── vscode/install.sh
├── ssh/install.sh
├── ghostty/install.sh
├── zellij/install.sh
├── zed/install.sh
└── fvm/install.sh
```

## Updating

```bash
cd ~/.dotfiles
git pull
./setup --all          # sync mode — picks up any new configs
```

Symlinked configs (ghostty, zellij, oh-my-posh theme) update automatically after `git pull`. New modules (like `fish`) need a one-time `./setup -m fish` to create the symlink.

## Troubleshooting

- **Backup of an old file**: check `~/.dotfiles-backup/<timestamp>/`
- **Bootstrap from a non-standard location**: the repo auto-detects its own path, clone anywhere
- **Linux Homebrew**: auto-detected (`/home/linuxbrew/.linuxbrew`)
- **macOS keyboard tweaks**: see `macos/keyboard-modifiers.md` (manual System Settings step)
