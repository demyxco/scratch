#!/bin/bash
# Demyx
# https://demyx.sh

# Get versions
DEMYX_NGINX_ALPINE_VERSION="$(docker exec "$DEMYX_REPOSITORY" cat /etc/os-release | grep VERSION_ID | cut -c 12- | sed 's/\r//g')"
DEMYX_NGINX_VERSION="$(docker exec "$DEMYX_REPOSITORY" "$DEMYX_REPOSITORY" -V 2>&1 | head -n 1 | cut -c 22- | sed 's/\r//g')"

# Replace versions
sed -i "s|alpine-.*.-informational|alpine-${DEMYX_NGINX_ALPINE_VERSION}-informational|g" README.md
sed -i "s|$DEMYX_REPOSITORY-.*.-informational|$DEMYX_REPOSITORY-${DEMYX_NGINX_VERSION}-informational|g" README.md

# Echo versions to file
echo "DEMYX_NGINX_ALPINE_VERSION=$DEMYX_NGINX_ALPINE_VERSION
DEMYX_NGINX_VERSION=$DEMYX_NGINX_VERSION" > VERSION

# Push back to GitHub
git config --global user.email "travis@travis-ci.com"
git config --global user.name "Travis CI"
git remote set-url origin https://"$DEMYX_GITHUB_TOKEN"@github.com/demyxco/"$DEMYX_REPOSITORY".git
# Push VERSION file first
git add VERSION
git commit -m "ALPINE $DEMYX_NGINX_ALPINE_VERSION, NGINX $DEMYX_NGINX_VERSION"
git push origin HEAD:master
# Add and commit the rest
git add .
git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"
git push origin HEAD:master

# Send a PATCH request to update the description of the repository
echo "Sending PATCH request"
DEMYX_DOCKER_TOKEN="$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"$DEMYX_USERNAME"'", "password": "'"$DEMYX_PASSWORD"'"}' "https://hub.docker.com/v2/users/login/" | jq -r .token)"
DEMYX_RESPONSE_CODE="$(curl -s --write-out "%{response_code}" --output /dev/null -H "Authorization: JWT ${DEMYX_DOCKER_TOKEN}" -X PATCH --data-urlencode full_description@"README.md" "https://hub.docker.com/v2/repositories/${DEMYX_USERNAME}/${DEMYX_REPOSITORY}/")"
echo "Received response code: $DEMYX_RESPONSE_CODE"

# Return an exit 1 code if response isn't 200
[[ "$DEMYX_RESPONSE_CODE" != 200 ]] && exit 1
