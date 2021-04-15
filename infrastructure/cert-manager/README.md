# cert-manager

Deploy [cert-manager][] to manage and issue TLS certificates.

## Intranet CA

Creates a `ClusterIssuer` which acts as a certificate authority using a
self-signed root certificate, as decribed in
[cert-manager self-signed configuration][cert-manager-ca].

To have an ingress automatically generate a certificate signed by the
`intranet-ca` issuer, add:
```yaml
annotations:
  cert-manager.io/cluster-issuer: intranet-ca
```

[cert-manager-ca]: https://cert-manager.io/docs/configuration/selfsigned/

## References

See the following cert-manager resources for additional information:
* [Securing NGINX-ingress][cert-manager-nginx]
* [Installing with Helm][cert-manager-helm]

[cert-manager]: https://github.com/jetstack/cert-manager
[cert-manager-nginx]: https://cert-manager.io/docs/tutorials/acme/ingress/#step-5-deploy-cert-manager
[cert-manager-helm]: https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm