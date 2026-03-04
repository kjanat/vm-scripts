#!/usr/bin/env bash
# Install jq system-wide from jqlang/jq GitHub releases.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		source <(curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh")
	fi
fi

log "jq: install system-wide (/usr/local/bin)"
if ! command -v jq >/dev/null 2>&1; then
	JQ_TAG="$(latest_tag_redirect "jqlang/jq")"
	case "${ARCH_SHORT}" in
		x86_64) JQ_ARCH="amd64" ;;
		aarch64) JQ_ARCH="arm64" ;;
		*) die "Unsupported arch for jq: ${ARCH_SHORT}" ;;
	esac
	_tmp="$(mktemp -d)"
	trap 'rm -rf "${_tmp}"' RETURN
	curl -fsSL "https://github.com/jqlang/jq/releases/download/${JQ_TAG}/jq-linux-${JQ_ARCH}" \
		-o "${_tmp}/jq"
	install -m 0755 "${_tmp}/jq" /usr/local/bin/jq
fi

jq --version
