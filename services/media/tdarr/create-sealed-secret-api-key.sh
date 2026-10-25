#!/usr/bin/bash
set -euo pipefail
script_dir=$(dirname $(realpath $0))

# The server seeds this key on startup, nodes and the homepage widget use it to connect.
# Format required by seededApiKey: https://docs.tdarr.io/docs/other/authentication
api_key="tapi_$(openssl rand -hex 16)"

kubectl create secret generic \
    --dry-run=client \
    --namespace=media \
    tdarr-api-key \
    --from-literal=api-key="$api_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-tdarr-api-key.yaml

kubectl create secret generic \
    --dry-run=client \
    --namespace=homepage \
    homepage-tdarr \
    --from-literal=HOMEPAGE_VAR_TDARR_KEY="$api_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/../../homepage/templates/sealed-secret-homepage-tdarr.yaml
