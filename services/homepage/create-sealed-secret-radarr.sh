#!/usr/bin/bash
set -euo pipefail
script_dir=$(dirname $(realpath $0))

# radarr has a single full-admin API key, read it from its config
api_key=$(kubectl --namespace=media exec deploy/radarr -- \
    sed -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' /config/config.xml)

kubectl create secret generic \
    --dry-run=client \
    --namespace=homepage \
    homepage-radarr \
    --from-literal=HOMEPAGE_VAR_RADARR_KEY="$api_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-homepage-radarr.yaml
