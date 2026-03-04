#!/usr/bin/env bash
# Install just system-wide from just.systems.
# shellcheck source=install/_common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

log "just: install system-wide (/usr/local/bin)"
if ! command -v just >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh |
		bash -s -- --to /usr/local/bin
fi

just --version
generate_completions just "just --completions bash" "just --completions zsh"
