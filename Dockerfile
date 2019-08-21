FROM alpine

RUN apk --update --no-cache add nginx dumb-init;

EXPOSE 80

ENTRYPOINT ["dumb-init"]

CMD ["nginx", "-g", "daemon off;"]
