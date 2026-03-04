#!/usr/bin/env bash
# Install deno system-wide from denoland/deno releases.
# shellcheck source=install/_common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

log "deno: install system-wide (/usr/local/bin)"
if ! command -v deno >/dev/null 2>&1; then
	DENO_TAG="$(latest_tag_redirect "denoland/deno")"
	case "${ARCH_SHORT}" in
		x86_64) DENO_ASSET="deno-x86_64-unknown-linux-gnu.zip" ;;
		aarch64) DENO_ASSET="deno-aarch64-unknown-linux-gnu.zip" ;;
		*) die "Unsupported arch for deno: ${ARCH_SHORT}" ;;
	esac
	install_zip_bin "https://github.com/denoland/deno/releases/download/${DENO_TAG}/${DENO_ASSET}" "deno"
fi

deno --version
