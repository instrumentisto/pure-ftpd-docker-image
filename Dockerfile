# https://hub.docker.com/_/alpine
FROM alpine:3.13

ARG pure_ftpd_ver=1.0.49
ARG s6_overlay_ver=2.2.0.1
ARG build_rev=2

LABEL org.opencontainers.image.source="\
    https://github.com/instrumentisto/pure-ftpd-docker-image"


# Build and install Pure-FTPd
RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
    \
 # Install Pure-FTPd dependencies
 && apk add --no-cache \
        libressl3.1-libcrypto libressl3.1-libssl \
        libsodium \
    \
 # Install tools for building
 && apk add --no-cache --virtual .tool-deps \
        curl coreutils autoconf g++ libtool make \
    \
 # Install Pure-FTPd build dependencies
 && apk add --no-cache --virtual .build-deps \
        libressl-dev \
        libsodium-dev \
    \
 # Download and prepare Pure-FTPd sources
 && curl -fL -o /tmp/pure-ftpd.tar.gz \
         https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${pure_ftpd_ver}.tar.gz \
 && (echo "7e7d4c81c5237624051bde53db6d9abcbae565a4e8a88627d81d369064b475f4b56305c105ed275264cce068844caad25b2014f41e2540058553222151fe3af8  /tmp/pure-ftpd.tar.gz" \
         | sha512sum -c -) \
 && tar -xzf /tmp/pure-ftpd.tar.gz -C /tmp/ \
 && cd /tmp/pure-ftpd-* \
    \
 # Build Pure-FTPd from sources
 && ./configure --prefix=/usr \
        --with-puredb \
        --with-quotas \
        --with-ratios \
        --with-rfc2640 \
        --with-throttling  \
        --with-tls \
        --without-capabilities \
        --without-humor \
        --without-inetd \
        --without-usernames \
 && make \
    \
 # Create Pure-FTPd user and groups
 && addgroup -S -g 91 pure-ftpd \
 && adduser -S -u 90 -D -s /sbin/nologin \
            -H -h /data \
            -G pure-ftpd -g pure-ftpd \
            pure-ftpd \
    \
 # Install and configure Pure-FTPd
 && make install \
 && install -d -o pure-ftpd -g pure-ftpd /data \
 # Disable daemonization
 && sed -i -e 's,^Daemonize .*,Daemonize no,' \
        /etc/pure-ftpd.conf \
 # No documentation included to keep image size smaller
 && rm -rf /usr/share/man/* \
    \
 # Cleanup unnecessary stuff
 && apk del .tool-deps .build-deps \
 && rm -rf /var/cache/apk/* \
           /tmp/*


# Install s6-overlay
RUN apk add --update --no-cache --virtual .tool-deps \
        curl \
 && curl -fL -o /tmp/s6-overlay.tar.gz \
         https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_ver}/s6-overlay-amd64.tar.gz \
 && tar -xzf /tmp/s6-overlay.tar.gz -C / \
    \
 # Cleanup unnecessary stuff
 && apk del .tool-deps \
 && rm -rf /var/cache/apk/* \
           /tmp/*

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1


COPY rootfs /

RUN chmod +x /etc/services.d/*/run \
             /etc/cont-init.d/*


EXPOSE 21 30000-30009

ENTRYPOINT ["/init"]

CMD ["pure-ftpd", "/etc/pure-ftpd.conf"]
