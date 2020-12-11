#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Support for old variables
[[ -n "${BROWSERSYNC_PROXY:-}" ]] && DEMYX_PROXY="$BROWSERSYNC_PROXY"
[[ -n "${OPENLITESPEED_CONFIG:-}" ]] && DEMYX_CONFIG="$OPENLITESPEED_ROOT"
[[ -n "${OPENLITESPEED_ROOT:-}" ]] && DEMYX="$OPENLITESPEED_ROOT"

# Define variables
SAGE_COMMAND="${1:-help}"
SAGE_THEME="${2:-sage}"
SAGE_WEBPACK_CONFIG="$DEMYX"/web/app/themes/"$SAGE_THEME"/resources/assets/build/webpack.config.watch.js

sage_cmd() {
    /bin/echo -e "[\e[34m${SAGE_THEME}\e[39m] yarn ${SAGE_COMMAND}"
    /usr/local/bin/yarn --cwd="$DEMYX"/web/app/themes/"$SAGE_THEME" "$@"
}

sage_init() {
    WP_HOME="$(/bin/grep WP_HOME= "$DEMYX"/.env | /usr/bin/awk -F '[=]' '{print $2}')"
    WP_DOMAIN="$(/bin/echo "$WP_HOME" | /usr/bin/awk -F/ '{print $3}')"

    if [[ ! -d "$DEMYX"/web/app/themes/"$SAGE_THEME" ]]; then
        /bin/echo -e "\n\e[31m${SAGE_THEME} doesn't exist\e[39m\n"
        sage_help
    fi

    /bin/echo -e "$(/bin/cat "$DEMYX_CONFIG"/bs.js)\n$(cat "$SAGE_WEBPACK_CONFIG")" > "$SAGE_WEBPACK_CONFIG"
    /bin/sed -i "s|delay: 500|delay: 500, advanced: demyxBS|g" "$SAGE_WEBPACK_CONFIG"
    /bin/sed -i "s|config.proxyUrl +|'$WP_HOME' +|g" "$SAGE_WEBPACK_CONFIG"
    /bin/sed -i "s|domain.tld|$WP_DOMAIN|g" "$SAGE_WEBPACK_CONFIG"
    /bin/sed -i "s|\"devUrl\": .*|\"devUrl\": \"${DEMYX_PROXY:-}\",|g" "$DEMYX"/web/app/themes/"$SAGE_THEME"/resources/assets/config.json
    /bin/echo -e "\nmodule.hot.accept();" >> "$DEMYX"/web/app/themes/"$SAGE_THEME"/resources/assets/scripts/main.js
}

sage_help() {
    /bin/echo "sage <arg>       Sage helper script"
    /bin/echo
    /bin/echo "     cmd         Run yarn commands"
    /bin/echo "                 Ex: sage cmd theme-name yarn-commands"
    /bin/echo
    /bin/echo "     init        Initializes fixes for webpack"
    /bin/echo "                 Ex: sage init theme-name"
    /bin/echo
    /bin/echo "     help        Help menu for sage helper script"
    /bin/echo "                 Ex: sage help"
    /bin/echo
    /bin/echo "     new         Executes composer create-project, yarn, and sage init theme-name"
    /bin/echo "                 Ex: sage new theme-name"
}

sage_new() {
    if [[ -d "$DEMYX"/web/app/themes/"$SAGE_THEME" ]]; then
        /bin/echo -e "\n\e[31m$SAGE_THEME already exists\e[39m\n"
        exit 1
    fi

    /usr/local/bin/composer create-project roots/sage "$DEMYX"/web/app/themes/"$SAGE_THEME"
    /usr/local/bin/yarn --cwd="$DEMYX"/web/app/themes/"$SAGE_THEME"
    /usr/local/bin/wp theme activate "$SAGE_THEME"/resources
    sage_init "$SAGE_THEME"
}

case "$SAGE_COMMAND" in
    cmd)
        shift 2
        sage_cmd "$@"
    ;;
    init)
        sage_init
    ;;
    help)
        sage_help
    ;;
    new)
        sage_new
    ;;
    *)
        sage_help
    ;;
esac
