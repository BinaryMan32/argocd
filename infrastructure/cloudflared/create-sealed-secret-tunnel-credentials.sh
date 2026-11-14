#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

echo "Create the tunnel first (see README.md):"
echo "  cloudflared tunnel login"
echo "  cloudflared tunnel create griffin"
read -e -p 'enter path to tunnel credentials file (~/.cloudflared/<UUID>.json) > ' credentials_file

kubectl create secret generic \
    --dry-run=client \
    --namespace=cloudflare \
    cloudflared-tunnel-credentials \
    --from-file=credentials.json="${credentials_file/#\~/$HOME}" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-tunnel-credentials.yaml
