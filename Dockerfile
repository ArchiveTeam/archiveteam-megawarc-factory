FROM debian:bookworm-slim
RUN DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io update \
 && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io install python3 python3-zstandard python3-requests rsync ca-certificates curl zstd libzstd-dev libzstd1
COPY * factory/
WORKDIR /factory
COPY docker-boot.sh /
RUN chmod +x /docker-boot.sh
ENTRYPOINT ["/docker-boot.sh"]
