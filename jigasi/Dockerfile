ARG JITSI_REPO=jitsi
FROM ${JITSI_REPO}/base-java
ARG VERSION

RUN \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -y jigasi=${VERSION:-*} && \
	apt-cleanup

COPY rootfs/ /

VOLUME /config
