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

- The `for _f in ...; do` download loop that fetches `install/*.sh` files must
  list every script this file later sources. If you add a new tool source line,
  add the filename to the download list in that loop too.
- Provider scripts are near-copies of each other. If you change the tool install
  order or add a new tool here, check `aws/`, `azure/`, and `digitalocean/` for
  the same change.
