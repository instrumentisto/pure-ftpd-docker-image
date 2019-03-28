# https://hub.docker.com/_/alpine
FROM alpine:3.9

MAINTAINER Instrumentisto Team <developer@instrumentisto.com>


# Build and install Pure-FTPd
RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
    \
 # Install Pure-FTPd dependencies
 && apk add --no-cache \
        libressl2.7-libcrypto libressl2.7-libssl \
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
         https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.48.tar.gz \
 && (echo "481b671d339952da873a3704671e0e1897cc7fa6f9393f470a228cd2154c029622e4ad726da707a16cde394319dd656db228c852ad87187786edeb2b59a08647  /tmp/pure-ftpd.tar.gz" \
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
         https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz \
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
