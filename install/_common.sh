#!/usr/bin/env bash
# Shared helpers for individual install scripts.
# Source this file; do not execute directly.
#
# Provides: log, die, ARCH_SHORT, BASH_COMP, ZSH_COMP,
#           generate_completions, latest_tag_redirect, install_zip_bin

# Guard against multiple sourcing
[[ -n "${_COMMON_LOADED:-}" ]] && return 0
_COMMON_LOADED=1

set -euo pipefail
IFS=$'\n\t'

log() { printf "\n==> %s\n" "$*"; }
die() {
	printf "\nERROR: %s\n" "$*" >&2
	exit 1
}

_euid="${EUID:-}"
[[ -z "${_euid}" ]] && _euid="$(id -u)"
[[ "${_euid}" -eq 0 ]] || die "Run as root (sudo $0)"

ARCH="$(uname -m)"
case "${ARCH}" in
x86_64 | amd64) ARCH_SHORT="x86_64" ;;
aarch64 | arm64) ARCH_SHORT="aarch64" ;;
*) die "Unsupported arch: ${ARCH}" ;;
esac
export ARCH_SHORT

BASH_COMP="/usr/share/bash-completion/completions"
ZSH_COMP="/usr/local/share/zsh/site-functions"
export BASH_COMP ZSH_COMP
mkdir -p "${BASH_COMP}" "${ZSH_COMP}"

# generate_completions NAME BASH_CMD ZSH_CMD
# Runs BASH_CMD → $BASH_COMP/NAME
# Runs ZSH_CMD  → $ZSH_COMP/_NAME
# SHELL is set explicitly so tools that auto-detect (e.g. bun) get the right value.
generate_completions() {
	local name="$1" bash_cmd="$2" zsh_cmd="$3"
	SHELL=/bin/bash eval "${bash_cmd}" >"${BASH_COMP}/${name}"
	SHELL=/bin/zsh eval "${zsh_cmd}" >"${ZSH_COMP}/_${name}"
}

latest_tag_redirect() {
	# avoids GitHub API rate limits: follows /releases/latest redirect
	local repo="$1" tag
	tag="$(curl -fsSLI "https://github.com/${repo}/releases/latest" 2>/dev/null |
		awk -F/ 'tolower($1) ~ /^location:/ {gsub("\r",""); print $NF; exit}')" || true
	[[ -n "${tag}" ]] || die "Could not resolve latest tag for ${repo}"
	printf '%s' "${tag}"
}

install_zip_bin() {
	local url="$1" binname="$2"
	local tmp
	tmp="$(mktemp -d)"
	curl -fsSL -o "${tmp}/asset.zip" "${url}"
	unzip -q "${tmp}/asset.zip" -d "${tmp}"
	local found
	found="$(find "${tmp}" -type f -name "${binname}" 2>/dev/null | head -n1 || true)"
	[[ -n "${found}" ]] || die "Could not find ${binname} in ${url}"
	install -m 0755 "${found}" "/usr/local/bin/${binname}"
	rm -rf "${tmp}"
}
