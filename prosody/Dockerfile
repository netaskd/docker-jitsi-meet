FROM jitsi/base

RUN \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -t stretch-backports -y prosody \
		sasl2-bin libsasl2-modules-ldap lua-ldap \
		luarocks git libsasl2-dev gcc liblua5.2-dev \
	&& cd /tmp \
	&& apt download jitsi-meet-tokens \
	&& git clone https://github.com/JorjBauer/lua-cyrussasl.git && \
	cd lua-cyrussasl && \
	luarocks make && \
	apt-dpkg-wrap apt-get remove -t stretch-backports -y luarocks git libsasl2-dev gcc liblua5.2-dev && \
	apt-cleanup \
	&& dpkg -x /tmp/jitsi-meet-tokens*.deb /tmp \
	&& mv /tmp/usr/share/jitsi-meet/prosody-plugins /prosody-plugins-custom \
	&& rm -rf /etc/prosody ../lua-cyrussasl /tmp/usr

COPY rootfs/ /

EXPOSE 5222 5269 5347 5280

VOLUME ["/config", "/prosody-plugins-custom"]
