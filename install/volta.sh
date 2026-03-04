#!/usr/bin/env bash
# Install volta system-wide to /opt/volta with node, npm, pnpm.
# Sets up profile.d env and hard wrappers for non-login shells.
# shellcheck source=install/_common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

log "volta: install system-wide (/opt/volta)"
export VOLTA_HOME="/opt/volta"
export VOLTA_FEATURE_PNPM=1
mkdir -p "${VOLTA_HOME}"
chmod 0755 "${VOLTA_HOME}"

if [[ ! -x "${VOLTA_HOME}/bin/volta" ]]; then
	curl -fsSL https://get.volta.sh | bash -s -- --skip-setup
fi

# PATH + pnpm feature flag for login shells (all users)
cat >/etc/profile.d/volta.sh <<'EOF'
export VOLTA_HOME="/opt/volta"
export VOLTA_FEATURE_PNPM=1
export PATH="$VOLTA_HOME/bin:$PATH"
EOF
chmod 0644 /etc/profile.d/volta.sh

# Hard wrappers so it works in non-login shells too (cron, cloud-init, etc.)
wrap() {
	local name="$1"
	cat >"/usr/local/bin/${name}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export VOLTA_HOME="/opt/volta"
export PATH="$VOLTA_HOME/bin:$PATH"
exec "$VOLTA_HOME/bin/REPLACE_ME" "$@"
EOF
	sed -i "s/REPLACE_ME/${name}/g" "/usr/local/bin/${name}"
	chmod 0755 "/usr/local/bin/${name}"
}
wrap volta
wrap node
wrap npm
wrap npx
wrap pnpm

log "volta: install node@latest + npm@latest + pnpm@latest"
"${VOLTA_HOME}/bin/volta" install node@latest npm@latest pnpm@latest

volta --version
node --version
npm --version
pnpm --version

generate_completions volta "volta completions bash" "volta completions zsh"
generate_completions npm "npm completion" "npm completion"
generate_completions pnpm "pnpm completion bash" "pnpm completion zsh"
