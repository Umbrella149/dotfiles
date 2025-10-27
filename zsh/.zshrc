# Created by newuser for 5.9
eval "$(starship init zsh)"
alias vi="nvim"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias rm="rm -i"
alias cr="~/.local/bin/cr.sh"
alias crc="~/.local/bin/crc.sh"
alias watool="~/.local/bin/watool.sh"
alias ls="ls --color=auto"
alias ll="ls -l --color=auto"
alias la="ls -a --color=auto"
alias lla="ls -l -a --color=auto"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
