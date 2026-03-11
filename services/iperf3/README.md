# iperf3

Runs an iperf server in the cluster for speed tests.

## From LAN

Test client to server.

```sh
iperf3 --client iperf3.int.fivebytestudios.com --verbose
```

Test server to client.

```sh
iperf3 --client iperf3.int.fivebytestudios.com --verbose --reverse
```

Add `--udp` to test UDP instead of TCP.
