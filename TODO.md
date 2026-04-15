# TODO

## Refactor: Modular install foundation

The modular install story has accumulated inconsistencies and duplication. Needs a proper refactor pass.

### Known issues

- **Duplication between `bootstrap.sh -m claude` and `claude-code-setup.sh`**
  - Both install settings files; `claude/install.sh` now delegates, but the two scripts still have independent logic (backup, symlink vs copy, file list).
  - `claude-code-setup.sh` installs `settings.local.json`; the rest of the bootstrap system doesn't know about it.
  - Pick one: either bootstrap owns config install and setup.sh only does plugins/powerline, or setup.sh is the single entrypoint and bootstrap just calls it.

- **Source path inconsistency**
  - Claude configs live in `.claude/` (dot-prefixed, hidden).
  - Other modules use plain dirs: `zsh/`, `vscode/`, `ghostty/`.
  - `claude/` dir only holds scripts, not configs — confusing. Unify the layout.

- **`--copy` mode retrofitted, not designed in**
  - Added to `lib/helpers.sh::link_file` and `bootstrap.sh` as a flag.
  - Each module's `install.sh` has to pass the mode through manually (see `claude/install.sh` building `$SETUP_FLAG`).
  - Other modules (ghostty, zellij, zsh, vscode) also use `link_file` and will silently respect `--copy` — untested. Verify every module works in copy mode.

- **CLI install responsibility is unclear**
  - `claude/install.sh` now installs the Claude Code CLI via brew if missing — but `homebrew/install.sh` also installs it via Brewfile.
  - Decide: do modules own their binary deps, or does the `homebrew` module own everything? Current state is a hybrid.

- **No module dependency declaration**
  - `claude` implicitly depends on brew being present.
  - `vscode` depends on `code` CLI.
  - `ssh` is interactive.
  - No declared DAG — `bootstrap.sh --core` just hardcodes order.

- **Backup strategy split**
  - `lib/helpers.sh` backs up to `~/.dotfiles-backup/<timestamp>/`.
  - `claude-code-setup.sh` backs up to `~/.claude/backup/<file>.<timestamp>`.
  - Pick one convention.

### Proposed direction (not decided)

1. One shared install primitive in `lib/helpers.sh` (`install_file` handling symlink+copy+backup uniformly).
2. Every module has a single `install.sh` — no standalone scripts at repo root.
3. `claude-code-setup.sh` becomes a helper sourced by the module, not a parallel entrypoint.
4. Move `.claude/` → `claude/configs/` so layout matches other modules.
5. Declarative module manifest (deps, core flag, interactive flag) instead of scattered logic.

### Why not now

Works for current use cases (home machine symlink, work PC copy). Refactor needs a dedicated session + test pass across all modules on a fresh VM.
