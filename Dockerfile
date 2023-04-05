# https://hub.docker.com/_/alpine
FROM alpine:3.17

ARG pure_ftpd_ver=1.0.51
ARG s6_overlay_ver=3.1.4.2
ARG build_rev=15


# Build and install Pure-FTPd
RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
    \
 # Install Pure-FTPd dependencies
 && apk add --no-cache \
        libretls \
        libsodium \
    \
 # Install tools for building
 && apk add --no-cache --virtual .tool-deps \
        curl coreutils autoconf g++ libtool make \
    \
 # Install Pure-FTPd build dependencies
 && apk add --no-cache --virtual .build-deps \
        libretls-dev \
        libsodium-dev \
    \
 # Download and prepare Pure-FTPd sources
 && curl -fL -o /tmp/pure-ftpd.tar.gz \
         https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${pure_ftpd_ver}.tar.gz \
 && (echo "8048e41cbe3d982807f3e4594776c65b0918d8782389b40f38a4505facad8bb4e2e62b042c69ad6fff637ea53ec1bd7839577b0e5d70c00f7261c764c34f579c  /tmp/pure-ftpd.tar.gz" \
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
 && curl -fL -o /tmp/s6-overlay-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_ver}/s6-overlay-noarch.tar.xz \
 && curl -fL -o /tmp/s6-overlay-bin.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_ver}/s6-overlay-x86_64.tar.xz \
 && tar -xf /tmp/s6-overlay-noarch.tar.xz -C / \
 && tar -xf /tmp/s6-overlay-bin.tar.xz -C / \
    \
 # Cleanup unnecessary stuff
 && apk del .tool-deps \
 && rm -rf /var/cache/apk/* \
           /tmp/*

ENV S6_KEEP_ENV=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1


COPY rootfs /

RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run \
             /etc/s6-overlay/s6-rc.d/*/*.sh


EXPOSE 21 30000-30009

ENTRYPOINT ["/init"]

CMD ["pure-ftpd", "/etc/pure-ftpd.conf"]
