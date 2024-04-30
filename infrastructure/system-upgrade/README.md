# system-upgrade

Automatic kubernetes upgrades

See https://docs.k3s.io/upgrades/automated

To enable automated updates:
```sh
kubectl label nodes --all k3s-upgrade=enabled
```
