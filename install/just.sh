#!/usr/bin/env bash
# Install just system-wide from casey/just releases.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		source <(curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh")
	fi
fi

log "just: install system-wide (/usr/local/bin)"
if ! command -v just >/dev/null 2>&1; then
	JUST_TAG="$(latest_tag_redirect "casey/just")"
	case "${ARCH_SHORT}" in
		x86_64) JUST_ARCH="x86_64" ;;
		aarch64) JUST_ARCH="aarch64" ;;
		*) die "Unsupported arch for just: ${ARCH_SHORT}" ;;
	esac
	_tmp="$(mktemp -d)"
	trap 'rm -rf "${_tmp}"' RETURN
	curl -fsSL "https://github.com/casey/just/releases/download/${JUST_TAG}/just-${JUST_TAG}-${JUST_ARCH}-unknown-linux-musl.tar.gz" \
		| tar xz -C "${_tmp}" just completions/just.bash completions/just.zsh
	install -m 0755 "${_tmp}/just" /usr/local/bin/just
	[[ -n "${BASH_COMP}" ]] && cp "${_tmp}/completions/just.bash" "${BASH_COMP}/just"
	[[ -n "${ZSH_COMP}" ]] && cp "${_tmp}/completions/just.zsh" "${ZSH_COMP}/_just"
fi

just --version
