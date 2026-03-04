#!/usr/bin/env bash
# Install Azure CLI system-wide via Microsoft's official installer (Debian/Ubuntu).
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		_common_tmp="$(mktemp)"
		curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/${BRANCH:-master}}/install/_common.sh" -o "${_common_tmp}"
		source "${_common_tmp}"
		rm -f "${_common_tmp}"
	fi
fi

log "azcli: install Azure CLI system-wide"
if ! command -v az >/dev/null 2>&1; then
	curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash
fi

az version
# Azure CLI package auto-registers bash completions
