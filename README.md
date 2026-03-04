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
dev tools system-wide. The only differences between providers are the header
comments, the package manager (apt vs dnf), and which provider CLI is included.

### [`gcp/debian-node.sh`](gcp/debian-node.sh)

Sets up a Debian-based GCP VM with Node.js and JS/TS tooling. Installs
system-wide to `/usr/local/bin` and `/opt/volta`.

**What it installs:**

| Tool   | Method                          |
| ------ | ------------------------------- |
| shfmt  | Binary from `mvdan/sh` releases |
| just   | Binary from `casey/just`        |
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

### [`aws/debian-node.sh`](aws/debian-node.sh)

Same tools as GCP, plus AWS CLI v2. For Debian/Ubuntu EC2 instances.

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/aws/debian-node.sh | sudo bash
```

### [`aws/amazon-linux-node.sh`](aws/amazon-linux-node.sh)

Same tools as above but uses `dnf` instead of `apt`. For Amazon Linux 2023 EC2
instances.

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/aws/amazon-linux-node.sh | sudo bash
```

### [`azure/debian-node.sh`](azure/debian-node.sh)

Same tools as GCP, plus Azure CLI. For Debian/Ubuntu Azure VMs.

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/azure/debian-node.sh | sudo bash
```

### [`digitalocean/debian-node.sh`](digitalocean/debian-node.sh)

Same tools as GCP (no provider CLI needed on the Droplet itself).

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/vm-scripts/master/digitalocean/debian-node.sh | sudo bash
```

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
