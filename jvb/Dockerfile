FROM jitsi/base-java

RUN \
	echo "deb http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list.d/backports.list && \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -t jessie -y libssl1.0.0 && \
	apt-dpkg-wrap apt-get install -y netbase whois jitsi-videobridge && \
	apt-cleanup

COPY rootfs/ /

VOLUME /config
