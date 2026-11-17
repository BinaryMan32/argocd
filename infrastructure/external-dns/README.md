# external-dns

Deploys [external-dns][] to create Cloudflare DNS records for HTTPRoutes attached
to Gateways in the `traefik` namespace. One instance runs per Gateway, since the
proxy setting can only be set on each HTTPRoute, not on a Gateway. This way the
Gateway a route is attached to decides whether its record is proxied.

| Instance | Gateway | Record | Proxied |
| --- | --- | --- | --- |
| `tunnel` | `traefik-cloudflare` | `CNAME` to `<tunnel UUID>.cfargotunnel.com`, see [cloudflared](../cloudflared/README.md) | yes |
| `direct` | `traefik-external` | `CNAME` to `relay.wildfreddy.net` | no |

* Only manages records in the `wildfreddy.net` zone (`domainFilters`, `zone-id-filter`),
  so routes on `traefik-external` with other hostnames are ignored.
* The `CNAME` target is taken from the `external-dns.kubernetes.io/target` annotation on the Gateway.
* Attach each route to only one of these Gateways. Otherwise both instances
  would try to create a record with the same name.
* Uses `policy: sync`, so records are deleted when routes are removed.
  Ownership is tracked using `TXT` records with a separate `txtOwnerId` per instance,
  so each instance only changes its own records. Records created by hand,
  such as `relay.wildfreddy.net`, are never changed.

## Initial Setup

1. Set `cloudflare.zoneId` in [values.yaml](../infrastructure/values.yaml)
   to the Zone ID shown on the `wildfreddy.net` overview page in the Cloudflare dashboard.
2. Run [create-sealed-secret-cloudflare-api-token.sh](./create-sealed-secret-cloudflare-api-token.sh)
   to create the `cloudflare-api-token` sealed secret.
3. In the Cloudflare dashboard, create a DNS only `A` record `relay.wildfreddy.net`
   with the public IP address of the relay VPS. It isn't updated automatically,
   so update it when the VPS is rebuilt with a new address.
   The API token IP filters are separate: they hold the home public IP address,
   which is the source address of requests made by the cluster.

Check the records that were created:

```sh
kubectl -n cloudflare logs deployment/external-dns-tunnel
kubectl -n cloudflare logs deployment/external-dns-direct
```

[external-dns]: https://github.com/kubernetes-sigs/external-dns
