FROM jitsi/base

RUN \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -t stretch-backports -y prosody \
		sasl2-bin libsasl2-modules-ldap lua-ldap \
		luarocks git libsasl2-dev gcc liblua5.2-dev && \
	git clone https://github.com/JorjBauer/lua-cyrussasl.git && \
	cd lua-cyrussasl && \
	luarocks make && \
	apt-dpkg-wrap apt-get remove -t stretch-backports -y luarocks git libsasl2-dev gcc liblua5.2-dev && \
	apt-cleanup && \
	rm -rf /etc/prosody ../lua-cyrussasl

COPY rootfs/ /

EXPOSE 5222 5269 5347 5280

VOLUME ["/config", "/prosody-plugins-custom"]
