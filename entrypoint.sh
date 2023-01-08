#!/bin/sh

set -e

# This is a replacement for subsonic.sh that comes with subsonic as it is not docker friendly
# This will properly NOT daemonize the java process and will log to stdout / stderr.

# Create subsonic user, taking uid, gid and homedir from (Docker) environment
if ! id -g subsonic > /dev/null 2>&1; then
    groupadd --system -o --gid "$SUBSONIC_GID" subsonic
fi
if ! id -u subsonic > /dev/null 2>&1; then
    useradd --system -o --home-dir "$SUBSONIC_HOME" --shell /usr/sbin/nologin \
            --gid "$SUBSONIC_GID" --uid "$SUBSONIC_UID" subsonic
fi

# Use JAVA_HOME if set, otherwise assume java is in the path.
JAVA=java
if [ -e "${JAVA_HOME}" ]; then
    JAVA=${JAVA_HOME}/bin/java
fi

# Make sure all transcoding executables are in /var/subsonic/transcode (subsonic requires this)
mkdir -p /var/subsonic/transcode
chown subsonic:subsonic /var/subsonic/transcode
ln -sf "$(which ffmpeg)" /var/subsonic/transcode/ffmpeg
ln -sf "$(which lame)" /var/subsonic/transcode/lame
cp /opt/subsonic/mikmod_stdout /var/subsonic/transcode
cp /opt/subsonic/timidity_stdout /var/subsonic/transcode

# Make sure permissions are correct on /var/subsonic
chown subsonic:subsonic /var/subsonic

exec /bin/su -s /bin/bash -c "${JAVA} -Xmx${SUBSONIC_MAX_MEMORY}m \
  -Dsubsonic.home=${SUBSONIC_HOME} \
  -Dsubsonic.host=${SUBSONIC_HOST} \
  -Dsubsonic.port=${SUBSONIC_PORT} \
  -Dsubsonic.httpsPort=${SUBSONIC_HTTPS_PORT} \
  -Dsubsonic.contextPath=${SUBSONIC_CONTEXT_PATH} \
  -Dsubsonic.db=\"${SUBSONIC_DB}\" \
  -Dsubsonic.defaultMusicFolder=${SUBSONIC_DEFAULT_MUSIC_FOLDER} \
  -Dsubsonic.defaultPodcastFolder=${SUBSONIC_DEFAULT_PODCAST_FOLDER} \
  -Dsubsonic.defaultPlaylistFolder=${SUBSONIC_DEFAULT_PLAYLIST_FOLDER} \
  -Djava.awt.headless=true \
  -verbose:gc \
  -jar subsonic-booter-jar-with-dependencies.jar" subsonic
