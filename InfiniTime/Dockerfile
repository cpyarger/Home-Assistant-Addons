# Docker file to create an image for a hass.io add-on that contains enough software to listen to events via RTL_SDR/RTL_433 and then publish them to the Home Assistant REST API.
# The script resides in a volume and can be modified to meet your needs.
# This hass.io addon is based on Chris Kacerguis' project here: https://github.com/chriskacerguis/honeywell2mqtt,
# which is in turn based on Marco Verleun's rtl2mqtt image here: https://github.com/roflmao/rtl2mqtt

# IMPORTANT: The container needs privileged access to /dev/bus/usb on the host.

ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8


LABEL Description="This image is used to start a script that will monitor for RF events on 433Mhz (configurable) and send the data to The Home Assistant REST API"

#
# First install software packages needed to compile rtl_433 and to publish MQTT events
#
RUN apk add --no-cache --virtual build-deps alpine-sdk cmake git bluez libusb-dev && \
    apk add --no-cache libusb mosquitto-clients jq coreutils wget make musl-dev go git gcc usb-modeswitch dbus bluez pulseaudio-utils python3 python3-pip

RUN pip install bluepy

RUN ls
COPY run.py /


CMD [ "python3 /run.py" ]
