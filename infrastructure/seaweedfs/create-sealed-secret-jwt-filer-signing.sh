#!/usr/bin/bash
# Usage: create-sealed-secret-jwt-filer-signing.sh
# Creates the sealed secret seaweedfs-jwt-filer-signing with a random `jwt.filer_signing.key`.
# Set KUBESEAL_ARGS to pass extra arguments to kubeseal, e.g. KUBESEAL_ARGS="--context griffin"
set -euo pipefail
script_dir=$(dirname $(realpath $0))
secret_name="seaweedfs-jwt-filer-signing"

# Based on https://github.com/lldap/lldap/blob/main/generate_secrets.sh
# Reads a fixed amount of random data, since `tr </dev/urandom | head` fails with pipefail
print_random () {
  local random
  random=$(head -c 1024 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9')
  printf '%s' "${random:0:$1}"
}

kubectl create secret generic \
    --dry-run=client \
    --namespace=seaweedfs \
    "${secret_name}" \
    --from-literal=key="$(print_random 64)" \
    --output=yaml |
kubeseal ${KUBESEAL_ARGS:-} --format=yaml --sealed-secret-file="$script_dir/templates/sealed-secret-${secret_name}.yaml"
