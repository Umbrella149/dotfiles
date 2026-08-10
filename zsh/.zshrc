# Created by newuser for 5.9
eval "$(starship init zsh)"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
# set for ai key
source ~/privatekey
alias vi="nvim"
alias rm="rm -i"
alias ls="lsd --color=auto"
alias ll="lsd -l --color=auto"
alias la="lsd -a --color=auto"
alias lla="lsd -l -a --color=auto"
alias tree="ls --tree"
alias ff="fastfetch"
alias cat="bat"
alias py="uv run"
manh() {
    tldr "$@" --color=always | bat --language=markdown --paging=always
}
# set PATHS
export PATH="$HOME/.local/bin:$PATH"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

alias tmux="tmux -u"
# Tmux aliases
[ ! -f ~/.config/tmux/scripts/tmux_aliases.sh ] || source ~/.config/tmux/scripts/tmux_aliases.sh
