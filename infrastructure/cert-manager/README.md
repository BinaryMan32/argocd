# cert-manager

Deploy [cert-manager][] to manage and issue TLS certificates.

## Issuers

Creates `ClusterIssuer`s which use the [dns01][] solver to create certificates:

| Issuer | DNS zones |
| --- | --- |
| `intranet-dns01-prod`, `intranet-dns01-staging` | `intranet.dnsZones` |
| `external-dns01-prod`, `external-dns01-staging` | `external.dnsZones` |

The DNS zones are set in [cert-manager.yaml](../infrastructure/templates/cert-manager.yaml).

The [dns01][] solver requires the `cloudflare-dns-fbs` secret to change DNS records, which are verified by Let's Encrypt servers.
This secret is created by running `infrastructure/cert-manager/create-sealed-secret-cloudflare-dns01.sh`.

[dns01]: https://cert-manager.io/docs/configuration/acme/dns01/

## Certificates

Certificates are created explicitly as `Certificate` resources, not from Gateway annotations,
so cert-manager's Gateway API support isn't enabled. Gateway listener certificates are created using
`wildcardCertificates` in [traefik.yaml](../infrastructure/templates/traefik.yaml).

## References

See the following cert-manager resources for additional information:

* [Installing with Helm][cert-manager-helm]

[cert-manager]: https://github.com/jetstack/cert-manager
[cert-manager-helm]: https://cert-manager.io/docs/installation/helm/
