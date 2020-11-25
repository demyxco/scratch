#!/bin/bash
# Demyx
# https://demyx.sh
# https://github.com/peter-evans/dockerhub-description/blob/master/entrypoint.sh

# Get versions
DEMYX_DOCKER_COMPOSE_ALPINE_VERSION=$(docker exec "$DEMYX_REPOSITORY" cat /etc/os-release | grep VERSION_ID | cut -c 12- | sed -e 's/\r//g')
DEMYX_DOCKER_COMPOSE_VERSION=$(docker exec "$DEMYX_REPOSITORY" "$DEMYX_REPOSITORY" --version | awk -F '[ ]' '{print $3}' | cut -c -6 | sed -e 's/\r//g')

# Replace versions
sed -i "s|alpine-.*.-informational|alpine-${DEMYX_DOCKER_COMPOSE_ALPINE_VERSION}-informational|g" README.md
sed -i "s|docker--compose-.*.-informational|docker--compose-${DEMYX_DOCKER_COMPOSE_VERSION}-informational|g" README.md

# Echo versions to file
echo "DEMYX_DOCKER_COMPOSE_ALPINE_VERSION=$DEMYX_DOCKER_COMPOSE_ALPINE_VERSION
DEMYX_DOCKER_COMPOSE_VERSION=$DEMYX_DOCKER_COMPOSE_VERSION" > VERSION

# Push back to GitHub
git config --global user.email "travis@travis-ci.com"
git config --global user.name "Travis CI"
git remote set-url origin https://"$DEMYX_GITHUB_TOKEN"@github.com/demyxco/"$DEMYX_REPOSITORY".git
# Commit VERSION first
git add VERSION
git commit -m "ALPINE $DEMYX_DOCKER_COMPOSE_ALPINE_VERSION, DOCKER-COMPOSE $DEMYX_DOCKER_COMPOSE_VERSION"
git push origin HEAD:master
# Commit the rest
git add .
git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"
git push origin HEAD:master

# Acquire a token for the Docker Hub API
echo "Acquiring token"
DEMYX_DOCKER_TOKEN="$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"$DEMYX_USERNAME"'", "password": "'"$DEMYX_PASSWORD"'"}' "https://hub.docker.com/v2/users/login/" | jq -r .token)"

# Send a PATCH request to update the description of the repository
echo "Sending PATCH request"
DEMYX_REPO_URL="https://hub.docker.com/v2/repositories/${DEMYX_USERNAME}/${DEMYX_REPOSITORY}/"
DEMYX_RESPONSE_CODE="$(curl -s --write-out "%{response_code}" --output /dev/null -H "Authorization: JWT ${DEMYX_DOCKER_TOKEN}" -X PATCH --data-urlencode full_description@"README.md" "$DEMYX_REPO_URL")"
echo "Received response code: $DEMYX_RESPONSE_CODE"

# Return an exit 1 code if response isn't 200
[[ "$DEMYX_RESPONSE_CODE" != 200 ]] && exit 1
