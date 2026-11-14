# external-dns

Deploys [external-dns][] to create Cloudflare DNS records for HTTPRoutes attached
to the `traefik-cloudflare` Gateway. See [cloudflared](../cloudflared/README.md).

* Only manages records in the `wildfreddy.net` zone (`domainFilters`, `zone-id-filter`).
* Records are `CNAME`s to `<tunnel UUID>.cfargotunnel.com`, taken from the
  `external-dns.kubernetes.io/target` annotation on the Gateway, and are always proxied.
* Uses `policy: sync`, so records are deleted when routes are removed.
  Ownership is tracked using `TXT` records, so records created by hand are never changed.

## Initial Setup

1. Set `cloudflare.tunnelZoneId` in [values.yaml](../infrastructure/values.yaml)
   to the Zone ID shown on the `wildfreddy.net` overview page in the Cloudflare dashboard.
2. Run [create-sealed-secret-cloudflare-api-token.sh](./create-sealed-secret-cloudflare-api-token.sh)
   to create the `cloudflare-api-token` sealed secret.

Check the records that were created:

```sh
kubectl -n cloudflare logs deployment/external-dns
```

[external-dns]: https://github.com/kubernetes-sigs/external-dns
