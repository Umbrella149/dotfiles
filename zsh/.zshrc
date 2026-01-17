# Created by newuser for 5.9
eval "$(starship init zsh)"
alias vi="nvim"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias rm="rm -i"
alias cr="~/.local/bin/cr.sh"
alias crc="~/.local/bin/crc.sh"
alias watool="~/.local/bin/watool.sh"
alias ls="lsd --color=auto"
alias ll="lsd -l --color=auto"
alias la="lsd -a --color=auto"
alias lla="lsd -l -a --color=auto"
alias tree="ls --tree"
alias ff="fastfetch"
alias cat="bat"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
