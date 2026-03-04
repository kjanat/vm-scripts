#!/usr/bin/env bash
# Install shfmt system-wide from mvdan/sh releases.
# shellcheck source=install/_common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

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
