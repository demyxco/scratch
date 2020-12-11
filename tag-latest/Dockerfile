FROM quay.io/vektorlab/ctop as demyx_ctop
FROM docker as demyx_docker
FROM koalaman/shellcheck as demyx_shellcheck
FROM debian:buster-slim

LABEL sh.demyx.image        demyx/code-server
LABEL sh.demyx.maintainer   Demyx <info@demyx.sh>
LABEL sh.demyx.url          https://demyx.sh
LABEL sh.demyx.github       https://github.com/demyxco
LABEL sh.demyx.registry     https://hub.docker.com/u/demyx

# Set default variables
#ENV CODE_VERSION            v3.7.0
ENV DEMYX                   /demyx
ENV DEMYX_AUTH              password
ENV DEMYX_BIND_ADDR         0.0.0.0:8080
ENV DEMYX_CODE              /home/demyx/.config/code-server
ENV DEMYX_CONFIG            /etc/demyx
ENV DEMYX_LOG               /var/log/demyx
ENV DEMYX_PASSWORD          demyx
ENV DOCKER_HOST             tcp://demyx_socket:2375
ENV TERM                    linux
ENV TZ                      America/Los_Angeles
# Support for old variables
ENV CODE_ROOT               "$DEMYX"
ENV CODE_CONFIG             "$DEMYX_CONFIG"
ENV CODE_LOG                "$DEMYX_LOG"

# Packages
RUN set -ex; \
    /usr/bin/apt-get update && /usr/bin/apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    bsdmainutils \
    ca-certificates \
    curl \
    dnsutils \
    git \
    gnupg \
    htop \
    iputils-ping \
    jq \
    less \
    nano \
    net-tools \
    openssh-client \
    procps \
    sudo \
    tzdata \
    unzip \
    util-linux \
    wget \
    zsh; \
    \
    /bin/rm -rf /var/lib/apt/lists/*

# Configure Demyx
RUN set -ex; \
    # Create demyx user
    /usr/sbin/adduser --gecos '' --disabled-password demyx; \
    \
    # Update .bashrc
    /bin/echo 'PS1="$(whoami)@\h:\w \$ "' > /home/demyx/.bashrc; \
    /bin/echo 'PS1="$(whoami)@\h:\w \$ "' > /root/.bashrc; \
    \
    # Create demyx directories
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX"; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"; \
    \
    # Oh-My-Zsh
    /bin/su -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" -s /bin/sh demyx; \
    /bin/su -c  "/usr/bin/git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions" -s /bin/sh demyx; \
    /bin/su -c  "/usr/bin/git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins.git /home/demyx/.oh-my-zsh/plugins/autoupdate" -s /bin/sh demyx; \
    /bin/sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /home/demyx/.zshrc; \
    /bin/sed -i "s|(git)|(git zsh-autosuggestions autoupdate)|g" /home/demyx/.zshrc; \
    \
    # Change user shell
    /bin/sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    \
    # gpg purposes
    /bin/echo 'export GPG_TTY=$(tty)' >> /home/demyx/.zshrc

# Imports
COPY --from=demyx_ctop /ctop /usr/local/bin/ctop
COPY --from=demyx_docker /usr/local/bin/docker /usr/local/bin/docker
COPY --from=demyx_shellcheck /bin/shellcheck /usr/local/bin/shellcheck
COPY --chown=demyx:demyx src "$DEMYX_CONFIG"

# Configure code-server
RUN set -ex; \
    # Get code-server
    if [ -z "$CODE_VERSION" ]; then CODE_VERSION="$(/usr/bin/curl -sL https://api.github.com/repos/cdr/code-server/releases/latest | /usr/bin/jq -r .tag_name)"; fi; \
    CODE_VERSION_NUMBER="$(/bin/echo "$CODE_VERSION" | /bin/sed 's|v||g')"; \
    /usr/bin/curl -sL https://github.com/cdr/code-server/releases/download/"$CODE_VERSION"/code-server-"$CODE_VERSION_NUMBER"-linux-amd64.tar.gz -o /tmp/code-server-"$CODE_VERSION"-linux-amd64.tar.gz; \
    /bin/tar -xzf /tmp/code-server-"$CODE_VERSION"-linux-amd64.tar.gz -C /tmp; \
    /bin/mv /tmp/code-server-"$CODE_VERSION_NUMBER"-linux-amd64 /usr/local/lib/code-server; \
    \
    # Create code-server directories
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_CODE"/data/User; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_CODE"/extensions; \
    \
    # Copy settings.json
    /bin/cp "$DEMYX_CONFIG"/settings.json "$DEMYX_CODE"/data/User/settings.json; \
    \
    # Symlink code-server
    /bin/ln -s /usr/local/lib/code-server/bin/code-server /usr/local/bin/code-server; \
    \
    # Install default extensions
    /usr/local/bin/code-server --extensions-dir="$DEMYX_CODE"/extensions \
        --install-extension=equinusocio.vsc-material-theme \
        --install-extension=pkief.material-icon-theme \
        --install-extension=remisa.shellman \
        --install-extension=ryu1kn.partial-diff \
        --install-extension=timonwong.shellcheck; \
    \
    # Finalize code-server
    /bin/chown -R demyx:demyx "$DEMYX_CODE"; \
    /bin/chown -R demyx:demyx "$DEMYX_CONFIG"; \
    /bin/cp -rp "$DEMYX_CODE" "$DEMYX_CONFIG"

# Finalize
RUN set -ex; \
    # ctop 
    /bin/cp "$DEMYX_CONFIG"/ctop /home/demyx/.ctop; \
    \
    # sudo
    /bin/echo "demyx ALL=(ALL) NOPASSWD: /usr/bin/apt" > /etc/sudoers.d/demyx; \
    \
    # demyx-entrypoint
    /bin/cp "$DEMYX_CONFIG"/entrypoint.sh /usr/local/bin/demyx-entrypoint; \
    /bin/chmod +x /usr/local/bin/demyx-entrypoint; \
    \
    # Set ownership
    /bin/chown -R root:root /usr/local/bin; \
    \
    # Clear /tmp
    /bin/rm -rf /tmp/*

EXPOSE 8080

WORKDIR /home/demyx

USER demyx

ENTRYPOINT /usr/local/bin/demyx-entrypoint
