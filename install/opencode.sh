#!/usr/bin/env bash
# Install opencode system-wide from anomalyco/opencode releases.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		source <(curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh")
	fi
fi

log "opencode: install system-wide (/usr/local/bin)"
if ! command -v opencode >/dev/null 2>&1; then
	OC_TAG="$(latest_tag_redirect "anomalyco/opencode")"
	case "${ARCH_SHORT}" in
		x86_64) OC_ARCH="x64" ;;
		aarch64) OC_ARCH="arm64" ;;
		*) die "Unsupported arch for opencode: ${ARCH_SHORT}" ;;
	esac
	_tmp="$(mktemp -d)"
	trap 'rm -rf "${_tmp}"' RETURN
	curl -fsSL "https://github.com/anomalyco/opencode/releases/download/${OC_TAG}/opencode-linux-${OC_ARCH}.tar.gz" \
		| tar xz -C "${_tmp}" opencode
	install -m 0755 "${_tmp}/opencode" /usr/local/bin/opencode
fi

opencode --version

# Completions use yargs — write static scripts (binary may not be on PATH yet)
if [[ -n "${BASH_COMP}" ]]; then
	cat >"${BASH_COMP}/opencode" <<'EOF'
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.bashrc
#    or opencode completion >> ~/.bash_profile on OSX.
#
_opencode_yargs_completions()
{
    local cur_word args type_list
    cur_word="${COMP_WORDS[COMP_CWORD]}"
    args=("${COMP_WORDS[@]}")
    # ask yargs to generate completions.
    # see https://stackoverflow.com/a/40944195/7080036 for the spaces-handling awk
    mapfile -t type_list < <(opencode --get-yargs-completions "${args[@]}")
    mapfile -t COMPREPLY < <(compgen -W "$( printf '%q ' "${type_list[@]}" )" -- "${cur_word}" |
        awk '/ / { print "\""$0"\"" } /^[^ ]+$/ { print $0 }')
    # if no match was found, fall back to filename completion
    if [ ${#COMPREPLY[@]} -eq 0 ]; then
      COMPREPLY=()
    fi
    return 0
}
complete -o bashdefault -o default -F _opencode_yargs_completions opencode
###-end-opencode-completions-###
EOF
fi
if [[ -n "${ZSH_COMP}" ]]; then
	cat >"${ZSH_COMP}/_opencode" <<'ZSHEOF'
#compdef opencode
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.zshrc
#    or opencode completion >> ~/.zprofile on OSX.
#
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###
ZSHEOF
fi
