FROM alpine

LABEL sh.demyx.image        demyx/docker-compose
LABEL sh.demyx.maintainer   Demyx <info@demyx.sh>
LABEL sh.demyx.url          https://demyx.sh
LABEL sh.demyx.github       https://github.com/demyxco
LABEL sh.demyx.registry     https://hub.docker.com/u/demyx

# Set default variables
ENV DEMYX                   /demyx
ENV DEMYX_CONFIG            /etc/demyx
ENV DEMYX_LOG               /var/log/demyx
ENV TZ                      America/Los_Angeles
# Support for old variables
ENV DOCKER_COMPOSE_ROOT     "$DEMYX"
ENV DOCKER_COMPOSE_CONFIG   "$DEMYX_CONFIG"
ENV DOCKER_COMPOSE_LOG      "$DEMYX_LOG"

# Configure Demyx
RUN set -ex; \
    /usr/sbin/addgroup -g 1000 -S demyx; \
    /usr/sbin/adduser -u 1000 -D -S -G demyx demyx; \
    \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX"; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"

# Packages
RUN set -ex; \
    /sbin/apk --update --no-cache add docker-compose tzdata

WORKDIR "$DEMYX"

ENTRYPOINT ["/usr/bin/docker-compose"]
