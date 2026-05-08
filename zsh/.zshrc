# ── Zinit Plugin Manager ──
ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"

if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ── Plugins ──
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zi snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh

# ── Completion ──
autoload -Uz compinit
compinit
zinit cdreplay -q

# ── PATH ──
export PATH="$HOME/fvm/default/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.shorebird/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# ── Tool Integrations ──

# Dart CLI completion
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true

# Oh-My-Posh prompt
if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/theme.omp.json")"
fi
