#!/usr/bin/env bash
# Install Google Cloud SDK system-wide to /opt/google-cloud-sdk.
# shellcheck source=install/_common.sh
if [[ -z "${_COMMON_LOADED:-}" ]]; then
	_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || _dir=""
	if [[ -f "${_dir}/_common.sh" ]]; then
		source "${_dir}/_common.sh"
	else
		_common_tmp="$(mktemp)"
		curl -fsSL "${REPO_RAW:-https://raw.githubusercontent.com/kjanat/vm-scripts/master}/install/_common.sh" -o "${_common_tmp}"
		source "${_common_tmp}"
		rm -f "${_common_tmp}"
	fi
fi

log "gcloud: install Google Cloud SDK (/opt/google-cloud-sdk)"
if ! command -v gcloud >/dev/null 2>&1; then
	curl -fsSL https://sdk.cloud.google.com | bash -s -- \
		--disable-prompts \
		--install-dir=/opt
	ln -sf /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
	ln -sf /opt/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil
	ln -sf /opt/google-cloud-sdk/bin/bq /usr/local/bin/bq
fi

gcloud version

# gcloud ships its own completion scripts
if [[ -n "${BASH_COMP}" && -f /opt/google-cloud-sdk/completion.bash.inc ]]; then
	cp /opt/google-cloud-sdk/completion.bash.inc "${BASH_COMP}/gcloud"
fi
if [[ -n "${ZSH_COMP}" && -f /opt/google-cloud-sdk/completion.zsh.inc ]]; then
	cp /opt/google-cloud-sdk/completion.zsh.inc "${ZSH_COMP}/_gcloud"
fi
