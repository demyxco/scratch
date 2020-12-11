#!/bin/bash
# Demyx
# https://demyx.sh

# Get versions
#DEMYX_ALPINE_VERSION="$(/usr/bin/docker run --rm --entrypoint=/bin/cat demyx/code-server:alpine /etc/os-release | grep VERSION_ID | cut -c 12- | /bin/sed 's/\r//g')"
DEMYX_CODE_DEBIAN_VERSION="$(/usr/bin/docker exec "$DEMYX_REPOSITORY" /bin/cat /etc/debian_version | /bin/sed 's/\r//g')"
DEMYX_CODE_VERSION="$(/usr/bin/docker exec "$DEMYX_REPOSITORY" /usr/local/bin/code-server --version | /usr/bin/awk -F '[ ]' '{print $1}' | /usr/bin/awk '{line=$0} END{print line}' | /bin/sed 's/\r//g')"
DEMYX_CODE_GO_VERSION="$(/usr/bin/docker run --rm --entrypoint=go demyx/"$DEMYX_REPOSITORY":go version | /usr/bin/awk -F '[ ]' '{print $3}' | /bin/sed 's/go//g' | /bin/sed 's/\r//g')"

# Replace versions
/bin/sed -i "s|debian-.*.-informational|debian-${DEMYX_CODE_DEBIAN_VERSION}-informational|g" README.md
/bin/sed -i "s|code--server-.*.-informational|code--server-${DEMYX_CODE_VERSION}-informational|g" README.md
/bin/sed -i "s|go-.*.-informational|go-${DEMYX_CODE_GO_VERSION}-informational|g" README.md

/bin/sed -i "s|debian-.*.-informational|debian-${DEMYX_CODE_DEBIAN_VERSION}-informational|g" tag-wp/README.md
/bin/sed -i "s|code--server-.*.-informational|code--server-${DEMYX_CODE_VERSION}-informational|g" tag-wp/README.md

/bin/sed -i "s|debian-.*.-informational|debian-${DEMYX_CODE_DEBIAN_VERSION}-informational|g" tag-sage/README.md
/bin/sed -i "s|code--server-.*.-informational|code--server-${DEMYX_CODE_VERSION}-informational|g" tag-sage/README.md

#/bin/sed -i "s|alpine-.*.-informational|alpine-${DEMYX_ALPINE_VERSION}-informational|g" README.md

#/bin/sed -i "s|alpine-.*.-informational|alpine-${DEMYX_ALPINE_VERSION}-informational|g" tag-wp-alpine/README.md
#/bin/sed -i "s|code--server-.*.-informational|code--server-${DEMYX_CODE_VERSION}-informational|g" tag-wp-alpine/README.md

#/bin/sed -i "s|alpine-.*.-informational|alpine-${DEMYX_ALPINE_VERSION}-informational|g" tag-sage-alpine/README.md
#/bin/sed -i "s|code--server-.*.-informational|code--server-${DEMYX_CODE_VERSION}-informational|g" tag-sage-alpine/README.md

# Echo versions to file
/bin/echo "DEMYX_CODE_DEBIAN_VERSION=$DEMYX_CODE_DEBIAN_VERSION
DEMYX_CODE_VERSION=$DEMYX_CODE_VERSION
DEMYX_CODE_GO_VERSION=$DEMYX_CODE_GO_VERSION" > VERSION

# Push back to GitHub
/usr/bin/git config --global user.email "travis@travis-ci.com"
/usr/bin/git config --global user.name "Travis CI"
/usr/bin/git remote set-url origin https://"$DEMYX_GITHUB_TOKEN"@github.com/demyxco/"$DEMYX_REPOSITORY".git
# Commit VERSION file first
/usr/bin/git add VERSION
/usr/bin/git commit -m "DEBIAN $DEMYX_CODE_DEBIAN_VERSION, CODE-SERVER $DEMYX_CODE_VERSION, GO $DEMYX_CODE_GO_VERSION"
/usr/bin/git push origin HEAD:master
# Add and commit the rest
/usr/bin/git add .
/usr/bin/git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"
/usr/bin/git push origin HEAD:master

# Send a PATCH request to update the description of the repository
/bin/echo "Sending PATCH request"
DEMYX_DOCKER_TOKEN="$(/usr/bin/curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"$DEMYX_USERNAME"'", "password": "'"$DEMYX_PASSWORD"'"}' "https://hub.docker.com/v2/users/login/" | /usr/local/bin/jq -r .token)"
DEMYX_RESPONSE_CODE="$(/usr/bin/curl -s --write-out "%{response_code}" --output /dev/null -H "Authorization: JWT ${DEMYX_DOCKER_TOKEN}" -X PATCH --data-urlencode full_description@"README.md" "https://hub.docker.com/v2/repositories/${DEMYX_USERNAME}/${DEMYX_REPOSITORY}/")"
/bin/echo "Received response code: $DEMYX_RESPONSE_CODE"

# Return an exit 1 code if response isn't 200
[[ "$DEMYX_RESPONSE_CODE" != 200 ]] && exit 1
