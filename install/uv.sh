#!/usr/bin/env bash
# Install uv, python, ruff, and ty system-wide.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		source <(curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh")
	fi
fi

# --- uv ----------------------------------------------------------------------
log "uv: install system-wide"
export UV_INSTALL_DIR="/usr/local/bin"
export XDG_BIN_HOME="/usr/local/bin"

if ! command -v uv >/dev/null 2>&1; then
	curl -LsSf https://astral.sh/uv/install.sh | sh
fi

uv --version
uvx --version

# --- python via uv -----------------------------------------------------------
log "uv: install latest stable python"
PYVER="$(uv python list --only-downloads --output-format=json 2>/dev/null \
	| jq -r '[.[] | select(.implementation == "cpython" and .variant == "default"
		and (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")))] | first | .version')"
if [[ -z "${PYVER}" ]]; then
	log "uv: could not determine latest stable python, falling back to default"
	uv python install --default --force
else
	log "uv: installing python ${PYVER}"
	uv python install --default --force "${PYVER}"
fi

python3 --version

# --- ruff from GitHub ---------------------------------------------------------
log "ruff: install from GitHub"
export RUFF_INSTALL_DIR="/usr/local/bin"
if ! command -v ruff >/dev/null 2>&1; then
	curl -LsSf https://astral.sh/ruff/install.sh | sh
fi

ruff --version

# --- ty from GitHub -----------------------------------------------------------
log "ty: install from GitHub"
export TY_INSTALL_DIR="/usr/local/bin"
if ! command -v ty >/dev/null 2>&1; then
	curl -LsSf https://astral.sh/ty/install.sh | sh
fi

ty --version

# --- shell completions --------------------------------------------------------
generate_completions uv "uv generate-shell-completion bash" "uv generate-shell-completion zsh"
generate_completions uvx "uvx --generate-shell-completion bash" "uvx --generate-shell-completion zsh"
generate_completions ruff "ruff generate-shell-completion bash" "ruff generate-shell-completion zsh"
generate_completions ty "ty generate-shell-completion bash" "ty generate-shell-completion zsh"
