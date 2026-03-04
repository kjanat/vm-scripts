#!/usr/bin/env bash
# Install just system-wide from just.systems.
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
	curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
		| bash -s -- --to /usr/local/bin
fi

just --version
generate_completions just "just --completions bash" "just --completions zsh"
