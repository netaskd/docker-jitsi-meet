# etherdraw #

# node 9.2 
FROM node:9-alpine
MAINTAINER Jonathan Rosenbaum <fspc@freesoftwarepc.com>

RUN apk update; apk add bash git giflib-dev libjpeg-turbo-dev curl mysql-client python2 pkgconfig cairo-dev make g++ 

WORKDIR /opt/

#RUN git clone https://github.com/aaronkvanmeerten/draw.git
RUN git clone git://github.com/JohnMcLear/draw.git

ENV PYTHON=/usr/bin/python2

WORKDIR draw 

RUN bin/installDeps.sh && rm settings.json

RUN sed -i 's/^node/exec\ node/' bin/run.sh

VOLUME /opt/draw/var /opt/draw/node_modules

RUN ln -s var/settings.json settings.json

EXPOSE 9002

#RUN adduser -u 5001 -D draw
#RUN chown -R draw:draw /opt/draw
#USER draw:draw

COPY run.sh bin/run.sh

CMD ["bin/run.sh"]
