#!/usr/bin/env bash
# Install dprint system-wide from dprint/dprint releases.
# shellcheck source=install/_common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

log "dprint: install system-wide (/usr/local/bin)"
if ! command -v dprint >/dev/null 2>&1; then
	DPRINT_TAG="$(latest_tag_redirect "dprint/dprint")"
	case "${ARCH_SHORT}" in
	x86_64) DPRINT_ASSET="dprint-x86_64-unknown-linux-gnu.zip" ;;
	aarch64) DPRINT_ASSET="dprint-aarch64-unknown-linux-gnu.zip" ;;
	*) die "Unsupported arch for dprint: ${ARCH_SHORT}" ;;
	esac
	install_zip_bin "https://github.com/dprint/dprint/releases/download/${DPRINT_TAG}/${DPRINT_ASSET}" "dprint"
fi

dprint --version
generate_completions dprint "dprint completions bash" "dprint completions zsh"
