# TODO

## Verify on a fresh VM

The new `setup` + `--fresh` flow needs a clean-machine pass before it can be trusted end-to-end:

- [ ] `./setup --all` on a fresh macOS — verify every module installs cleanly
- [ ] `./setup --all --fresh` on an already-set-up machine — verify reset works without losing critical state (SSH keys, `.gitconfig.local`, `~/fvm/versions`)
- [ ] `./setup --all --copy` — verify copy mode still works after the refactor
- [ ] Linux: smoke-test `homebrew`, `zsh`, `git` modules

## Known limitations

- **SSH keys are never auto-deleted.** `--fresh` on the `ssh` module just warns. Intentional: regenerating keys silently is too risky.
- **Homebrew itself is preserved on `--fresh`.** Removing brew would also remove every package and break the rest of the run.
- **`~/fvm/versions` (cached Flutter SDKs) is preserved.** `fvm --fresh` only reinstalls the `fvm` binary; cached SDKs stay.
- **VS Code extensions on `--fresh` require `code` on PATH.** If `code` isn't installed, extension reset is silently skipped.
