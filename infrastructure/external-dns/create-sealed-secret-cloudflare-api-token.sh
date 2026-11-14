#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

cat <<'EOF'
Go to https://dash.cloudflare.com/profile/api-tokens and select "Create Token"
  Token name: griffin external-dns
  Policies: "Start from scratch" > "Start with a Zone policy", including only
  the wildfreddy.net zone (not all zones), with permissions:
    Zone Read - look up the zone
    DNS Write/Edit - create, update and delete records
  Token expiration: No expiration
  Client IP address filtering: Clicking offers to "Use your IP address"
Create the token and copy it, it is only shown once.
EOF
read -e -p 'enter token > ' cloudflare_token

kubectl create secret generic \
    --dry-run=client \
    --namespace=cloudflare \
    cloudflare-api-token \
    --from-literal=token="$cloudflare_token" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-cloudflare-api-token.yaml
