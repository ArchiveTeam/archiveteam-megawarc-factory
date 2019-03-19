FROM debian:stretch-slim
RUN DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io update \
 && DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -qqy --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-unsafe-io install python python2.7 rsync git ca-certificates curl \
 && git clone https://github.com/ArchiveTeam/archiveteam-megawarc-factory /factory \
 && git clone https://github.com/alard/megawarc.git /factory/megawarc \
 && rm -rf /var/lib/apt/lists/* \
 && sync
WORKDIR /factory
COPY docker-boot.sh /
ENTRYPOINT ["/boot.sh"]
