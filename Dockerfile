FROM ubuntu:latest
LABEL version="1.1" maintainer="John Stucklen <stuckj@gmail.com>"

ARG DL_BASE_URL=https://s3-eu-west-1.amazonaws.com/subsonic-public/download
ARG DL_VERSION=6.1.6
ARG DL_SHA256=dfb78fa9bb38f2265f498122846b1d6121f7666035a78dbe3a24305bd16c18a0

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV SUBSONIC_UID 1000
ENV SUBSONIC_GID 1000
ENV SUBSONIC_VERSION $DL_VERSION

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y locales ffmpeg openjdk-8-jre-headless nano flac lame mikmod timidity wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && locale-gen \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN mkdir -p /opt/subsonic \
  && wget --no-check-certificate $DL_BASE_URL/subsonic-$DL_VERSION-standalone.tar.gz \
  && echo $DL_SHA256 *subsonic-$DL_VERSION-standalone.tar.gz | sha256sum -c - \
  && tar xvzf subsonic-$DL_VERSION-standalone.tar.gz -C /opt/subsonic \
  && rm -rf subsonic-$DL_VERSION-standalone.tar.gz

COPY mikmod_stdout /opt/subsonic
COPY timidity_stdout /opt/subsonic
COPY entrypoint.sh /opt/subsonic/entrypoint.sh

WORKDIR /opt/subsonic

VOLUME [ "/var/music", "/var/playlists", "/var/subsonic" ]

EXPOSE 4040/tcp

ENTRYPOINT [ "/opt/subsonic/entrypoint.sh" ]
