# gcp/

GCP Compute Engine provisioning scripts.

## `debian-node.sh`

Sets up a Debian-based GCP VM with JS/TS dev tools. Uses `apt` for system
packages.

**Tools installed:** shfmt, just, bun, deno, dprint, volta (+ node, npm, pnpm),
shell aliases.

**No provider CLI included** — GCP images ship with `gcloud` pre-installed. Use
`install/gcloud.sh` standalone if needed on a non-GCP machine.

### Editing

- The download list in the `for _f in ...` loop (line 36) must include every
  `install/*.sh` file that this script sources. If you add a new tool source
  line, add it to the download list too.
- Provider scripts are near-copies of each other. If you change the tool install
  order or add a new tool here, check `aws/`, `azure/`, and `digitalocean/` for
  the same change.
