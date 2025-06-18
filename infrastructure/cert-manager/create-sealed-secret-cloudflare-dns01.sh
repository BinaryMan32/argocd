#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

echo "Go to https://dash.cloudflare.com/profile/api-tokens"
echo "Create a new API Token which can edit only fivebytestudios.com DNS records"
echo "Allow the token to only by used from the correct IP address"
read -e -p 'enter token > ' cloudflare_token

kubectl create secret generic \
    --dry-run=client \
    --namespace=cert-manager \
    cloudflare-dns-fbs \
    --from-literal=token="$cloudflare_token" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-cloudflare-dns-fbs.yaml
