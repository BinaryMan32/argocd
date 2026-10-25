# tdarr

See [docs](https://docs.tdarr.io/docs/installation/docker/run-compose)

The server runs without an internal node, so it does no transcoding or health
checks itself. Workers run on separate tdarr node pods which connect to
`tdarr.media.svc.cluster.local:8266`.

## Setup

Create the transcode cache directory `/mnt/mercury/media/tdarr-cache` on the
NAS, owned by uid/gid `2000`. Keeping it on the same dataset as the media
makes replacing the original file a rename instead of a copy.

When adding a library:

- **Source** `/data/media/movies` or `/data/media/tv`
- **Transcode cache** `/data/tdarr-cache`
