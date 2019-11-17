#!/bin/bash
# Demyx
# https://demyx.sh
# https://github.com/peter-evans/dockerhub-description/blob/master/entrypoint.sh
set -euo pipefail
IFS=$'\n\t'

# Get versions
DEMYX_ALPINE_VERSION=$(docker exec -t demyx_wp cat /etc/os-release | grep VERSION_ID | cut -c 12- | sed -e 's/\r//g')
DEMYX_PHP_VERSION=$(docker exec -t demyx_wp php -v | grep cli | awk -F '[ ]' '{print $2}' | sed -e 's/\r//g')
DEMYX_WP_VERSION=$(docker run --rm --volumes-from demyx_wp --network container:demyx_wp demyx/"$DEMYX_REPOSITORY":cli core version | sed -e 's/\r//g')
DEMYX_BEDROCK_VERSION=$(docker exec demyx_wp cat CHANGELOG.md | head -n1 | awk -F '[:]' '{print $1}' | awk -F '[ ]' '{print $2}' | sed -e 's/\r//g')
DEMYX_WPCLI_VERSION=$(docker run --rm demyx/"$DEMYX_REPOSITORY":cli --version | awk -F '[ ]' '{print $2}' | sed -e 's/\r//g')

# Replace versions
sed -i "s|alpine-.*.-informational|alpine-${DEMYX_ALPINE_VERSION}-informational|g" README.md
sed -i "s|php-.*.-informational|php-${DEMYX_PHP_VERSION}-informational|g" README.md
sed -i "s|wordpress-.*.-informational|wordpress-${DEMYX_WP_VERSION}-informational|g" README.md
sed -i "s|bedrock-.*.-informational|bedrock-${DEMYX_BEDROCK_VERSION}-informational|g" README.md
sed -i "s|wp--cli-.*.-informational|wp--cli-${DEMYX_WPCLI_VERSION}-informational|g" README.md

# Push back to GitHub
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
git remote set-url origin https://${DEMYX_GITHUB_TOKEN}@github.com/demyxco/"$DEMYX_REPOSITORY".git
git add .; git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"; git push origin HEAD:master

# Set the default path to README.md
README_FILEPATH="./README.md"

# Acquire a token for the Docker Hub API
echo "Acquiring token"
LOGIN_PAYLOAD="{\"username\": \"${DEMYX_USERNAME}\", \"password\": \"${DEMYX_PASSWORD}\"}"
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d ${LOGIN_PAYLOAD} https://hub.docker.com/v2/users/login/ | jq -r .token)

# Send a PATCH request to update the description of the repository
echo "Sending PATCH request"
REPO_URL="https://hub.docker.com/v2/repositories/${DEMYX_USERNAME}/${DEMYX_REPOSITORY}/"
RESPONSE_CODE=$(curl -s --write-out %{response_code} --output /dev/null -H "Authorization: JWT ${TOKEN}" -X PATCH --data-urlencode full_description@${README_FILEPATH} ${REPO_URL})
echo "Received response code: $RESPONSE_CODE"

if [ $RESPONSE_CODE -eq 200 ]; then
  exit 0
else
  exit 1
fi
