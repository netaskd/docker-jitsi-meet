ARG JITSI_REPO=jitsi

FROM ${JITSI_REPO}/base as pjsua-builder

RUN apt-dpkg-wrap apt-get update \
  && apt-dpkg-wrap apt-get install -y git build-essential libv4l-dev libsdl2-dev \
    libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavresample-dev \
    libavutil-dev libswresample-dev libswscale-dev libasound2-dev libopus-dev libvpx-dev libssl-dev

RUN git clone --single-branch https://github.com/pjsip/pjproject \
  && cd pjproject \
  && curl -4so jibri-2.10-dev1.patch https://github.com/pjsip/pjproject/compare/master...jitsi:jibri-2.10-dev1.patch \
  && git apply jibri-2.10-dev1.patch \
  && ./configure \
  && make dep \
  && make 

FROM maven:3-jdk-8-slim as jibri-builder
#FROM maven:3-jdk-8-slim-local as jibri-builder
ARG VERSION

RUN apt-get update \
  && apt-get install -y git devscripts vim libxml2-utils

RUN rm -rf /app >/dev/null 2>&1 \
  ; mkdir -p /app \
  && export WORKSPACE=/app/jibri \
  && git clone https://github.com/jitsi/jibri.git ${WORKSPACE} \
  && cd ${WORKSPACE} \
  && git reset --hard $(echo ${VERSION}|awk -F\- '{print $3}'|sed 's/^g//') \
  && curl -4so ${PWD}/pr277.patch https://github.com/jitsi/jibri/commit/dcd2cee2d51ffd9e4737f79fa79fa9fe3aa422ff.patch \
  && git apply pr277.patch \
  && sed -i 's/1280x720/1920x1080/' src/main/kotlin/org/jitsi/jibri/capture/ffmpeg/FfmpegCapturer.kt \
  && sed -i 's/h264ConstantRateFactor: Int = 25/h264ConstantRateFactor: Int = 22/' src/main/kotlin/org/jitsi/jibri/capture/ffmpeg/FfmpegCapturer.kt \
  && sed -i 's/val callLoginParams: XmppCredentials?/val callLoginParams: XmppCredentials? = null/' src/main/kotlin/org/jitsi/jibri/service/impl/SipGatewayJibriService.kt \
  && sed -i -n '/SipClientParams(startIq/{x;s/xmppEnvironment.callLogin/null/;x};x;1!p;${x;p}' src/main/kotlin/org/jitsi/jibri/api/xmpp/XmppApi.kt \
  && git --no-pager diff \
  && sed -i "s/^git push/#git push/" resources/jenkins/release.sh \
  && resources/jenkins/build.sh \
  && resources/jenkins/release.sh Minor

# Main jibri image
FROM ${JITSI_REPO}/base-java

# list of versions http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable
ARG CHROME_RELEASE=84.0.4147.89
ARG CHROMEDRIVER_MAJOR_RELEASE=84

RUN \
	[ "${CHROME_RELEASE}" = "latest" ] \
	&& curl -4s https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-dpkg-wrap apt-get update \
	&& apt-dpkg-wrap apt-get install -y google-chrome-stable \
	&& apt-cleanup \
	|| true

RUN \
        [ "${CHROME_RELEASE}" != "latest" ] \
        && curl -4so /tmp/google-chrome-stable_${CHROME_RELEASE}_amd64.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb \
	&& apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y /tmp/google-chrome-stable_${CHROME_RELEASE}_amd64.deb \
	&& apt-cleanup \
	|| true

RUN \
	[ ${CHROMEDRIVER_MAJOR_RELEASE} = "latest" ] \
	&& CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" \
	|| CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_MAJOR_RELEASE})" \
	&& curl -4Ls https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip \
	| zcat >> /usr/bin/chromedriver \
	&& chmod +x /usr/bin/chromedriver \
	&& chromedriver --version

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y ffmpeg curl alsa-utils icewm xdotool xserver-xorg-input-void \
           xserver-xorg-video-dummy libv4l-0 libgl1-mesa-dri jitsi-upload-integrations unclutter psmisc \
        && apt-cleanup

# JIBRI package
ARG VERSION
COPY --from=jibri-builder /app/jibri_${VERSION:-*}_all.deb /tmp/

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y /tmp/jibri_${VERSION:-*}_all.deb \
        && apt-cleanup

# PJSUA binary
COPY --from=pjsua-builder /pjproject/pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/local/bin/pjsua
COPY --from=pjsua-builder /pjproject/pjsip-apps/bin/samples/x86_64-unknown-linux-gnu/* /usr/local/bin/

COPY rootfs /

VOLUME /config
