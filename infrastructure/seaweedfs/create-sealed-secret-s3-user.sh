#!/usr/bin/bash
# Usage: create-sealed-secret-s3-user.sh <user> [kubeseal args...]
# Creates the sealed secret seaweedfs-s3-user-<user> with random credentials.
# Set ACCESS_KEY_ID and SECRET_ACCESS_KEY to use existing credentials instead.
# Remaining arguments are passed to kubeseal, e.g. --context griffin
set -euo pipefail
script_dir=$(dirname $(realpath $0))
user="$1"
kubeseal_args=("${@:2}")

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c $1
}

secret_name="seaweedfs-s3-user-${user}"

kubectl create secret generic \
    --dry-run=client \
    --namespace=seaweedfs \
    "${secret_name}" \
    --from-literal=access-key-id="${ACCESS_KEY_ID:-$(print_random 32)}" \
    --from-literal=secret-access-key="${SECRET_ACCESS_KEY:-$(print_random 64)}" \
    --output=yaml |
kubeseal "${kubeseal_args[@]}" --format=yaml --sealed-secret-file="$script_dir/templates/sealed-secret-${secret_name}.yaml"
