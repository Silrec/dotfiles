export SUDO_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R -F -i'
export MANPAGER='nvim +Man!'
export BROWSER=firefox
export TERMINAL=kitty

typeset -U path
path=(~/.local/bin $path)

#if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
#    exec start-hyprland
#fi
