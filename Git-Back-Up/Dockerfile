# Docker file to create an image for a hass.io add-on that contains enough software to listen to events via RTL_SDR/RTL_433 and then publish them to the Home Assistant REST API.
# The script resides in a volume and can be modified to meet your needs.
# This hass.io addon is based on Chris Kacerguis' project here: https://github.com/chriskacerguis/honeywell2mqtt,
# which is in turn based on Marco Verleun's rtl2mqtt image here: https://github.com/roflmao/rtl2mqtt

# IMPORTANT: The container needs privileged access to /dev/bus/usb on the host.

ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8


LABEL Description="This image is used to start a script that will monitor for changes to config files and automatically back them up with git"


RUN  apk add --no-cache jq coreutils wget git watchman


# Define an environment variable
#
# Use this variable when creating a container to specify the MQTT broker host.

RUN git clone https://github.com/cpyarger/Home-Assistant-Addons/ &&\
    cd Git-Back-Up &&\ 
    git pull &&\
    cd ..


CMD cd Home-Assistant-Addons/Git-Back-Up && ls -alt && chmod +x ./gba.sh && ./gba.sh
