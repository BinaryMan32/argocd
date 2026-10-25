# tdarr

See [docs](https://docs.tdarr.io/docs/installation/docker/run-compose)

The server runs without an internal node, so it does no transcoding or health
checks itself. Workers run on separate tdarr node pods which connect to
`tdarr.media.svc.cluster.local:8266`.

## Nodes

Nodes are deployments with their worker limits set by env vars, and pods
labeled with `tdarr-worker-type`:

- `tdarr-node-cpu` with 1 transcode CPU worker and 1 health check CPU worker

The free version of tdarr is limited to 5 nodes, so each node runs both worker
types instead of using a separate pool per worker type.

Pod anti-affinity allows at most one pod per worker type on each kubernetes
node, so tdarr nodes are named after the host they run on, e.g. `<host>-cpu`.
The server saves node options by name, so options set in the UI persist while
the pod stays on the same host. Scaling a deployment beyond the number of hosts
leaves the extra pods pending.

## Setup

Create the transcode cache directory `/mnt/mercury/media/tdarr-cache` on the
NAS, owned by uid/gid `2000`. Keeping it on the same dataset as the media
makes replacing the original file a rename instead of a copy.

When adding a library:

- **Source** `/data/media/movies` or `/data/media/tv`
- **Transcode cache** `/data/tdarr-cache`
