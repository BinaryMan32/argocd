# Non-root Devices

Devices given to a container, such as `devic.es/rkmpp` from
[generic-device-plugin-rk3588](../infrastructure/generic-device-plugin-rk3588/README.md),
keep the host's owner and mode by default.
Most Rockchip devices are `root:root` mode `600`, so only a container running
as root can open them.

The k3s `nonroot-devices` option sets containerd's
`device_ownership_from_security_context`, which creates a container's device
files owned by the pod's `runAsUser` and `runAsGroup` instead.
Host device files are unchanged, and containers running as root or privileged
are unaffected.
See [Non-root containers and devices](https://kubernetes.io/blog/2021/11/09/non-root-containers-and-devices/).

## Cluster Setup

Push configuration files.

```sh
for host in griffin{0..9}; do
  ssh $host sudo mkdir -p /etc/rancher/k3s/config.yaml.d
  cat docs/nonroot-devices.yaml | ssh $host sudo tee /etc/rancher/k3s/config.yaml.d/nonroot-devices.yaml
done
```

Restart k3s on each host, which regenerates the containerd config.
Running containers keep running.

```sh
for host in griffin{0..9}; do
  echo $host
  ssh $host sudo systemctl restart k3s-agent || ssh $host sudo systemctl restart k3s
done
```

If necessary, `ssh` into the failed host and view logs for troubleshooting.

```sh
journalctl -xeu k3s.service        # servers
journalctl -xeu k3s-agent.service  # agents
```

## Checking Configs

```sh
for host in griffin{0..9}; do
  ssh $host sudo cat /var/lib/rancher/k3s/agent/etc/containerd/config.toml | grep --with-filename --label=$host device_ownership_from_security_context
done
```

Expected output:

```text
griffin9:  device_ownership_from_security_context = true
```
