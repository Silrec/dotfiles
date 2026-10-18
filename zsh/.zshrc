HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_ignore_all_dups hist_ignore_space autocd interactive_comments
WORDCHARS=${WORDCHARS//\/}

# --- Completion ---
zmodload zsh/complist
autoload -Uz compinit && compinit
eval "$(dircolors -b)"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' completer _complete _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*:corrections' format '%F{red}-- %d (errors: %e) --%f'

# --- Keys ---
bindkey -e
typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-Backspace]='^H'
key[Control-Delete]="${terminfo[kDC5]}"

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Home]}"		]] && bindkey -- "${key[Home]}"				beginning-of-line
[[ -n "${key[End]}"		]] && bindkey -- "${key[End]}"				end-of-line
[[ -n "${key[Delete]}"		]] && bindkey -- "${key[Delete]}"			delete-char
[[ -n "${key[Up]}"		]] && bindkey -- "${key[Up]}"				up-line-or-beginning-search
[[ -n "${key[Down]}"		]] && bindkey -- "${key[Down]}"				down-line-or-beginning-search
[[ -n "${key[Control-Left]}"	]] && bindkey -- "${key[Control-Left]}"			backward-word
[[ -n "${key[Control-Right]}"	]] && bindkey -- "${key[Control-Right]}"		forward-word
[[ -n "${key[Shift-Tab]}"	]] && bindkey -M menuselect -- "${key[Shift-Tab]}"	reverse-menu-complete
[[ -n "${key[Control-Backspace]}" ]] && bindkey -- "${key[Control-Backspace]}" backward-kill-word
[[ -n "${key[Control-Delete]}"    ]] && bindkey -- "${key[Control-Delete]}"    kill-word

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start	{ echoti smkx }
	function zle_application_mode_stop	{ echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init	zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish	zle_application_mode_stop
fi

# --- Prompt ---
if [[ $TERM == linux ]]; then
	PROMPT='%(?..%F{red}[%?]%f )%F{cyan}%n%f@%m %~%(!.#.$) '
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=magenta'
else
	eval "$(starship init zsh)"
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#a8a8a8'
fi

# --- Plugins (order matters) ---
# fzf: Ctrl+R fuzzy history, Ctrl+T files, Alt+C cd
(( $+commands[fzf] )) && source <(fzf --zsh)

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(forward-char vi-forward-char)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-toggle

# Must be sourced last
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Safety nets ---
alias cp='cp -iv' mv='mv -iv' rm='rm -Iv' mkdir='mkdir -pv'

# --- Better defaults ---
alias ls='eza --group-directories-first --icons=auto'
alias ll='ls -l --git' la='ll -a' lt='ls --tree --level=2'
alias cat='bat --paging=never'
alias grep='grep --color=auto' diff='diff --color=auto' ip='ip -color=auto'
alias df='df -h' du='du -h' free='free -h'

# --- Arch ---
alias update='sudo pacman -Syu'
alias orphans='pacman -Qdtq'                            # list only
alias explicit='pacman -Qqe'
alias pkgsize='expac -H M "%m\t%n" | sort -h | tail -20'

# --- systemd / logs / network ---
alias sc='systemctl' scu='systemctl --user' failed='systemctl --failed'
alias jerr='journalctl -p 3 -xb'                        # errors from this boot
alias ports='sudo ss -tulpn'

# --- Btrfs ---
alias fsusage='sudo btrfs filesystem usage /'           # df is misleading on Btrfs
alias compratio='sudo compsize -x /'                    # real zstd savings

# --- Git / editor ---
alias g='git' gs='git status -sb' gd='git diff' gl='git log --oneline --graph --decorate -20' lg='lazygit'
alias v='nvim' sv='sudoedit'

# --- zsh-only ---
alias -g G='| grep -i' L='| less' NE='2>/dev/null'      # e.g. pacman -Q G python
alias -s {md,txt,lua,toml,conf}=nvim                    # type notes.md to open it

# --- yazi: cd into the dir you were in when quitting ---
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# --- zoxide: z <part of dir name>, zi for an fzf picker ---
eval "$(zoxide init zsh)"

# --- proxy
proxy_on() {
  export http_proxy=http://127.0.0.1:2080 https_proxy=http://127.0.0.1:2080
  export all_proxy=socks5h://127.0.0.1:2080 no_proxy=localhost,127.0.0.1
}
proxy_off() { unset http_proxy https_proxy all_proxy no_proxy }

# --- filemanager quickswithch
fm() {
  case "$1" in
    yazi)    xdg-mime default yazi.desktop inode/directory ;;
    dolphin) xdg-mime default org.kde.dolphin.desktop inode/directory ;;
    *)       echo "usage: fm yazi|dolphin" ;;
  esac
  echo "Default file manager: $(xdg-mime query default inode/directory)"
}
