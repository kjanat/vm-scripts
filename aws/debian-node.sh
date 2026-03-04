#!/usr/bin/env bash
# Set up a Debian-based AWS EC2 instance with Node.js, Bun, Deno, and related tools.
#
# From a local clone:
#   sudo ./aws/debian-node.sh
#
# Download + run (fetches install scripts automatically):
#   curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/aws/debian-node.sh -o debian-node.sh
#   chmod +x debian-node.sh
#   sudo ./debian-node.sh
#
# Pipe directly:
#   curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/aws/debian-node.sh | sudo bash
#
# Disable completions for a specific shell:
#   COMPLETIONS_ZSH=0 sudo ./debian-node.sh

set -euo pipefail
IFS=$'\n\t'
export DEBIAN_FRONTEND=noninteractive

REPO_RAW="${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}"

# ---------------------------------------------------------------------------
# Resolve install script directory: local clone or temp download
# ---------------------------------------------------------------------------
_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _script_dir=""
_repo_dir="$(cd "${_script_dir}/.." 2>/dev/null && pwd)" || _repo_dir=""
_install_tmp=""

if [[ -f "${_repo_dir}/install/_common.sh" ]]; then
	INSTALL_DIR="${_repo_dir}/install"
else
	_install_tmp="$(mktemp -d)"
	INSTALL_DIR="${_install_tmp}"
	for _f in _common.sh shfmt.sh just.sh bun.sh deno.sh dprint.sh volta.sh awscli.sh aliases.sh; do
		curl -fsSL "${REPO_RAW}/install/${_f}" -o "${INSTALL_DIR}/${_f}"
	done
fi
[[ -n "${_install_tmp}" ]] && trap 'rm -rf "${_install_tmp}"' EXIT

# ---------------------------------------------------------------------------
# Platform dependencies — runs before _common.sh so completion auto-detection
# finds bash-completion and zsh already installed.
# ---------------------------------------------------------------------------
printf "\n==> apt: update/upgrade + deps\n"
apt-get update -y
apt-get upgrade -y
apt-get install -y --no-install-recommends \
	ca-certificates curl gnupg unzip xz-utils tar \
	build-essential git bash-completion zsh

# ---------------------------------------------------------------------------
# Load shared helpers (detects installed shells for completions)
# ---------------------------------------------------------------------------
# shellcheck source=install/_common.sh
source "${INSTALL_DIR}/_common.sh"

# ---------------------------------------------------------------------------
# Individual tool installs (each generates its own completions)
# ---------------------------------------------------------------------------
# shellcheck source=install/shfmt.sh
source "${INSTALL_DIR}/shfmt.sh"
# shellcheck source=install/just.sh
source "${INSTALL_DIR}/just.sh"
# shellcheck source=install/bun.sh
source "${INSTALL_DIR}/bun.sh"
# shellcheck source=install/deno.sh
source "${INSTALL_DIR}/deno.sh"
# shellcheck source=install/dprint.sh
source "${INSTALL_DIR}/dprint.sh"
# shellcheck source=install/volta.sh
source "${INSTALL_DIR}/volta.sh"

# ---------------------------------------------------------------------------
# Provider CLI
# ---------------------------------------------------------------------------
# shellcheck source=install/awscli.sh
source "${INSTALL_DIR}/awscli.sh"

# Shell aliases and options for all users
# shellcheck source=install/aliases.sh
source "${INSTALL_DIR}/aliases.sh"

log "done"
