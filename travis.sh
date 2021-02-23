#!/bin/bash
# Demyx
# https://demyx.sh
set -x

# Get versions 
DEMYX_DOCKER_SOCKET_PROXY_ALPINE_VERSION="$(docker exec --user=root "$DEMYX_REPOSITORY" cat /etc/os-release | grep VERSION_ID | cut -c 12- | sed 's/\r//g')"
DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION="$(docker exec --user=root "$DEMYX_REPOSITORY" haproxy -v | awk '{print $3}' | sed 's/\r//g')"

# Replace versions
sed -i "s|alpine-.*.-informational|alpine-${DEMYX_DOCKER_SOCKET_PROXY_ALPINE_VERSION}-informational|g" README.md
sed -i "s|haproxy-.*.-informational|haproxy-${DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION}-informational|g" README.md

# Echo versions to file
echo "DEMYX_DOCKER_SOCKET_PROXY_ALPINE_VERSION=$DEMYX_DOCKER_SOCKET_PROXY_ALPINE_VERSION
DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION=$DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION" > VERSION

# Push back to GitHub
git config --global user.email "travis@travis-ci.com"
git config --global user.name "Travis CI"
git remote set-url origin https://"$DEMYX_GITHUB_TOKEN"@github.com/demyxco/"$DEMYX_REPOSITORY".git
# Commit VERSION first
git add VERSION
git commit -m "ALPINE $DEMYX_DOCKER_SOCKET_PROXY_ALPINE_VERSION, HAPROXY $DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION"
git push origin HEAD:master
# Commit the rest
git add .
git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"
git push origin HEAD:master
