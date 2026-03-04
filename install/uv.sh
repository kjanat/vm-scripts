#!/usr/bin/env bash
# Install uv system-wide, then use it to install python, ruff, and ty.
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
if ! command -v uv >/dev/null 2>&1; then
	curl -LsSf https://astral.sh/uv/install.sh | sh
fi

uv --version
uvx --version

# --- python via uv -----------------------------------------------------------
log "uv: install python@latest"
uv python install --default

python3 --version

# --- ruff via uv tool --------------------------------------------------------
log "uv: install ruff@latest"
uv tool install ruff@latest

ruff --version

# --- ty via uv tool -----------------------------------------------------------
log "uv: install ty@latest"
uv tool install ty@latest

ty --version

# --- shell completions --------------------------------------------------------
generate_completions uv "uv generate-shell-completion bash" "uv generate-shell-completion zsh"
generate_completions uvx "uvx --generate-shell-completion bash" "uvx --generate-shell-completion zsh"
generate_completions ruff "ruff generate-shell-completion bash" "ruff generate-shell-completion zsh"
generate_completions ty "ty generate-shell-completion bash" "ty generate-shell-completion zsh"
