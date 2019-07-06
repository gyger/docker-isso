FROM alpine:3.10

LABEL maintainer="gyger"
LABEL source="https://github.com/gyger/docker-isso"

ARG ISSO_VER=0.11.1

ENV GID=1000 UID=1000

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apk add --update \
        python \
        ca-certificates \
        python-dev \
        py-pip \
        sqlite  && \
    update-ca-certificates && \
    apk add --virtual .build-dependencies \
        build-base  && \
    pip install --no-cache "isso==${ISSO_VER}" && \
    pip install --no-cache gunicorn && \
    apk del .build-dependencies && \
    rm -rf /var/cache/apk/*

RUN addgroup -S isso && adduser -S -G isso isso 
USER isso
RUN mkdir -p /isso && mkdir -p /isso/database
ADD src/isso.conf /isso.conf

ENV ISSO_SETTINGS /isso/isso.conf

EXPOSE 8080

VOLUME ["/isso/database"]

ENTRYPOINT ["gunicorn", "isso.dispatch", "-b 0.0.0.0:8080"]
