#!/usr/bin/bash
# Seals an Audiobookshelf API key, used by the cronjob to scan the library after importing books.
# Library scans require an admin, so create the key for a dedicated admin user (e.g. libation-scan)
# under Settings -> Users and Settings -> API Keys in Audiobookshelf.
# Set KUBECTL_ARGS to pass extra arguments to kubeseal, e.g. KUBECTL_ARGS="--context griffin"
set -euo pipefail
script_dir=$(dirname "$(realpath "$0")")

read -rs -p 'Audiobookshelf API key > ' api_key
echo

kubectl create secret generic \
    --dry-run=client \
    --namespace=media \
    libation-audiobookshelf-api-key \
    --from-literal=api-key="$api_key" \
    --output=yaml |
kubeseal ${KUBECTL_ARGS:-} --format=yaml --sealed-secret-file="$script_dir/resources/sealed-secret-libation-audiobookshelf-api-key.yaml"
