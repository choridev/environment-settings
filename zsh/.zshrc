# PATH / Env
typeset -U path PATH
path=("$HOME/.local/bin" $path /usr/local/go/bin /usr/local/nvim/bin)
export EDITOR=nvim VISUAL=nvim
export LESS='-R -F'

# Multiplexer: Herdr where it exists, Tmux on machines without it.
#
# Both variables have to be clear, not just one. Each multiplexer sets only its
# own, so testing $TMUX alone would start Herdr inside every Tmux pane. A Herdr
# pane inherits SSH_TTY from the login shell, so without the $HERDR_ENV test
# every new pane — and every split — would open another Herdr inside itself.
# That variable is Herdr's own marker for running inside Herdr; its agent skill
# file checks it the same way.
#
# Plain `herdr` attaches to the persistent session it names 'default'; passing
# --session with the hostname would fragment that into a second one. Tmux keeps
# the single 'main' session it always used, hostname on the first window.
if [[ -o interactive ]] && [[ -n "$SSH_TTY" ]] \
   && [[ -z "$HERDR_ENV" ]] && [[ -z "$TMUX" ]]; then
    if command -v herdr >/dev/null 2>&1; then
        herdr
    elif command -v tmux >/dev/null 2>&1; then
        tmux new-session -A -s main -n "$(hostname -s)"
    fi
fi

# Color
# `dircolors` only ships with GNU coreutils, so its presence stands in for the
# whole GNU-vs-BSD userland split (macOS lands in the else branch).
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
else
    export CLICOLOR=1
fi

# Completion
autoload -Uz compinit && compinit
# 'menu yes' + menu_complete keeps fzf-tab from being skipped when the matches
# share a common prefix: without them Zsh inserts the prefix and never opens fzf.
zstyle ':completion:*' menu yes
# Substring matching comes first so that 'tron' still offers 'neutron'; a prefix
# matcher here would win outright and hide every non-prefix match. The trailing
# entry is a fuzzy fallback for queries like 'argocd/k8s/osmo'.
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' \
  'r:|?=**'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
setopt complete_in_word
setopt menu_complete

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

# Up/Down search history for entries starting with whatever is already typed.
# Both sequences are bound because terminals switch between normal and
# application cursor mode, and binding only one makes this fail intermittently.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for _k in '^[[A' '^[OA'; do bindkey "$_k" up-line-or-beginning-search; done
for _k in '^[[B' '^[OB'; do bindkey "$_k" down-line-or-beginning-search; done
unset _k

# Alias
# `--color=auto` and `-I` are GNU-only; BSD ls colours via CLICOLOR and has no -I.
if command -v dircolors >/dev/null 2>&1; then
    alias ls='ls --color=auto'
    alias rm='rm -I'      # prompt once before removing three or more files
else
    alias ls='ls -G'
    alias rm='rm -i'      # BSD has no -I, so fall back to prompting every time
fi
alias l='ls -F'
alias ll='ls -alFh'
alias grep='grep --color=auto'
diff --color /dev/null /dev/null >/dev/null 2>&1 && alias diff='diff --color'
alias vi='nvim'
alias tm='tmux'
alias hr='herdr'
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
# fzf-tab has to come before the plugins that wrap widgets (autosuggestions,
# syntax-highlighting), otherwise it cannot take over the completion widget.
for _p in \
  ~/.zsh/ssh-helper.zsh \
  ~/.zsh/fzf-tab/fzf-tab.plugin.zsh \
  ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh \
  ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -r "$_p" ]] && source "$_p"
done
unset _p

# Machine-local settings
# Secrets and per-machine paths belong in ~/.zshrc.local, which is never
# committed. Loaded last so it can override anything set above.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
