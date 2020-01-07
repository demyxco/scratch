FROM golang:alpine as demyx_go
FROM alpine

ENV PATH="$PATH":/usr/local/go/bin

RUN apk add --no-cache --update --virtual .deps \
    git cmake curl make clang patch expat-dev libtool \
    build-base autoconf automake libunwind-dev musl-dev libxml2-dev

COPY --from=demyx_go /usr/local/go /usr/local
COPY openlitespeed-1.6.5 /openlitespeed

RUN cd openlitespeed; \
    ./configure; \
    make; \
    make install
    #chmod +x build.sh; \
    #./build.sh
