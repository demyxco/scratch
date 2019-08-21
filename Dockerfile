FROM alpine

RUN apk --update --no-cache add nginx dumb-init;

EXPOSE 80
