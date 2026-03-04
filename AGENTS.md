# vm-scripts

Provisioning scripts for cloud VMs. Installs JS/TS dev tools system-wide on
Linux (Debian/Ubuntu and Amazon Linux).

## Repository layout

- `gcp/`, `aws/`, `azure/`, `digitalocean/` — provider-specific entry-point
  scripts. Each is self-contained and curl-pipeable.
- `install/` — modular, standalone install scripts. Each installs one tool from
  GitHub releases or an official installer. Sourced by the provider scripts.
- `install/_common.sh` — shared helpers sourced by every install script.

## Conventions

### Shell scripts

- All scripts use `#!/usr/bin/env bash` with `set -euo pipefail` and
  `IFS=$'\n\t'`.
- Indentation: tabs (matching `shfmt -i 0`).
- Formatting: `shfmt -i 0 -ln bash -bn -ci` via dprint (see `.dprint.jsonc`).
- ShellCheck-clean: use `# shellcheck source=...` annotations for sourced files.

### Install scripts (`install/*.sh`)

Every install script follows this pattern:

1. `_common.sh` bootstrap guard — auto-fetch from GitHub if not local.
2. `log "toolname: ..."` — announce what's being installed.
3. `if ! command -v tool` guard — skip if already installed.
4. Install to `/usr/local/bin` (or `/opt/` for larger tools like volta, gcloud).
5. Print version.
6. Generate/write shell completions using `BASH_COMP` / `ZSH_COMP` variables.

Use `latest_tag_redirect "owner/repo"` to resolve latest GitHub release tags
(avoids API rate limits). Use `install_zip_bin` for `.zip` assets; for `.tar.gz`
assets, use `curl | tar xz` directly.

### Provider scripts (`{provider}/debian-node.sh`)

Each provider wrapper:

1. Resolves install dir (local clone or downloads scripts to a temp dir).
2. Installs OS packages (`apt` for Debian, `dnf` for Amazon Linux).
3. Sources `_common.sh`, then each `install/*.sh` in order.
4. Sources any provider-specific CLI module (awscli, azcli, etc.).
5. Sources `aliases.sh` last.

### Completions

- Bash: `${BASH_COMP}` → `/usr/share/bash-completion/completions/`
- Zsh: `${ZSH_COMP}` → `/usr/local/share/zsh/site-functions/`
- Use `generate_completions name "bash_cmd" "zsh_cmd"` when the tool can output
  completions to stdout. Use static heredocs (like `awscli.sh`, `opencode.sh`)
  when the tool uses non-standard completion mechanisms.

### Architecture support

All scripts support `x86_64` and `aarch64`. Map via `ARCH_SHORT` from
`_common.sh`. Asset naming varies per project — check existing scripts for
examples of the `case` mapping pattern.
