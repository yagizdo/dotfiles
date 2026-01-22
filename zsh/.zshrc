# Dotfiles path
export DOTFILES="$HOME/.dotfiles"

# Zinit installation
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}Installing Zinit...%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# OMZ plugins
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found

# Keybindings
bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups

# Oh-My-Posh
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/theme.omp.json)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Source custom configs
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/path.zsh"
source "$DOTFILES/zsh/exports.zsh"
