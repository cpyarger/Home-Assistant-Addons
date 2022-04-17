# Docker file to create an image for a hass.io add-on

ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

LABEL Description="This image is used to start a script that will monitor for changes to config files and automatically back them up with git"

RUN  apk add --no-cache jq coreutils wget git inotify-tools

RUN git clone https://github.com/cpyarger/Home-Assistant-Addons/ &&\
    cd Git-Back-Up &&\ 
    git pull &&\
    cd ..
    
CMD cd Home-Assistant-Addons/Git-Back-Up && ls -alt && chmod +x ./gba.sh && ./gba.sh
