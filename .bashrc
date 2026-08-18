#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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
export PATH="$HOME/.local/bin:$PATH"
enable -f libflyline.so flyline
# PS1='\e[01;32m\u@\h\e[00m:\e[01;34m\w\e[00m\n$ '
RPS1='\e[01;33m\t\n<\e[00m'
# PS1_FILL='-'
PS2='\e[2mline FLYLINE_PROMPT_LINE_NUMBER:\e[0m '
PS1_FINAL='Ran at \D{%Y-%m-%d %H:%M:%S}> '
RPS1_FINAL=''
PS1_FILL_FINAL=''

# set keybinds
flyline key bind Ctrl+n tabCompletionAvailable=tabCompletionNextSuggestion
flyline key bind Ctrl+p tabCompletionAvailable=tabCompletionPrevSuggestion
flyline key bind Ctrl+n fuzzyHistorySearch=fuzzyHistorySelectNext
flyline key bind Ctrl+p fuzzyHistorySearch=fuzzyHistorySelectPrev
flyline key bind Ctrl+n agentOutputSelection=agentOutputNextSuggestion
flyline key bind Ctrl+p agentOutputSelection=agentOutputSelectPrev

flyline key bind Ctrl+y tabCompletionEntrySelected=tabCompletionAcceptEntry
flyline key bind Ctrl+y fuzzyHistorySearchCancelledCommands=fuzzyHistoryAcceptEntry
flyline key bind Ctrl+y fuzzyHistorySearchNormalCommands=fuzzyHistoryAcceptEntry
flyline key bind Ctrl+y fuzzyHistorySearchAgentCommands=fuzzyHistoryAcceptAgentCommandEntry
flyline key bind Ctrl+y agentOutputSelection=agentOutputAcceptEntry
flyline key bind Ctrl+y agentOutputNoneSelected=agentOutputRunAgentMode
flyline key bind Ctrl+y agentModeError=agentModeRunHelpCommand
flyline key bind Ctrl+y promptDirSelection=promptDirAcceptEntry
flyline key bind Ctrl+y bufferHasAgentModePrefix+editingBufferMode=runAgentMode

flyline key bind Enter tabCompletionEntrySelected=insertNewline
flyline key bind Enter fuzzyHistorySearchCancelledCommands=insertNewline
flyline key bind Enter fuzzyHistorySearchNormalCommands=insertNewline
flyline key bind Enter fuzzyHistorySearchAgentCommands=insertNewline
flyline key bind Enter agentOutputSelection=insertNewline
flyline key bind Enter agentOutputNoneSelected=insertNewline
flyline key bind Enter agentModeError=insertNewline
flyline key bind Enter promptDirSelection=insertNewline
flyline key bind Enter bufferHasAgentModePrefix+editingBufferMode=insertNewline
# set agent mode
flyline set-agent-mode \
  --system-prompt "Be concise. Answer with a JSON array of at most 3 items with objects containing: command and description. Command will be a Bash command." \
  --trigger-prefix ': ' \
  --command 'deepseek.sh'
# set name animation

_umbrella_frames=()
_umbrella_word="umbrella"
_umbrella_noise='@#$%&*!?'
_umbrella_len=${#_umbrella_word}

for ((_i = 0; _i <= _umbrella_len; _i++)); do
  _frame=""
  for ((_j = 0; _j < _umbrella_len; _j++)); do
    if ((_i == 0)); then
      _noise_idx=$(((_j + _i) % ${#_umbrella_noise}))
      _frame+="\e[32m${_umbrella_noise:_noise_idx:1}\e[0m"
    elif ((_j < _i)); then
      _frame+="\e[92m${_umbrella_word:_j:1}\e[0m"
    elif ((_j == _i)); then
      _frame+="\e[97m\e[42m${_umbrella_word:_j:1}\e[0m"
    else
      _noise_idx=$(((_j + _i) % ${#_umbrella_noise}))
      _frame+="\e[32m${_umbrella_noise:_noise_idx:1}\e[0m"
    fi
  done
  _umbrella_frames+=("$_frame")
done

flyline create-prompt-widget animation --name "umbrella" --ping-pong --fps 10 "${_umbrella_frames[@]}"

unset _umbrella_frames _umbrella_word _umbrella_noise _umbrella_len _i _j _frame _noise_idx
# export PS1='\u:\w '
PS1='\e[01;32m\u@\h\e[00m:\e[01;34m\w\e[00m\n$ '
