ARG JITSI_REPO=jitsi
FROM ${JITSI_REPO}/base
ARG VERSION

COPY rootfs/ /
COPY patch/build/jitsi-meet-web_${VERSION}_all.deb /patch/build/
COPY patch/build/jitsi-meet-web-config_${VERSION}_all.deb /patch/build/

RUN \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -y cron nginx-extras /patch/build/jitsi-meet-web_${VERSION}_all.deb && \
	apt-dpkg-wrap apt-get install -y -t stretch-backports certbot && \
    dpkg -x /patch/build/jitsi-meet-web-config_${VERSION}_all.deb /tmp/pkg && \
    mv /tmp/pkg/usr/share/jitsi-meet-web-config/config.js /defaults && \
	mv /usr/share/jitsi-meet/interface_config.js /defaults && \
	apt-cleanup && \
	rm -f /etc/nginx/conf.d/default.conf && \
	rm -rf /tmp/pkg /var/cache/apt

EXPOSE 80 443

VOLUME ["/config", "/etc/letsencrypt", "/usr/share/jitsi-meet/transcripts"]
