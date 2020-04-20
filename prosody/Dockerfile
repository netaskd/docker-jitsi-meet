ARG JITSI_REPO=jitsi
FROM ${JITSI_REPO}/base
ARG VERSION

ADD https://prosody.im/files/prosody-debian-packages.key /tmp/prosody.key

RUN \
    apt-key add /tmp/prosody.key \
    && rm -f /tmp/prosody.key \
    && echo "deb http://packages.prosody.im/debian stretch main" > /etc/apt/sources.list.d/prosody.list \
    && apt-dpkg-wrap apt-get update \
    && apt-dpkg-wrap apt-get install -y prosody=${VERSION:-*}~stretch6 \
    && apt-dpkg-wrap apt-get install -t stretch-backports -y \
      liblua5.2-dev \
      sasl2-bin \
      libsasl2-modules-ldap \
      libsasl2-dev \
      libssl1.0-dev \
      lua-basexx \
      lua-ldap \
      lua-sec \
      luarocks \
      git \
      gcc \
      patch \
    && luarocks install cyrussasl 1.1.0-1 \
    && luarocks install lua-cjson 2.1.0-1 \
    && luarocks install luajwtjitsi 1.3-7 \
    && apt-dpkg-wrap apt-get remove -y \
      git \
      gcc \
      luarocks \
      libsasl2-dev \
      libssl1.0-dev \
      liblua5.2-dev \
    && apt-cleanup \
    && rm -rf /etc/prosody /var/cache/apt /etc/apt/sources.list.d/prosody.list

RUN \
    apt-dpkg-wrap apt-get update \
    && apt-dpkg-wrap apt-get -d install -y jitsi-meet-prosody \
    && dpkg -x /var/cache/apt/archives/jitsi-meet-prosody*.deb /tmp \
    && mv /tmp/usr/share/jitsi-meet/prosody-plugins /prosody-plugins \
    && apt-cleanup \
    && rm -rf /tmp/usr /var/cache/apt /var/lib/apt/lists

RUN \
    curl -4so /prosody-plugins/mod_turncredentials.lua \
    https://raw.githubusercontent.com/netaskd/mod_turncredentials/master/mod_turncredentials.lua

RUN patch -d /usr/lib/prosody/modules/muc -p0 < /prosody-plugins/muc_owner_allow_kick.patch

COPY rootfs/ /

EXPOSE 5222 5269 5347 5280

VOLUME ["/config", "/prosody-plugins"]

