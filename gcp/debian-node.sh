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

latest_tag_redirect() {
	# avoids GitHub API rate limits: follows /releases/latest redirect
	local repo="$1"
	curl -fsSLI "https://github.com/${repo}/releases/latest" \
		| awk -F/ 'tolower($1) ~ /^location:/ {gsub("\r",""); print $NF; exit}'
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

log "apt: update/upgrade + deps"
apt-get update -y
apt-get upgrade -y
apt-get install -y --no-install-recommends \
	ca-certificates curl gnupg unzip xz-utils tar \
	build-essential git bash-completion zsh

log "shfmt: install system-wide (/usr/local/bin)"
if ! command -v shfmt >/dev/null 2>&1; then
	SHFMT_TAG="$(latest_tag_redirect "mvdan/sh")"
	case "${ARCH_SHORT}" in
		x86_64) SHFMT_ARCH="amd64" ;;
		aarch64) SHFMT_ARCH="arm64" ;;
		*) die "Unsupported arch for shfmt: ${ARCH_SHORT}" ;;
	esac
	curl -fsSL -o /usr/local/bin/shfmt \
		"https://github.com/mvdan/sh/releases/download/${SHFMT_TAG}/shfmt_${SHFMT_TAG}_linux_${SHFMT_ARCH}"
	chmod 0755 /usr/local/bin/shfmt
fi

log "just: install system-wide (/usr/local/bin)"
if ! command -v just >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
		| bash -s -- --to /usr/local/bin
fi

log "bun: install system-wide (/usr/local/bin)"
if ! command -v bun >/dev/null 2>&1; then
	BUN_TAG="$(latest_tag_redirect "oven-sh/bun")"
	case "${ARCH_SHORT}" in
		x86_64) BUN_ASSET="bun-linux-x64.zip" ;;
		aarch64) BUN_ASSET="bun-linux-aarch64.zip" ;;
		*) die "Unsupported arch for bun: ${ARCH_SHORT}" ;;
	esac
	install_zip_bin "https://github.com/oven-sh/bun/releases/download/${BUN_TAG}/${BUN_ASSET}" "bun"
	ln -sf /usr/local/bin/bun /usr/local/bin/bunx
fi

log "deno: install system-wide (/usr/local/bin)"
if ! command -v deno >/dev/null 2>&1; then
	DENO_TAG="$(latest_tag_redirect "denoland/deno")"
	case "${ARCH_SHORT}" in
		x86_64) DENO_ASSET="deno-x86_64-unknown-linux-gnu.zip" ;;
		aarch64) DENO_ASSET="deno-aarch64-unknown-linux-gnu.zip" ;;
		*) die "Unsupported arch for deno: ${ARCH_SHORT}" ;;
	esac
	install_zip_bin "https://github.com/denoland/deno/releases/download/${DENO_TAG}/${DENO_ASSET}" "deno"
fi

log "dprint: install system-wide (/usr/local/bin)"
if ! command -v dprint >/dev/null 2>&1; then
	DPRINT_TAG="$(latest_tag_redirect "dprint/dprint")"
	case "${ARCH_SHORT}" in
		x86_64) DPRINT_ASSET="dprint-x86_64-unknown-linux-gnu.zip" ;;
		aarch64) DPRINT_ASSET="dprint-aarch64-unknown-linux-gnu.zip" ;;
		*) die "Unsupported arch for dprint: ${ARCH_SHORT}" ;;
	esac
	install_zip_bin "https://github.com/dprint/dprint/releases/download/${DPRINT_TAG}/${DPRINT_ASSET}" "dprint"
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

# Hard wrappers so it works in non-login shells too (cron, cloud-init leftovers, etc.)
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

log "completions: generate for bash + zsh"
BASH_COMP="/usr/share/bash-completion/completions"
ZSH_COMP="/usr/local/share/zsh/site-functions"
mkdir -p "${BASH_COMP}" "${ZSH_COMP}"

volta completions bash >"${BASH_COMP}/volta"
volta completions zsh >"${ZSH_COMP}/_volta"

just --completions bash >"${BASH_COMP}/just"
just --completions zsh >"${ZSH_COMP}/_just"

deno completions bash >"${BASH_COMP}/deno"
deno completions zsh >"${ZSH_COMP}/_deno"

dprint completions bash >"${BASH_COMP}/dprint"
dprint completions zsh >"${ZSH_COMP}/_dprint"

npm completion >"${BASH_COMP}/npm"
npm completion >"${ZSH_COMP}/_npm"

pnpm completion bash >"${BASH_COMP}/pnpm"
pnpm completion zsh >"${ZSH_COMP}/_pnpm"

log "verify"
volta --version
node --version
npm --version
pnpm --version
shfmt --version
just --version
bun --version
deno --version
dprint --version

log "done"
