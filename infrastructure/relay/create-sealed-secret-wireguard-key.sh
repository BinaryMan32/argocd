#!/usr/bin/bash
# Creates the WireGuard private key for the cluster end of the tunnel.
# Requires docker for wg from the relay image, and kubectl using the cluster context for kubeseal.
set -e
script_dir=$(dirname $(realpath $0))

image=$(yq --raw-output '.image.repository + ":" + .image.tag' "$script_dir/values.yaml")
wg() {
    docker run --rm --interactive --network=none --entrypoint=wg "$image" "$@"
}

private_key=$(wg genkey)
echo "Set wireguard_cluster_public_key in relay/group_vars/relay.yml to:"
echo "$private_key" | wg pubkey

kubectl create secret generic \
    --dry-run=client \
    --namespace=relay \
    relay-wireguard-key \
    --from-literal=private-key="$private_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-wireguard-key.yaml
