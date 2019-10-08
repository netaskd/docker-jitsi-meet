ARG JITSI_REPO=jitsi
FROM ${JITSI_REPO}/base
ARG VERSION

RUN \
	curl -so /dev/stdout https://openresty.org/package/pubkey.gpg | apt-key add - \
	&& echo "deb http://openresty.org/package/debian buster openresty" > /etc/apt/sources.list.d/openresty.list \
	&& apt-dpkg-wrap apt-get update \
	&& apt-dpkg-wrap apt-get install -y git cron openresty jitsi-meet-web=${VERSION:-*} \
	&& apt-dpkg-wrap apt-get install -y certbot \
	&& apt-cleanup \
	&& rm -f /etc/nginx/conf.d/default.conf \
	&& rm -f /usr/share/jitsi-meet/interface_config.js

COPY rootfs/ /

EXPOSE 80 443

VOLUME /config

