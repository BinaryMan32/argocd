# relay

A VPS with a public IP address that relays inbound connections to the cluster,
since the home internet connection is behind CGNAT and has no public IP address
for inbound connections.

It is configured with [Ansible][], see [playbook.yml](./playbook.yml).

## Linode

The VPS is a Linode Nanode 1 GB in Chicago (`us-ord`) running Debian.

The `root` password is only used for the Lish console, which is the fallback if SSH
is unreachable. It is stored in the password manager. SSH only allows key authentication.

Its Cloud Firewall drops inbound traffic by default and accepts outbound traffic.
Inbound rules:

| Label | Protocol | Port | Source |
| --- | --- | --- | --- |
| ssh-home | TCP | 22 | home public IP address `/32` |
| icmp | ICMP | | all IPv4 and IPv6 |
| wireguard-relay | UDP | 51820 | all IPv4 |
| wireguard-vpn | UDP | 14585 | all IPv4 |
| https | TCP | 443 | all IPv4 |

When the home public IP address changes, update the `ssh-home` rule.
`wireguard-relay` allows all sources, since WireGuard ignores packets that aren't from a known key,
and the tunnel keeps working if the home public IP address changes.
The VPS also runs nftables with similar rules, see [nftables.conf.j2](./templates/nftables.conf.j2).

## WireGuard

The cluster starts a WireGuard tunnel to the VPS, see [infrastructure/relay](../infrastructure/relay/README.md).
The VPS end is `10.99.0.1`, the cluster end is `10.99.0.2`.

The playbook generates the VPS private key on the VPS, and prints the public key at the end of each run.
The cluster public key is set in [group_vars/relay.yml](./group_vars/relay.yml).

Check the tunnel on the VPS:

```sh
ansible relay -a "wg show"
```

## Forwarded Ports

The UDP ports in `forwarded_udp_ports` in [group_vars/relay.yml](./group_vars/relay.yml)
are forwarded through the tunnel to the cluster end, which forwards them on to their destination,
see `forwards` in [infrastructure/relay/values.yaml](../infrastructure/relay/values.yaml).
Each port also needs a Cloud Firewall rule.

```text
client → VPS public IP:port → tunnel → cluster pod → destination:port
```

The VPS replaces the client's address with its tunnel address `10.99.0.1`, since the cluster end
only accepts packets from that address, and sends replies back through the tunnel.

## HTTPS

HAProxy forwards HTTPS through the tunnel to the cluster end, which forwards it to the Traefik
`websecure-relay` entrypoint. It doesn't decrypt the connections. It closes connections without a hostname
in the TLS handshake, e.g. scanners connecting to the IP address, and Traefik rejects unknown hostnames.
Each connection starts with a PROXY protocol header containing the client IP address.

```text
client → VPS public IP:443 → HAProxy → tunnel → cluster pod → Traefik websecure-relay
```

A hostname also needs an HTTPRoute on the `traefik-external` Gateway, which makes external-dns create
its DNS record.

## DNS

`relay.wildfreddy.net` is a DNS only `A` record created by hand in the Cloudflare dashboard,
pointing at the public IP address of the VPS. The `direct` instance of
[external-dns](../infrastructure/external-dns/README.md) creates `CNAME` records to it.

`vpn.wildfreddy.net` is a DNS only `CNAME` to it created by hand, used as the endpoint
`vpn.wildfreddy.net:14585` by the clients of the UniFi WireGuard VPN server.
It can't be proxied, since the Cloudflare proxy doesn't forward UDP.

At home, UniFi `Dest. NAT` policies redirect connections to the VPS public IP address
to their destination on the internal network, so clients at home don't go through the relay.
Clients use the same address on both networks, so they don't need a new DNS lookup when they move.
The policies share the UniFi network list `Relay Host IP`.

## Usage

Install Ansible, for example `sudo apt install ansible`, then run from this directory:

```sh
# check connectivity
ansible relay -m ping
# show changes without making them
ansible-playbook playbook.yml --check --diff
# make the changes
ansible-playbook playbook.yml --diff
```

Unattended upgrades install Debian stable and security updates daily,
and reboot at 10:00 UTC when an update requires it.

## Rebuild

1. Create the Linode with the Debian image, a root password and an SSH key,
   and attach the Cloud Firewall.
2. If the IP address changed, update `relay.wildfreddy.net` and the UniFi network list `Relay Host IP`.
3. Compare the SSH host key fingerprint with the output of
   `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` in the Lish console,
   then connect once with `ssh root@relay.wildfreddy.net` to accept it.
4. Run the playbook. A new VPS has a new WireGuard key, so set `vps.publicKey` in
   [infrastructure/relay/values.yaml](../infrastructure/relay/values.yaml) to the printed public key,
   and `vps.address` if the IP address changed.

[Ansible]: https://docs.ansible.com/
