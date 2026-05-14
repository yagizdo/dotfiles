set fish_greeting

if status is-interactive
    # Oh My Posh prompt
    if type -q oh-my-posh
        oh-my-posh init fish --config ~/.config/oh-my-posh/theme.omp.json | source
    end

    # Zellij auto-start in supported terminals
    set -gx ZELLIJ_CONFIG_DIR $HOME/.config/zellij
    if test "$TERM" = xterm-ghostty -o "$TERM" = alacritty
        eval (zellij setup --generate-auto-start fish | string collect)
    end
end
