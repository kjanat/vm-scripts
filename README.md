# vm-scripts

Provisioning scripts for cloud VMs.

## Structure

```tree
gcp/
  debian-node.sh    Full Debian setup (apt + all tools)
install/
  _common.sh        Shared helpers (logging, arch detection, completions, GitHub release utils)
  aliases.sh        Shell aliases, functions, and options for bash/zsh
  shfmt.sh          Shell formatter from mvdan/sh
  just.sh           Command runner from just.systems
  bun.sh            JS runtime from oven-sh/bun
  deno.sh           JS/TS runtime from denoland/deno
  dprint.sh         Code formatter from dprint/dprint
  volta.sh          Node toolchain manager + node, npm, pnpm
```

## Provisioning Scripts

### [`gcp/debian-node.sh`](gcp/debian-node.sh)

Sets up a Debian-based GCP VM with Node.js and JS/TS tooling. Installs
system-wide to `/usr/local/bin` and `/opt/volta`.

**What it installs:**

| Tool   | Method                          |
| ------ | ------------------------------- |
| shfmt  | Binary from `mvdan/sh` releases |
| just   | `just.systems/install.sh`       |
| bun    | Binary from `oven-sh/bun`       |
| deno   | Binary from `denoland/deno`     |
| dprint | Binary from `dprint/dprint`     |
| volta  | `get.volta.sh`                  |
| node   | Via Volta                       |
| npm    | Via Volta                       |
| pnpm   | Via Volta                       |

Also configures bash/zsh tab completions and shell aliases for all users.

**Usage (GCP startup script):**

```bash
#!/usr/bin/env bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/gcp/debian-node.sh -o debian-node.sh
chmod +x debian-node.sh
sudo ./debian-node.sh
```

**Or run directly:**

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/gcp/debian-node.sh | sudo bash
```

## Individual Install Scripts

Each script under `install/` is self-contained and can be run standalone. When
run outside a local clone, it auto-fetches `_common.sh` from the repo.

```bash
# Example: install just only
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/install/just.sh | sudo bash
```

All scripts require root. Supports `x86_64` and `aarch64`.

### Shell Completions

Completions are auto-detected (bash-completion installed? zsh available?).
Override with env vars:

```bash
COMPLETIONS_BASH=0 sudo ./debian-node.sh   # disable bash completions
COMPLETIONS_ZSH=1  sudo ./install/bun.sh   # force zsh completions
```
