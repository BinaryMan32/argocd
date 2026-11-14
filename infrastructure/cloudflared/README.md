# cloudflared

Runs a [Cloudflare Tunnel][tunnel] connector, which exposes services on the
`wildfreddy.net` domain without opening any ports on the router.
Cloudflare terminates TLS using its free Universal SSL certificate, which covers
`wildfreddy.net` and `*.wildfreddy.net`, so services must use single level
subdomains such as `argocd-github-webhook.wildfreddy.net`.

```text
client → Cloudflare edge (TLS) → tunnel → cloudflared
  → traefik-cloudflare Service (web-cloudflare entrypoint)
  → traefik-cloudflare Gateway → HTTPRoute → service
```

* The tunnel is [locally-managed][local]: routing rules are in
  [configmap.yaml](./templates/configmap.yaml) instead of the Cloudflare dashboard.
  All `*.wildfreddy.net` traffic is sent to Traefik, so routing for individual
  services is done by HTTPRoutes.
* Hostnames without a matching HTTPRoute return 404.
* cloudflared is deployed into the `cloudflare` namespace.

## Initial Setup

1. Install [cloudflared][install] locally.
2. Create the tunnel, choosing the `wildfreddy.net` zone when the browser opens.
   This writes the tunnel credentials to `~/.cloudflared/<UUID>.json`.

   ```sh
   cloudflared tunnel login
   cloudflared tunnel create griffin
   ```

3. Set `cloudflare.tunnelId` in [values.yaml](../infrastructure/values.yaml) to the tunnel UUID.
4. Run [create-sealed-secret-tunnel-credentials.sh](./create-sealed-secret-tunnel-credentials.sh)
   to create the `cloudflared-tunnel-credentials` sealed secret.
   Then delete the local credentials file and `~/.cloudflared/cert.pem`.
   `cert.pem` can create and delete tunnels in the account, and can be recreated
   with `cloudflared tunnel login` when needed.

## Verification

In the [Cloudflare dashboard][dashboard], the tunnel is listed by name (`griffin`)
under **Networking** → **Tunnels**.
Since the tunnel is locally-managed, its routing rules can't be edited there, and
dashboard log streams aren't available.

Check that the tunnel connected:

```sh
kubectl -n cloudflare logs deployment/cloudflared | grep "Registered tunnel connection"
```

From the command line, which requires `cert.pem` from `cloudflared tunnel login`:

```sh
cloudflared tunnel info griffin
```

## Adding a Service

1. Add a listener to `cloudflare.gateway.listeners.http` in
   [traefik.yaml](../infrastructure/templates/traefik.yaml), using a hostname
   `<name>.{{ .Values.domain.tunnel }}` and the service namespace.
2. Add an HTTPRoute with `parentRefs` set to Gateway `traefik-cloudflare` in namespace `traefik`.

[tunnel]: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
[local]: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/
[install]: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/downloads/
[dashboard]: https://dash.cloudflare.com/
