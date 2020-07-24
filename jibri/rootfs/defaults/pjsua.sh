#!/bin/bash
exec pjsua --config-file /etc/jitsi/jibri/pjsua.config "$2" > /dev/null

# soft kill unused services
kill -9 $(pidof ffmpeg pjsua unclutter)

