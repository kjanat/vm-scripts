#!/usr/bin/env bash
# Configure shell aliases, functions, and options for all users.
# Writes to /etc/profile.d/ so settings apply to both bash and zsh.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		_common_tmp="$(mktemp)"
		curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh" -o "${_common_tmp}"
		source "${_common_tmp}"
		rm -f "${_common_tmp}"
	fi
fi

log "aliases: configure shell aliases and options for all users"

# --- Common aliases (bash + zsh) ---------------------------------------------
cat >/etc/profile.d/aliases.sh <<'COMMON_EOF'
# Common shell aliases — sourced by both bash and zsh via /etc/profile.d/

# --- ls variants -------------------------------------------------------------
alias ll='ls -lAhF --color=auto --group-directories-first'
alias la='ls -AhF --color=auto'
alias l='ls -CF --color=auto'

# --- Navigation --------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Safety ------------------------------------------------------------------
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'

# --- Colorized output --------------------------------------------------------
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

# --- Disk & system -----------------------------------------------------------
alias df='df -h'
alias du='du -h'
alias free='free -h'

# --- Networking --------------------------------------------------------------
alias ports='ss -tulnp'

# --- Git shortcuts -----------------------------------------------------------
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'

# --- Utility functions -------------------------------------------------------
# mkcd: create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# path: pretty-print PATH, one entry per line
path() { echo "${PATH}" | tr ':' '\n'; }
COMMON_EOF
chmod 0644 /etc/profile.d/aliases.sh

# --- Bash-specific -----------------------------------------------------------
cat >/etc/profile.d/aliases-bash.sh <<'BASH_EOF'
# Bash-specific shell options — guarded; returns early in other shells
[[ -n "${BASH_VERSION:-}" ]] || return 0

# --- Shell options -----------------------------------------------------------
shopt -s histappend       # append to history, don't overwrite
shopt -s checkwinsize     # update LINES/COLUMNS after each command
shopt -s cdspell          # autocorrect minor cd typos
shopt -s dirspell         # autocorrect directory name typos in completion
shopt -s globstar 2>/dev/null  # ** recursive glob (bash 4+)

# --- History tuning ----------------------------------------------------------
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
BASH_EOF
chmod 0644 /etc/profile.d/aliases-bash.sh

# --- Zsh-specific ------------------------------------------------------------
cat >/etc/profile.d/aliases-zsh.sh <<'ZSH_EOF'
# Zsh-specific shell options — guarded; returns early in other shells
[[ -n "${ZSH_VERSION:-}" ]] || return 0

# --- Shell options -----------------------------------------------------------
setopt AUTO_CD              # type a directory name to cd into it
setopt CORRECT              # offer correction for mistyped commands
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS   # remove unnecessary blanks from history
setopt SHARE_HISTORY        # share history across sessions
setopt APPEND_HISTORY       # append rather than overwrite
setopt EXTENDED_GLOB        # extended globbing (#, ~, ^)
setopt NO_CASE_GLOB         # case-insensitive globbing

# --- History tuning ----------------------------------------------------------
export HISTSIZE=10000
export SAVEHIST=20000

# --- Global aliases (zsh only) -----------------------------------------------
# These expand anywhere in a command line, not just at the start.
# e.g. "ls G foo" becomes "ls | grep foo". Unset with "unalias -g G" if unwanted.
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc -l'
alias -g S='| sort'
alias -g U='| sort -u'
ZSH_EOF
chmod 0644 /etc/profile.d/aliases-zsh.sh
