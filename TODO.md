# TODO

## Verify on a fresh VM

The new `setup` + `--fresh` flow needs a clean-machine pass before it can be trusted end-to-end:

- [ ] `./setup --all` on a fresh macOS — verify every module installs cleanly
- [ ] `./setup --all --fresh` on an already-set-up machine — verify reset works without losing critical state (SSH keys, `.gitconfig.local`, `~/fvm/versions`)
- [ ] `./setup --all --copy` — verify copy mode still works after the refactor
- [ ] Linux: smoke-test `homebrew`, `zsh`, `git` modules

## Test Linux-specific configs

Ghostty, zellij and fish configs were split into per-platform files (2026-05-24). macOS side is verified.

- [x] `ghostty/config.linux`: `command = zellij` — zellij at `/usr/bin/zellij`, in PATH
- [ ] `ghostty/config.linux`: verify `ctrl+` keybindings work correctly
- [x] `zellij/config.linux.kdl`: `default_shell "fish"` — fish at `/usr/bin/fish`, in PATH
- [x] `fish/config.fish`: PATH additions are no-ops on Linux — verified, guarded with `test -d`
- [ ] Full chain Ghostty → zellij → fish opens without errors
- [x] Zed: `Google Sans Code` font installed from GitHub releases (v7.000, OFL license)

## Known limitations

- **SSH keys are never auto-deleted.** `--fresh` on the `ssh` module just warns. Intentional: regenerating keys silently is too risky.
- **Homebrew itself is preserved on `--fresh`.** Removing brew would also remove every package and break the rest of the run.
- **`~/fvm/versions` (cached Flutter SDKs) is preserved.** `fvm --fresh` only reinstalls the `fvm` binary; cached SDKs stay.
- **VS Code extensions on `--fresh` require `code` on PATH.** If `code` isn't installed, extension reset is silently skipped.
