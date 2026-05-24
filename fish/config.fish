set fish_greeting

# Ensure standard paths are available (Ghostty launches with minimal PATH)
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
end
if test -d /usr/local/bin
    fish_add_path /usr/local/bin
end

if status is-interactive
    # Oh My Posh prompt
    if type -q oh-my-posh
        oh-my-posh init fish --config ~/.config/oh-my-posh/theme.omp.json | source
    end

    # Zellij auto-start in supported terminals (skip if already inside zellij)
    set -gx ZELLIJ_CONFIG_DIR $HOME/.config/zellij
    if test -z "$ZELLIJ"; and type -q zellij; and test "$TERM" = xterm-ghostty -o "$TERM" = alacritty
        eval (zellij setup --generate-auto-start fish | string collect)
    end
end
