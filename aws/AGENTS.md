# aws/

AWS EC2 provisioning scripts.

## `debian-node.sh`

Debian/Ubuntu on EC2. Uses `apt` for system packages. Same tools as
`gcp/debian-node.sh` plus **AWS CLI v2** (`install/awscli.sh`).

## `amazon-linux-node.sh`

Amazon Linux 2023 on EC2. Uses **`dnf`** instead of `apt`. Same tool set. Key
package differences from Debian: `gnupg2` (not `gnupg`), `gcc gcc-c++ make`
(not `build-essential`), `xz` (not `xz-utils`). No `DEBIAN_FRONTEND` export.

### Editing

- The download list in the `for _f in ...` loop must include every
  `install/*.sh` file that this script sources, including `awscli.sh`.
- Provider scripts are near-copies of each other. If you change the tool install
  order or add a new tool, check all other provider directories too.
