# Jitsi Meet on Docker

![](resources/jitsi-docker.png)

[Jitsi](https://jitsi.org/) is a set of Open Source projects that allows you to easily build and deploy secure videoconferencing solutions.

[Jitsi Meet](https://jitsi.org/jitsi-meet/) is a fully encrypted, 100% Open Source video conferencing solution that you can use all day, every day, for free — with no account needed.

This repository contains the necessary tools to run a Jitsi Meet stack on [Docker](https://www.docker.com) using [Docker Compose](https://docs.docker.com/compose/).

## Installation

The installation manual is available [here](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker).

## Additional features that included on this fork

### Images
* **turn**: [Coturn](https://github.com/coturn/coturn), the TURN server.

### Advanced configuration

#### Transcription configuration

If you want to enable the Transcribing function, these options are required:

Variable | Description | Example
--- | --- | ---
`ENABLE_JIGASI_TRANSCRIBER` | Enable Jigasi transcription in a conference | 1
`GOOGLE_APPLICATION_CREDENTIALS` | Credentials for connect to Cloud Google API from Jigasi. Path located inside the container | /config/key.json

For set `GOOGLE_APPLICATION_CREDENTIALS` please read https://cloud.google.com/text-to-speech/docs/quickstart-protocol section "Before you begin" from 1 to 5 paragraph

#### JItsi BRoadcasting Infrastructure configuration Recorders

For working jibri after commit jibri@5a71969 and jibri@600d4fe, you need to configure 8 capture/playback interfaces It's enough for 4 jibri instances on one node. All commands need to do on a `HOST` machine (not in container).

for Centos 7, module already compiled with kernel, so just run:
```
# configure 8 capture/playback interfaces
echo "options snd-aloop enable=1,1,1,1,1,1,1,1 index=0,1,2,3,4,5,6,7" > /etc/modprobe.d/asound.conf
# setup autoload the module
echo "snd_aloop" > /etc/modules-load.d/snd_aloop.conf
# load the module
modprobe snd-aloop
# check that the module is loaded
lsmod | grep snd_aloop
```
for Ubuntu 16.04 (Xenial):
```
# install the module
apt update && apt install linux-image-extra-virtual
# configure 8 capture/playback interfaces
echo "options snd-aloop enable=1,1,1,1,1,1,1,1 index=0,1,2,3,4,5,6,7" > /etc/modprobe.d/asound.conf
# setup autoload the module
echo "snd-aloop" >> /etc/modules
# load the module
modprobe snd-aloop
# check that the module is loaded
lsmod | grep snd_aloop
```

#### JItsi BRoadcasting Infrastructure configuration SIP gateways

Before you start please make sure that you have working JWT tokens for jibri-meet,
or apply this dirty hack to jitsi-meet repo (rebuild needed) for using `peopleSearchUrl` with LDAP auth:

```
sed -i 's/!isGuest(state)/isLocalParticipantModerator(state)/' jitsi-meet/react/features/invite/functions.js
```

Also, this repo contains scripts with dirty hacks (around `callLogin`/`callLoginParams`) of JiBRI files for working JiBRI in kinda dual-mode Recorder/SIPgw on the same instance.

Anyway, the instance can handle only one mode at the same time, but in free state, the instance ready to run any of two mode.

For more details about changes please see `jibri/mod/Dockerfile` and `jibri/rootfs/defaults/google-chrome.replace` and another files ;)

By default, this `mod` enabled in `jibri/Makefile`.

It depends on 8 capture/playback interfaces, described above.

For working with PJSUA video in Jibri on `Centos 7` please follow this instruction. All commands need to do on a `HOST` machine (not in container).
```
# install v4l2loopback module
git clone https://github.com/umlaeute/v4l2loopback.git
cd v4l2loopback
yum install -y gcc kernel-devel-$(uname -r)
make && make install && depmod -a
# configure 8 video interfaces. It's enough for 4 Jibri SIPgw instances
echo "options v4l2loopback devices=8 video_nr=10,11,12,13,14,15,16,17 exclusive_caps=1,1,1,1,1,1,1,1" > /etc/modprobe.d/v4l2loopback.conf
# setup autoload the module
echo "v4l2loopback" > /etc/modules-load.d/v4l2loopback.conf
# load the module
modprobe v4l2loopback
# check that the module is loaded
lsmod | grep v4l2loopback
ls /dev/video[1][0-7]
```

For enable SIP Video Gateway in JIBRI, these options are required:

Variable | Description | Default value
--- | --- | ---
`JIBRI_SIP_BREWERY_MUC` | MUC name for the SIP Jibri pool | sipjibribrewery
`JIBRI_SIP_USERNAME` | SIP username | 1234
`JIBRI_SIP_PASSWORD` | SIP password | Passw0rd
`JIBRI_SIP_REALM` | SIP realm/domain | sip.domain.com
`JIBRI_SIP_PORT_MIN` | Initial UDP port for RTP | 19900
`JIBRI_SIP_TRANSPORT` | Transport for SIP connections | TLS
`JIBRI_SIP_ENABLE_SRTP` | Enable SRTP for media | 1

#### Setting up Octo (cascaded bridges)
NOTE: For get working octo properly you have to set header "X-User-Region" before it passing to nginx. It can be realized via geoip or another logic and it's not described here.

The header "X-User-Region" will be passed through nginx and dynamically set variable for `userRegion` in config.js file via ssi nginx module.
If `userRegion` and `JVB_OCTO_REGION` the same region, user will be connected to the instanse JVB that has this region.

This behavion already preconfigured and receiving X-User-Region in config.js looks like this:

```
deploymentInfo: {
    // shard: "shard1",
    // region: europe" -->',
    userRegion: '<!--#echo var="http_x_user_region" default="us-east-1" -->'
},
```

If you want to enable the Octo cascading briges, these options are required:

Variable | Description | Default value
--- | --- | ---
`JICOFO_BRIDGE_SELECTION_STRATEGY` | Bridge selection stratagy for new connections | RegionBasedBridgeSelectionStrategy
`JVB_OCTO_BIND_PORT` | The UDP port number which the Octo relay should use | 4096
`JVB_OCTO_REGION` | The region that the jitsi-videbridge instance is in | us-east-1

The brige selection stratagy is:

* `SplitBridgeSelectionStrategy` - can be used for testing. It tries to select a new bridge for each client, regardless of the regions.

* `RegionBasedBridgeSelectionStrategy` - matches the region of the clients to the region of the Jitsi Videobridge instances. Used by default.

#### TURN(S) server
If you want to enable TURN server, configure it and run Docker Compose as
follows: ``docker-compose -f docker-compose.yml -f turn.yml up``

Variable | Description | Default value
--- | --- | ---
`TURN_ENABLE` | Use TURN for P2P and JVB (bridge mode) connections | 0
`TURN_REALM` | Realm to be used for the users with long-term credentials mechanism or with TURN REST API | realm
`TURN_SECRET` | Secret for connect to TURN server | keepthissecret
`TURN_TYPE` | Type of TURN(s) (turn/turns) | turns
`TURN_HOST` | Annonce FQDN/IP address of the turn server via XMPP (XEP-0215) | 192.168.1.1
`TURN_PUBLIC_IP` | Public IP address for an instance of turn server | set dynamically
`TURN_PORT` | TLS/TCP/UDP turn port for connection | 5349
`TURN_TRANSPORT` | transport for turn connection (tcp/udp) | tcp
`TURN_RTP_MIN` | RTP start port for turn/turns connections | 16000
`TURN_RTP_MAX` | RTP end port for turn/turns connections | 17000

For enable web-admin panel for turn, please set variables below

Variable | Description | Default value
--- | --- | ---
`TURN_ADMIN_ENABLE` | Enable web-admin panel | 0
`TURN_ADMIN_USER` | Username for admin panel | admin
`TURN_ADMIN_SECRET` | Password for admin panel | changeme
`TURN_ADMIN_PORT` | HTTP(s) port for acess to admin panel | 8443

#### WebSockets for XMPP and JVB connections.

If you want to enable the WebSockets for XMPP and JVB, these options are required:

For confirm that XMPP Websockets work please make a conference, open dev console and run `APP.conference._room.xmpp.connection.closeWebsocket()`

Variable | Description | Default value
--- | --- | ---
`JVB_WS_ENABLE` | Enable WebSockets for XMPP (prosody) and JVB connections | 0

## TODO

* Spot
* Broadcasting interface (one-to-all). Include streamer mpeg-dash and webstreamer viewer.
