ARG VERSION
FROM etherpad/etherpad:${VERSION:-latest}

USER root
RUN \
	apt-get update \
	&& apt-get install -y abiword \
	&& apt-get clean \
	&& chown etherpad /usr/bin/abiword

USER etherpad:etherpad

ARG ETHERPAD_PLUGINS
RUN for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}"; done

ADD ./rootfs/defaults/settings.json /opt/etherpad-lite/settings.json

EXPOSE 9001

