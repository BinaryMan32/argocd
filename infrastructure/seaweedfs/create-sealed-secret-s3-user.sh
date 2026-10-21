#!/usr/bin/bash
# Usage: create-sealed-secret-s3-user.sh <user> [<namespace> <secret-name> <output-dir>]
# Creates the sealed secret seaweedfs-s3-user-<user> with random credentials.
# If <namespace> is given, also seals the same credentials as <secret-name> in that namespace,
# written to <output-dir> (relative to this script).
# Set ACCESS_KEY_ID and SECRET_ACCESS_KEY to use existing credentials instead.
# Set KUBESEAL_ARGS to pass extra arguments to kubeseal, e.g. KUBESEAL_ARGS="--context griffin"
set -euo pipefail
script_dir=$(dirname $(realpath $0))
user="$1"
client_namespace="${2:-}"
client_secret_name="${3:-}"
client_output_dir="${4:-}"

# Based on https://github.com/lldap/lldap/blob/main/generate_secrets.sh
# Reads a fixed amount of random data, since `tr </dev/urandom | head` fails with pipefail
print_random () {
  local random
  random=$(head -c 1024 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9')
  printf '%s' "${random:0:$1}"
}

access_key_id="${ACCESS_KEY_ID:-$(print_random 32)}"
secret_access_key="${SECRET_ACCESS_KEY:-$(print_random 64)}"

create_sealed_secret () {
  secret_namespace="$1"
  secret_name="$2"
  output_file_path="$3"
  mkdir -p "$(dirname "$output_file_path")"
  kubectl create secret generic \
      --dry-run=client \
      --namespace="${secret_namespace}" \
      "${secret_name}" \
      --from-literal=access-key-id="${access_key_id}" \
      --from-literal=secret-access-key="${secret_access_key}" \
      --output=yaml |
  kubeseal ${KUBESEAL_ARGS:-} --format=yaml --sealed-secret-file="${output_file_path}"
}

create_sealed_secret seaweedfs "seaweedfs-s3-user-${user}" \
    "$script_dir/templates/sealed-secret-seaweedfs-s3-user-${user}.yaml"

if [ -n "$client_namespace" ]; then
  create_sealed_secret "$client_namespace" "$client_secret_name" \
      "$script_dir/$client_output_dir/sealed-secret-${client_secret_name}.yaml"
fi
