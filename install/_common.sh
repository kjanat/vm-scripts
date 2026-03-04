#!/usr/bin/env bash
# Shared helpers for individual install scripts.
# Source this file; do not execute directly.
#
# Provides: log, die, REPO_RAW, ARCH_SHORT, BASH_COMP, ZSH_COMP,
#           generate_completions, latest_tag_redirect, install_zip_bin
#
# Completions are conditional — auto-detected from installed shells.
# Override with env vars before sourcing:
#   COMPLETIONS_BASH=0  disable bash completions
#   COMPLETIONS_ZSH=0   disable zsh completions
#   COMPLETIONS_BASH=1   force bash completions even if bash-completion is absent
#   COMPLETIONS_ZSH=1    force zsh completions even if zsh is absent

# Guard against multiple sourcing
[[ -n "${_COMMON_LOADED:-}" ]] && return 0
_COMMON_LOADED=1

set -euo pipefail
IFS=$'\n\t'

REPO_RAW="${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}"
export REPO_RAW

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

# --- Shell completion support ------------------------------------------------
# BASH_COMP / ZSH_COMP are set to the target directory when enabled, or empty
# when disabled. generate_completions checks these before writing.

BASH_COMP=""
case "${COMPLETIONS_BASH:-auto}" in
	1) BASH_COMP="/usr/share/bash-completion/completions" ;;
	0) ;;
	*)
		if [[ -d /usr/share/bash-completion ]]; then
			BASH_COMP="/usr/share/bash-completion/completions"
		fi
		;;
esac

ZSH_COMP=""
case "${COMPLETIONS_ZSH:-auto}" in
	1) ZSH_COMP="/usr/local/share/zsh/site-functions" ;;
	0) ;;
	*)
		if command -v zsh >/dev/null 2>&1; then
			ZSH_COMP="/usr/local/share/zsh/site-functions"
		fi
		;;
esac

[[ -n "${BASH_COMP}" ]] && mkdir -p "${BASH_COMP}"
[[ -n "${ZSH_COMP}" ]] && mkdir -p "${ZSH_COMP}"
export BASH_COMP ZSH_COMP

# generate_completions NAME BASH_CMD ZSH_CMD
# Runs BASH_CMD → $BASH_COMP/NAME   (skipped if BASH_COMP is empty)
# Runs ZSH_CMD  → $ZSH_COMP/_NAME   (skipped if ZSH_COMP is empty)
# SHELL is set explicitly so tools that auto-detect (e.g. bun) get the right value.
# Commands run in a subprocess to isolate from the caller's shell context.
generate_completions() {
	local name="$1" bash_cmd="$2" zsh_cmd="$3"
	if [[ -n "${BASH_COMP}" ]]; then
		SHELL=/bin/bash bash -c "${bash_cmd}" >"${BASH_COMP}/${name}"
	fi
	if [[ -n "${ZSH_COMP}" ]]; then
		SHELL=/bin/zsh bash -c "${zsh_cmd}" >"${ZSH_COMP}/_${name}"
	fi
}

# --- GitHub release helpers --------------------------------------------------

latest_tag_redirect() {
	# avoids GitHub API rate limits: follows /releases/latest redirect
	local repo="$1" tag
	tag="$(curl -fsSLI "https://github.com/${repo}/releases/latest" 2>/dev/null \
		| awk -F/ 'tolower($1) ~ /^location:/ {gsub("\r",""); print $NF; exit}')" || true
	[[ -n "${tag}" ]] || die "Could not resolve latest tag for ${repo}"
	printf '%s' "${tag}"
}

install_zip_bin() {
	local url="$1" binname="$2"
	local tmp
	tmp="$(mktemp -d)"
	trap 'rm -rf "${tmp}"' RETURN
	curl -fsSL -o "${tmp}/asset.zip" "${url}"
	unzip -q "${tmp}/asset.zip" -d "${tmp}"
	local found
	found="$(find "${tmp}" -type f -name "${binname}" 2>/dev/null | head -n1 || true)"
	[[ -n "${found}" ]] || die "Could not find ${binname} in ${url}"
	install -m 0755 "${found}" "/usr/local/bin/${binname}"
}
