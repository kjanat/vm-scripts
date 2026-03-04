# vm-scripts

Provisioning scripts for cloud VMs.

## Structure

```tree
gcp/
  debian-node.sh              Debian setup for GCP Compute Engine
aws/
  debian-node.sh              Debian setup for EC2 (+ AWS CLI)
  amazon-linux-node.sh        Amazon Linux 2023 setup for EC2 (dnf, + AWS CLI)
azure/
  debian-node.sh              Debian setup for Azure VM (+ Azure CLI)
digitalocean/
  debian-node.sh              Debian setup for DigitalOcean Droplet
install/
  _common.sh                  Shared helpers (logging, arch detection, completions, GitHub release utils)
  aliases.sh                  Shell aliases, functions, and options for bash/zsh
  awscli.sh                   AWS CLI v2 from Amazon's official installer
  azcli.sh                    Azure CLI via Microsoft's Debian installer
  gcloud.sh                   Google Cloud SDK to /opt/google-cloud-sdk
  opencode.sh                 AI coding assistant from anomalyco/opencode
  shfmt.sh                    Shell formatter from mvdan/sh
  just.sh                     Command runner from casey/just
  bun.sh                      JS runtime from oven-sh/bun
  deno.sh                     JS/TS runtime from denoland/deno
  dprint.sh                   Code formatter from dprint/dprint
  volta.sh                    Node toolchain manager + node, npm, pnpm
```

## Provisioning Scripts

Each provider directory contains a ready-to-run script that installs all JS/TS
dev tools system-wide to `/usr/local/bin` and `/opt/volta`. The only differences
between providers are the package manager (`apt` vs `dnf`) and which provider
CLI is included.

**Common tools installed by every script:**

| Tool   | Method                                                          |
| ------ | --------------------------------------------------------------- |
| shfmt  | Binary from [`mvdan/sh`](https://github.com/mvdan/sh)           |
| just   | Binary from [`casey/just`](https://github.com/casey/just)       |
| bun    | Binary from [`oven-sh/bun`](https://github.com/oven-sh/bun)     |
| deno   | Binary from [`denoland/deno`](https://github.com/denoland/deno) |
| dprint | Binary from [`dprint/dprint`](https://github.com/dprint/dprint) |
| volta  | [`get.volta.sh`](https://volta.sh)                              |
| node   | Via Volta                                                       |
| npm    | Via Volta                                                       |
| pnpm   | Via Volta                                                       |

All scripts also configure bash/zsh tab completions and shell aliases for all
users.

**Usage — pipe directly or download first:**

```bash
# pipe to bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/<provider>/<script>.sh | sudo bash

# or download, then run
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/<provider>/<script>.sh -o setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

**Available scripts:**

| Script                                                       | Provider             | Base OS                 | Extra CLI  |
| ------------------------------------------------------------ | -------------------- | ----------------------- | ---------- |
| [`gcp/debian-node.sh`](gcp/debian-node.sh)                   | GCP Compute Engine   | Debian (apt)            | —          |
| [`aws/debian-node.sh`](aws/debian-node.sh)                   | AWS EC2              | Debian (apt)            | AWS CLI v2 |
| [`aws/amazon-linux-node.sh`](aws/amazon-linux-node.sh)       | AWS EC2              | Amazon Linux 2023 (dnf) | AWS CLI v2 |
| [`azure/debian-node.sh`](azure/debian-node.sh)               | Azure VM             | Debian (apt)            | Azure CLI  |
| [`digitalocean/debian-node.sh`](digitalocean/debian-node.sh) | DigitalOcean Droplet | Debian (apt)            | —          |

## Individual Install Scripts

Each script under `install/` is self-contained and can be run standalone. When
run outside a local clone, it auto-fetches `_common.sh` from the repo.

```bash
# Example: install just only
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/install/just.sh | sudo bash
```

All scripts require root. Supports `x86_64` and `aarch64`.

### Provider CLI Tools

The provider CLI modules can be mixed into any provisioning script or run
standalone:

```bash
# Install AWS CLI v2 only
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/install/awscli.sh | sudo bash

# Install Google Cloud SDK only
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/install/gcloud.sh | sudo bash

# Install Azure CLI only (Debian/Ubuntu)
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/install/azcli.sh | sudo bash
```

### Shell Completions

Completions are auto-detected (bash-completion installed? zsh available?).
Override with env vars:

```bash
COMPLETIONS_BASH=0 sudo ./debian-node.sh   # disable bash completions
COMPLETIONS_ZSH=1  sudo ./install/bun.sh   # force zsh completions
```
