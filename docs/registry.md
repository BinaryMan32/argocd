# Container Registry Pull Through Cache

Use a container registry pull through cache for docker hub.
This pulls the image only once, instead of once per node.
It's also easier to configure a docker hub personal access token once in the cache instead of on each k3s node.

## Mirror on TrueNAS

Install the `distribution` application.

`http.secret` is required and can be generated using:

```sh
openssl rand -hex 32
```

See the [distribution configuration docs](https://distribution.github.io/distribution/about/configuration/) for details.
Also the [distribution mirror recipe](https://distribution.github.io/distribution/recipes/mirror/).

### Docker Hub Access Token

Generate a new [access token](https://app.docker.com/settings/personal-access-tokens) with

- Access token description: mercury
- Expires on: Never
- Access permissions: Public Repo Read-only

Configure the TrueNAS distribution app by setting the environment variables:

- `REGISTRY_PROXY_REMOTEURL`: `https://registry-1.docker.io`
- `REGISTRY_PROXY_USERNAME`: (from access token)
- `REGISTRY_PROXY_PASSWORD`: (from access token)

### Allow Image Deletion

- `REGISTRY_STORAGE_DELETE_ENABLED`: `true`

### Noisy Trace Export Logging

The logs were full of messages like this:

```text
level=error msg="traces export: Post \"https://localhost:4318/v1/traces\": dial tcp [::1]:4318: connect: connection refused" environment=development go.version=go1.23.7 instance.id=ea669697-1947-4c5f-825f-67342f1d60d9 service=registry version=3.0.0
```

Which are caused by trying to export OpenTelemetry traces.
To disable, configure:

- `OTEL_TRACES_EXPORTER`: `none`
- `REGISTRY_LOG_LEVEL`: `info`

## Configuring K3S Containerd

```sh
for host in griffin{0..8}; do
    echo $host
    ssh $host sudo mkdir -p /etc/rancher/k3s/
    cat docs/registries.yaml | ssh $host sudo tee /etc/rancher/k3s/registries.yaml
    ssh $host sudo systemctl restart k3s-agent || ssh $host sudo systemctl restart k3s
done
```

See [K3S Private Registry](https://docs.k3s.io/installation/private-registry).
