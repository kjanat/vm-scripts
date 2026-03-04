#!/usr/bin/env bash
# Install deno system-wide from denoland/deno releases.
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
generate_completions deno "deno completions bash" "deno completions zsh"
