# azure/

Azure VM provisioning scripts.

## `debian-node.sh`

Debian/Ubuntu on Azure. Uses `apt` for system packages. Same tools as
`gcp/debian-node.sh` plus **Azure CLI** (`install/azcli.sh`).

### Editing

- The download list in the `for _f in ...` loop must include every
  `install/*.sh` file that this script sources, including `azcli.sh`.
- Provider scripts are near-copies of each other. If you change the tool install
  order or add a new tool, check all other provider directories too.
