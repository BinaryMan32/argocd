#!/usr/bin/bash
set -euo pipefail
script_dir=$(dirname $(realpath $0))

# sonarr has a single full-admin API key, read it from its config
api_key=$(kubectl --namespace=media exec deploy/sonarr -- \
    sed -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' /config/config.xml)

kubectl create secret generic \
    --dry-run=client \
    --namespace=homepage \
    homepage-sonarr \
    --from-literal=HOMEPAGE_VAR_SONARR_KEY="$api_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-homepage-sonarr.yaml
