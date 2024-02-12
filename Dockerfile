FROM alpine

RUN apk update

COPY main /usr/bin/main

