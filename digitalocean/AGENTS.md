# digitalocean/

DigitalOcean Droplet provisioning scripts.

## `debian-node.sh`

Debian/Ubuntu on a Droplet. Uses `apt` for system packages. Same tools as
`gcp/debian-node.sh` — no provider CLI is included (doctl is typically used from
a local machine, not on the Droplet itself).

### Editing

- The download list in the `for _f in ...` loop must include every
  `install/*.sh` file that this script sources.
- Provider scripts are near-copies of each other. If you change the tool install
  order or add a new tool, check all other provider directories too.
