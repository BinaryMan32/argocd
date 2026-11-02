#!/usr/bin/bash
# Exports the desktop Libation master key, which encrypts the tokens in AccountsSettings.json,
# into a sealed secret mounted by the deployment via LIBATION_MASTER_KEY_FILE.
# Set KUBECTL_ARGS to pass extra arguments to kubeseal, e.g. KUBECTL_ARGS="--context griffin"
set -euo pipefail
script_dir=$(dirname "$(realpath "$0")")

umask 077
tmp_dir=$(mktemp -d)
trap 'shred -u "$tmp_dir"/* 2>/dev/null; rm -rf "$tmp_dir"' EXIT

libationcli export-master-key "$tmp_dir/libation-master.key" > /dev/null

kubectl create secret generic \
    --dry-run=client \
    --namespace=media \
    libation-master-key \
    --from-file=libation-master.key="$tmp_dir/libation-master.key" \
    --output=yaml |
kubeseal ${KUBECTL_ARGS:-} --format=yaml --sealed-secret-file="$script_dir/resources/sealed-secret-libation-master-key.yaml"
