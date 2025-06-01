# Media

Deploys services which manage media files, including the `servarr` stack of services.
I couldn't find helm charts for most of these components.
This is based on the blog [Deploying a Kubernetes-Based Media Server][k8s-media] as well as [catvec's funkyboy.zone media-server](https://github.com/catvec/funkyboy.zone/tree/f95c01b6d1f16dd937898d9f3753cf28f17353a3/kubernetes/base/media-server).
It was easier to use `kustomize` instead of creating helm charts, since it's only for this deployment so the configuration doesn't need to be generalized.
See the [kustomization file documentation][kustomization]

[k8s-media]: https://merox.dev/blog/kubernetes-media-server/
[kustomization]: https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/

## Setup

### Secrets

Run scripts to generate `SealedSecret` resources:

- `./create-protonvpn-sealed-secret.sh` to update [sealed-secret-protonvpn-credentials.yaml][].
- `./create-spotfy-navidrome-sealed-secret.sh` to update [sealed-secret-spotify-navidrome.yaml][].

[sealed-secret-protonvpn-credentials.yaml]: ./resources/sealed-secret-protonvpn-credentials.yaml
[sealed-secret-spotify-navidrome.yaml]: ./resources/sealed-secret-spotify-navidrome.yaml

### Common

Some settings are common to all of lidarr, prowlarr, radarr, and sonarr.

Under `General`:

1. enable `Use Proxy`
2. Hostname `vpn-http-proxy.media.svc.cluster.local`
3. Port `8080`
4. Username (leave blank)
5. Password (leave blank)
6. Ignored addresses `*.media.svc.cluster.local`

Under `Download Clients`

1. click `+` to add a client
2. pick `qBittorrent`
3. Host `qbittorrent.media.svc.cluster.local`
4. Port `80`
5. Username (from bitwarden qbittorrent)
6. Password (from bitwarden qbittorrent)

### Components

- [qbittorrent](./qbittorrent/) (w/ gluetun VPN client): torrent downloads
- [prowlarr](./prowlarr): torrent indexer manager
- [radarr](./radarr/): movies
- [sonarr](./sonarr/): tv
- [jellyseerr](../services/templates/jellyseerr.yaml): request management

## Implementation Details

### Hard Links

If you store torrents and media on the same volume, radarr and sonarr can use hard links when copying from `torrents/` to `media/`.

The high-level directory structure:

```text
media/
    torrents/
        movies/
        tv/
    media/
        movies/
        tv/
```

what each component mounts:

- qbittorrent `media/torrents/`
- radarr/sonarr `media/`
- jellyfin `media/media/`

For more info, see the [servarr wiki](https://wiki.servarr.com/docker-guide#consistent-and-well-planned-paths).

### Linuxserver Tags

Unfortunately, renovate expects container image tags to follow semver, and the linuxserver team doesn't use semver.

The linuxserver team wrote a [blog post about docker tags][lsio-blog-tags] in which the most promising format "Built tag (static)" looked like `1.2.3-ls123`.
However, no tags exactly like this appear in any project.
Below are the latest versions for each package:

- qbittorrent 5.1.0-r0-ls393
- prowlarr 1.35.1.5034-ls117
- radarr 5.22.4.9896-ls274
- sonarr 4.0.14.2939-ls282

Renovate has some [linuxserver regex versioning examples][renovate-regex] which aren't quite correct for these versions, but can be adapted fairly easily

[lsio-blog-tags]: https://www.linuxserver.io/blog/docker-tags-so-many-tags-so-little-time#2-build-tag-static
[renovate-regex]: https://docs.renovatebot.com/modules/versioning/regex/
