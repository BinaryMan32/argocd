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
