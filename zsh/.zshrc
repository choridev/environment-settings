# PATH / Env
typeset -U path PATH
path=("$HOME/.local/bin" $path /usr/local/go/bin /usr/local/nvim/bin)
export EDITOR=nvim VISUAL=nvim
export LESS='-R -F'

# tmux
if [[ -o interactive ]] && [[ -n "$SSH_TTY" ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
    tmux new-session -A -s main -n "$(hostname -s)"
fi

# Color
eval "$(dircolors -b)"

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
setopt complete_in_word

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history hist_ignore_space inc_append_history

# Option / Keybinding
setopt interactive_comments
unsetopt flowcontrol
bindkey -e
WORDCHARS=''

# Alias
alias ls='ls --color=auto'
alias l='ls -F'
alias ll='ls -alFh'
alias grep='grep --color=auto'
alias diff='diff --color'
alias rm='rm -I'
alias vi='nvim'
alias tm='tmux'
alias sa='ssha'
alias cl='clear'
alias g='git'

# SSH Agent
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  [[ -r ~/.ssh-agent-info ]] && source ~/.ssh-agent-info >/dev/null
  ssh-add -l &>/dev/null
  if [[ $? == 2 ]]; then
    (umask 077; ssh-agent -s > ~/.ssh-agent-info)
    source ~/.ssh-agent-info >/dev/null
  fi
fi

# Prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Plugin
for _p in \
  ~/.zsh/ssh-helper.zsh \
  ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh \
  ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -r "$_p" ]] && source "$_p"
done
unset _p
