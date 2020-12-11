FROM demyx/openlitespeed

LABEL sh.demyx.image        demyx/code-server:openlitespeed
LABEL sh.demyx.maintainer   Demyx <info@demyx.sh>
LABEL sh.demyx.url          https://demyx.sh
LABEL sh.demyx.github       https://github.com/demyxco
LABEL sh.demyx.registry     https://hub.docker.com/u/demyx

# Set default variables
#ENV CODE_VERSION           v3.7.0
ENV DEMYX_CODE              /home/demyx/.config/code-server
ENV DEMYX_CODE_AUTH         password
ENV DEMYX_CODE_BIND_ADDR    0.0.0.0:8080
ENV DEMYX_CODE_PASSWORD     demyx
ENV DEMYX_PHP_VERSION       php7.4

# Run as root for now
USER root

# Packages
RUN set -ex; \
    /usr/bin/apt-get update && /usr/bin/apt-get install -y --no-install-recommends \
        apt-transport-https \
        bash \
        bsdmainutils \
        curl \
        dnsutils \
        git \
        gnupg \
        htop \
        iputils-ping \
        less \
        lsb-release \
        nano \
        net-tools \
        openssh-client \
        unzip \
        util-linux \
        wget \
        zsh; \
    \
    /usr/bin/curl -sL https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg; \
    /bin/echo "deb https://packages.sury.org/php/ $(/usr/bin/lsb_release -sc) main" | /usr/bin/tee /etc/apt/sources.list.d/php.list; \
    /usr/bin/apt-get update && /usr/bin/apt-get install -y --no-install-recommends \
        "$DEMYX_PHP_VERSION" \
        "$DEMYX_PHP_VERSION"-mysql; \
    \
    /bin/rm -rf /var/lib/apt/lists/*

# Configure Demyx
RUN set -ex; \
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

# Install php extensions
RUN set -ex; \
    /usr/bin/curl -sL https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions -o /usr/local/bin/install-php-extensions; \
    /bin/chmod uga+x /usr/local/bin/install-php-extensions; \
    /bin/sync; \
    /usr/local/bin/install-php-extensions \
        exif \
        gd \
        imagick \
        mysqli \
        opcache \
        pdo_mysql \
        ssh2 \
        sockets \
        xdebug \
        zip

# Composer
RUN set -ex; \
    /bin/su -c "/usr/bin/curl -sL https://getcomposer.org/installer -o /tmp/composer-setup.php" -s /bin/sh demyx; \
    /usr/local/bin/php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# PHP CodeSniffer & WPCS
RUN set -ex; \
    /bin/su -c "/bin/mkdir \"$DEMYX_CONFIG\"/phpcs && cd \"$DEMYX_CONFIG\"/phpcs; \
        \
        /usr/local/bin/composer require \"squizlabs/php_codesniffer=*\"; \
        \
        cd .. && /usr/bin/git clone -b master https://github.com/WordPress/WordPress-Coding-Standards.git wpcs; \
        \
        \"$DEMYX_CONFIG\"/phpcs/vendor/bin/phpcs --config-set installed_paths ${DEMYX_CONFIG}/wpcs" -s /bin/sh demyx; \
    \
    /bin/ln -s "$DEMYX_CONFIG"/phpcs/vendor/bin/phpcs /usr/local/bin/phpcs

# wp-cli
RUN set -ex; \
    /usr/bin/curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp; \
    /bin/chmod +x /usr/local/bin/wp

# Imports
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
    # Tag specifc extensions
    /usr/local/bin/code-server --extensions-dir="$DEMYX_CODE"/extensions \
        --install-extension="$DEMYX_CONFIG"/shevaua.phpcs-1.0.8.vsix \
        --install-extension=felixfbecker.php-debug; \
    \
    # Finalize code-server
    /bin/chown -R demyx:demyx "$DEMYX_CODE"; \
    /bin/chown -R demyx:demyx "$DEMYX_CONFIG"; \
    /bin/cp -rp "$DEMYX_CODE" "$DEMYX_CONFIG"

# Finalize
RUN set -ex; \
    # demyx-install
    /bin/cp "$DEMYX_CONFIG"/install.sh /usr/local/bin/demyx-install; \
    /bin/chmod +x /usr/local/bin/demyx-install; \
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

EXPOSE 80 8080 8081

USER demyx
