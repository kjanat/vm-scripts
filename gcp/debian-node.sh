#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

# Update package lists and install necessary dependencies
sudo apt update \
	&& sudo apt upgrade -y \
	&& sudo apt install -y \
		curl gnupg unzip build-essential git just shfmt

# Install Bun
curl -fsSL https://bun.com/install | bash

# Add Bun to PATH
export BUN_INSTALL=/home/$USER/.bun
export PATH=$BUN_INSTALL/bin:$PATH

# Install Deno and dprint globally using Bun
bum i -g deno@latest dprint@latest

# Add Deno to PATH
export DENO_INSTALL=/home/$USER/.deno
export PATH=$DENO_INSTALL/bin:$PATH

# Install Node.js using Volta
curl https://get.volta.sh | bash

# Add Volta to PATH
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install \
	node@latest \
	npm@latest

# Verify Node.js installation
node --version
npm --version

# Verify installations
bun --version
deno --version

# Optional: Add the paths to the user's shell profile for persistence
cat <<'EOF' >>~/.bashrc
# Add Bun to PATH
export BUN_INSTALL=/home/$USER/.bun
export PATH=$BUN_INSTALL/bin:$PATH

# Add Deno to PATH
export DENO_INSTALL=/home/$USER/.deno
export PATH=$DENO_INSTALL/bin:$PATH
EOF

# Also add to the system-wide profile for all users
sudo tee -a /etc/profile.d/devtools.sh >/dev/null <<'EOF'
# Add Bun to PATH
export BUN_INSTALL=/home/$USER/.bun
export PATH=$BUN_INSTALL/bin:$PATH

# Add Deno to PATH
export DENO_INSTALL=/home/$USER/.deno
export PATH=$DENO_INSTALL/bin:$PATH
EOF

# Reload the shell profile
source "${HOME}/.bashrc"
