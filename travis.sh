#!/bin/bash
# Demyx
# https://demyx.sh
# https://github.com/peter-evans/dockerhub-description/blob/master/entrypoint.sh
set -euo pipefail
IFS=$'\n\t'

# Get versions
#DEMYX_ALPINE_VERSION="$(docker run --rm --entrypoint=cat demyx/code-server:alpine /etc/os-release | grep VERSION_ID | cut -c 12- | sed 's/\r//g')"
DEMYX_CODE_DEBIAN_VERSION="$(docker exec "$DEMYX_REPOSITORY" cat /etc/debian_version | sed 's/\r//g')"
DEMYX_CODE_VERSION="$(docker exec "$DEMYX_REPOSITORY" code-server --version | awk -F '[ ]' '{print $1}' | sed 's/\r//g')"

echo "$DEMYX_CODE_DEBIAN_VERSION"
echo "DEMYX_CODE_VERSION=$DEMYX_CODE_VERSION"
