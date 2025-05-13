# Arr

Deploys the `*arr` stack of services.
I couldn't find helm charts for most of these components.
This is based on the blog [Deploying a Kubernetes-Based Media Server][k8s-media] as well as [catvec's funkyboy.zone media-server](https://github.com/catvec/funkyboy.zone/tree/f95c01b6d1f16dd937898d9f3753cf28f17353a3/kubernetes/base/media-server).
It was easier to use `kustomize` instead of creating helm charts, since it's only for this deployment so the configuration doesn't need to be generalized.
See the [kustomization file documentation][kustomization]

[k8s-media]: https://merox.dev/blog/kubernetes-media-server/
[kustomization]: https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/

## Components

- [qbittorrent](./qbittorrent/) (w/ gluetun VPN client): torrent downloads
- radarr: movies
- sonarr: tv
- prowlarr: torrent indexer manager
- jellyseerr: request management

## Secrets

Run `./create-protonvpn-sealed-secret.sh` to update ProtonVPN credentials in [sealed-secret-protonvpn-credentials.yaml][].

[sealed-secret-protonvpn-credentials.yaml]: ./resources/sealed-secret-protonvpn-credentials.yaml

## Linuxserver Tags

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
