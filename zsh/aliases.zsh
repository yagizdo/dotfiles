# General
alias c='clear'
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias vim='nvim'
alias reloadshell="exec zsh"

# Directories
alias dotfiles="cd $DOTFILES"
alias projects="cd $HOME/workspace"

# Flutter/FVM
alias f='flutter'
alias fp='flutter pub get'
alias fr='flutter run'
alias fb='flutter build'
alias fc='flutter clean'
alias fvm-use='fvm use'
alias fvm-list='fvm list'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph'

# iOS
alias pod-install='cd ios && pod install && cd ..'
alias sim='open -a Simulator'
