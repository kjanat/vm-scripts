#!/usr/bin/env bash
# Install GitHub CLI system-wide from cli/cli releases.
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

log "gh: install GitHub CLI system-wide (/usr/local/bin)"
if ! command -v gh >/dev/null 2>&1; then
	GH_TAG="$(latest_tag_redirect "cli/cli")"
	GH_VER="${GH_TAG#v}"
	case "${ARCH_SHORT}" in
	x86_64) GH_ARCH="amd64" ;;
	aarch64) GH_ARCH="arm64" ;;
	*) die "Unsupported arch for gh: ${ARCH_SHORT}" ;;
	esac
	_tmp="$(mktemp -d)"
	trap 'rm -rf "${_tmp}"' RETURN
	curl -fsSL "https://github.com/cli/cli/releases/download/${GH_TAG}/gh_${GH_VER}_linux_${GH_ARCH}.tar.gz" |
		tar xz -C "${_tmp}" --strip-components=2 "gh_${GH_VER}_linux_${GH_ARCH}/bin/gh"
	install -m 0755 "${_tmp}/gh" /usr/local/bin/gh
fi

gh --version

generate_completions gh "gh completion -s bash" "gh completion -s zsh"
