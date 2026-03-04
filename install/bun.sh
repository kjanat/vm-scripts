#!/usr/bin/env bash
# Install bun system-wide from oven-sh/bun releases.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		source <(curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh")
	fi
fi

log "bun: install system-wide (/usr/local/bin)"
if ! command -v bun >/dev/null 2>&1; then
	BUN_TAG="$(latest_tag_redirect "oven-sh/bun")"
	case "${ARCH_SHORT}" in
		x86_64) BUN_ASSET="bun-linux-x64.zip" ;;
		aarch64) BUN_ASSET="bun-linux-aarch64.zip" ;;
		*) die "Unsupported arch for bun: ${ARCH_SHORT}" ;;
	esac
	install_zip_bin "https://github.com/oven-sh/bun/releases/download/${BUN_TAG}/${BUN_ASSET}" "bun"
	ln -sf /usr/local/bin/bun /usr/local/bin/bunx
fi

bun --version
generate_completions bun "bun completions" "bun completions"
