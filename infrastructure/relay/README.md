# relay

Connects the cluster to the [relay VPS](../../relay/README.md) with a WireGuard tunnel.
The home connection is behind CGNAT, so the tunnel is started from the cluster,
and the VPS sends inbound connections back through it.

```text
cluster pod 10.99.0.2 → home router → CGNAT → VPS 10.99.0.1, UDP 51820
```

* WireGuard runs in the node kernel (`CONFIG_WIREGUARD=m` in the Rockchip kernel).
  The pod creates the `wg0` interface in its own network namespace, which needs `NET_ADMIN`.
  `NET_ADMIN` only applies to that namespace, not the node.
* The image only provides the tools. [run.sh](./templates/configmap.yaml) runs `wg-quick`
  instead of the image's OpenRC init.
* The private key is in a sealed secret. `wg0.conf` sets it with `PostUp`,
  so the config can be a ConfigMap.
* The [NetworkPolicy](./templates/network-policy.yaml) only allows the tunnel to the VPS.
  It's enforced on the node, so the pod can't change it, and it limits where traffic
  from the tunnel can go even if the VPS is compromised.
* There is one replica, since the VPS has one peer for the key.
  The pod is ready while its last handshake with the VPS is less than 3 minutes old.

## Initial Setup

1. With `kubectl` using the cluster context, run
   [create-sealed-secret-wireguard-key.sh](./create-sealed-secret-wireguard-key.sh).
   It runs `wg` from the image in [values.yaml](./values.yaml) with docker,
   creates the `relay-wireguard-key` sealed secret, and prints the public key.
2. Set `wireguard_cluster_public_key` in [group_vars/relay.yml](../../relay/group_vars/relay.yml)
   to the public key, and run the playbook.
3. Set `vps.publicKey` in [values.yaml](./values.yaml) to the public key printed by the playbook.

## Verification

```sh
kubectl -n relay get pods
kubectl -n relay exec deploy/relay -- wg show
kubectl -n relay exec deploy/relay -- ping -c 3 10.99.0.1
```

Throughput test, with an `iperf3` server in a debug container sharing the pod's network:

```sh
kubectl -n relay debug -it deploy/relay --image=nicolaka/netshoot --profile=general -- iperf3 -s
# on the VPS, after `apt install iperf3`: VPS to cluster, then cluster to VPS
iperf3 -c 10.99.0.2 -t 30
iperf3 -c 10.99.0.2 -t 30 -R
```
