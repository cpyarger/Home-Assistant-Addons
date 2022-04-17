# Docker file to create an image for a hass.io add-on that watches the config folders and uses Git to back them up to a remote repository 
FROM node:8-alpine



LABEL Description="This image is used to start a script that will monitor for changes to config files and automatically back them up with git"
# Install the packages required for watchman to work properly:
RUN apk add --no-cache libcrypto1.0 libgcc libstdc++

# Copy the watchman executable binary directly from our image:
COPY --from=icalialabs/watchman:4-alpine3.4 /usr/local/bin/watchman* /usr/local/bin/

# Create the watchman STATEDIR directory:
RUN mkdir -p /usr/local/var/run/watchman \
 && touch /usr/local/var/run/watchman/.not-empty

ENV LANG C.UTF-8
RUN  apk add --no-cache jq coreutils wget git

RUN git clone https://github.com/cpyarger/Home-Assistant-Addons/ &&\
    cd Git-Back-Up &&\ 
    git pull &&\
    cd ..

CMD cd Home-Assistant-Addons/Git-Back-Up && ls -alt && chmod +x ./gba.sh && ./gba.sh
