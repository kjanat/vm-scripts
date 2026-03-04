#!/usr/bin/env bash
# Install volta system-wide to /opt/volta with node, npm, pnpm.
# Sets up profile.d env and hard wrappers for non-login shells.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		_common_tmp="$(mktemp)"
		curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh" -o "${_common_tmp}"
		source "${_common_tmp}"
		rm -f "${_common_tmp}"
	fi
fi

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
	cat >"/usr/local/bin/${name}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
export VOLTA_HOME="/opt/volta"
export VOLTA_FEATURE_PNPM=1
export PATH="\$VOLTA_HOME/bin:\$PATH"
exec "\$VOLTA_HOME/bin/${name}" "\$@"
EOF
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
