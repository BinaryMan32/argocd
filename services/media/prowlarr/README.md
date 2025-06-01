# prowlarr

See [dockerhub](https://hub.docker.com/r/linuxserver/prowlarr)

## Setup

Make sure to do common setup from media.

Under `Indexers`:

1. click `+` to add `Indexer Proxy`
2. pick `Http`
3. Host `vpn-http-proxy.media.svc.cluster.local`
3. Port `8080`
4. Username (leave blank)
5. Password (leave blank)

Under `Apps`:

1. click `+` to add app
2. Prowlarr Server `http://prowlarr.media.svc.cluster.local`
3. `*arr` Server
    - `http://lidarr.media.svc.cluster.local`
    - `http://radarr.media.svc.cluster.local`
    - `http://sonarr.media.svc.cluster.local`

Under `General`

1. Host
    1. Application URL `https://prowlarr.int.fivebytestudios.com`
