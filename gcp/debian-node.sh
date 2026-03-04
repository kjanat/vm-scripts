#!/usr/bin/env bash
# Use this script to set up a Debian-based system
# with Node.js, Bun, Deno, and related tools.
#
# Under 'Automation', enter this 'Startup script'
# when creating a new VM instance in GCP:
#
# ```bash
# #!/usr/bin/env bash
# curl -fsSL https://raw.github.com/kjanat/vm-scripts/master/gcp/debian-node.sh -o debian-node.sh
# chmod +x debian-node.sh
# sudo ./debian-node.sh
# ```
#
# Or run directly:
#
# ```bash
# curl -fsSL https://raw.github.com/kjanat/vm-scripts/master/gcp/debian-node.sh | sudo bash
# ```

set -euo pipefail
IFS=$'\n\t'
export DEBIAN_FRONTEND=noninteractive

# shellcheck source=install/_common.sh
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/_common.sh"

log "apt: update/upgrade + deps"
apt-get update -y
apt-get upgrade -y
apt-get install -y --no-install-recommends \
	ca-certificates curl gnupg unzip xz-utils tar \
	build-essential git bash-completion zsh

# Individual tool installs
# shellcheck source=install/shfmt.sh
source "${REPO_DIR}/install/shfmt.sh"
# shellcheck source=install/just.sh
source "${REPO_DIR}/install/just.sh"
# shellcheck source=install/bun.sh
source "${REPO_DIR}/install/bun.sh"
# shellcheck source=install/deno.sh
source "${REPO_DIR}/install/deno.sh"
# shellcheck source=install/dprint.sh
source "${REPO_DIR}/install/dprint.sh"
# shellcheck source=install/volta.sh
source "${REPO_DIR}/install/volta.sh"

# Shell aliases for all users
cat >/etc/profile.d/aliases.sh <<'EOF'
alias ll='ls -lAhF --color=auto --group-directories-first'
EOF
chmod 0644 /etc/profile.d/aliases.sh

log "done"
