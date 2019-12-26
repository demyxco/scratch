FROM golang:alpine as demyx_go
FROM alpine

ENV PATH="$PATH":/usr/local/go/bin

RUN apk add --no-cache --update --virtual .deps \
    git cmake curl make clang patch expat-dev libtool \
    build-base autoconf automake libunwind-dev musl-dev

COPY --from=demyx_go /usr/local/go /usr/local
COPY openlitespeed-1.6.4.src.tgz /
COPY build.sh /

RUN tar -xzf openlitespeed-1.6.4.src.tgz; \
    \
    mv /build.sh /openlitespeed-1.6.4; \
    \
    ln -s /usr/bin/go /usr/local/go/bin; \
    \
    cd openlitespeed-1.6.4; \
    chmod +x build.sh; \
    ./build.sh
