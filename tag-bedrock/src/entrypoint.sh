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

# Check for autoupdate plugin
if [[ ! -d /home/demyx/.oh-my-zsh/plugins/autoupdate ]]; then
    /usr/bin/git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins.git /home/demyx/.oh-my-zsh/plugins/autoupdate
    /bin/sed -i "s|plugins=(git|plugins=(autoupdate git|g" /home/demyx/.zshrc
fi

# Generate config
/usr/local/bin/demyx-config

# Auto install WordPress if it's not installed already
/usr/local/bin/demyx-install

# Install demyx helper plugin
[[ ! -d "$DEMYX"/web/app/mu-plugins ]] && /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX"/web/app/mu-plugins
/bin/cp "$DEMYX_CONFIG"/bs.php "$DEMYX"/web/app/mu-plugins

# Configure xdebug
if [[ ! -d "$DEMYX"/.vscode ]]; then
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX"/.vscode
    /bin/mv "$DEMYX_CONFIG"/launch.json "$DEMYX"/.vscode
fi

# Set Bedrock to debug mode
/bin/sed -i "s|WP_ENV=.*|WP_ENV=development|g" "$DEMYX"/.env

# Start php-fpm in the background
/usr/local/sbin/php-fpm -D

# Migrate old configs to new directory
[[ -d /home/demyx/.code/data ]] && /bin/mv /home/demyx/.code/data /home/demyx/.config/code-server
[[ -d /home/demyx/.code/extensions ]] && /bin/mv /home/demyx/.code/extensions /home/demyx/.config/code-server

# Generate code-server yaml
/bin/echo "auth: $DEMYX_CODE_AUTH
bind-addr: $DEMYX_CODE_BIND_ADDR
cert: false
disable-telemetry: true
extensions-dir: ${DEMYX_CODE}/extensions
password: $DEMYX_CODE_PASSWORD
user-data-dir: ${DEMYX_CODE}/data" > "$DEMYX_CODE"/config.yaml

# Start code-server
/usr/local/bin/code-server "$DEMYX"
