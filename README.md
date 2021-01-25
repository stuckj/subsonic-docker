# subsonic-docker

This is a simple Docker container for subsonic. You can customize some aspects of subsonic via environment
variables. See the table below for customization options.

## Environment Variables

| Variable Name                    | Description                                                                                               | Default Value      |
| :------------------------------- | :-------------------------------------------------------------------------------------------------------- | :----------------- |
| SUBSONIC_HOME                    | The home directory for subsonic (inside the container).                                                   | /var/subsonic      |
| SUBSONIC_HOST                    | The hostname or IP of the interface to bind to. You very likely don't want to change this in a container. | 0.0.0.0            |
| SUBSONIC_PORT                    | The port to bind subsonic to.                                                                             | 4040               |
| SUBSONIC_HTTPS_PORT              | The port to use for HTTPS.                                                                                | 0 (unused)         |
| SUBSONIC_CONTEXT_PATH            | The path in the URL under which subsonic will reside.                                                     | /                  |
| SUBSONIC_DB                      | The JDBC database string of the DB to use for subsonic. The default is an in-memory HSQLDB.               |                    |
| SUBSONIC_MAX_MEMORY              | The maximum amount of RAM in MB Subsonic may use                                                          | 150                |
| SUBSONIC_DEFAULT_MUSIC_FOLDER    | The default folder (within the container) for music.                                                      | /var/music         |
| SUBSONIC_DEFAULT_PODCAST_FOLDER  | The default folder (within the container) for podcasts.                                                   | /var/music/Podcast |
| SUBSONIC_DEFAULT_PLAYLIST_FOLDER | The default folder (within the container) for playlists.                                                  | /var/playlists     |

## Tracker (MOD, S3M, etc) / MIDI support

The container has ffmpeg, mikmod (for screamtracker modules), timidity (for midi files), and LAME (for encoding screamtracker and midi files to MP3).
Subsonic is not, by default, configured to use mikmod or timitidy. You must add the configuration. In the transcoding section, add a configuration like
the following for screamtracker / etc files:

| Name               | Convert from                                                               | Convert to | Step 1             | Step 2                                                                  |
| :----------------- | :------------------------------------------------------------------------- | :--------- | :----------------- | :---------------------------------------------------------------------- |
| xm, mod, etc > mp3 | xm mod s3m 669 it stm amf dsm far gdm gt2 imf med mtm okt stx ult umx apun | mp3        | mikmod_stdout %s   | lame -r -b %b --tt %t --ta screamtracker --tl %l -S --resample 44.1 - - |
| mid > mp3          | mid                                                                        | mp3        | timidity_stdout %s | lame - -b 64                                                            |

The `mikmod_stdout` and `timidity_stdout` scripts are simple scripts that run mikmod and timidity sending
the output to stdout in wav format for lame to use for encoding. If you have no need to handle tracker or
midi files than you can safely ignore this configuration.

## Volumes

The container will use volumes for for the following directories within the container:

| Volume Path    | Description |
| :------------- | :---------- |
| /var/music     | Path where subsonic will look for music (by default).                 |
| /var/playlists | Path where subsonic will look for (and store) playlists (by default). |
| /var/subsonic  | Path where subsonic stores any state and configuration.               |

## Docker run

Here is an example `docker run` command that you can use to run the container:

```
docker run -it \
    -p "4040:4040/tcp" \
    -v /data/music:/var/music \
    -v /data/subsonic-data:/var/subsonic \
    --name="subsonic" \
    stuckj/subsonic:latest
```

Here's another example with environment variable customizations:

```
docker run -it \
    -p "8080:8080/tcp" \
    -eSUBSONIC_PORT=8080 \
    -eSUBSONIC_MAX_MEMORY=512 \
    -v /data/music:/var/music \
    -v /data/playlists:/var/playlists \
    -v /data/subsonic-data:/var/subsonic \
    --name="subsonic" \
    stuckj/subsonic:latest
```

## Docker compose

Here is an example `docker-compose.yaml` if you choose to run with docker compose:

```
version: '2'
services:
  subsonic:
    image: stuckj/subsonic:latest
    restart: unless-stopped
    environment:
      - SUBSONIC_MAX_MEMORY=512
      - SUBSONIC_PORT=8080
    ports:
      - 8080:8080/tcp
    volumes:
      - /data/music:/var/music
      - /data/playlists:/var/playlists
      - /data/subsonic-data:/var/subsonic
```

## TODOs

TODO: Change user to non-root!!!

TODO: Setup auto-detection of new versions in Dockerfile (will need to scrape page).