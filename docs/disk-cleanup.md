# Disk Cleanup

## Cluster Setup

Push configuration files.

```sh
for host in griffin{0..9}; do
  cat docs/50-kubelet-image-gc.conf | ssh $host sudo tee /var/lib/rancher/k3s/agent/etc/kubelet.conf.d/50-kubelet-image-gc.conf
done
```

Restart k3s on each `HOST`.

```sh
for host in griffin{0,4,7}; do
  echo $host
  ssh $host sudo systemctl restart k3s
done
```

```sh
for host in griffin{1,2,3,5,6,8,9}; do
  echo $host
  ssh $host sudo systemctl restart k3s-agent
done
```

If necessary, `ssh` into the failed host and view logs for troubleshooting.

```sh
journalctl -xeu k3s.service
```

## Checking Configs

In another terminal (Lens suggested)

```sh
kubectl proxy
```

```sh
for node in griffin{0..9}; do
  curl --silent http://127.0.0.1:8001/api/v1/nodes/$node/proxy/configz | jq --arg node $node --compact-output '.kubeletconfig | {node: $node, imageMinimumGCAge, imageMaximumGCAge, imageGCHighThresholdPercent, imageGCLowThresholdPercent}'
done
```

Expected output:

```json
{"node":"griffin9","imageMinimumGCAge":"2m0s","imageMaximumGCAge":"168h0m0s","imageGCHighThresholdPercent":70,"imageGCLowThresholdPercent":50}
```

Kill `kubectl proxy`.

## Checking Storage

```sh
for h in griffin{0..9}; do ssh $h df -h / | grep --with-filename --label=$h /dev/; done
```
