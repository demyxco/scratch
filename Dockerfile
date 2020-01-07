FROM alpine

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing litespeed-snmp; \
    apk add --no-cache --update --virtual .deps \
    linux-headers openssl-dev geoip-dev expat-dev pcre-dev zlib-dev \
	bsd-compat-headers lua-dev luajit-dev brotli-dev \
    expat geoip libcrypto1.1 libgcc libssl1.1 libstdc++ musl \
    pcre php7-bcmath php7-json php7-litespeed php7-pecl-mcrypt \
    php7-posix php7-session php7-session php7-sockets zlib \
    #cmake curl make clang patch expat-dev libtool \
    build-base autoconf automake musl-dev 

#RUN addgroup -S litespeed 2>/dev/null; \
#    adduser -S -D -H -h /var/lib/litespeed -s /sbin/nologin -G litespeed -g litespeed litespeed 2>/dev/null

COPY openlitespeed-1.6.5 /openlitespeed-1.6.5

RUN set -ex; \
    cd /openlitespeed-1.6.5; \
    chmod +x build.sh; \
    ./build.sh
