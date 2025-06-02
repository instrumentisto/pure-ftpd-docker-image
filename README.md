Pure-FTPd Docker image
======================

[![Release](https://img.shields.io/github/v/release/instrumentisto/pure-ftpd-docker-image "Release")](https://github.com/instrumentisto/pure-ftpd-docker-image/releases)
[![CI](https://github.com/instrumentisto/pure-ftpd-docker-image/actions/workflows/ci.yml/badge.svg?branch=main "CI")](https://github.com/instrumentisto/pure-ftpd-docker-image/actions?query=workflow%3ACI+branch%3Amain)
[![Docker Hub](https://img.shields.io/docker/pulls/instrumentisto/pure-ftpd?label=Docker%20Hub%20pulls "Docker Hub pulls")](https://hub.docker.com/r/instrumentisto/pure-ftpd)
[![Uses](https://img.shields.io/badge/uses-s6--overlay-blue.svg "Uses s6-overlay")](https://github.com/just-containers/s6-overlay)

[Docker Hub](https://hub.docker.com/r/instrumentisto/pure-ftpd)
| [GitHub Container Registry](https://github.com/orgs/instrumentisto/packages/container/package/pure-ftpd)
| [Quay.io](https://quay.io/repository/instrumentisto/pure-ftpd)

[Changelog](https://github.com/instrumentisto/pure-ftpd-docker-image/blob/main/CHANGELOG.md)




## Supported tags and respective `Dockerfile` links

- [`1.0.52-r8`, `1.0.52`, `1.0`, `1`, `latest`][201]




## What is Pure-FTPd?

Pure-FTPd is a free ([BSD][91]), secure, production-quality and standard-conformant FTP server. It doesn't provide useless bells and whistles, but focuses on efficiency and ease of use. It provides simple answers to common needs, plus unique useful features for personal users as well as hosting providers.

PureFTPd‘s mantra is ‘Security First.’ This is evident in the [low number of CVE entries][101].

> [www.pureftpd.org](https://www.pureftpd.org)

![Pure-FTPd Logo](https://www.pureftpd.org/images/pure-ftpd.png)




## How to use this image

To run Pure-FTPd server just start the container: 
```bash
docker run -d -p 21:21 -p 30000-30009:30000-30009 instrumentisto/pure-ftpd
```


### Why so many ports opened?

This is for `PASV` support, please see: [#5 PASV not fun :)][12]


### Configuration

By default it uses [default configuration file][10] `/etc/pure-ftpd.conf`.

1. You may either specify your own configuration file instead.

    ```bash
    docker run -d -p 21:21 \
               -v $(pwd)/my.conf:/etc/pure-ftpd.conf \
           instrumentisto/pure-ftpd
    ```

2. Or specify command line options directly.

    ```bash
    docker run -d -p 21:21 instrumentisto/pure-ftpd \
           pure-ftpd -c 50 -E -H -R
    ```
    
3. Or even specify another configuration file.

    ```bash
    docker run -d -p 21:21 \
               -v $(pwd)/my.conf:/my/pure-ftpd.conf \
           instrumentisto/pure-ftpd \
           pure-ftpd /my/pure-ftpd.conf
    ```


### Accounts

This image uses [PureDB][11] for virtual FTP accounts.

It's just enough to mount `/etc/pureftpd.passwd` file, which will be converted into `/etc/pureftpd.pdb` file on container start.

Location of `.passwd` file may be changed with `PURE_PASSWDFILE` env var. Location of `.pdb` file may be changed with `PURE_DBFILE` env var.

To generate `pureftpd.passwd` you may use `pure-pw` binary contained in image:
```bash
docker run --rm -it -v $(pwd)/my.passwd:/etc/pureftpd.passwd --entrypoint sh \
       instrumentisto/pure-ftpd \
           pure-pw useradd joe -u 90 -d /data/joe
```




## Image tags

This image is based on the popular [Alpine Linux project][1], available in [the alpine official image][2]. [Alpine Linux][1] is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc][4] instead of [glibc and friends][5], so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread][6] for more discussion of the issues that might arise and some pro/con comparisons of using [Alpine][1]-based images.


### `<X>`

Latest tag of the latest major `X` Pure-FTPd version.


### `<X.Y>`

Latest tag of the latest minor `X.Y` Pure-FTPd version.


### `<X.Y.Z>`

Latest tag of the concrete `X.Y.Z` Pure-FTPd version.


### `<X.Y.Z>-r<N>`

Concrete `N` image revision tag of the concrete `X.Y.Z` Pure-FTPd version.

Once built, it's never updated.




## Important tips

As far as Pure-FTPd writes its logs only to `syslog`, the `syslogd` process runs inside container as second side-process and is supervised with [`s6` supervisor][20] provided by [`s6-overlay` project][21].


### Logs

The `syslogd` process of this image is configured to write everything to `/dev/stdout`.

To change this behaviour just mount your own `/etc/syslog.conf` file with desired log rules.


### s6-overlay

This image contains [`s6-overlay`][21] inside. So you may use all the [features it provides][22] if you need to.




## License

Pure-FTPd is licensed under [BSD license][92].

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

The [sources][90] for producing `instrumentisto/pure-ftpd` Docker images are licensed under [Blue Oak Model License 1.0.0][91].




## Issues

We can't notice comments in the [DockerHub] (or other container registries) so don't use them for reporting issue or asking question.

If you have any problems with or questions about this image, please contact us through a [GitHub issue][3].




[DockerHub]: https://hub.docker.com

[1]: http://alpinelinux.org
[2]: https://hub.docker.com/_/alpine
[3]: https://github.com/instrumentisto/pure-ftpd-docker-image/issues
[4]: http://www.musl-libc.org
[5]: http://www.etalabs.net/compare_libcs.html
[6]: https://news.ycombinator.com/item?id=10782897
[10]: https://github.com/jedisct1/pure-ftpd/blob/1.0.47/pure-ftpd.conf.in
[11]: https://download.pureftpd.org/pure-ftpd/doc/README.Virtual-Users
[12]: https://github.com/stilliard/docker-pure-ftpd/issues/5
[20]: http://skarnet.org/software/s6/overview.html
[21]: https://github.com/just-containers/s6-overlay
[22]: https://github.com/just-containers/s6-overlay#usage
[90]: https://github.com/instrumentisto/pure-ftpd-docker-image
[91]: https://github.com/instrumentisto/pure-ftpd-docker-image/blob/main/LICENSE.md
[92]: https://download.pureftpd.org/pub/pure-ftpd/doc/COPYING
[101]: https://nvd.nist.gov/view/vuln/search-results?query=pure-ftpd&search_type=all&cves=on

[201]: https://github.com/instrumentisto/pure-ftpd-docker-image/blob/main/Dockerfile
