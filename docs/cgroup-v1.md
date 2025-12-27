# cgroup v1

Kubernetes `1.35.0` and later deprecated cgroup v1 support and will fail to start with error:

```text
failed to validate kubelet configuration, error: kubelet is configured to not run on a host using cgroup v1. cgroup v1 support is unsupported and will be removed in a future release
```

According to [About cgroup v2](https://kubernetes.io/docs/concepts/architecture/cgroups/) use of the deprecated cgroup v1 can be allowed by configuring `failCgroupV1: false`, but it will be completely removed in a year, or `1.38.0`.

## Configuration

This is only required on turing rk1 nodes which are still running ubuntu 22.04.

```sh
for host in griffin{0..8}; do
  cat docs/40-allow-cgroup-v1.conf | ssh $host sudo tee /var/lib/rancher/k3s/agent/etc/kubelet.conf.d/40-allow-cgroup-v1.conf
done
```

This should be done before upgrading to kubernetes `1.35.0`.
Since the upgrade process will restart all nodes, no manual restart is needed.
