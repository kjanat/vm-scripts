#!/usr/bin/env bash
# Install shfmt system-wide from mvdan/sh releases.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		source <(curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh")
	fi
fi

log "shfmt: install system-wide (/usr/local/bin)"
if ! command -v shfmt >/dev/null 2>&1; then
	SHFMT_TAG="$(latest_tag_redirect "mvdan/sh")"
	case "${ARCH_SHORT}" in
		x86_64) SHFMT_ARCH="amd64" ;;
		aarch64) SHFMT_ARCH="arm64" ;;
		*) die "Unsupported arch for shfmt: ${ARCH_SHORT}" ;;
	esac
	curl -fsSL -o /usr/local/bin/shfmt \
		"https://github.com/mvdan/sh/releases/download/${SHFMT_TAG}/shfmt_${SHFMT_TAG}_linux_${SHFMT_ARCH}"
	chmod 0755 /usr/local/bin/shfmt
fi

shfmt --version
