#!/bin/sh
# https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md#qbittorrent-example
PORTS="$1"
echo "VPN PORTS=$PORTS"
PORTS_JSON="{\"listen_port\":\"$PORTS\"}"
echo "VPN PORTS_JSON=$PORTS_JSON"
wget -O- --retry-connrefused --post-data "json=$PORTS_JSON" http://127.0.0.1:8080/api/v2/app/setPreferences 2>&1
