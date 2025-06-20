# kubectl OIDC

## User Setup

Install plugin `oidc-login`

```sh
kubectl krew install oidc-login
```

Set up configuration

```sh
kubectl oidc-login setup \
  --oidc-issuer-url=https://auth.int.fivebytestudios.com \
  --oidc-client-id=kubectl \
  --oidc-extra-scope=email,groups
```

For additional info to debug, append `-v 1` or a higher number for more info.

## Cluster Setup

Push configuration files.

```sh
for host in griffin{0,4,7}; do
  cat docs/apiserver-authentication-config.yaml | ssh $host sudo tee /etc/rancher/k3s/apiserver-authentication-config.yaml
  ssh $host sudo mkdir -p /etc/rancher/k3s/config.yaml.d
  cat docs/kube-apiserver-arg.yaml | ssh $host sudo tee /etc/rancher/k3s/config.yaml.d/kube-apiserver-arg.yaml
done
```

Restart k3s on each `HOST`.

```sh
ssh HOST sudo systemctl restart k3s
```

If necessary, `ssh` into the failed host and view logs for troubleshooting.

```sh
journalctl -xeu k3s.service
```
