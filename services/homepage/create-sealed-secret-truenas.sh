#!/usr/bin/bash
set -euo pipefail
script_dir=$(dirname $(realpath $0))

echo "Go to https://192.168.0.8/ui/credentials/users and add user 'homepage' with:"
echo "  Full Name: Homepage"
echo "  Disable Password: on"
echo "  Create new primary group: off"
echo "  Primary Group: truenas_readonly_administrators"
echo "  Shell: nologin"
echo "  SMB User: off"
echo "Go to API Keys, add key 'Homepage' for user 'homepage', non-expiring"
read -e -p 'enter API Key > ' api_key

kubectl create secret generic \
    --dry-run=client \
    --namespace=homepage \
    homepage-truenas \
    --from-literal=HOMEPAGE_VAR_TRUENAS_KEY="$api_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-homepage-truenas.yaml
