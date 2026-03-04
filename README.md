# vm-scripts

Provisioning scripts for cloud VMs.

## Scripts

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
curl -fsSL https://raw.github.com/kjanat/vm-scripts/master/gcp/debian-node.sh -o debian-node.sh
chmod +x debian-node.sh
sudo ./debian-node.sh
```

**Or run directly:**

```bash
curl -fsSL https://raw.github.com/kjanat/vm-scripts/master/gcp/debian-node.sh | sudo bash
```
