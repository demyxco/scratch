FROM golang:alpine as demyx_go
FROM alpine

ENV PATH="$PATH":/usr/local/go/bin

RUN apk add --no-cache --update --virtual .deps \
    git cmake curl make clang patch expat-dev libtool \
    build-base autoconf automake libunwind-dev musl-dev

COPY --from=demyx_go /usr/local/go /usr/local
COPY openlitespeed-1.6.5 /openlitespeed
COPY build.sh /

RUN ln -s /usr/bin/go /usr/local/go/bin; \
    \
    cd openlitespeed; \
    chmod +x build.sh; \
    ./build.sh
