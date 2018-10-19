FROM openjdk:8u171-jdk-alpine3.8

RUN set -x && \
    addgroup -g 1000 appuser && \
    adduser -u 1000 -D -G appuser appuser
