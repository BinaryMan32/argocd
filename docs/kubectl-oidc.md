# kubectl OIDC

## User Setup

Install plugin `oidc-login`

```sh
kubectl krew install oidc-login
```

Set up configuration

```sh
kubectl oidc-login setup --oidc-issuer-url=https://auth.int.fivebytestudios.com --oidc-client-id=kubectl
```

## Cluster Setup

TODO
