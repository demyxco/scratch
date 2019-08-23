# demyx/nginx-php-wordpress 
[![Build Status](https://travis-ci.org/demyxco/scratch.svg?branch=master)](https://travis-ci.org/demyxco/scratch) 
[![](https://images.microbadger.com/badges/version/demyx/demyx.svg)](https://microbadger.com/images/demyx/demyx "Get your own version badge on microbadger.com") 
[![](https://images.microbadger.com/badges/image/demyx/demyx.svg)](https://microbadger.com/images/demyx/demyx "Get your own image badge on microbadger.com")
[![Architecture](https://img.shields.io/badge/linux-amd64-important)]()

Automatically installs wp-config.php using environment variables, configures salts, and enables HTTP_X_FORWARDED_PROTO.
* User: www-data, UID: 82
* Volume: /var/www/html
* Port: 80
* Timezone: America/Los_Angeles
* Modified: nginx.conf, php.ini, and php-fpm.conf
* Included basic security nginx conf files in /etc/nginx/common
* Custom modules in /etc/nginx/modules: [ngx_cache_purge](http://github.com/FRiCKLE/ngx_cache_purge/), [headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module)

# Usage
For automatic setup, see my repo: [github.com/demyxco](https://github.com/demyxco/demyx). 
```
version: "3.7"

services:
  traefik:
    image: traefik
    restart: unless-stopped
    networks:
      - traefik
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.toml:/etc/traefik/traefik.toml:ro
    ports:
      - 80:80
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=Host:traefik.domain.tld"
      - "traefik.port=8080"
  db:
    image: demyx/mariadb
    restart: unless-stopped
    networks:
      - traefik
    environment:
      MARIADB_DATABASE: demyx_db
      MARIADB_USERNAME: demyx_user
      MARIADB_PASSWORD: demyx_password
      MARIADB_ROOT_PASSWORD: demyx_root_password
  wp:
    image: demyx/nginx-php-wordpress
    restart: unless-stopped
    networks:
      - traefik
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: demyx_db
      WORDPRESS_DB_USER: demyx_user
      WORDPRESS_DB_PASSWORD: demyx_password
      TZ: America/Los_Angeles
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=Host:domain.tld,www.domain.tld"
      - "traefik.port=80"
networks:
  traefik:
    name: traefik
```

# Questions?
[info@demyx.sh](mailto:info@demyx.sh)