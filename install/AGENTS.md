# install/

Modular, standalone install scripts. Each installs one tool system-wide.

## Key files

- `_common.sh` — shared helpers, sourced by all other scripts. Provides: `log`,
  `die`, `REPO_RAW`, `ARCH_SHORT`, `BASH_COMP`, `ZSH_COMP`,
  `generate_completions`, `latest_tag_redirect`, `install_zip_bin`. Requires
  root. Guards against multiple sourcing via `_COMMON_LOADED`.
- `aliases.sh` — writes `/etc/profile.d/aliases.sh`, `aliases-bash.sh`, and
  `aliases-zsh.sh`. Not a tool installer — configures shell environment.

## Adding a new install script

1. Copy the boilerplate from any existing script (e.g., `bun.sh`):
   - `_common.sh` guard with auto-fetch fallback
   - `log "toolname: ..."` announcement
   - `if ! command -v tool` skip guard
2. Use `latest_tag_redirect "owner/repo"` to get the latest release tag.
3. Map architecture with a `case` on `ARCH_SHORT` (x86_64 / aarch64). Each
   project uses different arch names in their asset filenames — check the
   project's GitHub releases.
4. Install the binary:
   - `.zip` assets: use `install_zip_bin "$url" "binname"`
   - `.tar.gz` assets: `curl -fsSL "$url" | tar xz -C /usr/local/bin binname`
   - Raw binaries: `curl -fsSL -o /usr/local/bin/tool "$url" && chmod 0755 ...`
   - External installers: `curl -fsSL https://... | bash -s -- --flags`
5. Print version: `tool --version`
6. Set up completions:
   - If the tool has `tool completions bash/zsh` commands:
     `generate_completions toolname "tool completions bash" "tool completions zsh"`
   - If completions ship in the tarball: extract and `cp` to `BASH_COMP`/`ZSH_COMP`
   - If the tool uses non-standard completions (yargs, `complete -C`): write
     static heredocs to `${BASH_COMP}/tool` and `${ZSH_COMP}/_tool`

## Scripts overview

| Script        | Tool             | Install method            | Completions            |
| ------------- | ---------------- | ------------------------- | ---------------------- |
| `shfmt.sh`    | shfmt            | Raw binary from GitHub    | None                   |
| `just.sh`     | just             | tar.gz from GitHub        | Bundled in tarball     |
| `bun.sh`      | bun              | zip from GitHub           | `bun completions`      |
| `deno.sh`     | deno             | zip from GitHub           | `deno completions`     |
| `dprint.sh`   | dprint           | zip from GitHub           | `dprint completions`   |
| `volta.sh`    | volta+node+pnpm  | `get.volta.sh` + wrappers | `volta completions`    |
| `opencode.sh` | opencode         | tar.gz from GitHub        | Static yargs heredocs  |
| `awscli.sh`   | AWS CLI v2       | Official zip installer    | Static `complete -C`   |
| `azcli.sh`    | Azure CLI        | Microsoft apt installer   | Auto-registered by pkg |
| `gcloud.sh`   | Google Cloud SDK | `sdk.cloud.google.com`    | Bundled completion files      |
| `aliases.sh`  | (shell config)   | Writes to /etc/profile.d/ | N/A                    |
