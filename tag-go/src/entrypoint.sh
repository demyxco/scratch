#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Support for old password variable
[[ -n "${PASSWORD:-}" ]] && DEMYX_PASSWORD="$PASSWORD"

# Copy code directory/configs if it doesn't exist
if [[ ! -d /home/demyx/.config ]]; then
    /bin/mkdir -p /home/demyx/.config
    /bin/cp -r "$DEMYX_CONFIG"/code-server /home/demyx/.config
fi

# Copy ctop settings if it doesn't exist
if [[ ! -f /home/demyx/.ctop ]]; then
    /bin/cp "$DEMYX_CONFIG"/ctop /home/demyx/.ctop
fi

# Check for autoupdate plugin
if [[ ! -d /home/demyx/.oh-my-zsh/plugins/autoupdate ]]; then
    /usr/bin/git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins.git /home/demyx/.oh-my-zsh/plugins/autoupdate
    /bin/sed -i "s|plugins=(git|plugins=(autoupdate git|g" /home/demyx/.zshrc
fi

# Migrate old configs to new directory
[[ -d /home/demyx/.code/data ]] && /bin/mv /home/demyx/.code/data /home/demyx/.config/code-server
[[ -d /home/demyx/.code/extensions ]] && /bin/mv /home/demyx/.code/extensions /home/demyx/.config/code-server

# Generate code-server yaml
/bin/echo "auth: $DEMYX_AUTH
bind-addr: $DEMYX_BIND_ADDR
cert: false
disable-telemetry: true
extensions-dir: ${DEMYX_CODE}/extensions
password: $DEMYX_PASSWORD
user-data-dir: ${DEMYX_CODE}/data" > "$DEMYX_CODE"/config.yaml

# Start code-server
/usr/local/bin/code-server /home/demyx
