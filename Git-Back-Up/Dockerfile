# Docker file to create an image for a hass.io add-on

ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

LABEL Description="This image is used to start a script that will monitor for changes to config files and automatically back them up with git"

RUN  apk add --no-cache jq coreutils wget git inotify-tools


COPY gba.sh /
RUN chmod a+x /gba.sh

CMD [ "/gba.sh" ]

