# Tdarr

See [docs](https://docs.tdarr.io/docs/installation/docker/run-compose)

The server runs without an internal node, so it does no transcoding or health
checks itself. Workers run on separate tdarr node pods which connect to
`tdarr.media.svc.cluster.local:8266`.

## Nodes

Nodes run in the `tdarr-node` deployment, with 1 transcode CPU worker and 1
health check CPU worker.

The free version of tdarr is limited to 5 nodes, so each node runs every worker
type instead of using a separate pool per worker type.

Pod anti-affinity allows at most one node pod on each kubernetes node, so tdarr
nodes are named after the host they run on.
The server saves node options by name, so options set in the UI persist while
the pod stays on the same host. Scaling a deployment beyond the number of hosts
leaves the extra pods pending.

## Setup

Create the transcode cache directory `/mnt/mercury/media/tdarr-cache` on the
NAS, owned by uid/gid `2000`. Keeping it on the same dataset as the media
makes replacing the original file a rename instead of a copy.

When adding a library:

- **Source** `/data/media/movies` or `/data/media/tv`
- **Transcode cache** `/data/tdarr-cache/movies` or `/data/tdarr-cache/tv`

## Authentication

Users sign in with [SSO](https://docs.tdarr.io/docs/other/single-sign-on)
through Authelia. Nodes and the homepage widget connect with an API key,
which the server creates on startup from `seededApiKey`.

Secrets are created by scripts, which must run before syncing:

- `infrastructure/authelia/create-sealed-secrets-oidc.sh tdarr` for the OIDC
  client, which an init container writes into the credentials file tdarr reads
- `services/media/tdarr/create-sealed-secret-api-key.sh` for the API key

Tdarr only lets existing users sign in with SSO, matched by email. On the first
start with authentication enabled, tdarr creates an `admin` user whose password
is the API key:

```sh
kubectl --namespace=media get secret tdarr-api-key --template='{{index .data "api-key" | base64decode}}{{"\n"}}'
```

Sign in as `admin`, then under **Tools → Users** add an SSO-only user for each
person with the email from their Authelia account. Keep the `admin` user as a
fallback in case SSO breaks.

## Radarr and Sonarr

Flows use the **Notify Radarr or Sonarr** plugin to rescan files after
replacing them. The plugin runs on the nodes, which the network policies allow
to reach radarr and sonarr.

Under **Tools → Variables** add global variables, so flows don't repeat them:

| Variable | Value |
| --- | --- |
| `radarr_host` | `http://radarr.media` |
| `radarr_api_key` | radarr API key |
| `sonarr_host` | `http://sonarr.media` |
| `sonarr_api_key` | sonarr API key |

Read the API keys from each app's config:

```sh
kubectl --namespace=media exec deploy/radarr -- sed -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' /config/config.xml
kubectl --namespace=media exec deploy/sonarr -- sed -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' /config/config.xml
```

Configure the plugin with:

| Arr | Arr Host | Arr API Key |
| --- | --- | --- |
| radarr | `{{{args.userVariables.global.radarr_host}}}` | `{{{args.userVariables.global.radarr_api_key}}}` |
| sonarr | `{{{args.userVariables.global.sonarr_host}}}` | `{{{args.userVariables.global.sonarr_api_key}}}` |

## Reviewing transcodes

Add the **Require Review** flow plugin before **Replace Original File** to hold
transcodes in the staging section, with **Auto accept successful transcodes**
off. [review-staged.py](review-staged.py) lists the held files, opens the
original and the transcode in
[video-compare](https://github.com/pixop/video-compare), then sends the chosen
verdict back to tdarr.

It needs `video-compare`, the media share mounted locally, and a tdarr API key
stored in the desktop keyring:

```sh
sudo apt install libsecret-tools
secret-tool store --label='Tdarr API key' service tdarr
./review-staged.py
```

`TDARR_PATH_MAP` maps the pods' `/data` to the local mount, `/mnt/nfs/media` by
default. `TDARR_API_KEY` overrides the keyring.
