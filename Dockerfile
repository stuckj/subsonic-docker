FROM ubuntu:latest
LABEL version="1.0" maintainer="John Stucklen <stuckj@gmail.com>"

RUN apt update \
  && apt upgrade -y \
  && apt install -y locales ffmpeg openjdk-8-jre-headless nano flac lame mikmod timidity wget \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en 

RUN mkdir -p /opt/subsonic \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN wget --no-check-certificate https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-6.1.6-standalone.tar.gz \
  && tar xvzf subsonic-6.1.6-standalone.tar.gz -C /opt/subsonic \
  && rm -rf subsonic-6.1.6-standalone.tar.gz

COPY mikmod_stdout /opt/subsonic
COPY timidity_stdout /opt/subsonic

COPY entrypoint.sh /opt/subsonic/entrypoint.sh

RUN groupadd --system --gid 1000 subsonic \
  && useradd --system --home-dir /var/subsonic --shell /usr/sbin/nologin --gid 1000 --uid 1000 subsonic

WORKDIR /opt/subsonic

VOLUME [ "/var/music", "/var/playlists", "/var/subsonic" ]

EXPOSE 4040/tcp

ENTRYPOINT [ "/opt/subsonic/entrypoint.sh" ]
