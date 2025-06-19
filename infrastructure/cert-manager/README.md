# cert-manager

Deploy [cert-manager][] to manage and issue TLS certificates.

## Intranet

Creates a `ClusterIssuer` named `intranet-dns01-prod` which uses the [dns01][] solver to create certificates.

To have an ingress automatically generate a certificate, add:
```yaml
annotations:
  cert-manager.io/cluster-issuer: intranet-dns01-prod
```

The [dns01][] solver requires the `cloudflare-dns-fbs` secret to change DNS records, which are verified by Let's Encrypt servers.
This secret is created by running `infrastructure/cert-manager/create-sealed-secret-cloudflare-dns01.sh`.

[dns01]: https://cert-manager.io/docs/configuration/acme/dns01/

## References

See the following cert-manager resources for additional information:
* [Securing NGINX-ingress][cert-manager-nginx]
* [Installing with Helm][cert-manager-helm]

[cert-manager]: https://github.com/jetstack/cert-manager
[cert-manager-nginx]: https://cert-manager.io/docs/tutorials/acme/ingress/#step-5-deploy-cert-manager
[cert-manager-helm]: https://cert-manager.io/docs/installation/helm/
