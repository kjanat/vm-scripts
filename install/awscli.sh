#!/usr/bin/env bash
# Install AWS CLI v2 system-wide from Amazon's official installer.
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

log "awscli: install AWS CLI v2 system-wide (/usr/local/bin)"
if ! command -v aws >/dev/null 2>&1; then
	_tmp="$(mktemp -d)"
	trap 'rm -rf "${_tmp}"' RETURN
	curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_SHORT}.zip" \
		-o "${_tmp}/awscliv2.zip"
	unzip -q "${_tmp}/awscliv2.zip" -d "${_tmp}"
	"${_tmp}/aws/install" --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin
fi

aws --version

# AWS CLI completions use complete -C style
if [[ -n "${BASH_COMP}" ]]; then
	cat >"${BASH_COMP}/aws" <<'EOF'
complete -C /usr/local/bin/aws_completer aws
EOF
fi
if [[ -n "${ZSH_COMP}" ]]; then
	cat >"${ZSH_COMP}/_aws" <<'EOF'
#compdef aws
autoload -Uz bashcompinit && bashcompinit
complete -C /usr/local/bin/aws_completer aws
EOF
fi
