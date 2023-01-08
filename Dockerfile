FROM ubuntu:latest
LABEL version="1.2" maintainer="John Stucklen <stuckj@gmail.com>"

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV SUBSONIC_HOME /var/subsonic
ENV SUBSONIC_HOST 0.0.0.0
ENV SUBSONIC_PORT 4040
ENV SUBSONIC_HTTPS_PORT 0
ENV SUBSONIC_CONTEXT_PATH /
ENV SUBSONIC_DB ""
ENV SUBSONIC_MAX_MEMORY 150
ENV SUBSONIC_DEFAULT_MUSIC_FOLDER /var/music
ENV SUBSONIC_DEFAULT_PODCAST_FOLDER /var/music/Podcast
ENV SUBSONIC_DEFAULT_PLAYLIST_FOLDER /var/playlists
ENV SUBSONIC_UID 1000
ENV SUBSONIC_GID 1000

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
  && wget --no-check-certificate https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-6.1.6-standalone.tar.gz \
  && tar xvzf subsonic-6.1.6-standalone.tar.gz -C /opt/subsonic \
  && rm -rf subsonic-6.1.6-standalone.tar.gz

COPY mikmod_stdout /opt/subsonic
COPY timidity_stdout /opt/subsonic
COPY entrypoint.sh /opt/subsonic/entrypoint.sh

WORKDIR /opt/subsonic

VOLUME $SUBSONIC_DEFAULT_MUSIC_FOLDER $SUBSONIC_DEFAULT_PLAYLIST_FOLDER $SUBSONIC_HOME

EXPOSE $SUBSONIC_PORT/tcp

ENTRYPOINT [ "/opt/subsonic/entrypoint.sh" ]
