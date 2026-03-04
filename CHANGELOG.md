# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- **Provider scripts**
  - `gcp/debian-node.sh` — Debian provisioning for GCP Compute Engine
  - `aws/debian-node.sh` — Debian provisioning for EC2 (+ AWS CLI v2)
  - `aws/amazon-linux-node.sh` — Amazon Linux 2023 provisioning for EC2 (dnf, +
    AWS CLI v2)
  - `azure/debian-node.sh` — Debian provisioning for Azure VM (+ Azure CLI)
  - `digitalocean/debian-node.sh` — Debian provisioning for DigitalOcean Droplet
- **Installer modules** (`install/`)
  - `_common.sh` — shared helpers: logging, arch detection, completions,
    GitHub release utilities
  - `aliases.sh` — shell aliases, functions, and options for bash/zsh
    (`/etc/profile.d/`)
  - `shfmt.sh` — shell formatter from `mvdan/sh`
  - `just.sh` — command runner from `casey/just`
  - `bun.sh` — JS runtime from `oven-sh/bun`
  - `deno.sh` — JS/TS runtime from `denoland/deno`
  - `dprint.sh` — code formatter from `dprint/dprint`
  - `volta.sh` — Node toolchain manager (+ node, npm, pnpm)
  - `opencode.sh` — AI coding assistant from `anomalyco/opencode`
  - `awscli.sh` — AWS CLI v2 from Amazon's official installer
  - `azcli.sh` — Azure CLI via Microsoft's Debian installer
  - `gh.sh` — GitHub CLI from `cli/cli`
  - `gcloud.sh` — Google Cloud SDK to `/opt/google-cloud-sdk`
  - `jq.sh` — JSON processor from `jqlang/jq`
- `AGENTS.md` files for root, `install/`, `gcp/`, `aws/`, `azure/`, and
  `digitalocean/` directories
- `.dprint.jsonc` config with `shfmt` exec plugin for shell formatting
- `.zed/settings.json` for editor integration

### Fixed

- Stale `just.systems/install.sh` reference in README tools table (now
  `casey/just` GitHub releases)
- EXIT trap in all provider scripts moved before the download loop so temp
  directories are cleaned up on early failures
- Stray leading single-quote in `opencode.sh` zsh completion
  `zsh_eval_context` conditional
- `generate_completions` in `_common.sh` now uses `bash -c` subprocess instead
  of `eval` to isolate from caller's shell context
- Temp dirs in `awscli.sh`, `just.sh`, `opencode.sh`, and `install_zip_bin`
  cleaned up via `trap RETURN` instead of manual `rm -rf` (no leak on failure)
- `volta.sh` wrapper uses unquoted heredoc instead of fragile `sed` replacement
- `python3 --version` in `uv.sh` guarded against PATH failure
- CI benchmark python version detection uses `sudo uv python find` to match
  root-installed managed python
- `jq` added as standalone installer `install/jq.sh` (required by `uv.sh`)
